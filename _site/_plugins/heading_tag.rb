module Jekyll
  module Tags
    # A tag for headings which generates an ID and renders a FAQ associated with it.
    class Heading < Liquid::Tag
      # Renders a heading tag, incrementing the ID if necessary and appending the FAQ if one is
      # found.
      def render(context)
        headings = (context.registers[:page]['headings'] ||= [])

        # set the id, class, style and text tokens
        @markup.strip.split(/( #[^ ]+| \.[^ ]+| \{[^\}]+\})/).each do |token|
          token.strip!

          if match = token.match(/^#(.+)$/)
            @id = context[match[1]] || match[1]
          elsif match = token.match(/^\.(.+)$/)
            classes = match[1].split('.').join(' ')
            @class = @class.nil? ? classes : @class += " #{classes}"
          elsif match = token.match(/^\{(.+)\}$/)
            @style = @style.nil? ? match[1] : @style += ";#{match[1]}"
          else
            unless token.empty?
              @text = context[token] || token
              @id = @text.downcase.gsub(/&amp;/, 'and').gsub(/[ \/\\]/, '-').gsub(/[^\w\-]/, '') unless @id
            end
          end
        end

        # if the heading exists on the page already...
        unless headings.index(@id).nil?
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
          @class = @class.nil? || @class.empty? ? 'footnote' : @class + ' footnote'
          # and render the FAQ
          faq = IncludeTag.new('include', "faq.html id='#{faq.data['id']}'", []).render(context)
        end

        h  = "<#{@tag_name} id=\"#{@id}\""
        h += " class=\"#{@class}\"" if @class
        h += " style=\"#{@style}\"" if @style
        h += ">#{@text}</#{@tag_name}>"
        h += "\n#{faq}" if faq

        h
      end
    end

    Liquid::Template.register_tag('h1', Heading)
    Liquid::Template.register_tag('h2', Heading)
    Liquid::Template.register_tag('h3', Heading)
    Liquid::Template.register_tag('h4', Heading)
  end
end