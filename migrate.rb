require 'date'
require 'uri'
require 'pry'
require 'set'

require_relative "./find_duplicate_ids"
require_relative "./migrate_booknotes"
require_relative "./migrate_devotionals"
require_relative "./migrate_diary"
require_relative "./migrate_links"
require_relative "./migrate_notes"

DST        = "./migrated"
ORGTAG     = /:([a-zA-Z\-_]+)/
UNIQUE_IDS = Set.new

# takes a datetime object and puts out the 14 character ZK id
def id(datetime)
  id = datetime.strftime("%Y%m%d%H%M%S")

  while UNIQUE_IDS.include? id
    id = (id.to_i + 1).to_s
  end

  UNIQUE_IDS << id
  return id
end

# takes a string, cleans it up.
def clean_title(string)
  string
    .downcase
    .gsub(/[^a-zA-Z0-9\-]/, "-")
    .gsub(/-{2,}/, '-')
    .split('-')
    .take(10)
    .join('-')
end

def extract_link(string)
  URI.extract(string)
    .filter{|url| url =~ /\A#{URI::regexp(['http', 'https'])}\z/}
    .first
end

# cleans a string and turns it into a 1Writer friendly hashtag
def string_to_tag(str)
  str
    .gsub(/[^a-zA-Z_]/, '_')
    .gsub(/_{2,}/, '_')
    .downcase
    .prepend('#')
end

def crawl(src)
  Dir.glob("#{src}**/*.{md,txt}")
end

# Clean the folder
Dir.each_child(DST){ |f| File.delete(File.join(DST, f)) }

puts "booknotes..."
booknotes()
puts "devotionals..."
devotionals()
puts "diary..."
diary()
puts "links..."
links()
puts "notes..."
notes()

puts "Finding duplicates... we need to get this to zero"
puts "================================================="
find_duplicate_ids()
