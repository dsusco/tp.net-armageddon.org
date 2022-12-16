Jekyll::Hooks.register(:site, :post_write) do |site|
  pdfs_dir = "#{site.dest}/pdfs"
  Dir.mkdir(pdfs_dir) unless File.directory?(pdfs_dir)

  site.pages.each do |page|
    if page.data['pdf']
      prince_commands(
        site,
        "#{page.data['pdf']}-.pdf",
        "#{pdfs_dir}/#{page.data['pdf']}-#{page.data['mtime'].strftime('%F')}.pdf",
        "#{site.dest}#{page.permalink || "#{page.url}#{page.name if page.index?}"}"
      )
    end
  end

  site.collections['army_lists'].docs.each do |army_list|
    prince_commands(
      site,
      "#{army_list.data['pdf']}-.pdf",
      "#{pdfs_dir}/#{army_list.data['pdf']}-#{army_list.data['mtime'].strftime('%F')}.pdf",
      "#{site.dest}#{army_list.url}"
    )
  end
end

BEGIN {
  def prince_commands(site, redirect, pdf, html)
    commands = [
      %Q`prince --media=print --script=https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js --script=#{Dir[File.join(site.dest, 'assets', 'tp.print-*.js')].pop} --style=#{Dir[File.join(site.dest, 'assets', 'tp.print-*.css')].pop} -o #{pdf} #{html}`,
      %Q`ruby -EASCII-8BIT -i -p -e 'found ||= false' -e 'line = $_.sub!(/^\\/Annots \\[\\d+ \\d R \\d+ \\d R /, "/Annots [") unless found' -e 'found = true unless line.nil?' #{pdf}`,
      %Q`ruby -i -p -e 'sub("#{redirect}", "#{pdf.sub(/.+\//, '')}")' #{site.dest}/.htaccess`
    ]
    %x(#{commands.join(';')})
  end
}
