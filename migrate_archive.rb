Filename_pattern = /^(\d+)-/
Content_pattern  = /^id: (\d+)$/

def archive(opts = {})
  crawl("../archive").each do |file|
    filename = File.basename(file)
    content  = File.read(file)

    id = filename.scan(Filename_pattern).flatten[0]
    content_id = content.scan(Content_pattern).flatten[0]

    if id == content_id
      if id.length() > 12
        new_id = id.slice(0, 12)

        filename.gsub!(Filename_pattern, "#{new_id}-")
        content.gsub!(Content_pattern, "id: #{new_id}")

        if opts[:test]
          puts filename + "-----"
          puts content
          puts "\n\n --- \n\n"
        else
          IO.write(DST + '/' + filename, content)
        end
      end
    else
      puts "YIKES!"
    end
  end
end
