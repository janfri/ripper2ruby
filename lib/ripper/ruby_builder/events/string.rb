class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module String
      def on_string_literal(string)
        string.rdelim = pop_token(:@tstring_end)
        string
      end

      def on_xstring_literal(string)
        string.rdelim = pop_token(:@tstring_end)
        string
      end

      def on_regexp_literal(string, rdelim)
        string.rdelim = pop_token(:@regexp_end)
        string
      end

      def on_string_add(string, content)
        string << content and string
      end

      def on_xstring_add(string, content)
        string.tap { |s| s << content }
      end

      def on_string_content
        Ruby::String.new(pop_token(:@tstring_beg))
      end

      def on_xstring_new(*args)
        ldelim = pop(:@symbeg, :@backtick, :@regexp_beg, :max => 1).first
        if ldelim.type == :@symbeg
          Ruby::DynaSymbol.new(build_token(ldelim))
        elsif ldelim.type == :@regexp_beg
          Ruby::Regexp.new(build_token(ldelim))
        else
          Ruby::ExecutableString.new(build_token(ldelim))
        end
      end

      def on_tstring_content(token)
        Ruby::StringContent.new(token, position)
      end
    end
  end
end