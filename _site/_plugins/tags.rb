require 'action_view'

module Jekyll
  module Tags
    class Heading < Liquid::Tag
      include ActionView::Helpers::OutputSafetyHelper
      include ActionView::Helpers::SanitizeHelper
      include ActionView::Helpers::TagHelper

      def render(context)
        h = { id: nil, class: [], number: '', style: [], text: nil }
        page = context.registers[:page]
        # hash for tracking all the heading tags on a page
        headings = (page['headings'] ||= {})

        # get the various arguments
        @markup.strip.split(/ (#[^ ]+|\.[^ ]+|\{[^\}]+\})/).each do |token|
          # id is preceded by #
          token.match(/^#(.+)$/) { |m| h[:id] = context[m[1]] || m[1] }
          # classes are preceded by .
          token.match(/^\.(.+)$/) { |m| h[:class].concat(m[1].split('.')) }
          # styles are enclosed within {}
          token.match(/^\{(.+)\}$/) { |m| h[:style].concat(m[1].split(';')) }
          # text is what doesn't match the above
          token.match(/^[^#\.\{]/) { |m| h[:text] = context[token] || token }
        end

        # if no ID is given, use the text
        h[:id] ||= strip_tags(h[:text]).downcase.gsub(/&amp;/, 'and').gsub(/[ \/\\]/, '-').gsub(/[^\w\-]/, '')
        # make the ID unique by appending numbering if needed
        h[:id] = "#{h[:id]}-#{headings.keys.select{ |k| k.start_with?(h[:id]) } .length}" if headings.key?(h[:id])

        # generate a heading number (CSS counters can't be used in the ToC/nav so it's done here)
        unless h[:class].include?('no-numbering')
          case @tag_name.to_sym
          when :h1
            page[:h1] += 1 rescue page[:h1] = 1
            page[:h2] = 0
            page[:h3] = 0
          when :h2
            page[:h2] += 1 rescue page[:h2] = 1
            page[:h3] = 0
          when :h3
            page[:h3] += 1 rescue page[:h3] = 1
          end

          h[:number] = "#{page[:h1]}.#{page[:h2]}#{".#{page[:h3]}" unless page[:h3] === 0}"
        end

        # add to the heading hash for the ToC/nav
        headings[h[:id]] = { 'class' => @tag_name, 'href' => "##{h[:id]}", 'text' => h[:text], 'number' => h[:number] }

        # if this isn't the FAQ page, and an faq exists, set it
        if !page['url'].eql?('/faq/') && faq = context.registers[:site].collections['faqs'].docs.find { |doc| doc.basename_without_ext.eql?(h[:id]) }
          page[:footnote] += 1 rescue page[:footnote] = 1
          h[:class] << 'has-footnote'

          # used for ordering the FAQ page
          if page['url'].eql?('/tournament-pack/')
            faq.data['footnote'] ||= page[:footnote]
            faq.data['number'] = h[:number]
          end

          faq = Liquid::Template.parse("{% include faq.html id='#{h[:id]}' %}").render(context)
        end

        "#{content_tag(@tag_name, raw(h[:text]), { id: h[:id], class: h[:class].join(' '), style: h[:style].join(';'), data: { footnote: page[:footnote], number: h[:number], target: "#faq-#{h[:id]}", toggle: :collapse } })}#{faq}"
      end
    end

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

    Liquid::Template.register_tag('h1', Heading)
    Liquid::Template.register_tag('h2', Heading)
    Liquid::Template.register_tag('h3', Heading)
    Liquid::Template.register_tag('h4', Heading)
    Liquid::Template.register_tag('h5', Heading)
    Liquid::Template.register_tag('h6', Heading)

    Liquid::Template.register_tag('include_special_rule', IncludeSpecialRule)
  end
end
