module Jekyll
  module Tags
    class SpecialRule < Liquid::Block
      def special_rule_hash(context)
        if context.registers[:special_rule_hash].nil?
          context.registers[:special_rule_hash] = Hash[
            context.registers[:site].collections['special_rules'].docs.collect { |sr|
              [sr.data['id'], sr]
            }
          ]
        end

        context.registers[:special_rule_hash]
      end

      def render(context)
        special_rules = (context.registers[:page]['special_rules'] ||= [])

        context.stack do
          context['specialrule'] = special_rule_hash(context)[context[@markup.strip]]

          # only render the special rule if it hasn't been rendered on the page yet
          if special_rules.index(context['specialrule']['id']).nil?
            special_rules << context['specialrule']['id']
            render_all(@nodelist, context)
          end
        end
      end
    end

    Liquid::Template.register_tag('specialrule', SpecialRule)
  end
end