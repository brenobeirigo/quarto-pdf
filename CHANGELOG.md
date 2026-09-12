# Changelog

## 0.3.0

- Add the `ledger` style, a ruled record sheet for exercises and exams: a
  header block with write-in fields in place of a title page, running heads
  between hairlines, soft grey callouts, a `page / total` folio, and a
  "Continued next page" footer. It uses Libertinus when installed.
- Add the `code` cover field, a short label for running heads.
- Add the `fields` cover field, a list of write-in labels. Each entry becomes
  `\pressfielditem{label}` so a style decides how to lay them out.

## 0.2.0

- Rename the `dact` style to `lucid`, after its design rather than the course
  it came from. Its colours match the Lucid HTML theme in
  [quarto-themes](https://github.com/brenobeirigo/quarto-themes).
- `lucid` is the default style.
- `press.style: dact` still works but prints a deprecation warning. The alias
  will be removed in 1.0.

## 0.1.0

- Initial release of the `press-pdf` format: LuaLaTeX with KOMA-Script,
  TeX Gyre Pagella and Heros, Inconsolata, wrapped code, and figures clamped
  to the printable area.
- Three styles selectable with `press.style`: `dact`, `classic` and `minimal`,
  plus support for a custom `.tex` style file.
- Colour roles overridable with `press.colors`.
- Metadata-driven title page fields under `press.cover`.
