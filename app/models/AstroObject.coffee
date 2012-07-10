class AstroObject extends Spine.Model
  @configure 'AstroObject', 'reference'
  
  constructor: ->
    super
  
  getUrl: ->
    # "http://ubret.s3.amazonaws.com/galaxyzoo3/lens/#{@reference}.png"
    "http://0.0.0.0:9296/data/png/#{@reference}.png"
  
  getThumbnail: ->
    # "http://ubret.s3.amazonaws.com/galaxyzoo3/lens/#{@reference}_sm.png"
    "http://0.0.0.0:9296/data/png/#{@reference}_sm.png"
    
module.exports = AstroObject