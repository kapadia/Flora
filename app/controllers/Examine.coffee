AstroObj  = require('models/AstroObject')
FITS    = require('Fits')
Utils   = require('lib/Utils')

class Examine extends Spine.Controller
  # @validDestination = "http://ubret.s3.amazonaws.com"
  @validDestination = "http://0.0.0.0:9296"
  @scaleResolution  = 5000
  
  constructor: ->
    super
    
    window.addEventListener("message", @receiveXHR, false)
    @bind "dataready", @setupUI
    
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
    astroobj = AstroObj.findByAttribute("reference", msg.reference)
    
    img = new FITS.File(msg.arraybuffer)
    dataunit = img.getDataUnit()
    dataunit.getFrameWebGL()
    
    astroobj.save()
    @trigger("dataready", astroobj)
  
  setupUI: (astroobj) ->
    console.log 'setupUI'
    @item = astroobj
    @visualize()
  
  visualize: ->
    console.log 'visualize'
    @el = document.getElementById("mwv")
    # dataunit = @item.getDataUnit()
    # dataunit.seek(0)
    # @viz = new FITS.Visualize(@item.imageset, @el, @index, 'linear')


  
  updateUrlState: (values) ->
    window.location.hash = "#{window.location.hash}/#{values[0]}/#{values[1]}"
    
  metadata: ->
    header = @item.imageset[0].getHeader()
    
    $("#metadata").append("<table>")
    rowCounter = 0
    for key, value of header.cards
      rowClass = if rowCounter % 2 is 0 then "even" else "odd"
      rowCounter += 1
      $("#metadata").append("<tr><td class='key #{rowClass}'>#{key}</td><td>#{header[key]}</td></tr>")
    $("#metadata").append("</table>")
  
    
module.exports = Examine