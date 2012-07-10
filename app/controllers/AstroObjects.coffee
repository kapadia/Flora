AstroObj  = require('models/AstroObject')
Utils     = require('lib/Utils')

class AstroObjects extends Spine.Controller
  
  constructor: ->
    super
    
    @sampleData()
    @render()
    
  # Generate sample data for development and demonstration
  sampleData: ->
    item = new AstroObj {reference: "m101"}
    item.save()
    
  render: ->
    @html require('views/astroobjs')(AstroObj.all())
    
  examine: (e) =>
    @navigate '/examine', e.currentTarget.dataset.reference
  
module.exports = AstroObjects