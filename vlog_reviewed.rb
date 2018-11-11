require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'aws-sdk'
require 'bcrypt'
require 'securerandom'

Dotenv.load

class User < ActiveRecord::Base
    has_many :devices
    has_many :vlogs
end

class Device < ActiveRecord::Base
    belongs_to :user
end

class Vlog < ActiveRecord::Base
    belongs_to :user
end

get '/user' do 
  user = Device.find_by_token(params[:token]).user
  user.to_json
end

post '/user' do 
  encrypt_password = BCrypt::Password.create(params[:password])
  u = User.new(email: params[:email],
              nickname: params[:nickname],
              password: encrypt_password)
  u.save
  u.to_json
end

delete '/user' do 
  user = Device.find_by_token(params[:token]).user
  target_user = User.find(params[:id])
  target_user.delete if user == target_user
  true.to_json
end

post '/device' do 
  user = User.where(email: params[:email]).take
  if !user.nil? and (BCrypt::Password.new(user.password) == params[:password])
    d = Device.create(user: user, token: SecureRandom.uuid)
    d.to_json
  else
    "error_1".to_json
  end
end

delete '/device' do 
  user = Device.find_by_token(params[:token]).user
  user.delete
  true.to_json
end

get '/vlog' do 
  v = Vlog.find(params[:id])
  v.to_json
end

post '/vlog' do 
  
  user = Device.find_by_token(params[:token]).user
  file = params[:file]
  path = "#{user.nickname}/#{file[:filename]}"

  s3 = Aws::S3::Resource.new(region:'ap-northeast-1')
  obj = s3.bucket('bgbgbg-bgbg').object(path)
  s = obj.upload_file(file[:tempfile], {acl: 'public-read'})

  v = Vlog.create(user: user, 
                created_at: Time.now,
                logged_at: params[:logged_at],
                feeling: params[:feeling],
                tag: params[:tag],
                video_link: "https://s3-ap-northeast-1.amazonaws.com/bgbgbg-bgbg/#{path}")
  v.to_json
=begin
      v.string    :thumbnail_link
      v.integer   :video_ptime
=end
end
