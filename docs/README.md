# 문서 (docs/)

이 프로젝트의 문서는 **기획 → 프론트엔드 설계 → 백엔드 설계** 3단계로 흐릅니다.

## 구조

```
docs/
├── 0-shared/ # 전역 공통: 용어집, 공통 API 규약 (모든 단계가 참조)
├── 1-feat/   # 기획: 무엇을, 왜 만드는가
├── 2-web/    # 프론트엔드 설계: 화면, API 연동
└── 3-api/    # 백엔드 설계: 데이터 모델, API, 에러 처리
```

> `0-shared`는 단계가 아니라 **기반**입니다. 여러 기능이 공유하는 것은 여기 한 번만 적고 기능 문서는 링크로 참조합니다.

## 워크플로우

하나의 기능은 **같은 F-XXX 슬러그**의 문서로 세 단계를 순서대로 통과합니다.

```
1-feat/F-001-user-login.md  →  2-web/F-001-user-login.md  →  3-api/F-001-user-login.md
       (무엇/왜)                     (어떻게 보이나)                (어떻게 동작하나)
```

1. **기획** — 무엇을, 누구를 위해, 왜 만드는지 정한다. 요구사항과 인수 조건까지.
2. **프론트엔드 설계** — 기획을 화면으로 옮기고, 백엔드에 필요한 API를 정의한다.
3. **백엔드 설계** — 프론트가 요구한 API를 데이터 모델·API·에러 처리로 구현 설계한다.
4. **자가개선** — 발견한 패턴/교훈을 `0-shared/lessons-learned.md`에 기록한다.

> **단계 스킵**: 관련 있는 단계만. UI 없는 기능은 `2-web` 생략, `1-feat → 3-api`.
> **경량 모드**: 소규모는 `1-feat/` 한 장에 인라인.
> **비-웹 프로젝트**: `2-web`=클라이언트/표면 설계, `3-api`=내부/처리 설계.

### 예시: `user-login` 기능

- `1-feat/F-001-user-login.md` — "이메일+비번 로그인". 인수 조건: 5회 실패 시 잠금.
- `2-web/F-001-user-login.md` — 로그인 화면 1개, API `POST /auth/login` 정의.
- `3-api/F-001-user-login.md` — API 구현 설계(검증·토큰 발급·잠금 로직). 공통 규약은 `0-shared/conventions.md` 참조.
- 이후 구현: 인수 조건을 테스트로(RED) → 구현(GREEN).

> 완성된 예시: [`docs/_example/`](../_example/) — F-001-user-login 3단계 완성본

## 새 문서 만들기

```bash
N=$(ls docs/1-feat/F-*.md 2>/dev/null | wc -l)
cp docs/1-feat/_template.md "docs/1-feat/F-$(printf "%03d" $((N+1)))-{슬러그}.md"
cp docs/2-web/_template.md "docs/2-web/F-$(printf "%03d" $((N+1)))-{슬러그}.md"
cp docs/3-api/_template.md "docs/3-api/F-$(printf "%03d" $((N+1)))-{슬러그}.md"
```

## 작성 원칙

- **파일명은 `F-XXX-영문-kebab-슬러그`.** 세 폴더에서 같은 인덱스+슬러그로 상호 링크.
- **F-XXX 할당은 순차적으로.** `ls docs/1-feat/F-*.md | wc -l`로 다음 ID 확인.
- **한 파일 = 한 기능/한 주제.**
- **상호 참조는 상대 경로.** 복사 후 `{F-XXX-슬러그}`를 실제 파일명으로 치환.
- **Mermaid만 사용.** Figma/이미지 링크 금지.
- **미결정은 `{UNSET}`.** `grep -r "{UNSET}" docs/`로 추적.
