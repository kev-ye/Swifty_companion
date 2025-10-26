"""
config.py - 配置管理
从环境变量中读取敏感配置信息
"""
import os
from pathlib import Path
from dotenv import load_dotenv

# 获取项目根目录（config.py 在 src/ 中，所以 parent.parent 是根目录）
BASE_DIR = Path(__file__).resolve().parent.parent

# 加载 .env 文件（从项目根目录）
env_path = BASE_DIR / '.env'
load_dotenv(dotenv_path=env_path)

# 42 API 配置
CLIENT_ID = os.getenv('CLIENT_ID')
CLIENT_SECRET = os.getenv('CLIENT_SECRET')

# API URLs
API_BASE = "https://api.intra.42.fr/v2"
TOKEN_URL = "https://api.intra.42.fr/oauth/token"

# 验证必需的环境变量
if not CLIENT_ID or not CLIENT_SECRET:
    raise ValueError(
        "Missing required environment variables. "
        "Please create a .env file with CLIENT_ID and CLIENT_SECRET. "
        "See .env.example for template."
    )

