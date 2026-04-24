# 速刷单词 App 实操手册

这份文档是基于这个项目从 0 到能跑、能登录、能部署、能在手机访问的真实过程整理出来的详细复刻手册。

目标：
- 以后即使没有这次对话，也能按步骤重新做一遍
- 知道每一步为什么做
- 知道常见报错怎么查
- 知道当前项目做到哪里、还差什么

项目目录：
- [rapid-word-flutter](D:/15pro/Documents/Clodex/rapid-word-flutter/README.md)

核心文件：
- [main.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/main.dart)
- [app.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/app.dart)
- [home_page.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/home/home_page.dart)
- [home_notifier.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/home/state/home_notifier.dart)
- [books_repository.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/books/data/books_repository.dart)

配套短版清单：
- [快速复刻清单.md](D:/15pro/Documents/Clodex/rapid-word-flutter/快速复刻清单.md)

## 1. 项目目标

这个 App 不是传统“背单词”，而是“快速刷词”。

核心玩法：
- 用户不断判断：`认识 / 不认识`
- 不认识的词自动进入错词本
- 错词可继续回刷
- 词书支持手动添加和批量导入
- 最终支持电脑和手机共用账号同步进度

参考方向：
- 接近“不背单词”那种快速过词体验
- 重点不是很重的学习系统，而是短时间高频过词

## 2. 当前技术方案

最终技术栈：
- 前端：`Flutter`
- 状态管理：`Riverpod`
- 本地持久化：`shared_preferences`
- 后端：`Supabase`
- 数据库：`PostgreSQL`
- 部署：`Vercel`

为什么这样选：
- `Flutter` 一套代码可以同时做 Windows 和 Web，后面还能扩手机
- `Supabase` 适合个人项目快速做登录、数据库和同步
- `Vercel` 免费方案够先把 Web 版跑起来

## 3. 整体开发路线

这次项目不是一步到位，而是按这个顺序推进的：

1. 先明确产品玩法
2. 先做原型，验证交互
3. 再迁到 Flutter
4. 先让 Windows 能跑起来
5. 再接 Supabase
6. 再做 Web
7. 再上线到 Vercel
8. 再回头修手机适配和性能

这个顺序很重要。以后复刻时也建议按这个节奏来。

## 4. 环境搭建

### 4.1 需要的环境

最少需要：
- Flutter SDK
- Git
- PowerShell
- Visual Studio 2022 的 Windows Desktop C++ 相关组件
- Chrome 或 Edge

如果以后想打 Android 包：
- Android Studio
- Android SDK

### 4.2 检查 Flutter 是否可用

```powershell
flutter --version
```

正常会输出 Flutter 和 Dart 版本。

如果命令找不到，再查：

```powershell
where.exe flutter
```

正常应该能看到类似：

```text
D:\flutter\bin\flutter.bat
```

### 4.3 进入项目目录

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter
```

### 4.4 拉依赖

```powershell
flutter pub get
```

成功后会看到：

```text
Got dependencies!
```

## 5. Flutter Windows 端搭建

### 5.1 补 Windows 工程

如果项目一开始没有 `windows/` 目录：

```powershell
flutter create --platforms=windows --project-name rapid_word_flutter .
```

注意：
- 当前目录名如果不合法，`flutter create` 可能因为 Dart 包名报错
- 用 `--project-name rapid_word_flutter` 可以绕开目录名不合法的问题

### 5.2 打开 Windows 开发者模式

如果运行时报：

```text
Building with plugins requires symlink support.
```

在 PowerShell 里运行：

```powershell
start ms-settings:developers
```

然后在系统设置里打开“开发者模式”。

### 5.3 运行 Windows 版

```powershell
flutter run -d windows
```

## 6. 项目结构说明

重要目录：
- [features/auth](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/auth)
- [features/books](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/books)
- [features/home](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/home)
- [features/review](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/review)
- [features/result](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/result)
- [features/wrong_words](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/wrong_words)
- [shared](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/shared)
- [theme](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/theme)

核心文件说明：

- [app.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/app.dart)
  - 应用入口
  - 注入 `BooksRepository`
  - 决定走登录页还是主页

- [home_page.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/home/home_page.dart)
  - 页面切换入口
  - 串起首页、词书、刷词、结果、错词本

- [home_notifier.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/home/state/home_notifier.dart)
  - 当前最重要的状态文件
  - 负责刷词状态、词书状态、本地持久化、云端同步

- [books_repository.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/books/data/books_repository.dart)
  - 与 Supabase 交互

## 7. Supabase 接入

### 7.1 创建项目

打开：

[https://supabase.com/dashboard](https://supabase.com/dashboard)

步骤：
1. 登录
2. 创建新项目
3. 记住项目名和地区

### 7.2 创建数据库表

SQL 文件位置：
- [schema.sql](D:/15pro/Documents/Clodex/rapid-word-flutter/supabase/schema.sql)

进入 Supabase 后台：
1. 打开项目
2. 进入 `SQL Editor`
3. 粘贴 `schema.sql`
4. 点击 `Run`

### 7.3 获取 API 配置

需要两个值：
- `Project URL`
- `Publishable key`

注意：
- `SUPABASE_URL` 要写成：

```text
https://你的项目.supabase.co
```

- 不要写成：

```text
https://你的项目.supabase.co/rest/v1/
```

- 只能用 `Publishable key`
- 不要用 `Secret key`

### 7.4 Flutter 里传入 Supabase 配置

当前项目使用 `--dart-define`：

```powershell
flutter run -d windows --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

配置读取文件：
- [supabase_config.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/core/supabase/supabase_config.dart)

## 8. 登录与邮箱验证

开发期常见问题：
- 注册后邮箱验证链接打不开
- 跳转地址不对

实际经验：
- 有时邮箱实际上已经确认成功，只是跳转地址没配好
- 在 Supabase 后台用户详情里看 `Confirmed at` 最稳
- 如果密码不确定，直接走 `password recovery`

## 9. Flutter Web 支持

### 9.1 补 Web 工程

如果项目没有 `web/` 目录：

```powershell
flutter create --platforms=web .
```

### 9.2 本机浏览器运行

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

成功后会打开本地地址，例如：

```text
http://localhost:53139
```

### 9.3 局域网测试

如果只是临时让手机访问本机开发网页：
- 电脑和手机必须连同一个 Wi-Fi
- 电脑必须开着
- `flutter run` 必须在跑

## 10. Vercel 部署

### 10.1 为什么要部署

如果不部署：
- 手机和电脑通常要在同一个局域网
- 电脑关机手机就打不开
- 不适合正式长期使用

部署后：
- 手机外网也能访问
- 不要求和电脑在同一网络
- 同一账号可多端同步数据

### 10.2 打包 Web

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter
flutter build web --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

### 10.3 安装 Vercel CLI

```powershell
npm i -g vercel
```

### 10.4 首次部署

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter\build\web
vercel
```

一般选择：
- `Set up and deploy?` 选 `Y`
- `Link to existing project?` 选 `N`
- `Project name` 自己填，例如 `rapid-word`
- 其他默认

### 10.5 正式部署

```powershell
cd build\web
vercel --prod
```

终端里通常会看到：
- `Inspect: ...`
- `Production: ...`
- `Aliased: https://rapid-word.vercel.app`

长期使用时优先打开正式别名域名。

## 11. 手机端适配问题

### 11.1 问题：像桌面网页缩小版

原因：
- `web/index.html` 缺少 `viewport`

修复位置：
- [index.html](D:/15pro/Documents/Clodex/rapid-word-flutter/web/index.html)

关键代码：

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
```

### 11.2 问题：词书页手机上很乱

表现：
- 卡片挤压
- 看起来像桌面双栏压缩到手机里

处理思路：
- 手机端单栏优先
- 当前词书区域单独成块
- 词书列表单独成块
- 词条预览单独成块

关键文件：
- [books_page.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/books/books_page.dart)

### 11.3 问题：刷词页单词断成两行

处理思路：
- 用 `FittedBox`
- `maxLines: 1`
- `softWrap: false`

关键文件：
- [review_page.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/review/review_page.dart)

### 11.4 问题：改了代码但手机看起来没变化

常见原因：
- 打开的不是最新部署
- 打开了旧的临时 Vercel 链接
- 浏览器缓存

验证方法：
- 给页面临时加版本标记
- 重新 `build + vercel --prod`
- 用最新 `Production` 地址或正式域名打开
- 必要时用无痕模式验证

## 12. 刷词交互调整记录

当前偏向的节奏：
- 默认先看英文
- 点击 `认识` 后显示答案
- 点击 `不认识` 后也显示中文，并自动进入下一词
- 不认识的词进入错词本

经验：
- 最影响手感的不是功能多，而是按钮点下去之后是否立刻响应

## 13. 性能问题与优化

### 13.1 实际感觉到的卡顿

主要两类：
- 滑动时略卡
- 点 `认识 / 不认识` 后有一丝停顿

### 13.2 原因分析

滑动卡顿：
- Flutter Web 在手机浏览器本来就比原生弱
- 卡片层级较多
- 渐变、圆角较重
- 列表布局复杂

点击卡顿：
- 点击后同时做本地状态更新和云端写入
- 如果先等 Supabase 返回再切 UI，就会顿一下

### 13.3 已做优化

当前已把 `recordDecision` 改成：
- 先更新本地 UI
- 再后台异步写错词状态、学习记录、会话进度

关键文件：
- [home_notifier.dart](D:/15pro/Documents/Clodex/rapid-word-flutter/lib/src/features/home/state/home_notifier.dart)

## 14. 本地持久化与云端同步

### 14.1 本地持久化

使用：
- `shared_preferences`

保存内容包括：
- 当前词书
- 当前 tab
- 当前 reviewMode
- reviewIndex
- 本轮 known / unknown 数
- wrongWordIds

### 14.2 云端同步

当前主要同步：
- 词书
- 单词
- 错词标记
- 学习会话
- 学习记录

### 14.3 断点续刷

实现思路：
- 优先尝试从 Supabase 恢复未完成会话
- 如果云端没有，再回退到本地 `shared_preferences`

## 15. 当前项目状态

已经打通：
- Windows 本地运行
- Flutter Web 本机运行
- Supabase 登录
- Supabase 数据库
- Vercel 部署
- 手机浏览器访问
- 基础词书功能
- 基础刷词流程
- 基础错词回刷

仍需继续打磨：
- 手机端词书页视觉与排版
- 手机端错词本排版
- 手机端首页与结果页美观度
- Flutter Web 手机端流畅度
- 乱码文案彻底清理

## 16. 从零复刻建议顺序

### 第一阶段：产品和原型

1. 先确定玩法
2. 先画原型或做静态演示
3. 确认页面结构

### 第二阶段：Flutter 基础运行

1. 安装 Flutter
2. 创建/补齐 Windows 工程
3. `flutter pub get`
4. `flutter run -d windows`

### 第三阶段：本地版能用

1. 做首页
2. 做词书页
3. 做刷词页
4. 做结果页
5. 做错词本
6. 做本地持久化

### 第四阶段：接后端

1. 建 Supabase 项目
2. 跑 `schema.sql`
3. 接 API key
4. 接登录
5. 接词书读写
6. 接学习记录

### 第五阶段：Web 与部署

1. `flutter create --platforms=web .`
2. `flutter build web`
3. 安装 `vercel`
4. `vercel --prod`

### 第六阶段：手机适配

1. 补 viewport
2. 页面改单栏优先
3. 清理卡顿
4. 清理视觉问题

## 17. 命令索引

检查 Flutter：

```powershell
flutter --version
```

拉依赖：

```powershell
flutter pub get
```

分析代码：

```powershell
flutter analyze
```

补 Windows 工程：

```powershell
flutter create --platforms=windows --project-name rapid_word_flutter .
```

运行 Windows：

```powershell
flutter run -d windows
```

补 Web 工程：

```powershell
flutter create --platforms=web .
```

浏览器本地运行：

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

构建 Web：

```powershell
flutter build web --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

正式部署：

```powershell
cd build\web
vercel --prod
```

## 18. 常见报错速查

### `No pubspec.yaml file found`

原因：
- 不在 Flutter 项目根目录

解决：

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter
```

### `No Windows desktop project configured`

原因：
- 项目还没有 `windows/` 工程目录

解决：

```powershell
flutter create --platforms=windows --project-name rapid_word_flutter .
```

### `Building with plugins requires symlink support`

原因：
- Windows 没开开发者模式

解决：

```powershell
start ms-settings:developers
```

### `relation public.study_sessions does not exist`

原因：
- 还没先建表

解决：
- 先在 Supabase 执行完整 `schema.sql`

### SQL 被翻译成中文

原因：
- 浏览器翻译把 SQL 一起翻译了

解决：
- 关掉网页翻译
- 粘贴原始英文 SQL

### `404: DEPLOYMENT_NOT_FOUND`

原因：
- 打开了旧的 Vercel 临时部署链接

解决：
- 使用最新 `Production`
- 或正式别名域名，例如：
  - [https://rapid-word.vercel.app](https://rapid-word.vercel.app)

## 19. 部署更新流程

什么时候需要重新部署：
- 改了 `lib/`
- 改了 `web/index.html`
- 改了主题或交互

标准流程：

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter
flutter build web --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
cd build\web
vercel --prod
```

更新后验证：
1. 看终端里新的 `Production` 地址
2. 打开正式域名
3. 如果手机看起来没变化，用无痕模式打开
4. 必要时加临时版本标记

## 20. 文档维护建议

以后不要等项目做完再更新文档，而是按这个规则维护：

### 每次新做一项功能时补

补 3 件事：
- 做了什么
- 改了哪些文件
- 有什么坑

### 每次新报错解决后补

按这个格式记：

```text
问题：
原因：
解决：
影响文件：
```

### 每次上线后补

记：
- 上线时间
- 主要改动
- 有没有新问题

## 21. 最后建议

这个项目的关键经验，不是“功能堆得多”，而是顺序对：

- 先跑起来
- 再能用
- 再同步
- 再上线
- 最后再精修体验

如果以后你要继续做别的 App，这个顺序基本也通用。
