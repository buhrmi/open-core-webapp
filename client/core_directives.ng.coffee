data =
  ledgerheaders: new PgSubscription 'lastLedgerHeaders'
  transactions: new PgSubscription 'lastTransactions'
  peers: new PgSubscription 'peers'

angular.module 'core', []
.factory 'stellarData', -> data

.directive 'coreAddress', ->
  restrict: 'A'
  link: (scope, el, attrs) ->
    address = scope.$eval(attrs.coreAddress)
    account = Accounts.find address
    el.attr 'href', "/account/#{address}"
    el.attr 'title', address
    el.html account?.name || (address.slice(0,7)+'...')

.directive 'coreTrustline', ->
  templateUrl: 'templates/core/directiveTrustline.html'
  restrict: 'E'
  link: (scope, e, attrs) ->
    accountid = attrs.account || scope.currentAccount._id
    unless scope.trustline
      scope.trustline = Trustlines.for accountid, 
        scope.$eval(attrs.issuer), 
        scope.$eval(attrs.assetcode)
