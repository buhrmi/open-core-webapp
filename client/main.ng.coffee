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

  $scope.displayTransactionResult = (txResult) ->
    results = txResult.result().result().results()
    # TODO multiple ops per transaction
    result = results[0]
    #opName = result.value().switch()
    opReturnValue = result.value().value().switch().name
    return opReturnValue

  $scope.formatAsset = (asset) ->
    if asset.isNative()
      return "XLM"
    else
      return asset.getCode() + "/" + asset.getIssuer()

  $scope.displayOperation = (operation) ->
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
        ", selling: " + $scope.formatAsset(operation.selling) +
        ", buying: " + $scope.formatAsset(operation.buying)
    else if operation.type == 'payment'
      return "payment of " +  operation.amount + " " + $scope.formatAsset(operation.asset) + " to " + operation.destination
    else if operation.type == 'changeTrust'
      return " limit set to  " + operation.limit + " for " + $scope.formatAsset(operation.line)
    else
      return operation

  $scope.$meteorAutorun ->
    pgTransactions = stellarData.transactions.reactive()
    $scope.pgTransactions = pgTransactions
    $scope.transactions = for pgTransaction in pgTransactions
      {
        pg: pgTransaction
        body:new StellarBase.Transaction(pgTransaction.txbody)
        result:StellarBase.Transaction.decodeTransactionResultPair(pgTransaction.txresult)
      }

    $scope.operations = []
    for transaction in $scope.transactions
      for operation in transaction.body.operations
        $scope.operations.push(operation)


  $scope.$meteorAutorun ->
    $scope.offers = stellarData.offers.reactive()

  $scope.$meteorAutorun ->
    $scope.ledgerheaders = stellarData.ledgerheaders.reactive()

  $scope.$meteorAutorun ->
    $scope.historyLedgerheaders = stellarData.historyLedgerheaders.reactive()

  $scope.$meteorAutorun ->
    $scope.peers = stellarData.peers.reactive()
