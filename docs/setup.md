# 环境搭建

> 本节目标：把 Flutter 本地环境搭起来，并能成功运行 Windows 版。

## 你会得到什么

看完这一节，你会完成：

- Flutter 可用
- 项目依赖拉取成功
- Windows 工程补齐
- Windows 本地运行成功

## 需要的环境

最少需要：

- Flutter SDK
- Git
- PowerShell
- Visual Studio 2022 的 Windows Desktop C++ 相关组件
- Chrome 或 Edge

如果以后要打 Android 包，再补：

- Android Studio
- Android SDK

## 第一步：检查 Flutter

```powershell
flutter --version
```

如果命令找不到，再查：

```powershell
where.exe flutter
```

正常应该能看到类似：

```text
D:\flutter\bin\flutter.bat
```

## 第二步：进入项目并拉依赖

```powershell
cd D:\15pro\Documents\Clodex\rapid-word-flutter
flutter pub get
```

成功后通常会看到：

```text
Got dependencies!
```

## 第三步：补 Windows 工程

如果项目没有 `windows/` 目录：

```powershell
flutter create --platforms=windows --project-name rapid_word_flutter .
```

注意：

- 如果当前目录名不符合 Dart 包命名规则，`flutter create` 可能报包名错误
- 用 `--project-name rapid_word_flutter` 可以绕开这个问题

## 第四步：打开开发者模式

如果运行时报 symlink 相关错误：

```powershell
start ms-settings:developers
```

然后在系统设置里打开“开发者模式”。

## 第五步：运行 Windows 版

```powershell
flutter run -d windows
```

## 常见报错

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
- 打开开发者模式

## 完成标志

到这里为止，你应该已经能做到：

- 在项目根目录执行 `flutter run -d windows`
- Windows 版应用能弹出来
