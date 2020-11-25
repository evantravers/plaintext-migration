require './lib/zettel'
require 'set'
require 'net/http'
require 'json'
require 'date'
require 'rubygems/text'

include Gem::Text

class Migrator
  DST = '../../wiki/'

  def initialize
    @unique_ids = Set.new
  end

  def file_crawl(src)
    search_path = "#{src}**/*.{md,txt}"
    count = Dir.glob(search_path).count
    puts "## Working #{src}...\n#{Dir.glob(search_path).count} files in #{src}"
    Dir.glob(search_path).each_with_index do |file, index|
      puts "[#{index+1}/#{count}]: #{File.basename(file)...}"
      yield file
    end
  end

  def ensure_uniqueness(zettel)
    if @unique_ids.include? zettel.id then
      # we've got a dup
      puts "🔴 Duplicate ID! #{zettel.title}: #{zettel.id}"

      zettel.set(:id, zettel.id.to_i + 1)
      puts "trying #{zettel.id}..."
      self.ensure_uniqueness(zettel)
    else
      if zettel.id.size > 12 then
        puts "#{zettel.id} 🟡 ID is too long! #{zettel.title}"
      elsif zettel.id.size < 12 then
        puts "#{zettel.id} 🟡 ID is too short! #{zettel.title}"
      end
      @unique_ids << zettel.id
    end
  end

  def old_zettel()
    file_crawl('../zk/') do |old_zettel|
      zettel = Zettel.new()
      content = File.read(old_zettel)

      if content.match(/^\w+: .+$/) then
        metadata, *content = content.split(/\n\n/)

        if content.class == Array then
          content = content.join("\n\n")
        end

        metadata
          .split(/\n/)
          .map{|metadata|
            key, value = metadata.scan(/^(\w+): (.*)$/).flatten
            if key == 'tags' then
              key = 'keywords'
              value = value.split(', ')
            end
            zettel.set(key, value)
          }
      end
      if !zettel.id then
        # try in the filename?
        zettel.set('id', old_zettel.scan(/\d{12}-/)[0].gsub('-', ''))
      end

      if !zettel.title then
        title, *content = content.split(/\n/)
        title = title.gsub(/^#+ /, '')
        zettel.set(:title, title)
        content = content.join("\n")
      end

      zettel.body = content

      self.ensure_uniqueness(zettel)

      File.write("#{DST}/#{zettel.render_filename()}", zettel.render())
    end
  end

  def books()
    file_crawl('../booknotes/') do |booknote|
      unless
        [
          /The War of Art/, # already has a note
          /You and Me Forever/,
          /Fall/,
          /Deep Work/,
          /Your Family God's Way/
        ].any?{|pattern| booknote.match? pattern } # blocklist
      then
        filename = File.basename(booknote)
        zettel = Zettel.new()
        content = File.read(booknote)

        title, *content = content.split(/\n/)
        title   = title.gsub(/^#+ /, '')
        content = content.join("\n")

        zettel.set(:keywords, ['booknote', 'book'])

        zettel.body = content.strip

        query  = filename.gsub(/\..{2,3}$/, '')
        title  = query.split(" by ").first.strip
        author = query.split(" by ").last.strip

        begin
          date = Date.parse(content)
        rescue StandardError
          date = File.birthtime(booknote)
        end

        books =
          JSON.parse(Net::HTTP.get_response(
            URI("https://www.googleapis.com/books/v1/volumes?q=#{URI.encode(query)}")).body)

        book = books["items"].min_by do |b|
          levenshtein_distance(b["volumeInfo"]["title"], title)
        end["volumeInfo"]

        zettel.set(:date, date.strftime("%a, %e %b %Y %T"))
        zettel.set(:id, date.strftime("%Y%m%d%H%M").ljust(12, "0"))
        ensure_uniqueness(zettel)

        zettel.set(:title, title)
        zettel.set(:subtitle, book['subtitle'])
        zettel.set(:author, book['authors'].join(', ')) # close enough to MLA
        zettel.set(:publisher, book['publisher'])
        zettel.set(:identifer, book["industryIdentifiers"][0]["identifier"])

        File.write("#{DST}/#{zettel.render_filename()}", zettel.render())
      end
    end
  end

  def links()
    file_crawl('../links/') do |link|
      zettel = Zettel.new
      content = File.read(link)
      filename = File.basename(link)

      datestring =
        filename
          .scan(/\w+ \d+, \d\d\d\d/)
          .flatten
          .first

      # handle backwards filenames
      if datestring.nil? || datestring.empty? then
        date = File.birthtime(link)
      else
        date = DateTime.parse(datestring)
      end

      title = content.lines.reject{|l| l.match(/tags:.*/) || l.strip.empty? }.first.strip

      link = URI.extract(content)
        .filter{|url| url =~ /\A#{URI::regexp(['http', 'https'])}\z/}
        .first

      zettel.set(:id, date.strftime("%Y%m%d%H%M").ljust(12, "0"))
      zettel.set(:date, date.strftime("%a, %e %b %Y %T"))
      zettel.set(:keywords, ['link'])
      zettel.set(:title, title)

      content =
        content
          .gsub(/^#{title}$/, '')
          .gsub(/\w+ \d+, \d\d\d\d at \d\d:\d\d../, "")
          .gsub(/via Instapaper /, "")
          .gsub(/^#{URI.regexp}/m, "")
          .strip

      content = content + "\n\n[#{title}](#{link})"

      zettel.body = content.strip

      if opts[:test] then
        puts "<< #{zettel.render_filename()} >>"
        puts zettel.render()
      else
        File.write("#{DST}/#{zettel.render_filename()}", zettel.render())
      end
    end
  end

  def test
    # Writing some tests
    test = Zettel.new
    test.set('id', '20200998955')
    test.set('title', 'If you can read this...')
    test.set('keywords', ['tag1', 'tag2', '#tag3'])
    test.set('isbn', '0192u319231098')
    test.body = "Then the tests are working."

    puts "<< #{test.render_filename} >>"
    puts test.render
  end

  def run()
    # clean out the folder
    Dir.each_child(DST){ |f| File.delete(File.join(DST, f)) unless f.match("obsidian") }

    # Pull in each source:
    # - new zk
    old_zettel(test: testing)
    # - booknotes (include subfolders)
    books(test: testing)
    # - links
    links(test: testing)
    # - diary
    # diary = '../diary/'
    # - notes (include subfolders)
    # plaintext = '../notes/'
  end
end

migrator = Migrator.new()

migrator.run()
