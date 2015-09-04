@Trustlines = new Mongo.Collection('cached_trustlines')

if Meteor.isServer
  Meteor.publish 'myTrustlines', ->
    accs = Accounts.find user_id: @userId
    addresses = (acc._id for acc in accs.fetch())
    Trustlines.find accountid: {$in:addresses}
  Meteor.publish 'trustlines', (addresses)->
    Trustlines.find accountid: {$in:addresses}
  # Meteor.publish 'receivedTrustlines', ->
  #   accs = Accounts.find user_id: @userId
  #   addresses = (acc._id for acc in accs.fetch())
  #   Trustlines.find issuer: {$in:addresses}

  # Meteor.publish 'recentTrustlines', ->
  #   Trustlines.find()

Trustlines.helpers
  manage: ->
    true # TODO: impl.

Trustlines.for = (accountid, issuer, assetcode) ->
  params = {accountid: accountid, issuer: issuer, assetcode: assetcode}
  t = Trustlines.findOne(params) || Trustlines._transform(params)
  


# Fields: user_id, verification