require 'couchrest'
require 'zenwiki/couch'

class Zenwiki
  DB = CouchRest.database!("http://127.0.0.1:5984/zenwiki")


end

