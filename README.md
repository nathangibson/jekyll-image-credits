# jekyll-image-credits

Reusable Jekyll image-credit system shared by nathangibson.github.io and the
courses site. Source of truth for:

- `_plugins/image_credit.rb` — Liquid filter: `image_credit(url)` → credit hash
- `_plugins/extract_image_credits_hook.rb` — auto-extract XMP → `_data/image_credits.yaml`
- `_plugins/extract_image_urls_filter.rb` — scrape image URLs from rendered HTML
- `_includes/image-caption.html` / `image-credits-list.html` — caption + list partials
- `scripts/extract_image_credits.rb` — exiftool extractor (image dir configurable)

Pull it into a site as a Git submodule; symlink (or copy) its `_plugins`,
`_includes`, and `scripts` into the site as needed.

## Credit fields (XMP → `_data/image_credits.yaml`)

The extractor maps XMP-dc tags to YAML keys:

| XMP-dc | YAML key | Notes |
| --- | --- | --- |
| `dc:description` | `description` | |
| `dc:creator` | `creator` | multi-value → `; `-joined |
| `dc:date` | `date` | normalized to ISO 8601 (`2012-12-31T15:20:00`, `2012-12`, `2012`); free text kept as-is |
| `dc:identifier` | `identifier` | |
| `dc:publisher` | `publisher` | multi-value → `; `-joined |
| `dc:source` | `source_url` | |
| `dc:rights` | `rights` | |

Dates are **optional**. Display formatting lives in one place,
`Jekyll::ImageCreditFormat.date` (in `_plugins/image_credit.rb`), exposed to
Liquid as the `credit_date` filter and reused by the popover hook:

| stored | shown |
| --- | --- |
| `2012-12-31T15:20:00` | `31 Dec 2012` |
| `2012-12-31` | `31 Dec 2012` |
| `2012-12` | `Dec 2012` |
| `2012` | `2012` |
| `c. 1900`, `1880s` | as-is |
| `''`, `nil`, junk | omitted (no `Date:` fragment, no dangling space) |

Only the date part is shown; the time is kept in the YAML for reference.
