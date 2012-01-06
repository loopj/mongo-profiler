mongo = require "mongoskin"

db = mongo.db("localhost/mobile")

db.collection("system.profile").findOne {}, (err, obj) ->
  console.log obj
  process.exit()