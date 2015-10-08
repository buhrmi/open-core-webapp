angular.module 'core', ['angularModalService']

.run ($rootScope, ModalService) ->
  $rootScope.initiatePayment = (trustline) ->
    ModalService.showModal
      templateUrl: 'templates/core/modal.payment.html'
      controller: 'ModalPaymentController'
      inputs:
        trustline:
          accountid: trustline.accountid
          issuer: trustline.issuer
          assetcode: trustline.assetcode

  $rootScope.initiateChangeTrust = (trustline) ->
    ModalService.showModal
      templateUrl: 'templates/core/modal.trustline.html'
      controller: 'ModalTrustlineController'
      inputs:
        trustline:
          accountid: trustline.accountid
          issuer: trustline.issuer
          assetcode: trustline.assetcode

  $rootScope.initiateManageOffer = (offer) ->
    ModalService.showModal
      templateUrl: 'templates/core/modal.offer.html'
      controller: 'ModalOfferController'
      inputs:
        offer: Offers.findOne(offer._id)

  $rootScope.initiateNewOffer = ->
    ModalService.showModal
      templateUrl: 'templates/core/modal.new_offer.html'
      controller: 'ModalNewOfferController'

  $rootScope.initiateNewTrustline = ->
    ModalService.showModal
      templateUrl: 'templates/core/modal.new_trustline.html'
      controller: 'ModalNewTrustlineController'

.controller 'ModalNewOfferController', ($scope, close) ->
  $scope.close = close
  # $scope.$meteorAutorun ->
  available_selling_trustlines = Trustlines.find($or: [{balance: {$gt: '0'}},{balance: {$gt: 0}}]).fetch()
  if $scope.currentAccount.assetcodes
    for assetcode in $scope.currentAccount.assetcodes
      available_selling_trustlines.push({assetcode: assetcode, issuer: $scope.currentAccount._id})
  $scope.selling_trustlines = available_selling_trustlines
  $scope.buying_trustlines = Trustlines.find($or: [{accountid: $scope.currentAccount._id},{issuer: $scope.currentAccount._id}]).fetch()
  $scope.create = ->
    want = new StellarBase.Asset($scope.buying_trustline.assetcode, $scope.buying_trustline.issuer)
    have = new StellarBase.Asset($scope.selling_trustline.assetcode, $scope.selling_trustline.issuer)
    tb = $scope.currentAccount.transactionBuilder()
    return console.log('Invalid amount or price') unless $scope.amount && $scope.price
    op = StellarBase.Operation.manageOffer
      selling: have
      buying: want
      amount: $scope.amount
      price: $scope.price
    tx = tb.addOperation(op).build()
    $scope.currentAccount.submitTransaction(tx)

.controller 'ModalNewTrustlineController', ($scope, close) ->
  $scope.close = close
  # $scope.$meteorAutorun ->
  $scope.create = ->
    trustline = Trustlines._transform($scope.newTrustline)
    trustline.tlimit = trustline.tlimit
    trustline.accountid = $scope.currentAccount._id
    trustline.manage()


.controller 'ModalPaymentController', ($scope, trustline, close) ->
  $scope.close = close
  # $scope.trustlines = $scope.$meteorCollection(( -> Trustlines.find(issuer: $scope.currentAccount._id)), false)
  $scope.$meteorAutorun ->
    $scope.trustline = Trustlines.findOne(trustline)
  $scope.send = ->
    txParams = $scope.trustline
    txParams.type = 'payment'
    txParams.amount = $scope.amount
    $scope.currentAccount.performTransaction(txParams)

.controller 'ModalOfferController', ($scope, offer, close) ->
  $scope.close = close
  $scope.$meteorAutorun ->
    $scope.offer = Offers.findOne(offer)
  $scope.newAmount = offer.amount / 10000000
  $scope.newPrice = offer.price

.controller 'ModalTrustlineController', ($scope, trustline, close) ->
  $scope.close = close
  $scope.$meteorAutorun ->
    $scope.trustline = Trustlines.findOne(trustline) || Trustlines._transform(trustline)
  $scope.newLimit = $scope.trustline.tlimit / 10000000

.factory 'coreAddressService', ($q, $meteor) ->
  subscribeAddresses: (addresses) ->
    $q.all([
      $meteor.subscribe('trustlines', addresses),
      $meteor.subscribe('offers', addresses),
      $meteor.subscribe('transactions', addresses),
      $meteor.subscribe('accounts', addresses)
    ])


.directive 'coreAddress', ($filter) ->
  restrict: 'A'
  scope: true
  link: (scope, el, attrs) ->
    scope.$watch attrs.coreAddress, ->
      address = scope.$eval(attrs.coreAddress)
      scope.$meteorSubscribe('accounts', [address]) unless CoreData.alreadySubscribed('accounts', [address])
      scope.$meteorAutorun ->
        account = Accounts.findOne address
        el.addClass 'core_address'
        el.attr 'href', "/accounts/#{address}"
        el.attr 'title', address
        el.html account?.name || (address.slice(0,7)+'...')

.directive 'coreTransaction', ->
  templateUrl: 'templates/core/directive.transaction.html'
  scope: true

.directive 'coreTrustlinePicker', ->
  templateUrl: 'templates/core/directive.trustline_picker.html'
  restrict: 'E'
  scope: true
  link: (scope, e, attrs) ->
    scope.trustlines = scope.$eval(attrs.trustlines)
    scope.$watch 'selectedTrustline', ->
      scope.$parent[attrs.model] = scope.selectedTrustline
    scope.$parent.$watch attrs.model, ->
      scope.selectedTrustline = scope.$parent[attrs.model]
    scope.selectedTrustline = scope.$eval(attrs.selectedTrustline)

.directive 'coreOffer', ->
  templateUrl: 'templates/core/directive.offer.html'
  restrict: 'E'
  link: (scope, e, attrs) ->
    true

.directive 'coreTrustline', ->
  templateUrl: 'templates/core/directive.trustline.html'
  restrict: 'E'
  # scope: true
  link: (scope, e, attrs) ->
    unless scope.trustline
      scope.$meteorAutorun ->
        accountid = attrs.account || scope.getReactively('currentAccount')._id
        scope.trustline = Trustlines.for accountid,
          scope.$eval(attrs.issuer),
          scope.$eval(attrs.assetcode)
        scope.trustline.tlimit = 0 unless scope.trustline.tlimit
