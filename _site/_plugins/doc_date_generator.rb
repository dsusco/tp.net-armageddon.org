module Jekyll
  class DocDateGenerator < Generator
    priority :lowest
    safe true

    #
    def generate(site)
      tp = site.data['pages']['netea-tournament-pack']
      faq_page = site.data['pages']['netea-faq']

      site.data['army_lists'].each_value do |army_list|
        updateDate(army_list, site.data['faqs']["#{army_list.data['id']}-army-list"])

        army_list.data['forces'].each do |f|
          updateDate(army_list, site.data['faqs']["#{f}-forces"])

          force = site.data['forces'][f]
          updateDate(army_list, force)

          force.data['units'].each do |u|
            unit = site.data['units'][u]
            updateDate(army_list, unit)

            if unit.data['weapons']
              unit.data['weapons'].each do |w|
                updateDate(army_list, site.data['weapons'][w])
              end
            end
          end

          if force.data['special_rules']
            force.data['special_rules'].each do |sr|
              updateDate(army_list, site.data['faqs'][sr])
              updateDate(army_list, site.data['special_rules'][sr])
            end
          end
        end

        army_list.data['special_rules'].each do |sr|
          updateDate(army_list, site.data['faqs'][sr])
          updateDate(army_list, site.data['special_rules'][sr])
        end

        updateDate(tp, army_list)
      end

      site.data['faqs'].each_value do |faq|
        updateDate(faq_page, faq)
      end
    end

    private

    def updateDate(parent, child)
      parent.data['date'] = child.data['date'] if child and child.data['date'] > parent.data['date']
    end
  end
end