@Accounts = new Mongo.Collection('accounts')

if Meteor.isServer
  Meteor.publish 'myAccounts', ->
    return [] unless @userId
    Accounts.find user_id: @userId
  Meteor.publish 'accounts', (addresses) ->
    Accounts.find {_id: {$in:addresses}}, fields:
      seed: false


# Fields: user_id, verification

Accounts.allow
  update: (userId, account, fields) ->
    return false unless userId && account.user_id == userId # TODO: or userId is admin
    return false unless Accounts._transform(account).isValid()
    return false if fields.indexOf('verified') != -1
    true

Accounts.helpers
  handlePgUpdate: (row, attemptToVerify = false) ->
    upd = {pg: row}
    if row.homedomain
      upd.name = row.homedomain
      # if attemptToVerify
      #   res = HTTP.get(pg.homedomain+'/accounts.txt')
      #   upd.verified = res.content.indexOf(row.accountid) != -1
    Accounts.upsert({_id: row.accountid}, {$set: upd})

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
      asset = new StellarBase.Asset(txParams.assetcode, txParams.issuer)
      @transactionBuilder()
      .addOperation StellarBase.Operation.payment
        destination: txParams.destination || txParams.accountid
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
    # console.log(stTransaction)
    stTransaction.sign(keypair)
    blob = stTransaction.toEnvelope().toXDR().toString('base64')
    Meteor.call 'submitTransaction', blob, (error, data) ->
      CoreUI.transactionResponse(data, stTransaction)
    CoreUI.transactionSent(stTransaction)

  transactionBuilder: ->
    stAccount = new StellarBase.Account(@_id, @pg?.seqnum || 0)
    memo = CoreUtil.randomId(4)
    builder = new StellarBase.TransactionBuilder(stAccount)
    # builder.memo = new StellarBase.Memo.text(memo)
    # builder.fee = 0
    builder

  getGivenTrustlines: ->
    Trustlines.find({accountid: @_id}).fetch()

  getOffers: ->
    Offers.find({sellerid: @_id}).fetch()

  getTransactions: ->
    Transactions.find({'body.source': @_id}).fetch()

  addAssetCode: (code) ->
    check(code, String)
    return false if code.length > 12
    @update $addToSet: {assetcodes: code}

  removeAssetCode: (code) ->
    @update $pull: {assetcodes: code}

  update: (operations) ->
    Accounts.update @_id, operations
