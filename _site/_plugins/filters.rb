require 'action_view'

module Jekyll
  module Filters
    include ActionView::Helpers::TagHelper

    def force_list(forces)
      forces.map { |f|
        force = @context.registers[:site].data['forces'][f]
        content_tag(:a, "the #{ force['name'] } Forces section", { href: "##{force['id']}-forces" })
      }.join(', ')
    end

    def weapon_arc(w, m)
      content_tag(:li, w['arc']) if w['arc'] and not %w((bc) (15cm)).include?(m['range'])
    end

    def weapon_name(weapon, w, m)
      if m['boolean']
        content_tag(:span, m['boolean'], { class: 'name boolean' })
      else
        content_tag(:span, "#{"#{w['multiplier']}× " if w['multiplier'] }#{weapon['name']}", { class: 'name' })
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::Filters)