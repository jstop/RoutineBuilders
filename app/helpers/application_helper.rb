module ApplicationHelper

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def s3_form_tag(options = {}) 
    bucket            = 'dev-routines'
    access_key_id     = ENV['AWS_ACCESS_KEY_ID']
    secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    key               = options[:key] || ''
    content_type      = options[:content_type] || '' # Defaults to binary/octet-stream if blank
    redirect          = options[:redirect] || 'localhost:3000/' 
    acl               = options[:acl] || 'public-read'
    expiration_date   = options[:expiration_date].strftime('%Y-%m-%dT%H:%M:%S.000Z') if options[:expiration_date]
    max_filesize      = options[:max_filesize] || 671088640 # 5 gb
    submit_button     = options[:submit_button] || '<input type="submit" value="Upload">'
 
    options[:form] ||= {}
    options[:form][:id] ||= 'upload-form'
    options[:form][:class] ||= 'upload-form'
 
    policy = Base64.encode64(
      "{'expiration': '#{expiration_date}',
        'conditions': [
          {'bucket': '#{bucket}'},
          ['starts-with', '$key', '#{key}'],
          {'acl': '#{acl}'},
          {'success_action_redirect': '#{redirect}'},
          ['starts-with', '#{content_type}', ''],
          ['content-length-range', 0, #{max_filesize}]
        ]
      }").gsub(/\n|\r/, '') 
 
      signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), secret_access_key, policy)).gsub("\n","")
      out = ""
      out << %(
        <form action="https://#{bucket}.s3.amazonaws.com/" method="post" enctype="multipart/form-data" id="#{options[:form][:id]}" class="#{options[:form][:class]}" style="#{options[:form][:style]}">
        <input type="hidden" name="key" value="#{key}">
        <input type="hidden" name="AWSAccessKeyId" value="#{access_key_id}">
        <input type="hidden" name="acl" value="#{acl}">
        <input type="hidden" name="success_action_redirect" value="#{redirect}">
        <input type="hidden" name="policy" value="#{policy}">
        <input type="hidden" name="signature" value="#{signature}">
        <input name="file" type="file">#{submit_button}
        </form>
      )
  end
  def s3_form
    out = ""
    out << %(
      <form action="https://s3-bucket.s3.amazonaws.com/" method="post" enctype="multipart/form-data">
      <input type="hidden" name="key" value="uploads/${filename}">
      <input type="hidden" name="AWSAccessKeyId" value="YOUR_AWS_ACCESS_KEY"> 
      <input type="hidden" name="acl" value="private"> 
      <input type="hidden" name="success_action_redirect" value="http://localhost/">
      <input type="hidden" name="policy" value="YOUR_POLICY_DOCUMENT_BASE64_ENCODED">
      <input type="hidden" name="signature" value="YOUR_CALCULATED_SIGNATURE">
      <input type="hidden" name="Content-Type" value="image/jpeg">
      <!-- Include any additional input fields here -->

      File to upload to S3: 
      <input name="file" type="file"> 
      <br> 
      <input type="submit" value="Upload File to S3"> 
      </form>
    )
    out.html_safe
  end
end
