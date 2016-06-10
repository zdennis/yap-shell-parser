require 'racc/parser'

module Yap
  module Shell
    module Parser
      class ParseError < ::StandardError ; end

      class << self
        def parse(input)
          debug_log "#parse entry with: #{input.inspect}"
          Yap::Shell::ParserImpl.new.parse(input).tap do |results|
            debug_log "#parse exit returning: #{results.inspect}"
          end
        rescue Racc::ParseError => ex
          raise ParseError, "Message: #{ex.message}\nInput: #{input}"
        end

        def each_command_substitution_for(input, &blk)
          Yap::Shell::Parser::Lexer.new.each_command_substitution_for(input, &blk)
        end

        private

        def debug_log(message)
          Treefell['parser'].puts message
        end
      end

    end
  end
end

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../../"
begin
  require 'treefell'
rescue LoadError => ex
  nil
end
require 'yap/shell/parser/lexer'
require 'yap/shell/parser/nodes'
require 'yap/shell/parser_impl'
