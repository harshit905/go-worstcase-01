module github.com/harshit905/sca-test-go

go 1.21

require (
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
	github.com/google/uuid v1.3.0
	github.com/gorilla/websocket v1.4.0
	gopkg.in/yaml.v2 v2.2.2
)

require github.com/davecgh/go-spew v1.1.1 // indirect

// Round 2: a major-version module path (/v4) and a commit pseudo-version.
require (
	github.com/golang-jwt/jwt/v4 v4.4.0
	golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
)

// Round 2: a module replaced by a LOCAL directory. The resolver must copy
// ./localmod or `go mod graph` fails on the missing replacement directory.
require github.com/harshit905/localmod v0.0.0

replace github.com/harshit905/localmod => ./localmod

// Worst case: `replace` swaps the vulnerable yaml.v2 2.2.2 for the patched
// 2.4.0. A correct SCA must report yaml.v2 at 2.4.0 (healthy), not 2.2.2.
replace gopkg.in/yaml.v2 => gopkg.in/yaml.v2 v2.4.0
