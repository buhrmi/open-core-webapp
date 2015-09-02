CORE_DB_URL = process.env['CORE_DB_URL']

throw 'Please specify Postgres connection string in CORE_DB_URL environment variable' unless CORE_DB_URL

liveDb = new LivePg(CORE_DB_URL, 'opencore');

# Keep Mongo Accounts in sync with PG accounts
liveDb
  .select("SELECT * FROM accounts ORDER BY lastmodified DESC limit 10")
  .on 'update', Meteor.bindEnvironment (diff, data) ->
    if diff.added
      for pgData in diff.added
        Accounts.update(pgData.accountid, {$set: {pg: pgData}})

liveDb
  .select("SELECT * FROM trustlines ORDER BY lastmodified DESC limit 10")
  .on 'update', Meteor.bindEnvironment (diff, data) ->
    if diff.added
      for pgData in diff.added
        Trustlines.upsert({accountid:pgData.accountid,issuer:pgData.issuer,assetcode:pgData.assetcode},pgData)


Meteor.publish 'lastLedgerHeaders', ->
  liveDb.select('SELECT * FROM ledgerheaders ORDER BY closetime DESC limit 10')

Meteor.publish 'lastTransactions', ->
  liveDb.select('SELECT * FROM txhistory ORDER BY ledgerseq DESC limit 10')

Meteor.publish 'peers', ->
  liveDb.select('SELECT * FROM peers ORDER BY rank DESC')

Meteor.publish 'offers', ->
  liveDb.select('SELECT * FROM offers ORDER BY offerid DESC')