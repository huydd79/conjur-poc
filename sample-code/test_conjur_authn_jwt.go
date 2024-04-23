package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

var CONJUR_HOST = "conjur.home.huydo.net"
var CONJUR_ACCOUNT = "DEMO"
var CONJUR_SECRET_PATH = "test/host1/pass"
var JWT_SERVICE_ID = "testjwt"
var JWT_FILE = "./test.jwt"

func main() {

	// Building authentication request
	url := "https://" + CONJUR_HOST + "/authn-jwt/" + JWT_SERVICE_ID + "/" + CONJUR_ACCOUNT + "/authenticate"
	method := "POST"

	data, err := os.ReadFile(JWT_FILE)
	if err != nil {
		fmt.Print(err)
	}
	JWT := string(data)
	payload := strings.NewReader("jwt=" + JWT)

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
