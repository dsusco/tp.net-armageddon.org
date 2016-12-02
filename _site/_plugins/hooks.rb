Jekyll::Hooks.register(:site, :post_write) do |site|
  pdfs_dir = "#{site.dest}/pdfs"
  Dir.mkdir(pdfs_dir) unless File.directory?(pdfs_dir)

  site.pages.each do |page|
    if page.data['pdf']
      redirect_match_string = "#{pdfs_dir}/#{page.data['id']}-"
      pdf_name = "#{redirect_match_string}#{page.data['mtime'].strftime('%F')}.pdf"
      html_name = "#{site.dest}#{page.permalink || "#{page.url}#{page.name if page.index?}"}"

      prince_commands(site, redirect_match_string, pdf_name, html_name)
    end
  end

  site.collections['army_lists'].docs.each do |army_list|
    redirect_match_string = "#{pdfs_dir}/netea-#{army_list.basename_without_ext}-"
    pdf_name = "#{redirect_match_string}#{army_list.data['mtime'].strftime('%F')}.pdf"
    html_name = "#{site.dest}#{army_list.url}"

    prince_commands(site, redirect_match_string, pdf_name, html_name)
  end
end

BEGIN {
  def prince_commands(site, redirect_match_string, pdf_name, html_name)
    %x(prince --media=print --script=#{site.dest}/assets/js/tp.net-armageddon.org.print.js --style=#{site.dest}/assets/css/tp.net-armageddon.org.print.css -o #{pdf_name} #{html_name};ruby -EASCII-8BIT -i -p -e '$_.sub!(/^\\/Annots \\[\\d+ \\d R ?/, "/Annots [") unless @found;@found = !($_ =~ /^\\/Annots \\[/).nil?' #{pdf_name};ruby -i -p -e 'sub("#{redirect_match_string.sub(/.+\//, '')}", "#{pdf_name.sub(/.+\//, '')}")' #{site.dest}/.htaccess)
  end
}
