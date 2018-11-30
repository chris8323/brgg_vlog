# BRGG VLOG Project
바로가기 1기, 기팀의 프로젝트입니다.
Kick-off @181006
[User Flow](https://goo.gl/6ThHKH) 



- - -

## Ideation / Brainstorming
  - 캘린더를 기반으로 한 v-log
  - 동영상 다이어리 + 달력 UI
  - 유저 어떨때 우리 서비스를 쓸까?
    - 글감 제공 > 영감적 글쓰기? 씀: 일상적글쓰기 http://www.ssm10b.com/
    - 고민 털어놓기 대나무숲
    - 무엇이든 매일 하나씩 올려보세요  One day One Log
  - 하루에 하나만
  - 영상 삭제 가능
  - 영상 다운로드 및 공유 기능
    - 다운로드는 우선 고려
    - 공유기능은 후 우선순위
  - 커스텀 니즈? > 후 우선순위 고려
 
## Service Concept
  - One day One log
    - 하루에 하나의 로그만
    - 과거 로그 삭제는 가능
    - 과거 로그는 원칙상 추가 불가 (1일 전 로그까지만 허용)

## Functional Specification
  - Sign-up / Sign-in
    - 기본 회원가입 + SNS 회원가입
  - Video Taking
    - 촬영 시작 시 말감 추천
      - 할말 있어요 or 할말 없어요
      - 할말 없어요 > 말감 추천
    - 촬영 후 태깅
    - 기분 선택
  - Default View: Calendar
  - Filter View: Grid
    - 기분
    - 기간 (연월)

* * *


### Error Code
| err_code | result_msg |
|--------|--------|
|err000|token이 만료되었습니다.|
|err001|이미 가입된 회원입니다.|
|err002|입력하신 비밀번호가 서로 일치하지 않습니다.|
|err003|가입되어 있지 않은 아이디입니다.|
|err004|비밀번호가 일치하지 않습니다.|
|err005|누락된 Parameter가 있습니다.|


