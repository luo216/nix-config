# Windows fonts

Fonts copied from a Windows 10/11 machine (`C:\Windows\Fonts`), including all
Microsoft TrueType/OpenType fonts and the WPS-specific `MT Extra` formula font.
The `programs.customFonts` module packages every `.ttf`, `.ttc`, and `.otf`
file in this directory and adds them to fontconfig through Home Manager.

## Microsoft Chinese fonts

- `msyh.ttc` / `msyhbd.ttc` / `msyhl.ttc` — Microsoft YaHei (微软雅黑) + bold + light
- `msyi.ttf` — Microsoft YaHei UI
- `simsun.ttc` / `simsunb.ttf` — SimSun (宋体) + bold
- `simhei.ttf` — SimHei (黑体)
- `simkai.ttf` — KaiTi (楷体)
- `simfang.ttf` — FangSong (仿宋)
- `Deng.ttf` / `Dengb.ttf` / `Dengl.ttf` — DengXian (等线) + bold + light
- `mingliub.ttc` — MingLiU (新细明体)
- `msjh.ttc` / `msjhbd.ttc` / `msjhl.ttc` — Microsoft JhengHei (微软正黑)
- `msgothic.ttc` — MS Gothic
- `YuGoth*.ttc` — Yu Gothic (游ゴシック)
- `monbaiti.ttf` — Mongolian Baiti

## Microsoft Office fonts

- `calibri*.ttf` — Calibri family
- `cambria.ttc` + `cambria*.ttf` — Cambria family
- `consola*.ttf` — Consolas family
- `arial*.ttf` — Arial family
- `times*.ttf` — Times New Roman family
- `cour*.ttf` — Courier New family
- `verdana*.ttf`, `tahoma*.ttf`, `georgia*.ttf`, `trebuc*.ttf`, `impact.ttf`
- `pala*.ttf` — Palatino Linotype
- `corbel*.ttf`, `candara*.ttf`, `constan*.ttf`, `comic*.ttf`, `ebrima*.ttf`
- `segoeui*.ttf` — Segoe UI family
- `bahnschrift.ttf`

## WPS formula fonts

- `mtextra.ttf` — MT Extra (from WPS Office install dir)
- `symbol.ttf`, `webdings.ttf`, `wingding.ttf`

## Notes

- These are proprietary Microsoft fonts; ensure your distribution is allowed
  to use them (personal use is generally fine).
- The `carlito` and `caladea` packages (metric-compatible Calibri/Cambria
  replacements) are still installed as fallbacks.
