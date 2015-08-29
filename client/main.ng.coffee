Meteor.subscribe 'allAccounts'

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
    resolove:
      currentUser: ($meteor) ->
        $meteor.waitForUser()

.filter 'isValidAccount', ->
  (account) ->
    account = Accounts._transform(account)
    account.isValid()

# .filter 'sign', ->
#   (object) ->
#     return unless object?.seed && object?.data
#     try
#       keypair = StellarBase.Keypair.fromSeed(object.seed)
#       secretKey = keypair.rawSecretKey()
#       data = object.data || object.user_id
#       StellarBase.sign(data, secretKey).toString('hex')
#     # StellarBase.sign(object.data, keypair.rawSeed())


.directive 'ocAddress', ->
  restrict: 'A'
  link: (scope, el, attrs) ->
    account = Accounts.find attrs.ocAddress
    el.attr 'href', "/account/#{attrs.ocAddress}"
    el.html account?.name || 'uknown'

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
      new StellarBase.Transaction(pgTransaction.txbody)

  $scope.$meteorAutorun ->
    $scope.offers = stellarData.offers.reactive()

  $scope.$meteorAutorun ->
    $scope.ledgerheaders = stellarData.ledgerheaders.reactive()

  $scope.$meteorAutorun ->
    $scope.peers = stellarData.peers.reactive()
