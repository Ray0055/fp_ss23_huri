package main

import (
	"encoding/json"
	"net/http"
	"os"
	"strconv"
)

type Question struct {
	ID           int      `json:"id"`
	Question     string   `json:"question"`
	Options      []string `json:"options"`
	CorrectIndex int      `json:"correntIndex"`
	CreatedTime  string   `json:"createdTime"`
	ModifiedTime string   `json:"modifiedTime"`
	Completed    int      `json:"completed"`
}

var questions = []Question{
	{
		ID:           0,
		Question:     `\( P \rightarrow Q \) if \( P \) is true, \( Q \) is false`,
		Options:      []string{"true", "false"},
		CorrectIndex: 1,
		CreatedTime:  "createdTime",
		ModifiedTime: "modifiedTime",
		Completed:    3,
	},
	{
		ID:           1,
		Question:     `\( P \land Q \) if \( P \) is false and \( Q \) is true`,
		Options:      []string{"true", "false"},
		CorrectIndex: 1,
		CreatedTime:  "createdTime",
		ModifiedTime: "modifiedTime",
		Completed:    3,
	},
	{
		ID:           2,
		Question:     `\( P \lor Q \) if \( P \) is false and \( Q \) is false`,
		Options:      []string{"true", "false"},
		CorrectIndex: 1,
		CreatedTime:  "createdTime",
		ModifiedTime: "modifiedTime",
		Completed:    3,
	},
	{
		ID:           3,
		Question:     `\( \lnot P \) if \( P \) is true`,
		Options:      []string{"true", "false"},
		CorrectIndex: 1,
		CreatedTime:  "createdTime",
		ModifiedTime: "modifiedTime",
		Completed:    3,
	},
	{
		ID:           4,
		Question:     `\( P \oplus Q \) if \( P \) is true and \( Q \) is true`,
		Options:      []string{"true", "false"},
		CorrectIndex: 1,
		CreatedTime:  "createdTime",
		ModifiedTime: "modifiedTime",
		Completed:    3,
	},
	{
		ID:           5,
		Question:     `\( P \iff Q \) if \( P \) is true and \( Q \) is false`,
		Options:      []string{"true", "false"},
		CorrectIndex: 1,
		CreatedTime:  "createdTime",
		ModifiedTime: "modifiedTime",
		Completed:    3,
	},
	{
		ID:           6,
		Question:     `\( \lnot (P \land Q) \) if \( P \) is true and \( Q \) is false`,
		Options:      []string{"true", "false"},
		CorrectIndex: 0,
		CreatedTime:  "createdTime",
		ModifiedTime: "modifiedTime",
		Completed:    3,
	},
	{
		ID:           7,
		Question:     `\( \lnot P \lor Q \) if \( P \) is true and \( Q \) is true`,
		Options:      []string{"true", "false"},
		CorrectIndex: 0,
		CreatedTime:  "createdTime",
		ModifiedTime: "modifiedTime",
		Completed:    3,
	},
	{
		ID:           8,
		Question:     `\( P \rightarrow \lnot Q \) if \( P \) is false and \( Q \) is true`,
		Options:      []string{"true", "false"},
		CorrectIndex: 0,
		CreatedTime:  "createdTime",
		ModifiedTime: "modifiedTime",
		Completed:    3,
	},
	{
		ID:           9,
		Question:     `\( P \lor \lnot Q \) if \( P \) is false and \( Q \) is false`,
		Options:      []string{"true", "false"},
		CorrectIndex: 0,
		CreatedTime:  "createdTime",
		ModifiedTime: "modifiedTime",
		Completed:    3,
	},
}

func saveQuestionsToFile() error {
	file, err := os.Create("questions.json")
	if err != nil {
		return err
	}
	defer file.Close()

	encoder := json.NewEncoder(file)
	err = encoder.Encode(questions)
	return err
}

func loadQuestionsFromFile() error {
	file, err := os.Open("questions.json")
	if err != nil {
		return err
	}
	defer file.Close()

	decoder := json.NewDecoder(file)
	err = decoder.Decode(&questions)
	return err
}

func addQuestionHandler(w http.ResponseWriter, r *http.Request) {
	var newQuestion Question
	err := json.NewDecoder(r.Body).Decode(&newQuestion)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	questions = append(questions, newQuestion)
	saveQuestionsToFile()
}

func deleteQuestionHandler(w http.ResponseWriter, r *http.Request) {
	idStr := r.URL.Query().Get("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	for index, question := range questions {
		if question.ID == id {
			questions = append(questions[:index], questions[index+1:]...)
			saveQuestionsToFile()
			return
		}
	}
	http.Error(w, "Question not found", http.StatusNotFound)
}

func editQuestionHandler(w http.ResponseWriter, r *http.Request) {
	var updatedQuestion Question
	err := json.NewDecoder(r.Body).Decode(&updatedQuestion)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	for index, question := range questions {
		if question.ID == updatedQuestion.ID {
			questions[index] = updatedQuestion
			saveQuestionsToFile()
			return
		}
	}
	http.Error(w, "Question not found", http.StatusNotFound)
}
