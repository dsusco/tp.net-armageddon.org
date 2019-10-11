Jekyll::Hooks.register :site, :post_read do |site|
  site.data['pages'] =
    site.pages.reduce({}) do |hash, page|
      page.data['mtime'] = File.mtime(File.join(site.source, page.relative_path)) unless page.data['mtime']
      hash[page.url] = page
      hash
    end

  site.collections.each do |label, collection|
    site.data[label] =
      collection.docs.reduce({}) do |hash, doc|
        doc.data['basename'] = doc.basename_without_ext
        doc.data['mtime'] = File.mtime(File.join(site.source, doc.relative_path)) unless doc.data['mtime']
        hash[doc.data['slug']] = doc
        hash
      end
  end

  # set the mtime on the FAQ page to the latest FAQ
  faqPage = site.data['pages']['/faq/']

  site.collections['faqs'].docs.each do |faq|
    faqPage.data['mtime'] = faq.data['mtime'] if faq.data['mtime'].to_s > faqPage.data['mtime'].to_s
  end

  # set the mtime on the TP page to the latest FAQ/Special Rule/Army List
  tpPage = site.data['pages']['/tournament-pack/']

  tpPage.data['mtime'] = faqPage.data['mtime'] if faqPage.data['mtime'].to_s > tpPage.data['mtime'].to_s

  # set the mtime on a unit to the latest weapon/special rule(faq)
  site.collections['units'].docs.each do |u|
    u.data['weapons'].each { |w|
      w = site.data['weapons'][w['id']]
      u.data['mtime'] = w.data['mtime'] if w.data['mtime'].to_s > u.data['mtime'].to_s
    } if u.data['weapons']

    u.data['special_rules'].each { |sr|
      faq = site.data['faqs'][sr]
      u.data['mtime'] = faq.data['mtime'] if faq.data['mtime'].to_s > u.data['mtime'].to_s rescue false
      sr = site.data['special_rules'][sr]
      u.data['mtime'] = sr.data['mtime'] if sr.data['mtime'].to_s > u.data['mtime'].to_s
    } if u.data['special_rules']
  end

  # set the mtime on a force to the latest faq/unit/special rule(faq)
  site.collections['forces'].docs.each do |f|
    faq = site.data['faqs'][f.basename_without_ext]
    f.data['mtime'] = faq.data['mtime'] if faq.data['mtime'].to_s > f.data['mtime'].to_s rescue false

    f.data['units'].each { |u|
      u = site.data['units'][u]
      f.data['mtime'] = u.data['mtime'] if u.data['mtime'].to_s > f.data['mtime'].to_s
    }

    f.data['special_rules'].each { |sr|
      faq = site.data['faqs'][sr]
      f.data['mtime'] = faq.data['mtime'] if faq.data['mtime'].to_s > f.data['mtime'].to_s rescue false
      sr = site.data['special_rules'][sr]
      f.data['mtime'] = sr.data['mtime'] if sr.data['mtime'].to_s > f.data['mtime'].to_s
    } if f.data['special_rules']
  end

  # set the mtime on an army list to the latest faq/force/special rule(faq)
  site.collections['army_lists'].docs.each do |al|
    faq = site.data['faqs'][al.basename_without_ext]
    al.data['mtime'] = faq.data['mtime'] if faq.data['mtime'].to_s > al.data['mtime'].to_s rescue false

    al.data['forces'].each { |f|
      f = site.data['forces'][f]
      al.data['mtime'] = f.data['mtime'] if f.data['mtime'].to_s > al.data['mtime'].to_s
    }

    al.data['special_rules'].each { |sr|
      faq = site.data['faqs'][sr]
      al.data['mtime'] = faq.data['mtime'] if faq.data['mtime'].to_s > al.data['mtime'].to_s rescue false
      sr = site.data['special_rules'][sr]
      al.data['mtime'] = sr.data['mtime'] if sr.data['mtime'].to_s > al.data['mtime'].to_s
    } if f.data['special_rules']

    # set the mtime on the TP page to the latest FAQ/Special Rule/Army List
    tpPage.data['mtime'] = al.data['mtime'] if al.data['mtime'].to_s > tpPage.data['mtime'].to_s
  end

  # set the mtime on the TP page to the latest FAQ/Special Rule/Army List
  site.collections['special_rules'].docs.each do |sr|
    tpPage.data['mtime'] = sr.data['mtime'] if sr.data['mtime'].to_s > tpPage.data['mtime'].to_s
  end
end