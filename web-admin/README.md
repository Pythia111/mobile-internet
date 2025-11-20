# 营养管理后台 - Web管理端

基于 Vue 3 + Element Plus 开发的营养管理系统Web管理端，负责模块1的所有管理员功能。

## 技术栈

- **框架**: Vue 3 (Composition API)
- **UI组件库**: Element Plus
- **状态管理**: Pinia
- **路由**: Vue Router 4
- **HTTP客户端**: Axios
- **图表库**: ECharts
- **构建工具**: Vite
- **开发语言**: JavaScript

## 项目结构

```
web-admin/
├── public/              # 静态资源
├── src/
│   ├── api/            # API接口封装
│   │   ├── auth.js     # 认证相关API
│   │   ├── user.js     # 用户管理API
│   │   └── system.js   # 系统管理API
│   ├── layouts/        # 布局组件
│   │   └── MainLayout.vue  # 主布局
│   ├── router/         # 路由配置
│   │   └── index.js
│   ├── stores/         # Pinia状态管理
│   │   └── auth.js     # 认证状态
│   ├── utils/          # 工具函数
│   │   └── request.js  # Axios封装
│   ├── views/          # 页面组件
│   │   ├── Login.vue       # 登录页
│   │   ├── Dashboard.vue   # 数据统计
│   │   ├── UserList.vue    # 用户管理
│   │   └── SystemConfig.vue # 系统设置
│   ├── App.vue         # 根组件
│   └── main.js         # 入口文件
├── index.html
├── package.json
└── vite.config.js      # Vite配置
```

## 功能模块

### 1. 管理员登录页面 ✅
- 手机号+验证码登录
- 自动倒计时验证码按钮
- 表单验证
- JWT令牌管理

### 2. 用户列表管理页面 ✅
- 用户列表展示（含分页）
- 搜索功能（手机号、姓名）
- 用户详情查看
- 用户信息编辑
- 角色标识显示

### 3. 用户数据统计面板 ✅
- 关键指标卡片（总用户数、今日新增、活跃用户、管理员数）
- 用户增长趋势图（ECharts折线图）
- 用户角色分布图（ECharts饼图）
- 最近注册用户列表

### 4. 系统设置页面 ✅
- 系统配置管理（增删改查）
- 配置数据导出/导入
- 系统日志查看
- 实时日志刷新

## 核心特性

### 认证与权限
- JWT Token认证
- 自动Token注入请求头
- 路由守卫保护
- 401/403自动跳转

### 布局系统
- 响应式侧边栏导航
- 顶部栏用户信息展示
- 面包屑导航
- 个人信息管理
- 密码修改功能

### 用户体验
- 统一的错误提示
- Loading加载状态
- 表单验证提示
- 确认对话框

## 安装与运行

### 前置要求
- Node.js >= 16
- npm 或 yarn

### 安装依赖
```bash
cd web-admin
npm install
```

### 开发运行
```bash
npm run dev
```

项目将在 `http://localhost:3000` 启动

### 生产构建
```bash
npm run build
```

构建产物在 `dist/` 目录

## API接口对接

### 后端地址配置
在 `vite.config.js` 中配置代理：
```javascript
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',  // 后端地址
      changeOrigin: true
    }
  }
}
```

### 已实现的API调用

#### 认证相关
- `POST /api/auth/send-code` - 发送验证码
- `POST /api/auth/login-sms` - 短信登录
- `GET /api/auth/me` - 获取当前用户

#### 用户管理
- `GET /api/users/me` - 获取个人资料
- `PUT /api/users/me` - 更新个人资料
- `POST /api/users/change-password` - 修改密码

#### 系统管理
- `GET /api/system/configs` - 获取配置列表
- `POST /api/system/configs` - 新增/更新配置
- `DELETE /api/system/configs/{key}` - 删除配置
- `POST /api/system/backup/export` - 导出备份
- `POST /api/system/backup/import` - 导入备份
- `GET /api/system/logs/tail` - 查看日志

## 默认登录信息

开发环境下：
- 手机号：任意有效手机号（如 13800000000）
- 验证码：123456

## 待完善功能

### 后端接口需求
以下功能已在前端实现，但需要后端提供相应接口：

1. **用户列表接口**
   - `GET /api/admin/users?page=1&size=10&phone=&name=`
   - 返回分页的用户列表数据

2. **管理员编辑用户接口**
   - `PUT /api/admin/users/{id}`
   - 管理员修改用户信息

3. **统计数据接口**
   - `GET /api/admin/statistics/overview`
   - 返回用户总数、今日新增等统计数据
   
   - `GET /api/admin/statistics/trend?days=7`
   - 返回用户增长趋势数据

## 注意事项

1. **权限控制**: 所有管理端接口需要 `ROLE_ADMIN` 权限
2. **Token过期**: Token过期后会自动跳转到登录页
3. **数据模拟**: 部分数据使用模拟数据，待后端接口完善后替换
4. **跨域问题**: 开发环境使用Vite代理解决，生产环境需要后端配置CORS

## 开发规范

### 命名规范
- 组件名：PascalCase (如 `UserList.vue`)
- 方法名：camelCase (如 `fetchUsers`)
- 常量名：UPPER_SNAKE_CASE (如 `API_BASE_URL`)

### 代码风格
- 使用 Composition API
- 使用 `<script setup>` 语法
- Props 和 Emits 使用 TypeScript 风格定义

### Git提交规范
- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- style: 代码格式调整
- refactor: 重构
- test: 测试
- chore: 构建/工具链调整

## 问题排查

### 登录失败
1. 检查后端服务是否启动（8080端口）
2. 检查验证码是否为 123456
3. 查看浏览器控制台网络请求

### 接口报错
1. 检查Token是否有效
2. 检查是否有ADMIN权限
3. 查看后端日志

### 页面空白
1. 清除浏览器缓存
2. 检查控制台错误信息
3. 重新安装依赖

## 作者

成员F - Web前端负责人

## 更新日志

### v1.0.0 (2024-11-20)
- ✅ 完成管理员登录功能
- ✅ 完成用户列表管理
- ✅ 完成数据统计面板
- ✅ 完成系统设置功能
- ✅ 完成主布局和导航
- ✅ 完成个人信息管理
- ✅ 完成密码修改功能
