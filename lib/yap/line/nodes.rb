
module Yap
  module Line
    module Nodes
      class Command
        attr_reader :command, :args
        attr_accessor :heredoc

        def initialize(command, *args, literal:false, heredoc:nil)
          @command = command
          @args = args.flatten
          @literal = literal
          @heredoc = nil
        end

        def literal?
          @literal
        end

        def heredoc?
          @heredoc
        end

        def to_s(indent:0)
          "#{' ' * indent}Command(#{@command}, args: #{@args}, literal:#{literal?}, heredoc: #{heredoc?})"
        end

        def inspect
          to_s
        end
      end

      class Statements
        attr_reader :head, :tail

        def initialize(head, tail=nil)
          @head = head
          @tail = tail
        end

        def to_s(indent:0)
          <<-EOT.gsub(/^\s+\|/, '')
            |  #{' ' * indent}Statements(
            |  #{' ' * indent}  #{@head.to_s},
            |  #{' ' * indent}  #{@tail.to_s}
            |  #{' ' * indent}
            )
          EOT
        end

        def inspect
          to_s
        end
      end

      class Conditional
        attr_reader :operator, :expr1, :expr2
        def initialize(operator, expr1, expr2)
          @operator = operator
          @expr1    = expr1
          @expr2    = expr2
        end

        def to_s(indent:0)
          "#{' ' * indent}Conditional(#{@operator}, #{@expr1}, #{@expr2.to_s})"
        end
      end
    end
  end
end
