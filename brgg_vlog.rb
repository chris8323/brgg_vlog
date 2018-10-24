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


get '/' do
    #view 단을 임시로 html로 구현
    erb :home
end


#-------------------------------------------
# 00 회원가입 및 로그인
#-------------------------------------------
get '/login' do
end

post '/login/process' do
end

get '/signup' do
end

post '/signup/process' do
end

get '/tapmenu' do
end

#-------------------------------------------
# 01 Vlog Creation
#-------------------------------------------



#-------------------------------------------
# 02 Vlog Default View
#-------------------------------------------

post '/vlog' do
    #session을 통해 user_id를 확인한다
    #user_id가 없으면 로그인 화면으로 이동한다
    if session["user_id"].nil? 
		redirect '/login'
	else
        #해당 user_id의 vlog_id 개수를 확인한다
        #해당 vlog_id 개수가 0이면 '/vlog/list/no_post'로 이동한다. or Count가 아닌 Exist함수를 써서 처리한다?
        #vlog Table 에서 user_id 컬럼 조건 검색을 어덯게 하지??
        if Vlog.count(user_id => session['user_id']) == 0 #https://apidock.com/rails/v2.3.8/ActiveRecord/Calculations/ClassMethods/count
            redirect '/vlog/list/no_post'
                
        #해당 vlog_id 개수가 0이 아니면 '/vlog/list/'로 이동한다.
        else
            redirect '/vlog/list'
        end        
	end 
end


get '/vlog/list/' do
    #해당 user_id에 속한 vlog_id를 호출한다.
    #vlog Table 에서 user_id 컬럼 조건 검색을 어덯게 하지??
    User.find(session['user_id'])
    
    #vlog개수가 너무 많으면 페이지를 나눠야 한다 (pagination)
    #calendar view로 보여줄 것이기 때문에 vlog 호출 단위는 log_date의 월 단위로 한다 (max 31)

end

get '/vlog/list/no_post' do
    #vlog 게시물 개수가 0개일 때 나오는 예외처리 화면
    erb :no_post
end

get '/vlog/detail/:vlog_id' do
    #Param을 통해 vlog_id를 확인한다. (Session이 아니라 Parameter)
    #vlog_id가 없으면 '/vlog'로 이동한다.

    #vlog_id가 있으면 vlog의 속성값들을 호출한다 (log_date / feeling / tag / video link / tumbnail link 등)

        #호출한 vlog의 속상 값을 view 값에 맞춰서 노출한다. (Fuse와 연동 필요)

end


post '/vlog/detail/:vlog_id/edit' do #/vlog/detail 에서 받은 vlog_id가 필요하기 때문에 /vlog/detail 의 하위 카테고리로 위치
end


post '/vlog/detail/:vlog_id/download' do #/vlog/detail 에서 받은 vlog_id가 필요하기 때문에 /vlog/detail 의 하위 카테고리로 위치
end


post '/vlog/detail/:vlog_id/delete' do #/vlog/detail 에서 받은 vlog_id가 필요하기 때문에 /vlog/detail 의 하위 카테고리로 위치
end



#-------------------------------------------
# 03 Vlog History View
#-------------------------------------------






