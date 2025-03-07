# KTV点歌系统

一个使用 Flutter 开发的现代化 KTV 点歌系统。

## 功能特点

- 歌曲搜索和浏览
- 播放列表管理
- 实时歌词显示
- 音频播放控制
- 响应式界面设计

## 开发环境要求

- Flutter SDK (3.0.0 或更高版本)
- Dart SDK (2.17.0 或更高版本)
- Android Studio / VS Code
- iOS 模拟器 / Android 模拟器

## 安装步骤

1. 安装 Flutter SDK
   ```bash
   # macOS
   brew install flutter

   # 或者从官网下载：
   # https://flutter.dev/docs/get-started/install
   ```

2. 克隆项目
   ```bash
   git clone https://github.com/yourusername/ktv.git
   cd ktv
   ```

3. 安装依赖
   ```bash
   flutter pub get
   ```

4. 运行项目
   ```bash
   flutter run
   ```

## 项目结构

```
lib/
  ├── app/              # 应用程序配置
  ├── core/             # 核心功能
  │   ├── models/       # 数据模型
  │   ├── services/     # 服务类
  │   └── utils/        # 工具函数
  ├── features/         # 功能模块
  │   ├── main_screen/  # 主屏幕
  │   ├── player/       # 播放器
  │   └── search/       # 搜索功能
  └── main.dart         # 入口文件
```

## 使用说明

1. 启动应用后，主界面分为左右两个面板
2. 左侧面板显示歌曲列表和搜索框
3. 右侧面板显示当前播放的歌曲信息和播放控制器
4. 点击歌曲可以将其添加到播放列表

## 开发计划

- [x] 基础界面框架
- [x] 歌曲列表显示
- [ ] 歌曲搜索功能
- [ ] 音频播放控制
- [ ] 歌词显示
- [ ] 播放列表管理
- [ ] 主题切换
- [ ] 设置界面

## 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情 