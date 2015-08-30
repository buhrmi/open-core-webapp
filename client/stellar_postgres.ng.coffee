data =
  ledgerheaders: new PgSubscription 'lastLedgerHeaders'
  historyLedgerheaders: new PgSubscription 'historyLastLedgerHeaders'
  transactions: new PgSubscription 'lastTransactions'
  peers: new PgSubscription 'peers'
  offers: new PgSubscription 'offers'

angular.module 'stellarPostgres', []
.factory 'stellarData', -> data
