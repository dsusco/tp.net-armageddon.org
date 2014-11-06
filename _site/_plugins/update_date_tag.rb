module Jekyll
  module Tags
    class UpdateDateTag < Liquid::Tag
      def render(context)
        date = context[@markup.strip]
        page = context.registers[:page]
        site = context.registers[:site]

        if date > page['date']
          page['date'] = date

          if page['layout'] == 'army_list'
            site.data['army_lists'][page['id']].data['date'] = date
          else
            site.data['pages'][page['id']].data['date'] = date
          end
        end

        nil
      end
    end

    Liquid::Template.register_tag('update_date', UpdateDateTag)
  end
end
