p = "E:/SMART - COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/notificationService.js"
s = open(p, encoding="utf-8").read()
old = "`Alert: ${title}. Check dashboard. -SmartCoaches`.slice(0, 160), process.env.DLT_TEMPLATE_ID"
new = "`SmartCoaches Railway Safety Alert: ${title}. Check dashboard immediately. -MIRTHA TECHNOLOGY`.slice(0, 160), process.env.DLT_TEMPLATE_ID"
cnt = s.count(old)
s = s.replace(old, new)
open(p, "w", encoding="utf-8").write(s)
print("replaced:", cnt)