@Transactions = new Mongo.Collection('cached_transactions')

if Meteor.isServer
  Meteor.publish 'myTransactions', ->
    return unless @userId
    accs = Accounts.find user_id: @userId
    addresses = (acc._id for acc in accs.fetch())
    Transactions.find 'body.source': {$in:addresses}
  Meteor.publish 'transactions', (addresses)->
    Transactions.find 'body.source': {$in:addresses}

Transactions.handlePgUpdate = (row) ->
  result = StellarBase.xdr.TransactionResultPair.fromXDR(new Buffer(row.txresult, 'base64'))
  return unless result.result().result().switch().name == 'txSuccess'
  row.body = new StellarBase.Transaction(row.txbody)
  Transactions.upsert({_id:row.txid}, row)