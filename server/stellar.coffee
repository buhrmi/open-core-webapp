@StellarBase = Meteor.npmRequire('stellar-base')
StellarBase.Network.usePublicNetwork()

Meteor.publish 'config', ->
  Configs.find()

Configs.upsert({_id: 'global'}, {$set: {
  app_name: process.env.APP_NAME || 'Open Core'
}})
