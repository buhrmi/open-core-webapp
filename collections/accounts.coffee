@Accounts = new Mongo.Collection('accounts')

if Meteor.isServer
  Meteor.publish 'allAccounts', -> Accounts.find()

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

  sign: ->
    try
      keypair = StellarBase.Keypair.fromSeed(@seed)
      secretKey = keypair.rawSecretKey()
      @verification = StellarBase.sign(@user_id, secretKey).toString('hex')
