# Puredo

Puredo 是一个基于 SwiftUI + SwiftData 的 macOS 待办应用，并支持桌面小组件快速查看任务。

## 功能特性

- 聚焦“今日任务”列表
- 红 / 黄 / 蓝优先级
- 搜索与快速新增任务
- 浅色 / 深色主题切换
- macOS 桌面小组件（极简任务视图）

## 技术栈

- SwiftUI
- SwiftData
- WidgetKit
- Xcode 工程（`Puredo.xcodeproj`）

## 目录结构

- `Puredo/`：主应用源码
- `PuredoWidget/`：小组件扩展源码
- `Puredo.xcodeproj/`：Xcode 工程配置

## 本地运行

1. 使用 Xcode 打开 `Puredo.xcodeproj`
2. 选择 `Puredo` Scheme
3. 在 macOS 上运行

## 小组件说明

小组件通过 App Group 读取主应用写入的任务快照，并展示未完成任务的极简列表。

## CI/CD

项目已配置 GitHub Actions：

- 在 `main` 分支的 push / pull request 时执行构建
- 推送 `v1.0.0` 这类版本标签时，自动打包并发布构建产物

配置文件：`.github/workflows/ci-cd.yml`

## English README

英文版本见 `README.md`。
