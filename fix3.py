p = "E:/SMART - COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/notificationService.js"
lines = open(p, encoding="utf-8").read().splitlines(keepends=True)
lines[189] = "  } catch (err) {\n"
lines[190] = '    console.error("ERR", err.message);\n'
lines[191] = "  }\n"
open(p, "w", encoding="utf-8").write("".join(lines))
print("done")