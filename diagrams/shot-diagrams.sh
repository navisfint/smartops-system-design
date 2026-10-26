#!/usr/bin/env bash
set -e
BASE="/f/workBuddy/2026-10-15-22-11-32/smarteops"
CHROME="/c/Program Files/Google/Chrome/Application/chrome.exe"
cd "$BASE/diagrams" && node gen-ipo.mjs >/dev/null

shoot () { # name width
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 \
    --window-size="$2",1400 \
    --screenshot="F:\\workBuddy\\2026-10-15-22-11-32\\smarteops\\img\\_raw_$1.png" \
    "file:///F:/workBuddy/2026-10-15-22-11-32/smarteops/diagrams/$1.html" >/dev/null 2>&1
}

shoot h 820
for f in ipo-resource-onboard ipo-resource-tag ipo-inspect-template ipo-inspect-dag \
         ipo-metric-anomaly ipo-alert-rule ipo-alert-denoise ipo-playbook; do
  shoot "$f" 748
done

cd "$BASE/img" && python3 - <<'EOF'
from PIL import Image, ImageChops
import glob, os
for f in sorted(glob.glob('_raw_*.png')):
    im = Image.open(f).convert('RGB')
    bg = Image.new('RGB', im.size, (255,255,255))
    bbox = ImageChops.difference(im, bg).getbbox()
    if bbox:
        im = im.crop((max(0,bbox[0]-24), max(0,bbox[1]-24), min(im.width,bbox[2]+24), min(im.height,bbox[3]+24)))
    out = f.replace('_raw_','').replace('.png','') + '.png'
    if out.startswith('h.'): out = 'h-diagram.png'
    im.save(out)
    print(f'{out:34s} {im.size}')
    os.remove(f)
EOF
