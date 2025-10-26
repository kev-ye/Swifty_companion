# 快速设置指南

## 1. 克隆/下载项目后的首次设置

### 安装依赖

```bash
# 激活虚拟环境（如果使用）
source kivy_venv/bin/activate

# 安装新的依赖
pip install python-dotenv==1.0.0
```

或者重新安装所有依赖：

```bash
pip install -r requirements.txt
```

### 配置 API Credentials

1. 在项目根目录复制环境变量模板：
```bash
cp .env.example .env
```

2. 编辑 `.env` 文件，填入你的 42 API credentials：
```bash
nano .env  # 或使用其他编辑器
```

```env
CLIENT_ID=你的_client_id
CLIENT_SECRET=你的_client_secret
```

4. 获取 credentials：访问 https://profile.intra.42.fr/oauth/applications

## 2. 运行程序

```bash
cd src
python3 main.py
```

## 3. Git 初始化（如果需要）

```bash
# 初始化 Git 仓库
git init

# 添加所有文件（.env 会自动被忽略）
git add .

# 查看状态，确认 .env 没有被添加
git status

# 提交
git commit -m "Initial commit: Swift Companion"
```

## 4. 验证配置

确保以下文件存在且正确：

✅ `.env` - 包含真实的 credentials（**不要提交到 Git**）  
✅ `.env.example` - 模板文件（可以提交）  
✅ `src/config.py` - 配置管理器（从根目录读取 .env）  
✅ `src/api.py` - 已更新为使用 config  

## 5. 安全检查

在提交到 Git 前，确认：

```bash
# 检查 .env 是否在 .gitignore 中
cat .gitignore | grep ".env"

# 确认 .env 不会被 Git 追踪
git status | grep ".env"
# 应该看不到 .env 文件
```

## 常见问题

### Q: 运行时出现 "Missing required environment variables" 错误

A: 确保：
1. `.env` 文件存在于项目根目录
2. `.env` 文件包含 `CLIENT_ID` 和 `CLIENT_SECRET`
3. credentials 没有多余的空格或引号

### Q: ModuleNotFoundError: No module named 'dotenv'

A: 安装 python-dotenv：
```bash
pip install python-dotenv==1.0.0
```

### Q: 如何在新电脑上设置

A: 
1. 克隆项目
2. 复制 `.env.example` 为 `.env`（在项目根目录）
3. 填入你的 credentials
4. 安装依赖：`pip install -r requirements.txt`
5. 运行：`cd src && python3 main.py`

