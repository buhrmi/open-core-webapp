@Offers = new Mongo.Collection('cached_offers')

if Meteor.isServer
  Meteor.publish 'myOffers', ->
    return unless @userId
    accs = Accounts.find user_id: @userId
    addresses = (acc._id for acc in accs.fetch())
    Offers.find sellerid: {$in:addresses}
  Meteor.publish 'offers', (addresses)->
    Offers.find sellerid: {$in:addresses}

Offers.helpers
  manage: (params) ->
    seller = Accounts.findOne(@sellerid)
    txBuilder = seller.transactionBuilder()
    want = new StellarBase.Asset(@buyingassetcode, @buyingissuer)
    have = new StellarBase.Asset(@sellingassetcode, @sellingissuer)
    op = StellarBase.Operation.manageOffer
      offerId: @offerid
      amount: params.amount || @amount
      selling: have
      buying: want
      price: params.price || @price
    tx = txBuilder.addOperation(op).build()
    seller.submitTransaction(tx)