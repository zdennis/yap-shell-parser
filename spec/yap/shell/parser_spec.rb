require 'spec_helper'
require 'yap/shell/parser'
require 'pry'
describe Yap::Shell::Parser do
  subject(:parser){ Yap::Shell::Parser }

  describe '.each_command_substitution_for' do
    let(:str){ "echo `echo hi`" }

    it "yields the command substitution string" do
      expect { |b|
        parser.each_command_substitution_for(str, &b)
      }.to yield_with_args OpenStruct.new(str:"echo hi", position:5..14)
    end
  end

  it { is_expected.to parse "" }
  it { is_expected.to parse " " }
  it { is_expected.to parse "ls" }
  it { is_expected.to parse "echo foo" }
  it { is_expected.to parse "echo foo ; echo bar baz yep" }
  it { is_expected.to parse "echo foo && echo bar baz yep" }
  it { is_expected.to parse "echo foo && echo bar && ls foo && ls bar" }
  it { is_expected.to parse "echo foo ; echo bar baz yep ; ls foo" }
  it { is_expected.to parse "echo foo && echo bar ; ls baz" }
  it { is_expected.to parse "echo foo && echo bar ; ls baz ; echo zach || echo gretchen" }
  it { is_expected.to parse "echo foo | bar" }
  it { is_expected.to parse "echo foo | bar && foo | bar" }
  it { is_expected.to parse "foo && bar ; word || baz ; yep | grep -v foo" }
  it { is_expected.to parse "( foo )" }
  it { is_expected.to parse "( foo a b && bar c d )" }
  it { is_expected.to parse "( foo a b && (bar c d | baz e f))" }
  it { is_expected.to parse "((((foo))))" }
  it { is_expected.to parse "foo -b -c ; (this ;that ;the; other  ;thing) && yep" }
  it { is_expected.to parse "foo -b -c ; (this ;that && other  ;thing) && yep" }
  it { is_expected.to parse "4 + 5" }
  it { is_expected.to parse "!'hello' ; 4 - 4 && 10 + 3" }
  it { is_expected.to parse "\\foo <<-EOT\nbar\nEOT" }
  it { is_expected.to parse "ls | grep md | grep WISH" }
  it { is_expected.to parse "(!upcase)" }
  it { is_expected.to parse "echo foo > bar.txt" }
  it { is_expected.to parse "ls -l > a.txt ; echo f 2> b.txt ; cat b &> c.txt ; du -sh 1>&2 1>hey.txt" }
  it { is_expected.to parse "!Dir.chdir('..')" }
  it { is_expected.to parse "FOO=123" }
  it { is_expected.to parse "FOO=123 BAR=345" }
  it { is_expected.to parse "FOO=abc bar=2314 car=14ab ls -l" }
  it { is_expected.to parse "FOO=abc BAR='hello world' ls -l ; CAR=f echo foo && say hi" }
  it { is_expected.to parse "`git cbranch`" }
  it { is_expected.to parse "`git cbranch`.bak" }
  it { is_expected.to parse "echo `echo hi`" }
  it { is_expected.to parse "echo `echo hi` foo" }
  it { is_expected.to parse "`hi``bye` `what`" }
  it { is_expected.to parse "echo && `what` && where is `that`thing | `you know`" }
  it { is_expected.to parse "(0..3)" }
  it { is_expected.to parse "(0..3): echo hi" }
  it { is_expected.to parse "(0..3) as n: echo hi $n" }
  it { is_expected.to parse "echo hi ; (0..3) {echo hi $n }" }
  it { is_expected.to parse "echo hi ; (0..3) { echo hi $n } ; echo bye" }
  it { is_expected.to parse "ls *.rb { |f,g,h| echo $f && echo $h && echo $i }" }

  it { is_expected.to fail_parsing "ls ()" }
end
