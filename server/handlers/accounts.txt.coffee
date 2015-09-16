WebApp.connectHandlers
  .use '/accounts.txt', (request, response, next) ->
    response.setHeader 'Access-Control-Allow-Origin', '*'
    result = ''
    liveDb.notifyClient.query 'select accountid, homedomain from accounts', (err, res) ->
      for row in res
        result += "#{row[0] row[1]}\n"
      response.end result