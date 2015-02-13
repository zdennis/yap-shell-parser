require 'spec_helper'
require 'yap/line/parser'

describe Yap::Line::Parser do
  describe '#parse' do
    subject(:parser){ described_class.new.parse(tokens) }
    let(:tokens){ raise("Must define :tokens in context") }

    def t(tag, val, lineno:0, attrs:{})
      Yap::Line::Lexer::Token.new(tag, val, lineno:lineno, attrs:attrs)
    end

    context "with no tokens" do
      let(:tokens){ [] }
      it { should eq [] }
    end

    context "unknown tokens" do
      let(:tokens){[
        t(:ThisIsSomethingThatWeDontKnowHowToParse,"foo")
      ]}
      it "should raise an UnknownTokenError" do
        expect { subject }.to raise_error(Yap::Line::Parser::UnknownTokenError)
      end
    end

    describe "command tokens" do
      context "with a single :Command token" do
        let(:tokens){[
          t(:Command,"foo")
        ]}
        it{ should eq [
          Yap::Line::Statement.new(command:"foo", args:[], literal:false)
        ]}
      end

      context "with multiple :Command tokens" do
        let(:tokens){[
          t(:Command, "foo"),
          t(:Command, "bar")
        ]}
        it{ should eq [
          Yap::Line::Statement.new(command:"foo", args:[], literal:false),
          Yap::Line::Statement.new(command:"bar", args:[], literal:false)
        ]}
      end

      context "with a :LiteralCommand token" do
        let(:tokens){ [t(:LiteralCommand, "foo")] }
        it{ should eq [
          Yap::Line::Statement.new(command:"foo", args:[], literal:true)
        ]}
      end

      context "with multiple :LiteralCommand tokens" do
        let(:tokens){[
          t(:LiteralCommand, "foo"),
          t(:LiteralCommand, "bar")
        ]}
        it{ should eq [
          Yap::Line::Statement.new(command:"foo", args:[], literal:true),
          Yap::Line::Statement.new(command:"bar", args:[], literal:true)
        ]}
      end
    end

    describe "command tokens with argument tokens following" do
      context "with a single :Command token followed by :Argument tokens" do
        let(:tokens){[
          t(:Command,  "foo"),
          t(:Argument, "arg1"),
          t(:Argument, "arg2")
        ]}
        it{ should eq [
          Yap::Line::Statement.new(command:"foo", args:["arg1", "arg2"], literal:false)
        ]}
      end

      context "with multiple :Command tokens all followed by :Argument tokens" do
        let(:tokens){[
          t(:Command,  "foo"),
          t(:Argument, "arg1"),
          t(:Command,  "bar"),
          t(:Argument, "barg1")
        ]}
        it{ should eq [
          Yap::Line::Statement.new(command:"foo", args:["arg1"], literal:false),
          Yap::Line::Statement.new(command:"bar", args:["barg1"], literal:false)
        ]}
      end

      context "with :LiteralCommand token followed by :Argument tokens" do
        let(:tokens){[
          t(:LiteralCommand,  "foo"),
          t(:Argument, "arg1"),
          t(:Argument, "arg2")
        ]}
        it{ should eq [
          Yap::Line::Statement.new(command:"foo", args:["arg1", "arg2"], literal:true)
        ]}
      end
    end

    describe "command tokens with heredoc tokens following" do
      context "wiith a single :Command token followed by a :Heredoc token" do
        let(:tokens){[
          t(:Command, "foo"),
          t(:Heredoc, "EOS")
        ]}
        it{ should eq [
          Yap::Line::Statement.new(command:"foo", args:[], heredoc_marker: "EOS", literal:false)
        ]}
      end

      context "with a single :Command token followed by :Argument tokens followed by a :Heredoc token" do
        let(:tokens){[
          t(:Command,  "foo"),
          t(:Argument, "arg1"),
          t(:Heredoc,  "EOS")
        ]}
        it{ should eq [
          Yap::Line::Statement.new(command:"foo", args:["arg1"], heredoc_marker: "EOS", literal:false)
        ]}
      end

      context "with multiple :Command tokens followed by a :Heredoc token" do
        let(:tokens){[
          t(:Command,  "foo"),
          t(:Heredoc,  "EOS"),
          t(:Command,  "bar"),
          t(:Heredoc,  "CODE")
        ]}
        it{ should eq [
          Yap::Line::Statement.new(command:"foo", args:[], heredoc_marker: "EOS", literal:false),
          Yap::Line::Statement.new(command:"bar", args:[], heredoc_marker: "CODE", literal:false)
        ]}
      end

      context "with :LiteralComand tokens followed by a :Heredoc token" do
        let(:tokens){[
          t(:LiteralCommand,  "foo"),
          t(:Heredoc,  "EOS"),
          t(:LiteralCommand,  "bar"),
          t(:Heredoc,  "CODE")
        ]}
        it{ should eq [
          Yap::Line::Statement.new(command:"foo", args:[], heredoc_marker: "EOS", literal:true),
          Yap::Line::Statement.new(command:"bar", args:[], heredoc_marker: "CODE", literal:true)
        ]}
      end
    end

    describe "internal eval tokens" do
      context "with :InternalEval tokens" do
        let(:tokens){[
          t(:InternalEval, "ruby code")
        ]}
        it{ should eq [
          Yap::Line::InternalEvalStatement.new(command:"ruby code")
        ]}
      end
    end

    describe "terminator tokens" do
      context "with ; :Separator tokens separating two tokens" do
        let(:tokens){[
          t(:InternalEval, "ruby code"),
          t(:Separator, ";"),
          t(:Command, "foo")
        ]}
        it "doesnt do anything special for them" do
          expect(subject).to eq [
            Yap::Line::InternalEvalStatement.new(command:"ruby code"),
            Yap::Line::Statement.new(command:"foo", args:[])
          ]
        end
      end
      #
      # context "with || :Conditional tokens separating two tokens" do
      #   let(:tokens){[
      #     t(:InternalEval, "ruby code"),
      #     t(:Conditional, "&&"),
      #     t(:Command, "foo")
      #   ]}
      #   it { should eq [
      #     Yap::Line::AndStatement
      #     Yap::Line::InternalEvalStatement.new(command:"ruby code"),
      #     Yap::Line::Statement.new(command:"foo", args:[])
      #   ]}
      # end

    end

  end
end
