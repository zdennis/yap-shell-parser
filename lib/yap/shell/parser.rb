require 'racc/parser'

module Yap
  module Shell
    module Parser
      class ParseError < ::StandardError ; end

      def self.parse(input)
        Yap::Shell::ParserImpl.new.parse(input)
      rescue Racc::ParseError => ex
        raise ParseError, "Message: #{ex.message}\nInput: #{input}"
      end
    end
  end
end

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../../"
require 'yap/shell/parser/lexer'
require 'yap/shell/parser/nodes'
require 'yap/shell/parser_impl'
