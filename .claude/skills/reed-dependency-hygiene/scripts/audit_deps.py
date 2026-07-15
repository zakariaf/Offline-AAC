#!/usr/bin/env python3
"""Audit the FULL transitive pub dependency tree for banned data paths.

Usage (from the repo root):
    dart pub deps --json > /tmp/deps.json
    python3 .claude/skills/reed-dependency-hygiene/scripts/audit_deps.py /tmp/deps.json

Exit 0 = clean. Exit 1 = a banned package is reachable, directly or transitively.
Direct-only inspection of pubspec.yaml cannot find these; that is the point.
"""

import json
import re
import sys

# Substring patterns matched against package names, case-insensitive.
# Each entry: (pattern, why it is refused)
BANNED = [
    (r"^firebase", "Firebase — its core pulls in device/usage data categories that worsen the store privacy label"),
    (r"^cloud_fire", "Firebase — same"),
    (r"crashlytics", "crash reporting = telemetry; the on-device exportable log is the only field signal"),
    (r"sentry", "crash reporting = telemetry"),
    (r"analytics", "analytics of any kind is refused, not un-built"),
    (r"^posthog|^mixpanel|^amplitude|^segment", "analytics"),
    (r"^google_mobile_ads|^appsflyer|^adjust", "ads/attribution SDK — network + identifiers"),
    (r"^http$|^dio$|^web_socket|^grpc$|^socket_io", "a network client. There is no INTERNET permission and never will be"),
    (r"^googleapis|^google_sign_in|^firebase_auth", "accounts and network"),
    (r"^package_info_plus|^device_info_plus", "collects device identifiers for no feature we ship"),
    (r"^provider$|^freezed$|^equatable$|^go_router$|^melos$|^glados$|^custom_lint$",
     "refused for architectural reasons, not privacy — do not reintroduce transitively without a decision"),
]

ALLOW = set()  # add a package name here only alongside a written justification in the repo


USAGE = """usage: audit_deps.py <deps.json>

Generate the input first:
    dart pub deps --json > deps.json

Flags any banned package in the resolved tree and says whether it arrived
directly or transitively. Exits 1 on a hit so it can gate CI."""


def main() -> int:
    if len(sys.argv) != 2 or sys.argv[1] in ("-h", "--help"):
        print(USAGE, file=sys.stderr)
        return 2
    try:
        with open(sys.argv[1]) as f:
            data = json.load(f)
    except OSError as e:
        print(f"audit_deps: cannot read {sys.argv[1]}: {e}", file=sys.stderr)
        return 2
    except json.JSONDecodeError as e:
        print(f"audit_deps: {sys.argv[1]} is not valid JSON: {e}", file=sys.stderr)
        print("  (expected the output of: dart pub deps --json)", file=sys.stderr)
        return 2

    pkgs = {p["name"]: p for p in data.get("packages", [])}
    names = {n for n, p in pkgs.items() if p.get("kind") != "root"}

    def reachable(kind: str) -> set[str]:
        """Everything pulled in, transitively, by one class of declared dependency."""
        seen: set[str] = set()
        stack = [n for n, p in pkgs.items() if p.get("kind") == kind]
        while stack:
            n = stack.pop()
            if n in seen or n not in pkgs:
                continue
            seen.add(n)
            stack.extend(pkgs[n].get("dependencies", []))
        return seen

    # What ships is what `dependencies:` drags in. `dev_dependencies:` — build_runner,
    # drift_dev, the test framework — never reach the APK, so a banned package that is
    # ONLY reachable from them is not a shipping defect. This distinction is the whole
    # point: build_runner pulls shelf and web_socket_channel for its watch-mode server,
    # and drift codegen requires build_runner. A gate that fails on an unavoidable dev
    # dependency gets switched off, which is worse than no gate.
    ships = reachable("direct")
    dev_only = reachable("dev") - ships

    def banned_in(pool: set[str]) -> list[tuple[str, str]]:
        found = []
        for name in sorted(pool):
            if name in ALLOW:
                continue
            for pattern, why in BANNED:
                if re.search(pattern, name, re.IGNORECASE):
                    found.append((name, why))
                    break
        return found

    hits = banned_in(ships)
    noise = banned_in(dev_only)
    direct_names = {n for n, p in pkgs.items() if p.get("kind") == "direct"}

    print(f"{len(names)} resolved · {len(ships)} ship in the APK · {len(dev_only)} build/test only")
    for name, why in hits:
        how = "direct" if name in direct_names else "TRANSITIVE"
        print(f"BANNED  {name}  [{how}]\n        {why}")

    if noise:
        print(f"\nBuild/test only — not in the APK, not a defect:")
        for name, _ in noise:
            print(f"  {name}")

    if hits:
        print("\nRefuse the dependency, or find one that does not pull these in.")
        print("To see who pulls a package in:  dart pub deps | grep -B4 <name>")
        return 1

    print("\nClean: nothing banned reaches the binary.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
