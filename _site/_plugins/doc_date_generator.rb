module Jekyll
  class DocDateGenerator < Generator
    priority :lowest
    safe true

    # Updates the dates on the TP, FAQ and army list pages.
    def generate(site)
      tp = site.data['pages']['netea-tournament-pack']
      faq_page = site.data['pages']['netea-faq']

      # for each army list, update its date
      site.data['army_lists'].each_value do |army_list|
        # check its FAQ
        updateDate(army_list, site.data['faqs']["#{army_list.data['id']}-army-list"])

        # each force
        army_list.data['forces'].each do |f|
          force = site.data['forces'][f]
          updateDate(army_list, force)
          # each force's faq
          updateDate(army_list, site.data['faqs']["#{f}-forces"])

          force.data['units'].each do |u|
            unit = site.data['units'][u]
            # each unit in the force
            updateDate(army_list, unit)

            if unit.data['weapons']
              # each weapon on each unit in the force
              unit.data['weapons'].each do |w|
                updateDate(army_list, site.data['weapons'][w['id']])
              end
            end
          end

          # each special rule and their FAQs in the force
          if force.data['special_rules']
            force.data['special_rules'].each do |sr|
              updateDate(army_list, site.data['special_rules'][sr])
              updateDate(army_list, site.data['faqs'][sr])
            end
          end
        end

        # and each special rule and their FAQs
        army_list.data['special_rules'].each do |sr|
          updateDate(army_list, site.data['special_rules'][sr])
          updateDate(army_list, site.data['faqs'][sr])
        end

        # update the TP page with the army list's updated date
        updateDate(tp, army_list)
      end

      # for each FAQ, update the FAQ page's date
      site.data['faqs'].each_value do |faq|
        updateDate(faq_page, faq)
      end

      # update the TP page with the FAQ page's updated date
      updateDate(tp, faq_page)

      # update the TP page with each of its included file dates
      (1..6).each do |i|
        include_time = File.mtime("#{site.config['source']}_includes/#{i}.html").strftime("%FT%T%:z")

        tp.data['date'] = include_time if include_time > tp.data['date']
      end
    end

    private

    def updateDate(parent, child)
      parent.data['date'] = child.data['date'] if child and child.data['date'] > parent.data['date']
    end
  end
end