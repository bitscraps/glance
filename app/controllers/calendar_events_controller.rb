class CalendarEventsController < ApplicationController
  def index
    events = Calendar.new.events.map do |event|
      {
        when: get_short_when(event.start.date_time, event.end.date_time),
        description: event.description,
        summary: event.summary,
        starts: event.start.date_time.strftime("%H:%M"),
        ends: event.end.date_time.strftime("%H:%M"),
        location: event.location,
      }
    end

    if events.first[:when] == 'LATER'
      events.first[:when] == 'NEXT'
    else
      if events.second[:when] == 'LATER'
        events.second[:when] == 'NEXT'
      end
    end

    render json: events
  end

  private

  def get_short_when(starts, ends)
    now = Time.now.utc

    short = if starts < Time.now.utc && ends > Time.now.utc
      'NOW'
    elsif starts.today?
      'LATER'
    elsif starts.wday == (Time.now + 1.day).wday
      'TOMORROW'
    else
      starts.strftime("%A").upcase
    end
  end
end