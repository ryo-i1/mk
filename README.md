# mk


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
make                  # PDF をビルドし，可能なら open
make pdf              # PDF をビルド
make dvi              # DVI をビルド
make sp v=1           # SP + version をビルドし，可能なら open
make clean            # 中間ファイル削除
make distclean        # 生成物含め削除
```
