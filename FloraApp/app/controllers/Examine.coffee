FITS    = require('Fits')
AstroObj  = require('models/AstroObject')
SubImage  = require('models/SubImage')

class Examine extends Spine.Controller
  # @validDestination = "http://ubret.s3.amazonaws.com"
  @validDestination = "http://0.0.0.0:9296"
  @scaleResolution  = 5000
  
  constructor: ->
    super
    
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
    @image  = img.getDataUnit()
    obj = AstroObj.findByAttribute("reference", msg.reference)
    
    obj.imageset.addImage img
    obj.save()
    
    @trigger "dataready", obj
  
  setupUI: (astroobj) ->
    @item = astroobj
    @visualize()
    closeup = $("#closeup")[0]
    @closeup = closeup.getContext('2d')
    imgData = @closeup.createImageData(10, 10)
    console.log imgData
  
  visualize: ->
    @el = document.getElementById("fitsviewer")
    @item.imageset.seek(0)
    @viz = new FITS.Visualize(@item.imageset, @el, 0, 'linear')
    
    @trigger "imageready", @setupInteraction
  
  setupInteraction: ->
    @canvas = $("#fitsviewer .fits-viewer canvas")
    @image.frame = 0
    @canvas.click (e) =>
      [i,j] = [e.offsetX, e.offsetY]
      [x, y] = [i, @header["NAXIS2"] - j]
      
      # MAGIC SubImage size 10 pixels
      params =
        image: @image
        x: x
        y: y
        size: 10
      subImage = new SubImage params
      subImage.save()
      console.log(x, y, subImage.getPixels())
    
module.exports = Examine