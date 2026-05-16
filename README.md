# I Love Day 情侣成长记录小站

![PHP](https://img.shields.io/badge/PHP-7.4%2B-777BB4?logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-5.7%2B-4479A1?logo=mysql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Supported-2496ED?logo=docker&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

一个为情侣/伴侣设计的轻量级私密小站，用于记录在一起的每一天：纪念日、相册、日记、留言等内容都集中在一个温馨的小空间里。

**项目地址**:
- GitHub: [https://github.com/MiTaosot/I_Love_Day](https://github.com/MiTaosot/I_Love_Day)
- Gitee(国内镜像): [https://gitee.com/miTaolou/i_-love_-day](https://gitee.com/miTaolou/i_-love_-day)

---

## 功能概览

- **首页 Dashboard** — 在一起天数实时计时器、统计卡片、纪念事件胶囊、最新动态
- **文章/日记** — 富文本编辑、加密文章、情侣共创、块级对话模式
- **相册** — 图片/视频上传、瀑布流展示、灯箱预览、自动图片优化
- **纪念事件** — 时间线展示、每年重复提醒、重要标记
- **留言墙** — 公开/私密留言、QQ 头像自动获取、IP 归属地
- **后台管理** — 仪表盘、文章/相册/事件管理、系统设置、图片工具
- **安全防护** — CSRF 保护、登录防爆破、SQL 注入防护、Session 安全

---

## 技术栈

| 层 | 技术 |
|----|------|
| 语言 | PHP 7.4+ |
| 数据库 | MySQL 5.7+ / MariaDB |
| 前端 | 原生 JS + CSS + Font Awesome 6 |
| 图片处理 | PHP GD（压缩、缩略图、WebP） |
| 视频转码 | ffmpeg（可选，用于 H.264+AAC 转码） |
| 编辑器 | wangEditor（后台富文本） |

---

## 图片优化系统

本项目内置完整的图片优化管线：

```
上传 → MIME 校验 → 压缩(2560px/JPEG82) → WebP副本 → 320px缩略图 → 1200px中尺寸
```

| 尺寸 | 用途 | 目录 |
|------|------|------|
| 原图(≤2560px) | 存档 | `uploads/albums/{id}/` |
| 1200px | 灯箱预览 | `uploads/albums/{id}/medium/` |
| 640px | 瀑布流（旧格式） | `uploads/albums/{id}/thumbs/` |
| 320px | 首页/列表卡片 | `uploads/albums/{id}/thumbs_320/` |
| WebP | 所有尺寸 | 同目录 `.webp` 文件 |

**兼容策略：** 所有新字段 NULL 默认，查询使用 `COALESCE(新字段, 旧字段, 原图)` 回退链，历史图片零影响。

---

## 目录结构

```
├── index.php             前台首页
├── install.php           可视化安装向导
├── login.php / logout.php
├── article.php           文章详情
├── albums.php            相册列表
├── album.php             相册详情
├── events.php            事件时间线
├── messages.php          留言墙
├── config/
│   ├── config.php        全局配置
│   └── database.php      数据库连接（安装时生成）
├── core/
│   ├── helpers.php       工具函数（上传/压缩/URL/CSRF）
│   ├── Database.php      PDO 封装
│   ├── Auth.php          认证与会话
│   └── Parsedown.php     Markdown 解析
├── admin/                后台管理
├── api/                  AJAX 接口
├── views/                前台视图模板
├── assets/               静态资源（CSS/JS/字体）
├── uploads/              用户上传文件
├── database/
│   └── schema.sql        数据库表结构
├── Dockerfile            Docker 镜像
├── docker-compose.yml    Docker 编排
└── docker-entrypoint.sh  Docker 启动脚本
```

---

## 环境要求

- PHP 7.4+（需启用 PDO、GD、mbstring、fileinfo）
- MySQL 5.7+ / MariaDB 10.3+
- Apache（mod_rewrite）或 Nginx
- ffmpeg（可选，视频转码增强）
- PHP 上传限制 ≥ 15MB

---

## 方式一：宝塔面板部署（推荐）

### 1. 准备环境

```
宝塔面板 → 软件商店 → 安装：
  - PHP 7.4 或 8.1
  - MySQL 5.7
  - Nginx 或 Apache

PHP → 设置 → 安装扩展：fileinfo、GD
PHP → 设置 → upload_max_filesize = 50M
```

### 2. 创建站点

```
宝塔面板 → 网站 → 添加站点
  - 域名：填写你的域名
  - 根目录：指向项目根目录
  - 数据库：创建 MySQL 数据库（记下库名、用户名、密码）
```

### 3. 上传代码

将项目所有文件上传到网站根目录。

### 4. 安装系统

```bash
# 在网站根目录创建解锁文件
touch enable_install.lock
```

浏览器访问 `https://你的域名/install.php`，按向导完成：
- Step 1：填写数据库信息
- Step 2：创建情侣账号
- Step 3：设置站点名称和恋爱开始日期

安装完成后系统自动删除 `enable_install.lock` 并创建 `.installed` 标记。建议手动删除 `install.php`。

### 5. 安全配置

编辑 `config/config.php`：
```php
// 修改为随机字符串（32位以上）
define('SECRET_KEY', '你的随机密钥');
```

生成随机密钥：
```bash
php -r "echo bin2hex(random_bytes(16));"
```

### 6. 图片优化升级（新功能）

如果你是从旧版本升级，执行以下 SQL（宝塔面板 → 数据库 → SQL 窗口）：

```sql
ALTER TABLE `album_images`
  ADD COLUMN `thumb_url`       varchar(500) DEFAULT NULL,
  ADD COLUMN `medium_url`      varchar(500) DEFAULT NULL,
  ADD COLUMN `webp_url`        varchar(500) DEFAULT NULL,
  ADD COLUMN `thumb_webp_url`  varchar(500) DEFAULT NULL,
  ADD COLUMN `medium_webp_url` varchar(500) DEFAULT NULL;

ALTER TABLE `albums`
  ADD COLUMN `cover_thumb_url` varchar(500) DEFAULT NULL,
  ADD COLUMN `cover_webp_url`  varchar(500) DEFAULT NULL;

ALTER TABLE `articles`
  ADD COLUMN `cover_image`     varchar(500) DEFAULT NULL,
  ADD COLUMN `cover_thumb_url` varchar(500) DEFAULT NULL,
  ADD COLUMN `cover_webp_url`  varchar(500) DEFAULT NULL;

INSERT IGNORE INTO `settings` (`key`, `value`, `description`) VALUES
  ('image_thumb_enabled', '1', '多尺寸缩略图开关'),
  ('image_webp_enabled',  '1', 'WebP自动生成开关'),
  ('image_lazy_enabled',  '1', '前端懒加载开关'),
  ('image_cdn_url',       '',  'CDN域名前缀');
```

然后上传更新后的业务文件覆盖：
- `core/helpers.php`
- `album.php`
- `albums.php`
- `views/home.php`
- `api/albums.php`
- `admin/tools_image_stats.php`

部署后进入后台 → 工具 → 图片统计 → 点击「补齐新变体字段」，为历史图片生成 320px/1200px/WebP 变体。

---

## 方式二：Docker 本地开发

### 启动

```powershell
cd 项目目录
docker compose up -d
```

首次启动会拉取 PHP 8.1 镜像和 MySQL 5.7 镜像并构建，约 2-3 分钟。

### 访问

| 服务 | 地址 |
|------|------|
| 网站首页 | http://localhost:8080 |
| 后台管理 | http://localhost:8080/admin/ |
| MySQL | localhost:3308 |

### 数据库

首次启动时自动创建数据库、导入表结构、生成配置文件。

数据库数据持久化在 Docker 卷 `db_data` 中，`docker compose down` 不会丢失。必须执行 `docker compose down -v` 才会清除。

### 常用命令

```bash
# 启动
docker compose up -d

# 停止
docker compose down

# 查看日志
docker compose logs -f web

# 重建（代码变更后）
docker compose build
docker compose up -d

# 进入容器
docker compose exec web bash

# 连接数据库
docker compose exec db mysql -u love_story -plove_story_dev love_story
```

### 文件说明

| 文件 | 用途 |
|------|------|
| `Dockerfile` | PHP 8.1 + Apache + GD(WebP) + PDO MySQL |
| `docker-compose.yml` | PHP + MySQL 双容器编排 |
| `docker-entrypoint.sh` | 启动时自动生成 database.php + .installed |
| `.env` | 端口和数据库凭据 |
| `.dockerignore` | 排除不需要的文件 |

> Docker 文件仅用于本地开发，部署到服务器不需要上传。

---

## 回滚方案

如果升级后遇到问题，秒级回滚：

```sql
UPDATE settings SET value = '0' WHERE `key` IN ('image_thumb_enabled', 'image_webp_enabled');
```

所有新逻辑自动失效，前端回退到旧字段。如需完全回滚代码，将备份的旧文件覆盖即可。

---

## 安全说明

- Session Cookie 设置 HttpOnly + SameSite + Secure(HTTPS)
- 登录防爆破：单账号+IP 15分钟内最多5次尝试，超限锁定15分钟
- CSRF 保护：所有后台敏感操作需验证 Token
- 数据库访问统一通过 PDO 预处理语句
- 文件上传限制 MIME 类型（finfo 检测）和扩展名
- 加密文章/相册：未登录用户仅看到提示，不暴露内容

---

## 常见问题

**Q：首次访问跳转到安装页面？**
系统检测到未安装会自动跳转到 `install.php`，完成安装后首页正常显示。

**Q：图片存储在哪里？**
上传的文件保存在 `uploads/` 目录，按 `articles/{id}/` 和 `albums/{id}/` 分目录存储。注意备份该目录。

**Q：可以不装 ffmpeg 吗？**
可以。ffmpeg 是可选的，仅影响视频转码和自动封面图功能。图片上传和展示不受影响。

**Q：旧图片在升级后会受影响吗？**
不会。所有新增字段默认 NULL，查询使用 COALESCE 回退链，旧图片加载路径完全不变。

---

## 授权与署名

- 允许修改和二次开发，用于自用或部署给他人使用
- 需保留原项目署名信息（项目名称、作者、项目地址）
- 较大改动建议注明"基于 I Love Day 二次开发"

---

本项目由多种 AI 模型与人工协作开发：
- GPT 5.1: 约 60%
- Claude 4.5: 约 35%
- Gemini 3 Pro: 约 2%
- 人工手动调整与纠错(MiTao): 约 3%

项目发起与维护者: **MiTao**
