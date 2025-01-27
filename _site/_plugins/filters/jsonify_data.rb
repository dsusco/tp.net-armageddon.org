module Jekyll
  module JsonifyDataFilter
    def jsonify_data(input)
      jsonify(input.transform_values { |v| { 'content' => v.content }.merge(v.data.except('excerpt', 'pdf', 'headings', :h1, :h2, :h3, :rendered_special_rules, :footnote, 'date')) })
    end
  end
end

Liquid::Template.register_filter(Jekyll::JsonifyDataFilter)
