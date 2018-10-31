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


# 시나트라는 Backend의 역할만! Fornt의 로직 및 기능은 모두 Fuse로 이관

# 특정 월 호출 시, 각 날짜마다 데이터 있는지 여부 확인
# Fuse에서 이걸 토대로 각 날짜를 눌렀을 때 write로 갈 지 Detail로 갈 지 




### backend에서 frontend로 던져줘야할 json data의 sample format


# Caledar List

# Grid List

# Vlog Detail
- vlog.log_date
- vlog.feeling
- vlog.tag
- vlog.thumbnail_link
- vlog.video_link
- vlog.video_ptime

