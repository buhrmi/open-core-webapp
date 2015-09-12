Tracker.autorun ->
  config = Configs.findOne('global')
  return unless config
  if config.passphrase
    StellarBase.Network.use(new StellarBase.Network(config.passphrase))
  window.TX_ENDPOINT = config.tx_endpoint
