package database

import (
	"fmt"
	"log"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"github.com/redis/go-redis/v9"
	"github.com/clming/edu-aitest/go-backend/pkg/models"
)

var (
	DB    *gorm.DB
	Redis *redis.Client
)

// Init 初始化数据库连接
// BUG-009: 改进数据库连接失败处理，添加连接池配置和重试机制
func Init(dsn string) error {
	var err error
	
	// 重试逻辑：最多重试 3 次
	maxRetries := 3
	for i := 0; i < maxRetries; i++ {
		DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.Default.LogMode(logger.Warn), // 减少日志噪音
		})
		if err == nil {
			break
		}
		
		if i < maxRetries-1 {
			log.Printf("⚠️ 数据库连接失败，%d秒后重试 (%d/%d)...", 2*(i+1), i+1, maxRetries)
			time.Sleep(time.Duration(2*(i+1)) * time.Second)
		}
	}
	
	if err != nil {
		// BUG-008: 不暴露详细技术细节
		log.Printf("❌ 数据库连接失败")
		return fmt.Errorf("数据库初始化失败")
	}

	// 获取底层 SQL DB 以配置连接池
	sqlDB, err := DB.DB()
	if err != nil {
		return fmt.Errorf("获取数据库实例失败")
	}

	// 配置连接池
	sqlDB.SetMaxIdleConns(10)        // 最大空闲连接数
	sqlDB.SetMaxOpenConns(100)       // 最大打开连接数
	sqlDB.SetConnMaxLifetime(time.Hour) // 连接最大生命周期

	// 自动迁移
	if err := DB.AutoMigrate(
		&models.User{},
		&models.Homework{},
		&models.Student{},
		&models.Report{},
	); err != nil {
		log.Printf("❌ 数据库迁移失败")
		return fmt.Errorf("数据库迁移失败")
	}

	log.Println("✅ 数据库初始化成功")
	return nil
}

// InitRedis 初始化 Redis 连接
// BUG-009: 改进 Redis 连接失败处理
func InitRedis(redisURL string) error {
	opt, err := redis.ParseURL(redisURL)
	if err != nil {
		log.Printf("❌ Redis URL 解析失败")
		return fmt.Errorf("Redis 配置错误")
	}

	Redis = redis.NewClient(opt)

	// 测试连接
	if err := Redis.Ping(nil).Err(); err != nil {
		log.Printf("❌ Redis 连接失败")
		return fmt.Errorf("Redis 连接失败")
	}

	log.Println("✅ Redis 初始化成功")
	return nil
}

// Close 关闭数据库连接
func Close() error {
	sqlDB, err := DB.DB()
	if err != nil {
		return err
	}
	
	if err := sqlDB.Close(); err != nil {
		return err
	}

	if Redis != nil {
		if err := Redis.Close(); err != nil {
			return err
		}
	}

	log.Println("✅ 数据库连接已关闭")
	return nil
}
