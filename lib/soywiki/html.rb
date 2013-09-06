require 'haml'
require 'rdiscount'
module Soywiki
  module Html
    include Template_Substitution

    HTML_DIR = 'html-export'
    INDEX_PAGE_TEMPLATE = File.read(File.join(File.dirname(__FILE__), '..', 'index_template.html.haml'))
    BROKEN_MARKDOWN_HYPERLINK = %r|\[([^\]]+)\]\(\[(#{HYPERLINK})\]\(\2\)\)|
    @current_namespace = nil

    def self.href_wiki_links(text)
      text = text.gsub(WIKI_WORD) {|match|
        href = if match =~ /\w\./ # namespace
          "../#{match.gsub(".", "/")}.html"
        else
          match + '.html'
        end
        %{<a href="#{href}">#{match}</a>}
      }
      return text
    end

    def self.href_hyperlinks(text)
      substitute = if @markdown then '[\\0](\\0)' else '<a href="\\0">\\0</a>' end
      text = text.gsub(HYPERLINK, substitute)
      if @markdown
        text = text.gsub(BROKEN_MARKDOWN_HYPERLINK, '[\\1](\\2)')
      end
      text = text.gsub(HYPERLINK) { |uri| soyfile_to_uri(uri) }
      return text
    end

    def self.soyfile_to_uri(uri)
      uri_after_scheme = %r{[^ >)\n\]]+}
      if uri =~ %r{^soyfile://(#{uri_after_scheme})}
        path = choose_soyfile_path($1)
        return "file://#{path}" if path[0] == '/'
      else
        return uri
      end
    end

    def self.choose_soyfile_path(path)
      return path if path[0] == '/'
      wiki_root = Dir.getwd
      autochdir_path = File.absolute_path(
        File.join(wiki_root, @current_namespace, path))
      wiki_path = File.absolute_path(File.join(wiki_root, path))
      File.exists?(autochdir_path) ? autochdir_path : wiki_path
    end

    def self.process(t)
      href_hyperlinks(href_wiki_links(t))
    end

    PAGE_TEMPLATE = File.read(File.join(File.dirname(__FILE__), '..', 'page_template.html.haml'))
    def self.generate_page(text, namespace, pages, namespaces)
      @current_namespace = namespace
      text = text.split("\n")

      title = text.shift || ''
      body = ''
      if not text.empty?
        body = self.process(text.join("\n").strip)
        if @markdown
             body = RDiscount.new(body).to_html.gsub("<pre><code>","<pre><code>\n") 
        end
      end

      page_template = if defined?(PAGE_TEMPLATE_SUB)
                        PAGE_TEMPLATE_SUB
                      else
                        PAGE_TEMPLATE
                      end
      Haml::Engine.new(page_template).render(nil, :body => body,
                                             :title => title,
                                             :namespace => namespace,
                                             :namespaces => namespaces,
                                             :pages => pages,
                                             :markdown => @markdown)
    end



    def self.wiki_page?(file)
      file.gsub("/", '.') =~ WIKI_WORD
    end

    def self.make_index_page(dir, pages, namespaces)
      index_page_template = if defined?(INDEX_PAGE_TEMPLATE_SUB)
                              INDEX_PAGE_TEMPLATE_SUB
                            else
                              INDEX_PAGE_TEMPLATE
                            end
      outfile = File.join(HTML_DIR, dir, 'index.html')
      html = Haml::Engine.new(index_page_template).render(nil, 
                                             :namespace => dir, 
                                             :root => false,
                                             :pages => pages.map {|p| p.split('/')[1]}.sort, 
                                             :namespaces => namespaces)
      File.open(outfile, 'w') {|f| f.write html}
      # puts "=> Writing #{outfile}"
    end

    def self.make_pages(dir, namespaces)
      `mkdir -p #{HTML_DIR}/#{dir}`
      pages = Dir["#{dir}/*"].select {|file| wiki_page? file} 
      # make pages
      pages.each do |file|
        outfile =  File.join(HTML_DIR, file + '.html')
        html = Soywiki::Html.generate_page(File.read(file), 
                                           dir, 
                                           pages.map {|p| p.split('/')[1]}.sort, 
                                           namespaces)
        File.open(outfile, 'w') {|f| f.write html}
        # puts "Writing #{outfile}"
      end
      make_index_page(dir, pages, namespaces)
    end

    def self.make_root_index_page(namespaces)
      outfile = File.join(HTML_DIR, 'index.html')
      index_page_template = if defined?(INDEX_PAGE_TEMPLATE_SUB)
                              INDEX_PAGE_TEMPLATE_SUB
                            else
                              INDEX_PAGE_TEMPLATE
                            end
      html = Haml::Engine.new(index_page_template).render(nil, 
                                             :namespace => nil, 
                                             :pages => [], 
                                             :root => true,
                                             :namespaces => namespaces)
      File.open(outfile, 'w') {|f| f.write html}
      # puts "=> Writing #{outfile}"
    end

    def self.export(markdown)
      @markdown = markdown

      `rm -rf #{HTML_DIR}/*`
      namespaces = Dir["*"].select {|f| 
        File.directory?(f) && f != HTML_DIR
      }.sort.map {|namespace|
        count = Dir["#{namespace}/*"].select {|f| wiki_page?(f)}.size
        [namespace, count]
      }
      @current_namespace = nil
      namespaces.each do |namespace_dir, count|
        make_pages namespace_dir, namespaces
      end
      # make root index page
      make_root_index_page namespaces
      @current_namespace = nil
      puts "HTML files written to #{HTML_DIR}/"
    end


  end
end

