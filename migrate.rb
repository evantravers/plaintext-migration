require './lib/zettel'
require 'set'

# Writing some tests
test = Zettel.new
test.set('id', '20200998955')
test.set('title', 'If you can read this...')
test.set('keywords', ['tag1', 'tag2', '#tag3'])
test.set('isbn', '0192u319231098')
test.body = "Then the tests are working."

puts "<< #{test.render_filename} >>"
puts test.render

class Migrator
  # links = '../links/'
  # books = '../booknotes/'
  # diary = '../diary/'
  # plaintext = '../notes/'

  # - new zk (seems to be split between two folders 😿 )
  # - links
  # - booknotes (include subfolders)
  # - diary
  # - notes (include subfolders)
  #
  # FOR EACH by folder:
  #   pull in each file
  #   build the Zettel object
  #   write it to the new folder
  #     IO.write('../../wiki/', zettel.render())

  # Build Zettel objects
  #   For each one, ensure that it has a unique ID compared to the other ones

  @unique_ids = Set.new
  DST = '../../wiki/'

  def self.file_crawl(src)
    Dir.glob("#{src}**/*.{md,txt}") do |file|
      yield file
    end
  end

  def self.old_zettel(opts = {test: true})
    file_crawl('../zk/') do |old_zettel|

      z = Zettel.new()
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
            z.set(key, value)
          }
      end
      if !z.id then
        # try in the filename?
        z.set('id', old_zettel.scan(/\d{12}-/)[0].gsub('-', ''))
      end

      if !z.title then
        title, *content = content.split(/\n/)
        title = title.gsub(/^#+ /, '')
        z.set(:title, title)
        content = content.join("\n")
      end

      z.body = content

      if opts[:test] then
        puts "<< #{z.render_filename()} >>"
        puts z.render()
      else
        File.write("#{DST}/#{z.render_filename()}", z.render())
      end
    end
  end

  def self.run(testing=false)
    # clean out the folder
    Dir.each_child(DST){ |f| File.delete(File.join(DST, f)) unless f.match("obsidian") }

    # Pull in each source:
    old_zettel(test: testing)
  end
end

Migrator.run()


