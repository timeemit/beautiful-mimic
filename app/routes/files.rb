get '/files/:file_hash' do
  'COMPLETE,TESTED'
  'Retrieve an uploaded photo'

  user_hash = session['user_hash']
  file_hash = params['file_hash']
  style = params['style']
  
  system = ! Upload.
    where(user_hash: user_hash).
    where(file_hash: file_hash).
    exists?

  bucket = settings.env['S3']['bucket']
  upload = S3Upload::Image.new(
    bucket: bucket,
    user_hash: system ? nil : user_hash, # System "user_hashes" are stored as nil
    file_hash: file_hash
  )

  redirect to(upload.signed_url style)
end

get '/files/:file_hash/print' do
  'Retrieve an uploaded photo'

  user_hash = session['user_hash']
  file_hash = params['file_hash']

  system = ! Upload.
    where(user_hash: user_hash).
    where(file_hash: file_hash).
    exists?

  bucket = settings.env['S3']['bucket']
  upload = S3Upload::Image.new(
    bucket: bucket,
    user_hash: system ? nil : user_hash, # System "user_hashes" are stored as nil
    file_hash: file_hash
  )

  canvas_store = "#{settings.env['canvaspop']['url']}/pull?image_url="
  canvas_store += CGI.escape(upload.signed_url('original'))
  canvas_store += "&access_key=#{settings.env['canvaspop']['access_key']}"
  redirect to canvas_store
end
