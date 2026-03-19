package models

import (
	"time"

	"gorm.io/gorm"
)

type Report struct {
	ID         uint           `gorm:"primaryKey" json:"id"`
	StudentID  uint           `gorm:"not null;index" json:"student_id"`
	Type       string         `gorm:"size:20;not null" json:"type"` // weekly, monthly
	StartTime  time.Time      `gorm:"not null" json:"start_time"`
	EndTime    time.Time      `gorm:"not null" json:"end_time"`
	Data       string         `gorm:"type:jsonb" json:"data"` // JSON 格式的报告数据
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`

	// 关联
	Student *Student `gorm:"foreignKey:StudentID" json:"student,omitempty"`
}

// TableName 指定表名
func (Report) TableName() string {
	return "reports"
}
