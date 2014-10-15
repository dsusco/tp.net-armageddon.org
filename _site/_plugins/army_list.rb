module Jekyll
  module Tags
    class ArmyList < Liquid::Block
      def army_list_hash(context)
        if context.registers[:army_list_hash].nil?
          context.registers[:army_list_hash] = Hash[
            context.registers[:site].collections['army_lists'].docs.collect { |f|
              [f.data['id'], f]
            }
          ]
        end

        context.registers[:army_list_hash]
      end

      def render(context)
        context.stack do
          context['armylist'] = army_list_hash(context)[context[@markup.strip]]
          render_all(@nodelist, context)
        end
      end
    end

    Liquid::Template.register_tag('armylist', ArmyList)
  end
end