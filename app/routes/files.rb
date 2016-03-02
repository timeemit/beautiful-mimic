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

  user_hash = nil if system

  bucket = settings.env['S3']['bucket']
  upload = S3Upload.new(
    bucket: bucket,
    user_hash: system ? nil : user_hash, # System "user_hashes" are stored as nil
    file_hash: file_hash
  )

  redirect to(upload.signed_url style)
end
