
# Collection of utility functions
Utils =
  pad: (str, num) ->
    excess = num - str.length
    return str unless excess > 0
    padding = ""
    num -= 1
    while num
      padding += "0"
      num -= 1
    return padding + str


  scale: (value, minimum, maximum, resolution) ->
    return resolution * (value - minimum) / (maximum - minimum)

  inverseScale: (value, minimum, maximum, resolution) ->
    return value * (maximum - minimum) / resolution + minimum
    
module.exports = Utils