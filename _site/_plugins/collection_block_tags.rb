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

    class ArmyList < CollectionBlock
    end

    class Force < CollectionBlock
    end

    class SpecialRule < CollectionBlock
    end

    class Unit < CollectionBlock
    end

    class Weapon < CollectionBlock
    end

    Liquid::Template.register_tag('army_list', ArmyList)
    Liquid::Template.register_tag('force', Force)
    Liquid::Template.register_tag('special_rule', SpecialRule)
    Liquid::Template.register_tag('unit', Unit)
    Liquid::Template.register_tag('weapon', Weapon)
  end
end