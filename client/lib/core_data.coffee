@CoreData =
  ledgerheaders: new PgSubscription 'lastLedgerHeaders'
  transactions: new PgSubscription 'lastTransactions'
  peers: new PgSubscription 'peers'
  featuredAssets: new PgSubscription 'featuredAssets'

  alreadySubscribed: (name, params) ->
    for id, sub of Meteor.default_connection._subscriptions
      continue unless sub.name == name
      continue unless JSON.stringify(sub.params[0]) == JSON.stringify(params)
      return !sub.inactive
    return false