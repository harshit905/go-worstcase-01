# SCA test repo — Go, worst case (no go.sum)

`go.mod` already pins exact versions, so Go is less about generation and more
about correct advisory matching. There is NO `go.sum` committed, so the scanner
must run `go mod graph` (with `-mod=mod`) to walk the module graph without a lock.

See `EXPECTED_RESULTS.md` for the ground truth.

## Run it
1. New GitHub repo, e.g. `harshit905/sca-test-go`.
2. `git remote add origin <url>` then `git push -u origin main`.
3. Scan in CodeAnt, compare to `EXPECTED_RESULTS.md`.

Do NOT commit `go.sum`.
