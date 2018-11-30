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

#----------------------------------------
# 유저 정보 조회
#----------------------------------------
get '/user' do 
  user = Device.find_by_token(params[:token]).user
  user.to_json
end

#----------------------------------------
# 회원 가입
#----------------------------------------
  
post '/user' do
  # Parameter Check
  if params[:email].nill?
    return "Please Enter your Email".to_json
  elsif params[:nickname].nill?
    return "Please Enter your Nickname".to_json
  elsif params[:password].nill?
    return "Please Enter your Password".to_json
  elsif params[:password_confirm].nill?
    return "Please Confirm your Password".to_json
  end
    ### 여러 조건 중 하나라도 만족하지 않으면 중간에 스크립트가 중단되나? 아니면 모두 pass 체크하게 되나?
    ### 모두 pass하게 된다면 비효율적이지 않나?

  # Password Validation Check
  if !params[:password] == params[:password_confirm]
    return "err002".to_json
  elsif param[:password].length < 5
    return "5글자 이상 비밀번호를 지정해주세요.".to_json
  end

  # Email Validation Check
  if !parmas[:email].include? "@"
    return "email 형식을 확인해주세요.".to_json
  elsif !parmas[:email].include? "."
    return "email 형식을 확인해주세요.".to_json
  elsif !User.find_by_email(params['email']).nill?
    return 'err001'.to_json 
  end

  
  encrypt_password = BCrypt::Password.create(params[:password])
  u = User.new(email: params[:email],
              nickname: params[:nickname],
              password: encrypt_password)
  u.save
  u.to_json
  
end


#----------------------------------------
# Login
#----------------------------------------
  # - 현재는 email / password 기반 로그인
  # - 차후 Facebook Login으로 변경 예정
post '/device' do 
  user = User.where(email: params[:email]).take
  if !user.nil? 
    if (BCrypt::Password.new(user.password) == params[:password])
      d = Device.create(user: user, token: SecureRandom.uuid)
      d.to_json
    else
      "err004".to_json
    end
  else
    "err003".to_json
  end
end

#----------------------------------------
# Logout? 회원 탈퇴?
#----------------------------------------
delete '/device' do 
  user = Device.find_by_token(params[:token]).user
  user.delete
  true.to_json
end

#----------------------------------------
# Vlog Detail 조회하기
#----------------------------------------
get '/vlog' do 
  d = Device.find_by_token(params[:token])
  v = Vlog.find(params[:id])
  if d.user_id == v.user_id?
    v.to_json
  else
    error = {:err_code => '000',
            :err_msg => '접근권한이 없는 게시물입니다.'}
    error.to_json
  end  
end

#----------------------------------------
# Vlog 작성하기
#----------------------------------------
# - FilePath는 Device의 Local Path??
# - 
post '/vlog' do 
  '''  
  if params[:token].nill?  
  elsif params[:logged_at].nill?
  elsif params[:feeling].nill?
  end
  '''

  
  user = Device.find_by_token(params[:token]).user
  logged_at = parmas[:logged_at] # yymmdd 형태로 변환?
  file = params[:file]
  #path = "#{user.nickname}/#{file[:filename]}" 
  video_path = "#{user.id}/#{logged_at}/video/#{file[:filename]}" #video upload path 수정
  thumbnail_path = "#{user.id}/#{logged_at}/thumbnail/#{file[:filename]}"

  s3 = Aws::S3::Resource.new(region:'ap-northeast-1')
  obj = s3.bucket('bgbgbg-bgbg').object(path)
  s = obj.upload_file(file[:tempfile], {acl: 'public-read'})

  v = Vlog.create(user: user, 
                created_at: Time.now,
                logged_at: params[:logged_at],
                feeling: params[:feeling],
                tag: params[:tag],
                video_link: "https://s3-ap-northeast-1.amazonaws.com/bgbgbg-bgbg/#{video_path}")
                
  v.to_json

=begin
Video Thumbnail과 Ptime 계산은 vlog 작성 이후 별도 로직으로 추출/계산?
      v.string    :thumbnail_link
      v.integer   :video_ptime
=end

end



#----------------------------------------
# Vlog List 호출하기 (Calendar view 적용)
#----------------------------------------
# 이를 기준으로 특정 날짜를 클릭했을 때, write로 redirect될 지, detail로 redirect될 지 결정된다.
get '/list_by_month' do
  device = Device.find_by_token(params[:token])
  unless device.nill?
    user = device.user
    unless user.nill?
      # :yesr와 :month는 Fuse에서 User가 선택한 값
      vlog.where(:user_id => user.id,
                :logged_at.year => params[:year], ### 문법에 맞는가??? 확인 필요...
                :logged_at.month => params[:month], ### 문법에 맞는가??? 확인 필요...
                ).to_json      
      
    else   
      'err003'.to_json   
    end
  else
    'err006'.to_json 
  end
end


#----------------------------------------
# Vlog List 호출하기 (Filter 적용)
#----------------------------------------
get '/list_by_filter' do
  device = Device.find_by_token(params[:token])
  unless device.nill?
    user = device.user
    unless user.nill?      
      v = user.vlogs.where(:logged_at => range(params[:filter_to_date],params[:filter_from_date], #문법 맞는지 확인 필요
                       :feeling => params[:filter_feeling])) # and조건이 아니라 or조건으로 걸어야 함
      
      #Pagination / :page 값을 Fuse에서 parameter로 받아야 함
      v = paginate(:page => params[:page], :per_page => 30).to_json
      
    else   
      'err003'.to_json   
    end
  else
    'err006'.to_json 
  end
end