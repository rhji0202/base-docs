# Testing Requirements

## 기본은 TDD

머지되는 구현 코드는 **기본적으로 TDD로** 작성한다 — 테스트보다 구현을 먼저 쓰지 않는다. "나중에 추가"·"간단해서 생략"으로 회피하지 않는다.

**예외**: 스파이크·PoC·일회성 스크립트·throwaway 실험은 테스트 없이 진행할 수 있다. 단 **결과물을 머지/유지하기로 하면 그때 테스트를 보강**한다. 순수 설정/마크다운/생성 코드 등 로직 없는 파일은 애초에 대상 아님.

**테스트의 출발점은 인수 조건이다** — `docs/1-feat/<슬러그>.md`의 인수 조건(Acceptance Criteria)을 그대로 테스트 케이스로 옮긴다. 설계(`docs/3-api`)가 끝나면 → 테스트 작성(RED) → 구현(GREEN) 순서로 진행한다.

## Test Coverage 목표: {UNSET: 예 — 80%}

> 커버리지 수치는 프로젝트가 정한다. 정하기 전 기본 가이드는 80%.

Test Types (프로젝트 규모에 맞게):
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (해당하는 경우. UI 없는 기능은 제외)

## Test-Driven Development

MANDATORY workflow:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Troubleshooting Test Failures

1. Use **tdd-guide** agent
2. Check test isolation
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)

## Agent Support

- **tdd-guide** - Use PROACTIVELY for new features, enforces write-tests-first

## Test Structure (AAA Pattern)

Prefer Arrange-Act-Assert structure for tests:

```typescript
test('calculates similarity correctly', () => {
  // Arrange
  const vector1 = [1, 0, 0]
  const vector2 = [0, 1, 0]

  // Act
  const similarity = calculateCosineSimilarity(vector1, vector2)

  // Assert
  expect(similarity).toBe(0)
})
```

### Test Naming

Use descriptive names that explain the behavior under test:

```typescript
test('returns empty array when no markets match query', () => {})
test('throws error when API key is missing', () => {})
test('falls back to substring search when Redis is unavailable', () => {})
```
