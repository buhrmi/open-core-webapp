CORE_DB_URL = process.env['CORE_DB_URL'] || 'postgres://stellar-core:stellar@open-core.org/stellar-core'

throw 'Please specify Postgres connection string in CORE_DB_URL environment variable' unless CORE_DB_URL

liveDb = new LivePg(CORE_DB_URL, 'opencore');

Meteor.publish 'lastLedgerHeaders', ->
  liveDb.select('SELECT * FROM ledgerheaders ORDER BY closetime DESC limit 10')

Meteor.publish 'lastTransactions', ->
  liveDb.select('SELECT * FROM txhistory ORDER BY ledgerseq DESC limit 10')

Meteor.publish 'peers', ->
  liveDb.select('SELECT * FROM peers ORDER BY rank DESC')