减脂饮食管理
harmony用户为普通用户
web用户为管理员

模块1：用户认证与个人中心模块
后端负责人：cx
- **核心功能**：
  - 用户注册（手机号唯一 + 密码 + 用户名）
  - 用户登录（JWT令牌签发，区分普通用户/管理员）
  - 个人资料管理（修改头像、用户名、密码）
  - 管理员用户管理（用户列表查询、注册统计）
- **开发注意事项**：
  - **密码规则**：长度≥6位，必须包含字母和数字（后端已实现强校验）。
  - **认证方式**：全局使用 JWT (Bearer Token)，无状态认证。
  - **权限体系**：
    - Harmony端 -> 普通用户 (ROLE_USER)
    - Web端 -> 管理员 (ROLE_ADMIN)
  - **接口规范**：统一响应结构 `{code, message, data}`。
  - **安全要求**：密码BCrypt加密存储，接口不返回敏感信息。
  - **负载均衡**：考虑后续扩展。

项目接口文档
模块1：用户认证与个人中心模块
后端负责人：cx

1.1 用户注册
- 路径: /api/auth/register
- 方法: POST
- 请求参数:
{
  "phone": "string",    // 手机号（唯一）
  "password": "string", // 密码（≥6位，含字母+数字）
  "username": "string"  // 用户名
}
- 成功响应:
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "userId": "string",
    "token": "string"   // JWT令牌
  }
}
- 失败响应:
{
  "code": 400,
  "message": "手机号已存在/密码格式错误"
}
  
1.2 用户登录
- 路径: /api/auth/login
- 方法: POST
- 请求参数:
{
  "phone": "string",
  "password": "string"
}
- 响应:
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "userId": "string",
    "token": "string",   // JWT令牌
    "role": "user|admin" // 用户角色
  }
}
  
1.3 个人资料修改
- 路径: /api/user/profile
- 方法: PUT
- 请求头: Authorization: Bearer <token>
- 请求参数:
{
  "username": "string",  // 可选
  "password": "string",  // 可选（需满足密码规则）
  "avatar": "string"     // 头像URL
}
- 响应:
{
  "code": 200,
  "message": "修改成功"
}
  
1.4 获取个人信息
- 路径: /api/user/profile
- 方法: GET
- 请求头: Authorization: Bearer <token>
- 响应:
{
  "code": 200,
  "data": {
    "userId": "string",
    "phone": "string",
    "username": "string",
    "avatar": "string",
    "role": "user|admin"
  }
}

---

全局规范
1. 认证:  
  - 所有需登录的接口需在请求头携带 Authorization: Bearer <JWT token>
  - 管理员接口需携带管理员权限的token。
    
2. 响应格式:
{
  "code": 200,      // HTTP状态码
  "message": "成功", // 操作描述
  "data": {}        // 业务数据
}
  
3. 错误码:
  - 400: 参数错误
  - 401: 未授权/Token无效
  - 403: 权限不足
  - 404: 资源不存在
  - 500: 服务器错误
    
4. 权限控制:
  - 普通用户只能操作自己的数据。
  - 管理员可操作全局数据。
    
5. 安全要求:
  - 密码需哈希存储。
  - 敏感数据（如密码）不可返回响应。
  - 所有用户输入需验证过滤。
