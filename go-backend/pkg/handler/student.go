package handler

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/clming/edu-aitest/go-backend/internal/database"
	"github.com/clming/edu-aitest/go-backend/pkg/models"
)

// CreateStudentRequest 创建学生请求
type CreateStudentRequest struct {
	UserID    uint   `json:"user_id" binding:"required"`
	Grade     string `json:"grade"`
	Class     string `json:"class"`
	StudentNo string `json:"student_no" binding:"required"`
	ParentID  *uint  `json:"parent_id"`
}

// GetStudentList 获取学生列表
// @Summary 获取学生列表
// @Description 获取学生列表
// @Tags students
// @Produce json
// @Success 200 {array} models.Student
// @Router /api/v1/students [get]
func GetStudentList(c *gin.Context) {
	var students []models.Student

	query := database.DB.Preload("User").Preload("Parent")

	// 筛选条件
	if grade := c.Query("grade"); grade != "" {
		query = query.Where("grade = ?", grade)
	}
	if class := c.Query("class"); class != "" {
		query = query.Where("class = ?", class)
	}

	if err := query.Find(&students).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取学生列表失败",
		})
		return
	}

	c.JSON(http.StatusOK, students)
}

// GetStudentDetail 获取学生详情
// @Summary 获取学生详情
// @Description 获取单个学生详情
// @Tags students
// @Produce json
// @Param id path int true "学生 ID"
// @Success 200 {object} models.Student
// @Router /api/v1/students/:id [get]
func GetStudentDetail(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的学生 ID",
		})
		return
	}

	var student models.Student
	if err := database.DB.Preload("User").Preload("Parent").First(&student, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "学生不存在",
		})
		return
	}

	c.JSON(http.StatusOK, student)
}

// CreateStudent 创建学生
// @Summary 创建学生
// @Description 创建学生档案
// @Tags students
// @Accept json
// @Produce json
// @Param request body CreateStudentRequest true "学生信息"
// @Success 200 {object} models.Student
// @Router /api/v1/students [post]
func CreateStudent(c *gin.Context) {
	var req CreateStudentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	student := models.Student{
		UserID:    req.UserID,
		Grade:     req.Grade,
		Class:     req.Class,
		StudentNo: req.StudentNo,
		ParentID:  req.ParentID,
	}

	if err := database.DB.Create(&student).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建学生失败",
		})
		return
	}

	database.DB.Preload("User").Preload("Parent").First(&student, student.ID)

	c.JSON(http.StatusCreated, student)
}

// UpdateStudent 更新学生
// @Summary 更新学生
// @Description 更新学生信息
// @Tags students
// @Accept json
// @Produce json
// @Param id path int true "学生 ID"
// @Param request body CreateStudentRequest true "学生信息"
// @Success 200 {object} models.Student
// @Router /api/v1/students/:id [put]
func UpdateStudent(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的学生 ID",
		})
		return
	}

	var req CreateStudentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	var student models.Student
	if err := database.DB.First(&student, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "学生不存在",
		})
		return
	}

	student.Grade = req.Grade
	student.Class = req.Class
	student.StudentNo = req.StudentNo
	student.ParentID = req.ParentID

	if err := database.DB.Save(&student).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "更新学生失败",
		})
		return
	}

	database.DB.Preload("User").Preload("Parent").First(&student, student.ID)

	c.JSON(http.StatusOK, student)
}
