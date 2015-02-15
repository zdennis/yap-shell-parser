
module Yap
  module Line
    module Nodes
      module Visitor
        def accept(visitor, *args)
          visitor.send "visit_#{self.class.name.split("::").last}", self, *args
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

        def to_s
          "CommandNode(#{@command}, args: #{@args}, literal:#{literal?}, heredoc: #{heredoc?}, redirects: #{redirects})"
        end

        def inspect
          to_s
        end
      end

      class StatementsNode
        include Visitor

        attr_reader :head, :tail

        def initialize(head, tail=nil)
          @head = head
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

        def initialize(src)
          @src = src
        end

        def internally_evaluate?
          true
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

        attr_reader :head, :tail

        def initialize(redirection, target)
          @redirection = redirection
          @target = target
        end

        def to_s(indent:0)
          "RedirectionNode(#{@redirection.to_s}, #{@target.to_s})"
        end

        def inspect
          to_s
        end
      end
    end
  end
end
