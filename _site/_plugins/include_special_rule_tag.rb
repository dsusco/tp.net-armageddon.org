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

    Liquid::Template.register_tag('include_special_rule', IncludeSpecialRule)
  end
end