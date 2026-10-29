p = "E:/SMART - COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/notificationService.js"
s = open(p, encoding="utf-8").read()
old = "  const tokens = [];\n  for (const row of (rows || [])) {\n    if (row.fcm_token && allowedUserIds.has(row.user_id)) tokens.push(row.fcm_token);\n  }\n  return { tokens, userIds: [...allowedUserIds] };"
new = "  console.log(\"[push-debug] allowedUserIds=\" + allowedUserIds.size + \" finalTokens=\" + (rows||[]).filter(r => allowedUserIds.has(r.user_id) && r.fcm_token).length);\n  const tokens = [];\n  for (const row of (rows || [])) {\n    if (row.fcm_token && allowedUserIds.has(row.user_id)) tokens.push(row.fcm_token);\n  }\n  return { tokens, userIds: [...allowedUserIds] };"
cnt = s.count(old)
s = s.replace(old, new)
open(p, "w", encoding="utf-8").write(s)
print("replaced:", cnt)