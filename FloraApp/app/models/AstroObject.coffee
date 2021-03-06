ImageSet = require('Fits/lib/fits.imageset')

class AstroObject extends Spine.Model
  @configure 'AstroObject', 'reference', 'imageset'
  
  constructor: ->
    super
    @imageset = new ImageSet()
  
  getUrl: ->
    # "http://ubret.s3.amazonaws.com/data/png/#{@reference}.png"
    "data/png/#{@reference}.png"
  
  getThumbnail: ->
    # "http://ubret.s3.amazonaws.com/data/png/#{@reference}.png"
    "data/png/#{@reference}_sm.png"
    
module.exports = AstroObject