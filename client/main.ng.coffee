Meteor.subscribe 'myAccounts'
Meteor.subscribe 'recentAccounts'

angular.module 'opencore', ['angular-meteor', 'ngRoute', 'ngCookies', 'stellarPostgres']

.run ($meteor, $rootScope) ->
  $rootScope.appName = 'OpenCore'

.config ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode(true)
  $routeProvider.when '/',
    templateUrl: 'templates/layout.html'
    controller: 'OverviewController'
  $routeProvider.when '/accounts',
    templateUrl: 'templates/layout.html'
    controller: 'AccountsController'
  $routeProvider.when '/mycore',
    templateUrl: 'templates/layout.html'
    controller: 'MyCoreController'
    resolve:
      currentUser: ($meteor) ->
        $meteor.waitForUser()

# .filter 'sign', ->
#   (object) ->
#     return unless object?.seed && object?.data
#     try
#       keypair = StellarBase.Keypair.fromSeed(object.seed)
#       secretKey = keypair.rawSecretKey()
#       data = object.data || object.user_id
#       StellarBase.sign(data, secretKey).toString('hex')
#     # StellarBase.sign(object.data, keypair.rawSeed())

.filter 'dispayAddress', ->
  (address) ->


.filter 'formatAsset', ->
  (asset) ->
    if asset.isNative()
      'NATIVE'
    else
      asset.code + '/' + asset.issuer

.filter 'displayOperation', ($filter)->
  (operation) ->
    if operation.type == 'createAccount'
      return "Destination: " + operation.destination + ", starting balance:" + operation.startingBalance
    else if operation.type == 'manageOffer'
      ops = "Creating offer, "
      if operation.orderId != 0
        if operation.amount == 0
          ops = "Updating offer, "
       else
         ops = "Cancelling order, "
      return ops + "amount: " + operation.amount +
        ", price " + operation.price +
        ", selling: " + $filter('formatAsset')(operation.selling) +
        ", buying: " + $filter('formatAsset')(operation.buying)
    else if operation.type == 'payment'
      return "payment of " +  operation.amount + " " + $filter('formatAsset')(operation.asset) + " to " + operation.destination
    else if operation.type == 'changeTrust'
      return " limit set to  " + operation.limit + " for " + $filter('formatAsset')(operation.line)
    else
      return operation

.directive 'ocAddress', ->
  restrict: 'A'
  link: (scope, el, attrs) ->
    account = Accounts.find attrs.ocAddress
    el.attr 'href', "/account/#{attrs.ocAddress}"
    el.html account?.name || ' unknown'

.controller 'MyCoreController', ($scope) ->
  $scope.resourceTitle = 'My Core'
  $scope.resourceTemplate = 'templates/mycore.html'

  $scope.newAccount = Accounts._transform(user_id: Meteor.userId())

  $scope.saveAccount = (account) ->
    Accounts.insert(account)

  $scope.userAccounts = $scope.$meteorCollection -> Meteor.user().getAccounts()

.controller 'AccountsController', ($scope) ->
  $scope.resourceTitle = 'Accounts'
  $scope.resourceTemplate = 'templates/accounts.html'

  $scope.accounts = $scope.$meteorCollection ->
    Accounts.find({}, {sort: {created_at: -1}})


.controller 'OverviewController', ($scope, $routeParams, stellarData) ->
  $scope.resourceTitle = 'Overview'
  $scope.resourceTemplate = 'templates/overview.html'

  $scope.$meteorAutorun ->
    pgTransactions = stellarData.transactions.reactive()
    $scope.transactions = for pgTransaction in pgTransactions
      {
        body: new StellarBase.Transaction(pgTransaction.txbody)
        result: StellarBase.xdr.TransactionResultPair.fromXDR(new Buffer(pgTransaction.txresult, 'base64'))
      }

  $scope.$meteorAutorun ->
    $scope.offers = stellarData.offers.reactive()

  $scope.$meteorAutorun ->
    $scope.ledgerheaders = stellarData.ledgerheaders.reactive()

  $scope.$meteorAutorun ->
    $scope.peers = stellarData.peers.reactive()
