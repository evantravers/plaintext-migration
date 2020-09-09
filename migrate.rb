require './lib/zettel'

z = Zettel.new
z.meta = {
  id: '2020098102240',
  title: 'This is a test of a note',
  tags: ['tag1', 'tag2', '#tag3'],
  isbn: '0192u319231098'
}
z.body = "Call me Ishmael"

puts z.render
