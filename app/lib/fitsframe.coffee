
# Collection of functions that are embedded in an iframe on S3.  These functions provide a way to 
# circumvent cross-origin XHR commands.
class DataOnWire
  @validOrigins = ["http://0.0.0.0:9294"]
  
  constructor: ->
    window.addEventListener("message", @receiveMessage, false)
  
  receiveMessage: (e) =>
    console.log "receiveMessage called from DataOnWire"
    reference = e.data.reference
    @requestXHR(reference)
  
  requestXHR: (reference) =>
    console.log 'requestXHR called from DataOnWire'
    
    for filter in ['u', 'g', 'r', 'i', 'z']
      # url = "http://ubret.s3.amazonaws.com/galaxyzoo3/lens/#{reference}_#{filter}_sci.fits.fz"
      url = "http://ubret.s3.amazonaws.com/galaxyzoo3/lens/#{reference}_#{filter}_sci.fits"
      do (url, reference) =>
        xhr = new XMLHttpRequest()
        xhr.open('GET', url)
        xhr.responseType = 'arraybuffer'
        xhr.onload = (e) =>
          msg =
            origin:       url
            reference:    reference
            arraybuffer:  e.currentTarget.response

          @sendMessage(msg)
        xhr.send()
  
  sendMessage: (msg) =>
    console.log 'sendMessage called from DataOnWire'
    window.parent.postMessage(msg, DataOnWire.validOrigins[0])
  
@DataOnWire = DataOnWire