class Zettel
  attr_accessor(:body)

  def initialize()
    @meta = Hash.new
    @body = ""
  end

  def set(key, var)
    @meta[key.to_sym] = var
  end

  def get(var)
    @meta[var]
  end

  def render
    %{
---
#{render_metadata}
---

#{@body}
    }.strip
  end

  def render_meta(var)
    %{
#{var}: #{get(var)}
    }.strip
  end

  def title
    get(:title)
  end

  def render_title
    render_meta(:title)
  end

  def keywords
    if @meta[:keywords]
      @meta[:keywords].map{|s| "\n  - ##{s.gsub('#', '')}"}.join()
    else
      ""
    end
  end

  def render_keywords
    "keywords: " + keywords()
  end

  def id
    get(:id)
  end

  def render_id
    render_meta(:id)
  end

  def render_other
    @meta.reject{|key, _value| [:title, :keywords, :id].include? key }.map do |k, v|
      render_meta(k)
    end.join("\n")
  end

  def slugify(str)
    str
    .downcase
    .gsub(/[^a-zA-Z0-9\-]/, "-")
    .gsub(/-{2,}/, '-')
    .split('-')
    .take(10)
    .join('-')
  end

  def render_filename
    "#{id}-#{slugify(title)}.md"
  end

  def render_metadata
    %{
#{render_title}
#{render_keywords}
#{render_id}
#{render_other}
    }.strip
  end
end
