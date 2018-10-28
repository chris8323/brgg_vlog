require 'sinatra'
require 'sinatra/activerecord'
require 'sqlite3'
require 'json'
require 'will_paginate'

class User < ActiveRecord::Base
    has_many :devices
    has_many :vlogs
end

class Device < ActiveRecord::Base
    belongs_to :users
end

class Vlog < ActiveRecord::Base
    belongs_to :users
end

get '/vlog' do 
  device = Device.find_by_token(params[:token])
  user = device.user
  v = Vlog.find(params[:id])
  if user == v.user
    v.to_json
  else
    "너는 볼 수 없다"
  end
end

get '/valid_list' do
  device = Device.find_by_token(params[:token])
  user = device.user
  user.vlogs.paginate(:page => params[:page], :per_page => 30).to_json
  end

end

post '/submit' do  
  token = Token.find_by_token(params[:token])
  user = token.first

# 파일 저장하기

  v = Vlog.new
  v.user = user
  v.create_date = params[:create_date]
  v.log_date = params[:log_date]
  v.feeling = params[:feeling]
  v.tag = params[:tag]
  v.video_link = video_path
  v.thumbnail_link = thumb_path
  v.save
  
  v.to_json
end

