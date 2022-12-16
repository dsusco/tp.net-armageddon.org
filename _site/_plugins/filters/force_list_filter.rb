require 'action_view'

module Jekyll
  module ForceListFilter
    include ActionView::Helpers::TagHelper

    def force_list(forces)
      forces.map { |f|
        force = @context.registers[:site].data['forces'][f]
        content_tag(:a, "the #{ force['name'] } Forces section", { href: "##{force.data['slug']}-forces" })
      }.to_sentence() rescue ''
    end
  end
end

Liquid::Template.register_filter(Jekyll::ForceListFilter)
