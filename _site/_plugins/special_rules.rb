module Jekyll
  module Tags
    class IncludeSpecialRule < IncludeTag
      def initialize(tag_name, markup, tokens)
        markup = 'special_rule.html ' + markup
        super
      end


      def render(context)
        special_rules = (context.registers[:page]['rendered_special_rules'] ||= [])

        context.stack do
          # only render the special rule if it hasn't been rendered on the page yet
          if special_rules.index(parse_params(context)['id']).nil?
            special_rules << parse_params(context)['id']
            super
          end
        end
      end
    end

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
        context.stack do
          context['specialrule'] = special_rule_hash(context)[context[@markup.strip]]
          render_all(@nodelist, context)
        end
      end
    end

    Liquid::Template.register_tag('includespecialrule', IncludeSpecialRule)
    Liquid::Template.register_tag('specialrule', SpecialRule)
  end
end