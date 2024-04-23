package main

import (
	"fmt"
	"io"
	"net/http"
	"strings"
)

var CONJUR_HOST = "conjur.home.huydo.net"
var CONJUR_ACCOUNT = "DEMO"
var CONJUR_USER_ID = "testuser01@test"
var CONJUR_USER_KEY = "1x1hh0f211c133nzbt6d25v50vrtzyvkm86mzm81h89f392gvexx2"
var CONJUR_SECRET_PATH = "test/host1/pass"

func main() {

	// Building authentication request
	url := "https://" + CONJUR_HOST + "/authn/" + CONJUR_ACCOUNT + "/" + CONJUR_USER_ID + "/authenticate"
	method := "POST"

	payload := strings.NewReader(CONJUR_USER_KEY)

	client := &http.Client{}
	req, err := http.NewRequest(method, url, payload)
 
	if err != nil {
		fmt.Println(err)
		return
	}
	req.Header.Add("Accept-Encoding", "base64")
	req.Header.Add("Content-Type", "text/plain")

	res, err := client.Do(req)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		fmt.Println(err)
		return
	}

	TOKEN := string(body)
	fmt.Println("TOKEN: " + TOKEN)

	// Building secret querry request
	url = "https://" + CONJUR_HOST + "/secrets/" + CONJUR_ACCOUNT + "/variable/" + CONJUR_SECRET_PATH
	method = "GET"

	req, err = http.NewRequest(method, url, payload)

	if err != nil {
		fmt.Println(err)
		return
	}
	req.Header.Add("Authorization", "Token token=\""+TOKEN+"\"")

	res, err = client.Do(req)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer res.Body.Close()

	body, err = io.ReadAll(res.Body)
	if err != nil {
		fmt.Println(err)
		return
	}

	SECRET := string(body)
	fmt.Println("SECRET: " + SECRET)
}
