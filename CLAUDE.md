# 프로젝트 컨텍스트

> Claude Code 자동 로드. **프로젝트 고유값 + 핵심 원칙**만.
> 상세 규칙: [docs/README.md](docs/README.md)

---

## 요약
{UNSET: 무엇을, 누구를 위해, 왜}
> ⚠️ `{UNSET}`은 미결정 상태입니다. 추측하지 말고 사용자에게 확인하세요.

## 현황
- **단계**: {UNSET: MVP / Beta / Production}
- **갱신**: {UNSET: YYYY-MM-DD}

---

## 작업 방식

`1-feat/{F-XXX}-{슬러그}.md` → `2-web/{F-XXX}-{슬러그}.md` → `3-api/{F-XXX}-{슬러그}.md`

| 단계 | 폴더 | 질문 |
|------|------|------|
| 기획 | `1-feat/` | 무엇을, 왜 |
| 프론트 | `2-web/` | 어떻게 보이나 (+ 필요 API) |
| 백엔드 | `3-api/` | 어떻게 동작하나 |

- **순서 준수.** 해당 없는 단계는 스킵 (역행 금지)
- **공통은 `0-shared/`에 한 번만.** 기능 문서는 링크 참조
- **경량 모드.** 소규모는 `1-feat/` 한 장으로

---

## 핵심 원칙

- 환경변수/시크릿은 `.env`로, 하드코딩 금지
- 구현 전 `docs/1-feat/` 문서 선행
- TDD: 인수조건 → RED → GREEN → REFACTOR
- 문서가 SSOT: 설계 변경은 문서 먼저, 그다음 코드
- Mermaid만 사용, 미결정은 `{UNSET}`

## 자동개선

- 작업 후 **self-review**: 개선점은 해당 문서에 반영
- 반복 실수/패턴 → `0-shared/lessons-learned.md`에 기록
- 새 통찰 → 이 파일에 규칙 추가 제안
- 예: "API 응답 401 통일" 깨달으면 → `conventions.md` 갱신
- 예: "3번째 같은 버그" → 템플릿에 검증 항목 추가
- **모든 작업 종료 후** `lessons-learned.md` 확인 및 `grep -r "{UNSET}" docs/` 실행

---

## 새 기능 시작

```bash
N=$(ls docs/1-feat/F-*.md 2>/dev/null | wc -l)  # 다음 ID = F-$(printf "%03d" $((N+1)))
SLUG="{슬러그}"  # kebab-case
cp docs/1-feat/_template.md "docs/1-feat/F-$(printf "%03d" $((N+1)))-${SLUG}.md"
cp docs/2-web/_template.md "docs/2-web/F-$(printf "%03d" $((N+1)))-${SLUG}.md"
cp docs/3-api/_template.md "docs/3-api/F-$(printf "%03d" $((N+1)))-${SLUG}.md"
grep -r "{UNSET}" docs/
```

---

## 기술 스택
{UNSET: 언어, 프레임워크, DB, 인프라}

## 컨벤션
{UNSET: 포맷터, 린터, 테스트, 커밋, 브랜치}
