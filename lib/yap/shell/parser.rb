module Yap
  module Shell
    module Parser
      def self.new
        Yap::Shell::ParserImpl.new
      end
    end
  end
end

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../../"
require 'yap/shell/parser/lexer'
require 'yap/shell/parser/nodes'
require 'yap/shell/parser_impl'
