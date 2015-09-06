angular.module 'core', []

# TODO: extract this into CoreData
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
      account = Accounts.findOne address
      el.attr 'href', "/accounts/#{address}"
      el.attr 'title', address
      el.html account?.name || (address.slice(0,7)+'...')

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
