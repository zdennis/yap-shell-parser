require "yap/line/parser/version"
require "yap/line/lexer"

module Yap
  module Line
    class Statement
      include Comparable

      attr_reader :command, :args
      attr_accessor :heredoc_marker

      def initialize(command:, args:, heredoc_marker:nil, literal:false)
        @command = command
        @args = args
        @heredoc_marker = heredoc_marker
        @literal = literal
      end

      def <=>(other)
        return -1 if self.class != other.class
        return 0 if [command, args, heredoc_marker, literal?] == [other.command, other.args, other.heredoc_marker, other.literal?]
        -1
      end

      def internally_evaluate?
        false
      end

      def literal?
        @literal
      end
    end

    class InternalEvalStatement
      include Comparable
      attr_reader :command

      def initialize(command:)
        @command = command
      end

      def <=>(other)
        return -1 if self.class != other.class
        return 0 if [command, heredoc_marker, internally_evaluate?] == [other.command, other.heredoc_marker, other.internally_evaluate?]
        -1
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
      class Error < ::StandardError ; end
      class UnknownTokenError < Error ; end

      def self.parse(str)
        tokens = Lexer.new.tokenize(str)
        new.parse(tokens)
      end

      def initialize
        @ast = []
      end

      def parse(tokens)
        i = 0
        loop do
          break if i >= tokens.length

          token = tokens[i]
          case token.tag
          when :Command
            result = parse_command_token(at:i, from_tokens:tokens, literal:false)
            @ast << result.statement
            i += result.consumed_length
          when :LiteralCommand
            result = parse_command_token(at:i, from_tokens:tokens, literal:true)
            @ast << result.statement
            i += result.consumed_length
          when :Heredoc
            @ast.last.heredoc_marker = token.value
            i += 1
          when :InternalEval
            @ast << InternalEvalStatement.new(command:token.value)
            i += 1
          when :Separator
            i += 1
          when :Conditional
            node = @ast.pop
            @ast << AndStatement.new(node)
            i += 1
          else
            raise UnknownTokenError, "Don't know how to pares token: #{token.inspect}"
          end
        end
        @ast
      end

      private

      def parse_command_token(at:, from_tokens:, literal:)
        token = from_tokens[at]
        consumed_length = 0
        arg_tokens = []
        loop do
          consumed_length += 1
          _token = from_tokens[at+=1]
          break if at >= from_tokens.length || _token.tag != :Argument
          arg_tokens << _token
        end
        statement = Statement.new(command:token.value, args:arg_tokens.map(&:value), literal:literal)
        OpenStruct.new(statement:statement, consumed_length:consumed_length)
      end

    end
  end
end
