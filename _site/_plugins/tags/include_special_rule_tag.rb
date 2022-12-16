require 'action_view'

module Jekyll
  module Tags
    class IncludeSpecialRule < IncludeTag
      def initialize(tag_name, markup, tokens)
        markup = "special_rule.html #{markup}"
        super
      end

      def render(context)
        id = parse_params(context)['id']
        special_rules = (context.registers[:page][:rendered_special_rules] ||= [])

        context.stack do
          # ensure a special rule is only rendered once per page
          unless special_rules.include?(id)
            special_rules << id
            super
          end
        end
      end
    end
  end
end

Liquid::Template.register_tag('include_special_rule', Jekyll::Tags::IncludeSpecialRule)