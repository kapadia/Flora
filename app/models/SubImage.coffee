class SubImage extends Spine.Model
  @configure 'Patch', 'reference', 'x', 'y', 'size'
  
  constructor: ->
    super

  getPixels: ->
    pixels = []
    for i in [1..100]
      pixels.push(@reference.getData().getPixel())
    return pixels

module.exports = SubImage