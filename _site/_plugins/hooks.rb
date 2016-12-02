Jekyll::Hooks.register(:site, :post_write) do |site|
  pdfs_dir = "#{site.dest}/pdfs"
  Dir.mkdir(pdfs_dir) unless File.directory?(pdfs_dir)

  site.pages.each do |page|
    if page.data['pdf']
      prince_commands(
        site,
        "#{page.data['id']}-.pdf",
        "#{pdfs_dir}/#{page.data['id']}-#{page.data['mtime'].strftime('%F')}.pdf",
        "#{site.dest}#{page.permalink || "#{page.url}#{page.name if page.index?}"}"
      )
    end
  end

  site.collections['army_lists'].docs.each do |army_list|
    prince_commands(
      site,
      "netea-#{army_list.basename_without_ext}-.pdf",
      "#{pdfs_dir}/netea-#{army_list.basename_without_ext}-#{army_list.data['mtime'].strftime('%F')}.pdf",
      "#{site.dest}#{army_list.url}"
    )
  end
end

BEGIN {
  def prince_commands(site, redirect, pdf, html)
    commands = [
      %Q`prince --media=print --script=#{site.dest}/assets/js/tp.net-armageddon.org.print.js --style=#{site.dest}/assets/css/tp.net-armageddon.org.print.css -o #{pdf} #{html}`,
      %Q`ruby -EASCII-8BIT -i -p -e '$_.sub!(/^\\/Annots \\[\\d+ \\d R ?/, "/Annots [") unless @found;@found = !($_ =~ /^\\/Annots \\[/).nil?' #{pdf}`,
      %Q`ruby -i -p -e 'sub("#{redirect}", "#{pdf.sub(/.+\//, '')}")' #{site.dest}/.htaccess`
    ]
    %x(#{commands.join(';')})
  end
}
