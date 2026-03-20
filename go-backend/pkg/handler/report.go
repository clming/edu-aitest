package handler

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/clming/edu-aitest/go-backend/internal/database"
	"github.com/clming/edu-aitest/go-backend/pkg/models"
)

// ReportData 报告数据结构
type ReportData struct {
	TotalHomework     int            `json:"total_homework"`
	CompletedHomework int            `json:"completed_homework"`
	PendingHomework   int            `json:"pending_homework"`
	CompletionRate    float64        `json:"completion_rate"`
	SubjectStats      []SubjectStat  `json:"subject_stats"`
	WeeklyTrend       []DailyStat    `json:"weekly_trend"`
}

type SubjectStat struct {
	Subject     string `json:"subject"`
	Total       int    `json:"total"`
	Completed   int    `json:"completed"`
}

type DailyStat struct {
	Date      string `json:"date"`
	Completed int    `json:"completed"`
}

// GetWeeklyReport 获取周报
// @Summary 获取周报
// @Description 获取学生周报
// @Tags reports
// @Produce json
// @Param student_id query int true "学生 ID"
// @Success 200 {object} map[string]interface{}
// @Router /api/v1/reports/weekly [get]
// BUG-007: 添加权限验证，只有家长、老师本人可以查看
func GetWeeklyReport(c *gin.Context) {
	studentIDStr := c.Query("student_id")
	if studentIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "缺少学生 ID 参数",
		})
		return
	}

	studentID, err := strconv.ParseUint(studentIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的学生 ID",
		})
		return
	}

	// 权限验证
	userID := getUserIDFromToken(c)
	userRole := getUserRoleFromToken(c)
	
	if !canAccessStudentReport(userRole, userID, uint(studentID)) {
		c.JSON(http.StatusForbidden, gin.H{
			"error": "无权查看此学生的报告",
		})
		return
	}

	// 计算一周的时间范围
	now := time.Now()
	startOfWeek := now.AddDate(0, 0, -7)

	// 统计作业数据
	var totalHomework, completedHomework int64
	database.DB.Model(&models.Homework{}).
		Where("student_id = ? AND created_at >= ?", studentID, startOfWeek).
		Count(&totalHomework)
	
	database.DB.Model(&models.Homework{}).
		Where("student_id = ? AND is_completed = true AND created_at >= ?", studentID, startOfWeek).
		Count(&completedHomework)

	pendingHomework := totalHomework - completedHomework
	
	completionRate := 0.0
	if totalHomework > 0 {
		completionRate = float64(completedHomework) / float64(totalHomework) * 100
	}

	// 按科目统计
	type SubjectCount struct {
		Subject   string
		Total     int64
		Completed int64
	}
	var subjectStats []SubjectCount
	database.DB.Model(&models.Homework{}).
		Select("subject, COUNT(*) as total, SUM(CASE WHEN is_completed = true THEN 1 ELSE 0 END) as completed").
		Where("student_id = ? AND created_at >= ?", studentID, startOfWeek).
		Group("subject").
		Scan(&subjectStats)

	subjectStatList := make([]SubjectStat, len(subjectStats))
	for i, stat := range subjectStats {
		subjectStatList[i] = SubjectStat{
			Subject:   stat.Subject,
			Total:     int(stat.Total),
			Completed: int(stat.Completed),
		}
	}

	// 每日趋势
	var dailyStats []DailyStat
	for i := 6; i >= 0; i-- {
		date := now.AddDate(0, 0, -i)
		dateStr := date.Format("2006-01-02")
		
		var completed int64
		database.DB.Model(&models.Homework{}).
			Where("student_id = ? AND is_completed = true AND DATE(updated_at) = ?", studentID, dateStr).
			Count(&completed)
		
		dailyStats = append(dailyStats, DailyStat{
			Date:      dateStr,
			Completed: int(completed),
		})
	}

	reportData := ReportData{
		TotalHomework:     int(totalHomework),
		CompletedHomework: int(completedHomework),
		PendingHomework:   int(pendingHomework),
		CompletionRate:    completionRate,
		SubjectStats:      subjectStatList,
		WeeklyTrend:       dailyStats,
	}

	c.JSON(http.StatusOK, gin.H{
		"type":       "weekly",
		"start_date": startOfWeek.Format("2006-01-02"),
		"end_date":   now.Format("2006-01-02"),
		"data":       reportData,
	})
}

// GetMonthlyReport 获取月报
// @Summary 获取月报
// @Description 获取学生月报
// @Tags reports
// @Produce json
// @Param student_id query int true "学生 ID"
// @Success 200 {object} map[string]interface{}
// @Router /api/v1/reports/monthly [get]
// BUG-007: 添加权限验证
func GetMonthlyReport(c *gin.Context) {
	studentIDStr := c.Query("student_id")
	if studentIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "缺少学生 ID 参数",
		})
		return
	}

	studentID, err := strconv.ParseUint(studentIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的学生 ID",
		})
		return
	}

	// 权限验证
	userID := getUserIDFromToken(c)
	userRole := getUserRoleFromToken(c)
	
	if !canAccessStudentReport(userRole, userID, uint(studentID)) {
		c.JSON(http.StatusForbidden, gin.H{
			"error": "无权查看此学生的报告",
		})
		return
	}

	// 计算一月的时间范围
	now := time.Now()
	startOfMonth := now.AddDate(0, -1, 0)

	// 统计作业数据
	var totalHomework, completedHomework int64
	database.DB.Model(&models.Homework{}).
		Where("student_id = ? AND created_at >= ?", studentID, startOfMonth).
		Count(&totalHomework)
	
	database.DB.Model(&models.Homework{}).
		Where("student_id = ? AND is_completed = true AND created_at >= ?", studentID, startOfMonth).
		Count(&completedHomework)

	pendingHomework := totalHomework - completedHomework
	
	completionRate := 0.0
	if totalHomework > 0 {
		completionRate = float64(completedHomework) / float64(totalHomework) * 100
	}

	// 按科目统计
	type SubjectCount struct {
		Subject   string
		Total     int64
		Completed int64
	}
	var subjectStats []SubjectCount
	database.DB.Model(&models.Homework{}).
		Select("subject, COUNT(*) as total, SUM(CASE WHEN is_completed = true THEN 1 ELSE 0 END) as completed").
		Where("student_id = ? AND created_at >= ?", studentID, startOfMonth).
		Group("subject").
		Scan(&subjectStats)

	subjectStatList := make([]SubjectStat, len(subjectStats))
	for i, stat := range subjectStats {
		subjectStatList[i] = SubjectStat{
			Subject:   stat.Subject,
			Total:     int(stat.Total),
			Completed: int(stat.Completed),
		}
	}

	// 每周趋势
	var weeklyStats []DailyStat
	for i := 3; i >= 0; i-- {
		weekStart := now.AddDate(0, 0, -i*7)
		weekEnd := weekStart.AddDate(0, 0, 7)
		
		var completed int64
		database.DB.Model(&models.Homework{}).
			Where("student_id = ? AND is_completed = true AND updated_at BETWEEN ? AND ?", studentID, weekStart, weekEnd).
			Count(&completed)
		
		weeklyStats = append(weeklyStats, DailyStat{
			Date:      weekStart.Format("2006-01-02"),
			Completed: int(completed),
		})
	}

	reportData := ReportData{
		TotalHomework:     int(totalHomework),
		CompletedHomework: int(completedHomework),
		PendingHomework:   int(pendingHomework),
		CompletionRate:    completionRate,
		SubjectStats:      subjectStatList,
		WeeklyTrend:       weeklyStats,
	}

	c.JSON(http.StatusOK, gin.H{
		"type":       "monthly",
		"start_date": startOfMonth.Format("2006-01-02"),
		"end_date":   now.Format("2006-01-02"),
		"data":       reportData,
	})
}

// canAccessStudentReport 检查用户是否有权查看学生报告
// BUG-007: 权限验证辅助函数
func canAccessStudentReport(userRole string, userID, studentID uint) bool {
	// 管理员和老师可以查看所有学生报告
	if userRole == "admin" || userRole == "teacher" {
		return true
	}
	
	// 家长只能查看自己孩子的报告 (需要检查 parent_id)
	if userRole == "parent" {
		var student models.Student
		if err := database.DB.Where("id = ? AND parent_id = ?", studentID, userID).First(&student).Error; err == nil {
			return true
		}
		return false
	}
	
	// 学生只能查看自己的报告
	if userRole == "student" {
		var student models.Student
		if err := database.DB.Where("id = ? AND user_id = ?", studentID, userID).First(&student).Error; err == nil {
			return true
		}
		return false
	}
	
	return false
}
