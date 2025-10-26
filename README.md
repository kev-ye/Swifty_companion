# Swift Companion - 42 Student Profile Viewer

一个使用 Kivy 开发的移动应用，用于查看 42 学校学生的个人信息。

## 项目结构

```
swift_companion/
├── .env                   # 环境变量（敏感信息，不提交）
├── .env.example           # 环境变量模板
├── .gitignore             # Git 忽略规则
├── requirements.txt       # Python 依赖
├── README.md              # 项目说明
├── SETUP.md               # 设置指南
├── src/                   # 源代码
│   ├── main.py            # 主程序入口
│   ├── config.py          # 配置管理
│   ├── api.py             # API 接口
│   └── pages/             # 页面组件
│       ├── search.py      # 搜索页面
│       └── profile.py     # 个人资料页面
└── swift_companion-ios/   # iOS 项目配置
```

## 功能特性

✅ 双页面布局（搜索 + 个人资料）  
✅ 完整的错误处理  
✅ 显示用户详细信息（登录名、邮箱、电话、位置、钱包等）  
✅ 显示用户技能及等级百分比  
✅ 显示已完成的项目（通过/失败状态）  
✅ 响应式布局，适配不同屏幕尺寸  
✅ 适配 iPhone 刘海屏和底部手势区域  
✅ Token 自动管理和缓存  

## 安装依赖

### 1. 创建虚拟环境

```bash
python3 -m venv kivy_venv
source kivy_venv/bin/activate  # macOS/Linux
```

### 2. 安装依赖

```bash
pip install -r requirements.txt
```

## 运行程序

### 桌面版测试

```bash
cd src
python3 main.py
```

### iOS 版本

使用 kivy-ios 工具链构建：

```bash
toolchain build kivy pillow
toolchain create <YourApp> <directory>
```

详见 [Kivy iOS 文档](https://kivy.org/doc/stable/guide/packaging-ios.html)

## API 配置

### 1. 创建环境变量文件

复制 `.env.example` 到 `.env` 并填入你的 42 API credentials：

```bash
cp .env.example .env
```

### 2. 编辑 `.env` 文件

```bash
CLIENT_ID=your_client_id_here
CLIENT_SECRET=your_client_secret_here
```

获取 credentials：https://profile.intra.42.fr/oauth/applications

**注意：** `.env` 和 `token_store.json` 已在 `.gitignore` 中忽略，不会提交到仓库。

## 使用方法

1. 启动应用
2. 在搜索框输入 42 学生的登录名
3. 点击 "Search" 或按回车键
4. 查看学生的详细信息、技能和项目
5. 点击 "< Back" 返回搜索页面

## 项目需求

- Python 3.11+
- Kivy 2.3.1
- requests 2.32.5
- python-dotenv 1.0.0
- 网络连接（访问 42 API）
- 有效的 42 API credentials

## 注意事项

- 确保有有效的 42 API credentials
- Token 会自动缓存，避免频繁请求
- 项目只显示状态为 "finished" 的项目
- 通过的项目显示为绿色，失败的显示为红色

## License

本项目仅用于教育目的。

