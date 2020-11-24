require './lib/zettel'
require 'set'

unique_ids = Set.new
DST = '../../wiki/'

def file_crawl(src)
  Dir.glob("#{src}**/*.{md,txt}") do |file|
    yield file
  end
end

def set_metadata(zettel, string)
  string
    .split(/\n/)
    .map{|metadata|
      key, value = metadata.split(': ')
      if key == 'tags' then
        key = 'keywords'
        value = value.split(', ')
      end
    }.each {|k, v|
      binding.pry
      puts k
      puts v
      zettel.set(k, v)
    }
end

# Writing some tests
test = Zettel.new
test.set('id', '20200998955')
test.set('title', 'This is a test of a note')
test.set('keywords', ['tag1', 'tag2', '#tag3'])
test.set('isbn', '0192u319231098')
test.body = "Call me Ishmael..."

puts "<< #{test.render_filename} >>"
puts test.render

# clean out the folder
Dir.each_child(DST){ |f| File.delete(File.join(DST, f)) unless f.match("obsidian") }

# Pull in each source:
def old_zettel(opts = {test: :true})
  file_crawl('../zk/') do |old_zettel|
    z = Zettel.new()
    content = File.read(old_zettel)

    if content.match(/^\w+: \w+$/) then
      metadata, *content = content.split(/\n\n/)

      if content.class == Array then
        content = content.join("\n\n")
      end

      metadata
        .split(/\n/)
        .map{|metadata|
          key, value = metadata.split(': ')
          if key == 'tags' then
            key = 'keywords'
            value = value.split(', ')
          end
          z.set(key, value)
        }
    end

    if !z.id then
      # try in the filename?
      z.set('id', old_zettel.scan(/^\d{12}-/)[0])
    end

    if !z.title then
      title, *content = content.split(/\n/)
      z.set(:title, title)
      content = content.join("\n")
    end

    z.body = content

    puts "<< #{z.render_filename()} >>"
    puts z.render()
  end
end

links = '../links/'
books = '../booknotes/'
diary = '../diary/'
plaintext = '../notes/'

# - new zk (seems to be split between two folders 😿 )
old_zettel()
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

