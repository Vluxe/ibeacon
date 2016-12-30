package main

import (
	"database/sql"
	"fmt"
	"net/http"
	"net/url"

	"github.com/acmacalister/helm"
)

type jsonResponse struct {
	IsError       bool   `json:"is_error"`
	CustomMessage string `json:"custom_message"`
	Error         error  `json:"-"`
}

func ifError(custom string, err error, w http.ResponseWriter, code int) bool {
	if err != nil && err != sql.ErrNoRows {
		fmt.Printf("Error: " + custom + " " + err.Error() + "\n")
		helm.RespondWithJSON(w, jsonResponse{IsError: true, CustomMessage: "Error: " + custom + "\n"}, code)
		return true
	}
	return false
}

func fallThrough(w http.ResponseWriter, r *http.Request, params url.Values) {
	http.Error(w, "You done messed up A-aron", http.StatusNotFound)
}
