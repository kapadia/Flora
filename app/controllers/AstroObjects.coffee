AstroObj  = require('models/AstroObject')
Utils     = require('lib/Utils')

class AstroObjects extends Spine.Controller
  
  constructor: ->
    super
    
    @sampleData()
    @render()
    
  # Generate sample data for development and demonstration (using FITS images from Lens Zoo group)
  sampleData: ->
    # CFHTLS_01_g_sci.fits
    for i in [1..30]
      digit = Utils.pad("#{i}", 2)
      item = new Galaxy {reference: "CFHTLS_#{digit}"}
      item.save()
    
  render: ->
    @html require('views/galaxies')(Galaxy.all())
    
  examine: (e) =>
    @navigate '/examine', e.currentTarget.dataset.reference
  
module.exports = AstroObjects