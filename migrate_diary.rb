def render(data)
%{title: #{data[:title]}
id: #{data[:id]}
tags: #{data[:tags]}
date: #{data[:date]}

#{data[:body]}}
end

def diary(opts = {})
  crawl("../diary/").each do |file|
    filename = File.basename(file)

    data    = Hash.new
    content = File.read(file)

    # EXTRACT date from filename and put in metadata
    datestring =
      filename
      .scan(/(\d+)/)
      .flatten
      .map{ |n| n.to_i }

    date = DateTime.new(*datestring)

    # ADD id to metadata based on date
    data[:id] = id(date)
    data[:date] = date.strftime("%a, %e %b %Y %T")

    # EXTRACT tags from /:\w+:/ format and transform to hashtags
    tags =
      content
      .scan(ORGTAG)
      .flatten
      .map{ |t| '#' + t.gsub(":", "").gsub('-', '_').downcase }
      .uniq

    content.gsub!(ORGTAG, '\1')

    # ADD tag for #journal
    tags.push('#journal')

    if content.match(/^## Notes/)
      tags.push('#meeting')
    end

    data[:tags] = tags.join(', ')

    # DETERMINE title from h1 (clean, remove tags)
    title = content.match(/^# .*/).to_s.gsub("# ", "")
    data[:title] = title

    data[:body] = content

    # WRITE filename with new filename to a new folder
    filename = "#{data[:id]}-#{clean_title(title)}.md"
    if opts[:test]
      puts filename
      puts render(data)
      puts "\n\n --- \n\n"
    else
      IO.write(DST + '/' + filename, render(data))
    end
  end
end
