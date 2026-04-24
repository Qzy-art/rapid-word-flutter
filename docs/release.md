# 上线更新清单

## 什么时候需要重新部署

只要改了这些任意一项，就要重新构建并部署：

- `lib/` 里的 Dart 页面
- `web/index.html`
- 主题和样式
- 交互逻辑

## 标准流程

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter
flutter build web --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
cd build\web
vercel --prod
```

## 上线后验证顺序

1. 登录页是否能打开
2. 首页是否正常
3. 词书页手机布局是否正常
4. 刷词页单词是否一行显示
5. 错词本是否正常滚动
6. 点击 `认识 / 不认识` 是否流畅

## 如果手机看起来没更新

按这个顺序查：

1. 终端里是否真的跑了 `vercel --prod`
2. 打开的是不是最新 `Production` 地址
3. 是否用无痕模式测试过
4. 是否加了版本标记验证
