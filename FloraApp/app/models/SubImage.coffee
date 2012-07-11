class SubImage extends Spine.Model
  @configure 'SubImage', 'image', 'x', 'y', 'size', 'min', 'max', 'pixels', 'sky'
  
  constructor: ->
    super
    @sum = 0
    @pixels = @getPixels()
    [@min, @max] = @getExtremes()
    @pixels = @getPixelsNormalized()
    @sky = @getSky()
  
  getPixels: ->
    pixels = []
    halfsize = @size / 2
    for i in [1..@size]
      for j in [1..@size]
        [x, y] = [@x - halfsize + i, @y - halfsize + j]
        pixel = @image.getPixel(x, y)
        pixels.push pixel
    return pixels
    
  getPixelsNormalized: ->
    pixels = []
    halfsize = @size / 2
    range = @max - @min
    
    for i in [1..@size]
      for j in [1..@size]
        [x, y] = [@x - halfsize + i, @y - halfsize + j]
        pixel = @image.getPixel(x, y)
        pixels.push((pixel - @min) / range)
    return pixels

  getSky: ->
    return @getMedian()
  
  getExtremes: ->
    return [Math.min.apply(Math, @pixels), Math.max.apply(Math, @pixels)]
  
  getMedian: ->
    sorted = []
    for i in [0..@pixels.length - 1]
      sorted.push @pixels[i]
    sorted = sorted.sort()
    return sorted[@size * @size / 2]

module.exports = SubImage