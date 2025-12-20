# 模块三：论坛模块 - Postman 接口测试指南

## 📋 目录
1. [导入说明](#导入说明)
2. [环境配置](#环境配置)
3. [测试流程](#测试流程)
4. [接口说明](#接口说明)
5. [常见问题](#常见问题)

---

## 🚀 导入说明

### 步骤1：导入 Collection
1. 打开 Postman 应用
2. 点击左上角 **Import** 按钮
3. 选择 **Upload Files** 或直接拖拽文件
4. 选择 `模块三-论坛模块-Postman测试集.json` 文件
5. 点击 **Import** 完成导入

### 步骤2：查看导入结果
导入成功后，你会在左侧看到：
- **Collection 名称**：模块三：论坛模块接口测试
- **包含的请求数量**：12 个接口测试用例

---

## ⚙️ 环境配置

### 必需配置的变量

在开始测试前，你需要配置以下环境变量（在 Collection 的 Variables 标签页）：

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `baseUrl` | 后端服务地址 | `http://localhost:8080` |
| `userToken` | 普通用户 JWT 令牌 | `eyJhbGciOiJIUzI1NiIs...` |
| `adminToken` | 管理员 JWT 令牌 | `eyJhbGciOiJIUzI1NiIs...` |
| `postId` | 测试用的帖子ID（会自动保存） | `1` |
| `userId` | 测试用的用户ID | `1` |

### 如何获取 Token？

#### 方法1：通过登录接口获取（推荐）
```bash
# 普通用户登录
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
  "phone": "13800138000",
  "password": "user123"
}

# 管理员登录
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
  "phone": "13900139000",
  "password": "admin123"
}
```

#### 方法2：先创建测试账号
如果没有测试账号，先调用注册接口：
```bash
POST http://localhost:8080/api/auth/register
Content-Type: application/json

{
  "phone": "13800138000",
  "password": "user123",
  "username": "测试用户"
}
```

### 配置步骤
1. 在 Postman 中找到导入的 Collection
2. 点击 Collection 名称旁的 `...` 菜单
3. 选择 **Edit**
4. 切换到 **Variables** 标签页
5. 在 `CURRENT VALUE` 列填入实际值
6. 点击 **Save**

---

## 🧪 测试流程

### 推荐测试顺序

#### 阶段1：基础功能测试（普通用户）

1. **3.1 发布帖子**
   - 测试发布新帖子
   - 自动保存 `postId` 供后续测试使用
   - ✅ 期望：返回 200，包含 postId

2. **3.2 获取论坛帖子列表（全部）**
   - 测试获取所有公开帖子
   - ✅ 期望：返回 200，包含帖子数组

3. **3.3 获取帖子详情**
   - 测试获取单个帖子的详细信息
   - ✅ 期望：返回 200，包含完整帖子信息和评论列表

4. **3.4 点赞帖子**
   - 测试点赞功能
   - 可以多次调用测试点赞/取消点赞
   - ✅ 期望：返回 200，`liked: true/false`

5. **3.5 评论帖子**
   - 测试发表评论
   - ✅ 期望：返回 200，包含 commentId

6. **3.6 用户删除帖子**
   - 测试用户删除自己的帖子
   - ⚠️ 注意：需要使用发帖人的 token
   - ✅ 期望：返回 200，`newStatus: 3`

#### 阶段2：管理员功能测试

7. **3.6 管理员隐藏帖子（私密化）**
   - 测试管理员将帖子设为私密
   - ⚠️ 注意：需要使用管理员 token
   - ✅ 期望：返回 200，`newStatus: 2`

8. **3.6 管理员公开帖子（审核通过）**
   - 测试管理员审核通过帖子
   - ✅ 期望：返回 200，`newStatus: 0`

#### 阶段3：权限测试

9. **3.6 权限测试-用户尝试隐藏他人帖子（应失败）**
   - 测试权限控制是否正常
   - ✅ 期望：返回 400 或 403 错误

#### 阶段4：筛选与查询测试

10. **3.2 获取论坛帖子列表（按状态筛选-公开）**
    - 测试按状态筛选
    - ✅ 期望：返回 200，仅显示状态为 0 的帖子

11. **3.2 获取论坛帖子列表（按状态筛选-待审核）**
    - 测试管理员查看待审核帖子
    - ⚠️ 注意：需要管理员权限
    - ✅ 期望：返回 200，仅显示状态为 1 的帖子

12. **3.7 获取用户主页及帖子**
    - 测试获取用户主页
    - ✅ 期望：返回 200，包含用户信息和帖子列表

---

## 📖 接口详细说明

### 3.1 发布帖子
- **路径**：`POST /api/forum/posts`
- **权限**：需要登录（用户 token）
- **必填字段**：
  - `title`：帖子标题
  - `content`：帖子内容
  - `creatorName`：发帖人名称
  - `creatorAvatar`：发帖人头像URL
- **可选字段**：
  - `images`：图片URL数组

**请求示例**：
```json
{
  "title": "健康饮食分享：我的减脂餐",
  "content": "今天分享一下我的减脂餐食谱...",
  "images": [
    "https://example.com/images/meal1.jpg"
  ],
  "creatorName": "健康达人小王",
  "creatorAvatar": "https://example.com/avatar/user1.jpg"
}
```

**响应示例**：
```json
{
  "code": 200,
  "message": "发布成功",
  "data": {
    "postId": "123",
    "creatorName": "健康达人小王",
    "creatorAvatar": "https://example.com/avatar/user1.jpg"
  }
}
```

---

### 3.2 获取论坛帖子列表
- **路径**：`GET /api/forum/posts`
- **权限**：无需登录（公开接口）
- **查询参数**：
  - `page`：页码（默认1）
  - `size`：每页数量（默认10）
  - `status`：状态筛选（可选）
    - 0 = 公开
    - 1 = 待审核
    - 2 = 私密
    - 3 = 已删除

**响应示例**：
```json
{
  "code": 200,
  "data": {
    "posts": [
      {
        "postId": "123",
        "title": "健康饮食分享",
        "userId": "1",
        "username": "健康达人小王",
        "images": ["https://..."],
        "avatar": "https://...",
        "status": 0,
        "likeCount": 15
      }
    ],
    "totalPages": 5,
    "totalElements": 48,
    "currentPage": 1
  }
}
```

---

### 3.3 获取帖子详情
- **路径**：`GET /api/forum/posts/{postId}`
- **权限**：无需登录（公开接口）
- **路径参数**：
  - `postId`：帖子ID

**响应示例**：
```json
{
  "code": 200,
  "data": {
    "postId": "123",
    "title": "健康饮食分享",
    "content": "今天分享一下...",
    "images": ["https://..."],
    "userId": "1",
    "username": "健康达人小王",
    "avatar": "https://...",
    "status": 0,
    "comments": [
      {
        "commentId": "456",
        "content": "这个减脂餐看起来很健康！",
        "userId": "2",
        "username": "运动爱好者李明"
      }
    ]
  }
}
```

---

### 3.4 点赞帖子
- **路径**：`POST /api/forum/posts/{postId}/like`
- **权限**：需要登录（用户 token）
- **功能**：切换点赞状态（再次调用取消点赞）

**响应示例**：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "liked": true  // true=已点赞，false=已取消点赞
  }
}
```

---

### 3.5 评论帖子
- **路径**：`POST /api/forum/posts/{postId}/comments`
- **权限**：需要登录（用户 token）
- **必填字段**：
  - `content`：评论内容
  - `username`：评论人名称
  - `avatar`：评论人头像URL

**请求示例**：
```json
{
  "content": "这个减脂餐看起来很健康！",
  "username": "运动爱好者李明",
  "avatar": "https://example.com/avatar/user2.jpg"
}
```

**响应示例**：
```json
{
  "code": 200,
  "message": "评论成功",
  "data": {
    "commentId": "456",
    "username": "运动爱好者李明",
    "avatar": "https://example.com/avatar/user2.jpg"
  }
}
```

---

### 3.6 更新帖子状态（重点接口）

#### 状态码定义
| 状态码 | 名称 | 可见性规则 |
|--------|------|-----------|
| 0 | 公开 | 所有用户可见 |
| 1 | 待审核 | 仅管理员可见 |
| 2 | 私密 | 仅管理员可见 |
| 3 | 已删除 | 所有用户不可见 |

#### 操作类型与权限
| 操作类型 | 适用角色 | 状态转换 | 说明 |
|---------|---------|---------|------|
| delete | 用户 | → 3 | 用户删除自己的帖子 |
| privatize | 管理员 | → 2 | 管理员隐藏帖子 |
| publicize | 管理员 | → 0 | 管理员公开帖子 |

#### 请求示例

**用户删除帖子**：
```json
{
  "action": "delete",
  "reason": "不想公开此内容了"
}
```

**管理员隐藏帖子**：
```json
{
  "action": "privatize",
  "reason": "内容涉嫌违规，需要隐藏处理"
}
```

**管理员公开帖子**：
```json
{
  "action": "publicize",
  "reason": "审核通过，内容健康"
}
```

#### 响应示例
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "postId": "123",
    "newStatus": 3,
    "oldStatus": 0,
    "operator": {
      "id": "1",
      "role": "user"
    },
    "updatedAt": "2023-11-15T10:30:00Z"
  }
}
```

#### 错误场景
1. **用户尝试删除他人帖子**：
   ```json
   {
     "code": 400,
     "message": "无权删除他人的帖子"
   }
   ```

2. **普通用户尝试执行管理员操作**：
   ```json
   {
     "code": 400,
     "message": "权限不足,仅管理员可执行此操作"
   }
   ```

3. **无效的操作类型**：
   ```json
   {
     "code": 400,
     "message": "无效的操作类型: xxx"
   }
   ```

---

### 3.7 获取用户主页及帖子
- **路径**：`GET /api/forum/user/{userId}/posts`
- **权限**：无需登录（公开接口）
- **路径参数**：
  - `userId`：用户ID

**响应示例**：
```json
{
  "code": 200,
  "data": {
    "userId": "1",
    "username": "健康达人小王",
    "avatar": "https://...",
    "posts": [
      {
        "postId": "123",
        "title": "健康饮食分享",
        "status": 0,
        "likeCount": 15
      }
    ]
  }
}
```

---

## ❓ 常见问题

### Q1: 导入后找不到 Collection？
**A**: 检查左侧边栏是否选择了 **Collections** 标签页，搜索 "模块三" 关键词。

### Q2: 请求返回 401 未授权？
**A**: 检查以下几点：
1. 是否配置了正确的 token？
2. token 是否已过期？
3. 请求头是否正确添加了 `Authorization: Bearer {{userToken}}`？

### Q3: 3.6 接口权限测试失败？
**A**: 确保：
1. 用户删帖：使用发帖人的 token
2. 管理员操作：使用管理员 token
3. 检查后端角色判断逻辑是否正确

### Q4: postId 变量没有自动保存？
**A**: 
1. 确保先执行 **3.1 发布帖子** 接口
2. 检查该接口的 **Tests** 标签页是否有保存脚本
3. 手动在 Variables 中设置 postId

### Q5: 如何查看自动化测试结果？
**A**: 
1. 点击 Collection 右侧的 **Run** 按钮
2. 选择要运行的请求
3. 点击 **Run 模块三：论坛模块接口测试**
4. 查看测试结果面板

### Q6: 图片上传怎么测试？
**A**: 
1. 先调用文件上传接口（通常是 `/api/upload`）
2. 获取返回的图片 URL
3. 在发帖或评论时使用该 URL

### Q7: 如何测试分页功能？
**A**: 修改 **3.2 获取论坛帖子列表** 的查询参数：
```
page=1&size=5  // 第1页，每页5条
page=2&size=5  // 第2页，每页5条
```

---

## 📝 测试检查清单

### 功能测试
- [ ] 发布帖子成功
- [ ] 获取帖子列表（带分页）
- [ ] 获取帖子详情
- [ ] 点赞/取消点赞
- [ ] 发表评论
- [ ] 用户删除自己的帖子
- [ ] 管理员隐藏帖子
- [ ] 管理员公开帖子
- [ ] 按状态筛选帖子
- [ ] 获取用户主页

### 权限测试
- [ ] 用户不能删除他人帖子
- [ ] 用户不能执行管理员操作（privatize/publicize）
- [ ] 管理员可以管理所有帖子

### 边界测试
- [ ] 空标题/内容发帖（应失败）
- [ ] 不存在的帖子ID（应返回404）
- [ ] 无效的 token（应返回401）
- [ ] 无效的操作类型（应返回400）

---

## 🎯 最佳实践

1. **测试前准备**
   - 确保后端服务已启动
   - 准备至少2个测试账号（1个普通用户 + 1个管理员）
   - 清理测试数据或使用独立测试数据库

2. **测试顺序**
   - 先测试基础功能（发帖、浏览）
   - 再测试交互功能（点赞、评论）
   - 最后测试管理功能（状态管理）

3. **数据管理**
   - 使用有意义的测试数据
   - 测试完成后清理垃圾数据
   - 记录测试用的 ID（postId、userId 等）

4. **自动化测试**
   - 利用 Postman 的 Tests 脚本验证响应
   - 使用 Collection Runner 批量执行测试
   - 导出测试报告分析结果

---

## 📞 技术支持

如有问题，请联系：
- **后端负责人**：hly
- **项目模块**：模块三 - 论坛模块

---

**祝测试顺利！** 🚀

