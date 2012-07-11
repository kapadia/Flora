SubImage  = require('models/SubImage')

class Gaussian2D extends Spine.Model
  @configure 'Gaussian2D', 'subImageId'
  
  constructor: ->
    super
    item = SubImage.find(@subImageId)
    @size = item.size
    @datapixels = item.getPixelsNormalized()
    [@min, @max] = @getExtremes()
    @sky = @getSky()

  getModelPatch: (x0, y0, re, F, sky) ->
    pixels = []
    
    halfsize = @size / 2
    
    sigma = re / Math.sqrt(2 * Math.log(2))
    sigma2 = sigma * sigma
    coeff = F / (2 * Math.PI * sigma2)
    
    for i in [1..@size]
      for j in [1..@size]
        [x, y] = [i - halfsize, j - halfsize]
        [xp, yp] = [x - x0, y - y0]
        
        pixel = coeff * Math.exp(-0.5 * (xp * xp + yp * yp) / sigma2) + sky
        pixels.push pixel
    return pixels
  
  getChi: (x0, y0, re, F, sky) ->
    modelpixels = @getModelPatch(x0, y0, re, F, sky)
    pixels = []
    for i in [0..@datapixels.length - 1]
      pixels.push(@datapixels[i] - modelpixels[i])
    return pixels

  getSky: ->
    return @getMedian()

  getExtremes: ->
    return [Math.min.apply(Math, @datapixels), Math.max.apply(Math, @datapixels)]

  getMedian: ->
    sorted = []
    for i in [0..@datapixels.length - 1]
      sorted.push @datapixels[i]
    sorted = sorted.sort()
    return sorted[@size * @size / 2]

module.exports = Gaussian2D