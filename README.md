# 饮食管理应用 - 鸿蒙前端模块二

## 功能特性

### 🍎 核心功能
- **食物搜索** - 通过关键词搜索食物营养信息
- **饮食记录** - 添加和管理每日饮食记录
- **营养统计** - 查看热量、蛋白质、碳水、脂肪摄入统计
- **餐别管理** - 支持早餐、午餐、晚餐、加餐分类

## 技术栈

- **开发框架**: HarmonyOS ArkUI
- **开发语言**: ArkTS (TypeScript)
- **构建工具**: DevEco Studio
- **API通信**: HTTP RESTful API

## 项目结构

```
FrontEnd_Harmony/
├── entry/                          # 主模块
│   └── src/
│       └── main/
│           ├── ets/
│           │   ├── pages/          # 页面组件
│           │   │   ├── DietSearch.ets    # 食物搜索页面
│           │   │   └── DietMain.ets      # 饮食记录主页面
|           |   |   |__ DietHistory.ets   # 历史记录页面
│           │   ├── common/         # 公共模块
│           │   │   ├── diet-service.js   # 饮食服务
│           │   │   ├── api.js            # API服务
│           │   │   └── types.ts          # 类型定义
│           │   └── components/     # 公共组件
│           ├── resources/          # 资源文件
│           └── module.json5        # 模块配置
└── build-profile.json5             # 构建配置
```

## API接口

### 认证接口
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录

### 饮食接口
- `GET /api/diet/search?keyword={keyword}` - 搜索食物
- `POST /api/diet/records` - 添加饮食记录
- `GET /api/diet/records/all` - 获取饮食历史
- `DELETE /api/diet/records/{id}` - 删除饮食记录

## 开发环境配置

### 前置要求
- DevEco Studio 4.0+
- HarmonyOS SDK
- Node.js 16+

### 运行步骤
1. 克隆项目到本地
2. 使用DevEco Studio打开项目
3. 配置签名证书
4. 连接设备或启动模拟器
5. 点击运行按钮

## 构建说明

### 调试版本
```bash
# 在DevEco Studio中直接运行
# 或使用命令行构建
```

### 发布版本
1. 在DevEco Studio中选择Build > Build Hap(s)/App(s) > Build Release Hap
2. 配置签名信息
3. 生成发布包

## 配置说明

### 网络权限
在 `module.json5` 中配置网络访问权限：
```json
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      }
    ]
  }
}
```

### API配置
在 `common/api.js` 中配置后端服务地址：
```javascript
baseURL = 'http://your-server:8081/api'
```

## 特色实现

### 状态管理
使用鸿蒙的 `@State` 装饰器进行响应式状态管理，确保UI与数据同步。

### 错误处理
- 网络请求异常处理
- 用户操作反馈
- 优雅的降级方案

### 性能优化
- 图片懒加载
- 列表项复用
- 请求缓存机制

## 注意事项

1. **网络请求**: 确保设备网络连接正常，后端服务可访问
2. **权限配置**: 正确配置应用权限，特别是网络权限
3. **API兼容**: 确保前端API调用与后端接口保持一致
4. **数据格式**: 严格按照接口文档处理请求和响应数据

## 版本信息

- **当前版本**: 1.0.0
- **HarmonyOS版本**: 4.0.0+
