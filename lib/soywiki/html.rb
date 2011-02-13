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

    def self.generate(text)
      title = text.split("\n")[0]
      body = process(text.split("\n")[1..-1].join("\n").strip)
      template = File.read(File.join(File.dirname(__FILE__), '..', 'export_template.html.haml'))
      Haml::Engine.new(template).render(nil, :body => body, :title => title)
    end

    # index.html has a list of all the pages
    def self.index_page
    end

    # make an index.html for each subdir?
    # Or use main?

    # TODO put sidebar with basic nav
    
    def self.export
      target_dir = "html"
      `mkdir -p #{target_dir}`
      `rm -rf #{target_dir}/*`
      Dir["*/*"].each do |file|
        next if file =~ /^html\//
        if file.gsub("/", '.') =~ WIKI_WORD
          subdir = target_dir + '/' + file.split('/')[0]
          `mkdir -p #{subdir}`
          outfile =  target_dir + '/' + file + '.html'
          html = Soywiki::Html.generate( File.read(file) )
          File.open(outfile, 'w') {|f| f.write html}
          puts "Writing #{outfile}"
        end
      end

    end


  end
end

