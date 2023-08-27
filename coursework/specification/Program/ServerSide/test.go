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

func init() {
	fmt.Println(_loadQuestionsFromFile())
}
