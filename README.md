# Migrating my vimwiki to zettelkasten

You probably should not use this as anything but inspiration.

I am actively chasing a "perfect format" for plain text markdown based zettelkasten notes, which I've dubbed [simple markdown zettelkasten](http://evantravers.com/articles/series/simple-markdown-zettelkasten/). This repo is the transformation script that I used to turn ten years of different plaintext note taking formats into zettelkasten format.

Things That I'd Have to Extract/Transform for ZK

## Transformations

- [x] Devotional Notes
- [x] `/notes/`
- [x] Diary
- [x] Booknotes
- [x] Links

I'm writing ruby scripts for each, each dumps copies of the changed files into a "migrated" folder.

I'll just open them up in buffers… if I think it's worth bringing into the zettelkasten, I'll run `:bd`, otherwise I'll run `:Delete` to remove the file.

In the end, ZK means "one thought, one note." Many of these are going to need to be "extracted" into separate thoughts.
