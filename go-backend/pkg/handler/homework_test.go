package handler

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestGetHomeworkList(t *testing.T) {
	router := setupRouter()
	
	req, _ := http.NewRequest("GET", "/api/v1/homework", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	
	// 由于需要 JWT 认证，应该返回 401
	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestCreateHomework_Validation(t *testing.T) {
	router := setupRouter()
	
	// 测试缺少必填字段
	homeworkData := map[string]interface{}{
		"title": "",
		"subject": "数学",
		"deadline": "2026-03-25",
		"student_id": 1,
	}
	jsonData, _ := json.Marshal(homeworkData)
	
	req, _ := http.NewRequest("POST", "/api/v1/homework", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestCreateHomework_ValidData(t *testing.T) {
	router := setupRouter()
	
	homeworkData := map[string]interface{}{
		"title":       "数学作业",
		"description": "完成第 1-5 题",
		"subject":     "数学",
		"deadline":    "2026-03-25T23:59:59",
		"student_id":  1,
	}
	jsonData, _ := json.Marshal(homeworkData)
	
	req, _ := http.NewRequest("POST", "/api/v1/homework", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	
	// 由于需要 JWT 认证，应该返回 401
	assert.Equal(t, http.StatusUnauthorized, w.Code)
}
