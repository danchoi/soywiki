require 'couchrest'
class Zenwiki
  class Couch

    class << self
      def find_or_create(doc)
        $stderr.puts "Looking up document: #{doc['_id']}"
        doc = DB.get(doc['_id']) # the url is the document id
        $stderr.puts "Found document: #{doc['_id']}"
        doc
      rescue RestClient::ResourceNotFound
        response = DB.save_doc doc
        doc = DB.get response['id']
        $stderr.puts "Created document: #{doc.inspect}"
        doc
      end

      def create_or_update(doc)
        raise RestClient::ResourceNotFound if doc['_id'].nil?
        doc = DB.get(doc['_id']) # the url is the document id
        doc = doc.update(doc)
        $stderr.puts "Updated document: #{doc['_id']}"
        doc.save
        doc
      rescue RestClient::ResourceNotFound
        find_or_create(doc)
      end

      def get_html_attachment(doc)
        attachment = DB.fetch_attachment(doc, 'page.html')
      rescue RestClient::ResourceNotFound
        nil
      end

      def get(feed_url)
        DB.get feed_url
      end
    end
  end
end

