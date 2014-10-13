module Jekyll
  class SpecialRulesDataGenerator < Generator
    safe true

    def generate(site)
      site.collections['special_rules'].docs.each do |sr|
        sr.data['id'] = File.basename(sr.path, File.extname(sr.path))
      end
    end
  end

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
        context.stack do
          context['specialrule'] = special_rule_hash(context)[context[@markup.strip]]
          render_all(@nodelist, context)
        end
      end
    end

    Liquid::Template.register_tag('specialrule', SpecialRule)
  end
end