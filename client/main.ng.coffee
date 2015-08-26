angular.module 'opencore', ['angular-meteor', 'ngRoute', 'ngCookies', 'stellarPostgres']

.run ($meteor, $rootScope) ->
  $rootScope.appName = 'OpenCore'

.config ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode(true)
  $routeProvider.when '/',
    templateUrl: 'templates/stats.html'
    controller: 'StatsController'

.controller 'StatsController', ($scope, $meteor, $routeParams, stellarData) ->
  $scope.$meteorAutorun ->
    $scope.ledgerheaders = stellarData.ledgerheaders.reactive()
    $scope.transactions = stellarData.transactions.reactive()
    $scope.peers = stellarData.peers.reactive()
    