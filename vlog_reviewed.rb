require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'aws-sdk'
require 'bcrypt'
require 'securerandom'
require 'will_paginate'

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

# 유저 정보 조회
get '/user' do 
  user = Device.find_by_token(params[:token]).user
  user.to_json
end

# 회원 가입
# - 아이디 중복 체크 필요
# - 비밀번호 validation check?

post '/user' do 
  encrypt_password = BCrypt::Password.create(params[:password])
  u = User.new(email: params[:email],
              nickname: params[:nickname],
              password: encrypt_password)
  u.save
  u.to_json
end

# 회원 탈퇴 > 초기에는 지원하지 않는게 좋겠다?
delete '/user' do 
  user = Device.find_by_token(params[:token]).user
  target_user = User.find(params[:id])
  target_user.delete if user == target_user
  true.to_json
end


# Login 기능
# - 현재는 email / password 기반 로그인
# - 차후 Facebook Login으로 변경 예정
post '/device' do 
  user = User.where(email: params[:email]).take
  if !user.nil? and (BCrypt::Password.new(user.password) == params[:password])
    d = Device.create(user: user, token: SecureRandom.uuid)
    d.to_json
  else
    "회원가입되어있지 않은 아이디입니다.".to_json
  end
end

delete '/device' do 
  user = Device.find_by_token(params[:token]).user
  user.delete
  true.to_json
end

# Vlog List > Detail
# - Validation Check: Token.user == Vlog.user ?

get '/vlog' do 
  v = Vlog.find(params[:id])
  v.to_json
end

# vlog 작성하기
# - FilePath는 Device의 링크??
post '/vlog' do 
  user = Device.find_by_token(params[:token]).user
  file = params[:file]
  #path = "#{user.nickname}/#{file[:filename]}" 
  path = "video/#{user.id}/#{file[:filename]}" #video upload path 수정

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

# Vlog List 호출하기 (Calendar view 적용)
# 이를 기준으로 특정 날짜를 클릭했을 때, write로 redirect될 지, detail로 redirect될 지 결정된다.
get '/list_by_month' do
  device = Device.find_by_token(params[:token])
  unless device.nill?
    user = device.user
    unless user.nill?
      # :yesr와 :month는 Fuse에서 User가 선택한 값
      vlog.where(:user_id => user.id,
                :log_date.year => params[:yeaer], ### 문법에 맞는가??? 확인 필요...
                :log_date.month => params[:month], ### 문법에 맞는가??? 확인 필요...
                ).to_json      
      
    else   
      error = {:err_code => '002', 
        :err_msg => '가입되어있지 않은 User입니다.'}
      error.to_json   
    end
  else
    error = {:err_code => '003', 
      :err_msg => '등록되어 있지 않은 Device입니다.'}
    error.to_json 
  end
end

# Vlog List 호출하기 (Filter 적용)
get '/list_by_filter' do
  device = Device.find_by_token(params[:token])
  unless device.nill?
    user = device.user
    unless user.nill?      
      v = user.vlogs.where(:log_date => range(params[:filter_to_date],params[:filter_from_date], #문법 맞는지 확인 필요
                       :feeling => params[:filter_feeling])) # and조건이 아니라 or조건으로 걸어야 함
      
      #Pagination / :page 값을 Fuse에서 받아야 함
      v = paginate(:page => params[:page], :per_page => 30).to_json
      
    else   
      error = {:err_code => '002', 
        :err_msg => '가입되어있지 않은 User입니다.'}
      error.to_json   
    end
  else
    error = {:err_code => '003', 
      :err_msg => '등록되어 있지 않은 Device입니다.'}
    error.to_json 
  end
end

