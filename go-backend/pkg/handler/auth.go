package handler

import (
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/clming/edu-aitest/go-backend/internal/config"
	"github.com/clming/edu-aitest/go-backend/internal/database"
	"github.com/clming/edu-aitest/go-backend/pkg/models"
)

// LoginRequest 登录请求
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// RegisterRequest 注册请求
type RegisterRequest struct {
	Username string `json:"username" binding:"required,min=3,max=50"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
	Role     string `json:"role" binding:"required,oneof=teacher student parent"`
}

// Login 用户登录
// @Summary 用户登录
// @Description 用户登录获取 token
// @Tags auth
// @Accept json
// @Produce json
// @Param request body LoginRequest true "登录信息"
// @Success 200 {object} map[string]interface{}
// @Router /api/v1/auth/login [post]
// BUG-003: 添加登录失败锁定机制
func Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
		})
		return
	}

	// BUG-003: 检查是否被锁定
	ctx := c.Request.Context()
	lockKey := database.LoginAttemptKey(req.Username)
	
	// 检查是否已被锁定
	isLocked, _ := database.CacheExists(ctx, lockKey)
	if isLocked {
		c.JSON(http.StatusTooManyRequests, gin.H{
			"error": "账户已被锁定，请 15 分钟后再试",
		})
		return
	}

	// 查找用户
	var user models.User
	if err := database.DB.Where("username = ? OR email = ?", req.Username, req.Username).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "用户名或密码错误",
		})
		return
	}

	// 验证密码
	if !user.CheckPassword(req.Password) {
		// BUG-003: 记录失败次数
		failCount, _ := database.CacheIncrement(ctx, lockKey, 15*time.Minute)
		if failCount >= 5 {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"error": "尝试次数过多，账户已被锁定 15 分钟",
			})
			return
		}
		
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "用户名或密码错误",
		})
		return
	}

	// 登录成功，清除失败计数
	database.CacheDelete(ctx, lockKey)

	// 生成 JWT token
	token, err := generateToken(user.ID, user.Username, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "生成 token 失败",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": token,
		"user": gin.H{
			"id":         user.ID,
			"username":   user.Username,
			"email":      user.Email,
			"role":       user.Role,
			"avatar":     user.Avatar,
			"created_at": user.CreatedAt,
		},
	})
}

// Register 用户注册
// @Summary 用户注册
// @Description 创建新用户
// @Tags auth
// @Accept json
// @Produce json
// @Param request body RegisterRequest true "注册信息"
// @Success 200 {object} map[string]interface{}
// @Router /api/v1/auth/register [post]
func Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	// 检查用户名是否已存在
	var existingUser models.User
	if err := database.DB.Where("username = ? OR email = ?", req.Username, req.Email).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{
			"error": "用户名或邮箱已被注册",
		})
		return
	}

	// 创建用户
	user := models.User{
		Username: req.Username,
		Email:    req.Email,
		Password: req.Password, // BeforeCreate 钩子会自动加密
		Role:     req.Role,
	}

	if err := database.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建用户失败",
		})
		return
	}

	// 生成 JWT token
	token, err := generateToken(user.ID, user.Username, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "生成 token 失败",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": token,
		"user": gin.H{
			"id":         user.ID,
			"username":   user.Username,
			"email":      user.Email,
			"role":       user.Role,
			"avatar":     user.Avatar,
			"created_at": user.CreatedAt,
		},
	})
}

// Logout 用户登出
// @Summary 用户登出
// @Description 用户登出
// @Tags auth
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Router /api/v1/auth/logout [post]
func Logout(c *gin.Context) {
	// 在实际应用中，这里可以将 token 加入黑名单
	c.JSON(http.StatusOK, gin.H{
		"message": "登出成功",
	})
}

// generateToken 生成 JWT token
// BUG-001: 使用配置中的 JWT_SECRET，不允许默认值
// BUG-004: 添加 iss (签发者) 声明
// BUG-014: 使用常量定义有效期
func generateToken(userID uint, username, role string) (string, error) {
	claims := jwt.MapClaims{
		"user_id":  userID,
		"username": username,
		"role":     role,
		"exp":      time.Now().Add(time.Hour * config.TokenExpireHours).Unix(),
		"iss":      config.JWTIssuer,  // BUG-004: 添加签发者
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(os.Getenv("JWT_SECRET")))
}
