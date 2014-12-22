require 'haml'
require 'rdiscount'
module Soywiki
  class Html
    HTML_DIR = 'html-export'
    INDEX_PAGE_TEMPLATE = File.read(File.join(File.dirname(__FILE__), '..', 'index_template.html.haml'))
    BROKEN_MARKDOWN_HYPERLINK = %r|\[([^\]]+)\]\(\[(#{HYPERLINK})\]\(\2\)\)|
    PAGE_TEMPLATE = File.read(File.join(File.dirname(__FILE__), '..', 'page_template.html.haml'))

    include Template_Substitution

    attr_reader :markdown, :relative_soyfile, :current_namespace

    def self.export(markdown, relative_soyfile)
      new(markdown, relative_soyfile).export
    end

    def initialize(markdown, relative_soyfile)
      @markdown = markdown
      @relative_soyfile = relative_soyfile
    end

    def export
      clear_html_dir
      @current_namespace = nil
      namespaces.each do |namespace, _count|
        make_pages(namespace)
      end
      make_root_index_page(namespaces)
      @current_namespace = nil
      puts "HTML files written to #{HTML_DIR}/"
    end

    def clear_html_dir
      `rm -rf #{HTML_DIR}/*`
    end

    def namespaces
      @namespaces ||= Dir["*"].select do |file|
        File.directory?(file) && file != HTML_DIR
      end.sort.map do |namespace|
        count = Dir["#{namespace}/*"].select { |f| wiki_page?(f) }.size
        [namespace, count]
      end
    end

    def wiki_page?(file)
      file.gsub("/", '.') =~ WIKI_WORD
    end

    def make_pages(namespace)
      `mkdir -p #{HTML_DIR}/#{namespace}`
      pages = wiki_pages(namespace)
      inner_pages = pages.map { |p| p.split('/')[1] }.sort
      pages.each do |file|
        outfile =  File.join(HTML_DIR, file + '.html')
        html = generate_page(File.read(file), namespace, inner_pages)
        File.open(outfile, 'w') { |f| f.write(html) }
      end
      make_index_page(namespace, inner_pages)
    end

    def wiki_pages(namespace)
      Dir["#{namespace}/*"].select { |file| wiki_page?(file) }
    end

    def generate_page(text, namespace, pages)
      @current_namespace = namespace
      text = text.split("\n")

      title = text.shift || ''
      body = ''
      unless text.empty?
        body = process(text.join("\n").strip)
        body = markdownify(body) if markdown
      end

      Haml::Engine.new(page_template).
        render(nil, :body => body,
               :title => title,
               :namespace => namespace,
               :namespaces => namespaces,
               :pages => pages,
               :markdown => markdown)
    end

    def process(text)
      href_hyperlinks(href_wiki_links(text))
    end

    def href_wiki_links(text)
      text.gsub(WIKI_WORD) do |match|
        href =
          if match =~ /\w\./ # namespace
            "../#{match.gsub(".", "/")}.html"
          else
            match + '.html'
          end
        %{<a href="#{href}">#{match}</a>}
      end
    end

    def href_hyperlinks(text)
      substitute =
        if markdown
          '[\\0](\\0)'
        else
          '<a href="\\0">\\0</a>'
        end
      text = text.gsub(HYPERLINK, substitute)
      if markdown
        text = text.gsub(BROKEN_MARKDOWN_HYPERLINK, '[\\1](\\2)')
      end
      text.gsub(HYPERLINK) { |uri| soyfile_to_href(uri) }
    end

    def soyfile_to_href(uri)
      match = soyfile_match(uri)
      if match
        path = choose_soyfile_path(match[1])
        path[0] == '/' ? "file://#{path}" : path
      else
        uri
      end
    end

    def soyfile_match(uri)
      uri_after_scheme = %r{[^ >)\n\]]+}
      regex = %r{^soyfile://(#{uri_after_scheme})}
      uri.match(regex)
    end

    def choose_soyfile_path(path)
      absolute_path = absolute_soyfile_path(path)
      if relative_soyfile
        Pathname.new(absolute_path).
          relative_path_from(Pathname.new(wiki_root)).to_s
      else
        absolute_path
      end
    end

    def absolute_soyfile_path(path)
      return path if path[0] == '/'
      autochdir_path = absolutify("#{current_namespace}/#{path}")
      wiki_path = absolutify(path)
      File.exists?(autochdir_path) ? autochdir_path : wiki_path
    end

    def absolutify(path)
      File.absolute_path(File.join(wiki_root, path))
    end

    def wiki_root
      Dir.getwd
    end

    def markdownify(text)
      RDiscount.new(text).to_html.gsub("<pre><code>", "<pre><code>\n")
    end

    def page_template
      if defined?(PAGE_TEMPLATE_SUB)
        PAGE_TEMPLATE_SUB
      else
        PAGE_TEMPLATE
      end
    end

    def make_index_page(namespace, inner_pages)
      outfile = File.join(HTML_DIR, namespace, 'index.html')
      html = Haml::Engine.new(index_page_template).
        render(nil, :namespace => namespace,
               :root => false,
               :pages => inner_pages,
               :namespaces => namespaces)
      File.open(outfile, 'w') { |f| f.write(html) }
    end

    def index_page_template
      if defined?(INDEX_PAGE_TEMPLATE_SUB)
        INDEX_PAGE_TEMPLATE_SUB
      else
        INDEX_PAGE_TEMPLATE
      end
    end

    def make_root_index_page(namespaces)
      outfile = File.join(HTML_DIR, 'index.html')
      html = Haml::Engine.new(index_page_template).
        render(nil, :namespace => nil,
               :pages => [],
               :root => true,
               :namespaces => namespaces)
      File.open(outfile, 'w') { |f| f.write(html) }
    end
  end
end

