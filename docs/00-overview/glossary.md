# 용어집 (Glossary / Ubiquitous Language)

> 팀과 코드 전체에서 일관되게 쓸 도메인 용어 사전.
> 새 용어를 만들기 전에 반드시 여기에 등록.
> 마지막 갱신: YYYY-MM-DD

## 작성 규칙
- 가나다 / 알파벳 순
- 동의어가 있다면 표준 용어 하나로 통일하고, 다른 용어는 "→ 표준 용어"로 redirect
- 코드/DB에서 쓰는 영문 표기 함께 명시
- 잘못 쓰이는 사례(Anti-pattern)도 명시

---

## 도메인 용어

### 가입자 (Subscriber) `subscriber`
유료 결제를 1회 이상 완료한 사용자. 단순히 회원가입만 한 사용자(`User`)와 구분.
- ❌ Anti: "회원가입한 사람도 가입자라고 부르기"
- 관련 코드: `src/domain/subscriber/`
- 관련 테이블: `subscribers`

### 거래 (Transaction) `transaction`
{UNSET: 정의 필요}
- 동의어 통합: "주문(Order)"은 거래의 일부 단계
- 상태: `pending`, `completed`, `failed`, `refunded`

### 워크스페이스 (Workspace) `workspace`
{UNSET: 정의 필요}
- 관련: 테넌트(Tenant)와 다름. 한 테넌트 안에 여러 워크스페이스 존재 가능.

---

## 기술 용어

### Idempotency Key
중복 요청을 방지하기 위한 고유 키. 결제·이메일 발송 등 부작용이 있는 API에 필수.
- 헤더: `Idempotency-Key`
- 보존 기간: 24시간

### Soft Delete
물리적으로 삭제하지 않고 `deleted_at` 컬럼으로 표시. 모든 도메인 테이블 기본 정책.

---

## 약어
| 약어 | 풀이 | 비고 |
|---|---|---|
| MAU | Monthly Active Users | 핵심 지표 |
| LTV | Lifetime Value | 고객 생애 가치 |
| GMV | Gross Merchandise Value | 총 거래액 |

---

## 비즈니스 상태값

### 사용자 상태 (`user.status`)
- `pending` : 이메일 인증 대기
- `active` : 정상
- `suspended` : 일시 정지
- `deactivated` : 탈퇴 (Soft delete, `deleted_at` 컬럼 사용)
<!-- 참고: domain-model.md, users.md 스키마와 용어 통일 (기존 "deleted" → "deactivated") -->

### 거래 상태 (`transaction.status`)
[상태 머신 정의는 별도 다이어그램 참조: `../03-architecture/diagrams/transaction-state.mmd`]
