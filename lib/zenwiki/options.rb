require 'optparse'

module Zenwiki
  class Options

    attr_accessor :config

    def initialize(argv)
      # config_file_locations = ['.zenwikirc', "#{ENV['HOME']}/.zenwikirc"]
      @config = {}
      parse argv
    end

    def parse(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage:  zenwiki" 
        opts.separator ""
        opts.separator "Specific options:"
        opts.on("-v", "--version", "Show version") do
          puts "zenwiki #{Zenwiki::VERSION}\nCopyright 2011 Daniel Choi under the MIT license"
          exit
        end
        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end
        opts.separator ""
        opts.separator INSTRUCTIONS

        rescue OptionParser::ParseError => e
          STDERR.puts e.message, "\n", opts
        end

      end
    end
  end

  INSTRUCTIONS = <<-EOF
Please visit http://danielchoi.com/software/zenwiki.html for instructions
on how to use zenwiki.

  EOF
end
