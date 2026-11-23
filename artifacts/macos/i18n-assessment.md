# OpenBCI GUI 中英文切换改造评估

> 评估对象：`/Users/zdeer/Desktop/OpenBCI_GUI`（分支 `build/macos-arm64-export`，基于 `e23869e7`）
> 评估日期：2026-11-22
> 结论：**可行，但不能直接替换字符串**。当前版本没有 i18n 框架；且有多处代码把“显示文案”当状态值使用，必须先解耦，否则翻译后会出现启动/停止、网络流、阻抗模式等行为异常。

---

## 0. 结论摘要

| 项目 | 结论 |
|---|---|
| 当前是否支持中英切换 | **不支持**，界面文案全部硬编码英文 |
| 是否可行 | **可行**，建议分三期实施 |
| 最大技术风险 | 6 处“文案即逻辑”耦合；现有字体不含中文字形；固定宽度布局 |
| 是否要改源码 | **要**，不是系统语言设置能解决的 |
| 建议默认语言 | 英文（保持现有行为），首次启动可选跟随系统语言 |
| 切换方式 | **保存设置 + 提示重启**（运行时重建整套 ControlP5 UI 风险高） |
| 日志是否翻译 | **建议不翻译**（564 条日志，保持英文便于排障与社区支持） |
| 完整改造估算 | **5–7 人日**（本 Agent 估算 · D，不含术语评审与多轮截图走查） |
| MVP 估算 | **2–2.5 人日**（本 Agent 估算 · D） |

---

## 1. 勘察方法与证据等级

- 扫描 `OpenBCI_GUI/*.pde` 共 **83** 个文件，按字符串所在函数上下文分类为：界面标签、提示/描述、弹窗、下拉项、枚举显示名、日志、内部 ID/路径。
- 对关键文件逐段实读，确认状态判断与显示文案的耦合。
- 标注约定：
  - `[来源: 源码实读 · A]`：可直接在源码中复现的事实。
  - `[本 Agent 推理 · D]`：基于源码的改造建议或估算，未经运行验证。
- 统计口径是“字符串出现次数”，不是最终词条数；同一英文词在多个文件出现会重复计数，术语表阶段再合并去重。

---

## 2. 现状数据

| 指标 | 数量 | 说明 |
|---|---:|---|
| `.pde` 文件 | 83 | 全部在 `OpenBCI_GUI/` |
| 含界面候选文案的文件 | 31 个直接文案 + 6 个枚举/弹窗文件 | 其余为数据/日志/串口/存储逻辑 |
| 直接界面候选字面量 | 190 处 / 155 条唯一 | 含按钮、标题、`text()`、`addItem()`、`setText()`；少量控件 ID/默认值需人工复核 |
| `setDescription()` 悬停提示 | 61 条 | 全部英文，用户可见 |
| `getCaptionLabel().setText("…")` | 34 处 | 按钮/下拉当前值 |
| 枚举构造器显示字符串 | 237 条 / 170 条唯一 | 其中约 60 条是纯数字/单位；约 110 条是词/短语，含解剖名、板卡名、SD 模式字母等 |
| `String[]` 下拉标签数组 | 20 组 / 约 100 项 | 文件时长、增益、输入类型、FFT/加速度/模拟读取/头部图/频谱图等 |
| `new PopupMessage(…)` | 15 处 | 标题 + 正文约 30 条 |
| 日志类字符串 | 564 条 | 建议保持英文 |
| `createFont("Arial", …)` | 4 处 | `ConsoleLog.pde:72,101`、`FilterUI.pde:542`、`Widget.pde:556` |
| 全局字体 | 19 个（`f1..f5`、`h1..h5`、`p0..p6/p13/p15`） | `OpenBCI_GUI.pde:352-376` |
| `GuiSettingsValues` 字段 | 3 个 | 新增 `language` 需迁移旧配置 |

---

## 3. 必须先解耦的“文案即逻辑”点（阻断项）

> 这些位置如果只做字符串替换，会把“显示语言”变成“程序状态”，直接破坏功能。必须先改成布尔/枚举/稳定 ID，再做翻译。

| # | 文件:行 | 当前写法 | 翻译后的后果 | 建议改法 |
|---|---|---|---|---|
| 1 | `ControlPanel.pde:2960` | `getInitSessionButtonText().equals("START SESSION")` 判断会话是否运行 | 中文“开始会话”不等于该常量，按钮永远进入 stop 分支或无法启动 | 增加 `boolean sessionActive`（或 `SessionState` 枚举），按钮文案只负责显示 |
| 2 | `CytonImpedanceEnums.pde:27` | `label.equals("Impedance")` | 中文“阻抗”导致 `getIsImpedanceMode()` 永远 false | 用枚举身份 `this == IMPEDANCE` 或显式布尔字段 |
| 3 | `CytonImpedanceEnums.pde:66` | `label.equals("Anatomical")` | 中文“解剖位置”导致通道/解剖显示切换失效 | 用枚举身份或显式布尔字段 |
| 4 | `DataWriterBF.pde:26,30,34` | `label.equals("Default"/"Custom"/"None")` | 中文标签导致 BrainFlow 输出目录判断失效 | 用枚举身份或显式布尔字段 |
| 5 | `FilterEnums.pde:93` | `name.equals("Active")` | 中文“启用”导致滤波器通道启用判断失效 | 用枚举身份或显式布尔字段 |
| 6 | `W_Networking.pde:68` + `:930/1173` + `NetworkStreamOut.pde:192` | `dataTypes` 列表同时用于下拉显示、`indexOf("FFT")`、`dataType.equals("TimeSeriesRaw")` 等 | 翻译下拉项后，网络流类型匹配全部失效，UDP/LSL/OSC/Serial 输出异常 | 拆成 `dataTypeIds`（英文稳定 ID）+ `dataTypeLabels`（本地化显示） |
| 7 | `W_Networking.pde:1199-1205` 等 | `protocolMode` 内部值 `"UDP"/"LSL"/"OSC"/"Serial"` 被大量 `equals` 比较 | 若把协议下拉显示值直接翻译，协议分支失效 | 保持内部 `Protocol` 枚举/ID；显示名单独映射 |
| 8 | `TopNav.pde:511` | 用按钮 caption 文本与 `stopButton_pressToStop_txt` 比较 | 只要常量与按钮文案同步翻译，暂时安全；但仍是脆弱设计 | 建议改为 `isStreaming` 状态判断 |
| 9 | `ControlPanel.pde:412` | `settings.controlEventDataSource = str` 保存的是菜单 headline（显示文案） | 目前只用于启动输出消息，风险低；若后续用作文案判断会出问题 | 记录数据源枚举 ID，不用显示文案 |
| 10 | `Widget.pde:566` | 从按钮 caption 解析通道号 | 通道号保持数字，不受翻译影响 | 保持数字；不要翻译为“通道 1” |

**结论**：第 1–6 项是硬阻断，必须在翻译前完成；第 7–10 项建议一并整理，降低后续维护风险。

---

## 4. 字体与渲染

### 4.1 现状

- 现有字体：Montserrat、Raleway、OpenSans，**均不含 CJK 字形** `[来源: 源码实读 · A]`。
- 全局字体初始化在 `OpenBCI_GUI.pde:352-376`；另有 4 处直接 `createFont("Arial", …)`。
- `PopupMessage` 使用 `p0/p1/p3`；`ConsoleLog` 使用 Arial；`Widget` 通道按钮使用 Arial；`FilterUI` 部分使用 Arial。

### 4.2 建议

1. 打包 **Noto Sans SC**（OFL 许可）Regular + SemiBold，放入 `OpenBCI_GUI/data/fonts/`。
   - 完整字体约 10–16 MB；可子集化到界面常用字符，但用户文件名/设备名可能含中文，建议保留完整字体。
2. 中文模式下让 `f1..f5`、`h1..h5`、`p0..p6` 全部指向 Noto Sans SC 对应字号。
3. 替换 4 处 Arial：
   - `ConsoleLog.pde:72,101`
   - `FilterUI.pde:542`
   - `Widget.pde:556`
4. 弹窗换行：`PopupMessage` 使用 `text(msg, x, y, w, h)` 的自动换行；中文没有空格，需实测换行效果，长句建议手动插入 `\n` 或做 CJK 换行辅助。
5. 高 DPI：现有 `f2`/`f5` 对 Retina 有特殊字号；中文字形宽高比不同，需在 1x/2x 下分别截图检查。
6. 字体回退：若某字形缺失，Processing/AWT 可能回退到系统字体；建议在中文模式统一显式指定 CJK 字体，避免混排。

---

## 5. 语言开关与设置持久化

### 5.1 建议方案

- `GuiSettingsValues` 增加 `String language = "en"`（或 `LanguageEnum`）。
- `GuiSettings.valueKeys` 当前使用**严格键集合相等**校验；旧 `GuiWideSettings.json` 没有 `language` 会被判为不兼容并重置，可能丢掉 `expertMode` 等设置。必须改为**向后兼容迁移**：
  - 允许缺失 `language`，默认 `"en"`；
  - 或读取旧 JSON 后补齐字段再保存。
- 设置面板新增「Language / 语言」下拉（`TopNav.ConfigSelector` 或顶部导航新增按钮）。
- 切换后保存设置，弹窗提示「需要重启生效 / Restart required」，用户重启应用。
- 不建议运行时重建 UI：`TopNav`、`ControlPanel`、19 个 widget 的 ControlP5 对象都在 `setup()` 中构造，运行时重建的引用和事件回调风险高。

### 5.2 默认语言

- 建议默认英文，保持与上游一致。
- 可选：首次启动读取 `Locale.getDefault().getLanguage()`，若为 `zh` 则默认中文，但必须写入设置文件，避免每次启动变化。

---

## 6. 逐文件改造清单

> “需翻译/判定”是字符串出现次数的粗略量级，不是最终词条数。`保留` 表示技术名/单位/解剖名/内部 ID，不建议翻译。

### 6.1 基础设施

| 文件 | 界面内容 | 需翻译/判定 | 改造内容 | 风险 |
|---|---|---:|---|---|
| `Localization.pde`（新增） | 词表 + `t()` + 语言枚举 | — | 新建翻译层、键命名、缺词回退 | 低 |
| `OpenBCI_GUI.pde` | 启动信息、窗口标题、数据流按钮常量 | ~12 | 字体加载、标题、启动错误、`stopButton_*_txt` | 中（字体） |
| `GuiSettings.pde` | 设置持久化 | ~3 | `language` 字段、`valueKeys` 迁移、应用设置 | 中（旧配置） |
| `TopNav.pde` | 顶部导航、Settings/Tutorials 面板 | ~50 | 25 标签 + 24 tooltip + 1 弹窗 + 语言开关 | 高（布局） |
| `ControlPanel.pde` | 数据源、串口/BLE/Wi-Fi、会话、网络、SD、Radio Config | ~80 | 25 `text()` + 41 标签 + 13 tooltip + 菜单项 | 高（最大文件） |
| `SessionSettings.pde` | 20 组下拉标签数组 | ~100 项 | 标签词条化，数值/单位保留 | 中 |
| `WidgetManager.pde` | 19 个 widget 标题 | 19 | `setTitle(t(…))` | 低 |
| `Widget.pde` | 通道选择、绘图 | ~3 | `"Channels"`、Arial 字体 | 低 |
| `CustomCp5Classes.pde` | 自定义控件/菜单 | 0 | 字体传递即可 | 低 |
| `PopupMessage.pde` | 弹窗默认值 | 3 | `Error`/`OK`/`Empty Popup`、字体 | 低 |
| `ConsoleLog.pde` | 控制台按钮/文本区 | ~6 | 4 个按钮 + 2 处 Arial | 低 |
| `FilterUI.pde` | 滤波器设置 | ~10 | 5 个表头 + Start/Stop Hz + 字体 | 中（布局） |
| `EmgSettingsUI.pde` | EMG 设置弹窗 | ~30 | 7 列名 + Save/Load/Reset + `Channel N` + 枚举 | 中 |
| `ADS1299SettingsController.pde` | 硬件设置 | ~15 | 7 标签 + 3 弹窗 + 4 tooltip + 枚举 | 中 |
| `CytonElectrodeStatus.pde` | 电极状态 | ~3 | `Test`、tooltip；解剖名保留 | 低 |

### 6.2 弹窗、枚举与边缘文件

| 文件 | 界面内容 | 需翻译/判定 | 备注 |
|---|---|---:|---|
| `Extras.pde` | Windows/Java 兼容弹窗 | 4 | 2 个弹窗 |
| `BoardGanglion.pde` | Ganglion 固件警告 | 4 | 2 个弹窗 |
| `BoardBrainflow.pde` | 数据流错误 | 2 | 1 个弹窗 |
| `BoardCyton.pde` | SD 卡模式 | 9 | `Do not write to SD...`、`5 minute maximum` 等 |
| `BoardBrainFlowStreaming.pde` | 板卡名 | 0 | Cyton/CytonDaisy/Ganglion/Synthetic 保留 |
| `CytonImpedanceEnums.pde` | Live/Impedance、Channel/Anatomical、间隔 | ~6 | **先解耦逻辑** |
| `DataWriterBF.pde` | Default/Custom/None | 3 | **先解耦逻辑** |
| `FilterEnums.pde` | BandStop/BandPass、All/Per Channel、滤波器类型 | ~10 | **先解耦 `isActive()`**；Butterworth 等保留 |
| `FocusEnums.pde` | Concentration/Relaxation/Regression | ~6 | 翻译词义 |
| `EmgSettingsEnums.pde` | 时间/电压/系数 | ~0–3 | 绝大多数是数值+单位，保留 |
| `SignalCheckThresholds.pde` | `%` | 0 | 保留 |

### 6.3 Widget 文件

| 文件 | 主要界面文案 | 需翻译/判定 | 风险 |
|---|---|---:|---|
| `W_Networking.pde` | Stream 1–4、Data Type、OSC/UDP/LSL/Serial、IP/Port、按钮 | ~40 | **高（dataTypes/protocolMode 逻辑）** |
| `W_Accelerometer.pde` | Accel. On/Off、X/Y/Z、g | ~10 | 低 |
| `W_AnalogRead.pde` | Analog Read On/Off | ~5 | 低 |
| `W_DigitalRead.pde` | Digital Read On/Off | ~5 | 低 |
| `W_PulseSensor.pde` | BPM、IBI、mS | ~7 | 低（单位保留） |
| `W_CytonImpedance.pde` | Thresholds、Check All、弹窗 | ~15 | 中 |
| `W_Playback.pde` | Playback File、v4→v5 转换弹窗 | ~6 | 低 |
| `W_FFT.pde` | Smoothing/UnfiltFilt、下拉 | ~8 | 低 |
| `W_TimeSeries.pde` | 弹窗、tooltip、下拉 | ~8 | 低 |
| `W_Spectrogram.pde` | Time、Frequency (Hz) | ~4 | 低 |
| `W_HeadPlot.pde` | `R` | ~1 | 保留/确认含义 |
| `W_BandPower.pde` | `Power — (uV)^2 / Hz` | ~2 | 低 |
| `W_Marker.pde` | Insert、窗口/量程 | ~5 | 低 |
| `W_EMG.pde` | EMG Settings 按钮 | ~3 | 低 |
| `W_EMGJoystick.pde` | EMG Settings、Channel 1–16 | ~20 | 低（通道名可保留） |
| `W_GanglionImpedance.pde` | Start/Stop Impedance Check | ~4 | 低 |
| `W_PacketLoss.pde` | Session/Stream length、窗口 | ~5 | 低 |
| `W_Focus.pde` | 指标/分类/阈值枚举 | ~10 | 低 |
| `W_Template.pde` | Design Your Own Widget! | ~2 | 可选（开发者模板） |
| `AuditoryNeurofeedback.pde` | Turn Audio On/Off、Use Band Powers | ~6 | 低 |

### 6.4 数据与构建

| 路径 | 改造 |
|---|---|
| `OpenBCI_GUI/data/fonts/NotoSansSC-*.otf` | 新增 CJK 字体（约 10–16 MB） |
| `artifacts/macos/export-macos-arm64.sh` | 不需要改；重新导出即可 |
| `artifacts/macos/launch-smoke.sh` | 增加中/英两种语言冒烟参数（可选） |

**涉及文件总数估算**：新增 1 个，修改约 **35–40 个**（含 19 个 widget、6 个枚举/设置文件、核心 10 余个）`[本 Agent 估算 · D]`。

---

## 7. 术语表（建议稿）

### 7.1 保留英文（不翻译）

| 类别 | 词条 |
|---|---|
| 品牌/产品 | OpenBCI, Cyton, CytonDaisy, Ganglion, BrainFlow, Ultracortex |
| 硬件/协议 | ADS1299, SRB1, SRB2, BIAS, EEG, EMG, ECG, EOG, AUX, FFT, LSL, OSC, UDP, IP, Port, COM, BLE, Wi-Fi, SD |
| 单位/符号 | µV/uV, Hz, sec, ms, BPM, IBI, dB, %, g |
| 解剖位置 | Fp1, Fp2, C3, C4, P3, P4, P7, P8, O1, O2, T7, T8, F3, F4, F7, F8 |
| 算法/滤波器名 | Butterworth, Chebyshev, Bessel |
| 内部 ID/文件名 | `TimeSeriesRaw`, `TimeSeriesFilt`, `BandPower`, `Accel/Aux`, `Default/Custom` 等内部值（显示层另映射） |

### 7.2 建议翻译（核心）

| 英文 | 中文 | 备注 |
|---|---|---|
| Data Source | 数据源 | |
| CYTON (live) | Cyton（实时） | 保留品牌名 |
| GANGLION (live) | Ganglion（实时） | |
| PLAYBACK (from file) | 回放（文件） | |
| SYNTHETIC (algorithmic) | 合成（算法） | |
| STREAMING (from external) | 流式（外部） | |
| Serial Connect | 串口连接 | |
| Serial/COM Port | 串口/COM 端口 | |
| BLE Devices | 蓝牙设备 | |
| Wi-Fi Shields | Wi-Fi 模块 | |
| Pick Transfer Protocol | 选择传输协议 | |
| Session Data | 会话数据 | |
| Channel Count | 通道数 | |
| Sample Rate | 采样率 | |
| Max File Duration | 最大文件时长 | |
| Playback File | 回放文件 | |
| Write to SD Card? | 写入 SD 卡？ | |
| Radio Configuration | 无线电配置 | |
| Start Session / Stop Session | 开始会话 / 停止会话 | **先解耦状态判断** |
| Start Data Stream / Stop Data Stream | 开始数据流 / 停止数据流 | 与常量同步 |
| Settings | 设置 | |
| Help | 帮助 | |
| Issues | 问题反馈 | |
| Shop | 商店 | |
| Update | 更新 | |
| Layout | 布局 | |
| Filters | 滤波器 | |
| Expert Mode | 专家模式 | |
| Save / Load / Default / Clear All | 保存 / 加载 / 默认 / 清除全部 | |
| Yes / No | 是 / 否 | |
| Active / Inactive | 启用 / 禁用 | 枚举显示名；内部名不变 |
| On / Off | 开 / 关 | |
| None | 无 | 网络流类型/下拉 |
| All Channels / Per Channel | 全部通道 / 每通道 | |
| Impedance | 阻抗 | |
| Live | 实时 | 阻抗模式 |
| Anatomical | 解剖位置 | |
| Notch | 陷波 | |
| BandPass / BandStop | 带通 / 带阻 | 可保留英文括号 |
| Smoothing | 平滑 | |
| Unfiltered | 未滤波 | |
| Log / Linear | 对数 / 线性 | |
| Auto | 自动 | |
| Sync | 同步 | |
| Time Series | 时域 | Widget 标题 |
| FFT Plot | FFT 图 | |
| Accelerometer | 加速度计 | |
| Cyton Signal | Cyton 信号 | |
| Playback History | 回放历史 | |
| Focus Widget | 专注度 | |
| Networking | 网络 | |
| Band Power | 频带功率 | |
| Head Plot | 头部图 | |
| EMG Joystick | EMG 摇杆 | |
| Spectrogram | 频谱图 | |
| Pulse Sensor | 脉搏传感器 | |
| Packet Loss | 丢包 | |
| Marker | 标记 | |
| Channel | 通道 | |
| Window | 窗口 | EMG 设置列名 |
| uV Limit | 电压上限 | 建议显示 `µV` |
| Creep + / Creep - | 漂移 + / 漂移 - | |
| Min ΔuV | 最小 ΔµV | |
| Low Limit | 下限 | |
| Concentration / Relaxation | 专注 / 放松 | Focus 指标 |
| Regression | 回归 | |
| Do not write to SD... | 不写入 SD 卡… | |
| 5/15/30 minute maximum | 最长 5/15/30 分钟 | |
| 1/2/4/12/24 hour maximum | 最长 1/2/4/12/24 小时 | |
| 5 Minutes / 15 minutes … / No Limit | 5 分钟 / 15 分钟 … / 不限 | 文件时长 |
| 1 sec / 10 sec / 1 min | 1 秒 / 10 秒 / 1 分钟 | 可保留数字+中文单位 |
| 30 Min. / 6 Min. / 3 Min. / 1.5 Min. / 1 Min. | 30 分钟 / 6 分钟 / 3 分钟 / 1.5 分钟 / 1 分钟 | |

### 7.3 需要产品确认的词

| 英文 | 选项 | 建议 |
|---|---|---|
| BandPower | 频带功率 / 保留 BandPower | 图表与社区常用英文，建议“频带功率 (BandPower)”首次出现时双语 |
| Focus | 专注度 / 专注 | 建议“专注度” |
| Marker | 标记 / 事件标记 | 建议“标记” |
| Aux | 辅助通道 / AUX | 建议保留 AUX |
| Synthetic | 合成 / 仿真 | 建议“合成” |
| Streaming | 流式 / 外部流 | 建议“流式” |
| Anatomical | 解剖位置 / 解剖名 | 建议“解剖位置” |

---

## 8. 实施阶段与工作量

> 以下为工程估算（本 Agent 估算 · D），实际取决于术语评审轮次和截图走查范围。

| 阶段 | 内容 | 估算 |
|---|---|---:|
| Phase 0 | 解耦 6 处“文案即逻辑”；确定术语表与键命名 | 1 人日 |
| Phase 1 | `Localization.pde`、字体、`GuiSettings.language`、语言开关、重启提示 | 1 人日 |
| Phase 2 | `TopNav`、`ControlPanel`、`SessionSettings`、`WidgetManager` 主界面 | 1.5 人日 |
| Phase 3 | 19 个 widget、Settings/Filter/EMG/ADS 弹窗、tooltip、popup | 1.5–2 人日 |
| Phase 4 | 中/英双模式冒烟、截图走查、布局修正、DMG 重建 | 1–1.5 人日 |
| **合计** | 完整界面翻译 | **5–7 人日** |
| MVP | Phase 0 + 1 + 主界面（不含全部 widget/弹窗） | **2–2.5 人日** |

---

## 9. 验收标准

### 9.1 功能回归

- [ ] 开始/停止会话按钮状态正确（不依赖文案比较）
- [ ] Cyton 串口/BLE/Wi-Fi、Ganglion BLE/Wi-Fi、回放、合成、流式均能启动
- [ ] 网络流四种协议（UDP/LSL/OSC/Serial）与所有数据类型正常
- [ ] 阻抗检查：Live/Impedance、Channel/Anatomical 切换正确
- [ ] 滤波器：All/Per Channel、BandPass/BandStop、类型/阶数正确
- [ ] EMG 设置保存/加载/重置
- [ ] 硬件设置保存/加载/发送
- [ ] 旧 `GuiWideSettings.json` 升级后不丢 `expertMode` 等字段
- [ ] 语言切换后重启生效，二次启动保持所选语言

### 9.2 渲染检查

- [ ] 中文无方框/豆腐块
- [ ] 按钮、下拉、表头、弹窗无截断/重叠
- [ ] 长中文弹窗自动换行或手动换行正常
- [ ] 1x/2x DPI 均正常
- [ ] 英文模式与当前版本视觉基本一致（回归基线）

### 9.3 交付物

- [ ] 中/英两个 DMG（或一个带语言开关的 DMG）
- [ ] `launch-smoke.log` 中/英各一份
- [ ] 术语表与截图清单归档
- [ ] 构建脚本、校验和、README 更新

---

## 10. 风险与开放问题

### 10.1 风险

| 风险 | 影响 | 缓解 |
|---|---|---|
| 文案即逻辑未彻底解耦 | 功能异常，且难排查 | Phase 0 全局搜索 `equals("…")`、`getText()`、`indexOf("…")`；逐个改状态/ID |
| 字体体积 | DMG 增大 10–16 MB | 可子集化，但保留完整字体更稳 |
| 固定宽度布局 | 中文截断/换行 | 逐屏截图，必要时调整按钮宽度/字号 |
| 弹窗 CJK 换行 | 长句溢出 | 手动 `\n` 或 CJK 换行辅助 |
| 旧设置迁移 | 用户设置丢失 | 向后兼容读取，缺字段补默认值 |
| 上游合并冲突 | 后续升级困难 | 翻译集中在 `Localization.pde`，调用点单行替换；逻辑解耦单独提交 |
| 术语不统一 | 用户体验差 | 先定术语表，再做翻译；保留英文技术名 |

### 10.2 需要你确认的问题

1. **简体中文**即可，还是也要繁体？
2. 日志/控制台输出是否翻译？建议**保持英文**。
3. 默认语言：**英文**（推荐）还是跟随系统语言？
4. 切换方式：**重启生效**（推荐）还是要求运行时即时切换？
5. 技术词（BandPower、Notch、Impedance 等）保留英文、翻译，还是首次出现双语？
6. 范围：先做 **MVP 主界面**，还是一次做**完整界面**？

---

## 11. 证据索引

| 结论 | 证据 |
|---|---|
| 无 i18n 框架 | 全仓无 `ResourceBundle`/UI 级 `Locale`；`Locale` 仅用于数字格式化 `NetworkStreamOut.pde:69-71` |
| 字体不含 CJK | `OpenBCI_GUI.pde:352-376` 仅加载 Montserrat/Raleway/OpenSans |
| 会话状态用文案判断 | `ControlPanel.pde:2960`、`:2985`、`:3004` |
| 阻抗模式用文案判断 | `CytonImpedanceEnums.pde:27,66` |
| BrainFlow 输出用文案判断 | `DataWriterBF.pde:26,30,34` |
| 滤波器启用用文案判断 | `FilterEnums.pde:93` |
| 网络数据类型同时用于显示与逻辑 | `W_Networking.pde:68`、`:930`、`:1173`；`NetworkStreamOut.pde:192` |
| 协议模式内部值 | `W_Networking.pde:1199-1205` |
| 设置键严格校验 | `GuiSettings.pde:valueKeys` 与 `validateJsonKeys()` |
| 下拉标签数组 | `SessionSettings.pde:51,114-144` |
| 19 个 widget 标题 | `WidgetManager.pde:38-102` |
| tooltip 61 条 | 全仓 `setDescription(` |
| 弹窗 15 处 | 全仓 `new PopupMessage(` |
| Arial 直接字体 | `ConsoleLog.pde:72,101`、`FilterUI.pde:542`、`Widget.pde:556` |

---

## 12. 建议的下一步

1. 你先确认第 10.2 的 6 个问题（尤其是语言范围、日志策略、即时切换 vs 重启）。
2. 确认后我先做 **Phase 0 解耦**（不改界面文案，只把状态判断改成布尔/枚举/ID），并跑一遍英文回归，确保功能不变。
3. 再做 **Phase 1 + MVP 主界面**，出一个可切换语言、可冒烟验证的 DMG。
4. 最后按 widget/弹窗分批补全，逐屏截图验收。

> 本报告只做评估，未修改任何界面代码；当前 DMG 仍是英文版。
