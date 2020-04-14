require 'date'
require 'uri'
require 'net/http'
require 'json'
require 'set'

SRC    = "../notes/"
DST    = "./migrated"
ORGTAG = /:([a-zA-Z\-_]+)/
IDS    = Set.new

def render(data)
%{title: #{data[:title]}
tags: #{data[:tags]}
id: #{data[:id]}

#{data[:body]}}
end

def id(datetime)
  id = datetime.strftime("%Y%m%d%H%M%S")
  while IDS.include?(id)
    id = (id.to_i + 1).to_s
  end
  IDS.push(id)
  return id
end

def clean_body(string)
  string.strip
end

def clean_title(string)
  string
    .downcase
    .gsub(/[^a-zA-Z0-9\-]/, "-")
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

def string_to_tag(str)
  str
    .gsub(/[^a-zA-Z_]/, '_')
    .gsub(/_{2,}/, '_')
    .downcase
    .prepend('#')
end

def process_folder(folder)
  Dir.children(folder).each do |filename|
    unless ["migrated", ".DS_Store", "migrate_notes.rb"].include?(filename)
      if File.directory?(filename)
        process_folder(filename)
      else
        puts "Processing #{filename}…"
        if filename.match?(/.*\.(?:md|txt)/)
          path    = File.join(folder, filename)
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
          # puts "\n\n>> #{filename} <<\n"
          # puts render(data)
          IO.write(File.join(DST, filename), render(data))
        end
      end
    end
  end
end

process_folder(SRC)
