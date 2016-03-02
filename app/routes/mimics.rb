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
    to_json(except: :_id)
end

get '/mimics/:content_hash-:style_hash' do
  'View uploaed mimic'

  user_hash = session['user_hash']
  content_hash = params['content_hash']
  style_hash = params['style_hash']

  @mimic = Mimic.
    where(user_hash: user_hash).
    where(content_hash: content_hash).
    where(style_hash: style_hash).
    only(:content_hash, :style_hash, :mimic_hash).
    limit(1).first.to_json(except: :_id)

  erb :show
end

get '/mimics/new' do
  'Form for new new mimic'

  erb :new
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

  return 201
end
