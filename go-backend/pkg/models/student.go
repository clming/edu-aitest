package models

import (
	"time"

	"gorm.io/gorm"
)

type Student struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	UserID    uint           `gorm:"uniqueIndex;not null" json:"user_id"`
	Grade     string         `gorm:"size:50" json:"grade"`
	Class     string         `gorm:"size:50" json:"class"`
	StudentNo string         `gorm:"size:50;uniqueIndex" json:"student_no"`
	ParentID  *uint          `json:"parent_id"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	// 关联
	User   *User `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Parent *User `gorm:"foreignKey:ParentID" json:"parent,omitempty"`
}

// TableName 指定表名
func (Student) TableName() string {
	return "students"
}
