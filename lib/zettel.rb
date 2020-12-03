class Zettel
  attr_accessor(:body, :enable_alias)

  def initialize()
    @meta = Hash.new
    @enable_alias = false
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
    if @meta[:title] && @enable_alias then
      "aliases: [\"#{@meta[:title]}\"]"
    end
  end

  def add_tag(tag)
    if tag then # not nil
      tag = tag
            .gsub("#", "")
            .gsub(" ", "_")

      if
        !tag.match(/\d+-?/) && # not just a number
        tag.size > 1 # not a single character
      then

        # blacklist
        unless [
          '_',
          '19.1',
          'ls',
          'bn',
          'bp',
          'bd',
          'gdiff',
          'vimwiki_list',
          'p',
          '_p',
          '_d',
          '1-',
          '2-',
          '3-',
          'uab',
          'responsible',
          'setforlife',
          'todos_archived',
          'wizardsetupstep',
          'tags',
          'id',
          'create_tickets',
          'http',
          'before',
          'comment_tabpanel',
          'gblame',
          'first',
          'study',
          'calendar_UI',
          'donut_chat',
          'blackbox',
          'wizardchoosestep',
          'wcw',
          'usd',
          'ticket_work',
          'telegraph',
          'settings',
          'hover',
          'help',
          'guide',
          'knowledge_transfer',
          'formatting',
          'generate',
          'archive',
          'feature',
          'music',
          'fixme_link_missing',
          'active',
          'button',
          'cars',
          'draft',
          'fixme',
          'published',
          'read',
          'todo',
        ].include? tag then

          tag =
            case tag
            when 'link'
              'links'
            when 'pmux'
              'ux'
            when 'interview'
              'career'
            when 'project'
              'projects'
            when 'book'
              'books'
            when 'design_doc'
              'design'
            when 'business_economics'
              'economics'
            when 'christianlife'
              'christian_life'
            when 'code'
              'programming'
            when 'fallacy'
              'fallacies'
            when 'lesson'
              'sundayschool'
            when 'political'
              'politics'
            when 'scifi'
              'sciencefiction'
            when 'self_help'
              'selfhelp'
            when 'social_media'
              'socialmedia'
            else
              tag
            end

          if @meta[:tags] then
            @meta[:tags].push(tag)
          else
            @meta[:tags] = [tag]
          end
        end
      end
    end
  end

  def tags
    if @meta[:tags]
      "tags: " + @meta[:tags].map{|s| "##{s.gsub('#', '')}"}.to_s
    end
  end

  def render_tags
    tags()
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
      .reject{|key, _value| [:title, :tags, :id].include? key }
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
    [render_title(), render_aliases(), render_tags(), render_id(), render_other()]
      .compact
      .join("\n")
  end
end
