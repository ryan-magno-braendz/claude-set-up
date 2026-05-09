#!/bin/bash
# Hook: Stop — Verify tests pass before Claude finishes
# Detects the project's test runner and runs the test suite.
# Exit 2 = block stop, Exit 0 = allow stop.

INPUT=$(cat)

# Avoid infinite loop — if already in stop-hook, let through
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd // "."')
cd "$CWD" 2>/dev/null || exit 0

# Skip if no test infrastructure detected
run_tests() {
  # Node.js projects
  if [ -f "package.json" ]; then
    # Check if test script exists and isn't the default "no test specified"
    TEST_SCRIPT=$(jq -r '.scripts.test // empty' package.json 2>/dev/null)
    if [ -n "$TEST_SCRIPT" ] && ! echo "$TEST_SCRIPT" | grep -q "no test specified"; then
      if [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
        bun test 2>&1
      elif [ -f "pnpm-lock.yaml" ]; then
        pnpm test 2>&1
      elif [ -f "yarn.lock" ]; then
        yarn test 2>&1
      else
        npm test 2>&1
      fi
      return $?
    fi
  fi

  # Python projects
  if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "pytest.ini" ] || [ -d "tests" ]; then
    if command -v pytest &>/dev/null; then
      pytest --tb=short -q 2>&1
      return $?
    fi
  fi

  # Go projects
  if [ -f "go.mod" ]; then
    go test ./... 2>&1
    return $?
  fi

  # Rust projects
  if [ -f "Cargo.toml" ]; then
    cargo test 2>&1
    return $?
  fi

  # Java/Gradle
  if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    ./gradlew test 2>&1
    return $?
  fi

  # Java/Maven
  if [ -f "pom.xml" ]; then
    mvn test -q 2>&1
    return $?
  fi

  # No test runner found — allow stop
  return 0
}

OUTPUT=$(run_tests)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "Tests are failing. Fix them before finishing." >&2
  echo "" >&2
  echo "$OUTPUT" | tail -30 >&2
  exit 2
fi

exit 0
