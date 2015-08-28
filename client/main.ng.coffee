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

.filter 'isValidAccount', ->
  (account) ->
    try StellarBase.verify(account.user_id, new Buffer(account.signature, 'hex'), new Buffer(account._id))

.filter 'sign', ->
  (object) ->
    return unless object?.secretSeed && object?.data
    keypair = StellarBase.Keypair.fromSeed(object.secretSeed)
    keypair.sign(object.data).toString('hex')
    # StellarBase.sign(object.data, keypair.rawSeed())


.directive 'ocAddress', ->
  restrict: 'A'
  link: (scope, el, attrs) ->
    el.attr 'href', "/account/#{attrs.ocAddress}"
    el.html 'unkown'

.controller 'MyCoreController', ($scope) ->
  $scope.saveAccount = (account) ->
    console.log('saving account')

  $scope.resourceTitle = 'My Core'
  $scope.resourceTemplate = 'templates/mycore.html'

.controller 'AccountsController', ($scope) ->
  $scope.resourceTitle = 'Accounts'
  $scope.resourceTemplate = 'templates/accounts.html'

  $scope.federatedAccounts = $scope.$meteorCollection ->
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
    