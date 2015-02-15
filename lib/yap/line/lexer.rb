require 'ostruct'

module Yap
  module Line
    class Lexer
      class Token
        include Comparable

        attr_reader :tag, :value, :lineno, :attrs

        def initialize(tag, value, lineno:,attrs:{})
          @tag = tag
          @value = value
          @lineno = lineno
          @attrs = attrs
        end

        def <=>(other)
          return -1 if self.class != other.class
          return 0 if [tag, value, lineno, attrs] == [other.tag, other.value, other.lineno, other.attrs]
          -1
        end

        def inspect
          "#{tag.inspect} '#{value}' #{attrs.inspect}"
        end

        def to_s
          "Token(#{tag.inspect} #{value.inspect} on #{lineno} with #{attrs.inspect})"
        end

        def length
          to_s.length
        end
      end

      ARG                    = /[^0-9\s;\|\(\)\{\}\[\]\&\!\\][^\s;\|\(\)\{\}\[\]\&\!\>]*/
      COMMAND                = /\A(#{ARG})/
      LITERAL_COMMAND        = /\A\\(#{ARG})/
      WHITESPACE             = /\A[^\n\S]+/
      ARGUMENT               = /\A([\$\-A-z_\.0-9'"=]+)/
      STATEMENT_TERMINATOR   = /\A(;)/
      PIPE_TERMINATOR        = /\A(\|)/
      CONDITIONAL_TERMINATOR = /\A(&&|\|\|)/
      HEREDOC                = /\A<<-?([A-z0-9]+)\s*^(.*)?(^\s*\1\s*$)/m
      INTERNAL_EVAL          = /\A(?:(\!)|([0-9]+))/
      SUBGROUP               = /\A(\(|\))/
      REDIRECTION            = /\A(([12]?>&?[12]?)\s*(#{ARG})?)/
      REDIRECTION2           = /\A((&>)\s*(#{ARG}))/

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
          result = subgroup_token ||
            literal_command_token ||
            command_token ||
            whitespace_token ||
            terminator_token ||
            redirection_token ||
            heredoc_token ||
            string_argument_token ||
            argument_token ||
            internal_eval_token

          count += 1
          raise "Infinite loop detected on #{@chunk.inspect}" if count == max

          @current_position += result.to_i
        end

        @tokens
      end

      private

      def token(tag, value, attrs:{})
        @tokens.push [tag, Token.new(tag, value, lineno:@lineno, attrs:attrs)]
      end

      def command_token
        if !@looking_for_args && md=@chunk.match(COMMAND)
          @looking_for_args = true
          token :Command, md[1]
          md[0].length
        end
      end

      def literal_command_token
        if !@looking_for_args && md=@chunk.match(LITERAL_COMMAND)
          @looking_for_args = true
          token :LiteralCommand, md[1]
          md[0].length
        end
      end

      def numeric_expr_token
        if !@looking_for_args && md=@chunk.match(NUMERIC_EXPR)
          @looking_for_args = true
          token :NumericExpr, md[1]
          md[0].length
        end
      end

      def heredoc_token
        if md=@chunk.match(HEREDOC)
          token :Heredoc, md[2]
          md[0].length
        end
      end

      def internal_eval_token
        if md=@chunk.match(INTERNAL_EVAL)
          consumed = 0
          substr = if md[1]                               # begins with !
            consumed = md[1].length
            @chunk[consumed..-1]
          elsif md[2]                                     # begins with a number
            @chunk[consumed..-1]
          end
          result = process_internal_eval substr, consumed: consumed
          token :InternalEval, result.str
          return result.consumed_length
        end
      end

      def redirection_token
        if md=@chunk.match(REDIRECTION)
          target = nil
          target = md[3] if md[3] && md[3].length > 0
          token :Redirection, md[2], attrs: { target: target }
          md[0].length
        elsif md=@chunk.match(REDIRECTION2)
          token :Redirection, md[2], attrs: { target: md[3] }
          md[0].length
        end
      end

      def subgroup_token
        if md=@chunk.match(SUBGROUP)
          token md[0], md[0]
          return md[0].length
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
          str = ''
          i = 0
          loop do
            ch = @chunk[i]
            if %w(' ").include?(ch)
              result = process_string @chunk[i..-1], ch
              str << result.str
              i += result.consumed_length

            elsif ch !~ ARGUMENT
              break
            else
              str << ch
              i += 1
            end

            break if i >= @chunk.length
          end

          token :Argument, str
          i
        end
      end

      def terminator_token
        if md=@chunk.match(CONDITIONAL_TERMINATOR)
          @looking_for_args = false
          token :Conditional, md[0]
          md[0].length
        elsif md=@chunk.match(STATEMENT_TERMINATOR)
          @looking_for_args = false
          token :Separator, md[0]
          md[0].length
        elsif md=@chunk.match(PIPE_TERMINATOR)
          @looking_for_args = false
          token :Pipe, md[0]
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

      def process_internal_eval(input_str, consumed:0)
        scope = []
        words = []
        str = ''

        i = 0
        loop do
          ch = input_str[i]
          popped = false

          if scope.empty? && md=input_str[i..-1].match(/\A(;|\||&&|\))/)
            return OpenStruct.new(str:str.strip, consumed_length:i+consumed)

          elsif (i == input_str.length)
            return OpenStruct.new(str:str.strip, consumed_length:i+consumed)
          else
            if scope.last == ch
              scope.pop
              popped = true
            end

            if !popped
              if %w(' ").include?(ch)
                scope << ch
              elsif ch == "{"
                scope << "}"
              elsif ch == "["
                scope << "]"
              elsif ch == "("
                scope << ")"
              end
            end
            str << ch
          end
          i += 1
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
  end #end Line
end #end Yap
