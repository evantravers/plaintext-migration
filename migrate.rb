require './lib/zettel'

# Writing some tests
z = Zettel.new
z.set('id', '20200998955')
z.set('title', 'This is a test of a note')
z.set('tags', ['tag1', 'tag2', '#tag3'])
z.set('isbn', '0192u319231098')
z.body = "Call me Ishmael"

puts "<< #{z.render_filename} >>"
puts z.render

# Pull in each source
# Build Zettel objects
