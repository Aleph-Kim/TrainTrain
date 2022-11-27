# 영차열차 프로젝트 소개
## Event Storming

<img width="700" alt="image" src="https://user-images.githubusercontent.com/74695165/189512519-0f793161-3719-4770-8fb2-01dcb0f071a1.png">

<br>

# 시작 (2022년 9월)

<img src="https://user-images.githubusercontent.com/71127966/204121542-4c35c362-28f0-4aad-95b3-e59db2b930d0.jpeg" width="500">

- 출근길 지하철역으로 내려갔을 때, 전광판에 거의 다 도착해있는 열차를 보신 적이 있으신가요?
  - **"아 조금만 뛰어왔으면 탈 수 있었는데.."** 와 같은 아쉬움이 생겼던 적이 있으실 겁니다.
- 이러한 불편함을 해결하기 위해, 코다와 예거는 `지하철 전광판`을 아이폰 화면으로 옮겨보자는 아이디어로 프로젝트를 시작했습니다.

<br>

# 지하철 데이터

- 공공데이터인 [서울시 지하철 실시간 도착정보](https://data.seoul.go.kr/dataList/OA-12764/F/1/datasetView.do)를 사용했습니다.
- 위 링크를 살펴보면, `실시간도착_역정보_(날짜).xlsx` 파일을 확인할 수 있는데요.
- 해당 파일은 `1 ~ 9호선` 및 경의중앙선(1063), 공항선(1065), 경춘선(1067), 수인분당선(1075), 신분당선(1077), 우이신설선(1092)에 대한 정보를 3개의 필드로 담고 있습니다.
  - SUBWAY_ID -> 호선에 대한 고유 아이디
  - STATN_ID -> 역에 대한 고유 아이디
  - STATN_NAME -> 역의 이름

<img width="345" alt="image" src="https://user-images.githubusercontent.com/71127966/204121887-9fe7acdc-d94c-450e-b3ff-0041718c00a3.png">

- 처음에는 [이 사이트](https://wtools.io/convert-excel-to-plist)를 통해 해당 xlsx 파일을 -> `plist` 파일로 변환해서 프로젝트에 추가해서 사용했습니다.
- 그러나 개발을 진행하면서, 해당 엑셀 파일의 정보를 신뢰할 수 없다는 걸 깨달았습니다. 특정 호선에 `누락된 역`이 있는 치명적인 문제가 있기도 했습니다.
  - 이 문제는 서울시 측에 댓글로 제보하여 지금은 수정 됐습니다. (아래 스크린샷 참고)
  
<img width="500" alt="image" src="https://user-images.githubusercontent.com/71127966/204122212-76af9de5-0d35-4c79-83b6-eed5b5576bd7.png">

- 뿐만 아니라, 저희는 사용자가 선택한 역을 기준으로 `상행`, `하행` 방향에 어떤 역들이 이어지는 지 알아야 했는데요.
- 엑셀 파일의 순서를 신뢰하기 어려워서, 코다와 제가 직접 지하철 노선도를 키고 하나하나 수동으로 체크하면서, `LinkedList 스타일의 DB` 를 새롭게 만들었습니다.
  - (스프레드 시트) [영차열차 지하철 노선도 API](https://docs.google.com/spreadsheets/d/1zfEVYLh4d9c8j9NUp9pstmU116OiqVoQQF1w5Gr6ji8/edit#gid=0)
- 이렇게 만든 스프레드 시트를 `plist` 파일로 변환해서 프로젝트에 넣어서 사용합니다.
  - 관련 코드는 프로젝트의 `StationInfo.swift` 파일을 확인해주세요.
  
<br>

# API 통신

- (작성 예정...)
