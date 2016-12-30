package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/url"

	"github.com/acmacalister/helm"
	"github.com/gorilla/websocket"
)

var connected = false

type appReporter struct {
	PhoneID    string          `db:"phone_id" json:"phone_id"`
	BeaconData []iBeaconRecord `db:"-" json:"beacon_data"`
}

type iBeaconRecord struct {
	UUID     string  `db:"uuid" json:"uuid"`
	Distance float64 `db:"distance" json:"distance"`
}

type config struct {
	ar chan appReporter
}

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

func main() {

	fmt.Println("iBeacon API Server")

	conf := config{}
	conf.ar = make(chan appReporter)

	r := helm.New(fallThrough)
	r.POST("/ibeacon", conf.postIBeacon)
	r.GET("/ibeacon", conf.getIBeacon)
	r.Run(":6000")
}

func (conf *config) postIBeacon(w http.ResponseWriter, r *http.Request, params url.Values) {

	var ar appReporter
	err := json.NewDecoder(r.Body).Decode(&ar)
	fmt.Println(ar)
	r.Body.Close()
	if notOk := ifError("failed decoding json body", err, w, http.StatusBadRequest); notOk {
		return
	}
	if connected {
		conf.ar <- ar
	}
	helm.RespondWithJSON(w, "ok", http.StatusOK)
}

func (conf *config) getIBeacon(w http.ResponseWriter, r *http.Request, params url.Values) {

	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		fmt.Print("upgrade:", err)
		return
	}
	defer c.Close()
	connected = true
	defer deviceDisconnected()
	for {
		select {
		case msg := <-conf.ar:

			data, err := json.Marshal(msg)
			if err != nil {
				fmt.Printf("Error: %s", err)
				return
			}
			err = c.WriteMessage(websocket.TextMessage, data)
			if err != nil {
				log.Println("write:", err)
				break
			}
			//fmt.Println("wrote data")
		}
	}
}

func deviceDisconnected() {
	connected = false
}
