require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'aws-sdk'
require 'bcrypt'
require 'securerandom'
require 'will_paginate'
require 'will_paginate/active_record'
require 'Date'

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
  if params[:email].nil?
    return "Please Enter your Email".to_json
  elsif params[:nickname].nil?
    return "Please Enter your Nickname".to_json
  elsif params[:password].nil?
    return "Please Enter your Password".to_json
  elsif params[:password_confirm].nil?
    return "Please Confirm your Password".to_json
  end
    ### 여러 조건 중 하나라도 만족하지 않으면 중간에 스크립트가 중단되나? 아니면 모두 pass 체크하게 되나?
    ### 모두 pass하게 된다면 비효율적이지 않나?

  # Password Validation Check
  if !params[:password] == params[:password_confirm]
    return "err002".to_json
  elsif params[:password].length < 5
    return "5글자 이상 비밀번호를 지정해주세요.".to_json
  end

  # Email Validation Check
  if !params[:email].include? "@"
    return "email 형식을 확인해주세요.".to_json
  elsif !params[:email].include? "."
    return "email 형식을 확인해주세요.".to_json 
  elsif !User.find_by_email(params[:email]).nil?
    return 'err001'.to_json 
  end

  # Nickname Validation Check
  if params[:password].length < 3
    return "3자 이상 10자 이하의 Nickname을 입력해주세요.".to_json
  elsif params[:password].length > 10
    return "3자 이상 10자 이하의 Nickname을 입력해주세요.".to_json
  elsif !User.find_by_nickname(params[:nickname]).nil?
    return '이미 등록된 nickname입니다. 수정해주세요.'.to_json 
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
  # Parameter Check
  if params[:email].nil?
    return "Please Enter your Email".to_json
  elsif params[:password].nil?
    return "Please Enter your Password".to_json
  end

  # Email Validation Check 
  if !params[:email].include? "@"
    return "email 형식을 확인해주세요.".to_json
  elsif !params[:email].include? "."
    return "email 형식을 확인해주세요.".to_json 
  elsif User.where(email: params[:email]).take.nil?     
    return "err003".to_json
  end

  # Password Validation Check
  if params[:password].length < 5
    return "비밀번호는 5글자 이상입니다.".to_json
  elsif !(BCrypt::Password.new(User.where(email: params[:email]).take.password) == params[:password])
    return "err004".to_json
  end

  d = Device.create(user_id: User.where(email: params[:email]).take.id, token: SecureRandom.uuid)
  d.to_json

end

#----------------------------------------
# Logout
#----------------------------------------
delete '/device' do 
  # Parameter Check
  if params[:token].nil?
    return "Missing Parameter (token)".to_json
  end

  device = Device.find_by_token(params[:token])

  if device.nil?
    'token과 일치하는 device data가 없습니다.'.to_json
  else
    device.delete
    true.to_json
  end
  
end

#----------------------------------------
# Vlog Detail 조회하기
#----------------------------------------
get '/vlog' do 
  # Parameter Check
  if params[:token].nil?
    return "Missing Parameter (token)".to_json
  elsif params[:vlog_id].nil?
    return "Missing Parameter (vlog_id)".to_json
  end

  d = Device.find_by_token(params[:token])
  v = Vlog.find(params[:vlog_id])
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

post '/vlog' do 

  # Parameter Check
  if params[:token].nil?
    return "Missing Parameter (token)".to_json
  elsif params[:is_todayLog].nil?
    return "Missing Parameter (is_todayLog)".to_json
  elsif params[:feeling].nil?
    return "Missing Parameter (feeling)".to_json
  elsif params[:tag].nil?
    return "Missing Parameter (tag)".to_json
  elsif params[:file].nil?
    return "Missing Parameter (file)".to_json
  end
  
  user = Device.find_by_token(params[:token]).user

  created_at = Date.today

  # Calculating 'logged_at'
  if params[:is_todayLog] == 'T'
    logged_at = created_at
  elsif params[:is_todayLog] == 'F'
    logged_at = created_at - 1
  else
    return 'Wrong Parameter (is_todayLog)'.to_json
  end
    
  file = params[:file]
    
  video_path = "#{user.id}/#{logged_at}/video/#{file[:filename]}" #video upload path 수정
  
  thumbnail_path = "#{user.id}/#{logged_at}/thumbnail/#{file[:filename]}"

  s3 = Aws::S3::Resource.new(region:"ap-northeast-1")
  obj = s3.bucket("bgbgbg-bgbg").object(video_path)
  s = obj.upload_file(file[:tempfile], {acl: "public-read"})
  
  v = Vlog.create(user: user, 
                created_at: created_at,
                logged_at: logged_at,
                feeling: params[:feeling],
                tag: params[:tag],
                video_link: "https://s3-ap-northeast-1.amazonaws.com/bgbgbg-bgbg/#{video_path}"
                )
             
  v.to_json
end


#----------------------------------------
# Vlog 존재 여부 확인
#----------------------------------------
get '/datecheck' do
  # Parameter Check
  if params[:token].nil?
    return "Missing Parameter (token)".to_json
  elsif params[:is_todayLog].nil?
    return "Missing Parameter (page)".to_json
  end

  device = Device.find_by_token(params[:token])

  # Device Validation Check
  if device.nil?
    return 'err006'.to_json
  end

  created_at = Date.today

  # Calculating 'logged_at'
  if params[:is_todayLog] == 'T'
    logged_at = created_at
  elsif params[:is_todayLog] == 'F'
    logged_at = created_at - 1
  else
    return 'Wrong Parameter (is_todayLog)'.to_json
  end

  v = Vlog.where(:user => device.user_id,
                :logged_at => logged_at
                ) 
  if v.length==0
    return 'Available'.to_json
  else
    return 'Occupied'.to_json
  end
  
end

#----------------------------------------
# Vlog List 호출하기 (Calendar view 적용)
#----------------------------------------
get '/list_by_month' do
  
  # Parameter Check
  if params[:token].nil?
    return "Missing Parameter (token)".to_json
  elsif params[:year].nil?
    return "Missing Parameter (year)".to_json
  elsif params[:month].nil?
    return "Missing Parameter (month)".to_json
  end
  
  device = Device.find_by_token(params[:token])
  
  # Device Validation Check
  if device.nil?
    return 'err006'.to_json
  end

  # Filtering Logic
  dateSelected = Date.new(params[:year].to_i, params[:month].to_i).to_time    

  v = Vlog.where(:user_id => device.user_id,
                 :logged_at => dateSelected.beginning_of_month..dateSelected.end_of_month)
            
  
  # Vlog Validation Check
  if v.nil?
    'No Vlogs yet'.to_json
  elsif v.length == 0
    'No Vlogs at this month'.to_json
  else
    v.to_json      
  end

end


#----------------------------------------
# Vlog List 호출하기 (Filter 적용)
#----------------------------------------
get '/list_by_filter' do
  # Parameter Check
  if params[:token].nil?
    return "Missing Parameter (token)".to_json
  elsif params[:page].nil?
    return "Missing Parameter (page)".to_json
  end


  device = Device.find_by_token(params[:token])

  # Device Validation Check
  if device.nil?
    'err006'.to_json
  end

  # Filtering Logic
  if !params[:feeling].nil?
    if !params[:tag].nil?
      v = Vlog.where(:user_id => device.user_id,
                    :feeling => params[:feeling],
                    :tag => params[:tag])
    else
      v = Vlog.where(:user_id => device.user_id,
                    :feeling => params[:feeling])
    end
  else
    if !params[:tag].nil?
      v = Vlog.where(:user_id => device.user_id,
                    :tag => params[:tag])
    else
      v = Vlog.where(:user_id => device.user_id)
    end
  end

  # Pagination (:per_page > Hard Cording 처리)
  p = v.paginate(:page => params[:page].to_i, 
                :per_page => 5
                )
  if p.length == 0
    return 'No Vlogs to show'
  else
    return p.to_json
  end  
end


