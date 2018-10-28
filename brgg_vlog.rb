# 필요한 Package 호출 / 추가할 경우 Gemfile에도 입력합니다.
require 'sinatra'
require 'sinatra/activerecord'
require 'sqlite3'
require 'json'

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


### 지금 DB에 어떤 데이터들이 들어있는지 확인 목적
### 개발 이후 삭제 예정
get '/temp/datacheck/vlog' do
    vlog_array = Array.new
    vlogs = Vlog.all
    vlogs.each do |v|
        vlog_array << {"vlog_id" => v.id,
                        "user_id" => v.user_ids,
                        "create_date" => v.create_date,
                        "log_date" => v.log_date,
                        "feeling" => v.feeling,
                        "tag" => v.tag,
                        }
    end
    vlog_array.to_json
end

get '/temp/datacheck/user' do
    u = User.all
    result = {"user_id" => u.ids,            
            "email" => u.email,
            "joined_date" => u.joined_date,
            }
    result.to_json
end


#-------------------------------------------
# 00 회원가입 및 로그인
#-------------------------------------------
get '/login' do
    erb :test
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
# 01 Vlog Creation (남기 + 은총)
#-------------------------------------------



#-------------------------------------------
# 02 Vlog Default View (지현 + 찬우)
#-------------------------------------------

post '/vlog' do
    #session을 통해 user_id를 확인한다
    #user_id가 없으면 로그인 화면으로 이동한다
    if session["user_id"].nil? 
		redirect '/login'
	else
        #해당 user_id가 vlog.user_id 내에 존재하는지 확인
        #해당 vlog_id 존재하면 '/vlog/list/'로 이동한다.
        if Vlog.where("user_id" => session['user_id']).exists?
            redirect '/vlog/list'
                
        #해당 vlog_id가 존재하지 않으면 '/vlog/list/no_post'로 이동한다.
        else
            redirect '/vlog/list/no_post'
        end        
	end 
end



get '/vlog/list/' do
    #해당 user_id에 속한 vlog_id를 호출한다.
    #vlog Table 에서 user_id 컬럼 조건 검색을 어덯게 하지??
    
    #session이 아직 구현 안됐기 때문에 1번 유저가 로그인되어있다고 가정하고 진행

    #u = User.find(session['user_id'])
    u = User.find(1) #임시로 가정

    v = Vlog.where("user_id" => 1)
    

    #불러온 데이터 결과값 > json으로
    result = {"user_id" => u.id,
            "user_email" => u.email,                 
            "#vlog" => v.count,
            }

    result.to_json
   

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
# 03 Vlog History View (예원+아영)
#-------------------------------------------

get '/creation/date_choice' do
	t = Date.today
	y = t.prev_day
	# date를 세션에 밀어넣기
	choice_date = t
	# 유저가 선택한거다 / 오늘을 선택했다고 가정한 상태.
	session['choice_date'] = choice_date
	#d = array{t.strftime('%Y-%m-%d'),
	#			y.strftime('%Y-%m-%d')}

	redirect '/creation/date_exist'
	erb :datechoice
end

post '/creation/date_exist' do
	#d = array{'t.strftime('%Y/%m/%d')', 't.strftime('%Y/%m/%d') - 1.day'}
	if v.where('log_date' => session['choice_date']).exists?
		#브이쩜 로그데이터가 초이스데이터와 같은 날짜가 존재하냐
		#==> 유저가 고른 날짜가 존재하냐
		redirect '/creation/date_overwrite'
		# 존재하면 덮어쓸지 물어보는 페이지로 이동하기
	else
		redirect '/creation/question'
	end
		# 그렇지 않으면 바로 쓸말 있냐 질문 페이지로 이동
end

	# Vlog.where("log_date" => session['log_date'], "user_id" => session['user_id'])

get '/creation/date_overwrite' do
	o = array{true,false}
	# 덮어쓸지 안쓸지 물어보기 덮어쓰면 true, 아니면 false
	if o.first
		v.where('log_date' => session['choice_date']).delete
		redirect '/creation/question'
	# 덮어쓴다 그러면 기존 브이로그 데이터 지우고
	# 질문 페이지로 이동
	else
		redirect '/Vlog'
	end
		#0 이라 하면 다음 단계 아니면 Vlog(캘린더 뷰) 탭으로 이동
	erb :overwrite
end

get '/creation/question' do
	q = array{true,false}
	if user_question_choice = array.first 
		redirect '/creation/video'
	else
		redirect '/creation/questionlist'
	end
	erb :question
end
# 질문할 거리가 있냐 없냐 물어보기
	# true = 질문할 거 있다
	# else
		# puts date 
		# redirect '/creation/video'
		# 없다 대답하면 질문 던져주고 이동하기

get '/createion/questionlist' do
	if Questionlist.where('question_date' => Date.today).exists?
		@questionlist = Questionlist.where('question_date' => Date.today)
	else
		@questionlist = Questionlist.shuffle
	end
# qustionlist db에서 qustion_date 값이 오늘과 같은것을 불러 오라 
# 아니면 나머지에서 셔플하라... 나머지...? 값 중에 하나 랜덤으로 보여줘라...? ㅠㅠ
	redirect '/creation/video'
	erb :questionlist
end
# 질문 리스트를 넣을 디비만들기 / 
# 디비에 있는 걸 불러와서 


get '/creation/video' do
	v = video
	created_date_video = Date.today
	session['created_date_video'] = created_date_video
	session['video_link'] = video_link
	session['video_ptime'] = video_ptime

	redirect '/creation/feeling'
	erb :video
#비디오 모름.... ㅠㅠㅠㅠ
#썸네일 어떻게...?
end

get '/creation/feeling' do
	feeling = array{a, b, c, d}
	# abcd안에 이미지 링크
	feeling_select = array.first
	# user가 a를 선택했다고 가정...
	session['feeling_select'] = feeling_select

	redirect '/creation/tag'
	erb :feeling
end

# 감정 선택하기 -> 희.노.애.락 이모티콘 네 개 중 유저가 선택하면
# 감정 세션(?)에 저장

get '/creation/tag' do
	#v.tag = params['tag']
	#session['tag'] = tag

	#-----------
	session['tag'] = tag

	redirect '/creation/complete'
	erb :tag
end

# 태그 한 단어로 사용자가 입력하면 마찬가지로 세션(?) 파람스(?)에 저장하기

get '/creation/complete' do
	v = Vlog.new
	v.log_date = session['choice_date']
	v.create_date = session['created_date_video']
	v.link = session['video_link']
	v.ptime = session['video_ptime']
	v.feeling = session['feeling_select']
	v.tag = session['tag']

#v에 지금까지 세션에 저장되어있던거를 저장하기
	v.save

	redirect '/Vlog'
end