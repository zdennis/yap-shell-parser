#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.9
# from Racc grammer file "".
#

require 'racc/parser.rb'
module Yap
  module Line
    class MyParser < Racc::Parser

module_eval(<<'...end grammar.y/module_eval...', 'grammar.y', 51)

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

...end grammar.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
     7,     8,     9,    10,    11,    13,    14,     7,     7,     7,
    18,    10,    11 ]

racc_action_check = [
     0,     1,     3,     4,     5,     7,     8,     9,    10,    11,
    12,    15,    16 ]

racc_action_pointer = [
    -2,     1,   nil,    -5,    -5,    -5,   nil,     1,     6,     5,
     6,     7,     6,   nil,   nil,     3,     3,   nil,   nil ]

racc_action_default = [
   -13,   -13,    -1,    -2,    -4,    -6,    -8,    -9,   -13,   -13,
   -13,   -13,   -10,   -11,    19,    -3,    -5,    -7,   -12 ]

racc_goto_table = [
     4,     1,     3,     2,    16,    17,    12,   nil,   nil,    15 ]

racc_goto_check = [
     4,     1,     3,     2,     5,     6,     7,   nil,   nil,     4 ]

racc_goto_pointer = [
   nil,     1,     3,     2,     0,    -6,    -6,    -1 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,     5,     6,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 11, :_reduce_none,
  1, 12, :_reduce_none,
  3, 13, :_reduce_3,
  1, 13, :_reduce_4,
  3, 14, :_reduce_5,
  1, 14, :_reduce_none,
  3, 15, :_reduce_7,
  1, 15, :_reduce_none,
  1, 16, :_reduce_9,
  2, 16, :_reduce_10,
  1, 17, :_reduce_11,
  2, 17, :_reduce_12 ]

racc_reduce_n = 13

racc_shift_n = 19

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
  :Pipe => 9 }

racc_nt_base = 10

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
  "$start",
  "program",
  "stmt",
  "expr",
  "mulex",
  "pipeline",
  "command",
  "args" ]

Racc_debug_parser = true

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

# reduce 2 omitted

module_eval(<<'.,.,', 'grammar.y', 26)
  def _reduce_3(val, _values, result)
     result = [*val[0], val[1], val[2]]
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 28)
  def _reduce_4(val, _values, result)
     result = val
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 31)
  def _reduce_5(val, _values, result)
     result = val[1], val[0], val[2]
    result
  end
.,.,

# reduce 6 omitted

module_eval(<<'.,.,', 'grammar.y', 35)
  def _reduce_7(val, _values, result)
     result = val[1], val[0], val[2]
    result
  end
.,.,

# reduce 8 omitted

module_eval(<<'.,.,', 'grammar.y', 39)
  def _reduce_9(val, _values, result)
     result = val
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 41)
  def _reduce_10(val, _values, result)
     result = [val[0], val[1]].flatten
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 44)
  def _reduce_11(val, _values, result)
     result = [val[0]]
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 46)
  def _reduce_12(val, _values, result)
     result = val
    result
  end
.,.,

def _reduce_none(val, _values, result)
  val[0]
end

    end   # class MyParser
    end   # module Line
  end   # module Yap


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