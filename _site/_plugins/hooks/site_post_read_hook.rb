Jekyll::Hooks.register :site, :post_read do |site|
  site.pages.filter { |page| page.ext.eql?('.html') }.each do |page|
    url = page.url
    url += page.name if page.index?

    site.data.dig('pages', *url.split('/')[1..]).data['mtime'] =
      Time.parse(%x(git log -1 --pretty="format:%ci" #{File.join(site.source, page.relative_path)}))
        rescue File.mtime(File.join(site.source, page.relative_path))
  end

  site.collections.each do |label, collection|
    site.data[label] =
      collection.docs.reduce({}) do |docs, doc|
        doc.data['basename'] = doc.basename_without_ext
        doc.data['mtime'] = Time.parse(%x(git log -1 --pretty="format:%ci" #{File.join(site.source, doc.relative_path)})) rescue File.mtime(File.join(site.source, doc.relative_path))
        docs[doc.data['slug']] = doc
        docs
      end
  end

  def update_parent_mtime (parent, child)
    parent.data['mtime'] = child.data['mtime'] if child.data['mtime'] > parent.data['mtime'] rescue false
  end

  rulesPage = site.data.dig('pages', 'rules', 'index.html')

  # set the mtime on the FAQ page to the latest FAQ
  faqPage = site.data.dig('pages', 'faq', 'index.html')

  site.collections['faqs'].docs.each do |faq|
    update_parent_mtime(faqPage, faq)
  end

  # set the mtime on the TP page to the latest rules/FAQ/Special Rule/Army List
  tpPage = site.data.dig('pages', 'tournament-pack', 'index.html')

  update_parent_mtime(tpPage, faqPage)
  update_parent_mtime(tpPage, rulesPage)

  # set the mtime on a unit to the latest weapon/special rule(faq)
  site.collections['units'].docs.each do |u|
    u.data['weapons'].each { |w|
      w = site.data['weapons'][w['id']]
      update_parent_mtime(u, w)
    } if u.data['weapons']

    u.data['special_rules'].each { |sr|
      faq = site.data['faqs'][sr]
      update_parent_mtime(u, faq)
      sr = site.data['special_rules'][sr]
      update_parent_mtime(u, sr)
    } if u.data['special_rules']
  end

  # set the mtime on a force to the latest faq/unit/special rule(faq)
  site.collections['forces'].docs.each do |f|
    faq = site.data['faqs'][f.basename_without_ext]
    update_parent_mtime(f, faq)

    f.data['units'].each { |u|
      u = site.data['units'][u]
      update_parent_mtime(f, u)
    }

    f.data['special_rules'].each { |sr|
      faq = site.data['faqs'][sr]
      update_parent_mtime(f, faq)
      sr = site.data['special_rules'][sr]
      update_parent_mtime(f, sr)
    } if f.data['special_rules']
  end

  # set the mtime on an army list to the latest faq/force/special rule(faq)
  site.collections['army_lists'].docs.each do |al|
    # set the army list's PDF name
    al.data['pdf'] = "netea-#{al.data['basename']}"

    faq = site.data['faqs'][al.basename_without_ext]
    update_parent_mtime(al, faq)

    al.data['forces'].each { |f|
      f = site.data['forces'][f]
      update_parent_mtime(al, f)
    }

    al.data['special_rules'].each { |sr|
      faq = site.data['faqs'][sr]
      update_parent_mtime(al, faq)
      sr = site.data['special_rules'][sr]
      update_parent_mtime(al, sr)
    } if al.data['special_rules']

    # set the mtime on the TP page to the latest FAQ/Special Rule/Army List
    update_parent_mtime(tpPage, al)
  end

  # set the mtime on the TP page to the latest FAQ/Special Rule/Army List
  site.collections['special_rules'].docs.each do |sr|
    update_parent_mtime(tpPage, sr)
    update_parent_mtime(rulesPage, sr)
  end
end
