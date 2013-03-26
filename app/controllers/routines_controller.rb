class RoutinesController < ApplicationController
  # GET /routines
  # GET /routines.json
  def index
    puts 'hello'
    puts ENV['GMAIL_USERNAME']
    @routines = Routine.all.desc(:download_count)

    respond_to do |format|
      format.html # index.html.erb
     # format.json { render json: @routines }
    end
  end
  
  def filtered 
    tag_ids = params[:tokens].split(",")
    @tags = []
    tag_ids.each do |tag|
      @tags << Tag.find(tag).name
    end
    @routines = Routine.all(:tags => @tags).desc(:download_count)

    respond_to do |format|
      format.html # filtered.html.erb
     # format.json { render json: @routines }
    end
  end

  def cal
    send_file icalData, :filename => 'RoutineBuilders.ics'
    respond_to do |format|
      format.ics { send_file(icalData, :filename => 'RoutineBuilders.ics')}
    end
  end

  # GET /routines/1
  # GET /routines/1.json
  def show
    @routine = Routine.find(params[:id])
    @comment = Comment.new( routine: @routine)
    unless @routine.days.first.nil?
      @dayMap = {'SU' => 'Sun', 'MO' => 'Mon', 'TU' => 'Tue', 'WE' => 'Wed', 'TH' => 'Thu', 'FR' => 'Fri', 'SA' => 'Sat'}
      date = Date.parse(@dayMap[@routine.days.first])
      if !date.today?
        delta = date > Date.today ? 0 : 7
      else 
        delta = 0
      end
      @default_start_date = (date + delta).strftime("%m/%d/%Y ") + @routine.start_time
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @routine }
    end
  end

  # GET /routines/new
  # GET /routines/new.json
  def new
    @routine = Routine.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @routine }
    end
  end

  # GET /routines/1/edit
  def edit
    @routine = Routine.find(params[:id])
    authorize! :manage, @routine
  end

  # POST /routines
  # POST /routines.json
  def create
    tag_ids = params[:tokens].split(",") #Can i move this logic into the model
    #how do you handle when user sends non existant tag
    params[:routine][:tags] = []
    tag_ids.each do |tag_id|
      tag = Tag.find(tag_id)
      params[:routine][:tags] << tag.name unless tag.nil? 
    end
    @routine = Routine.new(params[:routine])
    if signed_in?
      @routine.user = current_user
    end
    @routine.save

    respond_to do |format|
      if @routine.save
        format.html { redirect_to @routine, notice: 'Routine was successfully created.' }
        format.json { render json: @routine, status: :created, location: @routine }
      else
        format.html { render action: "new" }
        format.json { render json: @routine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /routines/1
  # PUT /routines/1.json
  def update
    @routine = Routine.find(params[:id])
    #@routine.update_tags(params[:routine][:tags])
    @tags = []
    @tag_ids = params[:tokens].split(",")
    @tag_ids.each do |tag|
      @tags << Tag.find(tag).name
    end
    params[:routine][:tags] = @tags
    respond_to do |format|
      if @routine.update_attributes(params[:routine])
        format.html { redirect_to @routine, notice: 'Routine was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @routine.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /routines/1
  # DELETE /routines/1.json
  def destroy
    @routine = Routine.find(params[:id])
    @routine.destroy

    respond_to do |format|
      format.html { redirect_to routines_url }
      format.json { head :no_content }
    end
  end

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
    File.open("public/RoutineBuilders.ics", 'w') {|f| f.write(calendar.to_s) }
    send_file('public/RoutineBuilders.ics', :type => "text/calendar", :filename => File.basename('RoutineBuilders.ics'))
  end
  

  protected

  def byday(days)
    @dayMap = {'SU' => 'Sun', 'MO' => 'Mon', 'TU' => 'Tue', 'WE' => 'Wed', 'TH' => 'Thu', 'FR' => 'Fri', 'SA' => 'Sat'}
    bydays = []
    days.each do |day|
      bydays << @dayMap[day]
    end
    bydays
  end

  def icalData
    the_calendar = RiCal.Calendar do |cal|

      cal.event do |event|
        event.description = "MA-6 First US Manned Spaceflight"
        event.dtstart =  DateTime.parse("2/20/1962 14:47:39")
        event.dtend = DateTime.parse("2/20/1962 19:43:02")
        event.location = "Cape Canaveral"
        event.add_attendee "john....@nasa.gov"
        event.alarm do
          description "Segment 51"
        end
      end
    end
    the_calendar.export
  end
end
