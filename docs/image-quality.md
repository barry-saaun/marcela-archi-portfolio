# Getting sharper images on the site

Status: not done yet. The site currently uses stand-in images rendered from the
portfolio PDF. This note is the plan for replacing them with proper exports.

## Why the current images look soft

- The sheets were rendered from the PDF at about 3300 px wide
  (`scripts/extract.sh`, 200 dpi). A high-density laptop screen already needs
  about that much, so there is nothing left for zooming.
- The build re-compresses each sheet to WebP at Astro's default quality, which
  softens thin lines and small legend text.
- The PDF may have downsampled photos and renders when it was saved from
  Illustrator. This has not been checked.
- The divider and cover sketches are crops of the PDF pages, not the original
  scans.

## What to export from Illustrator

Use File > Export > Export for Screens, one file per artboard.

| What | Format | Size |
|---|---|---|
| 15 drawing spreads | PNG-24 | 300 ppi, about 4960 x 2480 px |
| 4 divider sketches | PNG-24, white background | about 2000 px on the long side |
| Cover diagram and back-cover fragment | PNG-24, white background | about 3000 px on the long side |

More than 300 ppi is not worth it: files get much heavier and no screen shows
the difference. The sketches must be pure black on pure white, because the site
inverts them for the black pages.

## Where the files go

Replace the existing files, keeping the names:

```
src/assets/cover.png
src/assets/back.png
src/assets/basin/sketch.png   01.png 02.png
src/assets/grain/sketch.png   01.png ... 06.png
src/assets/agora/sketch.png   01.png ... 04.png
src/assets/hub/sketch.png     01.png ... 03.png
```

Sheets are picked up by number, so adding `07.png` to a project adds a page.
Do not re-run `scripts/extract.sh` afterwards; it would overwrite the exports
with PDF renders.

Note: the divider layout positions `sketch.png` assuming the current crop
(a 480 x 395 pt area of the page with the drawing centred). A tightly cropped
export will sit differently and the `.divider .art` rule in
`src/pages/index.astro` will need adjusting.

## Code changes to make at the same time

All in `src/pages/index.astro`, on the sheet `<Image>`:

1. Add a larger width step: `widths={[1280, 1920, 2560, 3840, img.width]}`.
2. Raise compression quality for line work, e.g. `quality={90}`, and compare
   against AVIF (`format="avif"`), which usually keeps thin lines cleaner at
   the same size but builds more slowly.
3. The click-to-zoom link currently points at the original PNG (`img.src`).
   With 4960 px sources those are 5-10 MB each. Point it at a full-size,
   high-quality WebP or AVIF from `getImage()` instead.

## Expected weight

Estimates, to be measured after the swap.

| | Now | With 4960 px sources |
|---|---|---|
| One sheet as loaded by a visitor | 250-400 KB | 300-600 KB |
| Whole book scrolled end to end | about 5 MB | 6-9 MB |
| Built `dist` folder | 55 MB | 80-120 MB, or near 55 MB after change 3 |

Images stay in the repo and are served by the same static host; no separate
image hosting is needed. Each re-export adds to Git history, which only matters
if it happens many times (Git LFS is the fix if it does).

## How to check

- Run `pnpm build` and look at the per-image sizes in the log.
- Open a dense sheet (Grain detail section, Hub sections) on a high-density
  screen and read the smallest legend text, both in the page and after
  clicking through to the zoom view.
