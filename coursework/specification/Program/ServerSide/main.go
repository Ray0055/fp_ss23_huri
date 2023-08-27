// package main

// import (
// 	"encoding/json"
// 	"log"
// 	"net/http"
// 	"strconv"
// 	"strings"
// 	"html/template"
// )
// var Questions = loadQuestionsFromFile()
// // 获取所有问题的处理函数。
// func getQuestionsHandler(w http.ResponseWriter, r *http.Request) {
// 	w.Header().Set("Content-Type", "application/json")
// 	if err := json.NewEncoder(w).Encode(Questions); err != nil {
// 		http.Error(w, "Failed to encode questions", http.StatusInternalServerError)
// 		return
// 	}
// }

// const PageSize = 50 // 每页50个问题

// func showQuestions(w http.ResponseWriter, r *http.Request) {
// 	page := 1 // 默认第一页
// 	pageStr := r.URL.Query().Get("page")
// 	if pageStr != "" {
// 		var err error
// 		page, err = strconv.Atoi(pageStr)
// 		if err != nil {
// 			http.Error(w, "Invalid page number", http.StatusBadRequest)
// 			return
// 		}
// 	}

// 	start := (page - 1) * PageSize
// 	end := start + PageSize
// 	if end > len(Questions) {
// 		end = len(Questions)
// 	}

// 	tmpl, err := template.ParseFiles("questions.html")
// 	if err != nil {
// 		log.Println("Error parsing template:", err)
// 		http.Error(w, "Internal server error", http.StatusInternalServerError)
// 		return
// 	}

// 	err = tmpl.Execute(w, Questions[start:end])
// 	if err != nil {
// 		log.Println("Error executing template:", err)
// 		http.Error(w, "Internal server error", http.StatusInternalServerError)
// 	}
// }

// func questionsHandler(w http.ResponseWriter, r *http.Request) {
// 	log.Println("Questions:", Questions)
// 	if strings.Contains(r.Header.Get("Accept"), "application/json") {
// 		getQuestionsHandler(w, r)
// 	} else {
// 		showQuestions(w, r)
// 	}
// }

// func main() {
// 	http.HandleFunc("/api/questions", questionsHandler)
// 	http.HandleFunc("/questions", showQuestions)
// 	http.HandleFunc("/api/questions/add", addQuestionHandler)
// 	http.HandleFunc("/api/question/delete", deleteQuestionHandler)
// 	http.HandleFunc("/api/question/edit", editQuestionHandler)

// 	log.Println("Server started on: http://localhost:8080/api/questions")
// 	if err := http.ListenAndServe(":8080", nil); err != nil {
// 		log.Fatal("ListenAndServe: ", err)
// 	}
// }

package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type Question struct {
	ID           int      `json:"id"`
	Question     string   `json:"question"`
	Options      []string `json:"options"`
	CorrectIndex int      `json:"correctIndex"`
	CreatedTime  string   `json:"createdTime"`
	ModifiedTime string   `json:"modifiedTime"`
	Completed    int      `json:"completed"`
}

func _loadQuestionsFromFile() ([]Question, error) {
	file, err := os.Open("questions.json")
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var questions []Question
	decoder := json.NewDecoder(file)
	err = decoder.Decode(&questions)
	if err != nil {
		return nil, err
	}

	return questions, nil
}

func main() {
	fmt.Println(_loadQuestionsFromFile())
}
