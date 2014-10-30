module Jekyll
  module Tags
    # A Liquid Block that holds the shared functionality of all the blocks used to access the
    # site's collections.
    class PageBlock < Liquid::Block
      def render(context)
        context.stack do
          context['_page'] = context.registers[:site].data[:page_hash][context[@markup.strip]]
          render_all(@nodelist, context)
        end
      end
    end

    Liquid::Template.register_tag('_page', PageBlock)
  end
end