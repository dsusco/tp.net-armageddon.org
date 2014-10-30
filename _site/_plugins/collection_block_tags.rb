module Jekyll
  module Tags
    # A Liquid Block that holds the shared functionality of all the blocks used to access the
    # site's collections.
    class CollectionBlock < Liquid::Block
      # Create/fetch a hash of a collection's docs on their ID.
      def hash(context)
        context.registers[:site].data["#{@tag_name}_hash".to_sym] ||= Hash[
            context.registers[:site].collections[@tag_name + 's'].docs.collect { |doc|
              [doc.data['id'], doc]
            }
          ]
      end

      # Render the block, updating the page's date if the doc's date is newer.
      def render(context)
        page = context.registers[:page]

        context.stack do
          # get the doc and added it to the context under the tag's name
          context[@tag_name] = hash(context)[context[@markup.strip]]

          # if the doc's date is newer than the page's...
          if context[@tag_name]['date'] > page['date']
            # update the page date
            page['date'] = context[@tag_name]['date']

            # and update the army lists date for the homepage
            if page['layout'] == 'army_list'
              context.registers[:site].data[:army_list_hash][page['id']].data['date'] =
                context[@tag_name]['date']
            end
          end

          render_all(@nodelist, context)
        end
      end
    end

    class ArmyListBlock < CollectionBlock
    end

    class FaqBlock < CollectionBlock
    end

    class ForceBlock < CollectionBlock
    end

    class SpecialRuleBlock < CollectionBlock
    end

    class UnitBlock < CollectionBlock
    end

    class WeaponBlock < CollectionBlock
    end

    Liquid::Template.register_tag('army_list', ArmyListBlock)
    Liquid::Template.register_tag('faq', FaqBlock)
    Liquid::Template.register_tag('force', ForceBlock)
    Liquid::Template.register_tag('special_rule', SpecialRuleBlock)
    Liquid::Template.register_tag('unit', UnitBlock)
    Liquid::Template.register_tag('weapon', WeaponBlock)
  end
end