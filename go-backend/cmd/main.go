package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	"github.com/clming/edu-aitest/go-backend/internal/config"
	"github.com/clming/edu-aitest/go-backend/internal/database"
	"github.com/clming/edu-aitest/go-backend/pkg/handler"
	"github.com/clming/edu-aitest/go-backend/pkg/middleware"
)

// @title 教育助手 API
// @version 1.0
// @description 教育类应用后端服务 API 文档
// @host localhost:8080
// @BasePath /api/v1
func main() {
	// 加载配置
	cfg := config.Load()

	// 初始化数据库
	if err := database.Init(cfg.DatabaseURL); err != nil {
		log.Fatalf("数据库初始化失败：%v", err)
	}

	// 初始化 Redis
	if err := database.InitRedis(cfg.RedisURL); err != nil {
		log.Fatalf("Redis 初始化失败：%v", err)
	}

	// 创建 Gin 路由
	r := gin.Default()

	// 中间件
	r.Use(middleware.CORS())
	r.Use(middleware.Logger())
	r.Use(middleware.Recovery())

	// 健康检查
	r.GET("/health", handler.HealthCheck)

	// API v1 路由
	v1 := r.Group("/api/v1")
	{
		// 认证相关
		auth := v1.Group("/auth")
		{
			auth.POST("/login", handler.Login)
			auth.POST("/register", handler.Register)
			auth.POST("/logout", middleware.JWTAuth(), handler.Logout)
		}

		// 作业相关
		homework := v1.Group("/homework")
		{
			homework.GET("", middleware.JWTAuth(), handler.GetHomeworkList)
			homework.GET("/:id", middleware.JWTAuth(), handler.GetHomeworkDetail)
			homework.POST("", middleware.JWTAuth(), handler.CreateHomework)
			homework.PUT("/:id", middleware.JWTAuth(), handler.UpdateHomework)
			homework.DELETE("/:id", middleware.JWTAuth(), handler.DeleteHomework)
		}

		// 学生相关
		student := v1.Group("/students")
		{
			student.GET("", middleware.JWTAuth(), handler.GetStudentList)
			student.GET("/:id", middleware.JWTAuth(), handler.GetStudentDetail)
		}

		// 学习报告
		report := v1.Group("/reports")
		{
			report.GET("/weekly", middleware.JWTAuth(), handler.GetWeeklyReport)
			report.GET("/monthly", middleware.JWTAuth(), handler.GetMonthlyReport)
		}
	}

	// Swagger 文档
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// 启动服务
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 服务启动在端口 %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("服务启动失败：%v", err)
	}
}
