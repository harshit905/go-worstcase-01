# Expected SCA results — ground truth (Go)

## Summary

| bucket | count | packages |
|--------|-------|----------|
| Vulnerable | 2 | `github.com/dgrijalva/jwt-go@3.2.0+incompatible`, `gopkg.in/yaml.v2@2.2.2` |
| Healthy | 1 (+ transitives) | `github.com/google/uuid@1.3.0` |
| Unresolved | 0 | — |

Because `go.mod` carries exact versions, the three direct modules are read
straight from it, so their versions are certain regardless of network.

## Vulnerabilities
- **`github.com/dgrijalva/jwt-go@3.2.0+incompatible`** — access restriction
  bypass, `CVE-2020-26160` (`GHSA-w73w-5m7g-f7qc`). The library is unmaintained;
  no fixed version. Zero dependencies.
- **`gopkg.in/yaml.v2@2.2.2`** — denial of service while parsing, `CVE-2019-11254`
  (`GHSA-wxc4-f4m6-wwqv`), fixed in 2.2.8.

## Healthy
- **`github.com/google/uuid@1.3.0`** — no advisories.
- `gopkg.in/yaml.v2` may pull `gopkg.in/check.v1` as a transitive; if it appears,
  it is healthy. Treat any extra transitives as healthy unless your DB flags them.

## Notes / pass-fail
- PASS: jwt-go and yaml.v2 flagged vulnerable at the versions above; uuid healthy.
- Go's `go.mod` is exact, so a full generation failure is unlikely here; the main
  thing to verify is correct advisory matching on the two known-vulnerable pins,
  and that uuid is not falsely flagged.
- FAIL: either known vuln missing, uuid falsely flagged, or a version other than
  what `go.mod` pins.
