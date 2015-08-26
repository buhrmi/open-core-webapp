data =
  ledgerheaders: new PgSubscription 'lastLedgerHeaders'
  transactions: new PgSubscription 'lastTransactions'
  peers: new PgSubscription 'peers'

angular.module 'stellarPostgres', []
.factory 'stellarData', -> data