# $Id$
#
# convert Array-like string into Ruby's Array.

class Yap::Shell::ParserImpl
  token Command LiteralCommand Argument Heredoc InternalEval Separator Conditional Pipe Redirection LValue RValue BeginCommandSubstitution EndCommandSubstitution Range BlockBegin BlockEnd BlockParams BlankLine Comment
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
  | BlankLine
    { result = NoOpNode }

stmts : stmts Separator stmt
    { result = StatementsNode.new(val[0], val[2]) }
  | stmt
    { result = StatementsNode.new(val[0]) }
  | range_stmt

stmt : stmt Conditional pipeline
    { result = ConditionalNode.new(val[1], val[0], val[2]) }
  | pipeline
  | block_stmt

block_stmt : range_stmt BlockBegin stmts BlockEnd
    { result = val[0].tap { |range_node| range_node.tail = BlockNode.new(nil, val[2]) } }
  | range_stmt BlockBegin BlockParams stmts BlockEnd
    { result = val[0].tap { |range_node| range_node.tail = BlockNode.new(nil, val[3], params: val[2]) } }
  | stmt BlockBegin stmts BlockEnd
    { result = BlockNode.new(val[0], val[2]) }
  | stmt BlockBegin BlockParams stmts BlockEnd
    { result = BlockNode.new(val[0], val[3], params: val[2]) }

range_stmt : Range
    { result = RangeNode.new(val[0]) }

pipeline : pipeline Pipe stmts2
    { result = PipelineNode.new(val[0], val[2]) }
  | stmts2
  | stmts2_w_comment

stmts2_w_comment : stmts2 Comment
    { result = StatementsNode.new(val[0], CommentNode.new(val[1])) }
  | Comment
    { result = CommentNode.new(val[0]) }

stmts2 : '(' stmts ')'
    { result = val[1] }
  | stmts2 stmt_w_substitutions
    { result = ConcatenationNode.new(val[0], val[1]) }
  | stmt_w_substitutions
  | command_w_heredoc
  | internal_eval

stmt_w_substitutions : stmt_w_substitutions2 args
    { result = val[0] ; val[0].tail = val[1] }
  | stmt_w_substitutions2

stmt_w_substitutions2 : BeginCommandSubstitution stmts EndCommandSubstitution
  { result = CommandSubstitutionNode.new(val[1]) }

command_w_heredoc : command_w_redirects Heredoc
    { val[0].heredoc = val[1] ; result = val[0] }
  | command_w_redirects
  | Redirection
    { result = RedirectionNode.new(val[0]) }

command_w_redirects : command_w_redirects Redirection
    { val[0].redirects << RedirectionNode.new(val[1]) ; result = val[0] }
  | command_w_vars
  | command
  | vars

command_w_vars : vars command
  { result = EnvWrapperNode.new(val[0], val[1]) }

vars : vars LValue RValue
    { val[0].add_var(val[1], ArgumentNode.new(val[2])) ; result = val[0] }
  | LValue RValue
    { result = EnvNode.new(val[0], ArgumentNode.new(val[1])) }

command : command2

command2: Command
    { result = CommandNode.new(val[0]) }
  | Command args
    { result = CommandNode.new(val[0], val[1].flatten) }
  | LiteralCommand
    { result = CommandNode.new(val[0], literal:true) }
  | LiteralCommand args
    { result = CommandNode.new(val[0], val[1].flatten, literal:true) }

args : Argument
    { result = [ArgumentNode.new(val[0])] }
  | args Argument
    { result = [val[0], ArgumentNode.new(val[1])].flatten }

internal_eval : InternalEval
    { result = InternalEvalNode.new(val[0]) }

---- header
if $0 ==__FILE__
  $LOAD_PATH.unshift File.dirname(__FILE__) + "/../../"
  module Yap
    module Shell
      module Parser
      end
    end
  end
  require 'yap/shell/parser/nodes'
end

---- inner
  include Yap::Shell::Parser::Nodes

#=end
  def parse(str)
    @yydebug = true

    @q = Yap::Shell::Parser::Lexer.new.tokenize(str)

    # @q.push [false, '$']   # is optional from Racc 1.3.7
# puts @q.inspect
# puts "---- parse tree follows ----"
    __send__(Racc_Main_Parsing_Routine, _racc_setup(), false)
    # do_parse
  end

  def next_token
    @q.shift
  end

---- footer

if $0 == __FILE__
  require 'pry'
  $LOAD_PATH.unshift File.dirname(__FILE__) + "/lib/"
  require 'yap/shell/parser/lexer'
  require 'yap/shell/parser/nodes'
    [
    # "echo `echo hi`",
    # "`git cbranch`",
    # "`git cbranch`.bak",
    # "echo `echo hi`",
    # "ls *.rb te* { |f| f }",
    # "f { |a, b, c| echo foo }"
    "(0..3) as n : echo hi",
    # "`hi``bye` `what`",
    # "echo && `what` && where is `that`thing | `you know`",
    ].each do |src|
      puts 'parsing:'
      print src
      puts
      puts 'result:'
      require 'pp'
      ast = Yap::Shell::ParserImpl.new.parse(src)
      pp ast
    end


  # puts "---- Evaluating"
  #   require 'pry'
  # binding.pry
  # Evaluator.new.evaltree(ast)
end
