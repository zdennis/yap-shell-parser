require "yap/line/parser/version"
require "yap/line/lexer"

module Yap
  module Line
    class Statement
      attr_reader :command, :args

      def initialize(command:command, args:args)
        @command = command
        @args = args
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
              break if i >= tokens.length
              break if [:Terminator, :ConditionalTerminator].include?(token.tag)
              arg_tokens << token
            end
            @ast << Statement.new(command: command_token.value, args:arg_tokens.map(&:value))
          when :Terminator
            i += 1
          when :ConditionalTerminator
            i += 1
            node = @ast.pop
            @ast << AndStatement.new(node)
          end
        end
        @ast
      end

    end
  end
end
