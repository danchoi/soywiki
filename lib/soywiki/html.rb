require 'haml'
module Soywiki
  module Html

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
      text = text.gsub(HYPERLINK) {|match|
        %{<a href="#{match}">#{match}</a>}
      }
      return text
    end

    def self.process(t)
      href_hyperlinks(href_wiki_links(t))
    end

    PAGE_TEMPLATE = File.read(File.join(File.dirname(__FILE__), '..', 'page_template.html.haml'))

    def self.generate_page(text, namespace, pages, namespaces)
      title = text.split("\n")[0]
      body = process(text.split("\n")[1..-1].join("\n").strip)
      Haml::Engine.new(PAGE_TEMPLATE).render(nil, :body => body, 
                                             :title => title, 
                                             :namespace => namespace,
                                             :namespaces => namespaces, :pages => pages)
    end


    HTML_DIR = 'soywiki-html-export'
    INDEX_PAGE_TEMPLATE = File.read(File.join(File.dirname(__FILE__), '..', 'index_template.html.haml'))

    def self.wiki_page?(file)
      file.gsub("/", '.') =~ WIKI_WORD
    end

    def self.make_index_page(dir, pages, namespaces)
      outfile = File.join(HTML_DIR, dir, 'index.html')
      html = Haml::Engine.new(INDEX_PAGE_TEMPLATE).render(nil, 
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
      html = Haml::Engine.new(INDEX_PAGE_TEMPLATE).render(nil, 
                                             :namespace => nil, 
                                             :pages => [], 
                                             :root => true,
                                             :namespaces => namespaces)
      File.open(outfile, 'w') {|f| f.write html}
      # puts "=> Writing #{outfile}"
    end

    def self.export
      `rm -rf #{HTML_DIR}/*`
      namespaces = Dir["*"].select {|f| 
        File.directory?(f) && f != HTML_DIR
      }.sort.map {|namespace|
        count = Dir["#{namespace}/*"].select {|f| wiki_page?(f)}.size
        [namespace, count]
      }
      namespaces.each do |namespace_dir, count|
        make_pages namespace_dir, namespaces
      end
      # make root index page
      make_root_index_page namespaces
      puts "HTML files written to #{HTML_DIR}/"
    end


  end
end

