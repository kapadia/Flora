FITS      = require('Fits')
AstroObj  = require('models/AstroObject')
SubImage  = require('models/SubImage')
Gaussian2D = require('models/Gaussian2D')

class Examine extends Spine.Controller
  @validDestination = "http://0.0.0.0:9296"
  @subImageSize  = 10
  
  constructor: ->
    super
    
    # TODO: Arcsinh would be better, but no function for raw pixels yet
    @stretch = 'linear'
    
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
    
    # Testing canvas pixel manipulate
    closeup = $("#closeup")[0]
    gaussian = $("#gaussian2d")[0]
    difference = $("#difference")[0]

    [closeup.width, closeup.height]       = [Examine.subImageSize, Examine.subImageSize]
    [gaussian.width, gaussian.height]     = [Examine.subImageSize, Examine.subImageSize]
    [difference.width, difference.height] = [Examine.subImageSize, Examine.subImageSize]
    
    @contextCloseup = closeup.getContext('2d')
    @contextGaussian = gaussian.getContext('2d')
    @contextDifference = difference.getContext('2d')

  visualize: ->
    @el = document.getElementById("fitsviewer")
    @item.imageset.seek(0)
    
    # MAGIC, zero because only one FITS file
    @viz = new FITS.Visualize(@item.imageset, @el, 0, @stretch)
    
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
        size: Examine.subImageSize
        min: null
        max: null
        median: null
      subImage = new SubImage params
      subImage.save()
      subImagePixels = subImage.pixels
      
      
      blob = new Gaussian2D {subImageId: subImage.id}
      blob.save()
      
      guessedre = 2
      guessedsigma = guessedre * Math.sqrt(2 * Math.log(2))
      guessedFlux = (1.0 - subImage.sky) * (2 * Math.PI * guessedsigma * guessedsigma)
      guessedsky = subImage.sky

      p0 = [0, 0, guessedre, guessedFlux, guessedsky]
      
      objfunc = (p) ->
        if p[0] < 0 or p[0] > 5
          return (1e10 for i in [1..subImage.pixels.length])
        console.log p
        chi = blob.getChi(p[0], p[1], p[2], p[3], p[4])
        return optimize.vector.dot(chi, chi)
        
      [dx, dy, re, flux, sky] = optimize.fmin(objfunc, p0)
      modelPatch = blob.getModelPatch(dx, dy, re, flux, sky)
      chi = blob.getChi(dx, dy, re, flux, sky)
      console.log chi
      
      [min, max] = subImage.getExtremes()
      
      imageDataCloseup    = @contextCloseup.getImageData(0, 0, Examine.subImageSize, Examine.subImageSize)
      imageDataGaussian   = @contextGaussian.getImageData(0, 0, Examine.subImageSize, Examine.subImageSize)
      imageDataDifference = @contextDifference.getImageData(0, 0, Examine.subImageSize, Examine.subImageSize)
      
      pixelsCloseup     = imageDataCloseup.data
      pixelsGaussian    = imageDataGaussian.data
      pixelsDifference  = imageDataDifference.data
      
      length = pixelsCloseup.length
      for i in [0..length - 1] by 4
        index = i / 4
        
        valueCloseup = 255 * (subImagePixels[index] - min) / (max - min)
        pixelsCloseup[i] = valueCloseup
        pixelsCloseup[i + 1] = valueCloseup
        pixelsCloseup[i + 2] = valueCloseup
        pixelsCloseup[i + 3] = 255
        
        valueGaussian = 255 * (modelPatch[index] - min) / (max - min)
        pixelsGaussian[i] = valueGaussian
        pixelsGaussian[i + 1] = valueGaussian
        pixelsGaussian[i + 2] = valueGaussian
        pixelsGaussian[i + 3] = 255
        
        valueDifference = 255 * (chi[index] - min) / (max - min)
        pixelsDifference[i] = valueDifference
        pixelsDifference[i + 1] = valueDifference
        pixelsDifference[i + 2] = valueDifference
        pixelsDifference[i + 3] = 255
      
      console.log pixelsDifference
      imageDataCloseup.data     = pixelsCloseup
      imageDataGaussian.data    = pixelsGaussian
      imageDataDifference.data  = pixelsDifference
      @contextCloseup.putImageData(imageDataCloseup, 0, 0)
      @contextGaussian.putImageData(imageDataGaussian, 0, 0)
      @contextDifference.putImageData(imageDataDifference, 0, 0)
    
module.exports = Examine