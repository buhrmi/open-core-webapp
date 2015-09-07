# TODO: extract subscription building process into angular provider or something...
defaultSubscriptions = [
  'myAccounts',
  'myTrustlines',
  'receivedTrustlines',
  'myOffers',
  'myTransactions'
]
subscriptionPromises = {}
defaultResolves = {}
_.each defaultSubscriptions, (subName) ->
  defaultResolves[subName] = ($meteor)->
    "ngInject"
    return subscriptionPromises[subName] if subscriptionPromises[subName]
    subscriptionPromises[subName] = $meteor.subscribe(subName)


angular.module 'opencore', ['angular-meteor', 'ngRoute', 'ngCookies', 'core']
.run ($meteor, $rootScope, ModalService) ->
  $rootScope.appName = 'OpenCore'
  $rootScope.$meteorAutorun ->
    headers = CoreData.ledgerheaders.reactive()
    $rootScope.ledgerSeq = headers[0]?.ledgerseq

  $rootScope.$meteorAutorun ->
    if Meteor.userId()
      if localStorage.getItem('currentAccountId')
        $rootScope.currentAccount = $rootScope.$meteorObject(Accounts, {_id: localStorage.getItem('currentAccountId')}, false)
      else
        $rootScope.currentAccount = $rootScope.$meteorObject(Accounts, {user_id: Meteor.userId()}, false)
    else
      $rootScope.currentAccount = false


.config ($locationProvider, $routeProvider, $compileProvider) ->
  $compileProvider.debugInfoEnabled(false)
  $locationProvider.html5Mode(true)
  $routeProvider.when '/',
    templateUrl: 'templates/layout.html'
    controller: 'OverviewController'
    resolve: defaultResolves
  $routeProvider.when '/accounts/:address',
    templateUrl: 'templates/layout.html'
    controller: 'AccountController'
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


.controller 'MyCoreAccountsController', ($scope, $rootScope) ->
  $scope.resourceTitle = 'My Core > Accounts'
  $scope.resourceTemplate = 'templates/mycore/accounts.html'

  $scope.newAccount = Accounts._transform(user_id: Meteor.userId())
  $scope.userAccounts = $scope.$meteorCollection -> Meteor.user().getAccounts()

  $scope.saveAccount = (account) ->
    Meteor.call('createAccount', account)
  $scope.useAccount = (account) ->
    $scope.$root.currentAccount = $scope.$root.$meteorObject Accounts, account._id
    localStorage.setItem('currentAccountId', account._id)
  $scope.generateRandom = ->
    kp = StellarBase.Keypair.random()
    $scope.newAccount._id = kp.address()
    $scope.newAccount.seed = kp.seed()
    $scope.newAccount.selfSign()


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
      $scope.receivedTrustlines = Trustlines.find({issuer: acc._id}, {sort: {balance: -1}}).fetch()

  $scope.$meteorAutorun ->
    acc = $scope.getReactively('currentAccount')
    if acc
      $scope.offers = Offers.find({sellerid: acc._id}).fetch()


.controller 'AccountController', ($scope, $routeParams, coreAddressService) ->
  $scope.resourceTitle = $routeParams.address
  $scope.resourceTemplate = 'templates/account.html'
  address = $routeParams.address
  coreAddressService.subscribeAddresses([address])
  .then ->
    $scope.$meteorAutorun ->
      $scope.account = account = Accounts.findOne(address)
      if account.pg?.homedomain?
        $scope.resourceTitle = account.pg.homedomain + ' / ' + account._id
      $scope.transactions = account.getTransactions()
      $scope.offers       = account.getOffers()
      $scope.trustlines   = account.getGivenTrustlines()


.controller 'AccountsController', ($scope) ->
  $scope.resourceTitle = 'Accounts'
  $scope.resourceTemplate = 'templates/accounts.html'

  $scope.accounts = $scope.$meteorCollection ->
    Accounts.find({}, {sort: {created_at: -1}})


.controller 'OverviewController', ($scope, $routeParams) ->
  $scope.resourceTitle = 'Overview'
  $scope.resourceTemplate = 'templates/overview.html'

  $scope.$meteorAutorun ->
    pgTransactions = CoreData.transactions.reactive()
    $scope.transactions = for pgTransaction in pgTransactions
      {
        body: new StellarBase.Transaction(pgTransaction.txbody)
        pg: pgTransaction
        result: StellarBase.xdr.TransactionResultPair.fromXDR(new Buffer(pgTransaction.txresult, 'base64'))
      }

  $scope.$meteorAutorun ->
    $scope.ledgerheaders = CoreData.ledgerheaders.reactive()

  $scope.$meteorAutorun ->
    $scope.featuredAssets = CoreData.featuredAssets.reactive()

  $scope.$meteorAutorun ->
    $scope.peers = CoreData.peers.reactive()
