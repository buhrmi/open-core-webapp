WebApp.connectHandlers
  .use '/stellar.txt', (request, response, next) ->
    
    result = ''
    result += '[domain]\n'
    result += process.env.ROOT_URL || 'http://open-core.org'
    result += '\n\n'
    result += '[accounts]\n'
    accs = Accounts.find({})
    accs.map (acc) ->
      result += acc._id + '\n'

    response.setHeader 'Access-Control-Allow-Origin', '*'
    response.end result

  