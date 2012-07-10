
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
    
    url = "http://0.0.0.0:9296/data/#{reference}.fits"
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