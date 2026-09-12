# quarto-pdf

A Quarto PDF format with selectable styles. One extension gives you a
typeset KOMA-Script layout (fonts, margins, wrapped code, clamped figures,
coloured callouts) and a designed title page. Pick the look with a single
option.

| `lucid` | `classic` | `minimal` | `ledger` |
|:------:|:---------:|:---------:|:--------:|
| ![lucid cover](images/lucid-cover.png) | ![classic cover](images/classic-cover.png) | ![minimal cover](images/minimal-cover.png) | ![ledger cover](images/ledger-cover.png) |
| ![lucid page](images/lucid-page.png) | ![classic page](images/classic-page.png) | ![minimal page](images/minimal-page.png) | ![ledger page](images/ledger-page.png) |

## Install

```bash
quarto add brenobeirigo/quarto-pdf
```

This copies the extension into `_extensions/brenobeirigo/press/`. Update it
later with `quarto update brenobeirigo/quarto-pdf`.

## Use

Replace `pdf` with `press-pdf`:

```yaml
format:
  press-pdf: default
```

That renders with the `lucid` style. Choose another style and fill in the title
page under `press`:

```yaml
format:
  press-pdf:
    press:
      style: classic
      cover:
        institution: [Example University, Faculty of Engineering]
        series: Practitioner handbooks
        label: Reference handbook
        tagline: [Plan, Draft, Review, Publish]
        edition: 2026 edition
```

Every regular `pdf` option (`toc`, `mainfont`, `geometry`, `documentclass`,
`include-in-header`, and so on) still works under `press-pdf` and overrides
the defaults below.

## Styles

| Style     | Headings                     | Running heads           | Title page                            |
|-----------|------------------------------|-------------------------|---------------------------------------|
| `lucid`   | sans, green accent rule      | chapter left, page right | banded, left-aligned, label box       |
| `classic` | serif, centred chapter titles | italic, no rule         | centred, burgundy rules, small caps   |
| `minimal` | sans, no decoration          | none; page number centred | quiet, left-aligned                  |
| `ledger`  | serif, bold and compact      | code left, write-in lines right, hairlines | ruled header block with write-in boxes |

`lucid` shares its palette with the
[Lucid HTML theme](https://github.com/brenobeirigo/quarto-themes), so a book
and its printed edition look alike. Before version 0.2.0 it was called
`dact`. The old name still works but prints a deprecation warning.

### ledger

`ledger` is a ruled record sheet for exercises and exams. The first page opens
with a header block instead of a title page, every callout is the same soft
grey box, and the footer shows `page / total` with "Continued next page" on
all but the last page. It is laid out for `scrartcl` with narrow margins:

```yaml
format:
  press-pdf:
    documentclass: scrartcl
    toc: false
    callout-appearance: simple
    callout-icon: false
    geometry: [top=18mm, bottom=18mm, left=18mm, right=18mm, heightrounded]
    press:
      style: ledger
      cover:
        title: Exercise sheet 3
        label: Week 3
        series: Applied Statistics
        edition: Friday, 18 September 2026
        subtitle: Sampling and estimation
        author: "Examiner: Ada Lovelace"
        code: EX-03
        fields: ["Student ID:", "Name:"]
```

The header block puts `title` and `label` on the first row, `series` and
`edition` on the second, and `subtitle` and `author` on the third. `code`
leads the running head, and each entry in `fields` becomes a labelled box in
the header and a short write-in line in the running head.

`ledger` sets Libertinus Serif, Sans and Math when they are installed and
otherwise keeps the format's fonts. With TinyTeX:

```bash
tlmgr install libertinus-fonts
```

In a report or book class the table of contents and chapters start new pages,
so the header block sits alone on the first page.

### Your own style

Point `style` at a `.tex` file, relative to the project or document:

```yaml
press:
  style: styles/house.tex
```

The file is loaded after the shared layout, so it can use the colour roles and
title-page macros listed below. Copy one of the files in
`_extensions/brenobeirigo/press/styles/` as a starting point.

## Options

All options live under the `press` key.

| Option          | Default | Description |
|-----------------|---------|-------------|
| `style`         | `lucid` | `lucid`, `classic`, `minimal`, `ledger`, or a path to a `.tex` file. |
| `colors.<role>` | style's | Six-digit hex colour for a role. Quote values that start with `#`. |
| `cover.<field>` | empty   | Title-page text. Markdown is allowed. A list is joined with the style's separator. |

### Colour roles

| Role           | LaTeX name         | Typical use |
|----------------|--------------------|-------------|
| `ink`          | `pressink`         | headings and title text |
| `strong`       | `pressstrong`      | heavy rules, warning callouts |
| `accent`       | `pressaccent`      | accent rules, quote bars |
| `accent-dark`  | `pressaccentdark`  | internal links, caption labels |
| `accent-light` | `pressaccentlight` | light callout frames |
| `secondary`    | `presssecondary`   | URLs, note callouts |
| `muted`        | `pressmuted`       | running heads, subtitles |
| `rule`         | `pressrule`        | hairlines |
| `soft`         | `presssoft`        | tinted boxes |

The LaTeX names are also available in your own `include-in-header` code.

### Cover fields

| Field         | Macro               | Notes |
|---------------|---------------------|-------|
| `title`       | `\presstitle`       | Falls back to the document `title`. Use a trailing `\` for a line break. |
| `subtitle`    | `\presssubtitle`    | Falls back to the document `subtitle`. |
| `author`      | `\pressauthor`      | Falls back to the document authors. |
| `institution` | `\pressinstitution` | |
| `series`      | `\pressseries`      | |
| `label`       | `\presslabel`       | |
| `tagline`     | `\presstagline`     | |
| `edition`     | `\pressedition`     | |
| `code`        | `\presscode`        | Short label for running heads. Used by `ledger`. |
| `fields`      | `\pressfields`      | Write-in labels. Each entry becomes `\pressfielditem{label}`. Used by `ledger`. |

In a custom style, `\presstitlefield`, `\presssubtitlefield` and
`\pressauthorfield` apply the fallbacks. `\pressifset{\macro}{...}` and
`\pressifsubtitle{...}` print their content only when the field is set, and
`\presssep` is the list separator. To lay out `fields`, define
`\pressfielditem` and then expand `\pressfields`.

A cover title with a manual line break:

```yaml
press:
  cover:
    title: |
      A practical guide\
      to careful measurement
```

## Defaults

| Option          | Value |
|-----------------|-------|
| `pdf-engine`    | `lualatex` |
| `documentclass` | `scrreprt` (`fontsize=10.5pt`, `numbers=noenddot`, `chapterprefix=false`) |
| `papersize`     | `a4`, margins 26/29/27/27 mm |
| `mainfont`      | TeX Gyre Pagella |
| `sansfont`      | TeX Gyre Heros |
| `monofont`      | Inconsolata (`Inconsolatazi4`) |
| `toc`           | `true`, depth 2 |

The fonts ship with TeX Live. With TinyTeX, install them once:

```bash
tlmgr install tex-gyre inconsolata
```

## Books with chapters outside the project

Quarto only resolves `format: press-pdf` for files inside the project
directory. If a book lists chapters such as `../chapters/intro.qmd`, keep
`format: pdf`, set the page options yourself (see [Defaults](#defaults)), and
load the filter by path. The styles, colours and cover fields work the same:

```yaml
filters:
  - ../_extensions/brenobeirigo/press/press.lua

format:
  pdf:
    pdf-engine: lualatex
    documentclass: scrreprt
    mainfont: "TeX Gyre Pagella"
    sansfont: "TeX Gyre Heros"
    press:
      style: lucid
```

## Requirements

- Quarto 1.4 or later.
- A KOMA-Script class: `scrreprt` (default), `scrbook` or `scrartcl`. Other
  classes compile, but the heading and running-head styling is skipped.

## Try the examples

```bash
cd example
quarto add .. --no-prompt
quarto render lucid.qmd
quarto render classic.qmd
quarto render minimal.qmd
quarto render ledger.qmd
```

`minimal.qmd` also shows `documentclass: scrartcl` and a colour override.
`ledger.qmd` shows the write-in fields.

## License

MIT
