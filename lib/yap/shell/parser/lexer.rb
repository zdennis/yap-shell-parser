require 'ostruct'

module Yap::Shell
  class Parser::Lexer
    class Error < ::StandardError ; end
    class HeredocMissingEndDelimiter < Error ; end
    class LineContinuationFound < Error ; end
    class NonterminatedString < Error ; end

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

    COMMAND_SUBSTITUTION   = /\A(`|\$\()/
    ARG                    = /[^\s;\|\(\)\{\}\[\]\&\!\\\<\>`][^\s;\|\(\)\{\}\[\]\&\>\<`]*/
    COMMAND                = /\A(#{ARG})/
    LITERAL_COMMAND        = /\A\\(#{ARG})/
    COMMENT                = /\A#[^$]+/
    WHITESPACE             = /\A\s+/
    LH_ASSIGNMENT          = /\A(([A-z_][\w]*)=)/
    RH_VALUE               = /\A(\S+)/
    STATEMENT_TERMINATOR   = /\A(;)/
    PIPE_TERMINATOR        = /\A(\|)/
    CONDITIONAL_TERMINATOR = /\A(&&|\|\|)/
    HEREDOC_START          = /\A<<-?([A-z0-9]+)\s*\n/
    INTERNAL_EVAL          = /\A(?:(\!)|([0-9]+))/
    SUBGROUP               = /\A(\(|\))/
    REDIRECTION            = /\A(([12]?>&?[12]?)\s*(?![12]>)(#{ARG})?)/
    REDIRECTION2           = /\A((&>|<)\s*(#{ARG}))/

    NUMERIC_RANGE              = /\A\(((\d+)\.\.(\d+))\)(\.each)?/
    NUMERIC_RANGE_W_CALL       = /\A\(((\d+)\.\.(\d+))\)(\.each)?\s*:\s*/
    NUMERIC_RANGE_W_PARAM      = /\A(\((\d+)\.\.(\d+))\)\s+as\s+([A-z0-9,\s]+)\s*:\s*/
    NUMERIC_REPETITION         = /\A((\d+)(\.times))/
    NUMERIC_REPETITION_2       = /\A((\d+)(\.times))\s*:\s*/
    NUMERIC_REPETITION_W_PARAM = /\A((\d+)(\.times))\s+as\s+([A-z0-9,\s]+)\s*:\s*/

    BLOCK_BEGIN = /\A\s+(\{)\s*(?:\|\s*([A-z0-9,\s]+)\s*\|)?/
    BLOCK_END = /\A\s+(\})\s*/

    LINE_CONTINUATION = /.*\\\Z/

    SPLIT_BLOCK_PARAMS_RGX = /\s*,\s*|\s*/

    # Loop over the given input and yield command substitutions. This yields
    # an object that responds to #str, and #position.
    #
    # * The #str will be the contents of the command substitution, e.g. foo in `foo` or $(foo)
    # * The #position will be range denoting where the command substitution started and stops in the string
    #
    # This will yield a result for every command substitution found.
    #
    # == Note
    #
    # This will not yield nested command substitutions. The caller is responsible
    # for that.
    def each_command_substitution_for(input, &blk)
      return unless input

      i = 0
      loop do
        break if i >= input.length

        @chunk = input[i..-1]
        if md=@chunk.match(COMMAND_SUBSTITUTION)
          start = i
          delimiter = md[1] == "$(" ? ")" : md[1]
          result = process_string @chunk[md[0].length-1..-1], delimiter
          consumed_length_so_far = result.consumed_length + (md[0].length - 1)
          i += consumed_length_so_far
          yield OpenStruct.new(str:result.str, position:(start..i))
        else
          i += 1
        end
      end
    end

    def tokenize(str)
      debug_log "##{__callee__} string: #{str.inspect}"
      @chunk = str
      @tokens = []
      @lineno = 0
      @looking_for_args = false
      @tokens_to_add_when_done = []

      max = 100
      count = 0
      @current_position = 0
      last_position = -1
      process_next_chunk = -> { @chunk = str.slice(@current_position..-1) ; @chunk != "" }

      strip_line_continutations_before_newlines
      line_continuation_token

      while process_next_chunk.call
        debug_log "##{__callee__} looking for next token in: #{@chunk.inspect}"
        result =
          comment_token ||
          block_token ||
          numerical_range_token ||
          command_substitution_token ||
          subgroup_token ||
          assignment_token ||
          literal_command_token ||
          string_token ||
          command_token ||
          whitespace_token ||
          terminator_token ||
          redirection_token ||
          heredoc_token ||
          argument_token ||
          internal_eval_token

        count += 1
        # raise "Infinite loop detected on #{@chunk.inspect}" if count == max
        raise "Infinite loop detected in #{str.inspect}\non chunk:\n  #{@chunk.inspect}" if @current_position == last_position

        last_position = @current_position
        @current_position += result.to_i
      end

      @tokens_to_add_when_done.each do |args|
        token *args
      end

      token :BlankLine, str if @tokens.empty?

      @tokens
    end

    private

    def token(tag, value, attrs:{})
      token = [tag, Token.new(tag, value, lineno:@lineno, attrs:attrs)]
      debug_log "#{__callee__} found token: #{token.inspect}"
      @tokens.push token
    end

    def block_token
      if md=@chunk.match(BLOCK_BEGIN)
        @looking_for_args = false
        token :BlockBegin, md[1]
        if md[2]
          params = md[2].split(SPLIT_BLOCK_PARAMS_RGX)
          token :BlockParams, params
        end
        md[0].length
      elsif md=@chunk.match(BLOCK_END)
        @looking_for_args = false
        token :BlockEnd, md[1]
        md[0].length
      else
        did_not_match
      end
    end

    def comment_token
      if md=@chunk.match(COMMENT)
        token :Comment, md[0]
        md[0].length
      else
        did_not_match
      end
    end

    def numerical_range_token
      if @looking_for_args
        skipping
        return
      end

      if md=@chunk.match(NUMERIC_RANGE_W_CALL)
        start, stop = md[2].to_i, md[3].to_i
        token :Range, (start..stop)
        token :BlockBegin, '{'
        @tokens_to_add_when_done << [:BlockEnd, '}']
        md[0].length

      elsif md=@chunk.match(NUMERIC_RANGE_W_PARAM)
        start, stop = md[2].to_i, md[3].to_i
        token :Range, (start..stop)
        token :BlockBegin, '{'
        params = md[4].split(SPLIT_BLOCK_PARAMS_RGX)
        token :BlockParams, params
        @tokens_to_add_when_done << [:BlockEnd, '}']
        md[0].length

      elsif md=@chunk.match(NUMERIC_REPETITION_2)
        start, stop = 1, md[2].to_i
        token :Range, (start..stop)
        token :BlockBegin, '{'
        @tokens_to_add_when_done << [:BlockEnd, '}']
        md[0].length

      elsif md=@chunk.match(NUMERIC_REPETITION_W_PARAM)
        start, stop = 1, md[2].to_i
        token :Range, (start..stop)
        token :BlockBegin, '{'
        params = md[4].split(SPLIT_BLOCK_PARAMS_RGX)
        token :BlockParams, params
        @tokens_to_add_when_done << [:BlockEnd, '}']
        md[0].length

      elsif md=@chunk.match(NUMERIC_REPETITION)
        start, stop = 1, md[2].to_i
        token :Range, (start..stop)
        md[0].length

      elsif md=@chunk.match(NUMERIC_RANGE)
        start, stop = md[2].to_i, md[3].to_i
        token :Range, (start..stop)
        md[0].length

      else
        did_not_match
      end
    end

    def command_token
      if @looking_for_args
        skipping
        return
      elsif md=@chunk.match(COMMAND)
        @looking_for_args = true
        token :Command, md[1]
        md[0].length
      else
        did_not_match
      end
    end

    def literal_command_token
      if @looking_for_args
        skipping
        return
      elsif md=@chunk.match(LITERAL_COMMAND)
        @looking_for_args = true
        token :LiteralCommand, md[1]
        md[0].length
      else
        did_not_match
      end
    end

    def numeric_expr_token
      if @looking_for_args
        skipping
        return
      elsif md=@chunk.match(NUMERIC_EXPR)
        @looking_for_args = true
        token :NumericExpr, md[1]
        md[0].length
      else
        did_not_match
      end
    end

    def heredoc_token
      if md=@chunk.match(HEREDOC_START)
        delimiter = md[1]
        str = @chunk[md[0].length..-1]
        consumed_length = md[0].length

        delimeter_regex = Regexp.escape(delimiter)

        contents = ""
        found_ending_delimiter = false
        str.lines.each do |line|
          if md=line.match(/^(.*?)\s*#{delimeter_regex}\s*$/m)
            contents << $1
            found_ending_delimiter = true
          else
            contents << line
          end
          consumed_length += line.length
        end

        unless found_ending_delimiter
          raise HeredocMissingEndDelimiter, "Missing end delimiter on #{@chunk}"
        end

        token :Heredoc, contents
        consumed_length
      else
        did_not_match
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
      else
        did_not_match
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
      else
        did_not_match
      end
    end

    def subgroup_token
      if md=@chunk.match(SUBGROUP)
        token md[0], md[0]
        return md[0].length
      else
        did_not_match
      end
    end

    # Matches and consumes non-meaningful whitespace.
    def whitespace_token
      if md=WHITESPACE.match(@chunk)
        input = md.to_a[0]
        input.length
      else
        did_not_match
      end
    end

    def argument_token
      if @looking_for_args
        str = ''
        characters_read = 0
        prev_char = ''
        loop do
          ch = @chunk[characters_read]

          if %w(' ").include?(ch)
            @quoted_by = ch
            result = process_string @chunk[characters_read..-1], ch
            str << result.str
            characters_read += result.consumed_length
          elsif ch == '\\'
            # no-op
            characters_read += 1
          elsif prev_char != '\\' && ch =~ /[\s\|;&\(\)]/
            break
          else
            str << ch
            characters_read += 1
          end

          break if characters_read >= @chunk.length

          prev_char = ch
        end

        if characters_read > 0
          attrs = {}
          if @quoted_by
            attrs.merge!(quoted_by: @quoted_by)
          end
          token :Argument, str, attrs: attrs
          characters_read
        else
          did_not_match
        end
      else
        skipping
      end
    end

    def assignment_token
      if @looking_for_args
        skipping
        return
      elsif md=@chunk.match(LH_ASSIGNMENT)
        token :LValue, md[2]
        consumed_length = md[1].length
        i = consumed_length

        @chunk = @chunk[i..-1]
        if %w(' ").include?(@chunk[0])
          result = process_string @chunk[0..-1], @chunk[0]
          token :RValue, result.str, attrs: { quoted_by: @chunk[0] }
          consumed_length += result.consumed_length
        elsif md=@chunk.match(RH_VALUE)
          token :RValue, md[1]
          consumed_length += md[0].length
        end
        consumed_length
      else
        did_not_match
      end
    end

    def line_continuation_token
      if @chunk.match(LINE_CONTINUATION)
        raise(
          LineContinuationFound,
          "Expected more input, line continutation found"
        )
      else
        did_not_match
      end
    end

    def strip_line_continutations_before_newlines
      @chunk.gsub!(/\\\n/, '\\')
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
      else
        did_not_match
      end
    end

    # Matches single and double quoted strings
    def string_token
      if %w(' ").include?(@chunk[0])
        result = process_string @chunk[0..-1], @chunk[0]
        if @looking_for_args
          token :Argument, result.str, attrs: { quoted_by: @chunk[0] }
        else
          token :Command, result.str
        end
        result.consumed_length
      else
        did_not_match
      end
    end

    def command_substitution_token
      if md=@chunk.match(COMMAND_SUBSTITUTION)
        @looking_for_args = true

        delimiter = md[1] == "$(" ? ")" : md[1]
        result = process_string @chunk[md[0].length-1..-1], delimiter

        consumed_length_so_far = result.consumed_length + (md[0].length - 1)
        append_result = process_until_separator(@chunk[consumed_length_so_far..-1])

        token :BeginCommandSubstitution, md[1]
        @tokens.push *self.class.new.tokenize(result.str)

        if append_result.consumed_length > 0
          token :EndCommandSubstitution, delimiter, attrs:{concat_with: append_result.str}
        else
          token :EndCommandSubstitution, delimiter
        end

        consumed_length_so_far + append_result.consumed_length
      else
        did_not_match
      end
    end

    def process_until_separator(input_str)
      str = ""
      i = 0
      loop do
        ch = input_str[i]

        if ch && ch !~ /[\s;\|&>\$<`]/
          str << ch
          i+=1
        else
          break
        end
      end
      OpenStruct.new(str:str, consumed_length: str.length)
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

      if indent == 0
        debug_log "##{__callee__} input_str=#{input_str.inspect} delimiter=#{delimiter.inspect} start_position=#{i}"
        indent += 1
      else
        debug_log "#{' ' * indent}##{__callee__} input_str=#{input_str.inspect} delimiter=#{delimiter.inspect} start_position=#{i}"
        indent += 1
      end
      indent_str = ' ' * indent

      loop do
        chunk = input_str[i..-1]

        if i >= input_str.length
          debug_log "#{indent_str}found unterminated string, raising error"
          raise NonterminatedString, "Expected to find #{delimiter} in:\n  #{input_str}"
        end

        if chunk.start_with?(nested_delimiter) # we found a nested escaped string
          debug_log "#{indent_str}nested string found in #{chunk.inspect}"
          result = process_string(chunk[0..-1], nested_delimiter, indent+2)
          result_str << [delimiter, result.str, delimiter].join
          debug_log "#{indent_str}nested string found was #{result.inspect}"
          i += result.consumed_length

        elsif chunk.start_with?(delimiter)    # we found the end of our current nested escaped string
          debug_log "#{indent_str}found the end of the string making string: #{result_str.inspect}"
          return OpenStruct.new(str:result_str, consumed_length: i+delimiter.length)

        else
          char = input_str[i]
          result_str << char
          debug_log "#{indent_str}consuming character #{char} at position #{i}"
          i += 1
        end
      end
    end

    def debug_log(message)
      Treefell['lexer'].puts message
    end

    def did_not_match
      calling_method = caller[0][/`.*'/][1..-2]
      debug_log "##{calling_method} didn't match: #{@chunk.inspect}"
      nil
    end

    def skipping
      calling_method = caller[0][/`.*'/][1..-2]
      debug_log "##{calling_method} is being skipped"
      nil
    end
  end
end
