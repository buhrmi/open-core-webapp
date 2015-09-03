CORE_DB_URL = process.env['CORE_DB_URL']

throw 'Please specify Postgres connection string in CORE_DB_URL environment variable' unless CORE_DB_URL

liveDb = new LivePg(CORE_DB_URL, 'opencore');

#TODO: subscribe to postgres user account to sync sequence

# Keep Mongo Accounts in sync with PG accounts
liveDb
  .select("SELECT * FROM accounts ORDER BY lastmodified DESC limit 10")
  .on 'update', Meteor.bindEnvironment (diff, data) ->
    if diff.added
      for pgData in diff.added
        upd = {pg: pgData}
        upd.name = pg.homeDomain if pg.homeDomain
        Accounts.upsert({_id: pgData.accountid}, upd)

liveDb
  .select "SELECT * FROM trustlines ORDER BY lastmodified DESC limit 10",
    trustlines: Meteor.bindEnvironment (row, op) ->
      row.accountid = String(row.accountid)
      if op == 'INSERT' or op == 'UPDATE1'
        Trustlines.upsert({accountid:row.accountid,assetcode:row.assetcode,issuer:row.issuer}, row)
      if op == 'DELETE'
        Trustlines.remove({accountid:row.accountid,assetcode:row.assetcode,issuer:row.issuer})
  .on 'update', Meteor.bindEnvironment (diff, data) ->
    if diff.added
      for row in diff.added
        row.accountid = String(row.accountid)
        Trustlines.upsert({accountid:row.accountid,assetcode:row.assetcode,issuer:row.issuer}, row)

liveDb
  .select "SELECT * FROM offers ORDER BY lastmodified DESC limit 10",
    offers: Meteor.bindEnvironment (row, op) ->
      row.offerid = String(row.offerid)
      if op == 'INSERT' or op == 'UPDATE1'
        Offers.upsert({_id:row.offerid}, row)
      if op == 'DELETE'
        Offers.remove({_id:row.offerid})
  .on 'update', Meteor.bindEnvironment (diff, data) ->
    if diff.added
      for row in diff.added
        row.offerid = String(row.offerid)
        Offers.upsert({_id:row.offerid}, row)
        

Meteor.publish 'lastLedgerHeaders', ->
  liveDb.select('SELECT * FROM ledgerheaders ORDER BY closetime DESC limit 10')

Meteor.publish 'lastTransactions', ->
  liveDb.select('SELECT * FROM txhistory ORDER BY ledgerseq DESC limit 10')

Meteor.publish 'peers', ->
  liveDb.select('SELECT * FROM peers ORDER BY rank DESC')

Meteor.publish 'offers', ->
  liveDb.select('SELECT * FROM offers ORDER BY offerid DESC')