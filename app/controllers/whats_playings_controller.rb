class WhatsPlayingsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show

    render json: whatsPlaying
  end

  def update
    case params[:to_do]
    when 'play'
      play
    when 'pause'
      pause
    when 'next'
      next_track
    when 'previous'
      previous_track
    end

    render json: {}
  end

  def wrapInEnvelope(body)
   "<?xml version=\"1.0\" encoding=\"utf-8\"?>
    <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
      <s:Body>#{body}</s:Body>
    </s:Envelope>"
  end

  def getURL(path)
    host = '192.168.86.105'
    "http://#{host}:1400#{path}"
  end

  def makeRequest(path, action, body, response)
    wrappedBody = wrapInEnvelope(body)
  
    uri = URI(getURL(path))

    req = Net::HTTP::Post.new(getURL(path))
    req['SOAPAction'] = action
    req['Content-type'] = 'text/xml; charset=utf8'
    req.body = wrappedBody
  
    res = Net::HTTP.start('192.168.86.105', 1400) {|http|

      res = http.request(req)
      
      album = res.body
      album = album.gsub(/.*?&lt;upnp:album&gt;/, '')
      album = album.gsub(/&lt;\/upnp:album&gt;.*/, '')
      album = album.gsub(/\&apos;/, "'")
      album = album.gsub(/\&amp;/, "&")
      
      artist = res.body
      artist = artist.gsub(/.*?&lt;dc:creator&gt;/, '')
      artist = artist.gsub(/&lt;\/dc:creator&gt;.*/, '')
      artist = artist.gsub(/\&apos;/, "'")
      artist = artist.gsub(/\&amp;/, "&")
      
      url = res.body
      url = url.gsub(/.*?&lt;upnp:albumArtURI&gt;/, '')
      url = url.gsub(/&lt;\/upnp:albumArtURI&gt;.*/, '')
      url = url.gsub(/&amp;amp;/, '&')
      url = getURL(url)

      track = res.body    
      track = track.gsub(/.*?&lt;dc:title&gt;/, '')
      track = track.gsub(/&lt;\/dc:title.*/, '')
      track = track.gsub(/\&apos;/, "'")
      track = track.gsub(/\&amp;/, "&")

      response = player_status
      
      return "{\"album\": \"#{album}\", \"artist\": \"#{artist}\", \"track\": \"#{track}\", \"url\": \"#{url}\", \"state\": \"#{player_status}\"} "
    }
  end

  def whatsPlaying()
    body = '<u:GetPositionInfo xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
              <InstanceID>0</InstanceID>
              <Channel>Master</Channel>
            </u:GetPositionInfo>'
    
    action = 'urn:schemas-upnp-org:service:AVTransport:1#GetPositionInfo'
    path = "/MediaRenderer/AVTransport/Control"
    
    obj = makeRequest(path, action, body, 'u:GetPositionInfoResponse')
    metadata = obj
  end

  def pause()
    body = '<?xml version="1.0" encoding="utf-8"?>
            <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
              <s:Body>
                <u:Pause xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
                  <InstanceID>0</InstanceID>
                </u:Pause>
              </s:Body>
            </s:Envelope>'

    action = 'urn:schemas-upnp-org:service:AVTransport:1#Pause'
    path = "/MediaRenderer/AVTransport/Control"

    wrappedBody = wrapInEnvelope(body)
  
    uri = URI(getURL(path))

    req = Net::HTTP::Post.new(getURL(path))
    req['SOAPAction'] = action
    req['Content-type'] = 'text/xml; charset=utf8'
    req.body = body

    res = Net::HTTP.start('192.168.86.105', 1400) {|http|
      res = http.request(req)
    }
  end

  def play()
    body = '<?xml version="1.0" encoding="utf-8"?>
            <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
              <s:Body>
                <u:Play xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
                  <InstanceID>0</InstanceID>
                  <Speed>1</Speed>
                </u:Play>
              </s:Body>
            </s:Envelope>'

    action = 'urn:schemas-upnp-org:service:AVTransport:1#Play'
    path = "/MediaRenderer/AVTransport/Control"

    wrappedBody = wrapInEnvelope(body)
  
    uri = URI(getURL(path))

    req = Net::HTTP::Post.new(getURL(path))
    req['SOAPAction'] = action
    req['Content-type'] = 'text/xml; charset=utf8'
    req.body = body

    res = Net::HTTP.start('192.168.86.105', 1400) {|http|
      res = http.request(req)
    }
  end

  def next_track()
    body = '<?xml version="1.0" encoding="utf-8"?>
            <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
              <s:Body>
                <u:Next xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
                  <InstanceID>0</InstanceID>
                  <Speed>1</Speed>
                </u:Next>
              </s:Body>
            </s:Envelope>'

    action = 'urn:schemas-upnp-org:service:AVTransport:1#Next'
    path = "/MediaRenderer/AVTransport/Control"

    wrappedBody = wrapInEnvelope(body)
  
    uri = URI(getURL(path))

    req = Net::HTTP::Post.new(getURL(path))
    req['SOAPAction'] = action
    req['Content-type'] = 'text/xml; charset=utf8'
    req.body = body

    res = Net::HTTP.start('192.168.86.105', 1400) {|http|
      res = http.request(req)
    }
  end

  def previous_track()
    body = '<?xml version="1.0" encoding="utf-8"?>
            <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
              <s:Body>
                <u:Previous xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
                  <InstanceID>0</InstanceID>
                  <Speed>1</Speed>
                </u:Previous>
              </s:Body>
            </s:Envelope>'

    action = 'urn:schemas-upnp-org:service:AVTransport:1#Previous'
    path = "/MediaRenderer/AVTransport/Control"

    wrappedBody = wrapInEnvelope(body)
  
    uri = URI(getURL(path))
  
    req = Net::HTTP::Post.new(getURL(path))
    req['SOAPAction'] = action
    req['Content-type'] = 'text/xml; charset=utf8'
    req.body = body

    res = Net::HTTP.start('192.168.86.105', 1400) {|http|
      res = http.request(req)
    }
  end

  def player_status()
    body = '<?xml version="1.0" encoding="utf-8"?>
            <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
              <s:Body>
                <u:GetTransportInfo xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
                  <InstanceID>0</InstanceID>
                  <Speed>1</Speed>
                </u:GetTransportInfo>
              </s:Body>
            </s:Envelope>'

    action = 'urn:schemas-upnp-org:service:AVTransport:1#GetTransportInfo'
    path = "/MediaRenderer/AVTransport/Control"

    wrappedBody = wrapInEnvelope(body)
  
    uri = URI(getURL(path))

    req = Net::HTTP::Post.new(getURL(path))
    req['SOAPAction'] = action
    req['Content-type'] = 'text/xml; charset=utf8'
    req.body = body

    res = Net::HTTP.start('192.168.86.105', 1400) {|http|
      res = http.request(req)

      if res.body =~ /<CurrentTransportState>PLAYING<\/CurrentTransportState>/
        return 'PLAYING'
      else
        return 'PAUSED'
      end
    }

    res
  end
end
