class SubImage extends Spine.Model
  @configure 'SubImage', 'image', 'x', 'y', 'size'
  
  constructor: ->
    super

  getPixels: ->
    pixels = []
    halfsize = @size / 2
    for i in [1..@size]
      for j in [1..@size]
        x = @x - halfsize + i
        y = @y - halfsize + j
        pixel = @image.getPixel(x, y)
        pixels.push pixel
    return pixels

module.exports = SubImage