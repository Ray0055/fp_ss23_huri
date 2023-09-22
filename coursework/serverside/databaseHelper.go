package main

import (
	"database/sql"
	"fmt"
	"log"

	"encoding/json"
	"io"
	"os"

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
	Information  string `json:"information"`
}

type UsersStatistics struct {
	ID                      int    `json:"id"`
	Username                string `json:"username"`
	TotalCompletedQuestions int    `json:"totalCompletedQuestions"`
	TotalCorrectQuestions   int    `json:"totalCorrectQuestions"`
	CompletedDate           string `json:"completedDate"`
	TotalCompletedTime      int    `json:"totalCompletedTime"`
}

var db *sql.DB

func initDatabase() {
	var err error
	db, err = sql.Open("mysql", "root:747025@tcp(127.0.0.1:3306)/questions_db")
	if err != nil {
		log.Fatal("Failed to connect to the database:", err)
	}
	_, err = db.Exec(`
	CREATE TABLE IF NOT EXISTS usersStatistics (
		id INTEGER,
		username TEXT NOT NULL,
		totalCompletedQuestions INTEGER NOT NULL DEFAULT 0,
		totalCorrectQuestions INTEGER NOT NULL DEFAULT 0,
		completedDate TEXT NOT NULL,
		totalCompletedTime INTEGER NOT NULL DEFAULT 0
	)
`)

	jsonFile, err := os.Open("questions.json")
	if err != nil {
		log.Fatal("Failed to open JSON file:", err)
	}
	defer jsonFile.Close()

	byteValue, _ := io.ReadAll(jsonFile)
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	}

	var rawQuestions []struct {
		ID           int      `json:"id"`
		Question     string   `json:"question"`
		Options      []string `json:"options"`
		CorrectIndex int      `json:"correctIndex"`
		CreatedTime  string   `json:"createdTime"`
		ModifiedTime string   `json:"modifiedTime"`
		Completed    int      `json:"completed"`
		Information  string   `json:"information"`
	}

	if err := json.Unmarshal(byteValue, &rawQuestions); err != nil {
		log.Fatalf("Error unmarshalling: %v", err)
	}

	var questions []Question
	for _, rawQuestion := range rawQuestions {
		questions = append(questions, Question{
			ID:           rawQuestion.ID,
			Question:     rawQuestion.Question,
			Options:      "[\"true\", \"false\"]",
			CorrectIndex: rawQuestion.CorrectIndex,
			CreatedTime:  rawQuestion.CreatedTime,
			ModifiedTime: rawQuestion.ModifiedTime,
			Completed:    rawQuestion.Completed,
			Information:  rawQuestion.Information,
		})
	}

	// Now, questions slice contains all the questions from the JSON file, with Options as string.
	for _, q := range questions {
		addQuestion(db, q)
		fmt.Printf("ID: %d, Question: %s, Options: %s, Correct Index: %d\n", q.ID, q.Question, q.Options, q.CorrectIndex)
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
		if err := rows.Scan(&q.ID, &q.Question, &q.Options, &q.CorrectIndex, &q.CreatedTime, &q.ModifiedTime, &q.Completed, &q.Information); err != nil {
			return nil, err
		}
		questions = append(questions, q)
	}

	return questions, nil
}

func getStatisticsFromDB() ([]UsersStatistics, error) {
	rows, err := db.Query("SELECT * FROM usersStatistics")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var usersStatistics []UsersStatistics
	for rows.Next() {
		var q UsersStatistics

		if err := rows.Scan(&q.ID, &q.Username, &q.TotalCompletedQuestions, &q.TotalCorrectQuestions, &q.CompletedDate, &q.TotalCompletedTime); err != nil {
			return nil, err
		}

		usersStatistics = append(usersStatistics, q)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return usersStatistics, nil
}

func addQuestion(db *sql.DB, question Question) error {
	fmt.Println("Attempting to upsert question:", question)

	// 将 options 从 []string 转换为 JSON 字符串以存储在数据库中
	//optionsJSON, err := json.Marshal(question.Options)
	// if err != nil {
	// 	fmt.Println("Error while marshalling options:", err)
	// 	return err
	// }

	question.Options = "[\"true\",\"false\"]"

	query := `
		INSERT INTO questions (id, question, options, correctIndex, createdTime, modifiedTime, completed, information) 
		VALUES (?, ?, ?, ?, ?, ?, ?, ?) 
		ON DUPLICATE KEY UPDATE 
		question = VALUES(question), 
		options = VALUES(options), 
		correctIndex = VALUES(correctIndex), 
		createdTime = VALUES(createdTime), 
		modifiedTime = VALUES(modifiedTime), 
		completed = VALUES(completed), 
		information = VALUES(information)
	`

	_, err := db.Exec(query, question.ID, question.Question, question.Options, question.CorrectIndex, question.CreatedTime, question.ModifiedTime, question.Completed, question.Information)
	if err != nil {
		fmt.Println("Error while adding:", err)
		return err
	}

	fmt.Println("Successfully added question.")
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

		// 将 options 从 []string 转换为 JSON 字符串以存储在数据库中
		//optionsJSON, err := json.Marshal(updatedQuestion.Options)

		// if err != nil {
		// 	fmt.Println("Error while marshalling options:", err)
		// 	return err
		// }
		updatedQuestion.Options = "[\"true\",\"false\"]"
		query := `
		INSERT INTO questions (id, question, options, correctIndex, createdTime, modifiedTime, completed, information) 
		VALUES (?, ?, ?, ?, ?, ?, ?, ?) 
		ON DUPLICATE KEY UPDATE 
		question = VALUES(question), 
		options = VALUES(options), 
		correctIndex = VALUES(correctIndex), 
		createdTime = VALUES(createdTime), 
		modifiedTime = VALUES(modifiedTime), 
		completed = VALUES(completed), 
		information = VALUES(information)
	`

		_, err := db.Exec(query, updatedQuestion.ID, updatedQuestion.Question, updatedQuestion.Options, updatedQuestion.CorrectIndex, updatedQuestion.CreatedTime, updatedQuestion.ModifiedTime, updatedQuestion.Completed, updatedQuestion.Information)
		if err != nil {
			fmt.Println("Error while updating:", err)
			return err
		}

		fmt.Println("Successfully updated question.")

		// 	// SQL UPDATE statement
		// 	query := `
		// UPDATE questions SET
		// 	question = ?,
		// 	options = ?,
		// 	correctIndex = ?,
		// 	createdTime = ?,
		// 	modifiedTime = ?,
		// 	completed = ?,
		// 	information = ?
		// WHERE
		// 	ID = ?`

		// 	result, err := db.Exec(query,
		// 		updatedQuestion.Question,
		// 		updatedQuestion.Options,
		// 		updatedQuestion.CorrectIndex,
		// 		updatedQuestion.CreatedTime,
		// 		updatedQuestion.ModifiedTime,
		// 		updatedQuestion.Completed,
		// 		updatedQuestion.Information,
		// 		updatedQuestion.ID,
		// 	) // Assuming that 'ID' is a field in your Question struct

		// 	if err != nil {
		// 		fmt.Println("Error while updating:", err)
		// 		return err
		// 	}

		// 	rowsAffected, err := result.RowsAffected()
		// 	if err != nil {
		// 		fmt.Println("Error while checking affected rows:", err)
		// 		return err
		// 	}

		// 	if rowsAffected == 0 {
		// 		fmt.Println("No rows updated. It's possible that the question with the provided ID does not exist.")
		// 	} else {
		// 		fmt.Printf("Successfully updated. Rows affected: %d\n", rowsAffected)
		// 	}
	}

	return nil
}

func updateUsersStatistics(db *sql.DB, newUsersStatistics UsersStatistics) error {
	fmt.Println("Attempting to insert user statistics:", newUsersStatistics)

	result, err := db.Exec(
		"REPLACE INTO usersStatistics (id, username, totalCompletedQuestions, totalCorrectQuestions, completedDate, totalCompletedTime) VALUES (?, ?, ?, ?, ?, ?)",
		newUsersStatistics.ID,
		newUsersStatistics.Username,
		newUsersStatistics.TotalCompletedQuestions,
		newUsersStatistics.TotalCorrectQuestions,
		newUsersStatistics.CompletedDate,
		newUsersStatistics.TotalCompletedTime,
	)
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
