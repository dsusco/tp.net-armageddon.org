Jekyll::Hooks.register :site, :post_read do |site|
  site.data['pages'] =
    site.pages.reduce({}) do |hash, page|
      hash[page.url] = page
      hash
    end

  site.collections.each do |label, collection|
    site.data[label] =
      collection.docs.reduce({}) do |hash, doc|
        doc.data['basename'] = doc.basename_without_ext
        hash[doc.data['slug']] = doc
        hash
      end
  end
end