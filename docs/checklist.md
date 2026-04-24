# 快速复刻清单

这份是短版执行清单，适合以后不翻长文档时直接照着做。

## 1. 环境准备

1. 安装 Flutter
2. 安装 Git
3. 安装 Visual Studio 2022（Windows Desktop C++）
4. 安装 Chrome 或 Edge

检查 Flutter：

```powershell
flutter --version
```

## 2. 进入项目

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter
flutter pub get
```

## 3. 补 Windows 工程

```powershell
flutter create --platforms=windows --project-name rapid_word_flutter .
```

## 4. 跑 Windows

```powershell
flutter run -d windows
```

## 5. 建 Supabase 项目

1. 打开 Supabase
2. 创建项目
3. 在 `SQL Editor` 执行：
   - `supabase/schema.sql`

## 6. 拿 API 配置

拿到：
- `Project URL`
- `Publishable key`

## 7. 本地带 Supabase 运行

```powershell
flutter run -d windows --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

## 8. 补 Web 工程

```powershell
flutter create --platforms=web .
```

## 9. 本地浏览器跑 Web

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

## 10. Web 打包

```powershell
flutter build web --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

## 11. 安装 Vercel

```powershell
npm i -g vercel
```

## 12. 首次部署

```powershell
cd build\web
vercel
```

## 13. 正式部署

```powershell
cd build\web
vercel --prod
```

## 14. 每次更新线上版本

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter
flutter build web --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
cd build\web
vercel --prod
```
