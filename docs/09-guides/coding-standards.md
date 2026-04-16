# Coding Standards

> 모든 코드가 따라야 할 컨벤션.
> 언어별 상세는 별도 섹션에서.

## 공통 원칙

### 1. 명확함 > 영리함
- 짧고 영리한 코드보다 길더라도 읽기 쉬운 코드
- 함수 이름이 길어져도 의도가 명확해야 함

### 2. 단일 책임
- 함수: 한 가지만 잘
- 모듈: 한 도메인만
- 파일: 한 클래스/큰 함수만

### 3. 부작용 최소화
- 순수 함수 선호
- 부작용 있으면 함수 이름에 명시 (`saveUser`, `sendEmail`)

### 4. Fail Fast
- 잘못된 입력은 즉시 거부
- 깊숙이 들어간 곳에서 실패하지 말 것

### 5. 명시적 > 암묵적
- 자동 변환, 매직 메서드 자제
- 중요한 것은 코드에서 보이게

## 명명 규칙

### 일반
- 의미 있는 이름: `d` ❌, `daysSinceLastLogin` ✅
- 약어 자제: `usr` ❌, `user` ✅
- Boolean: `is`, `has`, `can` 접두사

### 언어별
- TypeScript/JavaScript: `camelCase` 변수, `PascalCase` 클래스/타입, `UPPER_SNAKE` 상수
- Python: `snake_case` 변수/함수, `PascalCase` 클래스, `UPPER_SNAKE` 상수
- 파일: 언어 컨벤션 따름

## 함수
- 길이: 50줄 이내 권장
- 매개변수: 4개 이내 (그 이상은 객체로)
- 중첩: 3단계 이내

## 주석
- **무엇**이 아닌 **왜**를 설명
- TODO에는 담당자/티켓 명시: `// TODO(F-024): 환불 정책 확정 후 구현`
- 잘못된 코드보다 잘못된 주석이 더 위험

## 에러 처리
- 잡을 수 없는 에러는 잡지 말 것
- 빈 catch 금지
- 도메인별 에러 클래스 사용: `UserNotFoundError`

## 보안
- 절대 하드코딩 금지: 비밀번호, 토큰, API 키
- SQL은 prepared statement만
- 입력은 검증, 출력은 escape

## 테스트
- 새 기능은 테스트 필수
- 버그 수정은 회귀 테스트 추가
- 테스트 이름: `should_X_when_Y` 패턴

## 상세 가이드
- [Git 워크플로](./git-workflow.md)
- [테스트 전략](./testing.md)
- [코드 리뷰](./code-review.md)
