# Flutter 项目骨架

这是基于当前快速刷词原型整理出来的 Flutter 跨端项目骨架，目标是继续演进成可发布的电脑 / 手机互通应用。

## 当前已包含

- 应用入口、主题和基础布局
- 首页、词书页、刷词页、结果页、错词本页
- 示例词书和示例单词数据
- `Supabase` 初始化、配置读取和仓库层骨架
- `Supabase Auth` 登录页与会话判断
- `Riverpod` 状态层
- 学习会话与学习记录写入骨架
- 首页统计读取骨架

## 当前状态

目前首页主流程已经迁到 `Riverpod`：

- 当前词书选择
- 整本刷 / 错词回刷
- `认识 / 不认识` 判定
- 本轮结果页状态
- 新建词书
- 手动加词
- 批量导入
- 编辑词书
- 编辑单词
- 删除单词
- 云端优先、失败回退到本地 mock
- 开始刷词时创建 `study_sessions`
- 每次点击 `认识 / 不认识` 时写入 `study_records`
- 本轮结束时回写会话汇总
- 首页会优先读取云端统计：今日已刷、总学习轮次、识别率、错词回刷轮次

核心文件：

- `lib/src/features/home/state/home_state.dart`
- `lib/src/features/home/state/home_notifier.dart`
- `lib/src/features/home/state/home_provider.dart`
- `lib/src/features/home/home_page.dart`

## Supabase 配置

建议用 Dart define 传入：

```bash
flutter run -d windows ^
  --dart-define=SUPABASE_URL=https://your-project.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=your-publishable-or-anon-key
```

数据库 SQL 文件路径：

- `D:\15pro\Documents\Clodex\rapid-word-flutter\supabase\schema.sql`

## 当前限制

这台机器目前没有可用的 `flutter` 命令，所以我还没法在本机执行：

- `flutter pub get`
- `flutter run`
- `flutter analyze`

也就是说，这一版已经是可继续开发的代码结构，但还没有在当前机器上实跑验证。

## 下一步建议

1. 安装 Flutter 后先跑 `flutter pub get`、`flutter analyze`、`flutter run -d windows`
2. 把 `BooksRepository` 继续扩成真正的学习记录与统计读写
3. 把登录后的用户数据、词书和错词记录完整落到 Supabase
