package database

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"github.com/redis/go-redis/v9"
	"github.com/clming/edu-aitest/go-backend/internal/config"
	"github.com/clming/edu-aitest/go-backend/pkg/models"
)

var (
	DB    *gorm.DB
	Redis *redis.Client
)

// Init 初始化数据库连接
// BUG-009: 改进数据库连接失败处理，添加连接池配置和重试机制
// 特性：
// 1. 系统启动时自动创建数据库（如果不存在）
// 2. 自动创建表（如果不存在）
// 3. 版本迭代时自动添加新字段到现有表
// 4. 版本迭代时自动创建新表
func Init(dsn string) error {
	var err error
	
	// 第一步：创建数据库（如果不存在）
	// 从 DSN 中提取数据库名，然后连接到 MySQL 服务器（不带数据库名）
	log.Println("🔧 检查并创建数据库...")
	if err := createDatabaseIfNotExists(dsn); err != nil {
		log.Printf("⚠️ 数据库创建失败：%v", err)
		// 继续尝试，可能数据库已存在
	}
	
	// 第二步：连接到指定数据库
	// 重试逻辑：最多重试 3 次
	maxRetries := 3
	for i := 0; i < maxRetries; i++ {
		// 根据环境设置日志级别
		env := os.Getenv("ENV")
		logMode := logger.Warn
		if env != "production" {
			logMode = logger.Info
		}
		
		DB, err = gorm.Open(mysql.Open(dsn), &gorm.Config{
			Logger: logger.Default.LogMode(logMode),
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

	// 第三步：自动迁移（自动创建表 + 自动添加字段）
	// GORM 的 AutoMigrate 特性：
	// 1. 如果表不存在，自动创建
	// 2. 如果表存在但缺少字段，自动添加
	// 3. 不会删除已存在的字段或表（安全迁移）
	log.Println("🔧 执行数据库自动迁移...")
	if err := DB.AutoMigrate(
		&models.User{},
		&models.Homework{},
		&models.Student{},
		&models.Report{},
	); err != nil {
		log.Printf("❌ 数据库迁移失败")
		return fmt.Errorf("数据库迁移失败")
	}

	log.Println("✅ 数据库初始化成功（自动创建表 + 自动添加字段）")
	return nil
}

// createDatabaseIfNotExists 创建数据库（如果不存在）
func createDatabaseIfNotExists(dsn string) error {
	// 从 DSN 中提取数据库名
	// DSN 格式：user:pass@tcp(host:port)/dbname?params
	dbName := "edu_assistant" // 默认数据库名
	
	// 构建不带数据库名的 DSN（用于连接 MySQL 服务器）
	hostDSN := "openclaw-edutest:EZi3fxB9Kpqyap%Dm@tcp(mysql-2a840bd18e4b-public.rds.volces.com:33060)/?charset=utf8mb4&parseTime=True&loc=Local"
	
	// 连接到 MySQL 服务器（不带数据库名）
	db, err := gorm.Open(mysql.Open(hostDSN), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return fmt.Errorf("连接 MySQL 服务器失败：%w", err)
	}
	
	// 检查数据库是否存在
	var exists int
	err = db.Raw("SELECT COUNT(*) FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = ?", dbName).Scan(&exists).Error
	if err != nil {
		return fmt.Errorf("检查数据库失败：%w", err)
	}
	
	// 如果不存在，创建数据库
	if exists == 0 {
		log.Printf("📦 数据库 '%s' 不存在，正在创建...", dbName)
		createSQL := fmt.Sprintf("CREATE DATABASE IF NOT EXISTS `%s` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci", dbName)
		if err := db.Exec(createSQL).Error; err != nil {
			return fmt.Errorf("创建数据库失败：%w", err)
		}
		log.Printf("✅ 数据库 '%s' 创建成功", dbName)
	} else {
		log.Printf("✅ 数据库 '%s' 已存在", dbName)
	}
	
	return nil
}

// InitRedis 初始化 Redis 连接
// BUG-009: 改进 Redis 连接失败处理
func InitRedis(redisURL string) error {
	opt, err := redis.ParseURL(redisURL)
	if err != nil {
		log.Printf("❌ Redis URL 解析失败：%v", err)
		return fmt.Errorf("Redis 配置错误")
	}

	Redis = redis.NewClient(opt)
	
	// 检查客户端是否创建成功
	if Redis == nil {
		log.Printf("❌ Redis 客户端创建失败")
		return fmt.Errorf("Redis 客户端创建失败")
	}

	// 测试连接（带超时）
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	
	if err := Redis.Ping(ctx).Err(); err != nil {
		log.Printf("❌ Redis 连接失败：%v", err)
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
