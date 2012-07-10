require('lib/setup')

AstroObj  = require('models/AstroObject')
AstroObjs = require('controllers/AstroObjects')

class Flora extends Spine.Stack
  className: "flora"
  
  controllers:
    astroobjs : AstroObjs
    # examine   : Examine
  
  routes:    
    '/'               : 'flora'
  
  default:  'astroobjects'
  
  constructor: ->
    super
    
    AstroObj.fetch()
    Spine.Route.setup()

module.exports = Flora