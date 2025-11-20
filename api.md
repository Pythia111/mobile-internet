# 营养管理后端 API 文档（已实现）

本文件面向前端与团队成员，汇总当前后端已完成的接口、鉴权方式、请求/响应示例与注意事项。

## 总览

- 身份认证：JWT Bearer Token（登录/注册成功返回 `token`）
- 角色：`ROLE_USER`、`ROLE_ADMIN`
- 文档页面：`/swagger-ui/index.html`（或 `/swagger-ui.html`）
- 健康检查：`/actuator/health`

## Base URL

- 本地（H2，默认）：`http://localhost:8080`
- 本地（MySQL，mysql profile）：`http://localhost:8081`

后续示例默认省略主机前缀，请按实际端口替换。

## 鉴权说明

- 登录/注册成功后，前端需在后续请求头携带：`Authorization: Bearer <token>`
- 未携带或无效/过期 Token：返回 401
- 管理端接口（System 模块）需 `ROLE_ADMIN`，否则 403

## 错误返回

- Bean 校验失败、业务失败时，当前实现多返回简单文本（`text/plain`）或默认错误结构（由 Spring 处理）。
- 常见状态码：400（参数/业务错误）、401（未认证）、403（无权限）、404（未找到）。

---

## 认证 Auth

### 发送验证码
- `POST /api/auth/send-code`
- Body
```json
{ "phone": "+8613800000000" }
```
- 成功：`200 OK`，文本提示（验证码在开发环境打印日志，不实际发送）
- 失败：可能 400/500，返回错误文本（如触发限流）

示例（PowerShell / curl）：
```powershell
curl -X POST "http://localhost:8080/api/auth/send-code" ^
  -H "Content-Type: application/json" ^
  -d '{"phone":"+8613800000000"}'
```

### 注册（手机号 + 验证码）
- `POST /api/auth/register-with-code`
- Body
```json
{ "phone": "+8613800000000", "name": "张三", "code": "123456" }
```
- 成功：`200 OK`
```json
{ "token": "<JWT_TOKEN>" }
```
- 失败：`400 Bad Request`，文本：`验证码错误或已过期`

### 短信登录（手机号 + 验证码）
- `POST /api/auth/login-sms`
- Body
```json
{ "phone": "+8613800000000", "code": "123456" }
```
- 成功：`200 OK`
```json
{ "token": "<JWT_TOKEN>" }
```
- 失败：`400 Bad Request`，文本：`验证码错误或已过期`

### 当前用户信息
- `GET /api/auth/me`
- 认证：需要（Bearer Token）
- 成功：`200 OK`，返回用户对象（来自实体 `User` 的序列化）。示例：
```json
{
  "id": 1,
  "phone": "+8613800000000",
  "passwordHash": null,
  "name": "Admin",
  "email": null,
  "avatarUrl": null,
  "roles": [ { "id": 1, "name": "ROLE_USER" }, { "id": 2, "name": "ROLE_ADMIN" } ],
  "createdAt": "2025-11-17T12:00:00Z",
  "updatedAt": "2025-11-17T12:00:00Z"
}
```
- 失败：`401` 未认证；`404 用户不存在`

---

## 个人中心 User

### 获取我的资料
- `GET /api/users/me`
- 认证：需要
- 成功：`200 OK`，返回用户对象（结构同上）

### 更新我的资料
- `PUT /api/users/me`
- 认证：需要
- Body（均可选）：
```json
{ "name": "新昵称", "email": "user@example.com", "avatarUrl": "https://..." }
```
- 成功：`200 OK`，返回更新后的用户对象
- 失败：`401` 未认证；`404 用户不存在`

### 修改密码
- `POST /api/users/change-password`
- 认证：需要
- Body
```json
{ "oldPassword": "旧密码", "newPassword": "新密码(>=6位)" }
```
- 成功：`200 OK`，文本：`密码已更新`
- 失败：`400 Bad Request`，文本：`原密码不正确`；或 `401/404`

> 说明：如果账号尚未设置过密码（`passwordHash` 为空），首次可直接设置 `newPassword`，无需 `oldPassword` 正确。

---

## 系统管理 System（管理员）

以下接口需要 `ROLE_ADMIN`。

### 列出所有系统配置
- `GET /api/system/configs`
- 成功：`200 OK`
```json
[
  { "id": 1, "key": "sms.provider", "value": "mock", "description": "短信服务商", "updatedAt": "2025-11-17T12:00:00Z" }
]
```

### 新增/更新配置（按 key）
- `POST /api/system/configs`
- Body
```json
{ "key": "sms.provider", "value": "mock", "description": "短信服务商" }
```
- 成功：`200 OK`，返回保存后的配置对象

### 删除配置
- `DELETE /api/system/configs/{key}`
- 成功：`200 OK`（或 204 No Content）
- 失败：`404` 未找到

### 导出备份（下载 JSON）
- `POST /api/system/backup/export`
- 成功：`200 OK`，`application/octet-stream`（或 `application/json`），附件名如 `backup-<timestamp>.json`

### 导入备份
- `POST /api/system/backup/import?file=xxx.json`
- 参数：`file` 为服务器 `backups/` 目录下的文件名
- 成功：`200 OK`，文本：`导入完成`
- 失败：`400` 文件不存在

### 查看日志尾部
- `GET /api/system/logs/tail?lines=200`
- 成功：`200 OK`，`text/plain` 文本为日志末尾 N 行

---

## 模型（请求/响应 DTO）

### 认证相关
- `SendCodeRequest`
```json
{ "phone": "+8613800000000" }
```
- `RegisterRequest`
```json
{ "phone": "+8613800000000", "name": "昵称", "code": "123456" }
```
- `LoginSmsRequest`
```json
{ "phone": "+8613800000000", "code": "123456" }
```
- `JwtResponse`
```json
{ "token": "<JWT_TOKEN>" }
```

### 个人中心
- `UpdateProfileRequest`
```json
{ "name": "昵称", "email": "user@example.com", "avatarUrl": "https://..." }
```
- `ChangePasswordRequest`
```json
{ "oldPassword": "旧", "newPassword": "新(>=6位)" }
```

### 系统配置
- `SystemConfigDto`
```json
{ "id": 1, "key": "k", "value": "v", "description": "desc" }
```

---

## 调用示例（汇总）

```powershell
# 1) 发送验证码
curl -X POST "http://localhost:8080/api/auth/send-code" -H "Content-Type: application/json" -d '{"phone":"+8613800000000"}'

# 2) 使用验证码注册/登录，拿到 token
curl -X POST "http://localhost:8080/api/auth/login-sms" -H "Content-Type: application/json" -d '{"phone":"+8613800000000","code":"123456"}'

# 假设 token 存到环境变量 $env:TOKEN
$env:TOKEN = "<JWT_TOKEN>"

# 3) 查看我的资料
curl -H "Authorization: Bearer $env:TOKEN" "http://localhost:8080/api/users/me"

# 4) 更新资料
curl -X PUT "http://localhost:8080/api/users/me" -H "Authorization: Bearer $env:TOKEN" -H "Content-Type: application/json" -d '{"name":"新昵称"}'

# 5) 修改密码
curl -X POST "http://localhost:8080/api/users/change-password" -H "Authorization: Bearer $env:TOKEN" -H "Content-Type: application/json" -d '{"oldPassword":"old","newPassword":"NewPass123"}'

# 6) 管理端：列出配置（需要管理员 token）
curl -H "Authorization: Bearer $env:TOKEN" "http://localhost:8080/api/system/configs"
```

---

## 注意事项 / 规划

- 当前 `/api/auth/me` 与 `/api/users/me` 返回的用户对象会包含 `passwordHash` 字段（若非空），前端请忽略此字段；后续将以 DTO 屏蔽敏感信息。
- 验证码为内存模拟（开发模式），生产需对接短信服务商。
- Token 目前仅 Access Token，无刷新机制；可按需拓展 Refresh Token 与黑名单。
