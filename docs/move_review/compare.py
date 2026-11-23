import json, sys
a = json.load(open(sys.argv[1])); b = json.load(open(sys.argv[2]))
print("removed:", sorted(set(a) - set(b)))
print("added:  ", sorted(set(b) - set(a)))
for n in sorted(set(a) & set(b)):
    if a[n] != b[n]:
        for k in a[n]:
            if a[n][k] != b[n][k]: print(f"changed {n}.{k}:\n   {a[n][k]}\n   {b[n][k]}")
