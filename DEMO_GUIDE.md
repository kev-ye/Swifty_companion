# Token 管理演示指南

## 📋 演示前准备

1. **打开终端/控制台**：确保可以看到 Flutter 应用的日志输出
2. **运行应用**：使用 `flutter run` 或通过 IDE 运行
3. **准备演示场景**：确保已登录到应用

## 🎯 演示要点

### 要求 1: 不要为每个查询创建新 Token

**演示步骤：**

1. **登录应用**后，观察控制台日志：
   ```
   🔐 [Token Management] Exchanging authorization code for token...
   ✅ [Token Management] Token obtained successfully
      Token expires in: 7200 minutes
      Token preview: abc123def456ghi789...
   ```

2. **连续进行多次搜索**（例如搜索 3-5 个不同的用户）：
   - 搜索用户 1
   - 搜索用户 2
   - 搜索用户 3

3. **观察控制台日志**，每次搜索应该显示：
   ```
   🔍 [API Call] Searching for user: username1
   ✅ [Token Management] Reusing existing token
      Token expires in: 7195 minutes
      Token preview: abc123def456ghi789...
   📡 [API Call] Making request with token: abc123def456ghi789...
   ✅ [API Call] User found successfully
   ```

4. **关键点**：
   - ✅ 每次搜索都显示 "Reusing existing token"
   - ✅ Token preview 都是相同的（前 20 个字符相同）
   - ✅ 没有创建新的 token

**向评估者说明：**
> "您可以看到，我进行了多次搜索，但每次都是复用同一个 token。控制台显示 'Reusing existing token'，并且 token preview 都是相同的，证明没有为每个查询创建新 token。"

---

### 要求 2: Token 过期时自动刷新

**演示步骤：**

#### 场景 A: Token 即将过期时自动刷新（提前 5 分钟）

1. **说明机制**：
   > "系统会在 token 过期前 5 分钟自动刷新，确保应用持续可用。"

2. **观察正常情况**：
   - 当 token 还有超过 5 分钟有效期时，会显示：
     ```
     ✅ [Token Management] Reusing existing token
        Token expires in: 100 minutes
     ```

#### 场景 B: Token 已过期后自动刷新

**方法 1：等待自然过期（需要等待 2 小时，不推荐）**

**方法 2：模拟过期场景（推荐用于演示）**

由于 42 API 的 token 有效期是 2 小时，为了演示，你可以：

1. **说明机制**：
   > "如果 token 过期，系统会自动刷新。让我展示一下当 API 返回 401 错误时的处理。"

2. **演示自动刷新和重试**：
   - 如果 token 真的过期了（或 API 返回 401），控制台会显示：
     ```
     🔍 [API Call] Searching for user: username
     📡 [API Call] Making request with token: abc123...
     🔄 [API Call] Token expired, refreshing and retrying...
     🔄 [Token Management] Refreshing token...
     ✅ [Token Management] Token refreshed successfully
        New token expires in: 7200 minutes
        New token preview: xyz789abc123def456...
     🔄 [API Call] Retrying request with new token...
     ✅ [API Call] User found successfully
     ```

3. **关键点**：
   - ✅ 检测到 401 错误后自动刷新 token
   - ✅ 刷新后自动重试请求
   - ✅ 用户无感知，应用继续正常工作

**向评估者说明：**
> "您可以看到，当 token 过期时，系统自动检测到 401 错误，然后刷新 token 并重试请求。整个过程对用户是透明的，应用可以继续正常工作。"

---

## 📱 演示流程建议

### 完整演示流程（5-10 分钟）

1. **登录阶段**（1 分钟）
   - 展示登录流程
   - 指出控制台中的 token 获取日志
   - 说明 token 有效期（约 2 小时）

2. **Token 复用演示**（2-3 分钟）
   - 连续搜索 3-5 个用户
   - 指出每次都是 "Reusing existing token"
   - 对比 token preview，证明是同一个 token

3. **Token 刷新机制说明**（2-3 分钟）
   - 解释提前 5 分钟刷新的机制
   - 说明过期后自动刷新的机制
   - 展示代码中的实现逻辑（可选）

4. **总结**（1 分钟）
   - 总结两个要求的实现
   - 强调应用在任何情况下都能正常工作

---

## 🔍 日志输出说明

### 日志标签含义

- `🔐 [Token Management]` - Token 获取/交换
- `✅ [Token Management]` - Token 操作成功
- `🔄 [Token Management]` - Token 刷新
- `❌ [Token Management]` - Token 操作失败
- `🔍 [API Call]` - API 调用
- `📡 [API Call]` - 网络请求
- `⚠️ [API Call]` - 警告信息

### 关键日志示例

**Token 复用：**
```
✅ [Token Management] Reusing existing token
   Token expires in: 7195 minutes
   Token preview: abc123def456ghi789...
```

**Token 刷新：**
```
🔄 [Token Management] Token expiring soon or expired, refreshing...
   Time until expiry: 3 minutes
🔄 [Token Management] Refreshing token...
✅ [Token Management] Token refreshed successfully
   New token expires in: 7200 minutes
   New token preview: xyz789abc123def456...
```

**多次查询使用同一 Token：**
```
🔍 [API Call] Searching for user: user1
✅ [Token Management] Reusing existing token
   Token preview: abc123...
📡 [API Call] Making request with token: abc123...
✅ [API Call] User found successfully

🔍 [API Call] Searching for user: user2
✅ [Token Management] Reusing existing token
   Token preview: abc123...  ← 相同的 token
📡 [API Call] Making request with token: abc123...
✅ [API Call] User found successfully
```

---

## 💡 演示技巧

1. **提前准备**：在演示前先登录，确保有有效的 token
2. **控制台可见**：确保评估者能看到控制台输出
3. **解释清楚**：每次操作时，解释控制台显示的内容
4. **强调关键点**：重点指出 "Reusing existing token" 和自动刷新机制
5. **代码展示**（可选）：如果评估者想看代码，可以展示 `getValidToken()` 和 `refreshToken()` 方法

---

## ⚠️ 注意事项

1. **Token 有效期**：42 API 的 token 有效期是 2 小时，所以：
   - 正常演示中可能看不到自动刷新（除非等待 2 小时）
   - 可以解释机制，并指出代码中的实现

2. **401 错误处理**：如果 token 真的过期，系统会自动处理，但演示时可能不会遇到

3. **日志清晰**：确保控制台日志清晰可见，字体大小适中

---

## ✅ 演示检查清单

- [ ] 控制台/终端已打开并可见
- [ ] 应用已登录
- [ ] 准备好搜索多个用户
- [ ] 了解日志输出的含义
- [ ] 准备好解释每个步骤

---

祝演示顺利！🎉

