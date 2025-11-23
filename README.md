# 营养管理系统

移动互联网课程大作业 - 营养管理系统

## 项目简介

一个基于现代技术栈的营养管理系统，包括HarmonyOS用户端、Web管理端和Spring Boot后端。

## 项目结构

```
mobile-internet/
├── web-admin/          # Web管理端（Vue 3 + Element Plus）✅ 已完成
├── api.md              # 后端API文档
└── README.md           # 项目说明
```

## 子项目说明

### Web管理端 (web-admin/)

**负责人**: 成员F  
**技术栈**: Vue 3 + Element Plus + Vite  
**状态**: ✅ 已完成

详细文档：
- [完整文档](./web-admin/README.md)
- [快速启动](./web-admin/QUICKSTART.md)
- [开发总结](./web-admin/MODULE1_SUMMARY.md)

快速启动：
```bash
cd web-admin
npm install
npm run dev
```

### HarmonyOS前端

**负责人**：cyg，lxy

**技术栈**：

- adb version：

  Android Debug Bridge version 1.0.41
  Version 36.0.0-13206524

- ArkTS SDK：

  6.0.0(20)

**项目结构**

```
entry/src/main/
├── ets/
│   ├── entryability/              # 应用入口
│   │   └── EntryAbility.ets
│   ├── pages/                     # 页面层
│   │   ├── auth/                  # 认证模块
│   │   │   ├── Login.ets          # 登录页面
│   │   │   ├── Register.ets       # 注册页面
│   │   │   └── AuthRouter.ets     # 认证路由
│   │   ├── user/                  # 用户中心模块
│   │   │   ├── Profile.ets        # 个人资料页
│   │   │   ├── EditProfile.ets    # 编辑资料页
│   │   │   └── ！SecuritySettings.ets # 安全设置（不需要）
│   │   ├── diet/                  # 饮食记录模块
│   │   │   ├── DietHome.ets       # 饮食记录主页
│   │   │   ├── FoodSearch.ets     # 食物搜索页
│   │   │   ├── FoodRecognition.ets # AI食物识别页
│   │   │   ├── AddRecord.ets      # 添加记录页
│   │   │   └── DietHistory.ets    # 饮食历史页
│   │   ├── forum/                 # 论坛模块
│   │   │   ├── ForumHome.ets      # 论坛主页
│   │   │   ├── PostDetail.ets     # 帖子详情页
│   │   │   ├── CreatePost.ets     # 发帖页面
│   │   │   ├── UserProfile.ets    # 用户主页
│   │   │   └── components/        # 论坛组件
│   │   │       ├── PostItem.ets
│   │   │       ├── CommentItem.ets
│   │   │       └── LikeButton.ets
│   │   └── main/                  # 主页面
│   │       ├── Index.ets          # 应用首页
│   │       ├── MainTab.ets        # 主标签页
│   │       └── Navigation.ets     # 导航组件
│   ├── model/                     # 数据模型层
│   │   ├── api/                   # API服务
│   │   │   ├── ApiClient.ets      # 网络请求封装
│   │   │   ├── AuthApi.ets        # 认证接口
│   │   │   ├── UserApi.ets        # 用户接口
│   │   │   ├── DietApi.ets        # 饮食接口
│   │   │   └── ForumApi.ets       # 论坛接口
│   │   ├── entity/                # 数据实体
│   │   │   ├── User.ets           # 用户实体
│   │   │   ├── DietRecord.ets     # 饮食记录实体
│   │   │   ├── Food.ets           # 食物实体
│   │   │   ├── Post.ets           # 帖子实体
│   │   │   └── Comment.ets        # 评论实体
│   │   └── response/              # 响应模型
│   │       ├── ApiResponse.ets
│   │       └── PageResponse.ets
│   ├── utils/                     # 工具类
│   │   ├── HttpUtils.ets          # HTTP工具
│   │   ├── StorageUtils.ets       # 存储工具
│   │   ├── TokenManager.ets       # Token管理
│   │   ├── Validator.ets          # 表单验证
│   │   ├── DateUtils.ets          # 日期工具
│   │   ├── ImageUtils.ets         # 图片工具(Base64处理)
│   │   └── Constants.ets          # 常量定义
│   ├── components/                # 公共组件
│   │   ├── common/                # 通用组件
│   │   │   ├── CustomButton.ets
│   │   │   ├── CustomInput.ets
│   │   │   ├── Avatar.ets
│   │   │   ├── Loading.ets
│   │   │   └── EmptyState.ets
│   │   ├── layout/                # 布局组件
│   │   │   ├── Header.ets
│   │   │   ├── BottomTab.ets
│   │   │   └── Sidebar.ets
│   │   └── form/                  # 表单组件
│   │       ├── PasswordInput.ets
│   │       ├── PhoneInput.ets
│   │       └── ImagePicker.ets
│   ├── router/                    # 路由管理
│   │   ├── RouterManager.ets
│   │   └── Routes.ets
│   └── state/                     # 状态管理
│       ├── UserState.ets          # 用户状态
│       ├── DietState.ets          # 饮食状态
│       ├── ForumState.ets         # 论坛状态
│       └── index.ets
├── resources/                     # 资源文件
│   ├── base/
│   │   ├── element/               # 元素资源
│   │   │   ├── string.json        # 字符串资源
│   │   │   ├── color.json         # 颜色资源
│   │   │   └── float.json         # 尺寸资源
│   │   ├── media/                 # 媒体资源
│   │   │   ├── icon.png           # 应用图标
│   │   │   ├── logo.png           # 应用logo
│   │   │   ├── default_avatar.png # 默认头像
│   │   │   └── images/            # 其他图片
│   │   └── profile/               # 页面配置文件
│   │       └── main_pages.json
│   ├── en_US/                     # 英文资源
│   └── zh_CN/                     # 中文资源
└── module.json5                   # 模块配置文件
```

### 后端API

详见 InterfaceDoc.md

## 团队分工

| 成员 | 角色 | 负责模块 |
|------|------|---------|
| 成员A | 后端开发 | 用户认证、系统管理 |
| 成员B | 后端开发 | 饮食记录、食物识别 |
| 成员C | 后端开发 | 营养分析、智能推荐 |
| 成员D | Harmony前端 | 用户认证、饮食记录 |
| 成员E | Harmony前端 | 食物搜索、营养分析 |
| 成员F | Web前端 | 管理员端所有功能 ✅ |

## 开发进度

- [x] 模块1-1：用户认证与个人中心模块（Web管理端）✅
- [ ] 模块1-2：HarmonyOS 端
- [ ] 模块2：饮食记录与食物识别模块
- [ ] 模块3：营养分析与进度追踪模块
- [ ] 模块4：报告生成与智能推荐模块
- [ ] 模块5：系统管理与工具模块

## 快速开始

### 1. Web管理端
```bash
cd web-admin
npm install
npm run dev
# 访问 http://localhost:3000
```

### 2. 后端服务
确保后端服务运行在 `http://localhost:8080`

## 文档索引

- [InterfaceDoc](./InterfaceDoc.md) - 后端接口文档
- [Web管理端文档](./web-admin/README.md) - 完整功能说明
- [快速启动指南](./web-admin/QUICKSTART.md) - 5分钟上手
- [模块1总结](./web-admin/MODULE1_SUMMARY.md) - 开发总结

## License

MIT
