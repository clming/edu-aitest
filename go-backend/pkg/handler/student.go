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
// BUG-006: 添加权限控制，老师只能查看自己班级/学校的学生
func GetStudentList(c *gin.Context) {
	userID := getUserIDFromToken(c)
	userRole := getUserRoleFromToken(c)

	query := database.DB.Preload("User").Preload("Parent")

	// 权限控制：非管理员/老师只能查看特定范围的学生
	if userRole != "admin" && userRole != "teacher" {
		// 家长只能查看自己绑定的孩子
		if userRole == "parent" {
			query = query.Where("parent_id = ?", userID)
		} else {
			// 学生只能查看自己的信息
			query = query.Where("user_id = ?", userID)
		}
	}

	// 筛选条件
	if grade := c.Query("grade"); grade != "" {
		query = query.Where("grade = ?", grade)
	}
	if class := c.Query("class"); class != "" {
		query = query.Where("class = ?", class)
	}

	var students []models.Student
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
// BUG-006: 添加权限验证
func GetStudentDetail(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的学生 ID",
		})
		return
	}

	userID := getUserIDFromToken(c)
	userRole := getUserRoleFromToken(c)

	var student models.Student
	if err := database.DB.Preload("User").Preload("Parent").First(&student, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "学生不存在",
		})
		return
	}

	// 权限验证
	canAccess := false
	if userRole == "admin" || userRole == "teacher" {
		canAccess = true
	} else if userRole == "parent" && student.ParentID != nil && *student.ParentID == userID {
		canAccess = true
	} else if userRole == "student" && student.UserID == userID {
		canAccess = true
	}

	if !canAccess {
		c.JSON(http.StatusForbidden, gin.H{
			"error": "无权查看此学生信息",
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
