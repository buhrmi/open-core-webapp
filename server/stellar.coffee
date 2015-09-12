@StellarBase = Meteor.npmRequire('open-core')

if process.env.PASSPHRASE
  StellarBase.Network.use(new StellarBase.Network(process.env.PASSPHRASE))

Meteor.publish 'config', ->
  Configs.find()

Configs.upsert({_id: 'global'}, {$set: {
  passphrase: process.env.PASSPHRASE,
  tx_endpoint: process.env.TX_ENDPOINT
  app_name: process.env.APP_NAME
}})
