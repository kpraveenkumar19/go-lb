package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
)

func main() {
	port := flag.Int("port", 8080, "Port to serve on")
	name := flag.String("name", "server", "Server name")
	flag.Parse()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		reqID := r.Header.Get("X-Request-ID")
		if reqID == "" {
			reqID = "unknown"
		}
		log.Printf("[%s] Received Request [ReqID: %s] from [LB]", *name, reqID)
	})

	log.Printf("[%s] Starting server on port %d...", *name, *port)
	if err := http.ListenAndServe(fmt.Sprintf(":%d", *port), nil); err != nil {
		log.Fatal(err)
	}
}
