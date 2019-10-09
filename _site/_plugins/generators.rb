__END__
module Jekyll
  require './_site/_helpers/hash'

  class MTimeUpdateGenerator < Generator
    priority :lowest
    safe true

    def generate(site)
      tp = site.data['pages']['netea-tournament-pack']

      # for each army list, update its mtime
      site.data['army_lists'].each_value do |army_list|
        # check its FAQ
        updateMTime(army_list, site.data['faqs']["#{army_list.data['id']}-army-list"])

        # each force
        army_list.data['forces'].each do |f|
          force = site.data['forces'][f]
          updateMTime(army_list, force)
          # each force's faq
          updateMTime(army_list, site.data['faqs']["#{f}-forces"])

          force.data['units'].each do |u|
            unit = site.data['units'][u]
            # each unit in the force
            updateMTime(army_list, unit)

            if unit.data['weapons']
              # each weapon on each unit in the force
              unit.data['weapons'].each do |w|
                updateMTime(army_list, site.data['weapons'][w['id']])
              end
            end
          end

          # each special rule and their FAQs in the force
          if force.data['special_rules']
            force.data['special_rules'].each do |sr|
              updateMTime(army_list, site.data['special_rules'][sr])
              updateMTime(army_list, site.data['faqs'][sr])
            end
          end
        end

        # and each special rule and their FAQs
        army_list.data['special_rules'].each do |sr|
          updateMTime(army_list, site.data['special_rules'][sr])
          updateMTime(army_list, site.data['faqs'][sr])
        end

        # update the TP page with the army list's updated date
        updateMTime(tp, army_list)
      end

      faq_page = site.data['pages']['netea-faq']

      # for each FAQ, update the FAQ page's date
      site.data['faqs'].each_value do |faq|
        updateMTime(faq_page, faq)
      end

      # update the TP page with the FAQ page's updated date
      updateMTime(tp, faq_page)
    end

    private
      def updateMTime(parent, child)
        parent.data['mtime'] = child.data['mtime'] if child and parent.data['mtime'] < child.data['mtime']
      end
  end

  class IdMTimeGenerator < Generator
    priority :highest
    safe true

    def generate(site)
      site.data['pages'] = {}

      site.pages.each do |page|
        begin
          page.data['id'] = page.data['title'].downcase.gsub(/&amp;/, 'and').gsub(/[ \/\\]/, '-') unless page.data['id']
          page.data['mtime'] = File.mtime("#{site.config['source']}#{page.path}") unless page.data['mtime']

          site.data['pages'][page.data['id']] = page
        rescue
        end
      end

      site.collections.each_pair do |key, value|
        site.data[key] = {}

        value.docs.each do |doc|
          doc.data['id'] = doc.basename_without_ext unless doc.data['id']
          doc.data['mtime'] = File.mtime(doc.path) unless doc.data['mtime']

          site.data[key][doc.data['id']] = doc
        end
      end
    end
  end
end
