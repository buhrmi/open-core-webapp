Meteor.users.helpers
  getAccounts: ->
    Accounts.find user_id: @_id
