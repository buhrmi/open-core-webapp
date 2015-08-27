angular.module 'opencore', ['angular-meteor', 'ngRoute', 'ngCookies', 'stellarPostgres']

.run ($meteor, $rootScope) ->
  $rootScope.appName = 'OpenCore'

.config ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode(true)
  $routeProvider.when '/',
    templateUrl: 'templates/stats.html'
    controller: 'StatsController'

.directive 'ocAddress', ->
  restrict: 'A'
  link: (scope, el, attrs) ->
    el.attr 'href', "/account/#{attrs.ocAddress}"
    el.html 'unkown'


.controller 'StatsController', ($scope, $meteor, $routeParams, stellarData) ->
  
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
    