require 'liquid'
require 'rdiscount'

module Webpage
  def self.generate(version)
    screenshots = RDiscount.new(File.read("top.screenshots")).to_html
    readme = File.expand_path("../../README.markdown", __FILE__)
    raise "no README" unless File.size?(readme)
    md = File.read(readme).split(/^\s*$/)
    insert_before = md.grep(/^A quick overview of/)
    insert_at = md.index insert_before.first
    md.insert(insert_at, screenshots) 
    md = md.join("\n\n")
    # for some reason markdown inserts extra blank lines
    content = RDiscount.new(md).to_html.gsub(/\n\n{3,}/, "\n\n")
    template = File.read("soywiki-template.html")
    out = Liquid::Template.parse(template).render 'content' => content, 'timestamp' => Time.now.to_i, 'version' => version
  end
end
