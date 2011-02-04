require 'couchrest'
class Zenwiki
  module Couch

    def view(view, params={})
      log "Getting view '#{view}'"
      res = DB.view view, params
      log res
      res
    end

    def find_or_create(doc)
      log "Looking up document: #{doc['_id']}"
      doc = DB.get(doc['_id']) # the url is the document id
      log "Found document: #{doc['_id']}"
      doc
    rescue RestClient::ResourceNotFound
      doc = doc.merge('updated_at' => Time.now.utc)
      response = DB.save_doc doc
      doc = DB.get response['id']
      log "Created document: #{doc.inspect}"
      doc
    end

    def create_or_update(new_doc)
      raise RestClient::ResourceNotFound if new_doc['_id'].nil?
      doc = DB.get(new_doc['_id']) # the url is the document id
      doc.update(new_doc)
      doc.save
      log "Updated document: #{doc.inspect}"
      doc
    rescue RestClient::ResourceNotFound
      find_or_create(new_doc)
    rescue
      log $!
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

