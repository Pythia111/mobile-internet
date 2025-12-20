# 模块二API使用指南

## 概述
模块二提供饮食记录与食物识别功能，集成了讯飞星火大模型AI，支持智能食物识别和营养分析。

## 功能特性
- ✅ AI食物识别（支持中文描述）
- ✅ 智能营养信息分析
- ✅ 饮食记录管理
- ✅ 食物搜索功能
- ✅ 饮食历史查询

## API接口列表

### 1. 用户认证

#### 1.1 用户注册
```
POST /api/auth/register
Content-Type: application/json

{
    "username": "testuser",
    "phone": "13800138001",
    "password": "test123"
}
```

**响应示例：**
```json
{
    "code": 200,
    "message": "success",
    "data": {
        "userId": 4,
        "token": "eyJhbGciOiJIUzI1NiJ9..."
    }
}
```

#### 1.2 用户登录
```
POST /api/auth/login
Content-Type: application/json

{
    "phone": "13800138001",
    "password": "test123"
}
```

**响应示例：**
```json
{
    "code": 200,
    "message": "success",
    "data": {
        "userId": 4,
        "token": "eyJhbGciOiJIUzI1NiJ9...",
        "role": "ROLE_USER"
    }
}
```

### 2. 饮食记录模块

**注意：所有饮食记录接口都需要在Headers中添加JWT令牌：**
```
Authorization: Bearer {token}
Content-Type: application/json; charset=utf-8
```

#### 2.1 添加饮食记录
```
POST /api/diet/records
```

**请求体：**
```json
{
    "foodName": "米饭",
    "calories": 125,
    "protein": 1.3,
    "carbohydrates": 49.2,
    "fat": 0.2,
    "mealType": "lunch",
    "date": "2025-11-28",
    "image": ""
}
```

**参数说明：**
- `foodName`: 食物名称
- `calories`: 热量（每100g）
- `protein`: 蛋白质含量（g）
- `carbohydrates`: 碳水化合物含量（g）
- `fat`: 脂肪含量（g）
- `mealType`: 餐别类型（breakfast/lunch/dinner/snack）
- `date`: 记录日期（YYYY-MM-DD）
- `image`: 图片URL（可选）

**响应示例：**
```json
{
    "code": 200,
    "message": "success",
    "data": {
        "recordId": "123"
    }
}
```

#### 2.2 AI食物识别 ⭐
```
POST /api/diet/recognize
```

**请求体：**
```json
{
    "description": "一碗白米饭"
}
```

**中文示例：**
- "红烧肉"
- "西红柿炒鸡蛋"
- "麻婆豆腐"
- "一份宫保鸡丁"

**响应示例：**
```json
{
    "code": 200,
    "message": "success",
    "data": {
        "foodName": "米饭",
        "calories": 125,
        "protein": 1.3,
        "carbohydrates": 49.2,
        "fat": 0.2
    }
}
```

#### 2.3 搜索食物
```
GET /api/diet/search?keyword={关键词}
```

**示例：**
```
GET /api/diet/search?keyword=牛肉
```

**响应示例：**
```json
{
    "code": 200,
    "message": "success",
    "data": [
        {
            "foodName": "牛肉",
            "calories": 250,
            "protein": 26.0,
            "carbohydrates": 0.0,
            "fat": 15.0
        }
    ]
}
```

#### 2.4 获取饮食历史
```
GET /api/diet/records/all
```

**响应示例：**
```json
{
    "code": 200,
    "message": "success",
    "data": {
        "date": "2025-11-28",
        "meals": [
            {
                "mealType": "lunch",
                "foods": [
                    {
                        "recordId": "123",
                        "foodName": "米饭",
                        "calories": 125,
                        "imageUrl": ""
                    }
                ]
            }
        ]
    }
}
```

#### 2.5 删除饮食记录
```
DELETE /api/diet/records/{recordId}
```

**响应示例：**
```json
{
    "code": 200,
    "message": "success",
    "data": "删除成功"
}
```

## 测试指南

### Postman测试步骤

#### 步骤1: 环境配置
1. 创建新的Environment: `Nutrition API`
2. 添加变量：
   - `base_url`: `http://localhost:8081`
   - `token`: (登录后自动设置)

#### 步骤2: 创建Collection
创建名为"模块二-饮食记录API"的Collection

#### 步骤3: 用户登录
```
POST {{base_url}}/api/auth/login
Body:
{
    "phone": "13800138001",
    "password": "test123"
}

Tests脚本（自动保存token）：
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    if (jsonData.data && jsonData.data.token) {
        pm.environment.set("token", jsonData.data.token);
    }
}
```

#### 步骤4: AI识别测试
```
POST {{base_url}}/api/diet/recognize
Headers:
    Authorization: Bearer {{token}}
    Content-Type: application/json; charset=utf-8
Body:
{
    "description": "红烧肉"
}
```

### PowerShell测试（UTF-8编码）

如果使用PowerShell测试，需要特别处理UTF-8编码：

```powershell
# 定义UTF-8请求函数
function Test-ChineseFoodAI {
    param($description)
    
    $jsonBody = @{ description = $description } | ConvertTo-Json -Compress
    $body = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
    
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("Authorization", "Bearer $token")
    $webClient.Headers.Add("Content-Type", "application/json; charset=utf-8")
    $webClient.Encoding = [System.Text.Encoding]::UTF8
    
    try {
        $responseBytes = $webClient.UploadData("http://localhost:8081/api/diet/recognize", "POST", $body)
        $responseText = [System.Text.Encoding]::UTF8.GetString($responseBytes)
        return $responseText | ConvertFrom-Json
    } finally {
        $webClient.Dispose()
    }
}

# 测试示例
$result = Test-ChineseFoodAI -description "麻婆豆腐"
```

## AI功能配置

### 开启/关闭AI功能
在 `application-module2.yml` 中配置：

```yaml
app:
  ai:
    xfyun:
      api-key: your-api-key-here
      api-base: https://maas-api.cn-huabei-1.xf-yun.com/v1
      model-id: your-model-id-here
      enabled: true  # true=使用AI, false=使用模拟数据
```

### AI功能说明
- **开启时**: 调用讯飞星火API进行真实的食物识别
- **关闭时**: 返回预设的20种食物中的随机一种
- **降级策略**: AI调用失败时自动降级到模拟数据

## 常见问题

### Q: 中文识别不准确？
A: 确保请求头包含 `charset=utf-8`，使用详细的中文描述

### Q: AI响应时间长？
A: 正常现象，AI API调用需要3-10秒，可以添加loading提示

### Q: 登录后访问接口返回403？
A: 检查JWT token是否正确设置在Authorization header中

### Q: PowerShell中文乱码？
A: 使用提供的UTF-8编码函数，或改用Postman测试

## 技术特性

- **数据库**: MySQL 8.0 with UTF-8支持
- **AI集成**: 讯飞星火大模型
- **认证方式**: JWT Token
- **编码支持**: 全栈UTF-8编码
- **容错机制**: AI调用失败时自动降级

---

**开发完成日期**: 2025年11月28日  
**版本**: v1.0.0  
**技术栈**: Spring Boot 2.7.18 + MySQL + 讯飞星火AI