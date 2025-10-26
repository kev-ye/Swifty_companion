import requests, time
from kivy.storage.jsonstore import JsonStore
from config import CLIENT_ID, CLIENT_SECRET, API_BASE, TOKEN_URL

store = JsonStore("token_store.json")

def get_token():
    # should check later
    if store.exists("auth"):
        token = store.get("auth")
        if time.time() < token["created_at"] + token["expires_in"]:
            return token["access_token"]
    return fetch_new_token()

def fetch_new_token():
    data = {
        "grant_type": "client_credentials",
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET
    }
    res = requests.post(TOKEN_URL, data=data)
    res.raise_for_status()

    token_data = res.json()
    token_data["created_at"] = time.time()
    store.put("auth", **token_data)
    return token_data["access_token"]

def get_user(login):
    token = get_token()
    headers = {"Authorization": f"Bearer {token}"}

    res = requests.get(f"{API_BASE}/users/?filter[login]={login}", headers=headers)
    res.raise_for_status()

    if not (user := res.json()):
        raise Exception(f"User: {login} not found")

    res = requests.get(f"{API_BASE}/users/{user[0]['id']}", headers=headers)
    res.raise_for_status()

    return res.json()
