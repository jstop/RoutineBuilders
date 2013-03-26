=begin
if Rails.env == "production" 
   S3_CREDENTIALS = { :access_key_id => ENV['AWS_ACCESS_KEY_ID'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'], :bucket => "production-routines"} 
 else 
   S3_CREDENTIALS = { :access_key_id => ENV['AWS_ACCESS_KEY_ID'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'], :bucket => "dev-routines"} 
end
service = S3::Service.new(:access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                          :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'])
=end
