# 手机适配与性能

## 手机适配核心问题

这次项目里，手机端最容易反复踩坑的部分有 3 类：

1. 页面像桌面版缩小
2. 词书页布局乱
3. 刷词按钮和滚动有卡顿

## 页面像桌面版缩小

关键原因：
- `web/index.html` 缺少 `viewport`

修复方式：

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
```

文件：
- `web/index.html`

## 词书页布局乱

表现：
- 像双栏桌面布局压缩到手机上
- 卡片互相挤压
- 文本竖排、断行

处理思路：
- 手机端单栏优先
- 当前词书单独一块
- 词书卡列表单独一块
- 词条预览单独一块

文件：
- `lib/src/features/books/books_page.dart`

## 刷词页单词要保持一行

处理方式：
- `FittedBox`
- `maxLines: 1`
- `softWrap: false`

文件：
- `lib/src/features/review/review_page.dart`

## 性能卡顿来源

### 滑动卡顿

常见原因：
- Flutter Web 在手机浏览器上比原生弱
- 页面卡片层级较多
- 渐变、圆角、列表布局较重

### 点击卡顿

更明确的原因：
- 点击后同时做本地状态更新和云端写入
- 如果先等 Supabase 返回，再切 UI，就会顿一下

## 已做优化

当前已经做过的优化：

- `recordDecision` 先更新本地 UI
- 再后台异步写错词状态、学习记录、会话进度

关键文件：
- `lib/src/features/home/state/home_notifier.dart`

## 验证当前是不是新版本

推荐做法：

- 给页面加临时版本标记，比如 `mobile-fix-v1`
- 重新 `build + vercel --prod`
- 用无痕模式打开最新 `Production` 地址验证
