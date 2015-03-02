#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.9
# from Racc grammer file "".
#

require 'racc/parser.rb'
module Yap
  module Shell
    class ParserImpl < Racc::Parser

module_eval(<<'...end grammar.y/module_eval...', 'grammar.y', 80)
  include Yap::Shell::Parser::Nodes
#=end
  def parse(str)
    # @yydebug = true

    @q = Yap::Shell::Parser::Lexer.new.tokenize(str)
    # @q.push [false, '$']   # is optional from Racc 1.3.7
# puts @q.inspect
# puts "---- parse tree follows ----"
    __send__(Racc_Main_Parsing_Routine, _racc_setup(), false)
    #do_parse
  end

  def next_token
    @q.shift
  end

...end grammar.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    15,    16,    29,    23,    17,    29,    15,    16,    24,    13,
    17,     6,    15,    16,    27,    13,    17,     6,    15,    16,
    31,    13,    17,     6,    15,    16,    21,    13,    17,     6,
    15,    16,    20,    13,    19,     6,    19,    18,    36,    26,
    37,    35,    37,    20,    21 ]

racc_action_check = [
     0,     0,    16,     9,     0,    15,     6,     6,     9,     0,
     6,     0,    21,    21,    13,     6,    21,     6,    20,    20,
    18,    21,    20,    21,    19,    19,     4,    20,    19,    20,
    12,    12,     3,    19,    22,    19,     2,     1,    26,    12,
    28,    22,    30,    32,    33 ]

racc_action_pointer = [
    -2,    37,    29,    24,    17,   nil,     4,   nil,   nil,    -2,
   nil,   nil,    28,     2,   nil,     1,    -2,   nil,    20,    22,
    16,    10,    27,   nil,   nil,   nil,    26,   nil,    36,   nil,
    38,   nil,    35,    35,   nil,   nil,   nil,   nil ]

racc_action_default = [
   -28,   -28,    -1,    -3,    -5,    -7,   -28,    -9,   -10,   -12,
   -14,   -15,   -16,   -28,   -20,   -21,   -23,   -27,   -28,   -28,
   -28,   -28,   -28,   -11,   -13,   -17,   -28,   -19,   -22,   -25,
   -24,    38,    -2,    -4,    -6,    -8,   -18,   -26 ]

racc_goto_table = [
     2,    28,    30,    33,    32,    34,    22,    25,     1 ]

racc_goto_check = [
     2,    13,    13,     4,     3,     5,     2,    10,     1 ]

racc_goto_pointer = [
   nil,     8,     0,   -15,   -17,   -16,   nil,   nil,   nil,   nil,
    -5,   nil,   nil,   -14 ]

racc_goto_default = [
   nil,   nil,   nil,     3,     4,     5,     7,     8,     9,    10,
    11,    12,    14,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 16, :_reduce_none,
  3, 17, :_reduce_2,
  1, 17, :_reduce_3,
  3, 18, :_reduce_4,
  1, 18, :_reduce_none,
  3, 19, :_reduce_6,
  1, 19, :_reduce_none,
  3, 20, :_reduce_8,
  1, 20, :_reduce_none,
  1, 20, :_reduce_none,
  2, 21, :_reduce_11,
  1, 21, :_reduce_none,
  2, 23, :_reduce_13,
  1, 23, :_reduce_none,
  1, 23, :_reduce_none,
  1, 23, :_reduce_none,
  2, 24, :_reduce_17,
  3, 26, :_reduce_18,
  2, 26, :_reduce_19,
  1, 25, :_reduce_none,
  1, 27, :_reduce_21,
  2, 27, :_reduce_22,
  1, 27, :_reduce_23,
  2, 27, :_reduce_24,
  1, 28, :_reduce_25,
  2, 28, :_reduce_26,
  1, 22, :_reduce_27 ]

racc_reduce_n = 28

racc_shift_n = 38

racc_token_table = {
  false => 0,
  :error => 1,
  :Command => 2,
  :LiteralCommand => 3,
  :Argument => 4,
  :Heredoc => 5,
  :InternalEval => 6,
  :Separator => 7,
  :Conditional => 8,
  :Pipe => 9,
  :Redirection => 10,
  :LValue => 11,
  :RValue => 12,
  "(" => 13,
  ")" => 14 }

racc_nt_base = 15

racc_use_result_var = true

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "Command",
  "LiteralCommand",
  "Argument",
  "Heredoc",
  "InternalEval",
  "Separator",
  "Conditional",
  "Pipe",
  "Redirection",
  "LValue",
  "RValue",
  "\"(\"",
  "\")\"",
  "$start",
  "program",
  "stmts",
  "stmt",
  "pipeline",
  "stmts2",
  "command_w_heredoc",
  "internal_eval",
  "command_w_redirects",
  "command_w_vars",
  "command",
  "vars",
  "command2",
  "args" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

module_eval(<<'.,.,', 'grammar.y', 23)
  def _reduce_2(val, _values, result)
     result = StatementsNode.new(val[0], val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 25)
  def _reduce_3(val, _values, result)
     result = StatementsNode.new(val[0]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 28)
  def _reduce_4(val, _values, result)
     result = ConditionalNode.new(val[1].value, val[0], val[2]) 
    result
  end
.,.,

# reduce 5 omitted

module_eval(<<'.,.,', 'grammar.y', 32)
  def _reduce_6(val, _values, result)
     result = PipelineNode.new(val[0], val[2]) 
    result
  end
.,.,

# reduce 7 omitted

module_eval(<<'.,.,', 'grammar.y', 36)
  def _reduce_8(val, _values, result)
     result = val[1] 
    result
  end
.,.,

# reduce 9 omitted

# reduce 10 omitted

module_eval(<<'.,.,', 'grammar.y', 41)
  def _reduce_11(val, _values, result)
     val[0].heredoc = val[1] ; result = val[0] 
    result
  end
.,.,

# reduce 12 omitted

module_eval(<<'.,.,', 'grammar.y', 45)
  def _reduce_13(val, _values, result)
     val[0].redirects << RedirectionNode.new(val[1].value, val[1].attrs[:target]) ; result = val[0] 
    result
  end
.,.,

# reduce 14 omitted

# reduce 15 omitted

# reduce 16 omitted

module_eval(<<'.,.,', 'grammar.y', 51)
  def _reduce_17(val, _values, result)
     result = EnvWrapperNode.new(val[0], val[1]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 54)
  def _reduce_18(val, _values, result)
     val[0].add_var(val[1].value, val[2].value) ; result = val[0] 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 56)
  def _reduce_19(val, _values, result)
     result = EnvNode.new(val[0].value, val[1].value) 
    result
  end
.,.,

# reduce 20 omitted

module_eval(<<'.,.,', 'grammar.y', 61)
  def _reduce_21(val, _values, result)
     result = CommandNode.new(val[0].value) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 63)
  def _reduce_22(val, _values, result)
     result = CommandNode.new(val[0].value, val[1].flatten) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 65)
  def _reduce_23(val, _values, result)
     result = CommandNode.new(val[0].value, literal:true) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 67)
  def _reduce_24(val, _values, result)
     result = CommandNode.new(val[0].value, val[1].flatten, literal:true) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 70)
  def _reduce_25(val, _values, result)
     result = [val[0].value] 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 72)
  def _reduce_26(val, _values, result)
     result = [val[0], val[1].value] 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 75)
  def _reduce_27(val, _values, result)
     result = InternalEvalNode.new(val[0].value) 
    result
  end
.,.,

def _reduce_none(val, _values, result)
  val[0]
end

    end   # class ParserImpl
    end   # module Shell
  end   # module Yap


if $0 == __FILE__
  $LOAD_PATH.unshift File.dirname(__FILE__) + "/lib/"
  require 'yap/shell/parser/lexer'
  require 'yap/shell/parser/nodes'
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
      ast = Yap::Shell::Parser.new.parse(src)
      pp ast
    end


  # puts "---- Evaluating"
  #   require 'pry'
  # binding.pry
  # Evaluator.new.evaltree(ast)
end
