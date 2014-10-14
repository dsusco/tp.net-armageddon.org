module Jekyll
  module Tags
    class Weapon < Liquid::Block
      def weapon_hash(context)
        if context.registers[:weapon_hash].nil?
          context.registers[:weapon_hash] = Hash[
            context.registers[:site].collections['weapons'].docs.collect { |w|
              [w.data['id'], w]
            }
          ]
        end

        context.registers[:weapon_hash]
      end

      def render(context)
        context.stack do
          context['weapon'] = weapon_hash(context)[context[@markup.strip]]
          render_all(@nodelist, context)
        end
      end
    end

    Liquid::Template.register_tag('weapon', Weapon)
  end
end