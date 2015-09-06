@CoreUI =
  transactionSources: {}
  transactionSourceElement: null

  transactionSent: (tx) ->
    txIdentifier = JSON.stringify(tx.operations)+tx.source
    # console.log('SENT IDENT:',txIdentifier)
    setTimeout (-> CoreUI.markLoading(txIdentifier)), 10

  # Transaction response from the server. Before accepting to the network
  transactionResponse: (response, tx) ->
    if response.status != 'PENDING'
      @transactionFailed(tx.source)


  transactionFailed: (identifier) ->
    el = CoreUI.transactionSources[identifier]
    return unless el
    el.removeClass('loading')

  transactionSuccess: (identifier) ->
    el = CoreUI.transactionSources[identifier]
    return unless el
    el.removeClass('loading')

  markLoading: (identifier) ->
    return unless CoreUI.transactionSourceElement?.length > 0
    CoreUI.transactionSources[identifier] = CoreUI.transactionSourceElement
    CoreUI.transactionSourceElement.addClass('loading')


$(document).on 'click', (e) ->
  CoreUI.transactionSourceElement = $(e.target).parents('.transaction_source')

Tracker.autorun ->
  lastPgTransaction = CoreData.transactions.reactive()[0]
  return unless lastPgTransaction
  result = StellarBase.xdr.TransactionResultPair.fromXDR(new Buffer(lastPgTransaction.txresult, 'base64'))
  success = result.result().result().switch().name == 'txSuccess'
  transaction = new StellarBase.Transaction(lastPgTransaction.txbody)
  identifier = JSON.stringify(transaction.operations)+transaction.source
  if success
    CoreUI.transactionSuccess(identifier)
  else
    CoreUI.transactionFailed(identifier)
