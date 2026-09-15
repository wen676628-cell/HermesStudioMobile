# Hermes Studio Mobile — 配置与使用说明

> Android 客户端，让你在手机上对话电脑上的 Hermes Agent：下达任务、查看执行进度、审批危险操作。
> UI 以 Hermes Agent 中文社区桌面版工作台为基底，功能对齐 Hermes Studio。
> 基底：rusty4444/hermes-android（Flutter），通信层零改动（Desktop Gateway JSON-RPC over WebSocket）。

---

## 1. 项目信息

| 项 | 值 |
|----|-----|
| 仓库 | `wen676628-cell/HermesStudioMobile`（GitHub） |
| 本地路径 | `D:\Hermes\projects\hermes-android-port\HermesStudioMobile` |
| 包名 | `com.hermesstudio.mobile` |
| 应用名 | Hermes Studio |
| 版本 | 1.0.0+1（Debug） |
| 构建产物 | `build/app/outputs/flutter-apk/app-debug.apk`（161MB） |

## 2. 技术栈

- **UI**：Flutter 3.47.4 / Dart 3.13.3，Material 3，深色工作台风格（indigo `#6366F1` 主题）
- **通信**：Desktop Gateway JSON-RPC over WebSocket（`/api/ws`），SSE 流式事件
- **状态**：flutter_riverpod、go_router
- **存储**：shared_preferences + flutter_secure_storage（Android Keystore）
- **通知**：flutter_local_notifications
- **上传**：image_picker + file_picker（10 附件 / 64MiB）

## 3. 构建环境（本机已装好）

| 组件 | 位置 | 版本 |
|------|------|------|
| Flutter | `D:\Flutter\flutter` | 3.47.4 stable |
| JDK | `C:\jdk21\jdk-21.0.12.1+1` | Temurin 21 LTS |
| Android SDK | `C:\Users\wangs\AppData\Local\Android\Sdk` | platform-36, build-tools, NDK 28.2.13676358, CMake 3.22.1 |
| Gradle | `~/.gradle/wrapper/dists/gradle-9.1.0-all` | 9.1.0 |

### 环境变量
```bash
export JAVA_HOME='C:\jdk21\jdk-21.0.12.1+1'
export ANDROID_HOME='C:/Users/wangs/AppData/Local/Android/Sdk'
export PUB_HOSTED_URL='https://pub.flutter-io.cn'          # 中国镜像
export FLUTTER_STORAGE_BASE_URL='https://storage.flutter-io.cn'  # 中国镜像
```

## 4. 构建命令

```bash
cd D:\Hermes\projects\hermes-android-port\HermesStudioMobile

# 1. 拉依赖
flutter pub get

# 2. 测试（约 940 个，全部通过）
flutter test

# 3. Debug APK
flutter build apk --debug
# 产物: build/app/outputs/flutter-apk/app-debug.apk

# 4. Release APK（需签名，见第 7 节）
flutter build apk --release
```

## 5. PC 端配置（Hermes Agent）

1. 在电脑上启动 Hermes Agent 的 Gateway：
   ```bash
   hermes serve
   ```
2. 默认端口：Gateway API `8642`、Dashboard `9119`（可在 `~/.hermes/config.yaml` 修改）。
3. 获取 API Key：运行 `hermes` 后查看 Gateway 状态，或从 `~/.hermes/auth.json` 读取。
4. 确保防火墙放行 8642/9119 端口（手机与电脑同一局域网）。

## 6. 手机端配置

1. 安装 `app-debug.apk`（需开启「允许安装未知来源」）。
2. 打开 App → 添加连接：
   - **Host**：电脑局域网 IP（如 `192.168.1.50`）
   - **Port**：`8642`
   - **API Key**：第 5 节的 key
   - **Dashboard Port**：`9119`（如需浏览记忆/技能/定时任务）
3. 保存并连接，即可对话。

## 7. Release 签名（可选）

```bash
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias hermes-studio
# 填写密码/姓名等信息

# 编辑 android/key.properties:
#   storeFile=release.jks
#   storePassword=...
#   keyAlias=hermes-studio
#   keyPassword=...

flutter build apk --release
```

## 8. 已知问题

- **Debug APK 161MB**：Debug 包未做 ABI 拆分与压缩；Release 包会显著更小。
- **后台通知**：依赖 Android 13+ 通知权限（首次启动时请求）；系统省电策略可能杀死后台进程，需在设置中允许。
- **Kotlin 增量编译已禁用**：`android/gradle.properties` 中 `kotlin.incremental=false`，否则 image_picker 在 Windows 上报缓存关闭错误。
- **GitHub 推送**：本机全局 git 配置将 `https://github.com/` 改写为 gh-proxy.com 镜像（大陆网络）；推送自有仓库需用带 token 的 URL。

## 9. 与基底（rusty4444/hermes-android）的差异

| 项 | 基底 | 本工程 |
|----|------|--------|
| 品牌 | Hermes Agent（金/黑） | Hermes Studio（indigo `#6366F1` 深色工作台） |
| 导航 | Home/Chats/Projects/Activity/More | 工作台/对话/项目/任务/更多 |
| 工作台 | Needs you/Running now/... | 需要你/正在运行/继续工作/最近完成 |
| 审批 | Allow once/Always allow/Deny | 允许一次/本次会话允许/始终允许/拒绝 |
| 工具状态 | Running/Completed/Failed | 运行中/准备中/工作中/完成/失败 |
| 界面语言 | 英文 | 全中文 |
| 版本号 | 2.1.1+2141 | 1.0.0+1 |
| 升级保护 | minimumInstalledVersionCode=2127 | 已移除（全新应用） |
| CI | 上游 release.yml/pr-quality.yml | 已移除（新项目另行配置） |
