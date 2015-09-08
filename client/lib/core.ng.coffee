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

.controller 'ModalPaymentController', ($scope, trustline, close) ->
  $scope.close = close
  $scope.trustlines = $scope.$meteorCollection(( -> Trustlines.find(issuer: $scope.currentAccount._id)), false)
  $scope.trustline = $scope.$meteorObject(Trustlines, trustline, false)
  $scope.send = ->
    txParams = $scope.trustline
    txParams.type = 'payment'
    txParams.amount = $scope.amount
    $scope.currentAccount.performTransaction(txParams)

.controller 'ModalTrustlineController', ($scope, trustline, close) ->
  $scope.close = close
  $scope.trustline = $scope.$meteorObject(Trustlines, trustline, false)
  $scope.newLimit = $scope.trustline.tlimit

.factory 'coreAddressService', ($q, $meteor) ->
  subscribeAddresses: (addresses) ->
    $q.all([
      $meteor.subscribe('trustlines', addresses),
      $meteor.subscribe('offers', addresses),
      $meteor.subscribe('transactions', addresses),
      $meteor.subscribe('accounts', addresses)
    ])

.directive 'coreAddress', ->
  restrict: 'A'
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

.directive 'coreTrustlinePicker', ->
  templateUrl: 'templates/core/directive.trustline_picker.html'
  restrict: 'E'
  link: (scope, e, attrs) ->
    scope.trustlines = scope.$eval(attrs.trustlines)
    scope.selectedTrustline = scope.$eval(attrs.selectedTrustline)

.directive 'coreTrustline', ->
  templateUrl: 'templates/core/directive.trustline.html'
  restrict: 'E'
  link: (scope, e, attrs) ->
    unless scope.trustline
      scope.$meteorAutorun ->
        accountid = attrs.account || scope.getReactively('currentAccount')._id
        scope.trustline = Trustlines.for accountid,
          scope.$eval(attrs.issuer),
          scope.$eval(attrs.assetcode)
        scope.trustline.tlimit = 0 unless scope.trustline.tlimit
