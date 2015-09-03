# TODO: extract subscription building process into angular provider or something...
defaultSubscriptions = [
  'recentAccounts',
  'myAccounts',
  'givenTrustlines',
  'madeOffers'
]
subscriptionPromises = {}
defaultResolves = {}
_.each defaultSubscriptions, (subName) ->
  defaultResolves[subName] = ($meteor)->
    "ngInject"
    return subscriptionPromises[subName] if subscriptionPromises[subName]
    subscriptionPromises[subName] = $meteor.subscribe(subName)


angular.module 'opencore', ['angular-meteor', 'ngRoute', 'ngCookies', 'stellarPostgres']
.run ($meteor, $rootScope, stellarData) ->
  $rootScope.appName = 'OpenCore'
  $rootScope.$meteorAutorun ->
    headers = stellarData.ledgerheaders.reactive()
    $rootScope.ledgerSeq = headers[0]?.ledgerseq
  $rootScope.$meteorAutorun ->
    $rootScope.currentAccount = Accounts.findOne(user_id: Meteor.userId())

.config ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode(true)
  $routeProvider.when '/',
    templateUrl: 'templates/layout.html'
    controller: 'OverviewController'
    resolve: defaultResolves
  $routeProvider.when '/accounts',
    templateUrl: 'templates/layout.html'
    controller: 'AccountsController'
    resolve: defaultResolves
  $routeProvider.when '/mycore',
    templateUrl: 'templates/layout.html'
    controller: 'MyCoreController'
    resolve: $.extend defaultResolves,
      currentUser: ($meteor) ->
        "ngInject"
        $meteor.waitForUser()
  $routeProvider.when '/mycore/accounts',
    templateUrl: 'templates/layout.html'
    controller: 'MyCoreAccountsController'
    resolve: $.extend defaultResolves,
      currentUser: ($meteor) ->
        "ngInject"
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
    el.attr 'title', attrs.ocAddress
    el.html account?.name || attrs.ocAddress.slice(0,7)+'...'


.controller 'MyCoreAccountsController', ($scope, $rootScope) ->
  $scope.resourceTitle = 'My Core > Accounts'
  $scope.resourceTemplate = 'templates/mycore/accounts.html'

  $scope.newAccount = Accounts._transform(user_id: Meteor.userId())
  $scope.userAccounts = $scope.$meteorCollection -> Meteor.user().getAccounts()

  $scope.saveAccount = (account) ->
    Meteor.call('createAccount', account)
  $scope.useAccount = (account) ->
    $scope.$root.currentAccount = account
  

.controller 'MyCoreController', ($scope) ->
  $scope.resourceTitle = 'My Core'
  $scope.resourceTemplate = 'templates/mycore.html'
  
  $scope.$meteorAutorun ->    
    acc = $scope.getReactively('currentAccount')
    if acc
      $scope.trustlines = Trustlines.find({accountid: acc._id}).fetch()

  $scope.$meteorAutorun ->
    acc = $scope.getReactively('currentAccount')
    if acc
      $scope.offers = Offers.find({sellerid: acc._id}).fetch()


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
        pg: pgTransaction
        result: StellarBase.xdr.TransactionResultPair.fromXDR(new Buffer(pgTransaction.txresult, 'base64'))
      }

  $scope.$meteorAutorun ->
    $scope.offers = stellarData.offers.reactive()

  $scope.$meteorAutorun ->
    $scope.ledgerheaders = stellarData.ledgerheaders.reactive()

  $scope.$meteorAutorun ->
    $scope.peers = stellarData.peers.reactive()
