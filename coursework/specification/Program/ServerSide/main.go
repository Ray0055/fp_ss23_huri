package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"text/template"
)

const PageSize = 50

func getQuestionsHandler(w http.ResponseWriter, r *http.Request) {
	questions, err := getQuestionsFromDB()
	if err != nil {
		http.Error(w, "Failed to get questions from database", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(questions); err != nil {
		http.Error(w, "Failed to encode questions", http.StatusInternalServerError)
		return
	}
}

func showQuestions(w http.ResponseWriter, r *http.Request) {
	page := 1
	pageStr := r.URL.Query().Get("page")
	if pageStr != "" {
		var err error
		page, err = strconv.Atoi(pageStr)
		if err != nil {
			http.Error(w, "Invalid page number", http.StatusBadRequest)
			return
		}
	}

	questions, err := getQuestionsFromDB()
	if err != nil {
		http.Error(w, "Failed to get questions from database", http.StatusInternalServerError)
		return
	}

	start := (page - 1) * PageSize
	end := start + PageSize
	if end > len(questions) {
		end = len(questions)
	}

	tmpl, err := template.ParseFiles("questions.html")
	if err != nil {
		log.Println("Error parsing template:", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	err = tmpl.Execute(w, questions[start:end])
	if err != nil {
		log.Println("Error executing template:", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
	}
}

func addQuestionHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var q Question
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&q)

	if err != nil {
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	err = addQuestion(db, q)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprint(w, "New question added")
}

func updateQuestionHander(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Attempting to update question")
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var q Question
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&q)

	if err != nil {
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	err = updateQuestion(db, q)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprint(w, "Question has been updated")
}
func main() {
	initDatabase()
	http.HandleFunc("/api/questions", getQuestionsHandler)
	http.HandleFunc("/questions", showQuestions)
	http.HandleFunc("/api/add_question", addQuestionHandler)
	http.HandleFunc("/api/update_question", updateQuestionHander)
	log.Println("Server started on: http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
