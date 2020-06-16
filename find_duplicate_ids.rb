# I thought I had it all figured out... but I was wrong.
# This is a lot more complicated than I thought.

def find_duplicate_ids
  history = Hash.new

  Dir.glob("**/*.{txt,md}") do |file|
    if File.dirname(file).include? "migrated"
      filename = File.basename(file)
      id       = filename.scan(/^\d{12}-/)[0]

      if history.member? id
        puts "⚠ #{filename} has duplicate IDs in:\n#{history[id].join("\n")}\n\n---\n\n"
      end

      if history[id]
        history[id] << filename
      else
        history[id] = [filename]
      end
    end
  end
  count = history.keys.select{|k| history[k].size > 1}

  puts "You have #{count.size} with duplicates out of #{Dir.children(DST).size}."
end
