# frozen_string_literal: true

class DocsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def api
    # List available API documentation languages
    @languages = %w[shell ruby python javascript typescript nodejs php go java csharp]
    @selected_language = params[:language] || 'shell'

    doc_path = Rails.root.join('docs', 'api', "#{@selected_language}.md")

    if File.exist?(doc_path)
      @content = File.read(doc_path)
      # Convert markdown to HTML
      @content_html = render_markdown(@content)
    else
      @content = "Documentation not found for #{@selected_language}"
      @content_html = "<p>#{@content}</p>"
    end

    render 'docs/api'
  end

  private

  def render_markdown(text)
    # Simple markdown-like rendering
    html = text.dup

    # Normalize line endings to Unix style
    html = html.gsub(/\r\n/, "\n")

    # Code blocks with language - use a placeholder to protect them
    code_blocks = []
    html = html.gsub(/```(\w+)?\n(.*?)```/m) do
      lang = Regexp.last_match(1)
      code = Regexp.last_match(2)
      placeholder = "\n\n___CODE_BLOCK_#{code_blocks.length}___\n\n"
      code_blocks << "<div class='rounded-lg p-4 my-4 overflow-x-auto' style='background-color: #1a1a2e; color: #e0e0e0;'><pre class='text-sm'><code>#{ERB::Util.html_escape(code)}</code></pre></div>"
      placeholder
    end

    # Headers (handle with potential \r\n)
    html = html.gsub(/^### (.+?)$/, '<h3 class="text-2xl font-bold mt-6 mb-3">\1</h3>')
    html = html.gsub(/^## (.+?)$/, '<h2 class="text-3xl font-bold mt-8 mb-4">\1</h2>')
    html = html.gsub(/^# (.+?)$/, '<h1 class="text-4xl font-bold mt-8 mb-4">\1</h1>')

    # Bold
    html = html.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')

    # Inline code (but not code block markers)
    html = html.gsub(/`([^`\n]+)`/, '<code class="bg-base-300 px-1 py-0.5 rounded text-sm">\1</code>')

    # Links
    html = html.gsub(/\[([^\]]+)\]\(([^)]+)\)/, '<a href="\2" class="link link-primary">\1</a>')

    # Paragraphs - split by double newlines
    paragraphs = html.split(/\n\n+/)
    html = paragraphs.map do |para|
      para = para.strip
      # Skip already processed HTML elements and code block placeholders
      next para if para.match?(/^</) || para.match?(/^___CODE_BLOCK_\d+___$/)
      next '' if para.empty?

      "<p class='mb-4'>#{para.gsub(/\n/, ' ')}</p>"
    end.compact.join("\n\n")

    # Restore code blocks
    code_blocks.each_with_index do |block, index|
      html = html.gsub("___CODE_BLOCK_#{index}___", block)
    end

    html
  end
end
