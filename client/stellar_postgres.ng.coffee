angular.module 'stellarPostgres', []
.factory 'stellarData', ->
  ledgerheaders: new PgSubscription 'lastLedgerHeaders'
  transactions: new PgSubscription 'lastTransactions'
  peers: new PgSubscription 'peers'