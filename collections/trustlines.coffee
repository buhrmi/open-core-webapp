@Trustlines = new Mongo.Collection('trustlines')

if Meteor.isServer
  Meteor.publish 'givenTrustlines', ->
    accs = Accounts.find user_id: @userId
    addresses = (acc._id for acc in accs.fetch())
    Trustlines.find accountid: {$in:addresses}
  Meteor.publish 'receivedTrustlines', ->
    accs = Accounts.find user_id: @userId
    addresses = (acc._id for acc in accs.fetch())
    Trustlines.find issuer: {$in:addresses}

  # Meteor.publish 'recentTrustlines', ->
  #   Trustlines.find()


# Fields: user_id, verification
