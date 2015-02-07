require 'spec_helper'
require File.dirname(__FILE__) + "/../lib/yap/line/lexer"

describe Yap::Line::Lexer do
  subject { described_class.new.tokenize(str) }

  def t(tag, val, lineno:0, attrs:{})
    Yap::Line::Lexer::Token.new(tag, val, lineno:lineno, attrs:attrs)
  end

  describe "empty string" do
    let(:str){ "" }
    it { should eq [] }
  end

  describe "env variables" do
    let(:str){ "foo $baz" }
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Argument, "$baz", lineno:0)
      ]}
  end

  context "argument parsing" do
    describe "commands with no args" do
      let(:str){ "ls" }
      it { should eq [
        t(:Command, "ls", lineno:0)
      ]}
    end

    describe "commands with a simple arg: ls foo" do
      let(:str){ "ls foo" }
      it { should eq [
        t(:Command, "ls", lineno:0),
        t(:Argument, "foo", lineno:0)
      ]}
    end

    describe "commands with a simple arg: ls -al" do
      let(:str){ "ls -al" }
      it { should eq [
        t(:Command, "ls", lineno:0),
        t(:Argument, "-al", lineno:0)
      ]}
    end

    describe "commands with multiple args: ls -al foo bar -baz" do
      let(:str){ "ls -al foo bar -baz" }
      it { should eq [
        t(:Command, "ls", lineno:0),
        t(:Argument, "-al", lineno:0),
        t(:Argument, "foo", lineno:0),
        t(:Argument, "bar", lineno:0),
        t(:Argument, "-baz", lineno:0)
      ]}
    end

    context "single quoted args" do
      describe "simple args: ls 'hello there'" do
        let(:str){ "ls 'hello there'" }
        it { should eq [
          t(:Command, "ls", lineno:0),
          t(:Argument, "hello there", lineno:0)
        ]}
      end

      describe "nested single quotes: ls 'hello \\'there\\''" do
        let(:str){ "ls 'hello \\'there\\''" }
        it { should eq [
          t(:Command, "ls", lineno:0),
          t(:Argument, "hello 'there'", lineno:0)
        ]}
      end

      describe "nested double quotes: ls 'hello \"there\"'" do
        let(:str){ %|ls 'hello "there"'| }
        it { should eq [
          t(:Command, "ls", lineno:0),
          t(:Argument, 'hello "there"', lineno:0)
        ]}
      end

      describe "multiple levels of nested single quotes: ls 'hello \\'there \\\\'guy\\\\' \\''" do
        let(:str){ "ls 'hello \\'there \\\\'guy\\\\' \\''" }
        it { should eq [
          t(:Command, "ls", lineno:0),
          t(:Argument, "hello 'there \\'guy\\' '", lineno:0)
        ]}
      end

      describe "multiple single quoted args: ls 'hello \\'there \\'' 'how are \\'you\\'?'" do
        let(:str){ "ls 'hello \\'there\\'' 'how are \\'you\\'?'" }
        it { should eq [
          t(:Command, "ls", lineno:0),
          t(:Argument, "hello 'there'", lineno:0),
          t(:Argument, "how are 'you'?", lineno:0)
        ]}
      end
    end

    context 'double quoted args' do
      describe 'simple args: ls "hello there"' do
        let(:str){ 'ls "hello there"' }
        it { should eq [
          t(:Command, 'ls', lineno:0),
          t(:Argument, 'hello there', lineno:0)
        ]}
      end

      describe 'nested singled quotes: ls "hello \'there\'"' do
        let(:str){ %|ls "hello 'there'"| }
        it { should eq [
          t(:Command, 'ls', lineno:0),
          t(:Argument, "hello 'there'", lineno:0)
        ]}
      end

      describe 'nested double quotes: ls "hello \\"there\\""' do
        let(:str){ 'ls "hello \\"there\\""' }
        it { should eq [
          t(:Command, 'ls', lineno:0),
          t(:Argument, 'hello "there"', lineno:0)
        ]}
      end

      describe 'multiple levels of nested double quotes: ls "hello \\"there \\\\"guy\\\\" \\""' do
        let(:str){ 'ls "hello \\"there \\\\"guy\\\\" \\""' }
        it { should eq [
          t(:Command, 'ls', lineno:0),
          t(:Argument, 'hello "there \\"guy\\" "', lineno:0)
        ]}
      end

      describe 'multiple double quoted args: ls "hello \\"there \\"" "how are \\"you\\"?"' do
        let(:str){ 'ls "hello \\"there\\"" "how are \\"you\\"?"' }
        it { should eq [
          t(:Command, 'ls', lineno:0),
          t(:Argument, 'hello "there"', lineno:0),
          t(:Argument, 'how are "you"?', lineno:0)
        ]}
      end
    end
  end

  context "statements" do
    ["foo;baz", "foo; baz", "foo ;baz", "foo ; baz", "foo     ;    baz"].each do |src|
      describe "are separated by a semi-colon: #{src.inspect}" do
        let(:str){ "foo ; baz"}
        it { should eq [
          t(:Command, "foo", lineno:0),
          t(:Terminator, ";", lineno:0),
          t(:Command, "baz", lineno:0)
        ]}
      end
    end

    ["foo&&baz", "foo&& baz", "foo &&baz", "foo && baz", "foo     &&    baz"].each do |src|
      describe "are separated by double ampersands: #{src.inspect}" do
        let(:str){ "foo && baz"}
        it { should eq [
          t(:Command, "foo", lineno:0),
          t(:ConditionalTerminator, "&&", lineno:0),
          t(:Command, "baz", lineno:0)
        ]}
      end
    end

    ["foo||baz", "foo|| baz", "foo ||baz", "foo || baz", "foo     ||    baz"].each do |src|
      describe "are separated by double ampersands: #{src.inspect}" do
        let(:str){ "foo || baz"}
        it { should eq [
          t(:Command, "foo", lineno:0),
          t(:ConditionalTerminator, "||", lineno:0),
          t(:Command, "baz", lineno:0)
        ]}
      end
    end
  end

  context "heredoc tokens" do
    describe "started by starting with double arrows followed by a character: foo <<E" do
      let(:str){ "foo <<E"}
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "E", lineno:0)
      ]}
    end

    describe "started by starting with double arrows followed by multiple character: foo <<FOO" do
      let(:str){ "foo <<FOO"}
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "FOO", lineno:0)
      ]}
    end

    describe "started by starting with double arrows followed by numbers characters: foo <<FOO" do
      let(:str){ "foo <<12"}
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "12", lineno:0)
      ]}
    end

    describe "started by starting with double arrows followed by a mixture of alphanumeric characters: foo <<L337" do
      let(:str){ "foo <<L337"}
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "L337", lineno:0)
      ]}
    end
  end

end
