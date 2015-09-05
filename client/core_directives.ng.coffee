data =
  ledgerheaders: new PgSubscription 'lastLedgerHeaders'
  transactions: new PgSubscription 'lastTransactions'
  peers: new PgSubscription 'peers'

angular.module 'core', []
.factory 'stellarData', -> data

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
  templateUrl: 'templates/core/directiveTrustline.html'
  restrict: 'E'
  link: (scope, e, attrs) ->
    accountid = attrs.account || scope.currentAccount._id
    unless scope.trustline
      scope.$meteorAutorun ->
        scope.trustline = Trustlines.for accountid,
          scope.$eval(attrs.issuer),
          scope.$eval(attrs.assetcode)
        scope.trustline.tlimit = 0 unless scope.trustline.tlimit
