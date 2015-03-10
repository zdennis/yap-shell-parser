require 'spec_helper'
require 'yap/shell/parser/lexer'

describe Yap::Shell::Parser::Lexer do
  subject { described_class.new.tokenize(str) }

  def t(tag, val, lineno:0, attrs:{})
    [tag, Yap::Shell::Parser::Lexer::Token.new(tag, val, lineno:lineno, attrs:attrs)]
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

  describe "commands" do
    describe "can begin with periods: .core" do
      let(:str){ ".core" }
      it { should eq [
        t(:Command, ".core", lineno:0)
      ]}
    end

    describe "can contain periods: ag.core" do
      let(:str){ "ag.core" }
      it { should eq [
        t(:Command, "ag.core", lineno:0)
      ]}
    end

    describe "can end with periods: core." do
      let(:str){ "core." }
      it { should eq [
        t(:Command, "core.", lineno:0)
      ]}
    end

    describe "can contain a number: ab4cd" do
      let(:str){ "ab4cd" }
      it { should eq [
        t(:Command, "ab4cd", lineno:0)
      ]}
    end

    describe "can contain slashes with periods: foo/bar" do
      let(:str){ "foo/bar" }
      it { should eq [
        t(:Command, "foo/bar", lineno:0)
      ]}
    end

    describe "can contain asterisks: foo/ba*" do
      let(:str){ "foo/ba*" }
      it { should eq [
        t(:Command, "foo/ba*", lineno:0)
      ]}
    end
  end

  describe "literal commands" do
    describe "begin with the backslash escape: \\rm" do
      let(:str){ '\rm' }
      it { should eq [
        t(:LiteralCommand, "rm", lineno: 0)
        ]}
    end

    describe "can contain slashes with periods: \\foo/bar" do
      let(:str){ "\\foo/bar" }
      it { should eq [
        t(:LiteralCommand, "foo/bar", lineno:0)
      ]}
    end
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

    describe "can contain asterisks: ls foo* b*r" do
      let(:str){ "ls foo* b*r" }
      it { should eq [
        t(:Command, "ls", lineno:0),
        t(:Argument, "foo*", lineno:0),
        t(:Argument, "b*r", lineno:0),
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

      describe "single quotes with spaces and assignment" do
        let(:str){ "alias z='echo hi'" }
        it { should eq [
          t(:Command, "alias", lineno:0),
          t(:Argument, "z=echo hi", lineno:0),
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

      describe "single quotes with spaces and assignment" do
        let(:str){ "alias z=\"echo hi\"" }
        it { should eq [
          t(:Command, "alias", lineno:0),
          t(:Argument, "z=echo hi", lineno:0),
        ]}
      end
    end
  end

  context "statements" do
    ["foo;baz", "foo; baz", "foo ;baz", "foo ; baz", "foo     ;    baz"].each do |src|
      describe "are separated by a semi-colon: #{src.inspect}" do
        let(:str){ src }
        it { should eq [
          t(:Command, "foo", lineno:0),
          t(:Separator, ";", lineno:0),
          t(:Command, "baz", lineno:0)
        ]}
      end
    end

    ["foo|baz", "foo| baz", "foo |baz", "foo | baz", "foo     |    baz"].each do |src|
      describe "are separated by a semi-colon: #{src.inspect}" do
        let(:str){ src }
        it { should eq [
          t(:Command, "foo", lineno:0),
          t(:Pipe, "|", lineno:0),
          t(:Command, "baz", lineno:0)
        ]}
      end
    end

    ["foo&&baz", "foo&& baz", "foo &&baz", "foo && baz", "foo     &&    baz"].each do |src|
      describe "are separated by double ampersands: #{src.inspect}" do
        let(:str){ src }
        it { should eq [
          t(:Command, "foo", lineno:0),
          t(:Conditional, "&&", lineno:0),
          t(:Command, "baz", lineno:0)
        ]}
      end
    end

    ["foo||baz", "foo|| baz", "foo ||baz", "foo || baz", "foo     ||    baz"].each do |src|
      describe "are separated by double ampersands: #{src.inspect}" do
        let(:str){ src }
        it { should eq [
          t(:Command, "foo", lineno:0),
          t(:Conditional, "||", lineno:0),
          t(:Command, "baz", lineno:0)
        ]}
      end
    end
  end

  context "heredocs" do
    describe "started with double arrows followed by a character: foo <<E" do
      let(:str){ "foo <<E\nfoo\nbar\nE" }
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "foo\nbar\n", lineno:0)
      ]}
    end

    describe "started with double arrows followed by multiple character: foo <<FOO" do
      let(:str){ "foo <<FOO\nhere\nwe\ngo\nFOO"}
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "here\nwe\ngo\n", lineno:0)
      ]}
    end

    describe "started with double arrows followed by numbers characters: foo <<12" do
      let(:str){ "foo <<12\nnumbers\nman\n12" }
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "numbers\nman\n", lineno:0)
      ]}
    end

    describe "started with double arrows followed by a mixture of alphanumeric characters: foo <<L337" do
      let(:str){ "foo <<L337\nhere\nwe\ngo\nL337"}
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "here\nwe\ngo\n", lineno:0)
      ]}
    end

    describe "started with a <<-: foo <<-L337" do
      let(:str){ "foo <<-L337\nhere\nwe\ngo\nL337"}
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "here\nwe\ngo\n", lineno:0)
      ]}
    end

    describe "the ending line can have leading whitespace which isn't consumed" do
      let(:str){ "foo <<L337\nhere\nwe\ngo\n   \t  L337"}
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "here\nwe\ngo\n", lineno:0)
      ]}
    end

    describe "the ending line can have trailing whitespace which isn't consumed" do
      let(:str){ "foo <<L337\nhere\nwe\ngo\nL337     \t "}
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "here\nwe\ngo\n", lineno:0)
      ]}
    end

    describe "the ending line can be followed by a newline" do
      let(:str){ "foo <<L337\nhere\nwe\ngo\nL337\n"}
      it { should eq [
        t(:Command, "foo", lineno:0),
        t(:Heredoc, "here\nwe\ngo\n", lineno:0)
      ]}
    end

    describe "the ending line cannot have non-whitespace characters beyond the delimiter" do
      let(:str){ "foo <<L337\nhere\nwe\ngo\n this is bad L337"}
      it "raises an error" do
        expect{ subject }.to raise_error
      end
    end
  end

  context "internal evaluations" do
    describe "started by a exclamation point: !to_s" do
      let(:str){ "!to_s" }
      it { should eq [
        t(:InternalEval, "to_s", lineno:0)
      ]}
    end

    describe "keeps strings" do
      let(:str){ "!Dir.chdir('..')" }
      it { should eq [
        t(:InternalEval, "Dir.chdir('..')", lineno:0)
      ]}
    end

    describe "can handle quoted strings: !a + 'b' + \"c\" + d" do
      let(:str){ "!a + 'b' + \"c\" + d" }
      it { should eq [
        t(:InternalEval, "a + 'b' + \"c\" + d", lineno:0)
      ]}
    end

    describe "can handle {/} blocks: !foo.map{ |bar| bar + 1 }" do
      let(:str){ "!foo.map{ |bar| bar + 1 }" }
      it { should eq [
        t(:InternalEval, "foo.map{ |bar| bar + 1 }", lineno:0)
      ]}
    end

    describe "can handle parentheses in method calls: !foo.map(&:bar)" do
      let(:str){ "!foo.map(&:bar)" }
      it { should eq [
        t(:InternalEval, "foo.map(&:bar)", lineno:0)
      ]}
    end

    describe "doesn't consume beyond a semi-colon terminator into other commands: !foo.map(&:bar) ; grep fox" do
      let(:str){ "!foo.map(&:bar) ; grep fox" }
      it { should eq [
        t(:InternalEval, "foo.map(&:bar)", lineno:0),
        t(:Separator, ";", lineno:0),
        t(:Command, "grep", lineno:0),
        t(:Argument, "fox", lineno:0)
      ]}
    end

    describe "doesn't consume beyond a pipe terminator into other commands: !foo.map(&:bar) | grep fox" do
      let(:str){ "!foo.map(&:bar) | grep fox" }
      it { should eq [
        t(:InternalEval, "foo.map(&:bar)", lineno:0),
        t(:Pipe, "|", lineno:0),
        t(:Command, "grep", lineno:0),
        t(:Argument, "fox", lineno:0)
      ]}
    end

    describe "doesn't consume beyond a pipe terminator into other commands: !downcase | sleep 4" do
      let(:str){ "!downcase | sleep 4" }
      it { should eq [
        t(:InternalEval, "downcase", lineno:0),
        t(:Pipe, "|", lineno:0),
        t(:Command, "sleep", lineno:0),
        t(:Argument, "4", lineno:0)
      ]}
    end

    describe "doesn't consume beyond a double-ampersand terminator into other commands: !foo.map(&:bar) && grep fox" do
      let(:str){ "!foo.map(&:bar) && grep fox" }
      it { should eq [
        t(:InternalEval, "foo.map(&:bar)", lineno:0),
        t(:Conditional, "&&", lineno:0),
        t(:Command, "grep", lineno:0),
        t(:Argument, "fox", lineno:0)
      ]}
    end

    describe "doesn't consume beyond a double-pipe terminator into other commands: !foo.map(&:bar) || grep fox" do
      let(:str){ "!foo.map(&:bar) || grep fox" }
      it { should eq [
        t(:InternalEval, "foo.map(&:bar)", lineno:0),
        t(:Conditional, "||", lineno:0),
        t(:Command, "grep", lineno:0),
        t(:Argument, "fox", lineno:0)
      ]}
    end
  end

  describe 'grouping statements' do
    describe 'simple one command: (bar)' do
      let(:str){ "(bar)" }
      it { should eq [
        t('(', '(', lineno:0),
        t(:Command, "bar", lineno:0),
        t(')', ')', lineno:0)
      ]}
    end

    describe 'simple interval eval: (!bar)' do
      let(:str){ "(!bar)" }
      it { should eq [
        t('(', '(', lineno:0),
        t(:InternalEval, "bar", lineno:0),
        t(')', ')', lineno:0)
      ]}
    end

    describe 'complicated interval eval: (!foo.map(&:bar).map{ |fasdf| baz })' do
      let(:str){ "(!foo.map(&:bar).map{ |fasdf| baz })" }
      it { should eq [
        t('(', '(', lineno:0),
        t(:InternalEval, "foo.map(&:bar).map{ |fasdf| baz }", lineno:0),
        t(')', ')', lineno:0)
      ]}
    end

    describe 'multiple commands: (bar ; baz && foo | yep' do
      let(:str){ '(bar ; baz && foo | yep)' }
      it { should eq [
        t('(', '(', lineno:0),
        t(:Command, "bar", lineno:0),
        t(:Separator, ";", lineno:0),
        t(:Command, "baz", lineno:0),
        t(:Conditional, "&&", lineno:0),
        t(:Command, "foo", lineno:0),
        t(:Pipe, "|", lineno:0),
        t(:Command, "yep", lineno:0),
        t(')', ')', lineno:0)
      ]}
    end
  end

  describe "redirections" do
    describe "stdin" do
      describe "can come after the command with no spaces: foo<bar.txt" do
        let(:str){ "foo<bar.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, "<", lineno: 0, attrs: { target: "bar.txt" }),
        ]}
      end

      describe "can come after the command with spaces after the command: foo <bar.txt" do
        let(:str){ "foo <bar.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, "<", lineno: 0, attrs: { target: "bar.txt" }),
        ]}
      end

      describe "can come after the command with spaces after the redirect: foo < /path/to/bar.txt" do
        let(:str){ "foo < /path/to/bar.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, "<", lineno: 0, attrs: { target: "/path/to/bar.txt" }),
        ]}
      end

      describe "can come after command arguments: ls -al < a.txt" do
        let(:str){ "ls -al < a.txt" }
        it { should eq [
          t(:Command, "ls", lineno: 0),
          t(:Argument, "-al", lineno: 0),
          t(:Redirection, "<", lineno: 0, attrs: { target: "a.txt" }),
        ]}
      end
    end

    describe "stdout" do
      describe "can come after the command with no spaces" do
        let(:str){ "foo>bar.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, ">", lineno: 0, attrs: { target: "bar.txt" }),
        ]}
      end

      describe "can come after the command with spaces after the command" do
        let(:str){ "foo >bar.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, ">", lineno: 0, attrs: { target: "bar.txt" }),
        ]}
      end

      describe "can come after the command with spaces after the redirect" do
        let(:str){ "foo > bar.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, ">", lineno: 0, attrs: { target: "bar.txt" }),
        ]}
      end

      describe "can be specified numerically: 1>" do
        let(:str){ "foo 1> bar.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, "1>", lineno: 0, attrs: { target: "bar.txt" }),
        ]}
      end

      describe "can come after command arguments" do
        let(:str){ "ls -al > a.txt" }
        it { should eq [
          t(:Command, "ls", lineno: 0),
          t(:Argument, "-al", lineno: 0),
          t(:Redirection, ">", lineno: 0, attrs: { target: "a.txt" }),
        ]}
      end
    end

    describe "stderr" do
      describe "without spaces after the command it cannot be redirected" do
        let(:str){ "foo2>bar.txt" }
        it { should eq [
          t(:Command, "foo2", lineno: 0),
          t(:Redirection, ">", lineno: 0, attrs: { target: "bar.txt" }),
        ]}
      end

      describe "it comes after the command with spaces after the command" do
        let(:str){ "foo 2>bar.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, "2>", lineno: 0, attrs: { target: "bar.txt" }),
        ]}
      end

      describe "it comes after the command with spaces after the redirect" do
        let(:str){ "foo 2> bar.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, "2>", lineno: 0, attrs: { target: "bar.txt" }),
        ]}
      end
    end

    describe "stdout / stderr" do
      describe "stdout redirecting to stderr: foo 1>&2" do
        let(:str){ "foo 1>&2" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, "1>&2", lineno: 0, attrs: { target: nil }),
        ]}
      end

      describe "stderr redirecting to stdout: foo 2>&1" do
        let(:str){ "foo 2>&1" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, "2>&1", lineno: 0, attrs: { target: nil }),
        ]}
      end

      describe "stdout redirecting to stderr with a file: foo 1>&2 bar.txt (bash incompatible)" do
        let(:str){ "foo 1>&2 bar.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          # TODO: This is bash incompatible. Keep it?
          t(:Redirection, "1>&2", lineno: 0, attrs: { target: "bar.txt" })
        ]}
      end

      describe "stderr redirecting to stdout with a file: foo 2>&1 bar.txt (bash incompatible)" do
        let(:str){ "foo 2>&1 bar.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          # TODO: This is bash incompatible. Keep it?
          t(:Redirection, "2>&1", lineno: 0, attrs: { target: "bar.txt" })
        ]}
      end

      describe "stdout and stderr redirecting to a file together: foo &> /dev/null" do
        let(:str){ "foo &> /dev/null" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, "&>", lineno: 0, attrs: { target: "/dev/null" })
        ]}
      end

      describe "stdout and sdterr redirecting separately: foo 2> err.txt 1> out.txt" do
        let(:str){ "foo 2> err.txt 1> out.txt" }
        it { should eq [
          t(:Command, "foo", lineno: 0),
          t(:Redirection, "2>", lineno: 0, attrs: { target: "err.txt" }),
          t(:Redirection, "1>", lineno: 0, attrs: { target: "out.txt" })
        ]}
      end

      describe "stdout and sdterr redirecting separately: du -sh 1>&2 1>hey.txt" do
        let(:str){ "du -sh 2>&1 1>hey.txt" }
        it { should eq [
          t(:Command, "du", lineno: 0),
          t(:Argument, "-sh", lineno: 0),
          t(:Redirection, "2>&1", lineno: 0, attrs: { target: nil }),
          t(:Redirection, "1>", lineno: 0, attrs: { target: "hey.txt" })
        ]}
      end
    end
  end

  describe "variables" do
    describe "one can be assigned its their own: FOO=123" do
      let(:str){ "FOO=123" }
      it { should eq [
        t(:LValue, "FOO", lineno: 0),
        t(:RValue, "123", lineno: 0)
      ]}
    end

    describe "many can be assigned on their own: FOO=123 BAR=a_c BAZ=4-5:6" do
      let(:str){ "FOO=123 BAR=a_c BAZ=4-5:6" }
      it { should eq [
        t(:LValue, "FOO", lineno: 0),
        t(:RValue, "123", lineno: 0),
        t(:LValue, "BAR", lineno: 0),
        t(:RValue, "a_c", lineno: 0),
        t(:LValue, "BAZ", lineno: 0),
        t(:RValue, "4-5:6", lineno: 0)
      ]}
    end

    describe "can be assigned before a command: FOO=123 echo $FOO" do
      let(:str){ "FOO=123 echo $FOO" }
      it { should eq [
        t(:LValue, "FOO", lineno: 0),
        t(:RValue, "123", lineno: 0),
        t(:Command, "echo", lineno: 0),
        t(:Argument, "$FOO", lineno: 0)
      ]}
    end

    describe "can be assigned before a command: FOO=abc BAR='hello world' ls -l" do
      let(:str){ "FOO=abc BAR='hello world' ls -l" }
      it { should eq [
        t(:LValue, "FOO", lineno: 0),
        t(:RValue, "abc", lineno: 0),
        t(:LValue, "BAR", lineno: 0),
        t(:RValue, "hello world", lineno: 0),
        t(:Command, "ls", lineno: 0),
        t(:Argument, "-l", lineno: 0)
      ]}
    end
  end

  describe "command substitution" do
    describe "backticks can wrap simple commands: `pwd`" do
      let(:str){ "`pwd`" }
      it { should eq [
        t(:BeginSubcommand, "`", lineno: 0),
        t(:Command, "pwd", lineno: 0),
        t(:EndSubcommand, "`", lineno: 0)
      ]}
    end

    describe "backticks can be used as part of an argument: git branch `git cbranch`.bak" do
      let(:str){ "git branch `git cbranch`.bak" }
      it { should eq [
        t(:Command, "git", lineno: 0),
        t(:Argument, "branch", lineno: 0),
        t(:BeginSubcommand, '`', lineno: 0),
        t(:Command, 'git', lineno: 0),
        t(:Argument, 'cbranch', lineno: 0),
        t(:EndSubcommand, '`', lineno: 0),
        t(:Argument, '.bak', lineno: 0)
      ]}
    end

    describe "backticks can wrap complex statements: `ls -al && foo bar || baz`" do
      let(:str){ "`ls -al && foo bar || baz`" }
      it { should eq [
        t(:BeginSubcommand, "`", lineno: 0),
        t(:Command,'ls', lineno: 0),
        t(:Argument, '-al', lineno: 0),
        t(:Conditional, '&&', lineno: 0),
        t(:Command, 'foo', lineno: 0),
        t(:Argument, 'bar', lineno: 0),
        t(:Conditional, '||', lineno: 0),
        t(:Command, 'baz', lineno: 0),
        t(:EndSubcommand, "`", lineno: 0)
      ]}
    end

    describe "backticks can appear as an argument: echo `pwd`" do
      let(:str){ "echo `pwd`" }
      it { should eq [
        t(:Command,'echo', lineno: 0),
        t(:BeginSubcommand, "`", lineno: 0),
        t(:Command,'pwd', lineno: 0),
        t(:EndSubcommand, "`", lineno: 0)
      ]}
    end

    describe "backticks can appear as a complex argument: echo `pwd && foo bar || baz ; yep` ; hello" do
      let(:str){ "echo `pwd && foo bar || baz ; yep` ; hello" }
      it { should eq [
        t(:Command,'echo', lineno: 0),
        t(:BeginSubcommand, "`", lineno: 0),
        t(:Command,'pwd', lineno: 0),
        t(:Conditional, '&&', lineno: 0),
        t(:Command, 'foo', lineno: 0),
        t(:Argument, 'bar', lineno: 0),
        t(:Conditional, '||', lineno: 0),
        t(:Command, 'baz', lineno: 0),
        t(:Separator, ";", lineno: 0),
        t(:Command, 'yep', lineno: 0),
        t(:EndSubcommand, "`", lineno: 0),
        t(:Separator, ";", lineno: 0),
        t(:Command, "hello", lineno: 0)
      ]}
    end

    describe "dollar-sign paren can wrap simple commands: $(pwd)" do
      let(:str){ "$(pwd)" }
      it { should eq [
        t(:BeginSubcommand, "$(", lineno: 0),
        t(:Command, "pwd", lineno: 0),
        t(:EndSubcommand, ")", lineno: 0)
      ]}
    end

    describe "dollar-sign paren can wrap complex statements: $(ls -al && foo bar || baz)" do
      let(:str){ "$(ls -al && foo bar || baz)" }
      it { should eq [
        t(:BeginSubcommand, "$(", lineno: 0),
        t(:Command,'ls', lineno: 0),
        t(:Argument, '-al', lineno: 0),
        t(:Conditional, '&&', lineno: 0),
        t(:Command, 'foo', lineno: 0),
        t(:Argument, 'bar', lineno: 0),
        t(:Conditional, '||', lineno: 0),
        t(:Command, 'baz', lineno: 0),
        t(:EndSubcommand, ")", lineno: 0)
      ]}
    end

    describe "dollar-sign paren can appear as an argument: echo $(pwd)" do
      let(:str){ "echo $(pwd)" }
      it { should eq [
        t(:Command,'echo', lineno: 0),
        t(:BeginSubcommand, "$(", lineno: 0),
        t(:Command,'pwd', lineno: 0),
        t(:EndSubcommand, ")", lineno: 0)
      ]}
    end

    describe "dollar-sign paren can appear as a complex argument: echo $(pwd && foo bar || baz ; yep) ; hello" do
      let(:str){ "echo $(pwd && foo bar || baz ; yep) ; hello" }
      it { should eq [
        t(:Command,'echo', lineno: 0),
        t(:BeginSubcommand, "$(", lineno: 0),
        t(:Command,'pwd', lineno: 0),
        t(:Conditional, '&&', lineno: 0),
        t(:Command, 'foo', lineno: 0),
        t(:Argument, 'bar', lineno: 0),
        t(:Conditional, '||', lineno: 0),
        t(:Command, 'baz', lineno: 0),
        t(:Separator, ";", lineno: 0),
        t(:Command, 'yep', lineno: 0),
        t(:EndSubcommand, ")", lineno: 0),
        t(:Separator, ";", lineno: 0),
        t(:Command, "hello", lineno: 0)
      ]}
    end

  end

end
