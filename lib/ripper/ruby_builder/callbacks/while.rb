class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module While
      def on_while(expression, statements)
        rdelim = pop_delim(:@kw, :value => 'end')
        ldelim = pop_delim(:@kw, :value => 'while')
        Ruby::While.new(expression, statements, ldelim, rdelim)
      end
      
      def on_until(expression, statements)
        rdelim = pop_delim(:@kw, :value => 'end')
        ldelim = pop_delim(:@kw, :value => 'until')
        Ruby::Until.new(expression, statements, ldelim, rdelim)
      end

      def on_while_mod(expression, statement)
        Ruby::WhileMod.new(expression, statement, pop_delim(:@kw, :value => 'while'))
      end
      
      def on_until_mod(expression, statement)
        Ruby::UntilMod.new(expression, statement, pop_delim(:@kw, :value => 'until'))
      end
    end
  end
end