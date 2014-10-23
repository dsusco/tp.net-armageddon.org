module Jekyll
  module Tags
    class Heading < Liquid::Tag
      def initialize(tag_name, markup, options)
        super

        markup = markup.strip

        @text = markup.gsub(/style="[^"]+"/, '').match(/^[^#.]+/) { |m| m[0].strip }
        @id =
          markup.match(/#([A-Za-z][\w\-:.]+)/) { |m| m[1] } ||
          @text.downcase.gsub(/&amp;/, 'and').gsub(' ', '-').gsub(/[^\w\-:.]/, '')
        @class = markup.scan(/\.(-?[_a-zA-Z]+[_a-zA-Z0-9-]*)/).flatten.join(' ')
        @style = markup.match(/style="([^"]+)"/) { |m| m[1] }
      end

      def render(context)
        headings = (context.registers[:page]['headings'] ||= [])

        if not headings.index(@id).nil?
          i = 1

          while not headings.index("#{@id}-#{i}").nil? do
            i += 1
          end

          @id += "-#{i}"
        end

        headings << @id

        unless (faq = context.registers[:site].collections['faqs'].docs.find { |doc| doc.data['id'] == @id }).nil?
          @class = @class.empty? ? 'footnote' : @class + ' footnote'
          faq = IncludeTag.new('include', "faq.html id='#{faq.data['id']}'", []).render(context)
        end

        h  = "<#{@tag_name} id=\"#{@id}\""
        h += " class=\"#{@class}\"" unless @class.empty?
        h += " style=\"#{@style}\"" unless @style.nil?
        h += ">#{@text}</#{@tag_name}>"
        h += "\n\n#{faq}" unless faq.nil?

        h
      end
    end

    Liquid::Template.register_tag('h1', Heading)
    Liquid::Template.register_tag('h2', Heading)
    Liquid::Template.register_tag('h3', Heading)
    Liquid::Template.register_tag('h4', Heading)
  end
end

