// ---------------------------------------------------------------------------
// Localization.pde — i18n 基础设施（中英文切换）
//
// 设计原则：
// 1. 所有用户可见文案统一通过 t(key) 取，缺词回退英文。
// 2. 状态判断（会话/阻抗/网络流等）一律用布尔/枚举身份，不用 t() 的返回文案。
//    —— 见 Phase 0 已解耦的 ControlPanel.sessionActive 等。
// 3. 默认英文；中文为可选语言。
// 4. 语言切换保存到 GuiSettings，重启生效（不运行时重建 UI）。
// ---------------------------------------------------------------------------

enum Language {
    EN,
    ZH;

    public static Language fromString(String s) {
        if (s != null && s.equalsIgnoreCase("zh")) {
            return ZH;
        }
        return EN;
    }

    public String getCode() {
        return this == ZH ? "zh" : "en";
    }
}

// 全局当前语言。默认英文，由 GuiSettings 在 setup 阶段赋值。
Language currentLanguage = Language.EN;

// 词表：key -> [英文, 中文]
// MVP 主界面范围：顶部导航、控制面板、主视图标题、通用按钮。
HashMap<String, String[]> translations = new HashMap<String, String[]>();

void initLocalization() {
    // 主视图 / 顶部导航
    translations.put("dataSource",            new String[]{"Data Source",            "数据源"});
    translations.put("cytonLive",             new String[]{"CYTON (live)",           "Cyton（实时）"});
    translations.put("ganglionLive",          new String[]{"GANGLION (live)",        "Ganglion（实时）"});
    translations.put("playbackFile",          new String[]{"PLAYBACK (from file)",   "回放（文件）"});
    translations.put("synthetic",             new String[]{"SYNTHETIC (algorithmic)", "合成（算法）"});
    translations.put("streaming",             new String[]{"STREAMING (from external)", "流式（外部）"});

    translations.put("serialConnect",         new String[]{"Serial Connect",         "串口连接"});
    translations.put("serialComPort",         new String[]{"Serial/COM Port",        "串口/COM 端口"});
    translations.put("bleDevices",            new String[]{"BLE Devices",            "蓝牙设备"});
    translations.put("wifiShields",           new String[]{"Wi-Fi Shields",          "Wi-Fi 模块"});
    translations.put("pickTransferProtocol",  new String[]{"Pick Transfer Protocol", "选择传输协议"});
    translations.put("sessionData",           new String[]{"Session Data",           "会话数据"});
    translations.put("channelCount",          new String[]{"Channel Count",          "通道数"});
    translations.put("sampleRate",            new String[]{"Sample Rate",            "采样率"});
    translations.put("radioConfiguration",    new String[]{"Radio Configuration",    "无线电配置"});

    // 会话 / 数据流按钮
    translations.put("startSession",          new String[]{"START SESSION",          "开始会话"});
    translations.put("stopSession",           new String[]{"STOP SESSION",           "停止会话"});
    translations.put("startDataStream",       new String[]{"Start Data Stream",      "开始数据流"});
    translations.put("stopDataStream",        new String[]{"Stop Data Stream",       "停止数据流"});

    // 通用
    translations.put("settings",              new String[]{"Settings",               "设置"});
    translations.put("help",                  new String[]{"Help",                   "帮助"});
    translations.put("layout",                new String[]{"Layout",                 "布局"});
    translations.put("filters",               new String[]{"Filters",                "滤波器"});
    translations.put("issues",                 new String[]{"Issues",                 "问题反馈"});
    translations.put("shop",                   new String[]{"Shop",                   "商店"});
    translations.put("update",                 new String[]{"Update",                 "更新"});
    translations.put("expertMode",            new String[]{"Expert Mode",            "专家模式"});
    translations.put("language",              new String[]{"Language",               "语言"});
    translations.put("restartRequired",       new String[]{"Restart required to apply language change.", "语言切换需重启后生效。"});
    translations.put("save",                  new String[]{"Save",                   "保存"});
    translations.put("load",                  new String[]{"Load",                   "加载"});
    translations.put("default",               new String[]{"Default",                "默认"});
    translations.put("clearAll",              new String[]{"Clear All",              "清除全部"});
    translations.put("systemControlPanel",     new String[]{"System Control Panel",   "系统控制面板"});
    translations.put("smoothingOn",            new String[]{"Smoothing On",           "平滑开"});
    translations.put("smoothingOff",           new String[]{"Smoothing Off",          "平滑关"});
    translations.put("smoothing",              new String[]{"Smoothing",              "平滑"});
    translations.put("yes",                   new String[]{"Yes",                    "是"});
    translations.put("no",                    new String[]{"No",                     "否"});
    translations.put("on",                    new String[]{"On",                     "开"});
    translations.put("off",                   new String[]{"Off",                    "关"});

    // 主视图标题（WidgetManager 的 widget 标题）
    translations.put("timeSeries",            new String[]{"Time Series",            "时域"});
    translations.put("fftPlot",               new String[]{"FFT Plot",               "FFT 图"});
    translations.put("headPlot",              new String[]{"Head Plot",              "头部图"});
    translations.put("bandPower",             new String[]{"Band Power",             "频带功率"});
    translations.put("networking",            new String[]{"Networking",             "网络"});
    translations.put("accelerometer",         new String[]{"Accelerometer",          "加速度计"});
    translations.put("analogRead",            new String[]{"Analog Read",            "模拟读取"});
    translations.put("digitalRead",           new String[]{"Digital Read",           "数字读取"});
    translations.put("pulse",                 new String[]{"Pulse",                  "脉搏"});
    translations.put("focus",                 new String[]{"Focus",                  "专注度"});
    translations.put("emg",                   new String[]{"EMG",                    "EMG"});
    translations.put("marker",                new String[]{"Marker",                 "标记"});
    translations.put("spectrogram",           new String[]{"Spectrogram",            "频谱图"});
    translations.put("packetLoss",            new String[]{"Packet Loss",            "丢包"});

    // Widget 标题补充
    translations.put("cytonSignal",           new String[]{"Cyton Signal",           "Cyton 信号"});
    translations.put("playbackHistory",       new String[]{"Playback History",       "回放历史"});
    translations.put("ganglionSignal",        new String[]{"Ganglion Signal",        "Ganglion 信号"});
    translations.put("focusWidget",           new String[]{"Focus Widget",           "专注度"});
    translations.put("emgJoystick",           new String[]{"EMG Joystick",           "EMG 摇杆"});
    translations.put("pulseSensor",           new String[]{"Pulse Sensor",           "脉搏传感器"});
    translations.put("widgetTemplate",        new String[]{"Widget Template 1",      "组件模板 1"});

    // ===== 第 1 批：控制面板 / 弹窗 / tooltip =====
    translations.put("name",                  new String[]{"Name",                    "名称"});
    translations.put("maxFileDuration",       new String[]{"Max File Duration",       "最大文件时长"});
    translations.put("location",              new String[]{"Location",                "位置"});
    translations.put("ip",                    new String[]{"IP",                      "IP"});
    translations.put("port",                  new String[]{"Port",                    "端口"});
    translations.put("playbackFileLabel",     new String[]{"PLAYBACK FILE",           "回放文件"});
    translations.put("writeToSDCard",         new String[]{"WRITE TO SD CARD?",       "写入 SD 卡？"});
    translations.put("brainflowStreamer",     new String[]{"BRAINFLOW STREAMER",      "BrainFlow 流式"});
    translations.put("enterIPAddress",        new String[]{"ENTER IP ADDRESS",        "输入 IP 地址"});
    translations.put("dataSourceUppercase",   new String[]{"DATA SOURCE",             "数据源"});
    translations.put("serialConnectUppercase",new String[]{"SERIAL CONNECT",          "串口连接"});
    translations.put("serialComPortUppercase",new String[]{"SERIAL/COM PORT",         "串口/COM 端口"});
    translations.put("bleDevicesUppercase",   new String[]{"BLE DEVICES",             "蓝牙设备"});
    translations.put("wifiShieldsUppercase",  new String[]{"WIFI SHIELDS",            "Wi-Fi 模块"});
    translations.put("pickTransferProtocolUp",new String[]{"PICK TRANSFER PROTOCOL",  "选择传输协议"});
    translations.put("sessionDataUppercase",  new String[]{"SESSION DATA",            "会话数据"});
    translations.put("channelCountUppercase", new String[]{"CHANNEL COUNT",           "通道数"});
    translations.put("sampleRateUppercase",   new String[]{"SAMPLE RATE",             "采样率"});
    translations.put("playbackHistoryUp",     new String[]{"PLAYBACK HISTORY",        "回放历史"});
    translations.put("radioConfigUppercase",  new String[]{"RADIO CONFIGURATION",     "无线电配置"});

    // 弹窗 / 输出消息（高频）
    translations.put("info",                  new String[]{"Info",                    "信息"});
    translations.put("error",                 new String[]{"Error",                   "错误"});
    translations.put("warning",               new String[]{"Warning",                 "警告"});
    translations.put("ok",                    new String[]{"OK",                      "确定"});
    translations.put("areYouSure",            new String[]{"Are You Sure?",           "确定吗？"});
    translations.put("noDataSourceSelected",  new String[]{"No DATA SOURCE selected. Please select a DATA SOURCE and retry system initiation.", "未选择数据源。请选择数据源后重试。"});
    translations.put("noSerialPort",          new String[]{"No Serial/COM port selected. Attempting to AUTO-CONNECT to Cyton.", "未选择串口。正在尝试自动连接 Cyton。"});
    translations.put("noTransferProtocol",    new String[]{"No Transfer Protocol selected. Please select your Transfer Protocol and retry system initiation.", "未选择传输协议。请选择传输协议后重试。"});

    translations.put("baudPort", new String[]{"Baud/Port", "波特率/端口"});
    translations.put("analogReadOn", new String[]{"Analog Read On", "模拟读取开"});
    translations.put("analogReadOff", new String[]{"Analog Read Off", "模拟读取关"});
    translations.put("dataStreamNoData", new String[]{"Data Streaming Error: No new data received in", "数据流错误：未收到新数据，已"});
    translations.put("defaultSettingsError", new String[]{"Default Settings Error: Valid Default Settings will be saved next system start.", "默认设置错误：下次系统启动时将保存有效的默认设置。"});
    translations.put("emgDrawError", new String[]{"EMG Settings UI: Unable to draw cp5 objects.", "EMG 设置界面：无法绘制界面对象。"});
    translations.put("unsupportedPlaybackFile", new String[]{"ERROR: Tried to load an unsupported file for playback! Please try a valid file.", "错误：尝试加载不支持的回放文件！请使用有效文件。"});
    translations.put("foundV4File", new String[]{"Found GUI v4 or earlier file. Please convert this file using the provided Python script.", "发现 GUI v4 或更早的文件。请使用提供的 Python 脚本转换此文件。"});
    translations.put("playbackHistoryJsonError", new String[]{"Found an error in UserPlaybackHistory.json. Deleting this file. Please, Restart the GUI.", "UserPlaybackHistory.json 中发现错误。正在删除此文件。请重启 GUI。"});
    translations.put("v4v5Converter", new String[]{"GUI v4 to v5 File Converter", "GUI v4 转 v5 文件转换器"});
    translations.put("oldWindows", new String[]{"Old Windows OS Detected", "检测到旧版 Windows 系统"});
    translations.put("noAdminAccess", new String[]{"OpenBCI_GUI: This application is not being run with Administrator access. This could limit the ability to connect to devices or read/write files.", "OpenBCI GUI：当前未以管理员权限运行。这可能会限制连接设备或读写文件的能力。"});
    translations.put("fftTooLarge", new String[]{"Please use Band Power instead of FFT for Serial Output. Changing data type...", "串口输出请使用频带功率（Band Power）而非 FFT。正在更改数据类型…"});
    translations.put("audioLoadError", new String[]{"AuditoryFeedback: Unable to load audio files. To enable this feature, please connect or turn on an audio device and restart the GUI.", "听觉反馈：无法加载音频文件。请连接或开启音频设备并重启 GUI。"});
    translations.put("accelAlwaysActive", new String[]{"Accelerometer is always active for BrainflowSyntheticBoard", "加速度计在 BrainflowSyntheticBoard 上始终激活"});
    translations.put("bfWindowClosed", new String[]{"BrainFlow File Streamer: Window was closed or the user hit cancel. Please select a new file location or choose Default.", "BrainFlow 文件流式：窗口已关闭或用户取消。请选择新文件位置或选择「默认」。"});
    translations.put("cytonCheckError", new String[]{"Cyton Signal Check Error: Please be patient when pressing 'Check All Channels' button!", "Cyton 信号检查错误：请耐心等待，再按「检查所有通道」按钮！"});
    translations.put("stopStreamError", new String[]{"ERROR: Exception when stopping stream. Please restart the Board and Session.", "错误：停止数据流时异常。请重启板卡和会话。"});
    translations.put("emgLoadError", new String[]{"Emg Settings: Could not load EMG settings from disk. Deleting this file...", "EMG 设置：无法从磁盘加载 EMG 设置。正在删除此文件…"});
    translations.put("emgDeleteError", new String[]{"Emg Settings: Error deleting old/broken EMG settings file! Please make sure the GUI has proper read/write permissions.", "EMG 设置：删除旧的/损坏的 EMG 设置文件出错！请确保 GUI 有正确的读写权限。"});
    translations.put("emgChannelMismatch", new String[]{"Emg Settings: Loaded EMG Settings file has different number of channels than the current board.", "EMG 设置：加载的 EMG 设置文件通道数与当前板卡不同。"});
    translations.put("openingNetGuide", new String[]{"Opening Networking Data Outputs Guide using default browser.", "正在使用默认浏览器打开网络数据输出指南。"});
    translations.put("openingNetWidgetGuide", new String[]{"Opening Networking Widget Guide using default browser.", "正在使用默认浏览器打开网络组件指南。"});
    translations.put("networkingPortError", new String[]{"Networking Error - Port:", "网络错误 - 端口："});
    translations.put("markerIpTooltip", new String[]{"Marker Widget: Enter your Marker Receiver IP Address or Port", "标记组件：输入标记接收器的 IP 地址或端口"});
    translations.put("uiObjectDescription", new String[]{"Here is the description for this UI object. It will fade in as help text when hovering over the object.", "这是该界面对象的描述。鼠标悬停时会以帮助文本淡入。"});
    translations.put("darkSchemeSoon", new String[]{"New Dark color scheme coming soon!", "新的深色配色方案即将推出！"});

    translations.put("unableConnectCyton", new String[]{"Unable to connect to Cyton. Please check hardware and power source.", "无法连接 Cyton。请检查硬件和电源。"});
    translations.put("noPlaybackFile", new String[]{"No playback file selected. Please select a playback file and retry system initiation.", "未选择回放文件。请选择回放文件后重试系统初始化。"});
    translations.put("noDataSourceSel", new String[]{"No DATA SOURCE selected. Please select a DATA SOURCE and retry system initiation.", "未选择数据源。请选择数据源后重试系统初始化。"});
    translations.put("start", new String[]{"Start", "开始"});
    translations.put("stop", new String[]{"Stop", "停止"});
    translations.put("test", new String[]{"Test", "测试"});
    translations.put("thresholds", new String[]{"Thresholds", "阈值"});
    translations.put("order", new String[]{"Order", "阶数"});
    translations.put("time", new String[]{"Time", "时间"});
    translations.put("channel", new String[]{"Channel", "通道"});
    translations.put("channels", new String[]{"Channels", "通道"});
    translations.put("type", new String[]{"Type", "类型"});
    translations.put("filter", new String[]{"Filter", "滤波器"});
    translations.put("notch", new String[]{"Notch", "陷波"});
    translations.put("serial", new String[]{"Serial", "串口"});
    translations.put("dataType", new String[]{"Data Type", "数据类型"});
    translations.put("portName", new String[]{"Port Name", "端口名称"});
    translations.put("frequencyHz", new String[]{"Frequency (Hz)", "频率 (Hz)"});
    translations.put("stream1", new String[]{"Stream 1", "数据流 1"});
    translations.put("stream2", new String[]{"Stream 2", "数据流 2"});
    translations.put("stream3", new String[]{"Stream 3", "数据流 3"});
    translations.put("stream4", new String[]{"Stream 4", "数据流 4"});
    translations.put("turnExpertOn", new String[]{"Turn Expert Mode On", "开启专家模式"});
    translations.put("turnExpertOff", new String[]{"Turn Expert Mode Off", "关闭专家模式"});
    translations.put("turnAccelOn", new String[]{"Turn Accel. On", "开启加速度"});
    translations.put("turnAccelOff", new String[]{"Turn Accel. Off", "关闭加速度"});
    translations.put("turnAudioOn", new String[]{"Turn Audio On", "开启音频"});
    translations.put("turnAudioOff", new String[]{"Turn Audio Off", "关闭音频"});
    translations.put("turnDigitalOn", new String[]{"Turn Digital Read On", "开启数字读取"});
    translations.put("turnDigitalOff", new String[]{"Turn Digital Read Off", "关闭数字读取"});
    translations.put("startImpedanceCheck", new String[]{"Start Impedance Check", "开始阻抗检查"});
    translations.put("stopImpedanceCheck", new String[]{"Stop Impedance Check", "停止阻抗检查"});
    translations.put("wifiRefreshing", new String[]{"Wifi Devices Refreshing", "正在刷新 Wi-Fi 设备"});
    translations.put("selectedWifiBoard", new String[]{"Selected WiFi Board:", "已选 Wi-Fi 板卡："});
    translations.put("auditoryFeedbackTooltip", new String[]{"Start and Stop Auditory Feedback.", "启动和停止听觉反馈。"});
    translations.put("playbackLoadError", new String[]{"Playback file load error. Try using a more recent recording.", "回放文件加载错误。请尝试使用更新的录制文件。"});
    translations.put("playbackHeaderError", new String[]{"Playback file does not contain the required header data.", "回放文件缺少所需的头部数据。"});
    translations.put("playbackHistoryMissing", new String[]{"Playback History: Selected file does not exist. Try another file or clear settings to remove this entry.", "回放历史：所选文件不存在。请尝试其他文件或清除设置以移除此条目。"});
    translations.put("playbackMissing", new String[]{"Playback: Selected file does not exist. Try another file or clear settings to remove this entry.", "回放：所选文件不存在。请尝试其他文件或清除设置以移除此条目。"});
    translations.put("saveDefaultError", new String[]{"Failed to save Default Settings during Init. Please submit an Issue on GitHub.", "初始化时保存默认设置失败。请在 GitHub 提交 Issue。"});
    translations.put("timerStartError", new String[]{"Failed to start Timer.", "无法启动定时器。"});
    translations.put("filtersFileNotSelected", new String[]{"Filters Settings file not selected.", "未选择滤波器设置文件。"});
    translations.put("noNewSettings", new String[]{"No new settings to send to board.", "没有要发送到板卡的新设置。"});
    translations.put("lslCloseError", new String[]{"Error closing network while creating LSL Stream:", "创建 LSL 流时关闭网络出错："});
    translations.put("oscCloseError", new String[]{"Error closing network while creating OSC Stream:", "创建 OSC 流时关闭网络出错："});
    translations.put("serialCloseError", new String[]{"Error closing network while creating Serial Stream:", "创建串口流时关闭网络出错："});
    translations.put("udpCloseError", new String[]{"Error closing network while creating UDP Stream:", "创建 UDP 流时关闭网络出错："});
    translations.put("channelMismatch", new String[]{"Settings Error:  Channel Number Mismatch Detected", "设置错误：检测到通道数不匹配"});
    translations.put("dataSourceMismatch", new String[]{"Settings Error: Data Source Mismatch Detected", "设置错误：检测到数据源不匹配"});
    translations.put("daisyNotAttached", new String[]{"User selected Cyton+Daisy, but no Daisy is attached. Please change Channel Count to 8 Channels.", "已选择 Cyton+Daisy，但未连接 Daisy。请将通道数改为 8。"});
    translations.put("udpConnected", new String[]{"UDP successfully connected", "UDP 连接成功"});
    translations.put("serialOpened", new String[]{"Successfully opened SERIAL/COM (", "成功打开串口/COM（"});
    translations.put("saveLoadSettingsTooltip", new String[]{"Save and Load GUI Settings! Click Default to revert to factory settings.", "保存和加载 GUI 设置！点击「默认」恢复出厂设置。"});
    translations.put("saveHwSettingsTooltip", new String[]{"Save hardware settings to file.", "将硬件设置保存到文件。"});
    translations.put("sendHwSettingsTooltip", new String[]{"Send hardware settings to the board.", "将硬件设置发送到板卡。"});
    translations.put("customCommandTooltip", new String[]{"Type a custom command and Send to board.", "输入自定义命令并发送到板卡。"});
    translations.put("clearAllTooltip", new String[]{"This will clear all user settings and playback history. You will be asked to confirm.", "这将清除所有用户设置和回放历史。系统会要求你确认。"});
    translations.put("autoscanTooltip", new String[]{"Scan through channels and connect to a nearby Cyton. This button solves most connection issues!", "扫描通道并连接附近的 Cyton。此按钮可解决大多数连接问题！"});
    translations.put("refreshBled112", new String[]{"Refreshing available Ganglions using BLED112 Dongle...", "正在使用 BLED112 Dongle 刷新可用的 Ganglion…"});
    translations.put("refreshNativeBle", new String[]{"Refreshing available Ganglions using Native Bluetooth...", "正在使用本机蓝牙刷新可用的 Ganglion…"});
    translations.put("searchBled112", new String[]{"Search for Ganglions using BLED112 Dongle is in progress.", "正在使用 BLED112 Dongle 搜索 Ganglion。"});
    translations.put("searchNativeBle", new String[]{"Search for Ganglions using Native Bluetooth is in progress.", "正在使用本机蓝牙搜索 Ganglion。"});

    translations.put("expertModeTooltip", new String[]{"Expert Mode enables advanced keyboard shortcuts and access to all GUI features.", "专家模式启用高级键盘快捷键并解锁全部功能。"});
    translations.put("startingAccel", new String[]{"Starting to read accelerometer", "开始读取加速度计"});
    translations.put("selectPlaybackFile", new String[]{"Select a file for playback", "选择要回放的文件"});
    translations.put("openingSerialPort", new String[]{"Attempting to open Serial/COM port:", "正在打开串口/COM 端口："});
    translations.put("playbackFileTooltip", new String[]{"Click to open a dialog box to select an OpenBCI playback file (.txt or .csv).", "点击打开对话框，选择一个 OpenBCI 回放文件（.txt 或 .csv）。"});
    translations.put("emgSettingsTooltip", new String[]{"Click to open the EMG Settings UI to adjust how this metric is calculated.", "点击打开 EMG 设置界面，调整该指标的计算方式。"});
    translations.put("noDeactivatePlayback", new String[]{"Deactivating channels is not possible for Playback board.", "回放板卡不支持停用通道。"});
    translations.put("ganglionFwV2", new String[]{"Detected Ganglion firmware version 2", "检测到 Ganglion 固件版本 2"});
    translations.put("ganglionFwV3", new String[]{"Detected Ganglion firmware version 3", "检测到 Ganglion 固件版本 3"});
    translations.put("emgFileNotSelected", new String[]{"EMG Settings file not selected.", "未选择 EMG 设置文件。"});
    translations.put("hwFileNotSelected", new String[]{"Hardware Settings file not selected.", "未选择硬件设置文件。"});
    translations.put("noSerialPortRetry", new String[]{"No Serial/COM port selected. Please select your Serial/COM port and retry.", "未选择串口/COM 端口。请选择串口/COM 端口后重试。"});
    translations.put("noWifiShield", new String[]{"No Wifi Shield selected. Please select your Wifi Shield and retry system initiation.", "未选择 Wi-Fi 模块。请选择 Wi-Fi 模块后重试系统初始化。"});
    translations.put("enterSessionName", new String[]{"SessionData: Enter your custom session name.", "会话数据：请输入自定义会话名称。"});
    translations.put("turnAnalogOff", new String[]{"Turn Analog Read Off", "关闭模拟读取"});
    translations.put("turnAnalogOn", new String[]{"Turn Analog Read On", "开启模拟读取"});
    translations.put("java32Detected", new String[]{"32-bit Java Detected", "检测到 32 位 Java"});
    translations.put("accelOn", new String[]{"Accel. On", "加速度开"});
    translations.put("startingSession", new String[]{"Attempting to Start Session...", "正在启动会话…"});
    translations.put("autogenSessionTooltip", new String[]{"Autogenerate a session name based on the date and time.", "根据日期和时间自动生成会话名称。"});
    translations.put("autogenSessionName", new String[]{"Autogenerated Session Name based on current date & time.", "基于当前日期和时间自动生成的会话名称。"});
    translations.put("bdfMade", new String[]{"BDF+ file has been made.", "已生成 BDF+ 文件。"});
    translations.put("boardCommError", new String[]{"Board Communication Error", "板卡通信错误"});
    translations.put("busyCheckingImpedance", new String[]{"Busy Checking Impedance", "正在检查阻抗"});
    translations.put("cannotInstantiateBoard", new String[]{"Cannot instantiate underlying board of class", "无法实例化底层板卡类"});
    translations.put("auditoryModeTooltip", new String[]{"Change Auditory Feedback mode. Use the Metric to control all notes at once, or use Band Powers to control certain notes of the chord.", "切换听觉反馈模式。用指标同时控制所有音符，或用频带功率控制特定音符。"});
    translations.put("changeDongleChannelOnly", new String[]{"Change the channel of the USB Dongle only.", "仅更改 USB Dongle 的通道。"});
    translations.put("changeCytonDongleChannel", new String[]{"Change the channel of your Cyton and USB Dongle.", "更改 Cyton 和 USB Dongle 的通道。"});
    translations.put("networkStreamTooltip", new String[]{"Click here to Start and Stop the network stream for the chosen protocol.", "点击此处启动/停止所选协议的网络流。"});
    translations.put("customWidgetTooltip", new String[]{"Click here to learn about creating your own custom OpenBCI widgets!", "点击了解如何创建自定义 OpenBCI 组件！"});
    translations.put("impedanceTooltip", new String[]{"Click here to learn more about testing the impedance on electrodes using the OpenBCI GUI. This process is different for Cyton and Ganglion. Checking impedance only works with passive electrodes.", "点击了解如何使用 OpenBCI GUI 测试电极阻抗。Cyton 和 Ganglion 的流程不同。阻抗检查仅适用于被动电极。"});
    translations.put("latencyTooltip", new String[]{"Click here to view information on how to lower the Cyton Dongle latency for your current operating system.", "点击查看如何降低当前操作系统的 Cyton Dongle 延迟。"});
    translations.put("forumTooltip", new String[]{"Click here to visit the official OpenBCI Forum.", "点击访问 OpenBCI 官方论坛。"});
    translations.put("impedanceCheckTooltip", new String[]{"Click this button to start or stop checking impedance.", "点击此按钮开始或停止检查阻抗。"});
    translations.put("accelTooltip", new String[]{"Click to activate/deactivate the accelerometer for capable boards.", "点击启用/禁用支持板卡的加速度计。"});
    translations.put("checkAllImpedanceTooltip", new String[]{"Click to check impedance on all electrodes. Please allow time for commands to be sent to the board.", "点击检查所有电极的阻抗。请留出时间将命令发送到板卡。"});
    translations.put("tutorialsTooltip", new String[]{"Click to find links to helpful online tutorials and getting started guides. Also, check out how to create custom widgets for the GUI!", "点击查看有用的在线教程和入门指南。也可了解如何为 GUI 创建自定义组件！"});
    translations.put("gotoStartTooltip", new String[]{"Click to go back to the beginning of the file.", "点击回到文件开头。"});
    translations.put("insertMarkerTooltip", new String[]{"Click to insert marker", "点击插入标记"});
    translations.put("consoleLogTooltip", new String[]{"Click to open the Console Log window.", "点击打开控制台日志窗口。"});
    translations.put("netOutputGuideTooltip", new String[]{"Click to open the Networking Data Outputs Guide in your default browser.", "点击在默认浏览器中打开网络数据输出指南。"});
    translations.put("netWidgetGuideTooltip", new String[]{"Click to open the Networking Widget Guide in your default browser.", "点击在默认浏览器中打开网络组件指南。"});
    translations.put("sampleDataTooltip", new String[]{"Click to open the folder containing OpenBCI GUI Sample Data.", "点击打开包含 OpenBCI GUI 示例数据的文件夹。"});
    translations.put("resetChannelTooltip", new String[]{"Click to reset all channel settings to default.", "点击将所有通道设置重置为默认。"});
    translations.put("toggleChannelTooltip", new String[]{"Click to toggle channel", "点击切换通道"});
    translations.put("toggleImpedanceTooltip", new String[]{"Click to toggle impedance check for this ADS pin.", "点击切换此 ADS 引脚的阻抗检查。"});
    translations.put("deleteAllSettingsTooltip", new String[]{"Clicking 'Yes' will delete all user settings and stop the session if running.", "点击「是」将删除所有用户设置，并在运行时停止会话。"});
    translations.put("checkVersionTooltip", new String[]{"Connect to internet to check GUI version. -- Local:", "联网检查 GUI 版本。-- 本地："});
    translations.put("customFilterTooltip", new String[]{"Custom Filtering: Enter your custom filter frequency.", "自定义滤波：输入自定义滤波频率。"});
    translations.put("impedanceCmdError", new String[]{"Cyton Impedance Check - Error sending impedance command to board.", "Cyton 阻抗检查 - 向板卡发送阻抗命令出错。"});
    translations.put("cytonSignalCheckError", new String[]{"Cyton Signal Check Error", "Cyton 信号检查错误"});
    translations.put("dataStreamingError", new String[]{"Data Streaming Error", "数据流错误"});
    translations.put("streamAlreadyStopped", new String[]{"Data stream is already stopped.", "数据流已停止。"});
    translations.put("streamStarted", new String[]{"Data stream started.", "数据流已启动。"});
    translations.put("streamStopped", new String[]{"Data stream stopped.", "数据流已停止。"});
    translations.put("digitalReadOn", new String[]{"Digital Read On", "数字读取开"});
    translations.put("emgApplyError", new String[]{"EMG Settings UI: Unable to apply settings. Please save EMG Settings to a new file.", "EMG 设置界面：无法应用设置。请将 EMG 设置保存到新文件。"});
    translations.put("serialConnectError", new String[]{"Error connecting to selected Serial/COM port. Make sure your board is powered up and your dongle is plugged in.", "连接所选串口/COM 端口出错。请确保板卡已上电且 Dongle 已插入。"});
    translations.put("loadSettingsError", new String[]{"Error trying to load settings file, possibly from previous GUI. Removing old settings.", "加载设置文件出错，可能是旧版 GUI 的文件。正在移除旧设置。"});
    translations.put("failedToConnectUsing", new String[]{"Failed to connect using", "无法使用以下方式连接："});
    translations.put("boardInitError", new String[]{"Failed to initialize board. Please check that the board is on and has power. See Console Log for more details.", "板卡初始化失败。请检查板卡是否开启并有电源。详情见控制台日志。"});
    translations.put("filterLoadError", new String[]{"Failed to load Filter Settings. The old/broken file has been deleted.", "加载滤波器设置失败。旧的/损坏的文件已被删除。"});
    translations.put("hwLoadError", new String[]{"Failed to load Hardware Settings.", "加载硬件设置失败。"});
    translations.put("emgSaveError", new String[]{"Failed to save EMG Settings.", "保存 EMG 设置失败。"});
    translations.put("filterSaveError", new String[]{"Failed to save Filter Settings.", "保存滤波器设置失败。"});
    translations.put("hwSaveError", new String[]{"Failed to save Hardware Settings.", "保存硬件设置失败。"});
    translations.put("streamStartError", new String[]{"Failed to start data stream. Please check hardware. See Console Log or BrainFlow Log for more details.", "启动数据流失败。请检查硬件。详情见控制台日志或 BrainFlow 日志。"});
    translations.put("filterFileNotSelected", new String[]{"Filter Settings file not selected.", "未选择滤波器设置文件。"});
    translations.put("filterApplyError", new String[]{"Filter Settings: Unable to apply settings. Please save Filter Settings to a new file.", "滤波器设置：无法应用设置。请将滤波器设置保存到新文件。"});
    translations.put("foundDongleAutoscan", new String[]{"Found a Cyton dongle, but could not connect to the board. Auto-Scanning now...", "已找到 Cyton Dongle，但无法连接板卡。正在自动扫描…"});
    translations.put("oldSettingsError", new String[]{"Found old/broken GUI settings. Please reconfigure the GUI and save new settings.", "发现旧的/损坏的 GUI 设置。请重新配置 GUI 并保存新设置。"});
    translations.put("ganglionLiveLabel", new String[]{"GANGLION (live)", "Ganglion（实时）"});
    translations.put("timerStopError", new String[]{"GUI Error: Failed to stop Timer. Please make an issue on GitHub in the GUI repo.", "GUI 错误：无法停止定时器。请在 GitHub 的 GUI 仓库提交 Issue。"});
    translations.put("guiUpToDate", new String[]{"GUI is up to date! -- Local:", "GUI 已是最新！-- 本地："});
    translations.put("guiNeedsUpdate", new String[]{"GUI needs to be updated. -- Local:", "GUI 需要更新。-- 本地："});
    translations.put("connectionStatusTooltip", new String[]{"Get connection status and the current channel of your Cyton and USB Dongle.", "获取 Cyton 和 USB Dongle 的连接状态及当前通道。"});
    translations.put("radioConfigTooltip", new String[]{"Having trouble connecting to Cyton? Click here to access Radio Configuration tools.", "连接 Cyton 遇到问题？点击此处访问无线电配置工具。"});
    translations.put("troubleshootTooltip", new String[]{"Having trouble? Start here with some general troubleshooting tips found on the OpenBCI Docs.", "遇到问题？从 OpenBCI 文档中的通用排查技巧开始。"});
    translations.put("shopTooltip", new String[]{"Head to our online store to purchase the latest OpenBCI hardware and accessories.", "前往我们的在线商店购买最新 OpenBCI 硬件和配件。"});
    translations.put("filtersTooltip", new String[]{"Here you can adjust the Filters that are applied to", "在这里可以调整应用于"});
    translations.put("layoutTooltip", new String[]{"Here you can alter the overall layout of the GUI, allowing for different container configurations with more or less widgets.", "在这里可以更改 GUI 的整体布局，配置不同容器、增减组件。"});
    translations.put("feedbackTooltip", new String[]{"If you have suggestions or want to share a bug you've found, please create an issue on the GUI's Github repo!", "如果你有建议或发现 bug，请在 GUI 的 GitHub 仓库提交 Issue！"});
    translations.put("invalidIp", new String[]{"Invalid Ip address", "无效的 IP 地址"});
    translations.put("loadHwSettingsTooltip", new String[]{"Load hardware settings from file.", "从文件加载硬件设置。"});
    translations.put("gettingStartedTooltip", new String[]{"Need help getting started? Click here to view the official OpenBCI Getting Started guides.", "需要帮助入门？点击查看 OpenBCI 官方入门指南。"});
    translations.put("networkResolveError", new String[]{"Network Error: Unable to resolve host @", "网络错误：无法解析主机 @"});
    translations.put("networkStreamStarted", new String[]{"Network Stream Started", "网络流已启动"});
    translations.put("networkStreamStopped", new String[]{"Network Stream Stopped", "网络流已停止"});
    translations.put("noBleDevice", new String[]{"No BLE device selected. Please select your Ganglion device and retry system initiation.", "未选择 BLE 设备。请选择 Ganglion 设备后重试系统初始化。"});
    translations.put("noBled112", new String[]{"No BLED112 Dongle Found", "未找到 BLED112 Dongle"});
    translations.put("noCytonDongle", new String[]{"No Cyton dongles were found.", "未找到 Cyton Dongle。"});
    translations.put("noDataSource", new String[]{"No DATA SOURCE selected. Please select a DATA SOURCE and retry system initiation.", "未选择数据源。请选择数据源后重试系统初始化。"});
}

// 翻译函数：key 找不到时回退英文（或返回 key 本身，便于发现漏词）
String t(String key) {
    if (translations == null || translations.isEmpty()) {
        return key;
    }
    String[] entry = translations.get(key);
    if (entry == null) {
        return key; // 漏词回退：返回 key 本身，便于排查
    }
    return currentLanguage == Language.ZH ? entry[1] : entry[0];
}

// 设置当前语言（由 GuiSettings 在 setup 阶段调用）
void setLanguage(Language lang) {
    currentLanguage = lang;
}

// 中文模式下，把全局字体（f*/h*/p*）重新指向 Noto Sans SC（含 CJK 字形）。
// 必须在 delayedSetup() 创建 UI 之前调用（即 setup() 主线程里）。
// 注意：字体文件 NotoSansSC-Regular.otf 已放入 data/fonts/。
void loadChineseFonts() {
    if (currentLanguage != Language.ZH) {
        return; // 英文模式保持现有 Raleway/Montserrat/OpenSans
    }
    f1 = createFont("fonts/NotoSansSC-Regular.otf", 16);
    int f2FontSize = isMac() && (displayDensity() > 1) ? 8 : 15;
    f2 = createFont("fonts/NotoSansSC-Regular.otf", f2FontSize);
    f3 = createFont("fonts/NotoSansSC-Regular.otf", 15);
    f4 = createFont("fonts/NotoSansSC-Regular.otf", 64);
    int f5FontSize = isMac() && (displayDensity() > 1) ? 6 : 12;
    f5 = createFont("fonts/NotoSansSC-Regular.otf", f5FontSize);

    h1 = createFont("fonts/NotoSansSC-Regular.otf", 20);
    h2 = createFont("fonts/NotoSansSC-Regular.otf", 18);
    h3 = createFont("fonts/NotoSansSC-Regular.otf", 16);
    h4 = createFont("fonts/NotoSansSC-Regular.otf", 14);
    h5 = createFont("fonts/NotoSansSC-Regular.otf", 12);

    p0 = createFont("fonts/NotoSansSC-Regular.otf", 24);
    p1 = createFont("fonts/NotoSansSC-Regular.otf", 20);
    p2 = createFont("fonts/NotoSansSC-Regular.otf", 18);
    p3 = createFont("fonts/NotoSansSC-Regular.otf", 16);
    p15 = createFont("fonts/NotoSansSC-Regular.otf", 15);
    p4 = createFont("fonts/NotoSansSC-Regular.otf", 14);
    p13 = createFont("fonts/NotoSansSC-Regular.otf", 13);
    p5 = createFont("fonts/NotoSansSC-Regular.otf", 12);
    p6 = createFont("fonts/NotoSansSC-Regular.otf", 10);
}
