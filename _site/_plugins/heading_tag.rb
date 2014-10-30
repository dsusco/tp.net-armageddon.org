module Jekyll
  module Tags
    # A tag for headings which generates an ID and renders a FAQ associated with it.
    class Heading < Liquid::Tag
      def initialize(tag_name, markup, options)
        super

        markup = markup.strip

        # the inner HTML of the heading tag
        @text = markup.gsub(/style="[^"]+"/, '').match(/^[^#.]+/) { |m| m[0].strip }
        # if no ID is given (with CSS # selector) then use the inner HTML to make one
        @id =
          markup.match(/#([A-Za-z][\w\-:.]+)/) { |m| m[1] } ||
          @text.downcase.gsub(/&amp;/, 'and').gsub(' ', '-').gsub(/[^\w\-:.]/, '')
        # classes given with the CSS . selector
        @class = markup.scan(/\.(-?[_a-zA-Z]+[_a-zA-Z0-9-]*)/).flatten.join(' ')
        # inline style given with 'style=""'
        @style = markup.match(/style="([^"]+)"/) { |m| m[1] }
      end

      # Renders a heading tag, incrementing the ID if necessary and appending the FAQ if one is
      # found.
      def render(context)
        headings = (context.registers[:page]['headings'] ||= [])

        # if the heading exists on the page already...
        if not headings.index(@id).nil?
          i = 1

          # add a number and look for the next open one
          while not headings.index("#{@id}-#{i}").nil? do
            i += 1
          end

          @id += "-#{i}"
        end

        headings << @id

        # if a faq is found...
        if faq = context.registers[:site]
                        .collections['faqs'].docs.find { |doc| doc.data['id'] == @id }
          # add the footnote class
          @class = @class.empty? ? 'footnote' : @class + ' footnote'
          # and render the FAQ
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