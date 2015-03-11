require 'spec_helper'
require 'yap/shell/parser'
require 'pry'

describe Yap::Shell::Parser do
  subject(:parser){ Yap::Shell::Parser.new }

  def self.it_parses(str)
    context "#{str.inspect}" do
      it "parses" do
        expect do
          begin
            parser.parse(str)
          rescue => ex
            raise "Parser error:\n\t#{str}\n\n#{ex.message}\n#{ex.backtrace.join("\n")}"
          end
        end.to_not raise_error
      end
    end
  end

  it_parses "ls"
  it_parses "echo foo"
  it_parses "echo foo ; echo bar baz yep"
  it_parses "echo foo && echo bar baz yep"
  it_parses "echo foo && echo bar && ls foo && ls bar"
  it_parses "echo foo ; echo bar baz yep ; ls foo"
  it_parses "echo foo && echo bar ; ls baz"
  it_parses "echo foo && echo bar ; ls baz ; echo zach || echo gretchen"
  it_parses "echo foo | bar"
  it_parses "echo foo | bar && foo | bar"
  it_parses "foo && bar ; word || baz ; yep | grep -v foo"
  it_parses "( foo )"
  it_parses "( foo a b && bar c d )"
  it_parses "( foo a b && (bar c d | baz e f))"
  it_parses "((((foo))))"
  it_parses "foo -b -c ; (this ;that ;the; other  ;thing) && yep"
  it_parses "foo -b -c ; (this ;that && other  ;thing) && yep"
  it_parses "4 + 5"
  it_parses "!'hello' ; 4 - 4 && 10 + 3"
  it_parses "\\foo <<-EOT\nbar\nEOT"
  it_parses "ls | grep md | grep WISH"
  it_parses "(!upcase)"
  it_parses "echo foo > bar.txt"
  it_parses "ls -l > a.txt ; echo f 2> b.txt ; cat b &> c.txt ; du -sh 1>&2 1>hey.txt"
  it_parses "!Dir.chdir('..')"
  it_parses "FOO=123"
  it_parses "FOO=123 BAR=345"
  it_parses "FOO=abc bar=2314 car=14ab ls -l"
  it_parses "FOO=abc BAR='hello world' ls -l ; CAR=f echo foo && say hi"

end
