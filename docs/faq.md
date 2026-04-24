# 问题排查 FAQ

## 1. `No pubspec.yaml file found`

原因：
- 不在 Flutter 项目根目录

解决：

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter
```

## 2. `No Windows desktop project configured`

解决：

```powershell
flutter create --platforms=windows --project-name rapid_word_flutter .
```

## 3. `Building with plugins requires symlink support`

解决：

```powershell
start ms-settings:developers
```

然后打开开发者模式。

## 4. `relation public.study_sessions does not exist`

原因：
- 还没先建表

解决：
- 在 Supabase 执行完整 `schema.sql`

## 5. SQL 被翻译成中文

原因：
- 浏览器翻译把 SQL 也翻译了

解决：
- 关闭网页翻译
- 粘贴原始英文 SQL

## 6. `404: DEPLOYMENT_NOT_FOUND`

原因：
- 打开了失效的旧临时部署地址

解决：
- 重新 `vercel --prod`
- 用最新 `Production` 或正式别名域名

## 7. 手机上页面没变化

先排查：

1. 有没有重新 `flutter build web`
2. 有没有重新 `vercel --prod`
3. 打开的是不是旧链接
4. 是否用无痕模式验证过

## 8. 点击刷词按钮时有卡顿

原因：
- 云端写入阻塞了 UI

解决：
- 后台异步写 Supabase
- 先切页面，再同步数据
