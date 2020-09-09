class Zettel
  attr_accessor(:meta, :body)

  def render
    %{
---
#{render_metadata}
---

#{@body}
    }.strip
  end

  def tags
    @tags.join(", ")
  end

  def meta(var)
    %{
#{var}: #{@meta[var]}
    }.strip
  end

  def title
    meta(:title)
  end

  def tags
    "tags: " + @meta[:tags].map{|s| "##{s.gsub('#', '')}"}.join(', ')
  end

  def id
    meta(:id)
  end

  def other
    @meta.reject{|key, _value| [:title, :tags, :id].include? key }.map do |k, v|
      meta(k)
    end.join("\n")
  end

  def render_metadata
    %{
#{title}
#{tags}
#{id}
#{other}
    }.strip
  end
end
