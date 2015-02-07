require 'spec_helper'
require File.dirname(__FILE__) + "/../lib/yap/line/lexer"

describe Yap::Line::Lexer do
  subject { described_class.new.tokenize(str) }

  def t(val, lineno:0, attrs:{})
    Yap::Line::Lexer::Token.new(val, lineno:lineno, attrs:attrs)
  end

  describe "empty string" do
    let(:str){ "" }
    it { should eq [] }
  end

  describe "env variables" do
    let(:str){ "foo $baz" }
      it { should eq [
        [:Command, t("foo", lineno:0)],
        [:Argument, t("$baz", lineno:0)]
      ]}
  end

  context "argument parsing" do
    describe "commands with no args" do
      let(:str){ "ls" }
      it { should eq [
        [:Command, t("ls", lineno:0)]
      ]}
    end

    describe "commands with a simple arg: ls foo" do
      let(:str){ "ls foo" }
      it { should eq [
        [:Command, t("ls", lineno:0)],
        [:Argument,   t("foo", lineno:0)]
      ]}
    end

    describe "commands with a simple arg: ls -al" do
      let(:str){ "ls -al" }
      it { should eq [
        [:Command, t("ls", lineno:0)],
        [:Argument,   t("-al", lineno:0)]
      ]}
    end

    describe "commands with multiple args: ls -al foo bar -baz" do
      let(:str){ "ls -al foo bar -baz" }
      it { should eq [
        [:Command, t("ls", lineno:0)],
        [:Argument,   t("-al", lineno:0)],
        [:Argument,   t("foo", lineno:0)],
        [:Argument,   t("bar", lineno:0)],
        [:Argument,   t("-baz", lineno:0)]
      ]}
    end

    context "single quoted args" do
      describe "simple args: ls 'hello there'" do
        let(:str){ "ls 'hello there'" }
        it { should eq [
          [:Command, t("ls", lineno:0)],
          [:Argument,   t("hello there", lineno:0)]
        ]}
      end

      describe "nested single quotes: ls 'hello \\'there\\''" do
        let(:str){ "ls 'hello \\'there\\''" }
        it { should eq [
          [:Command, t("ls", lineno:0)],
          [:Argument,   t("hello 'there'", lineno:0)]
        ]}
      end

      describe "nested double quotes: ls 'hello \"there\"'" do
        let(:str){ %|ls 'hello "there"'| }
        it { should eq [
          [:Command, t("ls", lineno:0)],
          [:Argument,   t('hello "there"', lineno:0)]
        ]}
      end

      describe "multiple levels of nested single quotes: ls 'hello \\'there \\\\'guy\\\\' \\''" do
        let(:str){ "ls 'hello \\'there \\\\'guy\\\\' \\''" }
        it { should eq [
          [:Command, t("ls", lineno:0)],
          [:Argument,   t("hello 'there \\'guy\\' '", lineno:0)]
        ]}
      end

      describe "multiple single quoted args: ls 'hello \\'there \\'' 'how are \\'you\\'?'" do
        let(:str){ "ls 'hello \\'there\\'' 'how are \\'you\\'?'" }
        it { should eq [
          [:Command, t("ls", lineno:0)],
          [:Argument,   t("hello 'there'", lineno:0)],
          [:Argument,   t("how are 'you'?", lineno:0)]
        ]}
      end
    end

    context 'double quoted args' do
      describe 'simple args: ls "hello there"' do
        let(:str){ 'ls "hello there"' }
        it { should eq [
          [:Command, t('ls', lineno:0)],
          [:Argument,   t('hello there', lineno:0)]
        ]}
      end

      describe 'nested singled quotes: ls "hello \'there\'"' do
        let(:str){ %|ls "hello 'there'"| }
        it { should eq [
          [:Command, t('ls', lineno:0)],
          [:Argument,   t("hello 'there'", lineno:0)]
        ]}
      end

      describe 'nested double quotes: ls "hello \\"there\\""' do
        let(:str){ 'ls "hello \\"there\\""' }
        it { should eq [
          [:Command, t('ls', lineno:0)],
          [:Argument,   t('hello "there"', lineno:0)]
        ]}
      end

      describe 'multiple levels of nested double quotes: ls "hello \\"there \\\\"guy\\\\" \\""' do
        let(:str){ 'ls "hello \\"there \\\\"guy\\\\" \\""' }
        it { should eq [
          [:Command, t('ls', lineno:0)],
          [:Argument,   t('hello "there \\"guy\\" "', lineno:0)]
        ]}
      end

      describe 'multiple double quoted args: ls "hello \\"there \\"" "how are \\"you\\"?"' do
        let(:str){ 'ls "hello \\"there\\"" "how are \\"you\\"?"' }
        it { should eq [
          [:Command, t('ls', lineno:0)],
          [:Argument,   t('hello "there"', lineno:0)],
          [:Argument,   t('how are "you"?', lineno:0)]
        ]}
      end
    end
  end
end
