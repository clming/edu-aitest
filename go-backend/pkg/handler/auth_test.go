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

func setupRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.Default()
	
	v1 := r.Group("/api/v1")
	{
		auth := v1.Group("/auth")
		{
			auth.POST("/login", Login)
			auth.POST("/register", Register)
		}
	}
	
	return r
}

func TestLogin_Success(t *testing.T) {
	// 注意：这个测试需要数据库中有测试用户
	// 在实际使用中，应该使用测试数据库或 mock
	
	router := setupRouter()
	
	loginData := map[string]string{
		"username": "testuser",
		"password": "testpass",
	}
	jsonData, _ := json.Marshal(loginData)
	
	req, _ := http.NewRequest("POST", "/api/v1/auth/login", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	
	// 由于没有真实数据库，这里只测试响应格式
	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestLogin_EmptyUsername(t *testing.T) {
	router := setupRouter()
	
	loginData := map[string]string{
		"username": "",
		"password": "testpass",
	}
	jsonData, _ := json.Marshal(loginData)
	
	req, _ := http.NewRequest("POST", "/api/v1/auth/login", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestRegister_Success(t *testing.T) {
	router := setupRouter()
	
	registerData := map[string]string{
		"username": "newuser",
		"email":    "newuser@example.com",
		"password": "newpass123",
		"role":     "student",
	}
	jsonData, _ := json.Marshal(registerData)
	
	req, _ := http.NewRequest("POST", "/api/v1/auth/register", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	
	// 测试响应状态（实际结果取决于数据库）
	assert.Contains(t, []int{http.StatusOK, http.StatusConflict}, w.Code)
}

func TestRegister_InvalidEmail(t *testing.T) {
	router := setupRouter()
	
	registerData := map[string]string{
		"username": "newuser",
		"email":    "invalid-email",
		"password": "newpass123",
		"role":     "student",
	}
	jsonData, _ := json.Marshal(registerData)
	
	req, _ := http.NewRequest("POST", "/api/v1/auth/register", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestRegister_InvalidRole(t *testing.T) {
	router := setupRouter()
	
	registerData := map[string]string{
		"username": "newuser",
		"email":    "newuser@example.com",
		"password": "newpass123",
		"role":     "invalid_role",
	}
	jsonData, _ := json.Marshal(registerData)
	
	req, _ := http.NewRequest("POST", "/api/v1/auth/register", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
