@Accounts = new Mongo.Collection('accounts')

if Meteor.isServer
  Meteor.publish 'myAccounts', ->
    Accounts.find user_id: @userId
  Meteor.publish 'accounts', (addresses) ->
    Accounts.find {_id: {$in:addresses}}, fields:
      seed: false


# Fields: user_id, verification

Accounts.allow
  update: (userId, account) ->
    return false unless userId && account.user_id == userId # TODO: or userId is admin
    return false unless Accounts._transform(account).isValid()
    true

Accounts.helpers
  isValid: ->
    try
      keypair = StellarBase.Keypair.fromAddress(@_id)
      StellarBase.verify(@user_id, new Buffer(@verification, 'hex'), keypair.rawPublicKey())

  seedIsValid: ->
    try
      StellarBase.Keypair.fromSeed(@seed).address() == @_id

  selfSign: ->
    try
      keypair = StellarBase.Keypair.fromSeed(@seed)
      secretKey = keypair.rawSecretKey()
      @verification = StellarBase.sign(@user_id, secretKey).toString('hex')

  buildTransaction: (txParams) ->
    if txParams.type == 'manageTrust'
      asset = new StellarBase.Asset(txParams.asset.code, txParams.asset.issuer)
      @transactionBuilder()
      .addOperation StellarBase.Operation.changeTrust
        asset: asset
        limit: txParams.limit
      .build()
    else if txParams.type == 'manageOffer'
      want = new StellarBase.Asset(txParams.want.code, txParams.want.issuer)
      have = new StellarBase.Asset(txParams.have.code, txParams.have.issuer)
      @transactionBuilder()
      .addOperation StellarBase.Operation.manageOffer
        offerid: txParams.offerid
        selling: have
        buying: want
        amount: txParams.amount
        price: txParams.price
      .build()
    else if txParams.type == 'payment'
      asset = new StellarBase.Asset(txParams.asset.code, txParams.asset.issuer)
      @transactionBuilder()
      .addOperation StellarBase.Operation.payment
        destination: txParams.destination
        asset: asset
        amount: txParams.amount
      .build()
    else if txParams.type == 'options'
      @transactionBuilder()
      .addOperation StellarBase.Operation.setOptions
        homeDomain: txParams.homeDomain
      .build()

  performTransaction: (txParams) ->  
    stTransaction = @buildTransaction(txParams)
    @submitTransaction(stTransaction)

  submitTransaction: (stTransaction) ->
    keypair = StellarBase.Keypair.fromSeed(@seed)
    stTransaction.sign(keypair)
    blob = stTransaction.toEnvelope().toXDR().toString('base64')
    result = $.getJSON(TX_ENDPOINT+encodeURIComponent(blob))

  transactionBuilder: ->
    stAccount = new StellarBase.Account(@_id, @pg?.seqnum || 0)
    builder = new StellarBase.TransactionBuilder(stAccount)
    builder.fee = 0
    builder

  getGivenTrustlines: ->
    Trustlines.find({accountid: @_id}).fetch()

  getOffers: ->
    Offers.find({sellerid: @_id}).fetch()

  getTransactions: ->
    Transactions.find({'body.source': @_id}).fetch()