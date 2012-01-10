mongo = require "mongoskin"
express = require "express"


# Set up db connection
# db = mongo.db("emongo2.heyzap.com/mobile")
db = mongo.db("localhost/mobile")

# Set up express
app = express.createServer();

app.configure ->
  app.set('views', __dirname + '/views');
  app.set('view engine', 'ejs');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.static(__dirname + '/public'));

app.configure "development", ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 

app.configure "production", ->
  app.use(express.errorHandler()); 

app.listen 8080

# App rendering helpers
app.helpers 
  queryFormatter: (query) ->
    ""

# Endpoints
app.get "/", (req, res) ->
  range = 1000 * 60 * 60 * 24 * 1
  now = new Date()
  query =
    ts:
      $gte: new Date(now.getTime() - range)
      $lt: now

  db.collection("system.profile").find(query, {sort: [["millis", -1]]}).toArray (err, records) ->
    ops = (getNormalizedOperation(r) for r in records)

    res.render "index",
      ops: ops

console.log "Starting server on port 8080"

getNormalizedQuery = (query) ->
  

getNormalizedOperation = (profile) ->
  res =
    ts: profile.ts
    millis: profile.millis
    nscanned: profile.nscanned
    nreturned: profile.nreturned

  if profile.op == "command"
    if profile.command.count
      res.operation = "count"
      res.collection = profile.command.count
      res.query = profile.command.query
    else
      res.operation = "unknown"
  else
    res.operation = profile.op
    res.collection = profile.ns
    res.payload = "TODO"
    res.query = profile.query
    res.query = profile.query.$query if profile.query && profile.query.$query
    res.query = profile.query.query if profile.query && profile.query.query

  res.normalized_query = getNormalizedQuery(res.query) if res.query

  return res