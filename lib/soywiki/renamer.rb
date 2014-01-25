module Soywiki
  class Renamer
    attr_reader :repo_path, :old_name, :new_name
    attr_reader :memo

    include PathHelper

    def initialize(repo_path, old_name, new_name)
      @repo_path = ensure_path(repo_path)
      @old_path = ensure_path(old_name)
      @new_path = ensure_path(new_name)
      @old_name = repo_relative(@old_path).to_s
      @new_name = repo_relative(@new_path).to_s
      @memo = ["Updating inbound and outbound links..."]
    end

    def namespace(query=nil)
      self.instance_variable_get("@#{query}_name").namespace
    rescue
      nil
    end

    def page_title(query=nil)
      self.instance_variable_get("@#{query}_name").to_page_title
    rescue
      nil
    end

    def short_page_title(query=nil)
      self.instance_variable_get("@#{query}_name").short_page_title
    rescue
      nil
    end

    def report(file, oldname, newname)
      @memo <<  "  - In #{file}: #{oldname} -> #{newname}"
    end

    def memorize(message)
      @memo ||= []
      @memo << message if message.is_a?(String)
      @memo += message if message.is_a?(Array)
      message
    end

    def print_report
      puts @memo.join("\n")
    end

    def grep_for_files(search, where, ignore=/(\.swp|\.swo)$/)
      cmd = "grep -rlF '#{search}' #{where}"
      puts cmd
      files = `#{cmd}`.strip.split(/\n/)
      ignore ? files.select { |f| f !~ ignore } : files
    end

    def change_all_absolute_links
      memorize "- Updating all absolute links"
      grep_for_files(page_title(:old), repo_path).each do |file|
        text = File.read(file)
        begin
          regex = /\b#{page_title(:old)}\b/
          matches = text.scan(regex)
          text = text.gsub(regex, page_title(:new))
          File.open(file, 'w') {|f| f.puts text}
          report file, page_title(:old), page_title(:new)
        rescue
          puts "Error processing #{file}: #$!"
        end
      end
    end

    def change_unqualified_inbound_links_in_same_namespace
      memorize "- Updating unqualified inbound links"
      grep_for_files(short_page_title(:old), in_repo(namespace(:old))).each do |file|
        text = File.read(file)
        begin
          text = text.gsub(/(\A|\s)(#{short_page_title(:old)}\b)/, '\1' + page_title(:new))
          File.open(file, 'w') {|f| f.puts text}
          report file, short_page_title(:old), new_name
        rescue
          puts "Error processing #{file}: #$!"
        end
      end
    end

    RELATIVE_LINK_REGEX = /(\A|\s)([A-Z][a-z]+[A-Z0-9]\w*)/

    def absolutize_unqualified_outbound_links
      memorize "Absolutizing unqualified inbound links"
      target_file = ensure_path(in_repo(new_name).to_s.to_file_path)
      if target_file.exist?
        text = target_file.read
        begin
          matches = text.scan(RELATIVE_LINK_REGEX).map {|x| x[1]}.
            select {|match| match.strip != "" }.
            select {|match| in_repo("#{namespace(:old)}/#{match}").exist? }
          puts memorize("  - In file #{target_file}: matches: #{matches.inspect}")

          text = text.gsub(RELATIVE_LINK_REGEX) do |match|
            if matches.include?($2)
              res = "#$1#{namespace(:old)}.#{$2}"
              memorize "  - In file #{target_file}: #{$2} -> #{res.strip}"
              res
            else
              memorize  "  - In file #{target_file}: skipping #{$2}"
              match
            end
          end
          File.open(target_file, 'w') {|f| f.puts text}
        rescue
          puts "Error processing #{target_file}: #$!"
        end
      end
    end

    def rename
      # Three other cases to cover, involving namespaces:
      #
      # Case 1: newname is in same namespace as oldname
      #
      # In the directory for OldName's namespace, change all unqualified references to
      # OldName to NewName

      if namespace(:old) == namespace(:new)
        memorize "- Updating unqualified links in same namespace"
        grep_for_files(short_page_title(:old), in_repo(namespace(:old))).each do |file|
          text = File.read(file)
          begin
            text = text.gsub(/(\A|\s)(#{short_page_title(:old)})\b/, '\1' + short_page_title(:new))
            File.open(file, 'w') {|f| f.puts text}
            report file, short_page_title(:old), short_page_title(:new)
          rescue
            puts "Error processing #{file}: #$!"
          end
        end
        # Case 2: newname is in different namespace from oldname
        # oldname.namespace != newname.namespace
      else
        # In the directory for OldName's namespace, change all unqualified references to
        # OldName to newnamespace.NewName (i.e. NewName).
        change_unqualified_inbound_links_in_same_namespace
        # And in the renamed file, change all unqualified references to
        # PageName to oldnamespace.PageName
        absolutize_unqualified_outbound_links
      end

      # Finally,
      change_all_absolute_links
    end

  end
end
