# mk

---

## Install / Uninstall

```bash
./install.sh
./uninstall.sh
````

---

## Paths

| src           | dst                            |
| ------------- | ------------------------------ |
| `tex/core.mk` | `~/local/share/mk/tex/core.mk` |

---

## Usage

プロジェクト側 `Makefile`:

```make
include ~/local/share/mk/tex/core.mk
```

---

## Make Commands

```bash
make                  # 通常ビルド
make sp               # SP ビルド
make open             # PDF を開く
make open v=1         # version 付き PDF をビルド・開く
make open sp=1 v=1    # SP + version をビルド・開く
```
