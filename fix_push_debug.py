p = "E:/SMART - COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/notificationService.js"
s = open(p, encoding="utf-8").read()
old = "  const userIds = [...new Set((rows || []).map((r) => r.user_id).filter((id) => id != null))];\n  if (userIds.length === 0) return { tokens: [], userIds: [] };"
new = "  const userIds = [...new Set((rows || []).map((r) => r.user_id).filter((id) => id != null))];\n  console.log(\"[push-debug] moduleKey=\" + moduleKey + \" location=\" + location + \" totalRows=\" + (rows||[]).length + \" userIds=\" + userIds.length);\n  if (userIds.length === 0) return { tokens: [], userIds: [] };"
cnt = s.count(old)
s = s.replace(old, new)
open(p, "w", encoding="utf-8").write(s)
print("replaced:", cnt)