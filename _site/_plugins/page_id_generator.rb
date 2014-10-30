module Jekyll
  class PageIdGenerator < Generator
    safe true

    # Adds an 'id' and 'date' attribute to each page if it doesn't have them in the YAML Front
    # Matter already. It also creates the site's page hash.
    def generate(site)
      site.data[:page_hash] = {}

      site.pages.each do |page|
        page.data['id'] = page.data['title'].downcase.gsub(/ /, '-') unless page.data['id']
        page.data['date'] = File.mtime("#{site.config['destination']}#{page.path}")
                                .strftime("%FT%T%:z") unless page.data['date']

        site.data[:page_hash][page.data['id']] = page
      end
    end
  end
end