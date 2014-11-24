module Jekyll
  class CollectionIdGenerator < Generator
    priority :highest
    safe true

    # Adds an 'id' and 'date' attribute to each document in every collection if it doesn't have
    # them in the YAML Front Matter already. Also creates the site's hash for the collection.
    def generate(site)
      site.collections.each_pair do |key, value|
        site.data[key] = {}

        value.docs.each do |doc|
          doc.data['id'] = File.basename(doc.path, File.extname(doc.path)) unless doc.data['id']
          doc.data['date'] = File.mtime(doc.path).strftime("%FT%T%:z") unless doc.data['date']

          site.data[key][doc.data['id']] = doc
        end
      end
    end
  end

  class CounterGenerator < Generator
    priority :lowest
    safe true

    def generate(site)
      weapons = []
      site.data['units'].each_value do |u|
        weapons += u.data['weapons'].map{ |w| w['id'] } if u.data['weapons']
      end
      p site.collections['weapons'].docs.map { |d| d.data['id'] } - weapons.uniq!
    end
  end
end