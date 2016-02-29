get '/uploads' do
  'COMPLETE,TESTED'
  'Retrieve uploaded photos'

  user_hash = session['user_hash']
  begin
    page = params['page'] || 1
    page = page.to_i
    raise unless page > 0
  rescue => e
    return 400
  end

  return Upload.
    in(user_hash: [user_hash, nil]).
    only(:filename, :file_hash, :created_at).
    sort(created_at: -1).
    limit(PAGE_COUNT).
    skip(PAGE_COUNT * (page - 1)).
    to_json(except: :_id)
end

get '/uploads/:file_hash' do
  'COMPLETE,TESTED'
  'Retrieve an uploaded photo'

  user_hash = session['user_hash']
  file_hash = params['file_hash']
  style = params['style']

  bucket = settings.env['S3']['bucket']
  upload = S3Upload.new(
    bucket: bucket,
    user_hash: upload.user_hash, # May be nil in the case of system images
    file_hash: file_hash
  )

  redirect to(upload.signed_url style)
end

post '/uploads' do
  'COMPLETE,TESTED'
  'Upload a new, private photo'

  # Processes a thumbnail and preview pics
  # Uploads file to S3
  # Saves handle to MongoDB record
  # Associate record with `user_hash`

  bucket = settings.env['S3']['bucket']
  user_hash = session['user_hash']

  # Ensure params structure

  begin
    file = params['file'][:tempfile]
    filename = params['file'][:filename]
  rescue => e
    return 400
  end

  uploader = Uploader.new(bucket, user_hash, filename, file)

  # Validations

  unless uploader.upload.valid?
    return 400, uploader.upload.errors.to_json
  end

  unless uploader.s3_upload.valid?
    return 400, uploader.s3_upload.errors.to_json
  end

  # Persit
  uploader.save!

  return uploader.upload.to_json(only: [:filename, :file_hash, :created_at])
end
