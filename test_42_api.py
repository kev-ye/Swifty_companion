#!/usr/bin/env python3
"""
42 API OAuth 2.0 测试脚本

使用说明：
1. 将你的 UID 和 SECRET 填入下面的变量
2. 运行脚本获取授权 URL
3. 在浏览器中打开授权 URL 并登录
4. 从重定向 URL 中获取授权码（code 参数）
5. 使用授权码换取 access token
"""

import requests
from urllib.parse import urlparse, parse_qs

# ========== 配置 ==========
UID = 'u-s4t2ud-e2cf8fda9cbaf28ced138deca873b4903a8853323e6b0363ced40da94e662f01'
SECRET = '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'
REDIRECT_URI = 'com.example.swiftcompanion://oauth2redirect'

# ========== Endpoints ==========
AUTH_URL = 'https://api.intra.42.fr/oauth/authorize'
TOKEN_URL = 'https://api.intra.42.fr/oauth/token'
API_BASE = 'https://api.intra.42.fr/v2'

def get_authorization_url():
    """生成授权 URL"""
    params = {
        'client_id': UID,
        'redirect_uri': REDIRECT_URI,
        'response_type': 'code',
    }
    
    url = f"{AUTH_URL}?client_id={params['client_id']}&redirect_uri={params['redirect_uri']}&response_type={params['response_type']}"
    return url

def exchange_code_for_token(code):
    """用授权码换取 access token"""
    data = {
        'grant_type': 'authorization_code',
        'client_id': UID,
        'client_secret': SECRET,
        'code': code,
        'redirect_uri': REDIRECT_URI,
    }
    
    print(f"\n🔐 正在用授权码换取 token...")
    print(f"Endpoint: {TOKEN_URL}")
    print(f"Request body: {data}\n")
    
    response = requests.post(TOKEN_URL, data=data)
    
    print(f"Status Code: {response.status_code}")
    print(f"Response Headers: {dict(response.headers)}\n")
    
    if response.status_code == 200:
        result = response.json()
        print("✅ Token 获取成功!")
        print(f"Response: {result}\n")
        return result
    else:
        print(f"❌ 失败!")
        print(f"Response: {response.text}\n")
        return None

def test_api_with_token(access_token):
    """使用 token 测试 API 调用"""
    headers = {
        'Authorization': f'Bearer {access_token}'
    }
    
    # 测试获取当前用户信息
    print("📡 测试 API 调用: GET /v2/me")
    response = requests.get(f"{API_BASE}/me", headers=headers)
    
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        print("✅ API 调用成功!")
        user_data = response.json()
        print(f"User: {user_data.get('login', 'N/A')}")
        print(f"Email: {user_data.get('email', 'N/A')}")
    else:
        print(f"❌ API 调用失败: {response.text}")

if __name__ == '__main__':
    print("=" * 60)
    print("42 API OAuth 2.0 测试")
    print("=" * 60)
    
    # 步骤 1: 生成授权 URL
    print("\n📋 步骤 1: 获取授权 URL")
    auth_url = get_authorization_url()
    print(f"\n请在浏览器中打开以下 URL 并登录:")
    print(f"{auth_url}\n")
    
    # 步骤 2: 获取授权码
    print("📋 步骤 2: 获取授权码")
    print("登录后，你会被重定向到一个类似以下的 URL:")
    print(f"{REDIRECT_URI}?code=AUTHORIZATION_CODE")
    print("\n请从重定向 URL 中复制 code 参数的值，然后粘贴到下面:")
    
    code = input("请输入授权码 (code): ").strip()
    
    if not code:
        print("❌ 未提供授权码，退出")
        exit(1)
    
    # 步骤 3: 用授权码换取 token
    print("\n📋 步骤 3: 用授权码换取 token")
    token_data = exchange_code_for_token(code)
    
    if token_data and 'access_token' in token_data:
        access_token = token_data['access_token']
        expires_in = token_data.get('expires_in', 0)
        
        print(f"✅ Access Token: {access_token[:50]}...")
        print(f"✅ Expires in: {expires_in} 秒 ({expires_in // 60} 分钟)")
        
        # 步骤 4: 测试 API 调用
        print("\n📋 步骤 4: 测试 API 调用")
        test_api_with_token(access_token)
    else:
        print("❌ 无法获取 token，请检查授权码是否正确")

