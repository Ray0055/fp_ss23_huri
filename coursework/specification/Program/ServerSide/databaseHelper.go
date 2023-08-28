package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/go-sql-driver/mysql"
)

type Question struct {
	ID           int    `json:"id"`
	Question     string `json:"question"`
	Options      string `json:"options"`
	CorrectIndex int    `json:"correctIndex"`
	CreatedTime  string `json:"createdTime"`
	ModifiedTime string `json:"modifiedTime"`
	Completed    int    `json:"completed"`
}

var db *sql.DB

func initDatabase() {
	var err error
	db, err = sql.Open("mysql", "root:747025@tcp(127.0.0.1:3306)/questions_db")
	if err != nil {
		log.Fatal("Failed to connect to the database:", err)
	}
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
		if err := rows.Scan(&q.ID, &q.Question, &q.Options, &q.CorrectIndex, &q.CreatedTime, &q.ModifiedTime, &q.Completed); err != nil {
			return nil, err
		}
		questions = append(questions, q)
	}

	return questions, nil
}

func addQuestion(db *sql.DB, newQuestion Question) error {
	fmt.Println("Attempting to insert question:", newQuestion)
	result, err := db.Exec("INSERT INTO questions (question, options, correctIndex, createdTime, modifiedTime, completed) VALUES (?, ?, ?, ?, ?, ?)",
		newQuestion.Question, newQuestion.Options, newQuestion.CorrectIndex, newQuestion.CreatedTime, newQuestion.ModifiedTime, newQuestion.Completed)
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

func deleteQuestion(db *sql.DB, id int) {
	var err error
	_, err = db.Exec("DELETE FROM questions WHERE id=?", id)
	if err != nil {
		fmt.Println("Error deleting question:", err)
		return
	}
}

func updateQuestion(db *sql.DB, updatedQuestion Question) error {
	fmt.Println("Attempting to update question:", updatedQuestion)

	// SQL UPDATE statement
	query := `
	UPDATE questions SET
		question = ?,
		options = ?,
		correctIndex = ?,
		createdTime = ?,
		modifiedTime = ?,
		completed = ?
	WHERE
		ID = ?`

	result, err := db.Exec(query,
		updatedQuestion.Question,
		updatedQuestion.Options,
		updatedQuestion.CorrectIndex,
		updatedQuestion.CreatedTime,
		updatedQuestion.ModifiedTime,
		updatedQuestion.Completed,
		updatedQuestion.ID) // Assuming that 'ID' is a field in your Question struct

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

	return nil
}
