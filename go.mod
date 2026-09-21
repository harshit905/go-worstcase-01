module github.com/harshit905/sca-test-go

go 1.21

require (
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
	github.com/google/uuid v1.3.0
	github.com/gorilla/websocket v1.4.0
	gopkg.in/yaml.v2 v2.2.2
)

require github.com/davecgh/go-spew v1.1.1 // indirect

// Worst case: `replace` swaps the vulnerable yaml.v2 2.2.2 for the patched
// 2.4.0. A correct SCA must report yaml.v2 at 2.4.0 (healthy), not 2.2.2.
replace gopkg.in/yaml.v2 => gopkg.in/yaml.v2 v2.4.0
