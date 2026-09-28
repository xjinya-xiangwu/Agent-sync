import re, sys, zipfile, shutil

path = sys.argv[1]
tmp = path + ".tmp"

with zipfile.ZipFile(path, "r") as zin:
    items = zin.infolist()
    data = {i.filename: zin.read(i.filename) for i in items}

def fix_para(m):
    body = m.group(0)
    pprs = list(re.finditer(r"<a:pPr(?:[^>]*/>|[^>]*>.*?</a:pPr>)", body, re.S))
    if len(pprs) > 1:
        for hit in reversed(pprs[1:]):
            body = body[:hit.start()] + body[hit.end():]
    return body

changed = 0
for name in list(data):
    if re.match(r"ppt/slides/slide\d+\.xml$", name):
        xml = data[name].decode("utf-8")
        fixed = re.sub(r"<a:p>.*?</a:p>", fix_para, xml, flags=re.S)
        if fixed != xml:
            changed += 1
        data[name] = fixed.encode("utf-8")

with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
    for i in items:
        zout.writestr(i, data[i.filename])

shutil.move(tmp, path)
print(f"pPr fix applied to {changed} slide xml")
