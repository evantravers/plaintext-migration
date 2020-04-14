require 'net/http'
require 'json'
require 'rubygems/text'

include Gem::Text

def render(data)
if data["subtitle"]
  subtitle = "\nsubtitle: #{data["subtitle"]}"
else
  subtitle = ""
end
%{title: #{data["title"]}#{subtitle}
author: #{mla_authors(data["authors"])}
publisher: #{data["publisher"]}
year: #{data["publishedDate"]}
identifier: #{data["identifier"]}
tags: #{data["tags"]}
id: #{data["id"]}

#{data["body"]}}
end

def clean_body(string)
  string.strip
end

def mla_authors(authors)
  authors.join(", ") if authors
end

def extract_link(string)
  URI.extract(string)
    .filter{|url| url =~ /\A#{URI::regexp(['http', 'https'])}\z/}
    .first
end

def booknotes(opts = {})
  crawl("../booknotes").each do |file|
    filename = File.basename(file)
    folder = File.dirname(file)

    path    = File.join(folder, filename)
    data    = Hash.new
    content = File.read(path)

    # EXTRACT read date from file
    # I had the files randomly labeled and foldered based on year.
    begin
      date = Date.parse(content)
    rescue StandardError
      date = File.birthtime(path)
    end

    # ADJUST dates (this is _crazy_ lazy, I know)
    until date.year == File.split(folder).last.to_i
      puts "Adjusting date... #{date.year}"
      if date.year > folder.to_i
        date = date.prev_year
      else
        date = date.next_year
      end
    end

    # ADD id to metadata based on date
    data["id"] = id(date)
    data["date"] = date.strftime("%a, %e %b %Y %T")

    # EXTRACT tags from /:\w+:/ format and transform to hashtags
    tags =
      content
      .scan(ORGTAG)
      .flatten
      .map{ |t| '#' + t.gsub(":", "").gsub('-', '_').downcase }
      .uniq

    tags.push("#book")

    content.gsub!(ORGTAG, '\1')

    # EXTRACT search query from filename
    query  = filename.gsub(/\..{2,3}$/, '')
    title  = query.split(" by ").first.strip
    author = query.split(" by ").last.strip

    books =
      JSON.parse(Net::HTTP.get_response(
        URI("https://www.googleapis.com/books/v1/volumes?q=#{URI.encode(query)}")).body)

    # https://stackoverflow.com/questions/16323571/measure-the-distance-between-two-strings-with-ruby
    book = books["items"].min_by do |b|
      levenshtein_distance(b["volumeInfo"]["title"], title)
    end

    if book
      data.merge!(book["volumeInfo"])
      data["identifier"] = data["industryIdentifiers"][0]["identifier"]

      if data["categories"]
        data["categories"].map{ |t| tags.push(string_to_tag(t)) }
      end
    else
      data["title"]  = title
      data["author"] = author
    end

    data["tags"] = tags.join(", ")
    data["body"] = clean_body(content)

    # WRITE filename with new filename to a new folder
    if opts[:test]
      filename = "#{data["id"]}-#{clean_title("#{data["title"]} by #{mla_authors(data["authors"])}")}.md"
      puts "\n\n>> #{filename} <<\n"
      puts render(data)
    else
      IO.write(File.join(DST, filename), render(data))
    end
  end
end
