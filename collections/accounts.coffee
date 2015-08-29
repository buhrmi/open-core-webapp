@Accounts = new Mongo.Collection('accounts')

if Meteor.isServer
  Meteor.publish 'allAccounts', -> Accounts.find()

# Fields: user_id, verification

Accounts.allow
  insert: (userId, account) ->
    Accounts._transform(account).isValid()

  update: (userId, account) ->
    Accounts._transform(account).isValid()

Accounts.helpers
  isValid: ->
    try
      keypair = StellarBase.Keypair.fromAddress(@_id)
      StellarBase.verify(@user_id, new Buffer(@verification, 'hex'), keypair.rawPublicKey())
    catch e
      false
