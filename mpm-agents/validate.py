"""
validate.py
===========

Author: Debraj Som

Validates that the orchestrator actually calls all three subagents
(figma_agent, spec_agent, test_agent) and that the wiring is sound - WITHOUT
needing an ANTHROPIC_API_KEY or any network access.

It forces MOCK mode (MPM_AGENTS_MOCK=1) so the subagents short-circuit instead
of calling the API, then runs the orchestrator's deterministic dispatch over a
sample requirement set and asserts that each subagent was invoked and reported
'completed' status.

Run:
    python validate.py
"""

from __future__ import annotations

import os
import sys
import tempfile
from pathlib import Path

# Force mock mode BEFORE importing the runner so MOCK is picked up.
os.environ["MPM_AGENTS_MOCK"] = "1"


def main() -> int:
    # 1. Imports succeed (catches syntax / wiring errors).
    import sdk_runner
    import figma_agent
    import spec_agent
    import test_agent
    import review_agent
    import orchestrator
    sdk_runner.print_banner()
    print("[ok] all modules import cleanly")

    assert sdk_runner.MOCK is True, "MOCK mode should be active"

    # 2. Each subagent runs in isolation under mock.
    st = sdk_runner.StatusTracker(status_file=Path(tempfile.gettempdir()) / "mpm_validate_iso.json")
    r1 = figma_agent.run_figma_agent("smoke", status=st)
    r2 = spec_agent.run_spec_agent("smoke", status=st)
    r3 = test_agent.run_test_agent("smoke", target="backend", status=st)
    r4 = review_agent.run_review_agent("smoke", target="backend", status=st)
    assert r1["ok"] and r1.get("mock"), f"figma_agent mock failed: {r1}"
    assert r2["ok"] and r2.get("mock"), f"spec_agent mock failed: {r2}"
    assert r3["ok"] and r3.get("mock"), f"test_agent mock failed: {r3}"
    assert r4["ok"] and r4.get("mock"), f"review_agent mock failed: {r4}"
    print("[ok] each subagent runs under mock mode")

    # 3. Orchestrator (deterministic mode) dispatches to ALL THREE subagents.
    sample = Path(tempfile.gettempdir()) / "mpm_validate_requirements.xlsx"
    orchestrator.write_sample_requirements(sample)
    print(f"[ok] sample requirements workbook written: {sample}")

    result = orchestrator.orchestrate(sample, use_llm=False)
    assert result.get("ok"), f"orchestration failed: {result}"

    # Read back the persisted status and confirm every subagent completed.
    import json
    status_data = json.loads(sdk_runner.STATUS_FILE.read_text(encoding="utf-8"))
    expected = {"figma_agent", "spec_agent", "test_agent", "review_agent"}
    called = {name for name, st in status_data.items()
              if name in expected and st["state"] == "completed" and st["tool_calls"] >= 1}
    missing = expected - called
    assert not missing, f"these subagents were NOT called by the orchestrator: {missing}"
    print(f"[ok] orchestrator called all subagents: {sorted(called)}")

    # 4. The routing logic maps the sample requirements as intended.
    reqs = orchestrator.read_requirements(sample)
    routes = {r["id"]: orchestrator._route(r) for r in reqs}
    assert routes.get("R1") == "spec_agent", routes
    assert routes.get("R2") == "figma_agent", routes
    assert routes.get("R6") == "test_agent", routes
    assert routes.get("R8") == "review_agent", routes
    print(f"[ok] requirement routing is correct: {routes}")

    # Figma URLs in the Notes column are extracted for the figma subagent.
    r2 = next(r for r in reqs if r["id"] == "R2")
    assert orchestrator._extract_figma_url(r2["notes"]) and "node-id=24-8" in orchestrator._extract_figma_url(r2["notes"]), \
        f"figma URL extraction failed for R2: {r2['notes']}"
    print("[ok] figma frame URLs are extracted from the requirements")

    print("\nVALIDATION PASSED: orchestrator -> {figma_agent, spec_agent, test_agent, review_agent} wiring verified.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except AssertionError as e:
        print(f"\nVALIDATION FAILED: {e}")
        sys.exit(1)
