package models

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestUser_SetPassword(t *testing.T) {
	user := User{
		Username: "testuser",
		Email:    "test@example.com",
	}
	
	err := user.SetPassword("mypassword123")
	assert.NoError(t, err)
	assert.NotEqual(t, "mypassword123", user.Password)
	assert.Len(t, user.Password, 60) // bcrypt 哈希长度
}

func TestUser_CheckPassword_Success(t *testing.T) {
	user := User{
		Username: "testuser",
		Email:    "test@example.com",
	}
	
	password := "mypassword123"
	err := user.SetPassword(password)
	assert.NoError(t, err)
	
	assert.True(t, user.CheckPassword(password))
}

func TestUser_CheckPassword_Failure(t *testing.T) {
	user := User{
		Username: "testuser",
		Email:    "test@example.com",
	}
	
	err := user.SetPassword("mypassword123")
	assert.NoError(t, err)
	
	assert.False(t, user.CheckPassword("wrongpassword"))
}

func TestUser_TableName(t *testing.T) {
	user := User{}
	assert.Equal(t, "users", user.TableName())
}
