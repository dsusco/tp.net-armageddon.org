module Jekyll
  module Tags
    # A tag for headings which generates an ID and renders any FAQ associated with it.
    class Heading < Liquid::Tag
      # Renders a heading tag, incrementing the ID if necessary and appending the FAQ if one is
      # found.
      def render(context)
        page = context.registers[:page]
        headings = (page['headings'] ||= [])

        # set the id, class, style and text tokens
        @markup.strip.split(/( #[^ ]+| \.[^ ]+| \{[^\}]+\})/).each do |token|
          token.strip!

          if match = token.match(/^#(.+)$/)
            @id = context[match[1]] || match[1]
          elsif match = token.match(/^\.(.+)$/)
            @class = match[1].split('.').join(' ')
          elsif match = token.match(/^\{(.+)\}$/)
            @style = @style.nil? ? match[1] : @style += ";#{match[1]}"
          else
            unless token.empty?
              @text = context[token] || token
              @id ||= @text.downcase.gsub(/&amp;/, 'and').gsub(/[ \/\\]/, '-').gsub(/[^\w\-]/, '')
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

        # set the data-heading attribute (a three level heading counter)
        if page['id'] == 'netea-tournament-pack'
          heading = @text
          page['h1'] ||= 0
          page['h2'] ||= 0
          page['h3'] ||= 0
          page['footnote'] ||= 0 # this is used to order the FAQs on the FAQ page

          if @class.nil? or not @class.include?('no-count')
            case @tag_name
              when 'h1'
                page['h1'] += 1
                page['h2'] = 0
                page['h3'] = 0
                heading = "#{page['h1']}.0"
              when 'h2'
                page['h2'] += 1
                page['h3'] = 0
                heading = "#{page['h1']}.#{page['h2']}"
              when 'h3'
                page['h3'] += 1
                heading = "#{page['h1']}.#{page['h2']}.#{page['h3']}"
            end
          end
          page['footnote'] += 1
        end

        # if a faq is found...
        if faq = context.registers[:site]
                        .collections['faqs'].docs.find { |doc| doc.data['id'] == @id }
          # set some data for the FAQ page
          faq.data['footnote'] = page['footnote'] if page['footnote']
          faq.data['heading'] = heading

          # add the footnote class
          @class = @class.nil? || @class.empty? ? 'footnote' : @class + ' footnote'
          # and render the FAQ
          faq = IncludeTag.new('include', "faq.html id='#{faq.data['id']}'", []).render(context)
        end

        # build the HTML to render
        h  = "<#{@tag_name}"
        h += " id=\"#{@id}\""
        h += " class=\"#{@class}\"" if @class
        h += " style=\"#{@style}\"" if @style
        h += " data-heading=\"#{heading}\"" if heading
        h += ">"
        h += "#{heading} " if heading and heading != @text
        h += @text
        h += "</#{@tag_name}>"
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