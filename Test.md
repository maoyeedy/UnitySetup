# Test Plan

All tests use a throwaway git repo with fake Unity YAML files. No Unity Editor needed unless testing UnityYAMLMerge binary invocation.

## Setup

```bash
mkdir /tmp/unity-test && cd /tmp/unity-test
git init
mkdir -p ProjectSettings
echo "m_EditorVersion: 6000.0.0f1" > ProjectSettings/ProjectVersion.txt

# Run the setup (adjust path)
bash /path/to/UnitySetup/setup.sh

# Verify configs were applied
git config --local --list | grep -E "core\.|pull\.|rebase\.|fetch\.|rerere\.|merge\.|diff\.|mergetool\."
```

Expected output should include all options from `setup-git-options.sh` plus the merge driver and mergetool entries.

---

## 1. Git Config Options

### 1.1 `diff.algorithm histogram`

Histogram produces cleaner diffs on repetitive YAML blocks. Compare output visually.

```bash
cat > test.unity <<'EOF'
--- !u!1 &100
GameObject:
  m_Name: ObjectA
  m_Component:
  - component: {fileID: 200}
  - component: {fileID: 201}

--- !u!1 &101
GameObject:
  m_Name: ObjectB
  m_Component:
  - component: {fileID: 300}
  - component: {fileID: 301}
EOF
git add test.unity && git commit -m "base"

# Insert a new object between A and B
cat > test.unity <<'EOF'
--- !u!1 &100
GameObject:
  m_Name: ObjectA
  m_Component:
  - component: {fileID: 200}
  - component: {fileID: 201}

--- !u!1 &102
GameObject:
  m_Name: ObjectC
  m_Component:
  - component: {fileID: 400}

--- !u!1 &101
GameObject:
  m_Name: ObjectB
  m_Component:
  - component: {fileID: 300}
  - component: {fileID: 301}
EOF

# Should show a clean insertion block, not a jumbled re-match of repeated keys
git diff test.unity

# Compare against myers to see the difference
git diff --diff-algorithm=myers test.unity
```

**Pass:** histogram diff shows a single clean `+` block for ObjectC. Myers may match `m_Component:` lines across objects, producing a confusing diff.

### 1.2 `diff.renameLimit` / `merge.renameLimit`

```bash
# Create many files
mkdir Assets
for i in $(seq 1 500); do echo "content-$i" > "Assets/File$i.txt"; done
git add . && git commit -m "500 files"

# Rename 450 of them (exceeds default limit of 400)
git checkout -b rename-test
for i in $(seq 1 450); do git mv "Assets/File$i.txt" "Assets/Renamed$i.txt"; done
git commit -m "rename 450 files"

# Should detect renames, not show 450 deletes + 450 adds
git diff --stat main...rename-test
git log --oneline --diff-filter=R --find-renames -- "Assets/*" | head
```

**Pass:** `git diff --stat` shows `{File => Renamed}` rename notation rather than separate deletions and additions.

### 1.3 `mergetool.keepBackup false`

Tested as part of mergetool tests below. After running `git mergetool`, no `.orig` files should remain.

### 1.4 `pull.rebase true` / `rebase.autoStash true`

```bash
# On main
echo "main change" > file.txt && git add . && git commit -m "main"

git checkout -b feature
echo "feature change" > feature.txt && git add . && git commit -m "feature"

git checkout main
echo "another main change" >> file.txt && git add . && git commit -m "main2"

git checkout feature
# Make an uncommitted change (tests autoStash)
echo "wip" > wip.txt

git pull origin main
```

**Pass:** pull rebases instead of creating a merge commit. Uncommitted `wip.txt` is auto-stashed and restored. `git log --oneline --graph` shows linear history.

### 1.5 `rerere.enabled true`

```bash
git checkout main
echo "line1" > conflict.txt && git add . && git commit -m "base"

git checkout -b branchA
echo "line1-A" > conflict.txt && git commit -am "A"

git checkout main
git checkout -b branchB
echo "line1-B" > conflict.txt && git commit -am "B"

# First merge — conflict
git checkout branchA
git merge branchB || true
# Manually resolve
echo "line1-resolved" > conflict.txt
git add conflict.txt && git commit -m "resolved"

# Reset and redo — rerere should auto-resolve
git reset --hard HEAD~1
git merge branchB
```

**Pass:** second merge auto-resolves with the recorded resolution. Message says `Resolved 'conflict.txt' using previous resolution`.

### 1.6 `fetch.prune true`

```bash
# Requires a remote. Create a bare repo to simulate.
git clone --bare . /tmp/bare-remote.git
git remote add test-remote /tmp/bare-remote.git
git push test-remote main

# Create and push a branch, then delete it on the remote
git checkout -b temp-branch
git push test-remote temp-branch
git checkout main
git push test-remote --delete temp-branch

# Fetch — stale remote-tracking branch should be pruned automatically
git fetch test-remote
git branch -r | grep temp-branch
```

**Pass:** `git branch -r` does not list `test-remote/temp-branch`.

### 1.7 `core.longpaths true` (Windows only)

```bash
# Create a deeply nested path exceeding 260 chars
mkdir -p "Assets/Very/Deeply/Nested/Directory/Structure/That/Goes/On/And/On/And/On/For/A/Very/Long/Time/To/Exceed/The/Windows/Path/Limit/Of/Two/Hundred/And/Sixty/Characters"
echo "test" > "Assets/Very/Deeply/Nested/Directory/Structure/That/Goes/On/And/On/And/On/For/A/Very/Long/Time/To/Exceed/The/Windows/Path/Limit/Of/Two/Hundred/And/Sixty/Characters/file.txt"
git add . && git commit -m "long path"
```

**Pass:** no `Filename too long` error on Windows.

### 1.8 `core.autocrlf input`

```bash
# Create a file with CRLF endings
printf "line1\r\nline2\r\n" > crlf-test.txt
git add crlf-test.txt

# Check what git stored
git show :crlf-test.txt | xxd | grep "0d 0a"
```

**Pass:** no `0d 0a` (CRLF) in the blob — git converted to LF on input.

---

## 2. UnityYAMLMerge — Merge Driver (Automatic)

Requires the UnityYAMLMerge binary to be installed (via Unity Hub). The `.gitattributes` must include `*.unity merge=unityyamlmerge` or equivalent.

### 2.1 Setup test gitattributes

```bash
echo "*.unity merge=unityyamlmerge" > .gitattributes
git add .gitattributes && git commit -m "gitattributes"
```

### 2.2 Non-conflicting changes to different objects — driver auto-resolves

```bash
cat > scene.unity <<'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!4 &100
Transform:
  m_LocalPosition: {x: 0, y: 0, z: 0}
  m_LocalRotation: {x: 0, y: 0, z: 0, w: 1}
  m_RootOrder: 0

--- !u!4 &200
Transform:
  m_LocalPosition: {x: 5, y: 5, z: 5}
  m_LocalRotation: {x: 0, y: 0, z: 0, w: 1}
  m_RootOrder: 1
EOF
git add . && git commit -m "base scene"

# Branch A: move object &100
git checkout -b driver-A
sed -i 's/&100/\&100/' scene.unity
sed -i '/&100/{n;s/x: 0, y: 0, z: 0/x: 1, y: 2, z: 3/}' scene.unity
git commit -am "move object 100"

# Branch B: move object &200
git checkout main
git checkout -b driver-B
sed -i '/&200/{n;s/x: 5, y: 5, z: 5/x: 10, y: 10, z: 10/}' scene.unity
git commit -am "move object 200"

# Merge — driver should auto-resolve (different objects modified)
git checkout driver-A
git merge driver-B
```

**Pass:** merge completes without conflict. `scene.unity` contains both changes (object 100 at 1,2,3 and object 200 at 10,10,10).

### 2.3 True conflict — driver fails, leaves conflict for mergetool

```bash
git checkout main
cat > scene2.unity <<'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!4 &100
Transform:
  m_LocalPosition: {x: 0, y: 0, z: 0}
EOF
git add . && git commit -m "base scene2"

# Both branches move the SAME object to different positions
git checkout -b conflict-A
sed -i 's/x: 0, y: 0, z: 0/x: 1, y: 1, z: 1/' scene2.unity
git commit -am "move to 1,1,1"

git checkout main
git checkout -b conflict-B
sed -i 's/x: 0, y: 0, z: 0/x: 9, y: 9, z: 9/' scene2.unity
git commit -am "move to 9,9,9"

git checkout conflict-A
git merge conflict-B
```

**Pass:** merge reports a conflict on `scene2.unity`. File is left in a conflicted state for manual resolution (mergetool test below).

---

## 3. UnityYAMLMerge — Mergetool (Manual)

Continues from the conflict in test 2.3.

### 3.1 Resolve with mergetool

```bash
# Should invoke UnityYAMLMerge interactively
git mergetool --tool=unityyamlmerge scene2.unity

# Or if merge.tool is set:
# git mergetool scene2.unity
```

**Pass:** UnityYAMLMerge opens and allows resolution. After completing:
- `scene2.unity` contains the resolved content
- No `scene2.unity.orig` file exists (keepBackup is false)
- `git status` shows the file is resolved

```bash
git add scene2.unity && git commit -m "resolved"
ls scene2.unity.orig 2>/dev/null && echo "FAIL: .orig exists" || echo "PASS: no .orig"
```

---

## 4. Merge Rules

These tests verify UnityYAMLMerge ignores negligible differences via `mergerules.txt`. Requires the custom rules to be appended to Unity's system `mergerules.txt`.

The general pattern: both branches change the same field by a tiny amount. The merge driver should auto-resolve because the difference is within tolerance.

### 4.1 Position tolerance (0.0000005)

```bash
git checkout main
cat > pos.unity <<'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!4 &100
Transform:
  m_LocalPosition: {x: 1, y: 2, z: 3}
EOF
git add . && git commit -m "base pos"

# Branch A: negligible drift
git checkout -b pos-A
sed -i 's/x: 1/x: 1.0000001/' pos.unity
git commit -am "pos drift A"

# Branch B: negligible drift in different direction
git checkout main
git checkout -b pos-B
sed -i 's/x: 1/x: 1.0000002/' pos.unity
git commit -am "pos drift B"

git checkout pos-A
git merge pos-B
```

**Pass:** auto-resolves without conflict (difference < 0.0000005).

### 4.2 Rotation tolerance (0.00005 base, 0.001 upper)

Same pattern but with `m_LocalRotation` values differing by < 0.00005.

### 4.3 Scale tolerance (0.0000005)

Same pattern with `m_LocalScale` values.

### 4.4 Euler hint tolerance (0.00005 base, 0.001 upper)

```bash
git checkout main
cat > euler.unity <<'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!4 &100
Transform:
  m_LocalEulerAnglesHint: {x: 45, y: 90, z: 0}
EOF
git add . && git commit -m "base euler"

git checkout -b euler-A
sed -i 's/x: 45/x: 45.00001/' euler.unity
git commit -am "euler drift A"

git checkout main
git checkout -b euler-B
sed -i 's/x: 45/x: 45.00002/' euler.unity
git commit -am "euler drift B"

git checkout euler-A
git merge euler-B
```

**Pass:** auto-resolves.

### 4.5 Material color tolerance (0.0000005)

Same pattern with `m_SavedProperties.m_Colors` values.

### 4.6 m_RootOrder tolerance (0.1)

This field is an integer so real changes (±1) should still conflict, but serialization noise should not.

```bash
git checkout main
cat > root.unity <<'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!4 &100
Transform:
  m_RootOrder: 3
EOF
git add . && git commit -m "base root"

# Both branches: value stays at 3 (no real change, tolerance test baseline)
# If Unity ever serializes as 3.0 vs 3, the tolerance absorbs it.
# Real conflict test: one changes to 4, other changes to 5
git checkout -b root-A
sed -i 's/m_RootOrder: 3/m_RootOrder: 4/' root.unity
git commit -am "root order 4"

git checkout main
git checkout -b root-B
sed -i 's/m_RootOrder: 3/m_RootOrder: 5/' root.unity
git commit -am "root order 5"

git checkout root-A
git merge root-B
```

**Pass:** this SHOULD conflict (difference is 1, exceeds 0.1 tolerance). Verifies the tolerance isn't too loose.

### 4.7 `[arrays] set` — Component list reordering

```bash
git checkout main
cat > comp.unity <<'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!1 &100
GameObject:
  m_Component:
  - component: {fileID: 200}
  - component: {fileID: 201}
  - component: {fileID: 202}
EOF
git add . && git commit -m "base components"

# Branch A: add a new component
git checkout -b comp-A
cat > comp.unity <<'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!1 &100
GameObject:
  m_Component:
  - component: {fileID: 200}
  - component: {fileID: 201}
  - component: {fileID: 202}
  - component: {fileID: 300}
EOF
git commit -am "add component 300"

# Branch B: add a different component
git checkout main
git checkout -b comp-B
cat > comp.unity <<'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!1 &100
GameObject:
  m_Component:
  - component: {fileID: 200}
  - component: {fileID: 201}
  - component: {fileID: 202}
  - component: {fileID: 400}
EOF
git commit -am "add component 400"

git checkout comp-A
git merge comp-B
```

**Pass:** auto-resolves. Result contains both fileID 300 and 400. The `set` rule treats the list as an unordered set keyed by fileID.

### 4.8 `[arrays] set` — Prefab modifications

```bash
git checkout main
cat > prefab.unity <<'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!1001 &100
Prefab:
  m_Modification:
    m_Modifications:
    - target: {fileID: 10, guid: aaa}
      propertyPath: m_Name
      value: ObjA
    - target: {fileID: 20, guid: bbb}
      propertyPath: m_Name
      value: ObjB
EOF
git add . && git commit -m "base prefab"

# Branch A: add a modification
git checkout -b prefab-A
cat > prefab.unity <<'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!1001 &100
Prefab:
  m_Modification:
    m_Modifications:
    - target: {fileID: 10, guid: aaa}
      propertyPath: m_Name
      value: ObjA
    - target: {fileID: 20, guid: bbb}
      propertyPath: m_Name
      value: ObjB
    - target: {fileID: 30, guid: ccc}
      propertyPath: m_IsActive
      value: 1
EOF
git commit -am "add modification for fileID 30"

# Branch B: add a different modification
git checkout main
git checkout -b prefab-B
cat > prefab.unity <<'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!1001 &100
Prefab:
  m_Modification:
    m_Modifications:
    - target: {fileID: 10, guid: aaa}
      propertyPath: m_Name
      value: ObjA
    - target: {fileID: 20, guid: bbb}
      propertyPath: m_Name
      value: ObjB
    - target: {fileID: 40, guid: ddd}
      propertyPath: m_Enabled
      value: 0
EOF
git commit -am "add modification for fileID 40"

git checkout prefab-A
git merge prefab-B
```

**Pass:** auto-resolves. Result contains modifications for fileID 30 and 40. The set rule keys by `target.fileID target.guid propertyPath`.

---

## 5. Git LFS

```bash
# Verify hooks
cat .git/hooks/post-merge | grep lfs

# Verify filter
git config filter.lfs.process

# Test tracking (requires .gitattributes with lfs patterns)
echo "*.png filter=lfs diff=lfs merge=lfs -text" >> .gitattributes
git add .gitattributes && git commit -m "lfs patterns"

# Add a binary file
cp /path/to/any/image.png test.png  # or: dd if=/dev/urandom bs=1024 count=1 > test.png
git add test.png
git diff --cached test.png  # should show "LFS" pointer, not binary blob
```

**Pass:** staged diff shows an LFS pointer (`oid sha256:...`, `size ...`), not raw binary content.

---

## Quick Verification Checklist

```bash
# Run after setup.sh to verify all configs in one shot
echo "=== Git Config ==="
git config core.autocrlf        # input
git config core.safecrlf        # false
git config core.filemode         # false
git config pull.rebase           # true
git config rebase.autoStash      # true
git config fetch.prune           # true
git config rerere.enabled        # true
git config mergetool.keepBackup  # false
git config diff.renameLimit      # 10000
git config merge.renameLimit     # 10000
git config diff.algorithm        # histogram

echo "=== Merge Driver ==="
git config merge.unityyamlmerge.name    # UnityYAMLMerge
git config merge.unityyamlmerge.driver  # '<path>' merge -p %O %B %A %A

echo "=== Mergetool ==="
git config mergetool.unityyamlmerge.trustExitCode  # false
git config mergetool.unityyamlmerge.cmd             # '<path>' merge -p ...

echo "=== LFS ==="
git config filter.lfs.process  # git-lfs filter-process
git lfs env | head -5
```
