module Jekyll
  class UnitDataGenerator < Generator
    safe true

    def generate(site)
      site.collections['units'].docs.each do |u|
        u.data['id'] = File.basename(u.path, File.extname(u.path))
        u.data['timestamp'] = File.mtime(u.path)
      end
    end
  end

  module Tags
    class Unit < Liquid::Block
      def unit_hash(context)
        if context.registers[:unit_hash].nil?
          context.registers[:unit_hash] = Hash[
            context.registers[:site].collections['units'].docs.collect { |u|
              [u.data['id'], u]
            }
          ]
        end

        context.registers[:unit_hash]
      end

      def render(context)
        context.stack do
          context['unit'] = unit_hash(context)[context[@markup.strip]]
          render_all(@nodelist, context)
        end
      end
    end

    Liquid::Template.register_tag('unit', Unit)
  end
end