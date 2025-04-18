# Our Days - 연인을 위한 데이트 기록 애플리케이션 상세 기획서

## 1. 시스템 아키텍처

### 1.1 전체 아키텍처
- **프론트엔드**: Flutter (크로스 플랫폼 모바일 애플리케이션)
- **백엔드**: Spring Boot (Java)
- **데이터베이스**: PostgreSQL
- **스토리지**: AWS S3 (이미지 및 동영상 저장)
- **인증**: JWT 기반 인증 시스템
- **실시간 통신**: WebSocket (Socket.IO)

### 1.2 백엔드 아키텍처 (Spring)
- **Spring Boot**: 애플리케이션 프레임워크
- **Spring Security**: 인증 및 권한 관리
- **Spring Data JPA**: 데이터베이스 접근 계층
- **Spring WebSocket**: 실시간 데이터 공유
- **REST Docs**: API 문서화

### 1.3 프론트엔드 아키텍처 (Flutter)
- **상태 관리**: Provider 또는 Bloc 패턴
- **네트워크 통신**: Dio 패키지
- **로컬 저장소**: Hive 또는 SharedPreferences
- **UI 컴포넌트**: Material Design 및 커스텀 위젯
- **이미지 처리**: cached_network_image
- **지도 통합**: Naver Maps

## 2. 데이터베이스 설계

### 2.1 주요 엔티티
1. **User (사용자)**
   - id: UUID (PK)
   - email: String
   - password: String (암호화)
   - name: String
   - profile_image: String (URL)
   - created_at: Timestamp
   - updated_at: Timestamp

2. **Couple (커플)**
   - id: UUID (PK)
   - user1_id: UUID (FK -> User)
   - user2_id: UUID (FK -> User)
   - anniversary_date: Date
   - status: Enum (PENDING, ACTIVE, INACTIVE)
   - created_at: Timestamp
   - updated_at: Timestamp

3. **DateRecord (데이트 기록)**
   - id: UUID (PK)
   - couple_id: UUID (FK -> Couple)
   - date: Date
   - title: String
   - memo: Text
   - emotion: Enum (HAPPY, EXCITED, NORMAL, SAD, etc.)
   - created_by: UUID (FK -> User)
   - created_at: Timestamp
   - updated_at: Timestamp

4. **Place (장소)**
   - id: UUID (PK)
   - date_record_id: UUID (FK -> DateRecord)
   - name: String
   - address: String
   - latitude: Double
   - longitude: Double
   - category: Enum (RESTAURANT, CAFE, MOVIE, etc.)
   - rating: Integer (1-5)
   - review: Text
   - created_at: Timestamp
   - updated_at: Timestamp

5. **Media (미디어)**
   - id: UUID (PK)
   - reference_id: UUID (FK -> DateRecord or Place)
   - reference_type: Enum (DATE_RECORD, PLACE)
   - type: Enum (IMAGE, VIDEO)
   - url: String
   - thumbnail_url: String
   - created_at: Timestamp
   - updated_at: Timestamp

6. **Comment (댓글)**
   - id: UUID (PK)
   - date_record_id: UUID (FK -> DateRecord)
   - user_id: UUID (FK -> User)
   - content: Text
   - created_at: Timestamp
   - updated_at: Timestamp

7. **SpecialDate (특별한 날짜)**
   - id: UUID (PK)
   - couple_id: UUID (FK -> Couple)
   - date: Date
   - title: String
   - description: Text
   - type: Enum (ANNIVERSARY, BIRTHDAY, SPECIAL_EVENT)
   - created_at: Timestamp
   - updated_at: Timestamp

### 2.2 관계 설계
- User와 Couple: 다대다 관계 (한 사용자는 여러 커플 관계를 가질 수 있음, 현재는 1:1로 제한)
- Couple과 DateRecord: 일대다 관계 (한 커플은 여러 데이트 기록을 가짐)
- DateRecord와 Place: 일대다 관계 (하나의 데이트 기록에 여러 장소 포함 가능)
- DateRecord/Place와 Media: 다형성 일대다 관계 (데이트 기록과 장소 모두 미디어 첨부 가능)
- DateRecord와 Comment: 일대다 관계 (하나의 데이트 기록에 여러 댓글 가능)
- Couple과 SpecialDate: 일대다 관계 (한 커플은 여러 특별한 날짜를 가짐)

## 3. API 엔드포인트

### 3.1 인증 API
- `POST /api/v1/auth/register`: 회원가입
- `POST /api/v1/auth/login`: 로그인
- `POST /api/v1/auth/refresh`: 토큰 갱신
- `POST /api/v1/auth/logout`: 로그아웃

### 3.2 사용자 API
- `GET /api/v1/users/me`: 현재 사용자 정보 조회
- `PUT /api/v1/users/me`: 사용자 정보 수정
- `PUT /api/v1/users/me/password`: 비밀번호 변경
- `POST /api/v1/users/me/profile-image`: 프로필 이미지 업로드

### 3.3 커플 API
- `POST /api/v1/couples/invite`: 커플 초대 코드 생성
- `POST /api/v1/couples/accept`: 커플 초대 수락
- `GET /api/v1/couples/me`: 현재 커플 정보 조회
- `PUT /api/v1/couples/me`: 커플 정보 수정
- `DELETE /api/v1/couples/me`: 커플 관계 해제

### 3.4 데이트 기록 API
- `POST /api/v1/date-records`: 데이트 기록 생성
- `GET /api/v1/date-records`: 데이트 기록 목록 조회 (페이징, 필터링)
- `GET /api/v1/date-records/{id}`: 특정 데이트 기록 조회
- `PUT /api/v1/date-records/{id}`: 데이트 기록 수정
- `DELETE /api/v1/date-records/{id}`: 데이트 기록 삭제
- `GET /api/v1/date-records/calendar`: 캘린더 형식의 데이트 기록 조회

### 3.5 장소 API
- `POST /api/v1/date-records/{dateRecordId}/places`: 장소 추가
- `GET /api/v1/date-records/{dateRecordId}/places`: 장소 목록 조회
- `PUT /api/v1/places/{id}`: 장소 정보 수정
- `DELETE /api/v1/places/{id}`: 장소 삭제
- `GET /api/v1/places/frequent`: 자주 가는 장소 조회

### 3.6 미디어 API
- `POST /api/v1/media/upload`: 미디어 업로드
- `DELETE /api/v1/media/{id}`: 미디어 삭제
- `GET /api/v1/date-records/{dateRecordId}/media`: 데이트 기록 미디어 조회
- `GET /api/v1/places/{placeId}/media`: 장소 미디어 조회

### 3.7 댓글 API
- `POST /api/v1/date-records/{dateRecordId}/comments`: 댓글 작성
- `GET /api/v1/date-records/{dateRecordId}/comments`: 댓글 목록 조회
- `PUT /api/v1/comments/{id}`: 댓글 수정
- `DELETE /api/v1/comments/{id}`: 댓글 삭제

### 3.8 특별한 날짜 API
- `POST /api/v1/special-dates`: 특별한 날짜 추가
- `GET /api/v1/special-dates`: 특별한 날짜 목록 조회
- `PUT /api/v1/special-dates/{id}`: 특별한 날짜 수정
- `DELETE /api/v1/special-dates/{id}`: 특별한 날짜 삭제

### 3.9 통계 API
- `GET /api/v1/statistics/monthly`: 월별 데이트 통계
- `GET /api/v1/statistics/yearly`: 연도별 데이트 통계
- `GET /api/v1/statistics/places`: 장소 분석 통계
- `GET /api/v1/statistics/emotions`: 감정 분석 통계

## 4. 프론트엔드 화면 설계

### 4.1 인증 화면
1. **시작 화면**: 앱 로고 및 소개
2. **로그인 화면**: 이메일/비밀번호 입력
3. **회원가입 화면**: 사용자 정보 입력
4. **커플 연결 화면**: 초대 코드 생성 및 입력

### 4.2 메인 화면
1. **홈 화면**: 최근 데이트 기록, 다가오는 기념일, 통계 요약
2. **캘린더 화면**: 월별 캘린더와 데이트 기록 표시
3. **추억 화면**: 사진/동영상 갤러리, 추억 앨범

### 4.3 데이트 기록 화면
1. **기록 목록 화면**: 날짜별 데이트 기록 목록
2. **기록 상세 화면**: 특정 데이트의 상세 정보
3. **기록 작성 화면**: 새 데이트 기록 작성
   - 날짜 선택 섹션
   - 장소 추가 섹션
   - 메모 및 감정 입력 섹션
   - 미디어 첨부 섹션

### 4.4 장소 관련 화면
1. **장소 검색 화면**: 지도 API를 활용한 장소 검색
2. **장소 상세 화면**: 장소 정보, 리뷰, 사진
3. **자주 가는 장소 화면**: 자주 방문한 장소 목록

### 4.5 통계 화면
1. **월별/연도별 통계 화면**: 데이트 빈도, 지출 등 통계
2. **장소 분석 화면**: 자주 가는 장소 유형, 선호도
3. **감정 분석 화면**: 데이트별 감정 추이

### 4.6 설정 화면
1. **프로필 설정**: 사용자 정보 관리
2. **커플 설정**: 기념일, 특별한 날짜 관리
3. **알림 설정**: 알림 유형 및 빈도 설정
4. **앱 설정**: 테마, 언어 등 설정

## 5. 기술 요구사항 및 의존성

### 5.1 백엔드 요구사항
- **Java 17** 또는 **Kotlin 1.6+**
- **Spring Boot 3.0+**
- **Spring Security**
- **Spring Data JPA**
- **PostgreSQL 14+**
- **Redis** (캐싱 및 세션 관리)
- **AWS S3** (미디어 저장)
- **JWT** (인증)
- **WebSocket** (실시간 통신)
- **Gradle** 또는 **Maven** (빌드 도구)
- **JUnit 5** (테스트)
- **Mockito** (테스트)
- **Swagger/OpenAPI** (API 문서화)

### 5.2 프론트엔드 요구사항
- **Flutter 3.0+**
- **Dart 2.17+**
- **Provider** 또는 **Bloc** (상태 관리)
- **Dio** (HTTP 클라이언트)
- **Flutter Secure Storage** (보안 저장소)
- **Google Maps Flutter** (지도 통합)
- **Image Picker** (이미지/비디오 선택)
- **Cached Network Image** (이미지 캐싱)
- **Socket.IO Client** (실시간 통신)
- **Intl** (국제화)
- **Flutter Local Notifications** (로컬 알림)
- **Firebase Cloud Messaging** (푸시 알림)

### 5.3 인프라 요구사항
- **AWS EC2** (서버 호스팅)
- **AWS S3** (미디어 스토리지)
- **AWS RDS** (데이터베이스)
- **Redis Cloud** (캐싱)
- **Firebase** (푸시 알림)
- **CI/CD 파이프라인** (GitHub Actions 또는 Jenkins)
- **Docker** (컨테이너화)

## 6. 개발 일정

### 6.1 1단계: 기초 설계 및 환경 구축 (2주)
- 상세 요구사항 분석 및 문서화
- 데이터베이스 스키마 설계
- 개발 환경 구축
- API 명세서 작성
- UI/UX 디자인 초안 작성

### 6.2 2단계: 핵심 기능 개발 (6주)
- 백엔드 기본 구조 개발
  - 인증 시스템 구현
  - 기본 CRUD API 구현
  - 데이터베이스 연동
- 프론트엔드 기본 구조 개발
  - 인증 화면 구현
  - 메인 화면 구현
  - 데이트 기록 기본 기능 구현

### 6.3 3단계: 고급 기능 개발 (4주)
- 지도 API 연동
- 미디어 업로드 및 관리 기능
- 실시간 공유 기능
- 통계 및 분석 기능

### 6.4 4단계: 테스트 및 최적화 (3주)
- 단위 테스트 및 통합 테스트
- 성능 최적화
- 사용자 피드백 수집 및 반영
- 버그 수정

### 6.5 5단계: 배포 및 모니터링 (1주)
- 프로덕션 환경 구축
- 애플리케이션 배포
- 모니터링 시스템 구축
- 사용자 피드백 수집 체계 구축

## 7. 확장 계획

### 7.1 1차 확장 (초기 출시 후 3개월)
- 소셜 미디어 공유 기능
- 고급 사진 편집 기능
- 데이트 비용 관리 기능
- 데이트 코스 추천 기능

### 7.2 2차 확장 (초기 출시 후 6개월)
- 커뮤니티 기능 (다른 커플과의 소통)
- 데이트 장소 예약 연동
- AI 기반 데이트 코스 추천
- 웹 버전 개발

### 7.3 3차 확장 (초기 출시 후 12개월)
- 다국어 지원
- 프리미엄 구독 모델 도입
- 고급 분석 및 인사이트 기능
- 타사 서비스 연동 (예: 식당 예약, 티켓 구매)

## 8. 보안 및 개인정보 보호

### 8.1 보안 조치
- 모든 통신에 HTTPS 적용
- JWT 기반 인증 및 권한 관리
- 비밀번호 해싱 (BCrypt)
- API 요청 제한 (Rate Limiting)
- SQL 인젝션 방지
- XSS 방지

### 8.2 개인정보 보호
- 개인정보 처리방침 수립
- 사용자 데이터 암호화 저장
- 데이터 접근 로깅
- GDPR 및 국내 개인정보보호법 준수
- 사용자 데이터 삭제 요청 처리 시스템

## 9. 모니터링 및 유지보수

### 9.1 모니터링 시스템
- 서버 상태 모니터링
- 애플리케이션 성능 모니터링
- 오류 로깅 및 알림
- 사용자 행동 분석

### 9.2 유지보수 계획
- 정기적인 보안 업데이트
- 성능 최적화
- 사용자 피드백 기반 개선
- 정기적인 백업 및 복구 테스트