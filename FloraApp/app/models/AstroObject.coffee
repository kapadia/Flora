ImageSet = require('Fits/lib/fits.imageset')

class AstroObject extends Spine.Model
  @configure 'AstroObject', 'reference', 'imageset'
  
  constructor: ->
    super
    @imageset = new ImageSet()
  
  getUrl: ->
    "http://0.0.0.0:9296/data/png/#{@reference}.png"
  
  getThumbnail: ->
    "http://0.0.0.0:9296/data/png/#{@reference}_sm.png"
    
module.exports = AstroObject