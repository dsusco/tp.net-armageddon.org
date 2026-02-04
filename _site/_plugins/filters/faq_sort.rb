module Jekyll
  module FaqSortFilter
    def faq_sort (input, property)
      input.values.sort_by { |doc| doc.data[property] }
    end
  end
end

Liquid::Template.register_filter(Jekyll::FaqSortFilter)
