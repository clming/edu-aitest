package models

import (
	"time"

	"gorm.io/gorm"
)

type Homework struct {
	ID          uint           `gorm:"primaryKey" json:"id"`
	Title       string         `gorm:"size:200;not null" json:"title"`
	Description string         `gorm:"type:text" json:"description"`
	Subject     string         `gorm:"size:50;not null" json:"subject"`
	Deadline    time.Time      `gorm:"not null" json:"deadline"`
	IsCompleted bool           `gorm:"default:false" json:"is_completed"`
	TeacherID   uint           `gorm:"not null" json:"teacher_id"`
	StudentID   uint           `gorm:"not null" json:"student_id"`
	CreatedBy   uint           `gorm:"not null" json:"created_by"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`

	// 关联
	Teacher  *User  `gorm:"foreignKey:TeacherID" json:"teacher,omitempty"`
	Student  *User  `gorm:"foreignKey:StudentID" json:"student,omitempty"`
	Creator  *User  `gorm:"foreignKey:CreatedBy" json:"creator,omitempty"`
}

// TableName 指定表名
func (Homework) TableName() string {
	return "homework"
}
