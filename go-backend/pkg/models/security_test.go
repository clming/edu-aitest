package models_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/clming/edu-aitest/go-backend/internal/config"
	"github.com/clming/edu-aitest/go-backend/pkg/models"
)

// TestBcryptCost 测试密码加密成本 (BUG-002)
func TestBcryptCost(t *testing.T) {
	// 验证 BcryptCost 常量是否已更新
	assert.GreaterOrEqual(t, config.BcryptCost, 12, "Bcrypt 成本因子应至少为 12")
	assert.LessOrEqual(t, config.BcryptCost, 14, "Bcrypt 成本因子不应超过 14")
}

// TestUserSetPassword 测试用户密码设置
func TestUserSetPassword(t *testing.T) {
	user := models.User{
		Username: "testuser",
		Email:    "test@example.com",
		Role:     "student",
	}

	err := user.SetPassword("testpassword123")
	assert.NoError(t, err, "设置密码不应出错")
	assert.NotEqual(t, "testpassword123", user.Password, "密码应被加密")
	assert.GreaterOrEqual(t, len(user.Password), 60, "加密后的密码长度应至少为 60")
}

// TestUserCheckPassword 测试密码验证
func TestUserCheckPassword(t *testing.T) {
	user := models.User{
		Username: "testuser",
		Email:    "test@example.com",
		Role:     "student",
	}

	password := "testpassword123"
	err := user.SetPassword(password)
	assert.NoError(t, err)

	// 验证正确密码
	assert.True(t, user.CheckPassword(password), "正确密码应验证通过")
	
	// 验证错误密码
	assert.False(t, user.CheckPassword("wrongpassword"), "错误密码应验证失败")
}

// TestJWTConfig 测试 JWT 配置 (BUG-001, BUG-014)
func TestJWTConfig(t *testing.T) {
	// 验证 JWT 配置常量
	assert.NotEmpty(t, config.JWTIssuer, "JWT 签发者不应为空")
	assert.Greater(t, config.TokenExpireHours, 0, "Token 有效期应大于 0")
}
