# $Id$
#
# convert Array-like string into Ruby's Array.

class Yap::Line::MyParser
token Command LiteralCommand Argument Heredoc InternalEval StatementTerminator ConditionalTerminator PipeTerminator
  #
  # prechigh
  # #   left '**' '*' '/' '%'
  # #   left '+' '-'
  # #   left '&&' '||'
  # #   left '|' '^' '&'
  # #   # right Not
  # left StatementTerminator
  # left ConditionalTerminator
  # right PipeTerminator
  # preclow

rule

# echo foo && echo bar ; ls baz ; echo zach || echo gretchen
program : stmt

stmt : expr

expr : expr StatementTerminator mulex
    { result = [*val[0], val[1], val[2]] }
  | mulex
    { result = val }

mulex : mulex ConditionalTerminator pipeline
    { result = val[1], val[0], val[2] }
  | pipeline

pipeline : pipeline PipeTerminator command
    { result = val[1], val[0], val[2] }
  | command

command : Command
    { result = val }
  | Command args
    { result = [val[0], val[1]].flatten }

args : Argument
    { result = [val[0]]}
  | args Argument
    { result = val }


---- inner

  def parse(str)
    @q = Yap::Line::Lexer.new.tokenize(str)
    # @q.push [false, '$']   # is optional from Racc 1.3.7
puts @q.inspect
puts "---- parse tree follows ----"
    __send__(Racc_Main_Parsing_Routine, _racc_setup(), false)
    #do_parse
  end

  def next_token
    @q.shift
  end

---- footer

if $0 == __FILE__
  $LOAD_PATH.unshift File.dirname(__FILE__) + "/../../"
  require 'yap/line/lexer'
  src = "echo foo"
  src = "echo foo ; echo bar baz yep"
  src = "echo foo && echo bar baz yep"
  src = "echo foo && echo bar && ls foo && ls bar"
  src = "echo foo ; echo bar baz yep ; ls foo"
  src = "echo foo && echo bar ; ls baz"
  src = "echo foo && echo bar ; ls baz ; echo zach || echo gretchen"
  src = "echo foo | bar"
  src = "echo foo | bar && foo | bar"
  src = "foo && bar ; word || baz ; yep | grep -v foo"
  puts 'parsing:'
  print src
  puts
  puts 'result:'
  require 'pp'
  pp Yap::Line::MyParser.new.parse(src)
end
