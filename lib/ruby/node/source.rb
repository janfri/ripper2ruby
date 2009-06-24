require 'ruby/node/text'

module Ruby
  class Node
    module Source
      def filename
        root? ? @filename : root.filename
      end

      def src(context = false)
        # p position(context)
        # p length(context)
        # p position(false)
        # p length(false)
        # p root.src
        root? ? @src : Ruby::Node::Text.new(root.src).clip(position(context), length(context)).to_s
      end

      def lines
        root.src.split("\n")
      end

      def line
        Ruby::Node::Text.new(lines[row]).clip([0, column], length)
      end
      
      def context(options = {})
        filter = options.has_key?(:highlight) ? options[:highlight] : false
        line = filter ? self.line.head + filter.highlight(to_ruby) + self.line.tail : nil
        Ruby::Node::Text::Context.new(lines, row, options[:width] || 2, line).to_s
      end
    end
  end
end