require 'action_view'

module Jekyll
  module WeaponArcFilter
    include ActionView::Helpers::TagHelper

    def weapon_arc(w, m)
      content_tag(:li, w['arc']) if w['arc'] and not %w((bc) (15cm)).include?(m['range'])
    end
  end
end

Liquid::Template.register_filter(Jekyll::WeaponArcFilter)
