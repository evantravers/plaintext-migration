def render(data)
%{title: #{data[:title]}
tags: #{data[:tags]}
id: #{data[:id]}

#{data[:body]}}
end

def clean_body(string)
  string.strip
end

def notes(opts = {})
  crawl("../notes").each do |path|
    filename = File.basename(path)
    folder = File.split(File.dirname(path)).last

    data    = Hash.new
    content = File.read(path)

    # EXTRACT read date from file
    # I had the files randomly labeled and foldered based on year.
    begin
      date = Date.parse(content)
    rescue StandardError
      date = File.birthtime(path)
      # date = Date.parse("#{t.month} #{t.day}, #{folder}")
    end

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

    if folder != "./"
      tags.push("##{folder.gsub("./", "")}")
    end

    content.gsub!(ORGTAG, '\1')

    data[:tags] = tags.join(", ")
    data[:body] = clean_body(content)
    data[:title] = filename.gsub(/\.(txt|md)/, "")

    # WRITE filename with new filename to a new folder
    filename = "#{data[:id]}-#{clean_title(data[:title])}.md"
    if opts[:test]
      puts "\n\n>> #{filename} <<\n"
      puts render(data)
    else
      IO.write(File.join(DST, filename), render(data))
    end
  end
end
