class Sonos
  SPEAKER_ADDRESS = '192.168.86.105'

  def self.whats_playing
    obj = makeRequest('GetPositionInfo')

    album = obj.body
    album = album.gsub(/.*?&lt;upnp:album&gt;/, '')
    album = album.gsub(/&lt;\/upnp:album&gt;.*/, '')
    album = album.gsub(/\&apos;/, "'")
    album = album.gsub(/\&amp;/, "&")
    
    artist = obj.body
    artist = artist.gsub(/.*?&lt;dc:creator&gt;/, '')
    artist = artist.gsub(/&lt;\/dc:creator&gt;.*/, '')
    artist = artist.gsub(/\&apos;/, "'")
    artist = artist.gsub(/\&amp;/, "&")
    
    url = obj.body
    url = url.gsub(/.*?&lt;upnp:albumArtURI&gt;/, '')
    url = url.gsub(/&lt;\/upnp:albumArtURI&gt;.*/, '')
    url = url.gsub(/&amp;amp;/, '&')
    url = getURL(url)

    track = obj.body    
    track = track.gsub(/.*?&lt;dc:title&gt;/, '')
    track = track.gsub(/&lt;\/dc:title.*/, '')
    track = track.gsub(/\&apos;/, "'")
    track = track.gsub(/\&amp;/, "&")

    response = player_status
    
    return "{\"album\": \"#{album}\", \"artist\": \"#{artist}\", \"track\": \"#{track}\", \"url\": \"#{url}\", \"state\": \"#{player_status}\"} "
  end

  def self.pause()
    makeRequest('Pause')
  end

  def self.play()
    makeRequest('Play')
  end

  def self.next_track()
    makeRequest('Next')
  end

  def self.previous_track()
    makeRequest('Previous')
  end

  def self.player_status()
    res = makeRequest('GetTransportInfo')

    if res.body =~ /<CurrentTransportState>PLAYING<\/CurrentTransportState>/
      return 'PLAYING'
    else
      return 'PAUSED'
    end
  end

  private

  def self.wrapInEnvelope(command)
   "<?xml version=\"1.0\" encoding=\"utf-8\"?>
    <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
      <s:Body>
        <u:#{command} xmlns:u=\"urn:schemas-upnp-org:service:AVTransport:1\">
          <InstanceID>0</InstanceID>
          <Channel>Master</Channel>
          <Speed>1</Speed>
        </u:#{command}>
      </s:Body>
    </s:Envelope>"
  end

  def self.getURL(path)
    "http://#{SPEAKER_ADDRESS}:1400#{path}"
  end

  def self.makeRequest(command)
    path = "/MediaRenderer/AVTransport/Control"
    action = "urn:schemas-upnp-org:service:AVTransport:1##{command}"
    uri = URI(getURL(path))

    req = Net::HTTP::Post.new(getURL(path))
    req['SOAPAction'] = action
    req['Content-type'] = 'text/xml; charset=utf8'
    req.body = wrapInEnvelope(command)
  
    res = Net::HTTP.start(SPEAKER_ADDRESS, 1400) {|http|
      res = http.request(req)
    }
  end
end