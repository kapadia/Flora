class GaussianBlob extends Spine.Model
  @configure 'GaussianBlob', 'subImageId', 'x0', 'y0', 're', 'F'
  
  constructor: ->
    super

  getPatch: ->
    console.log 'getPatch'

module.exports = GaussianBlob