class CalendarEventsController < ApplicationController
	def index
		events = Calendar.new.events.map do |event|
			{
				description: event.description,
				summary: event.summary,
				starts: event.start.date_time,
				ends: event.end.date_time,
				location: event.location,
			}
		end
		
		render json: events
	end
end