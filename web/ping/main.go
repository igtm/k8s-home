package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", Ping)
    http.ListenAndServe(":80", nil)
}

func Ping(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Ping, %s!", r.URL.Path[1:])
}