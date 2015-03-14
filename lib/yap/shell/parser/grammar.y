# $Id$
#
# convert Array-like string into Ruby's Array.

class Yap::Shell::ParserImpl
  token Command LiteralCommand Argument Heredoc InternalEval Separator Conditional Pipe Redirection LValue RValue BeginCommandSubstitution EndCommandSubstitution
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
    { result = [ArgumentNode.new(val[0].value)] }
  | args Argument
    { result = [val[0], ArgumentNode.new(val[1].value)].flatten }

internal_eval : InternalEval
    { result = InternalEvalNode.new(val[0].value) }

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
puts @q.inspect
puts "---- parse tree follows ----"
    __send__(Racc_Main_Parsing_Routine, _racc_setup(), false)
    # do_parse
  end

  def next_token
    @q.shift
  end

---- footer

if $0 == __FILE__
  $LOAD_PATH.unshift File.dirname(__FILE__) + "/lib/"
  require 'yap/shell/parser/lexer'
  require 'yap/shell/parser/nodes'
    [
    # "echo `echo hi`",
    # "`git cbranch`",
    # "`git cbranch`.bak",
    # "echo `echo hi`",
    "echo `echo hi` foo bar baz",
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
