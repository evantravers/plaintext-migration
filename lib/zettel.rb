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
    ['---', render_metadata(), '---', "", @body]
      .compact
      .join("\n")
  end

  def render_meta(var) "#{var}: #{get(var)}" end

  def title
    get(:title)
  end

  def render_title
    render_meta(:title)
  end

  def render_aliases
    if @meta[:title] then
      "aliases: [\"#{@meta[:title]}\"]"
    end
  end

  def keywords
    if @meta[:keywords]
      "tags: " + @meta[:keywords].map{|s| "##{s.gsub('#', '')}"}.to_s
    end
  end

  def render_keywords
    keywords()
  end

  def id
    get(:id)
  end

  def render_id
    render_meta(:id)
  end

  def render_other
    meta =
      @meta
      .reject{|key, _value| [:title, :keywords, :id].include? key }
      .filter{|_k, v| v}
      .map {|k, _v| render_meta(k)}
      .join("\n")

    if meta == ""
      return nil
    else
      return meta
    end
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
    [render_title(), render_aliases(), render_keywords(), render_id(), render_other()]
      .compact
      .join("\n")
  end
end
