require "yap/line/parser/version"
require "yap/line/lexer"

module Yap
  module Line
    class Statement
      attr_reader :command, :args
      attr_accessor :heredoc_marker

      def initialize(command:, args:, heredoc_marker:nil)
        @command = command
        @args = args
        @heredoc_marker = heredoc_marker
      end

      def internally_evaluate?
        false
      end
    end

    class InternalEvalStatement
      attr_reader :command

      def initialize(command:)
        @command = command
      end

      def heredoc_marker
        nil
      end

      def internally_evaluate?
        true
      end
    end

    class AndStatement
      def initialize(statement)
        @statement = statement
      end
    end

    class Parser
      def self.parse(str)
        tokens = Lexer.new.tokenize(str)
        new.parse(tokens)
      end

      def initialize
        @ast = []
      end

      def walk_tree
      end

      def parse(tokens)
        i = 0
        loop do
          break if i >= tokens.length

          token = tokens[i]
          case token.tag
          when :Command
            command_token = token
            arg_tokens = []
            loop do
              token = tokens[i+=1]
              break if i >= tokens.length || token.tag != :Argument
              arg_tokens << token
            end
            @ast << Statement.new(command:command_token.value, args:arg_tokens.map(&:value))
          when :Heredoc
            @ast.last.heredoc_marker = token.value
            i += 1
          when :InternalEval
            @ast << InternalEvalStatement.new(command:token.value)
            i += 1
          when :Terminator
            i += 1
          when :ConditionalTerminator
            node = @ast.pop
            @ast << AndStatement.new(node)
            i += 1
          end
        end
        @ast
      end

    end
  end
end
