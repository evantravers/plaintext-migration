require './lib/zettel'
require 'set'

# Writing some tests
z = Zettel.new
z.set('id', '20200998955')
z.set('title', 'This is a test of a note')
z.set('keywords', ['tag1', 'tag2', '#tag3'])
z.set('isbn', '0192u319231098')
z.body = "Call me Ishmael..."

puts "<< #{z.render_filename} >>"
puts z.render

# Pull in each source:
# - new zk (seems to be split between two folders 😿 )
# - links
# - booknotes (include subfolders)
# - diary
# - notes (include subfolders)

# Build Zettel objects
#   For each one, ensure that it has a unique ID compared to the other ones

