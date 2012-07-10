require('lib/setup')

AstroObj  = require('models/AstroObject')
AstroObjs = require('controllers/AstroObjects')
Examine   = require('controllers/Examine')

class Flora extends Spine.Stack
  className: "flora"
  
  controllers:
    astroobjs : AstroObjs
    examine   : Examine
    
  routes:
    '/'               : 'astroobjs'
    '/examine/:objid' : 'examine'
  
  default:  'astroobjs'
  
  constructor: ->
    super
    
    AstroObj.fetch()
    Spine.Route.setup()

module.exports = Flora