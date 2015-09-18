WebApp.connectHandlers
  .use '/accounts.txt', (request, response, next) ->
    response.setHeader 'Access-Control-Allow-Origin', '*'
    result = ''
    accs = Accounts.find({seed: {$exists: true}})
    accs.map (acc) ->
      result += acc._id +'\n'
    response.end result
