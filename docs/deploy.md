# Web 与 Vercel 部署

## 为什么要部署

如果不部署：

- 手机和电脑通常要在同一个局域网
- 电脑关机后手机打不开
- 不适合长期正式使用

部署后：

- 手机外网也能访问
- 不要求和电脑同一网络
- 同一账号可以多端同步数据

## 补 Web 工程

如果没有 `web/` 目录：

```powershell
flutter create --platforms=web .
```

## 本地浏览器运行

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

## 构建 Web

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter
flutter build web --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

## 安装 Vercel

```powershell
npm i -g vercel
```

## 首次部署

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter\build\web
vercel
```

一般这样选：

- `Set up and deploy?` 选 `Y`
- `Link to existing project?` 选 `N`
- `Project name` 自己填，比如 `rapid-word`
- 其他默认即可

## 正式部署

```powershell
cd build\web
vercel --prod
```

终端里会看到：

- `Inspect: ...`
- `Production: ...`
- `Aliased: https://rapid-word.vercel.app`

长期使用时优先打开正式别名域名。

## 常见问题

### `404: DEPLOYMENT_NOT_FOUND`

原因：
- 打开了旧的临时部署地址

解决：
- 重新 `vercel --prod`
- 使用最新 `Production`
- 或直接使用正式别名域名
