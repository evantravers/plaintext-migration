require 'date'

SRC    = "../notes/bible_study/"
DST    = "./migrated"
ORGTAG = /:([a-zA-Z\-_]+)/

def render(data)
%{id: #{data[:id]}
tags: #{data[:tags]}
date: #{data[:date]}

#{data[:body]}}
end

def id(datetime)
  datetime.strftime("%Y%m%d%H%M%S")
end

def clean_body(string)
  string
    .gsub(/^## +\d\d\d\d-\d\d-\d\d\n\n/, "")
    .gsub(/^## \d\d-\d\d-\d\d\d\d\n\n/, "")
end

def clean_title(string)
  string
    .downcase
    .gsub(/[^a-zA-Z\-]/, "-")
    .gsub(/-{2,}/, '-')
end

Dir.foreach(SRC) do |filename|
  unless ["bible-study.md"].include?(filename)
    if filename.match?(/.*\.(?:md|txt)/)
      data    = Hash.new
      content = File.read(filename)

      # EXTRACT date from filename and put in metadata
      datestring =
        filename
        .scan(/(\d+)/)
        .flatten
        .map{ |n| n.to_i }

      # handle backwards filenames
      if datestring.empty?
        date = File.birthtime(filename)
      else
        if datestring[0] < 100
          datestring = [datestring[2], datestring[0], datestring[1]]
        end

        date = DateTime.new(*datestring)
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

      content.gsub!(ORGTAG, '\1')

      # ADD tag for #journal
      tags.push('#journal')
      tags.push('#devotional')

      data[:tags] = tags.join(', ')

      # DETERMINE from first four words
      if filename.gsub(/\.(?:txt|md)/, '').scan(/[a-zA-Z]+/).empty?
        title = content.split(' ').filter{|w| w.match(/[a-zA-Z]/)}.take(4).join(' ')
      else
        title = filename.gsub(/\.(?:txt|md)/, '')
      end

      data[:title] = title
      data[:body] = clean_body(content)

      # WRITE filename with new filename to a new folder
      filename = "#{data[:id]}-#{clean_title(title)}.md"
      puts filename
      puts render(data)
      puts "\n\n --- \n\n"
      IO.write(DST + '/' + filename, render(data))
    end
  end
end

