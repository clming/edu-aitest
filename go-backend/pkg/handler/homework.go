package handler

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/clming/edu-aitest/go-backend/internal/database"
	"github.com/clming/edu-aitest/go-backend/pkg/models"
)

// CreateHomeworkRequest 创建作业请求
type CreateHomeworkRequest struct {
	Title       string `json:"title" binding:"required,min=1,max=200"`
	Description string `json:"description"`
	Subject     string `json:"subject" binding:"required"`
	Deadline    string `json:"deadline" binding:"required"`
	StudentID   uint   `json:"student_id" binding:"required"`
}

// UpdateHomeworkRequest 更新作业请求
type UpdateHomeworkRequest struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	Subject     string `json:"subject"`
	Deadline    string `json:"deadline"`
	IsCompleted *bool  `json:"is_completed"`
}

// GetHomeworkList 获取作业列表
// @Summary 获取作业列表
// @Description 获取作业列表
// @Tags homework
// @Produce json
// @Success 200 {array} models.Homework
// @Router /api/v1/homework [get]
func GetHomeworkList(c *gin.Context) {
	var homeworkList []models.Homework

	query := database.DB.Preload("Teacher").Preload("Student")

	// 筛选条件
	if subject := c.Query("subject"); subject != "" {
		query = query.Where("subject = ?", subject)
	}
	if isCompleted := c.Query("is_completed"); isCompleted != "" {
		query = query.Where("is_completed = ?", isCompleted == "true")
	}

	if err := query.Order("deadline ASC").Find(&homeworkList).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取作业列表失败",
		})
		return
	}

	c.JSON(http.StatusOK, homeworkList)
}

// GetHomeworkDetail 获取作业详情
// @Summary 获取作业详情
// @Description 获取单个作业详情
// @Tags homework
// @Produce json
// @Param id path int true "作业 ID"
// @Success 200 {object} models.Homework
// @Router /api/v1/homework/:id [get]
func GetHomeworkDetail(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的作业 ID",
		})
		return
	}

	var homework models.Homework
	if err := database.DB.Preload("Teacher").Preload("Student").First(&homework, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "作业不存在",
		})
		return
	}

	c.JSON(http.StatusOK, homework)
}

// CreateHomework 创建作业
// @Summary 创建作业
// @Description 创建新作业
// @Tags homework
// @Accept json
// @Produce json
// @Param request body CreateHomeworkRequest true "作业信息"
// @Success 200 {object} models.Homework
// @Router /api/v1/homework [post]
func CreateHomework(c *gin.Context) {
	var req CreateHomeworkRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	// 解析截止时间
	deadline, err := parseTime(req.Deadline)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的截止时间格式",
		})
		return
	}

	// 获取当前用户 ID（从 JWT token 中）
	userID := getUserIDFromToken(c)
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未授权",
		})
		return
	}

	homework := models.Homework{
		Title:       req.Title,
		Description: req.Description,
		Subject:     req.Subject,
		Deadline:    deadline,
		IsCompleted: false,
		TeacherID:   userID,
		StudentID:   req.StudentID,
		CreatedBy:   userID,
	}

	if err := database.DB.Create(&homework).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建作业失败",
		})
		return
	}

	// 加载关联数据
	database.DB.Preload("Teacher").Preload("Student").First(&homework, homework.ID)

	c.JSON(http.StatusCreated, homework)
}

// UpdateHomework 更新作业
// @Summary 更新作业
// @Description 更新作业信息
// @Tags homework
// @Accept json
// @Produce json
// @Param id path int true "作业 ID"
// @Param request body UpdateHomeworkRequest true "作业信息"
// @Success 200 {object} models.Homework
// @Router /api/v1/homework/:id [put]
func UpdateHomework(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的作业 ID",
		})
		return
	}

	var req UpdateHomeworkRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	var homework models.Homework
	if err := database.DB.First(&homework, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "作业不存在",
		})
		return
	}

	// 更新字段
	if req.Title != "" {
		homework.Title = req.Title
	}
	if req.Description != "" {
		homework.Description = req.Description
	}
	if req.Subject != "" {
		homework.Subject = req.Subject
	}
	if req.Deadline != "" {
		deadline, err := parseTime(req.Deadline)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "无效的截止时间格式",
			})
			return
		}
		homework.Deadline = deadline
	}
	if req.IsCompleted != nil {
		homework.IsCompleted = *req.IsCompleted
	}

	if err := database.DB.Save(&homework).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "更新作业失败",
		})
		return
	}

	database.DB.Preload("Teacher").Preload("Student").First(&homework, homework.ID)

	c.JSON(http.StatusOK, homework)
}

// DeleteHomework 删除作业
// @Summary 删除作业
// @Description 删除作业
// @Tags homework
// @Produce json
// @Param id path int true "作业 ID"
// @Success 200 {object} map[string]interface{}
// @Router /api/v1/homework/:id [delete]
func DeleteHomework(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的作业 ID",
		})
		return
	}

	if err := database.DB.Delete(&models.Homework{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "删除作业失败",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "作业已删除",
	})
}
