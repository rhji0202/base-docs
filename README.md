# [프로젝트명]

> [한 줄 설명]

## Quick Start

```bash
# 의존성 설치
[설치 명령]

# 개발 서버 실행
[실행 명령]

# 테스트
[테스트 명령]
```

## 문서

전체 기획·설계 문서는 [`docs/`](./docs) 디렉토리에 있으며, **기획 → 프론트엔드 설계 → 백엔드 설계** 3단계로 흐릅니다. ([워크플로우 설명](./docs/README.md))

- 🔗 [전역 공통](./docs/0-shared/) — 용어집·공통 API 규약 (모든 단계가 참조)
- 📝 [기획](./docs/1-feat/)
- 🎨 [프론트엔드 설계](./docs/2-web/)
- ⚙️ [백엔드 설계](./docs/3-api/)

## 기여 방법

각 폴더의 `_template.md`를 복사해 시작합니다. 새 기능은 항상 기획부터.

```bash
# 다음 ID 확인 후 템플릿 복사
N=$(ls docs/1-feat/F-*.md 2>/dev/null | wc -l)
cp docs/1-feat/_template.md "docs/1-feat/F-00$((N+1))-{슬러그}.md"
cp docs/2-web/_template.md "docs/2-web/F-00$((N+1))-{슬러그}.md"
cp docs/3-api/_template.md "docs/3-api/F-00$((N+1))-{슬러그}.md"
```

## License
[라이선스]
