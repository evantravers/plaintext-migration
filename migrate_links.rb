require 'date'
require 'uri'

SRC    = "../links/"
DST    = "./migrated"
ORGTAG = /:([a-zA-Z\-_]+)/

def render(data)
%{id: #{data[:id]}
tags: #{data[:tags]}
date: #{data[:date]}

#{data[:body]}

[#{data[:title]}](#{data[:link]})}
end

def id(datetime)
  datetime.strftime("%Y%m%d%H%M%S")
end

def clean_body(string)
  string
    .gsub(/\w+ \d+, \d\d\d\d at \d\d:\d\d../, "")
    .gsub(/via Instapaper /, "")
    .gsub(/^#{URI.regexp}/m, "")
    .strip
end

def clean_title(string)
  string
    .downcase
    .gsub(/[^a-zA-Z\-]/, "-")
    .gsub(/-{2,}/, '-')
    .split('-')
    .take(5)
    .join('-')
end

def extract_link(string)
  URI.extract(string)
    .filter{|url| url =~ /\A#{URI::regexp(['http', 'https'])}\z/}
    .first
end

Dir.foreach(SRC) do |filename|
  unless [].include?(filename)
    if filename.match?(/.*\.(?:md|txt)/)
      data    = Hash.new
      content = File.read(filename)

      # EXTRACT date from filename and put in metadata
      datestring =
        filename
        .scan(/\w+ \d+, \d\d\d\d/)
        .flatten
        .first

      # handle backwards filenames
      if datestring.nil? || datestring.empty?
        date = File.birthtime(filename)
      else
        date = DateTime.parse(datestring)
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

      # EXTRACT title from first line
      title = content.lines.reject{|l| l.match(/tags:.*/) || l.strip.empty? }.first.strip

      # ADD tag for #link
      tags.push('#link')

      data[:tags] = tags.join(', ')

      data[:link] = extract_link(content)

      data[:title] = title
      data[:body] = clean_body(content)

      # Only accept ones with quotes
      if content.match(/^> /)
        # WRITE filename with new filename to a new folder
        filename = "#{data[:id]}-#{clean_title(title)}.md"
        # puts filename + "-----"
        # puts render(data)
        # puts "\n\n --- \n\n"
        IO.write(DST + '/' + filename, render(data))
      end
    end
  end
end
