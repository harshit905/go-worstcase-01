# Expected SCA results — ground truth (Go, richer worst case)

`go.mod` pins exact versions, so the direct modules are certain. There is no
`go.sum`, so the scanner must walk `go mod graph`. This version adds two
worst-case features: a `replace` directive and a second known-vulnerable module.

## Summary

| bucket | packages |
|--------|----------|
| Vulnerable | `github.com/dgrijalva/jwt-go@3.2.0+incompatible`, `github.com/gorilla/websocket@1.4.0`, `github.com/golang-jwt/jwt/v4@4.4.0`, `golang.org/x/text@0.0.0-20170915032832-14c0d48ead0c` |
| Healthy | `github.com/google/uuid@1.3.0`, `gopkg.in/yaml.v2@2.4.0` (via `replace`), `github.com/davecgh/go-spew@1.1.1` (indirect), plus any transitive like `gopkg.in/check.v1` |
| Unresolved | none |

`github.com/harshit905/localmod` is replaced by the local `./localmod` directory
(the repo's own code) and is excluded from the resolved graph (or healthy at
`0.0.0`; either is fine). Never `go`/`toolchain` entries.

## Vulnerabilities
- **`github.com/dgrijalva/jwt-go@3.2.0+incompatible`** — access restriction
  bypass, `CVE-2020-26160` (`GHSA-w73w-5m7g-f7qc`). Unmaintained, no fix. Zero deps.
- **`github.com/gorilla/websocket@1.4.0`** — integer overflow / DoS,
  `CVE-2020-27813` (`GHSA-jf24-p9p9-4rjh`), fixed in 1.4.1. Zero deps.

## Healthy
- **`github.com/google/uuid@1.3.0`** — no advisories.
- **`gopkg.in/yaml.v2`** — see the replace test below.

## Worst-case feature 1 — the `replace` directive (the main thing to analyze)
`go.mod` declares `gopkg.in/yaml.v2 v2.2.2` (vulnerable, `CVE-2019-11254`) but
then `replace`s it with `v2.4.0` (patched). Go's build actually uses `2.4.0`.

- **CORRECT:** the SCA reports `gopkg.in/yaml.v2@2.4.0` as **healthy**. This means
  it derived versions from the module graph / build list, which honors `replace`.
- **FINDING (a real bug to flag):** the SCA reports `gopkg.in/yaml.v2@2.2.2` as
  **vulnerable**. That means it read the `require` version textually and ignored
  `replace`, so it is scanning a version the build never uses — a false positive.

Watch which one you get; this is the most interesting signal in this repo.

## Worst-case feature 2 — the `go`/`toolchain` pseudo-modules (fix verification)
`go mod graph` emits `go@1.21` and `toolchain@go1.21.x` pseudo-modules. A correct
SCA must NOT list them as packages.

- **CORRECT (after the fix):** no `go@...` or `toolchain@...` entries anywhere.
- **REGRESSION:** they appear under Healthy Packages (this is what the previous
  scan showed before the fix).

## Pass / fail
- PASS: jwt-go and websocket vulnerable; uuid healthy; yaml.v2 healthy at 2.4.0;
  no `go`/`toolchain` entries.
- FINDINGS to flag: yaml.v2 shown at 2.2.2 (replace ignored), or `go`/`toolchain`
  present (fix regressed), or any invented version.

## New edge case (regression re-test) — `// indirect` dependency
`go.mod` adds `github.com/davecgh/go-spew v1.1.1 // indirect`.
- **PASS:** `go-spew@1.1.1` is healthy and marked **transitive/indirect**.

## Round 2 edge cases

### A. Major-version module path (`github.com/golang-jwt/jwt/v4 v4.4.0`)
The module path carries the `/v4` suffix. Advisory matching must use the full
path `github.com/golang-jwt/jwt/v4`, not a stripped `github.com/golang-jwt/jwt`.
- **PASS:** `github.com/golang-jwt/jwt/v4@4.4.0` vulnerable (`CVE-2024-51744` /
  `GHSA-29wx-vh33-7x7r`, fixed 4.5.1; `CVE-2025-30204` / `GHSA-mh63-6h87-95cp`,
  fixed 4.5.2). Zero deps.
- **FAIL:** listed without `/v4`, healthy, or unresolved.

### B. Commit pseudo-version (`golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c`)
No go.mod at that commit, so zero deps. The version is older than 0.3.3.
- **PASS:** `golang.org/x/text` at that exact pseudo-version, vulnerable
  (`CVE-2020-14040`, fixed 0.3.3; `CVE-2021-38561`, fixed 0.3.7;
  `CVE-2022-32149`, fixed 0.3.8).
- **FAIL:** healthy (pseudo-version not compared as `< 0.3.3`), unresolved, or
  the version rewritten to something invented.

### C. `replace` to a local directory (`github.com/harshit905/localmod => ./localmod`)
The resolver must copy the whole manifest directory. If only `go.mod` is
copied, `go mod graph` fails with
`replacement directory ./localmod does not exist` and the WHOLE graph is lost.
- **PASS:** generation succeeds; `localmod` excluded or healthy at 0.0.0;
  every other result above unchanged.
- **FAIL:** 0 healthy / everything unresolved / 0 vulns (false all-clear), or
  `localmod` reported at an invented registry version.

### Round 2 pass / fail (combined)
- PASS: 4 vulnerable (jwt-go, websocket, jwt/v4, x/text pseudo-version);
  uuid, yaml.v2@2.4.0, go-spew healthy; no `go`/`toolchain`; 0 unresolved.
