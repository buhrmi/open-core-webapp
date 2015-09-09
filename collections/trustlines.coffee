@Trustlines = new Mongo.Collection('cached_trustlines')

if Meteor.isServer
  Meteor.publish 'myTrustlines', ->
    accs = Accounts.find user_id: @userId
    addresses = (acc._id for acc in accs.fetch())
    Trustlines.find accountid: {$in:addresses}
  Meteor.publish 'trustlines', (addresses)->
    Trustlines.find accountid: {$in:addresses}
  Meteor.publish 'receivedTrustlines', ->
    accs = Accounts.find user_id: @userId
    addresses = (acc._id for acc in accs.fetch())
    Trustlines.find issuer: {$in:addresses}

  # Meteor.publish 'recentTrustlines', ->
  #   Trustlines.find()

Trustlines.helpers
  manage: (opts)->
    asset = new StellarBase.Asset(@assetcode, @issuer)
    account = Accounts.findOne(@accountid)
    txBuilder = account.transactionBuilder()
    op = StellarBase.Operation.changeTrust
      asset: asset
      limit: String(opts.tlimit || opts.limit || @tlimit || 10000000)
    tx = txBuilder.addOperation(op).build()
    account.submitTransaction(tx)

  cancel: ->
    @manage limit: '0'

  isEqual: (otherTrustline) ->
    @assetcode == otherTrustline.assetcode && @accountid == otherTrustline.accountid && @issuer == otherTrustline.issuer

Trustlines.for = (accountid, issuer, assetcode) ->
  params = {accountid: accountid, issuer: issuer, assetcode: assetcode}
  t = Trustlines.findOne(params) || Trustlines._transform(params)


# Fields: user_id, verification
