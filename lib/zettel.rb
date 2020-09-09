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
    meta(:title)
  end

  def render_title
    render_meta(:title)
  end

  def tags
    @meta[:tags].map{|s| "\n  - ##{s.gsub('#', '')}"}.join("")
  end

  def render_tags
    "tags: " + tags()
  end

  def id
    meta(:id)
  end

  def render_id
    render_meta(:id)
  end

  def render_other
    @meta.reject{|key, _value| [:title, :tags, :id].include? key }.map do |k, v|
      render_meta(k)
    end.join("\n")
  end

  def render_metadata
    %{
#{render_title}
#{render_tags}
#{render_id}
#{render_other}
    }.strip
  end
end
