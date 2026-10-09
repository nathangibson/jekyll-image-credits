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
