require 'ostruct'

module Yap
  module Line
    class Lexer
      class Token
        include Comparable

        attr_reader :tag, :lineno, :attrs

        def initialize(tag, lineno:,attrs:{})
          @tag = tag
          @lineno = lineno
          @attrs = @attrs
        end

        def <=>(other)
          return -1 if self.class != other.class
          return 0 if [tag, lineno, attrs] == [other.tag, other.lineno, other.attrs]
          -1
        end

        def inspect
          "'#{tag}'"
        end

        def to_s
          green("Token(#{tag.inspect} on #{lineno})")
        end

        def length
          to_s.length
        end
      end

      COMMAND                = /\A([A-Za-z_]+[A-Za-z_0-9]*)/
      WHITESPACE             = /\A[^\n\S]+/
      ARGUMENT               = /\A([\S]+)/
      TERMINATOR             = /\A(;)/
      CONDITIONAL_TERMINATOR =/\A(&&|\|\|)/

      def tokenize(str)
        @str = str
        @tokens = []
        @lineno = 0
        @looking_for_args = false

        max = 100
        count = 0
        @current_position = 0
        process_next_chunk = -> { @chunk = str.slice(@current_position..-1) ; @chunk != "" }

        while process_next_chunk.call
          result = command_token ||
            whitespace_token ||
            terminator_token ||
            string_argument_token ||
            argument_token ||


          count += 1
          raise "Infinite loop detected on #{@chunk.inspect}" if count == max

          @current_position += result.to_i
        end

        @tokens
      end

      private

      def token(tag, value, attrs:{})
        @tokens.push [tag, Token.new(value, lineno:@lineno, attrs:attrs)]
      end

      def command_token
        if !@looking_for_args && md=@chunk.match(COMMAND)
          @looking_for_args = true
          token :Command, md[0]
          md[0].length
        end
      end

      # Matches and consumes non-meaningful whitespace.
      def whitespace_token
        return nil unless md=WHITESPACE.match(@chunk)
        input = md.to_a[0]
        input.length
      end

      def argument_token
        if @looking_for_args && md=@chunk.match(ARGUMENT)
          token :Argument, md[0]
          md[0].length
        end
      end

      def terminator_token
        if md=@chunk.match(TERMINATOR)
          @looking_for_args = false
          token :Terminator, md[0]
          md[0].length
        elsif md=@chunk.match(CONDITIONAL_TERMINATOR)
          @looking_for_args = false
          token :ConditionalTerminator, md[0]
          md[0].length
        end
      end

      # Matches single and double quoted strings
      def string_argument_token
        if %w(' ").include?(@chunk[0])
          result = process_string @chunk[0..-1], @chunk[0]
          token :Argument, result.str
          return result.consumed_length
        end
      end

      def process_string(input_str, delimiter, indent=0)
        return input_str if input_str.length == 0
        nested_delimiter = "\\#{delimiter}"

        i = delimiter.length  # start string matching after our delimiter
        result_str = ''

        loop do
          chunk = input_str[i..-1]

          puts "#{' '*indent}I: #{i}" if ENV["DEBUG"]

          if i >= input_str.length
            puts "#{' '*indent}C-yah: result:#{result_str.inspect}  length: #{input_str.length}"  if ENV["DEBUG"]
            return OpenStruct.new(str:result_str, consumed_length: input_str.length)
          end

          if chunk.start_with?(nested_delimiter) # we found a nested escaped string
            puts "#{' '*indent}A-pre: chunk:#{chunk.inspect}  nested_delimiter:#{nested_delimiter.inspect}" if ENV["DEBUG"]
            result = process_string(chunk[0..-1], nested_delimiter, indent+2)
            result_str << [delimiter, result.str, delimiter].join
            puts "#{' '*indent}A-pos: result:#{result.inspect}  result_str:#{result_str.inspect}  #{nested_delimiter.length} + #{result.consumed_length} + #{nested_delimiter.length}" if ENV["DEBUG"]

            i += result.consumed_length

          elsif chunk.start_with?(delimiter)    # we found the end of our current nested escaped string
            puts "#{' '*indent}B-yah: result:#{result_str.inspect}  length: #{i}" if ENV["DEBUG"]
            return OpenStruct.new(str:result_str, consumed_length: i+delimiter.length)

          else
            char = input_str[i]
            result_str << char
            puts "#{' '*indent}D-yah: i:#{i}  char: #{char}   result_str:#{result_str.inspect}" if ENV["DEBUG"]
            i += 1
          end
        end
      end

    end #end Lexer
  end #end Parser
end #end Yap
