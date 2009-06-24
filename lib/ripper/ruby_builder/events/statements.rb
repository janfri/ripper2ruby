class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Statements
      def on_program(statements)
        program = statements.to_program(src, filename)
        
        # TODO trailing whitespace
        if context = pop_context
          program << Ruby::Token.new('', position, context)
        end
        
        # context = Ruby::Whitespace.new([pop_context, trailing_whitespace].compact.join)
        # program << Ruby::Token.new('', position, whitespace) unless whitespace.empty?
        # program << Ruby::Token.new('', position, trailing_whitespace) # unless whitespace.empty?
        # program << Ruby::Token.new('', position, pop_whitespace) if stack.whitespace?
        
        program
      end

      def on_body_stmt(body, rescue_block, else_block, ensure_block)
        statements = [rescue_block, else_block, ensure_block].compact
        body = body.to_chained_block(nil, statements) if rescue_block || ensure_block
        body
      end
      
      def on_paren(node)
        if stack.peek.type == :@rparen
          # TODO crap. this should test more specifically for ArgList, Hash etc.
          # case node
          # when Ruby::List
          if node.is_a?(Ruby::List) && node.ldelim.nil? && node.rdelim.nil?
            node.rdelim = pop_token(:@rparen)
            node.ldelim = pop_token(:@lparen)
          else
            rdelim = pop_token(:@rparen)
            ldelim = pop_token(:@lparen)
            node = Ruby::Statements.new(node, ldelim, rdelim)
          end
        end
        
        node
      end

      def on_stmts_add(target, statement)
        target.elements << statement if statement
        target
      end

      def on_stmts_new
        Ruby::Statements.new
      end
    
      def on_void_stmt
        nil
      end

      def on_var_ref(ref)
        ref.instance_of?(Ruby::Identifier) ? ref.to_variable : ref
      end

      def on_const_ref(const)
        const
      end

      def on_var_field(field)
        field
      end
      
      def on_backref(arg)
        push
        Ruby::Variable.new(arg, position, pop_context)
      end
    end
  end
end