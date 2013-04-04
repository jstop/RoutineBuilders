desc "This task is called by the Heroku cron add-on"
task :call_page => :environment do
   p 'task running'
   uri = URI.parse('http://www.routinebuilders.com/')
   Net::HTTP.get(uri)
   p 'task ran'
 end
