# $Id$
#
# convert Array-like string into Ruby's Array.

class Yap::Line::MyParser
  token Command LiteralCommand Argument Heredoc InternalEval Separator Conditional Pipe Redirection
  #
  # prechigh
  # #   left '**' '*' '/' '%'
  # #   left '+' '-'
  # #   left '&&' '||'
  # #   left '|' '^' '&'
  # #   # right Not
  # left Separator
  # left Conditional
  # right Pipe
  # preclow

rule

program : stmts

stmts : stmts Separator stmt
    { result = StatementsNode.new(val[0], val[2]) }
  | stmt
    { result = StatementsNode.new(val[0]) }

stmt : stmt Conditional pipeline
    { result = ConditionalNode.new(val[1].value, val[0], val[2]) }
  | pipeline

pipeline : pipeline Pipe stmts2
    { result = PipelineNode.new(val[0], val[2]) }
  | stmts2

stmts2 : '(' stmts ')'
    { result = val[1] }
  | command_w_redirects
  | internal_eval

command_w_heredoc : command_w_redirects Heredoc
  | command_w_redirects

command_w_redirects : command_w_redirects Redirection
    { val[0].redirects << RedirectionNode.new(val[1].value, val[1].attrs[:target]) ; result = val[0] }
  | command Redirection
    { val[0].redirects << RedirectionNode.new(val[1].value, val[1].attrs[:target]) ; result = val[0] }
  | command

command : command2 Heredoc
    { val[0].heredoc = val[1].value ; result = val[0] }
  | command2

command2: Command
    { result = CommandNode.new(val[0].value) }
  | Command args
    { result = CommandNode.new(val[0].value, val[1].flatten) }
  | LiteralCommand
    { result = CommandNode.new(val[0].value, literal:true) }
  | LiteralCommand args
    { result = CommandNode.new(val[0].value, val[1].flatten, literal:true) }

args : Argument
    { result = [val[0].value] }
  | args Argument
    { result = [val[0], val[1].value] }

internal_eval : InternalEval
    { result = InternalEvalNode.new(val[0].value) }


---- inner
  $LOAD_PATH.unshift File.dirname(__FILE__) + "/../../"
  require 'yap/line/lexer'
  require 'yap/line/nodes'

  include Yap::Line::Nodes

  def parse(str)
    @q = Yap::Line::Lexer.new.tokenize(str)
    # @q.push [false, '$']   # is optional from Racc 1.3.7
# puts @q.inspect
# puts "---- parse tree follows ----"
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
  require 'yap/line/nodes'
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
  src = "( foo )"
  src = "( foo a b && bar c d )"
  src = "( foo a b && (bar c d | baz e f))"
  src = "((((foo))))"
  src = "foo -b -c ; (this ;that ;the; other  ;thing) && yep"
  src = "foo -b -c ; (this ;that && other  ;thing) && yep"
  src = "4 + 5"
  src = "!'hello' ; 4 - 4 && 10 + 3"
  src = "\\foo <<-EOT\nbar\nEOT"
  src = "ls | grep md | grep WISH"
  src = "(!upcase)"
  src = "echo foo > bar.txt"
  src = "ls -l > a.txt ; echo f 2> b.txt ; cat b &> c.txt ; du -sh 1>&2 1>hey.txt"
  puts 'parsing:'
  print src
  puts
  puts 'result:'
  require 'pp'
  ast = Yap::Line::MyParser.new.parse(src)
  pp ast

  # puts "---- Evaluating"
  #   require 'pry'
  # binding.pry
  # Evaluator.new.evaltree(ast)
end
