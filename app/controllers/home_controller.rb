class HomeController < ApplicationController
  def index
    if signed_in?
      redirect_to routines_path
    end
    @users = User.all
    @routine = Routine.desc(:download_count).first
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
  end
end
