AstroObj  = require('models/AstroObject')
FITS    = require('Fits')
Utils   = require('lib/Utils')

class Examine extends Spine.Controller
  # @validDestination = "http://ubret.s3.amazonaws.com"
  @validDestination = "http://0.0.0.0:9296"
  @scaleResolution  = 5000
  
  constructor: ->
    super
    
    console.log Raphael
    
    window.addEventListener("message", @receiveXHR, false)
    @bind "dataready", @setupUI
    @bind "imageready", @setupInteraction
    
    @active (params) ->
      @change(params)
      
    @html require('views/examine')
  
  change: (params) ->
    obj = AstroObj.findByAttribute("reference", params.objid)
    return null unless obj?
    
    @requestXHR(params.objid)
  
  requestXHR: (reference) ->
    
    msg =
      reference: reference
    
    # TODO: Timeout needed to wait for iframe to load.  Find way to 
    #       determine if iframe loaded and wait before posting message
    setTimeout ( =>
      $("#dataonwire")[0].contentWindow.postMessage(msg, Examine.validDestination)
    ), 1000
    
  receiveXHR: (e) =>
    msg = e.data
    img = new FITS.File(msg.arraybuffer)
    @header = img.getHeader()
    obj = AstroObj.findByAttribute("reference", msg.reference)
    
    obj.imageset.addImage img
    img.getDataUnit().getFrameWebGL()
    obj.save()
    
    @trigger "dataready", obj
  
  setupUI: (astroobj) ->
    @item = astroobj
    @visualize()
  
  visualize: ->
    @el = document.getElementById("fitsviewer")
    @item.imageset.seek(0)
    @viz = new FITS.Visualize(@item.imageset, @el, 0, 'linear')
    
    @trigger "imageready", @setupInteraction
  
  setupInteraction: ->
    @canvas = $("#fitsviewer .fits-viewer canvas")
    @canvas.click (e) =>
      console.log e.offsetX, @header["NAXIS2"] - e.offsetY
    
module.exports = Examine