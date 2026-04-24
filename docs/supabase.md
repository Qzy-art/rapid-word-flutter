# Supabase 接入

> 本节目标：创建 Supabase 项目、跑通数据库、拿到 Flutter 所需配置。

## 你会得到什么

看完这一节，你会完成：

- Supabase 项目创建
- 数据库表创建
- `Project URL` 和 `Publishable key` 获取
- Flutter 项目成功连接 Supabase

## 第一步：创建项目

打开：

[https://supabase.com/dashboard](https://supabase.com/dashboard)

步骤：

1. 登录
2. 创建新项目
3. 记住项目名和地区

## 第二步：创建数据库表

本地 SQL 文件：

- `supabase/schema.sql`

进入 Supabase 后台：

1. 打开项目
2. 进入 `SQL Editor`
3. 粘贴 `schema.sql`
4. 点击 `Run`

## 第三步：获取 API 配置

需要两个值：

- `Project URL`
- `Publishable key`

注意：

- URL 要写成：

```text
https://你的项目.supabase.co
```

- 不要写成：

```text
https://你的项目.supabase.co/rest/v1/
```

- 前端只能用 `Publishable key`
- 不要用 `Secret key`

## 第四步：在 Flutter 里传入配置

当前项目通过 `--dart-define` 传入：

```powershell
flutter run -d windows --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-publishable-key
```

## 常见问题

### `relation public.study_sessions does not exist`

原因：
- 还没先创建表，就直接改表

解决：
- 先执行完整 `schema.sql`

### SQL 被翻译成中文

表现：
- SQL 编辑器里出现“修改 表 … 如果不存在则添加列 …”

原因：
- 浏览器翻译把 SQL 一起翻译了

解决：
- 关闭网页翻译
- 粘贴原始英文 SQL

### 邮箱确认链接打不开

常见原因：
- 跳转地址不适合当前 Flutter Web / 桌面环境

建议处理方式：

1. 先去 Supabase 后台看 `Confirmed at`
2. 如果已确认，就别再纠结邮箱链接
3. 如果只是忘记密码，直接走 `password recovery`

## 完成标志

到这里为止，你应该已经能做到：

- Supabase 后台能看到你的项目
- `schema.sql` 已执行成功
- 你手里已经有 `Project URL` 和 `Publishable key`
- Flutter 能带着这两个值启动
