HISTORY_DB_URL = process.env['HISTORY_DB_URL']

if !HISTORY_DB_URL
  return

#console.log 'Please specify Postgres connection string in CORE_DB_URL environment variable' unless CORE_DB_URL

liveDbHistory = new LivePg(HISTORY_DB_URL, 'history');

Meteor.publish 'historyLastLedgerHeaders', ->
  liveDbHistory.select('SELECT * FROM history_ledgers ORDER BY sequence DESC limit 10')

Meteor.publish 'historyLastTransactions', ->
  liveDbHistory.select('SELECT * FROM history_transactions ORDER BY ledgerseq DESC limit 10')
