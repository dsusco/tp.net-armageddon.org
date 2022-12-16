require 'action_view'

module Jekyll
  module WeaponNameFilter
    include ActionView::Helpers::TagHelper

    def weapon_name(weapon, w, m)
      if m['boolean']
        content_tag(:span, m['boolean'], { class: 'name boolean' })
      else
        content_tag(:span, "#{"#{w['multiplier']}× " if w['multiplier'] }#{weapon['name']}", { class: 'name' })
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::WeaponNameFilter)
