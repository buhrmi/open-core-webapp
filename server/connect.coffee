CORE_DB_URL = process.env['CORE_DB_URL'] || Meteor.settings.core_db_url
throw 'Please specify Postgres connection string in CORE_DB_URL environment variable' unless CORE_DB_URL

Kadira.connect('Avas3b7wzNdXJjbL7', 'c9d95d49-4e5f-4301-a38e-3678d6e2cf53') unless process.env['CORE_DB_URL']

liveDb = new LivePg(CORE_DB_URL, 'opencore');

# Catch up on the recent 10 changes and set up sync
liveDb
  .select("SELECT * FROM accounts ORDER BY lastmodified DESC limit 10")
  .on 'update', Meteor.bindEnvironment (diff, data) ->
    for row in data
      upd = {pg: row}
      upd.name = row.homedomain if row.homedomain
      Accounts.upsert({_id: row.accountid}, {$set: upd})

# Catch up on the recent 100 changes and set up sync
liveDb
  .select "SELECT * FROM trustlines ORDER BY lastmodified DESC limit 100",
    trustlines: Meteor.bindEnvironment (row, op) ->
      row.accountid = String(row.accountid)
      if op == 'INSERT' or op == 'UPDATE1'
        Accounts.update({_id:row.issuer},{$addToSet: {assetcodes: row.assetcode}})
        Trustlines.upsert({accountid:row.accountid,assetcode:row.assetcode,issuer:row.issuer}, row)
      if op == 'DELETE'
        Trustlines.remove({accountid:row.accountid,assetcode:row.assetcode,issuer:row.issuer})
      return false
  .on 'update', Meteor.bindEnvironment (diff, data) ->
    for row in data
      row.accountid = String(row.accountid)
      Accounts.update({_id:row.issuer},{$addToSet: {assetcodes: row.assetcode}})
      Trustlines.upsert({accountid:row.accountid,assetcode:row.assetcode,issuer:row.issuer}, row)

# Catch up on the recent 100 changes and set up sync
liveDb
  .select "SELECT * FROM offers ORDER BY lastmodified DESC limit 100",
    offers: Meteor.bindEnvironment (row, op) ->
      row.offerid = String(row.offerid)
      if op == 'INSERT' or op == 'UPDATE1'
        Offers.upsert({_id:row.offerid}, {$set: row})
      if op == 'DELETE'
        Offers.remove({_id:row.offerid})
      return false
  .on 'update', Meteor.bindEnvironment (diff, data) ->
    for row in data
      row.offerid = String(row.offerid)
      Offers.upsert({_id:row.offerid}, {$set: row})

# Catch up on the recent 100 changes and set up sync
liveDb
  .select "SELECT * FROM txhistory ORDER BY ledgerseq DESC limit 100",
    txhistory: Meteor.bindEnvironment (row, op) ->
      row.txid = String(row.txid)
      if op == 'INSERT' or op == 'UPDATE1'
        Transactions.handlePgUpdate(row)
      if op == 'DELETE'
        Transactions.remove({_id:row.txid})
      return false
  .on 'update', Meteor.bindEnvironment (diff, data) ->
    for row in data
      row.txid = String(row.txid)
      Transactions.handlePgUpdate(row)

# Legacy... Should remove this publications.
Meteor.publish 'lastLedgerHeaders', ->
  liveDb.select('SELECT * FROM ledgerheaders ORDER BY closetime DESC limit 10')

Meteor.publish 'lastTransactions', ->
  liveDb.select('SELECT * FROM txhistory ORDER BY ledgerseq DESC limit 10')

Meteor.publish 'peers', ->
  liveDb.select('SELECT * FROM peers ORDER BY rank DESC')

Meteor.publish 'featuredAssets', ->
  liveDb.select('select distinct ON(issuer,assetcode) issuer,assetcode,balance  from trustlines order by issuer,assetcode,balance limit 10')

# Meteor.publish 'offers', ->
#   liveDb.select('SELECT * FROM offers ORDER BY offerid DESC')
