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
    gal = AstroObj.findByAttribute("reference", params.objid)
    return null unless gal?
    
    if params['min']? and params['max']?
      return

    if gal.hasImageSet()
      @setupUI(gal)
    else
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
    gal = AstroObj.findByAttribute("reference", msg.reference)
    
    gal.imageset.addImage(new FITS.File(msg.arraybuffer))
    
    dataunit = img.getDataUnit()
    dataunit.getFrame()
    gal.stats.push(new FITS.ImageStats(dataunit))
    gal.save()
    
    @trigger("dataready", gal) if gal.imageset.count is 5
  
  cleanUI: ->
    @buttons.empty()
    @slider.empty()
    @markerPlot.empty()
    @histogramPlot.empty()
  
  setupUI: (galaxy) ->
    @item = galaxy
    @cleanUI()
    
    @visualize()
    @histogram()
    @metadata()
    @sed()
    
    @item.imageset.seek(0)
    @item.imageset.getExtremes()
    
    $("#stretch").change( (e) =>
      @item.imageset.seek(0)
      @viz = new FITS.Visualize(@item.imageset, @el, @index, e.currentTarget.value)
    )
    
    counter = -1
    for filter, image of @item.imageset.images
      id = filter.replace(/[^a-zA-Z0-9]/g, "")
      html = "<input type='radio' id='#{id}' name='filter' class='filter-toggle' data-filter='#{filter}' data-index='#{counter += 1}'/><label for='#{id}'>#{filter}</label>"
      @buttons.append(html)
    
    $("input[name='filter']").change( (e) =>
      filter  = e.currentTarget.dataset['filter']
      @index  = e.currentTarget.dataset['index']
      @item.imageset.seek(0)
      @viz = new FITS.Visualize(@item.imageset, @el, @index, $("#stretch").val())
      @histogram()
    )
    
    @buttons.buttonset()
  
  visualize: ->
    @el = document.getElementById("mwv")
    @item.imageset.seek(0)
    @index ?= 0
    @viz = new FITS.Visualize(@item.imageset, @el, @index, 'linear')


  
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