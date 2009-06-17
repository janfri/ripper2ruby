class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Hash
      def on_hash(assocs)
        separators = pop_tokens(:@rbrace, :@comma, :@lbrace).reverse
        ldelim, rdelim = separators.shift, separators.pop

        Ruby::Hash.new(assocs, separators, ldelim, rdelim)
      end

      def on_assoclist_from_args(args)
        args
      end

      def on_bare_assoc_hash(assocs)
        separators = pop_tokens(:@comma, :max => assocs.length - 1).reverse
        Ruby::Hash.new(assocs, separators)
      end

      def on_assoc_new(key, value)
        Ruby::Assoc.new(key, value, pop_token(:@op))
      end
    end
  end
end

