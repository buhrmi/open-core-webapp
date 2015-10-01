@CoreUI =
  transactionSources: {}
  transactionSourceElement: null

  transactionSent: (tx) ->
    txIdentifier = JSON.stringify(tx.operations)+tx.source
    # console.log('SENT IDENT:',txIdentifier)
    setTimeout (-> CoreUI.markLoading(txIdentifier)), 10

  # Transaction response from the server. Before accepting to the network
  transactionResponse: (response, tx) ->
    if !response || response.status != 'PENDING'
      @transactionFailed(JSON.stringify(tx.operations)+tx.source)


  transactionFailed: (identifier) ->
    el = CoreUI.transactionSources[identifier]
    return unless el
    el.removeClass('loading')
    el.find('.tx:visible').notify("Transaction Failed", className: "error", position: 'top center')

  transactionSuccess: (identifier) ->
    el = CoreUI.transactionSources[identifier]
    return unless el
    el.removeClass('loading')
    el.find('.tx:visible').notify("Transaction Completed", className: "success", position: 'top center')

  markLoading: (identifier) ->
    return unless CoreUI.transactionSourceElement?.length > 0
    CoreUI.transactionSources[identifier] = CoreUI.transactionSourceElement
    CoreUI.transactionSourceElement.addClass('loading')

$(document).on 'click', (e) ->
  CoreUI.transactionSourceElement = $(e.target).parents('.transaction_source')
Meteor.startup -> Tracker.autorun -> Transactions.find().map (transaction) ->
  result = StellarBase.xdr.TransactionResultPair.fromXDR(new Buffer(transaction.txresult, 'base64'))
  success = result.result().result().switch().name == 'txSuccess'
  transaction = new StellarBase.Transaction(transaction.txbody)
  identifier = JSON.stringify(transaction.operations)+transaction.source
  if success
    CoreUI.transactionSuccess(identifier)
  else
    CoreUI.transactionFailed(identifier)
