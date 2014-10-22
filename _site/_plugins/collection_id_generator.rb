module Jekyll
  class CollectionIDGenerator < Generator
    safe true

    def generate(site)
      site.collections.each_value do |collection|
        collection.docs.each do |doc|
          doc.data['id'] = File.basename(doc.path, File.extname(doc.path)) unless doc.data['id']
          doc.data['date'] = doc.data['date'].to_s unless doc.data['date']
        end
      end
    end
  end
end