angular.module 'opencore', ['angular-meteor', 'ngRoute', 'ngCookies', 'stellarPostgres']

.run ($meteor, $rootScope) ->
  $rootScope.appName = 'OpenCore'

.config ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode(true)
  $routeProvider.when '/',
    templateUrl: 'templates/stats.html'
    controller: 'MainController'

.controller 'MainController', ($scope, $meteor, $routeParams, stellarData) ->
  Tracker.autorun (comp) ->
    $scope.ledgerheaders = stellarData.ledgerheaders.reactive()
    $scope.transactions = stellarData.transactions.reactive()
    $scope.peers = stellarData.peers.reactive()
    $scope.$apply() unless comp.firstRun

  
  