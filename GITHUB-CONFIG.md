# 🔧 GitHub 配置文件位置说明

**更新时间**: 2026-03-19  
**更新人**: OpenClaw (二爷的助手)

---

## 📁 配置文件位置

### 1. Git 全局配置
**路径**: `~/.gitconfig`

### 2. GitHub CLI 配置
**路径**: `~/.config/gh/`
- `config.yml` - CLI 主配置
- `hosts.yml` - 认证信息 ⚠️ **敏感**

### 3. Git 凭证文件
**路径**: `~/.git-credentials` ⚠️ **敏感，包含 token**

### 4. 项目级配置
**路径**: `<项目>/.git/config`

---

## 🔑 当前配置

| 配置项 | 值 |
|--------|-----|
| **用户名** | lianming cao |
| **邮箱** | cao_lianming@163.com |

---

## 🛠️ 常用命令

```bash
# 查看配置
git config --list

# 修改邮箱
git config user.email "your@email.com"

# 修改用户名
git config user.name "Your Name"
```

---

## 🔐 安全提示

⚠️ **不要泄露以下文件**:
- `~/.git-credentials` (包含 token)
- `~/.config/gh/hosts.yml` (包含 token)

如 token 泄露，立即：
1. 去 GitHub 撤销
2. 生成新 token
3. 更新配置

---

**二爷，配置说明已更新！** 🚀
