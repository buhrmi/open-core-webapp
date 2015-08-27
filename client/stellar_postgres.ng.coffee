data =
  ledgerheaders: new PgSubscription 'lastLedgerHeaders'
  transactions: new PgSubscription 'lastTransactions'
  peers: new PgSubscription 'peers'
  offers: new PgSubscription 'offers'

angular.module 'stellarPostgres', []
.factory 'stellarData', -> data