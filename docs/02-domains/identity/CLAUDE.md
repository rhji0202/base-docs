# Identity Domain

> 사용자 인증·권한·프로필 관리를 담당하는 도메인.
> 다른 모든 도메인의 기반이 되며, 가장 높은 안정성이 요구됨.

## 책임 범위 (In Scope)
- 사용자 가입·로그인·로그아웃
- 비밀번호 관리 (해싱, 재설정)
- 세션·토큰 관리 (JWT)
- 권한·역할 (RBAC)
- 사용자 프로필

## 책임 외 (Out of Scope)
- 결제 정보 → `payment` 도메인
- 알림 발송 → `notification` 도메인
- 활동 로그 분석 → `analytics` 도메인

## 핵심 개념
- **User** (애그리게이트 루트): 모든 사용자 데이터의 진입점
- **Credential** (값 객체): 이메일+해싱된 비밀번호
- **Session** (엔티티): 토큰 기반 활성 세션
- **Role** (값 객체): 권한 묶음

## 외부 의존성
- 이메일 발송: `notification` 도메인의 `EmailService` 호출
- 감사 로그: `audit-log` 이벤트 발행

## 발행하는 도메인 이벤트
- `UserRegistered`
- `UserVerified`
- `UserLoggedIn`
- `PasswordChanged`
- `UserDeactivated`

## 문서 인덱스
- [도메인 모델](./domain-model.md)
- [비즈니스 규칙](./business-rules.md)
- [엣지 케이스](./edge-cases.md)
- [워크플로](./workflows/)
