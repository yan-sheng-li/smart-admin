# SmartAdmin

基于 SpringBoot3 + Vue3 的快速开发平台脚手架。后端 Java17 + Sa-Token + Mybatis-Plus，前端 Vue3 + Vite5 + Pinia + Ant Design Vue，移动端 uniapp。

## 技术栈

| 端 | 技术 |
|---|---|
| 后端 | Java 17 · SpringBoot 3.5 · Sa-Token · Mybatis-Plus 3.5 · MySQL · Redis |
| 前端 | JavaScript · Vue 3 · Vite 5 · Pinia · Ant Design Vue 4 |
| 移动端 | uniapp (Vue3) · uni-ui · 支持 APP / 小程序 / H5 |

## 目录结构

```
smart-admin/
├── smart-admin-api-java17-springboot3/   后端（多模块 Maven）
│   ├── sa-base/                          公共底座（common + 23 个 support 模块）
│   └── sa-admin/                         主应用（业务 + 系统）
├── smart-admin-web-javascript/           前端
├── smart-app/                            移动端
└── 数据库SQL脚本/                         SQL 初始化脚本
```

后端四层架构：`controller → service → manager → dao`。

## 快速开始

### 环境要求

- JDK 17+（实际用 21 亦可）
- Maven 3.6+
- Node.js 18+ · pnpm
- MySQL 5.7+ / 8.x
- Redis 5+

### 1. 初始化数据库

```bash
mysql -e "CREATE DATABASE smart_admin_v3 DEFAULT CHARSET utf8mb4;"
mysql smart_admin_v3 < 数据库SQL脚本/mysql/smart_admin_v3.sql
```

### 2. 启动后端

```bash
cd smart-admin-api-java17-springboot3
mvn -Pdev clean package -DskipTests
java -jar sa-admin/target/sa-admin-dev-3.0.0.jar
```

默认端口 `1024`，依赖 MySQL `127.0.0.1:3306`（库名 `smart_admin_v3`，root/root）与 Redis `127.0.0.1:6379`（db1）。连接配置见 `sa-base/src/main/resources/<profile>/sa-base.yaml`。

### 3. 启动前端

```bash
cd smart-admin-web-javascript
pnpm install
pnpm localhost          # 本地联调，指向后端 1024
```

## 环境切换

后端用 Maven profile，对应 `src/main/resources/<profile>/application.yaml`：

| profile | 激活方式 | jar 名 |
|---|---|---|
| `dev`（默认） | （不指定即默认） | `sa-admin-dev-3.0.0.jar` |
| `test` | `-Ptest` | `sa-admin-test-3.0.0.jar` |
| `pre` | `-Ppre` | `sa-admin-pre-3.0.0.jar` |
| `prod` | `-Pprod` | `sa-admin-prod-3.0.0.jar` |

前端用 Vite mode 对应：`localhost` / `build:test` / `build:pre` / `build:prod`。

## 功能清单

- **安全**：双因子登录 · 密码加密 · 登录错误次数锁定 · 登录超时 · 数据脱敏
- **接口加解密**：请求参数与返回内容加解密，支持国产算法
- **表格自定义列**：用户自定义列并持久化
- **数据变更记录**：基于 git-diff 的数据变化追踪
- **在线文档**：右侧帮助文档 · 意见反馈 · 版本记录
- **OA 办公**：公司信息（发票/银行/员工）· 通知公告
- **日志监控**：心跳日志 · 登录日志 · 操作日志（IP/浏览器/OS）
- **系统**：员工 · 部门 · 角色 · 权限 · 菜单 · 水印 · 文件管理 · 系统参数 · 数据字典 · 单号生成
- **代码生成**：基于表配置 · 在线预览 · 下载

## 工具脚本

### `auto-deploy-generated-code.ps1` — 一键部署生成代码

代码生成器下载的 zip 默认要手工解压、逐文件复制到对应目录。此脚本自动完成：后端 controller/dao/domain/manager/service、mapper XML、SQL 脚本就位，前端 api/const/views 复制，并自动追加 `constants/index.js` 的 import 与 `table-id-const.js` 的 tableId。

```powershell
# 默认按 smart-admin 项目根路径部署，模块名取自 zip 内目录名（如 demo）
./auto-deploy-generated-code.ps1 -zipPath "E:/下载/t_demo_code.zip"

# 自定义项目根路径
./auto-deploy-generated-code.ps1 -zipPath "<zip>" `
  -backendRoot "<后端根>" -frontendRoot "<前端根>"
```

脚本会自动清理空目录（`config`、`mapper`）。运行后仍需手动：执行 `sql/*.sql` 建菜单、重启前后端。

### `rename-pkg.sh` — Java 包名整体迁移

把整个后端的包名从 `OLD` 整体改为 `NEW`，覆盖 java/xml/yml/vm 等文件内的点号与斜杠形态，并迁移物理目录、自检残留。默认 dry-run，加 `--apply` 才真改。

```bash
# 预览命中（不改文件）
./rename-pkg.sh net.lab1024 com.example.project smart-admin-api-java17-springboot3

# 确认无误后真改
./rename-pkg.sh net.lab1024 com.example.project smart-admin-api-java17-springboot3 --apply

# 改完验证
./rename-pkg.sh net.lab1024 com.example.project smart-admin-api-java17-springboot3 --apply
```

参数：`<OLD_DOTTED> <NEW_DOTTED> <TARGET_DIR> [--apply]`。`NEW` 段数可与 `OLD` 不同。改完建议 `cd <TARGET> && mvn -q -o compile` 验证。
