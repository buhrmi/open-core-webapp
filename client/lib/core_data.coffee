@CoreData =
  ledgerheaders: new PgSubscription 'lastLedgerHeaders'
  transactions: new PgSubscription 'lastTransactions'
  peers: new PgSubscription 'peers'
  featuredAssets: new PgSubscription 'featuredAssets'
  subscribeAddresses: (addresses, scope) ->
    scope.$meteorSubscribe('trustlines', addresses)
    scope.$meteorSubscribe('offers', addresses)
    scope.$meteorSubscribe('transactions', addresses)
    scope.$meteorSubscribe('accounts', addresses)
