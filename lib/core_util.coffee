@CoreUtil =
  randomId: (length)->
    result = ""
    possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

    for i in [0..length]
      result += possible.charAt(Math.floor(Math.random() * possible.length))
