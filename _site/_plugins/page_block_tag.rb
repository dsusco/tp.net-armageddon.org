module Jekyll
  module Tags
    # A block which gets a page from the page hash and places it in the context.
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