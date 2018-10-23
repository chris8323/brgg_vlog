# 필요한 Package 호출 / 추가할 경우 Gemfile에도 입력합니다.
require 'sinatra'
require 'sinatra/activerecord'
require 'sqlite3'

# Session 활성화
enable :sessions

# DB 구조 관련 Mapping: https://workflowy.com/s/HFv6.vNf2TwztBy

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



# Service Flow: https://goo.gl/6ThHKH


#-------------------------------------------
# 00 회원가입 및 로그인
#-------------------------------------------

get '/tapmenu' do
end


#-------------------------------------------
# 01 Vlog Creation
#-------------------------------------------



#-------------------------------------------
# 02 Vlog Default View
#-------------------------------------------

get '/vlog' do
end

get '/vlog/list' do
end

get '/vlog/list/error' do
end

get '/vlog/detail' do
end

post '/vlog/detail/edit' do #/vlog/detail 에서 받은 vlog_id가 필요하기 때문에 /vlog/detail 의 하위 카테고리로 위치
end

post '/vlog/detail/download' do #/vlog/detail 에서 받은 vlog_id가 필요하기 때문에 /vlog/detail 의 하위 카테고리로 위치
end

post '/vlog/detail/delete' do #/vlog/detail 에서 받은 vlog_id가 필요하기 때문에 /vlog/detail 의 하위 카테고리로 위치
end



#-------------------------------------------
# 03 Vlog History View
#-------------------------------------------






