# 관련 PR 및 이슈
- 해당 변경 사항과 연관된 PR 또는 이슈를 멘션합니다(예: #123)

# 배경
- PR의 근거를 작성합니다.
- Figma, Notion, 회의록, 카카오톡의 논의 내용 링크를 추가할 것을 권장합니다.
- 링크는 시간이 흐르며 깨질 수 있으므로 핵심 내용을 캡처하여 추가합니다.
- 이미지를 추가할 때는 HTML image tag의 width 속성을 사용하여 너무 크거나 작게 보이지 않도록 설정합니다.
  - <img src="https://some-image.com" width="700">

# 목적(선택)
- 제목과 배경이 변경사항을 만드는 목적을 충분히 설명하지 못하는 경우 작성합니다.

# 작업 내용
- 작업한 내용을 개조식으로 설명합니다.
- 사용 관점에서 변경 사항은 배경에서 충분히 설명하고 있으므로 코드 관점에서의 작업 내용을 설명합니다.
  - 예) X View, Y Service 추가. X는 Y를 이용하여 Z 수행.

# 테스트
- 리뷰어가 해당 변경 사항을 테스트할 수 있는 방법을 설명합니다.
- 유닛 테스트가 있는 경우 테스트 메서드들의 의미와 목적을 포함할 수 있습니다.

# 결과
- UI에 영향을 주는 변경 사항이라면 이미지, gif 또는 영상을 추가합니다.
- 순수한 로직과 관련된 변경사항이라면 유닛 테스트 수행 결과를 캡처하여 추가합니다.
- 위 사항 중 어느 것에도 해당되지 않을 경우 '코드 및 리뷰 참고' 문구를 남깁니다. 여기서 리뷰는 셀프 리뷰를 의미합니다.
- 기기 캡처 이미지 또는 영상은 추가할 이미지 개수에 따라 너비 기준으로 250~320 px 중 선택하여 사용합니다(하나인 경우 320, 두개인 경우 280 등 자유)

||예시 기기(예: iPhone 14 Pro)|
|------|---|
|캡처/gif/영상|<img src="" width="">|

||예시 기기1|예시 기기2|
|------|---|---|
|변경 1|<img src="" width="">|<img src="" width="">|
|변경 2|<img src="" width="">|<img src="" width="">|
|변경 3|<img src="" width="">|<img src="" width="">|
