@Accounts = new Mongo.Collection('accounts')

if Meteor.isServer
  Meteor.publish 'myAccounts', ->
    Accounts.find user_id: @userId
  Meteor.publish 'recentAccounts', ->
    Accounts.find {}, fields:
      seed: false


# Fields: user_id, verification

Accounts.allow
  insert: (userId, account) ->
    return false unless userId && account.user_id == userId # TODO: or userId is admin
    return false unless Accounts._transform(account).isValid()
    true

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

  performTransaction: (txParams) ->  
    stTransaction = @buildTransaction(txParams)
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

