class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Assignment
      # simple assignments, e.g. a = b
      def on_assign(left, right)
        Ruby::Assignment.new(left, right, pop_token(:'@=', :pass => true))
      end

      # mass assignments, e.g. a, b = c, d
      def on_massign(left, right)
        Ruby::Assignment.new(left, right, pop_token(:'@=', :pass => true))
      end
      
      # operator assignment (?), e.g. a ||= b; a += 1
      def on_opassign(left, operator, right)
        Ruby::Assignment.new(left, right, pop_assignment_operator(:pass => true))
      end

      def on_mlhs_new
        Ruby::MultiAssignment.new(:left, nil, pop_token(:@lparen))
      end

      def on_mlhs_add(assignment, ref)
        assignment << ref
        assignment
      end

      def on_mlhs_paren(arg)
        if arg.is_a?(Ruby::MultiAssignment)
          arg.rdelim ||= pop_token(:@rparen) 
          arg.ldelim ||= pop_token(:@lparen) 
        end
        arg
      end

      def on_mrhs_new
        Ruby::MultiAssignment.new(:right, nil)
      end

      def on_mrhs_new_from_args(args)
        Ruby::MultiAssignment.new(:right, args.elements)
      end

      def on_mrhs_add(assignment, ref)
        assignment << ref
        assignment
      end

      def on_mlhs_add_star(assignment, ref)
        star = pop_token(:'@*')
        ref = Ruby::Arg.new(ref, star) if star

        assignment << ref
        assignment
      end

      def on_mrhs_add_star(assignment, ref)
        star = pop_token(:'@*', :right => ref, :pass => true)
        ref = Ruby::Arg.new(ref, star) if star

        assignment << ref
        assignment
      end
    end
  end
end