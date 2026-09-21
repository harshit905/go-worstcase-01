# Expected SCA results — ground truth (Go, richer worst case)

`go.mod` pins exact versions, so the direct modules are certain. There is no
`go.sum`, so the scanner must walk `go mod graph`. This version adds two
worst-case features: a `replace` directive and a second known-vulnerable module.

## Summary

| bucket | packages |
|--------|----------|
| Vulnerable | `github.com/dgrijalva/jwt-go@3.2.0+incompatible`, `github.com/gorilla/websocket@1.4.0` |
| Healthy | `github.com/google/uuid@1.3.0`, `gopkg.in/yaml.v2@2.4.0` (via `replace`), plus any transitive like `gopkg.in/check.v1` |
| Unresolved | none |

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
