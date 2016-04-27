module Yap::Shell
  module Parser::Nodes
    module Visitor
      def accept(visitor, *args)
        visitor.send "visit_#{self.class.name.split("::").last}", self, *args
      end
    end

    module NoOpNode
      extend Visitor

      def self.accept(*args)
        # no-op
      end
    end

    class ArgumentNode
      include Visitor

      attr_reader :lvalue

      def initialize(token)
        @lvalue = token.value
        @attrs = token.attrs
      end

      def quoted?
        double_quoted? || single_quoted?
      end

      def double_quoted?
        @attrs[:quoted_by] == '"'
      end

      def single_quoted?
        @attrs[:quoted_by] == "'"
      end

      def inspect
        to_s
      end

      def to_s
        "ArgumentNode(#{lvalue.inspect})"
      end
    end

    class AssignmentNode
      include Visitor

      attr_reader :lvalue, :rvalue

      def initialize(lvalue, rvalue)
        @lvalue, @rvalue = lvalue, rvalue
      end

      def inspect
        to_s
      end

      def to_s
        "A(#{lvalue.inspect}=#{rvalue.inspect})"
      end
    end

    class CommandNode
      include Visitor

      attr_reader :command, :args
      attr_accessor :heredoc, :redirects

      def initialize(command, *args, literal:false, heredoc:nil)
        @command = command
        @args = args.flatten
        @literal = literal
        @heredoc = nil
        @redirects = []
      end

      def literal?
        @literal
      end

      def heredoc?
        @heredoc
      end

      def internally_evaluate?
        false
      end

      def inspect
        to_s
      end

      def to_s
        "CommandNode(#{@command}, args: #{@args}, literal:#{literal?}, heredoc: #{heredoc?}, redirects: #{redirects})"
      end
    end

    class CommentNode
      include Visitor

      attr_reader :text

      def initialize(text)
        @text = text
      end

      def inspect
        to_s
      end

      def to_s
        "CommentNode(#{@text})"
      end
    end

    class EnvNode
      include Visitor

      attr_reader :env

      def initialize(token, argument_node)
        @env = {}
        @env[token.value] = argument_node
      end

      def add_var(token, argument_node)
        @env[token.value] = argument_node
      end
    end

    class EnvWrapperNode
      include Visitor

      attr_reader :node

      def initialize(env, node)
        @env = env
        @node = node
      end

      def env
        @env.env
      end
    end

    class StatementsNode
      include Visitor

      attr_reader :head, :tail

      def initialize(head, tail=nil)
        if head.is_a?(StatementsNode) && head.tail.nil?
          @head = head.head
        else
          @head = head
        end
        @tail = tail
      end

      def to_s(indent:0)
        <<-EOT.gsub(/^\s+\|/, '')
          |  #{' ' * indent}StatementsNode(
          |  #{' ' * indent}  #{@head.to_s},
          |  #{' ' * indent}  #{@tail.to_s})
        EOT
      end

      def inspect
        to_s
      end
    end

    class ConditionalNode
      include Visitor

      attr_reader :operator, :expr1, :expr2

      def initialize(operator, expr1, expr2)
        @operator = operator
        @expr1    = expr1
        @expr2    = expr2
      end

      def to_s
        "ConditionalNode(#{@operator}, #{@expr1}, #{@expr2.to_s})"
      end
    end

    class InternalEvalNode
      include Visitor

      attr_reader :src
      alias_method :command, :src

      def initialize(src)
        @src = src
      end

      def args
        nil
      end

      def heredoc
        nil
      end

      def internally_evaluate?
        true
      end

      def to_s
        "InternalEvalNode(#{@src.inspect})"
      end
    end

    class PipelineNode
      include Visitor

      attr_reader :head, :tail

      def initialize(head, tail)
        @head = head
        @tail = tail
      end

      def to_s(indent:0)
        <<-EOT.gsub(/^\s+\|/, '')
          |  #{' ' * indent}PipelineNode(
          |  #{' ' * indent}  #{@head.to_s},
          |  #{' ' * indent}  #{@tail.to_s})
        EOT
      end

      def inspect
        to_s
      end
    end

    class RedirectionNode
      include Visitor

      attr_reader :kind, :target

      def initialize(kind, target)
        @kind = kind
        @target = target
      end

      def to_s(indent:0)
        "RedirectionNode(#{@kind.to_s}, #{@target.to_s})"
      end

      def inspect
        to_s
      end
    end

    class ConcatenationNode
      include Visitor

      attr_reader :left, :right

      def initialize(left, right)
        @left = left
        @right = right
      end

      def to_s(indent:0)
        "ConcatenationNode(left: #{left.to_s}, right: #{right.to_s})"
      end

      def inspect
        to_s
      end

    end

    class CommandSubstitutionNode
      include Visitor

      attr_accessor :tail
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def to_s(indent:0)
        "CommandSubstitutionNode(#{@node.to_s}, tail: #{tail.inspect})"
      end

      def inspect
        to_s
      end
    end

    class BlockNode
      include Visitor

      attr_accessor :head, :tail, :params

      def initialize(head, tail, params: [])
        @head = head
        @tail = tail
        @params = params
      end

      def to_s(indent:0)
        if @counter_reference
          "BlockNode(#{@head.inspect}, tail: #{@tail.inspect} params: #{@params.inspect})"
        else
          "BlockNode(#{@head.inspect}, tail: #{@tail.inspect} params: #{@params.inspect})"
        end
      end

      def inspect
        to_s
      end
    end

    class RangeNode
      include Visitor

      attr_accessor :head, :tail

      def initialize(head, tail=nil)
        @head = head
        @tail = tail
      end

      def to_s(indent:0)
        "(#{@head.inspect}, tail: #{tail.inspect})"
      end

      def inspect
        to_s
      end
    end
  end
end
