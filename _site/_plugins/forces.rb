module Jekyll
  class ForceDataGenerator < Generator
    safe true

    def generate(site)
      site.collections['forces'].docs.each do |f|
        f.data['id'] = File.basename(f.path, File.extname(f.path))
        f.data['timestamp'] = File.mtime(f.path)
      end
    end
  end

  module Tags
    class Force < Liquid::Block
      def force_hash(context)
        if context.registers[:force_hash].nil?
          context.registers[:force_hash] = Hash[
            context.registers[:site].collections['forces'].docs.collect { |f|
              [f.data['id'], f]
            }
          ]
        end

        context.registers[:force_hash]
      end

      def render(context)
        context.stack do
          context['force'] = force_hash(context)[context[@markup.strip]]
          render_all(@nodelist, context)
        end
      end
    end

    Liquid::Template.register_tag('force', Force)
  end
end