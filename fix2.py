p = "E:/SMART - COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/notificationService.js"
lines = open(p, encoding="utf-8").read().splitlines(keepends=True)
insert = "    } catch (err) {\n      console.error(\"ERR\", err.message);\n    }\n"
for ln in [272, 190]:
    lines.insert(ln - 1, insert)
open(p, "w", encoding="utf-8").write("".join(lines))
print("done")