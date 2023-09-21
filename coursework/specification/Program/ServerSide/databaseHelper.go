package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"

	_ "github.com/go-sql-driver/mysql"
)

type Question struct {
	ID           int      `json:"id"`
	Question     string   `json:"question"`
	Options      []string `json:"options"`
	CorrectIndex int      `json:"correctIndex"`
	CreatedTime  string   `json:"createdTime"`
	ModifiedTime string   `json:"modifiedTime"`
	Completed    int      `json:"completed"`
	Information  string   `json:"information"`
}

var db *sql.DB

func initDatabase() {
	var err error
	db, err = sql.Open("mysql", "root:747025@tcp(127.0.0.1:3306)/questions_db")
	if err != nil {
		log.Fatal("Failed to connect to the database:", err)
	}

	// Read JSON file
	jsonFile, err := os.Open("questions.json")
	if err != nil {
		log.Fatal("Failed to open JSON file:", err)
	}
	defer jsonFile.Close()
	byteValue, _ := io.ReadAll(jsonFile)

	var questions []Question
	err = json.Unmarshal(byteValue, &questions)

	if err != nil {
		log.Fatal("Failed to decode JSON:", err)
	}

	for _, question := range questions {
		err = addQuestion(db, question)
		if err != nil {
			fmt.Printf("add question failed.")
			return
		}

	}

	fmt.Printf("Database has been initialed, questions have been loaded.")

}

func getQuestionsFromDB() ([]Question, error) {
	rows, err := db.Query("SELECT * FROM questions")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var questions []Question
	for rows.Next() {
		var q Question
		var optionsJSON string // 使用 string 类型来接收 JSON 字符串

		if err := rows.Scan(&q.ID, &q.Question, &optionsJSON, &q.CorrectIndex, &q.CreatedTime, &q.ModifiedTime, &q.Completed, &q.Information); err != nil {
			return nil, err
		}

		// 反序列化 JSON 字符串到 q.Options
		if err := json.Unmarshal([]byte(optionsJSON), &q.Options); err != nil {
			return nil, err
		}

		questions = append(questions, q)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return questions, nil
}

func addQuestion(db *sql.DB, newQuestion Question) error {
	fmt.Println("Attempting to insert question:", newQuestion)

	optionsJSON, err := json.Marshal(newQuestion.Options)
	if err != nil {
		fmt.Println("Error while marshalling options:", err)
		return err
	}

	result, err := db.Exec("INSERT IGNORE INTO questions (id, question, options, correctIndex, createdTime, modifiedTime, completed, information) VALUES (?,?, ?, ?, ?, ?, ?, ?)",
		newQuestion.ID, newQuestion.Question, string(optionsJSON), newQuestion.CorrectIndex, newQuestion.CreatedTime, newQuestion.ModifiedTime, newQuestion.Completed, newQuestion.Information)
	if err != nil {
		fmt.Println("Error while inserting:", err)
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		fmt.Println("Error while checking affected rows:", err)
		return err
	}

	fmt.Printf("Successfully inserted. Rows affected: %d\n", rowsAffected)
	return nil
}

func deleteQuestion(db *sql.DB, id int) error {
	fmt.Println("DeleteQuestion function of databaseHelper is called")
	var err error
	_, err = db.Exec("DELETE FROM questions WHERE id=?", id)
	if err != nil {
		fmt.Println("Error deleting question:", err)
		return err
	}

	return nil
}

func updateQuestion(db *sql.DB, updatedQuestions []Question) error {
	for _, updatedQuestion := range updatedQuestions {
		fmt.Println("Attempting to update question:", updatedQuestion)

		// SQL UPDATE statement
		query := `
	UPDATE questions SET
		question = ?,
		options = ?,
		correctIndex = ?,
		createdTime = ?,
		modifiedTime = ?,
		completed = ?,
		information = ?
	WHERE
		ID = ?`

		result, err := db.Exec(query,
			updatedQuestion.Question,
			updatedQuestion.Options,
			updatedQuestion.CorrectIndex,
			updatedQuestion.CreatedTime,
			updatedQuestion.ModifiedTime,
			updatedQuestion.Completed,
			updatedQuestion.Information,
			updatedQuestion.ID,
		) // Assuming that 'ID' is a field in your Question struct

		if err != nil {
			fmt.Println("Error while updating:", err)
			return err
		}

		rowsAffected, err := result.RowsAffected()
		if err != nil {
			fmt.Println("Error while checking affected rows:", err)
			return err
		}

		if rowsAffected == 0 {
			fmt.Println("No rows updated. It's possible that the question with the provided ID does not exist.")
		} else {
			fmt.Printf("Successfully updated. Rows affected: %d\n", rowsAffected)
		}
	}

	return nil
}
