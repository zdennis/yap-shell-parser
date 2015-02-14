# $Id$
#
# convert Array-like string into Ruby's Array.

class Yap::Line::MyParser
token Command LiteralCommand Argument Heredoc InternalEval Separator Conditional Pipe
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

# echo foo && echo bar ; ls baz ; echo zach || echo gretchen
program : stmt

stmt : expr

expr : expr Separator mulex
    { result = [val[0], val[2]] }
  | mulex
    { result = val }

mulex : mulex Conditional pipeline
    { result = val[1], val[0], val[2] }
  | pipeline

pipeline : pipeline Pipe stmts2
    { result = val[1], val[0], val[2] }
  | stmts2

stmts2 : '(' expr ')'
    { result = val[0], *val[1], val[2] }
  | command
  | internal_eval

command : Command
    { result = val }
  | Command args
    { result = [val[0], val[1]].flatten }

args : Argument
    { result = [val[0]]}
  | args Argument
    { result = val }

internal_eval : InternalEval
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

class Evaluator

  def evaltree(tree)
    result = 0
    leftnode = tree[0]
    if leftnode.is_a?(Array)
      result = evaltree(leftnode)
    elsif leftnode
      puts leftnode.inspect
      puts tree[1..-1].inspect
      puts "--"
      result = evalnode leftnode, tree[1..-1]
    end

    rightnode = tree[1]
    if rightnode.is_a?(Array)
      result = evaltree(rightnode)
    elsif rightnode
      puts rightnode.inspect
      puts tree[1..-1].inspect
      puts "--"
      result = evalnode rightnode, tree[1..-1]
    end
    result
  end

  def evalnode(node, parts)
    result = nil
    puts "NODE: #{node.inspect}"
    puts "PARTS: #{parts.inspect}"
    case node.tag
    when :InternalEval
      result = eval node.value
      puts "Eval'd: #{result}"
    when :Separator
      puts "no-op"
    when :Conditional
      result = evaltree(parts[0])
      if result > 0
        result = evaltree(parts[1])
      end
      puts "CEval'd: #{result}"
    else
      raise "Don't know how to evalnode: #{node.inspect}"
    end
    result
  end
end


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
  src = "( foo )"
  src = "( foo a b && bar c d )"
  src = "( foo a b && (bar c d | baz e f))"
  src = "((((foo))))"
  src = "foo -b -c ; (this ;that ;the; other  ;thing) && yep"
  src = "foo -b -c ; (this ;that && other  ;thing) && yep"
  src = "4 + 5"
  src = "!'hello' ; 4 - 4 && 10 + 3"
  puts 'parsing:'
  print src
  puts
  puts 'result:'
  require 'pp'
  ast = Yap::Line::MyParser.new.parse(src)
  pp ast

  puts "---- Evaluating"
  Evaluator.new.evaltree(ast)
end
