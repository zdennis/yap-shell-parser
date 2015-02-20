# $Id$
#
# convert Array-like string into Ruby's Array.

class Yap::Line::Parser
  token Command LiteralCommand Argument Heredoc InternalEval Separator Conditional Pipe Redirection LValue RValue
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
  | command_w_heredoc
  | internal_eval

command_w_heredoc : command_w_redirects Heredoc
    { val[0].heredoc = val[1] ; result = val[0] }
  | command_w_redirects

command_w_redirects : command_w_redirects Redirection
    { val[0].redirects << RedirectionNode.new(val[1].value, val[1].attrs[:target]) ; result = val[0] }
  | command_w_vars
  | command
  | vars

command_w_vars : vars command
  { result = EnvWrapperNode.new(val[0], val[1]) }

vars : vars LValue RValue
    { val[0].add_var(val[1].value, val[2].value) ; result = val[0] }
  | LValue RValue
    { result = EnvNode.new(val[0].value, val[1].value) }

command : command2

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
    # @yydebug = true

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
    [
    # "echo foo",
    # "echo foo ; echo bar baz yep",
    # "echo foo && echo bar baz yep",
    # "echo foo && echo bar && ls foo && ls bar",
    # "echo foo ; echo bar baz yep ; ls foo",
    # "echo foo && echo bar ; ls baz",
    # "echo foo && echo bar ; ls baz ; echo zach || echo gretchen",
    # "echo foo | bar",
    # "echo foo | bar && foo | bar",
    # "foo && bar ; word || baz ; yep | grep -v foo",
    # "( foo )",
    # "( foo a b && bar c d )",
    # "( foo a b && (bar c d | baz e f))",
    # "((((foo))))",
    # "foo -b -c ; (this ;that ;the; other  ;thing) && yep",
    # "foo -b -c ; (this ;that && other  ;thing) && yep",
    # "4 + 5",
    # "!'hello' ; 4 - 4 && 10 + 3",
    # "\\foo <<-EOT\nbar\nEOT",
    # "ls | grep md | grep WISH",
    # "(!upcase)",
    # "echo foo > bar.txt",
    # "ls -l > a.txt ; echo f 2> b.txt ; cat b &> c.txt ; du -sh 1>&2 1>hey.txt",
    # "!Dir.chdir('..')",
    # "FOO=123",
    # "FOO=123 BAR=345",
    # "FOO=abc bar=2314 car=14ab ls -l",
    "FOO=abc BAR='hello world' ls -l ; CAR=f echo foo && say hi"
    ].each do |src|
      puts 'parsing:'
      print src
      puts
      puts 'result:'
      require 'pp'
      ast = Yap::Line::Parser.new.parse(src)
      pp ast
    end


  # puts "---- Evaluating"
  #   require 'pry'
  # binding.pry
  # Evaluator.new.evaltree(ast)
end
