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

### 后端API

详见 [api.md](./api.md)

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

- [x] 模块1：用户认证与个人中心模块（Web管理端）✅
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

- [API文档](./api.md) - 后端接口文档
- [Web管理端文档](./web-admin/README.md) - 完整功能说明
- [快速启动指南](./web-admin/QUICKSTART.md) - 5分钟上手
- [模块1总结](./web-admin/MODULE1_SUMMARY.md) - 开发总结

## License

MIT
