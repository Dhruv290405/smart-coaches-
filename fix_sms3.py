p = "E:/SMART - COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/notificationService.js"
s = open(p, encoding="utf-8").read()
old = "SmartCoaches Railway Safety Alert: ${title}. Check dashboard immediately. -SmartCoaches"
new = "SmartCoaches Railway Coach Safety Alert: ${title}. Immediate action required for train safety. Check SmartCoaches dashboard now. -SmartCoaches"
cnt = s.count(old)
s = s.replace(old, new)
open(p, "w", encoding="utf-8").write(s)
print("replaced:", cnt)