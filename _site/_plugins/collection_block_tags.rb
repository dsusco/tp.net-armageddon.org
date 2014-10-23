module Jekyll
  module Tags
    class CollectionBlock < Liquid::Block
      def hash(context)
        hash = context.registers["#{@tag_name}_hash".to_sym]

        if hash.nil?
          hash = Hash[
            context.registers[:site].collections[@tag_name + 's'].docs.collect { |doc|
              [doc.data['id'], doc]
            }
          ]
        end

        hash
      end

      def render(context)
        context.stack do
          context[@tag_name] = hash(context)[context[@markup.strip]]
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