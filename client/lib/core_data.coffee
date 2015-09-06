@CoreData =
  ledgerheaders: new PgSubscription 'lastLedgerHeaders'
  transactions: new PgSubscription 'lastTransactions'
  peers: new PgSubscription 'peers'
  featuredAssets: new PgSubscription 'featuredAssets'
