Games = new Meteor.Collection("games")

Meteor.publish "games", ->
  Games.find {}

# Meteor.users.allow
#   update: (userId, docs, fields, modifier) ->
#     if 'points' in fields
#       change = modifier['$inc']['points']
#       (change > 0 && change <= 10 || change == -10)
#     else if 'gold_stars' in fields
#       (Meteor.user().gold_stars > 0)

# Games.allow
#   insert: (userId, doc) ->
#     if userId && doc.userId == userId
#       (doc.points > 0 && doc.points <= 10)
