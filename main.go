package main

import (
	"fmt"
	"log"
	"net/http"
)

// rootHandler handles requests to the root path ("/").
// It writes a friendly greeting to the response.
func rootHandler(w http.ResponseWriter, r *http.Request) {
	// Set the content type header to ensure the browser renders the text correctly.
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	// Write the response string.
	fmt.Fprint(w, "Hello from Kubernetes!")
}

// healthHandler handles requests to the "/health" path.
// This is a common pattern for load balancers or container orchestrators
// like Kubernetes to check if the application is alive and healthy.
func healthHandler(w http.ResponseWriter, r *http.Request) {
	// Set the content type and write a simple "OK!" response.
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	fmt.Fprint(w, "OK!")
}

func main() {
	// Register the handler functions for specific URL paths.
	// http.HandleFunc sets up the default router (also known as a ServeMux).
	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/health", healthHandler)

	// Define the port the server will listen on.
	const port = "8080"

	// Log a message to the console to indicate the server is starting.
	log.Printf("Kubernetes Example Application listening on port %s", port)

	// Start the HTTP server on the specified port.
	// http.ListenAndServe blocks until the server is stopped or an error occurs.
	// If an error occurs (e.g., the port is already in use), it will be logged.
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
