# Feature Registry (기능-문서 매핑)

> 각 기능(Feature)이 프로젝트 전체에서 어디에 문서화되어 있는지 추적하는 중앙 레지스트리.
> 분산된 "관련 문서" 섹션의 **SSOT (Single Source of Truth)**.

<!-- AUTO:UPDATED:START -->
> 마지막 갱신: 2026-04-25 _(자동 생성)_
<!-- AUTO:UPDATED:END -->

## 사용법

```bash
# 자동 갱신 (Feature 추가/수정 후 실행)
bash .claude/scripts/sync-registry.sh

# CI 검증 (registry가 실제 파일과 동기화되어 있는지 확인)
bash .claude/scripts/sync-registry.sh --check

# 특정 기능의 모든 관련 문서 확인
grep -r "F-001" docs/
```

> **참고**: 아래 `Feature Map` YAML 블록과 `도메인별 인덱스` 테이블은
> `sync-registry.sh`가 자동 생성합니다. 직접 편집하지 마세요.
> 변경하려면 원본 문서(F-XXX PRD, 도메인 폴더)를 수정 후 스크립트를 재실행하세요.

---

## Feature Map

<!-- AUTO:FEATURES:START -->
```yaml
# (등록된 Feature 없음. docs/01-product/features/F-XXX-*.md 추가 후 재실행)
```
<!-- AUTO:FEATURES:END -->

---

## 도메인별 인덱스

<!-- AUTO:DOMAINS:START -->
| 도메인 | 관련 Features | 도메인 문서 | 상태 |
|---|---|---|---|
| (도메인 없음) | — | — | — |
<!-- AUTO:DOMAINS:END -->

---

## 관련 문서
- **기능 목록**: [Features INDEX](../01-product/features/INDEX.md)
- **ADR 목록**: [Decisions INDEX](../07-decisions/INDEX.md)
- **도메인 가이드**: [Domains CLAUDE.md](../02-domains/CLAUDE.md)
- **자동 동기화 스크립트**: `.claude/scripts/sync-registry.sh`
