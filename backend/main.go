package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
	"todo-backend/data"
	todoHandlers "todo-backend/handlers"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	store, err := data.NewStore("./data")
	if err != nil {
		log.Fatalf("Failed to initialize store: %v", err)
	}

	h := &todoHandlers.Handler{Store: store}
	r := mux.NewRouter()
	h.RegisterRoutes(r)

	// CORS middleware
	corsRouter := handlers.CORS(
		handlers.AllowedOrigins([]string{"*"}),
		handlers.AllowedMethods([]string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}),
		handlers.AllowedHeaders([]string{"Content-Type", "Authorization"}),
	)(r)

	addr := fmt.Sprintf(":%s", port)
	fmt.Printf("🚀 Todo API server running on http://localhost%s\n", addr)
	fmt.Printf("📱 For Flutter app, use: http://<your-machine-ip>%s\n", addr)
	log.Fatal(http.ListenAndServe(addr, corsRouter))
}
