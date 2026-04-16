# Architecture 폴더 가이드

이 폴더는 **시스템이 어떻게 구성되고 동작하는가**를 다룹니다.
도메인 로직은 `02-domains/`, 결정 근거는 `07-decisions/`에 있습니다.

## 폴더 구조
```
03-architecture/
├── overview.md          # 시스템 한 장 요약 (가장 먼저 읽을 것)
├── tech-stack.md        # 기술 스택과 선택 이유
├── system-context.md    # C4 Level 1 (외부 시스템과의 관계)
├── containers.md        # C4 Level 2 (서비스/앱 단위)
├── components.md        # C4 Level 3 (서비스 내부 구조)
├── data-flow.md         # 데이터 흐름
├── security.md          # 보안 모델
├── infrastructure.md    # 클라우드 인프라
└── diagrams/            # Mermaid/PlantUML 원본
```

## C4 모델 사용
이 프로젝트는 [C4 Model](https://c4model.com/)을 따릅니다:
- **L1 Context**: 우리 시스템과 외부 세계
- **L2 Containers**: 배포 가능한 단위 (앱, DB, 큐)
- **L3 Components**: 컨테이너 내부 모듈
- **L4 Code**: (필요 시만, 보통 코드로 충분)

## 다이어그램 작성 규칙
- 모든 다이어그램은 Mermaid 또는 PlantUML
- 원본은 `diagrams/`에 `.mmd` 또는 `.puml`로 저장
- 마크다운에 임베드해서 사용
- ❌ Figma, draw.io, 이미지 파일 금지 (Claude가 못 읽음)

## 갱신 정책
- 시스템 구조가 변경되면 **PR과 함께** 다이어그램도 갱신
- 갱신 안 된 다이어그램은 거짓말
