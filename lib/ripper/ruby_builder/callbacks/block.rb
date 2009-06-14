class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Block
      def on_body_stmt(statements, *something)
        Ruby::Body.new(statements.compact)
      end
    
      def on_method_add_arg(call, args)
        call.arguments = args
        call
      end

      def on_method_add_block(call, block)
        block.rdelim = pop_delim(:@kw, :value => 'end') || pop_delim(:@rbrace)
        block.ldelim = pop_delim(:@kw, :value => 'do')  || pop_delim(:@lbrace)
        call.block = block
        call
      end

      def on_do_block(params, statements)
        Ruby::Block.new(statements.compact, params)
      end
      
      def on_brace_block(params, statements)
        Ruby::Block.new(statements.compact, params)
      end

      def on_block_var(params, something)
        params
      end

      def on_stmts_add(target, statement)
        case statement
        when Ruby::Statement # from on_void_stmt
          target << statement
        when Ruby::Node
          target << Ruby::Statement.new(statement, pop_delim(:@semicolon)) 
        end
        target
      end

      def on_stmts_new
        Ruby::Composite::Array.new
      end
    
      def on_void_stmt
        rdelim = pop_delim(:@semicolon)
        Ruby::Statement.new(nil, rdelim) if rdelim
      end
    end
  end
end