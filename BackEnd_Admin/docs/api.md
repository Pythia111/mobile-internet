# 营养管理后端 API 文档

本文件汇总当前后端已完成的接口、鉴权方式、请求/响应示例与注意事项。

## 总览

- **身份认证**：JWT Bearer Token
- **接口前缀**：`/api`
- **文档页面**：`/swagger-ui/index.html`
- **健康检查**：`/actuator/health`

## 全局规范

### 1. 响应格式
所有接口统一返回 JSON 格式：
```json
{
  "code": 200,      // 业务状态码 (200: 成功, 400: 业务错误, 401: 未认证, 403: 无权限, 500: 系统错误)
  "message": "成功", // 提示信息
  "data": {}        // 业务数据
}
```

### 2. 鉴权说明
- 登录/注册成功后，返回 `token`。
- 后续请求需在 Header 中携带：`Authorization: Bearer <token>`
- 角色区分：
  - 普通用户：`ROLE_USER`
  - 管理员：`ROLE_ADMIN`

---

## 模块1：用户认证与个人中心

### 1.1 用户注册
- **路径**: `/api/auth/register`
- **方法**: `POST`
- **描述**: 用户使用手机号、密码和用户名注册。
- **请求参数**:
```json
{
  "phone": "13800138000",    // 必填，手机号（唯一）
  "password": "Password123", // 必填，≥6位，含字母+数字
  "username": "张三"         // 必填，用户名
}
```
- **响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "userId": 1,
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

### 1.2 用户登录
- **路径**: `/api/auth/login`
- **方法**: `POST`
- **描述**: 用户使用手机号和密码登录。
- **请求参数**:
```json
{
  "phone": "13800138000",
  "password": "Password123"
}
```
- **响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "userId": 1,
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "role": "ROLE_USER"
  }
}
```

### 1.3 获取个人资料
- **路径**: `/api/user/profile`
- **方法**: `GET`
- **鉴权**: 需要
- **响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "userId": 1,
    "phone": "13800138000",
    "username": "张三",
    "avatar": "http://example.com/avatar.jpg",
    "role": "ROLE_USER"
  }
}
```

### 1.4 修改个人资料
- **路径**: `/api/user/profile`
- **方法**: `PUT`
- **鉴权**: 需要
- **描述**: 修改用户名、密码或头像（可选参数）。
- **请求参数**:
```json
{
  "username": "李四",          // 可选
  "password": "NewPassword123", // 可选
  "avatar": "http://new-avatar.jpg" // 可选
}
```
- **响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": null
}
```

---

## 模块1：管理员接口 (Admin)

### 1.5 获取所有用户列表
- **路径**: `/api/admin/users`
- **方法**: `GET`
- **鉴权**: 需要 (`ROLE_ADMIN`)
- **响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "phone": "13800138000",
      "username": "张三",
      "email": null,
      "avatar": null,
      "roles": ["ROLE_USER"],
      "createdAt": "2023-11-21T10:00:00Z"
    }
  ]
}
```

### 1.6 获取用户统计数据
- **路径**: `/api/admin/users/stats`
- **方法**: `GET`
- **鉴权**: 需要 (`ROLE_ADMIN`)
- **参数**: `days` (可选，默认7，统计最近几天的注册数)
- **响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "totalUsers": 100,
    "adminUsers": 5,
    "usersWithPassword": 90,
    "dailyRegistrations": {
      "2023-11-21": 10,
      "2023-11-20": 5
    }
  }
}
```
