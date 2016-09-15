get '/mimics' do
  'Retrieve uploaded photos'

  user_hash = session['user_hash']
  begin
    page = params['page'] || 1
    page = page.to_i
    raise unless page > 0
  rescue => e
    return 400
  end

  return Mimic.
    where(user_hash: user_hash).
    only(:content_hash, :style_hash, :mimic_hash).
    sort(created_at: -1).
    limit(PAGE_COUNT).
    skip(PAGE_COUNT * (page - 1)).
    to_json
end

get '/mimics/new' do
  'Form for new new mimic'

  erb :new
end

get '/mimics/:mimic_id' do
  'View uploaed mimic'

  user_hash = session['user_hash']
  mimic_id = params['mimic_id']

  mimic = Mimic.
    where(user_hash: user_hash).
    only(:content_hash, :style_hash, :mimic_hash).
    find(mimic_id)

  @mimic = mimic.to_json
  erb :show
end

post '/mimics' do
  'COMPLETED,TESTED'
  'Make a beautiful mimic'

  # Persist a mimic record
  # Queue a Sidekiq task

  user_hash = session['user_hash']

  begin
    content_hash = params[:content_hash]
    style_hash = params[:style_hash]
  rescue => e
    return 400, {message: 'invalid'}
  end

  # Object

  mimic = Mimic.new
  mimic.user_hash = user_hash
  mimic.content_hash = content_hash
  mimic.style_hash = style_hash

  # Validations

  unless mimic.valid?
    return 400, mimic.errors.to_json
  end

  # Persit

  mimic.save!    # => To mongo

  # Queue Job

  MimicMaker.perform_async(
    bucket = settings.env['S3']['bucket'],
    mimic.id
  )

  return 201, mimic.to_json(only: [:content_hash, :style_hash])
end
