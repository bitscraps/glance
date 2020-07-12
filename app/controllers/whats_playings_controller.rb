class WhatsPlayingsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    render json: Sonos.whats_playing
  end

  def update
    case params[:to_do]
    when 'play'
      Sonos.play
    when 'pause'
      Sonos.pause
    when 'next'
      Sonos.next_track
    when 'previous'
      Sonos.previous_track
    end

    render json: {}
  end
end
