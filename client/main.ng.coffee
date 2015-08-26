ledgerheaders = new PgSubscription 'lastLedgerHeaders'
transactions = new PgSubscription 'lastTransactions'
peers = new PgSubscription 'peers'

angular.module 'opencore', ['angular-meteor', 'ngRoute', 'ngCookies']

.run ($meteor, $rootScope) ->
  $rootScope.appName = 'OpenCore'

.config ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode(true)
  $routeProvider.when '/',
    templateUrl: 'templates/stats.html'
    controller: 'MainController'

.controller 'MainController', ($scope, $meteor, $routeParams) ->
  Tracker.autorun (comp) ->
    $scope.ledgerheaders = ledgerheaders.reactive()
    $scope.transactions = transactions.reactive()
    $scope.peers = peers.reactive()
    $scope.$apply() unless comp.firstRun

  
  