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
	fmt.Println("Attempting to add question")
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

	var result interface{} //could be single question or multiple questions
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&result)

	if err != nil {
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}

	var questionsToUpdate []Question
	switch v := result.(type) {
	case map[string]interface{}:
		var singleQuestion Question
		// Populate singleQuestion from v
		singleQuestion.ID = int(v["id"].(float64))
		singleQuestion.Question = v["question"].(string)
		singleQuestion.Options = v["options"].(string)
		singleQuestion.CorrectIndex = int(v["correctIndex"].(float64))
		singleQuestion.CreatedTime = v["createdTime"].(string)
		singleQuestion.ModifiedTime = v["modifiedTime"].(string)
		singleQuestion.Completed = int(v["completed"].(float64))
		questionsToUpdate = append(questionsToUpdate, singleQuestion)
	case []interface{}:
		for _, item := range v {
			m := item.(map[string]interface{})
			var q Question
			q.ID = int(m["id"].(float64))
			q.Question = m["question"].(string)
			q.Options = m["options"].(string)
			q.CorrectIndex = int(m["correctIndex"].(float64))
			q.CreatedTime = m["createdTime"].(string)
			q.ModifiedTime = m["modifiedTime"].(string)
			q.Completed = int(m["completed"].(float64))
			questionsToUpdate = append(questionsToUpdate, q)
		}
	default:
		http.Error(w, "Unsupported data format", http.StatusBadRequest)
		return
	}
	err = updateQuestion(db, questionsToUpdate)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprint(w, "Question has been updated")
}

func deleteQuestionHander(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Attempting to delete question, message from server side")
	if r.Method != "DELETE" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	idStr := r.URL.Query().Get("id")
	id, err := strconv.Atoi(idStr)

	if err != nil {
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	err = deleteQuestion(db, id)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprint(w, "Question has been deleted")
}

func main() {
	initDatabase()
	http.HandleFunc("/api/questions", getQuestionsHandler)
	http.HandleFunc("/questions", showQuestions)
	http.HandleFunc("/api/add_question", addQuestionHandler)
	http.HandleFunc("/api/update_question", updateQuestionHander)
	http.HandleFunc("/api/delete_question", deleteQuestionHander)

	log.Println("Server started on: http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}