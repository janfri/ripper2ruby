class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module For
      def on_for(variable, range, statements)
        rdelim     = pop_token(:@end)
        operator   = pop_token(:@in, :pass => true)
        identifier = pop_token(:@for, :pass => true)
        ldelim     = pop_token(:@do, :left => identifier, :right => rdelim)

        Ruby::For.new(identifier, variable, operator, range, statements, ldelim, rdelim)
      end
    end
  end
end