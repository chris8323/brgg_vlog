require 'sinatra'
require 'passenger'
require 'sinatra/activerecord'
require 'sqlite3'
require 'json'
require 'will_paginate'
require 'dotenv'

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
  v = Vlog.find(params[:id])
end

get '/vlog_list' do
  Vlogs.paginate(:page => params[:page], :per_page => 30).to_json
end

post '/submit' do  
  
  v = Vlog.new
  v.create_date = Time.now
  v.log_date = params[:log_date]
  v.feeling = params[:feeling]
  v.tag = params[:tag]
  v.video_link = video_path
  v.thumbnail_link = thumb_path
  v.save
  
  v.to_json
end

