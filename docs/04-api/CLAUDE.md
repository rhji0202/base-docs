# API 폴더 가이드

이 폴더는 **외부·내부 인터페이스 계약**을 다룹니다.
구현보다 **계약(Contract)이 먼저** 작성되어야 합니다.

## 폴더 구조
```
04-api/
├── conventions.md       # API 설계 공통 규칙 (필독)
├── versioning.md        # 버전 정책
├── error-codes.md       # 표준 에러 코드
├── rest/                # REST API 스펙 (OpenAPI)
│   ├── auth.yaml
│   ├── users.yaml
│   └── ...
├── events/              # 이벤트 스키마 (AsyncAPI/JSON Schema)
│   ├── user-events.yaml
│   └── ...
└── webhooks.md          # 외부 시스템 웹훅 규격
```

## API First 원칙

```
[기획] → [API 계약 작성] → [리뷰] → [Mock 생성] → [구현] → [배포]
```

- 계약이 없으면 구현 시작 금지
- Frontend는 Mock으로 병렬 개발 가능
- 계약 변경은 Breaking 여부 판단 → Breaking이면 RFC 필수

## 작성 형식
- **REST**: OpenAPI 3.1 (.yaml)
- **GraphQL**: SDL 파일 + 별도 문서
- **이벤트**: AsyncAPI 또는 JSON Schema
- **gRPC**: .proto 파일

## SSOT (Single Source of Truth)
이 폴더의 스펙 파일이 **유일한 진실의 원천**입니다.
- 코드 생성: 이 스펙으로부터 클라이언트/서버 stub 생성
- 문서 생성: 이 스펙으로부터 자동 생성 (Swagger UI 등)
- 테스트: Contract Test로 검증

## 변경 절차
1. 변경 PR에 스펙 파일 수정 포함
2. Breaking Change면 라벨 `breaking-change` 추가
3. CHANGELOG에 명시
4. 클라이언트 팀에 사전 공지
