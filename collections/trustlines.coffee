@Trustlines = new Mongo.Collection('cached_trustlines')

if Meteor.isServer
  Meteor.publish 'myTrustlines', ->
    return unless @userId
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


# Fields: user_id, verification