# I thought I had it all figured out... but I was wrong.
# This is a lot more complicated than I thought.

require 'date'

history = Hash.new

Dir.glob("**/*.{txt,md}") do |file|
  if File.dirname(file).include? "migrated"
    filename = File.basename(file)
    id       = filename.scan(/\d{14}/)[0]

    if history.member? id
      puts "⚠ #{filename} has duplicate IDs in:\n#{history[id].join("\n")}\n\n"
    else
      if history[id]
        history[id] << filename
      else
        history[id] = [filename]
      end
    end
  end
end
