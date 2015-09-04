Meteor.methods
  'createAccount': (newAccount) ->
    return false unless @userId && newAccount.user_id == @userId # TODO: or userId is admin
    return false unless Accounts._transform(newAccount).isValid()

    acc = Accounts.findOne(newAccount._id)
    if acc
      newAccount.name = acc.pg.homedomain if acc.pg?.homedomain
      delete newAccount._id
      Accounts.update(acc._id, {$set: newAccount})
    else
      Accounts.insert(newAccount)