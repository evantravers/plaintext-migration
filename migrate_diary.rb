require 'date'

SRC    = "../diary/"
DST    = "./migrated"
ORGTAG = /:([a-zA-Z\-_]+)/

def render(data)
%{title: #{data[:title]}
id: #{data[:id]}
tags: #{data[:tags]}
date: #{data[:date]}

#{data[:body]}}
end

def id(datetime)
  datetime.strftime("%Y%m%d%H%M%S")
end

def clean_title(string)
  string
    .downcase
    .gsub(/[^a-zA-Z_]/, "_")
    .gsub(/_{2,}/, '_')
end

Dir.foreach(SRC) do |filename|
  if filename.match?(/.*\.md/)
    data    = Hash.new
    content = File.read(filename)

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
    IO.write(DST + '/' + filename, render(data))
  end
end

