# From routines_controller.rb
  def build_routine 
    routine = Routine.find(params[:id])
    if signed_in?
      current_user.records << Record.new(routine_id: routine.id, start_date: params[:start_date])
      current_user.routines_used << routine.id
      current_user.save
      unless routine.used_by.include? current_user.id
        routine.used_by << current_user.id
        routine.inc(:download_count, 1)
        routine.save
      end
    end
    #days =  byday routine.days
    days = params[:days]
    start = DateTime.strptime(params[:start_date], '%m/%d/%Y %I:%M %p')
    calendar = RiCal.Calendar do
      event do
        summary routine.title
        url routine.resources
        description routine.purpose + routine.resources
        dtstart     start.with_floating_timezone
        duration    "+PT#{routine.hours}H#{routine.minutes}M" #get_duration that will create the currect string for building the duration
        rrule       :freq => "WEEKLY", :until => start + routine.weeks.week, :byday => days
      end
    end
    #File.open("public/RoutineBuilders.ics", 'w') {|f| f.write(calendar.to_s) }
    #send_file('public/RoutineBuilders.ics', :type => 'text/calendar', :filename => File.basename('RoutineBuilders.ics'))
    respond_to do |format|
      format.ics { send_data(calendar.export, :filename=>"RoutineBuilders.ics", :disposition=>"inline; filename=RoutineBuilders.ics", :type=>'text/calendar')}
    end
    #send_file(calendar.to_ical, :type => 'text/calendar', :filename => File.basename('RoutineBuilders.ics'))
  end
  

