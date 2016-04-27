#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.14
# from Racc grammer file "".
#

require 'racc/parser.rb'

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

module Yap
  module Shell
    class ParserImpl < Racc::Parser

module_eval(<<'...end grammar.y/module_eval...', 'grammar.y', 125)
  include Yap::Shell::Parser::Nodes

#=end
  def parse(str)
    @yydebug = true

    @q = Yap::Shell::Parser::Lexer.new.tokenize(str)
    pp @q if ENV["DEBUG"]
    # @q.push [false, '$']   # is optional from Racc 1.3.7
# puts @q.inspect
# puts "---- parse tree follows ----"
    __send__(Racc_Main_Parsing_Routine, _racc_setup(), false)
    # do_parse
  end

  def next_token
    @q.shift
  end

...end grammar.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    25,    26,    29,    17,    27,    29,    29,    29,    19,    23,
    34,    17,    60,     8,    32,    64,    62,     3,    11,    12,
    25,    26,    56,    29,    27,    29,    30,    40,    19,    23,
    58,    17,    41,     8,    31,    65,    25,    26,    11,    12,
    27,    57,    25,    26,    19,    23,    27,    17,    38,     8,
    19,    23,    59,    17,    11,    12,    25,    26,    30,    57,
    27,    12,    25,    26,    19,    23,    31,    17,    57,     8,
    47,    43,    54,    33,    11,    12,    25,    26,    33,    38,
    27,    29,    25,    26,    19,    23,    27,    17,    38,     8,
    19,    23,    28,    17,    11,    12,    17,    44,    25,    26,
    11,    12,    27,    32,   nil,   nil,    19,    23,   nil,    17,
   nil,     8,   nil,   nil,    25,    26,    11,    12,    27,   nil,
   nil,   nil,    19,    23,   nil,    17,   nil,     8,   nil,   nil,
    25,    26,    11,    12,    27,   nil,   nil,   nil,    19,    23,
   nil,    17,   nil,     8,   nil,   nil,    52,   nil,    11,    12 ]

racc_action_check = [
     0,     0,    51,     9,     0,    61,    53,    36,     0,     0,
     9,     0,    51,     0,    49,    61,    53,     0,     0,     0,
    54,    54,    36,    39,    54,    63,     4,    18,    54,    54,
    39,    54,    18,    54,     4,    63,    52,    52,    54,    54,
    52,    37,    33,    33,    52,    52,    33,    52,    16,    52,
    33,    33,    43,    33,    52,    52,    32,    32,    48,    45,
    32,    33,    22,    22,    32,    32,    48,    32,    46,    32,
    28,    22,    32,     6,    32,    32,    17,    17,    50,    26,
    17,     2,    30,    30,    17,    17,    30,    17,    25,    17,
    30,    30,     1,    30,    17,    17,    55,    23,    12,    12,
    30,    30,    12,     5,   nil,   nil,    12,    12,   nil,    12,
   nil,    12,   nil,   nil,    29,    29,    12,    12,    29,   nil,
   nil,   nil,    29,    29,   nil,    29,   nil,    29,   nil,   nil,
    31,    31,    29,    29,    31,   nil,   nil,   nil,    31,    31,
   nil,    31,   nil,    31,   nil,   nil,    31,   nil,    31,    31 ]

racc_action_pointer = [
    -2,    92,    74,   nil,    18,    87,    64,   nil,   nil,   -10,
   nil,   nil,    96,   nil,   nil,   nil,    44,    74,    22,   nil,
   nil,   nil,    60,    85,   nil,    84,    75,   nil,    70,   112,
    80,   128,    54,    40,   nil,   nil,     0,    37,   nil,    16,
   nil,   nil,   nil,    40,   nil,    55,    64,   nil,    50,    -2,
    69,    -5,    34,    -1,    18,    83,   nil,   nil,   nil,   nil,
   nil,    -2,   nil,    18,   nil,   nil ]

racc_action_default = [
   -45,   -45,    -1,    -2,    -4,    -5,    -7,    -8,   -13,   -15,
   -16,   -18,   -45,   -21,   -22,   -23,   -25,   -45,   -28,   -29,
   -31,   -32,   -33,   -45,   -37,   -38,   -40,   -44,   -45,   -45,
   -45,   -45,   -45,   -45,   -17,   -20,   -45,   -24,   -42,   -45,
   -27,   -30,   -34,   -45,   -36,   -39,   -41,    66,    -3,   -45,
    -6,   -45,   -45,   -45,   -45,   -14,   -19,   -43,   -26,   -35,
   -11,   -45,    -9,   -45,   -12,   -10 ]

racc_goto_table = [
     2,    35,    50,    49,    37,    55,    48,     1,    42,   nil,
   nil,   nil,    36,    45,    46,   nil,   nil,    39,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,    51,    53,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    35,   nil,   nil,
   nil,   nil,    61,   nil,    63 ]

racc_goto_check = [
     2,     9,     5,     4,    13,     7,     3,     1,    16,   nil,
   nil,   nil,     2,    13,    13,   nil,   nil,     2,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,     2,     2,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,     9,   nil,   nil,
   nil,   nil,     2,   nil,     2 ]

racc_goto_pointer = [
   nil,     7,     0,   -23,   -26,   -28,   nil,   -28,   nil,    -8,
   nil,   nil,   nil,   -12,   nil,   nil,   -14,   nil,   nil ]

racc_goto_default = [
   nil,   nil,   nil,     4,     5,     6,     7,     9,    10,    13,
    14,    15,    16,   nil,    18,    20,    21,    22,    24 ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 24, :_reduce_none,
  1, 24, :_reduce_2,
  3, 25, :_reduce_3,
  1, 25, :_reduce_4,
  1, 25, :_reduce_none,
  3, 26, :_reduce_6,
  1, 26, :_reduce_none,
  1, 26, :_reduce_none,
  4, 29, :_reduce_9,
  5, 29, :_reduce_10,
  4, 29, :_reduce_11,
  5, 29, :_reduce_12,
  1, 27, :_reduce_13,
  3, 28, :_reduce_14,
  1, 28, :_reduce_none,
  1, 28, :_reduce_none,
  2, 31, :_reduce_17,
  1, 31, :_reduce_18,
  3, 30, :_reduce_19,
  2, 30, :_reduce_20,
  1, 30, :_reduce_none,
  1, 30, :_reduce_none,
  1, 30, :_reduce_none,
  2, 32, :_reduce_24,
  1, 32, :_reduce_none,
  3, 35, :_reduce_26,
  2, 33, :_reduce_27,
  1, 33, :_reduce_none,
  1, 33, :_reduce_29,
  2, 37, :_reduce_30,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  2, 38, :_reduce_34,
  3, 40, :_reduce_35,
  2, 40, :_reduce_36,
  1, 39, :_reduce_none,
  1, 41, :_reduce_38,
  2, 41, :_reduce_39,
  1, 41, :_reduce_40,
  2, 41, :_reduce_41,
  1, 36, :_reduce_42,
  2, 36, :_reduce_43,
  1, 34, :_reduce_44 ]

racc_reduce_n = 45

racc_shift_n = 66

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
  :BeginCommandSubstitution => 13,
  :EndCommandSubstitution => 14,
  :Range => 15,
  :BlockBegin => 16,
  :BlockEnd => 17,
  :BlockParams => 18,
  :BlankLine => 19,
  :Comment => 20,
  "(" => 21,
  ")" => 22 }

racc_nt_base = 23

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
  "BeginCommandSubstitution",
  "EndCommandSubstitution",
  "Range",
  "BlockBegin",
  "BlockEnd",
  "BlockParams",
  "BlankLine",
  "Comment",
  "\"(\"",
  "\")\"",
  "$start",
  "program",
  "stmts",
  "stmt",
  "range_stmt",
  "pipeline",
  "block_stmt",
  "stmts2",
  "stmts2_w_comment",
  "stmt_w_substitutions",
  "command_w_heredoc",
  "internal_eval",
  "stmt_w_substitutions2",
  "args",
  "command_w_redirects",
  "command_w_vars",
  "command",
  "vars",
  "command2" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

module_eval(<<'.,.,', 'grammar.y', 22)
  def _reduce_2(val, _values, result)
     result = NoOpNode 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 25)
  def _reduce_3(val, _values, result)
     result = StatementsNode.new(val[0], val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 27)
  def _reduce_4(val, _values, result)
     result = StatementsNode.new(val[0]) 
    result
  end
.,.,

# reduce 5 omitted

module_eval(<<'.,.,', 'grammar.y', 31)
  def _reduce_6(val, _values, result)
     result = ConditionalNode.new(val[1], val[0], val[2]) 
    result
  end
.,.,

# reduce 7 omitted

# reduce 8 omitted

module_eval(<<'.,.,', 'grammar.y', 36)
  def _reduce_9(val, _values, result)
     result = val[0].tap { |range_node| range_node.tail = BlockNode.new(nil, val[2]) } 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 38)
  def _reduce_10(val, _values, result)
     result = val[0].tap { |range_node| range_node.tail = BlockNode.new(nil, val[3], params: val[2]) } 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 40)
  def _reduce_11(val, _values, result)
     result = BlockNode.new(val[0], val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 42)
  def _reduce_12(val, _values, result)
     result = BlockNode.new(val[0], val[3], params: val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 45)
  def _reduce_13(val, _values, result)
     result = RangeNode.new(val[0]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 48)
  def _reduce_14(val, _values, result)
     result = PipelineNode.new(val[0], val[2]) 
    result
  end
.,.,

# reduce 15 omitted

# reduce 16 omitted

module_eval(<<'.,.,', 'grammar.y', 53)
  def _reduce_17(val, _values, result)
     result = StatementsNode.new(val[0], CommentNode.new(val[1])) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 55)
  def _reduce_18(val, _values, result)
     result = CommentNode.new(val[0]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 58)
  def _reduce_19(val, _values, result)
     result = val[1] 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 60)
  def _reduce_20(val, _values, result)
     result = ConcatenationNode.new(val[0], val[1]) 
    result
  end
.,.,

# reduce 21 omitted

# reduce 22 omitted

# reduce 23 omitted

module_eval(<<'.,.,', 'grammar.y', 66)
  def _reduce_24(val, _values, result)
     result = val[0] ; val[0].tail = val[1] 
    result
  end
.,.,

# reduce 25 omitted

module_eval(<<'.,.,', 'grammar.y', 70)
  def _reduce_26(val, _values, result)
     result = CommandSubstitutionNode.new(val[1]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 73)
  def _reduce_27(val, _values, result)
     val[0].heredoc = val[1] ; result = val[0] 
    result
  end
.,.,

# reduce 28 omitted

module_eval(<<'.,.,', 'grammar.y', 76)
  def _reduce_29(val, _values, result)
     result = RedirectionNode.new(val[0]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 79)
  def _reduce_30(val, _values, result)
     val[0].redirects << RedirectionNode.new(val[1]) ; result = val[0] 
    result
  end
.,.,

# reduce 31 omitted

# reduce 32 omitted

# reduce 33 omitted

module_eval(<<'.,.,', 'grammar.y', 85)
  def _reduce_34(val, _values, result)
     result = EnvWrapperNode.new(val[0], val[1]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 88)
  def _reduce_35(val, _values, result)
     val[0].add_var(val[1], ArgumentNode.new(val[2])) ; result = val[0] 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 90)
  def _reduce_36(val, _values, result)
     result = EnvNode.new(val[0], ArgumentNode.new(val[1])) 
    result
  end
.,.,

# reduce 37 omitted

module_eval(<<'.,.,', 'grammar.y', 95)
  def _reduce_38(val, _values, result)
     result = CommandNode.new(val[0]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 97)
  def _reduce_39(val, _values, result)
     result = CommandNode.new(val[0], val[1].flatten) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 99)
  def _reduce_40(val, _values, result)
     result = CommandNode.new(val[0], literal:true) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 101)
  def _reduce_41(val, _values, result)
     result = CommandNode.new(val[0], val[1].flatten, literal:true) 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 104)
  def _reduce_42(val, _values, result)
     result = [ArgumentNode.new(val[0])] 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 106)
  def _reduce_43(val, _values, result)
     result = [val[0], ArgumentNode.new(val[1])].flatten 
    result
  end
.,.,

module_eval(<<'.,.,', 'grammar.y', 109)
  def _reduce_44(val, _values, result)
     result = InternalEvalNode.new(val[0]) 
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
