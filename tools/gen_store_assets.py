"""ChromaPulse - full store-asset generator.

Emits to `store_assets/`:
  feature_graphic_1024x500.png
  og_card_1200x630.png
  phone/01_menu.png ... 05_paywall.png    (1290x2796)
  tablet/01_menu.png ... 05_paywall.png   (2064x2752)
  android/icon-512.png

Dark, neon-accented arcade-style for a color-perception game.
"""
from __future__ import annotations
import os
import math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "store_assets")
ICON_PATH = os.path.join(
    ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset",
    "Icon-App-1024x1024@1x.png",
)

# Theme (matches lib/core/constants/app_colors.dart)
BG = (10, 10, 15)
SURFACE = (19, 19, 26)
SURFACE2 = (28, 28, 38)
ACCENT = (0, 255, 170)      # mint
ACCENT2 = (255, 51, 102)    # coral
ACCENT3 = (123, 97, 255)    # purple
GOLD = (255, 215, 0)
SILVER = (192, 192, 192)
BRONZE = (205, 127, 50)
TEXT = (232, 232, 240)
DIM = (106, 106, 128)

PHONE_W, PHONE_H = 1290, 2796
TABLET_W, TABLET_H = 2064, 2752


def _font(size, bold=False):
    candidates = [
        "C:/Windows/Fonts/seguibl.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]
    for c in candidates:
        if os.path.exists(c):
            try:
                return ImageFont.truetype(c, size)
            except Exception:
                pass
    return ImageFont.load_default()


def _radial_glow(w, h, cx, cy, color, max_r, alpha_peak=120, steps=24):
    """Soft radial neon glow, returns RGBA."""
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(steps):
        t = 1 - i / steps
        alpha = int(alpha_peak * t * t)
        rr = int(max_r * (1 - i / steps))
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr],
                  fill=(color[0], color[1], color[2], alpha))
    return layer.filter(ImageFilter.GaussianBlur(max_r // 6))


def _bg(w, h):
    """Dark gradient with two neon glow blooms."""
    base = Image.new("RGBA", (w, h), BG + (255,))
    base.alpha_composite(_radial_glow(w, h, int(w * 0.25), int(h * 0.2),
                                      ACCENT3, max_r=w, alpha_peak=80))
    base.alpha_composite(_radial_glow(w, h, int(w * 0.8), int(h * 0.75),
                                      ACCENT, max_r=w, alpha_peak=60))
    return base


def _rounded_rect(draw, box, radius, fill=None, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def _wrap(text, font, max_w):
    words = text.split()
    lines, cur = [], ""
    d = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    for w in words:
        trial = (cur + " " + w).strip()
        if d.textlength(trial, font=font) <= max_w:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def _draw_text_centered(img, text, y, font, fill, max_w):
    d = ImageDraw.Draw(img)
    lines = _wrap(text, font, max_w)
    for line in lines:
        bbox = d.textbbox((0, 0), line, font=font)
        tw = bbox[2] - bbox[0]
        d.text(((img.width - tw) // 2, y), line, font=font, fill=fill)
        y += int((bbox[3] - bbox[1]) * 1.25)


def _device_frame(w, h):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = int(min(w, h) * 0.09)
    _rounded_rect(d, [0, 0, w, h], r, fill=(14, 14, 20, 255))
    inset = 18
    _rounded_rect(d, [inset, inset, w - inset, h - inset], r - inset // 2,
                  fill=BG + (255,))
    island_w, island_h = int(w * 0.32), int(w * 0.09)
    island_x = (w - island_w) // 2
    island_y = int(w * 0.05)
    _rounded_rect(d, [island_x, island_y, island_x + island_w, island_y + island_h],
                  island_h // 2, fill=(6, 6, 10, 255))
    return img, (inset, inset, w - inset, h - inset)


def _header(canvas, title, subtitle=""):
    f_title = _font(120, bold=True)
    f_sub = _font(56)
    y = int(canvas.height * 0.05)
    _draw_text_centered(canvas, title, y, f_title, TEXT + (255,),
                        int(canvas.width * 0.86))
    if subtitle:
        d = ImageDraw.Draw(canvas)
        bbox = d.textbbox((0, 0), title, font=f_title)
        lines = len(_wrap(title, f_title, int(canvas.width * 0.86)))
        y += lines * int((bbox[3] - bbox[1]) * 1.25) + 20
        _draw_text_centered(canvas, subtitle, y, f_sub, ACCENT + (255,),
                            int(canvas.width * 0.8))
    return int(canvas.height * 0.28)


# --- UI painters ---

def _paint_menu(ui):
    """Menu: logo + 4 mode cards + shop."""
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    pad = int(W * 0.05)

    # Bg
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)

    # Status bar
    d.text((W - pad - 90, int(H * 0.025)), "9:41",
           font=_font(36, bold=True), fill=TEXT)

    # Logo block
    y = int(H * 0.08)
    # Glow circles
    ui.alpha_composite(_radial_glow(W, H, W // 2, y + 100, ACCENT,
                                    max_r=280, alpha_peak=140), (0, 0))
    d = ImageDraw.Draw(ui)
    f = _font(110, bold=True)
    tw = d.textlength("ChromaPulse", font=f)
    d.text(((W - tw) / 2, y + 60), "ChromaPulse", font=f, fill=TEXT)
    f = _font(32, bold=True)
    tw = d.textlength("TRAIN YOUR COLOR EYE", font=f)
    d.text(((W - tw) / 2, y + 200), "TRAIN YOUR COLOR EYE",
           font=f, fill=ACCENT)
    y += 320

    # Stats bar
    _rounded_rect(d, [pad, y, W - pad, y + 140], 30,
                  fill=SURFACE + (255,), outline=SURFACE2 + (255,), width=2)
    stats = [("COINS", "428", GOLD), ("STREAK", "7", ACCENT2), ("BEST", "12,450", ACCENT3)]
    sw = (W - 2 * pad) // 3
    for i, (label, val, col) in enumerate(stats):
        sx = pad + i * sw
        fv = _font(48, bold=True)
        vw = d.textlength(val, font=fv)
        d.text((sx + sw / 2 - vw / 2, y + 24), val, font=fv, fill=col)
        fl = _font(20, bold=True)
        lw = d.textlength(label, font=fl)
        d.text((sx + sw / 2 - lw / 2, y + 90), label, font=fl, fill=DIM)
    y += 175

    # Mode cards
    modes = [
        ("Shade Hunter", "Spot the odd tile", ACCENT, "12,450"),
        ("Odd Chroma", "Faster grids, sharper eye", ACCENT2, "8,200"),
        ("Chroma Recall", "Remember. Then match.", ACCENT3, "5,900"),
        ("Color Alchemist", "Mix RGB to recreate", GOLD, "3,780"),
    ]
    for name, tag, col, best in modes:
        ch = 260
        # Card with neon accent
        _rounded_rect(d, [pad, y, W - pad, y + ch], 32,
                      fill=SURFACE + (255,), outline=col + (255,), width=3)
        # Color swatch
        sx, sy = pad + 40, y + 40
        sz = 180
        _rounded_rect(d, [sx, sy, sx + sz, sy + sz], 28, fill=col + (255,))
        # Glow under swatch
        ui.alpha_composite(_radial_glow(W, H, sx + sz // 2, sy + sz // 2,
                                        col, max_r=200, alpha_peak=80), (0, 0))
        d = ImageDraw.Draw(ui)
        d.text((pad + 250, y + 50), name, font=_font(48, bold=True), fill=TEXT)
        d.text((pad + 250, y + 112), tag, font=_font(26), fill=DIM)
        d.text((pad + 250, y + 170), "BEST", font=_font(18, bold=True), fill=DIM)
        d.text((pad + 250, y + 195), best, font=_font(34, bold=True), fill=col)
        # Play arrow
        ax = W - pad - 80
        ay = y + ch // 2
        d.polygon([(ax, ay - 28), (ax + 42, ay), (ax, ay + 28)], fill=col)
        y += ch + 24


def _paint_gameplay(ui):
    """Gameplay: 6x6 grid with one odd tile."""
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.04)

    d.text((W - pad - 90, int(H * 0.025)), "9:42",
           font=_font(36, bold=True), fill=TEXT)

    # Top info bar
    y = int(H * 0.075)
    # Score
    d.text((pad, y), "SCORE", font=_font(22, bold=True), fill=DIM)
    d.text((pad, y + 34), "2,430", font=_font(62, bold=True), fill=ACCENT)
    # Combo (center)
    d.text((W // 2 - 80, y), "COMBO", font=_font(22, bold=True), fill=DIM)
    f = _font(62, bold=True)
    tw = d.textlength("x7", font=f)
    d.text((W // 2 - tw / 2, y + 34), "x7", font=f, fill=ACCENT2)
    # Level (right)
    d.text((W - pad - 140, y), "LEVEL", font=_font(22, bold=True), fill=DIM)
    d.text((W - pad - 140, y + 34), "14", font=_font(62, bold=True), fill=ACCENT3)
    y += 140

    # Timer bar
    _rounded_rect(d, [pad, y, W - pad, y + 28], 14,
                  fill=SURFACE2 + (255,))
    bw = (W - 2 * pad) * 0.62
    _rounded_rect(d, [pad, y, pad + int(bw), y + 28], 14, fill=ACCENT)
    y += 80

    # Mode label
    d.text((pad, y), "SHADE HUNTER", font=_font(28, bold=True), fill=ACCENT)
    d.text((pad, y + 42), "Tap the tile that's different",
           font=_font(28), fill=TEXT)
    y += 130

    # 6x6 grid
    base_col = (72, 148, 220)
    odd_col = (82, 158, 232)   # slightly different - the target
    odd_r, odd_c = 3, 4
    cols = 6
    rows = 6
    gap = 18
    gw = W - 2 * pad
    tile_w = (gw - gap * (cols - 1)) // cols
    gx = pad
    gy = y
    for r in range(rows):
        for c in range(cols):
            tx = gx + c * (tile_w + gap)
            ty = gy + r * (tile_w + gap)
            col = odd_col if (r == odd_r and c == odd_c) else base_col
            _rounded_rect(d, [tx, ty, tx + tile_w, ty + tile_w], 24,
                          fill=col + (255,))
    y = gy + rows * (tile_w + gap) + 40

    # Hints bar
    _rounded_rect(d, [pad, y, W - pad, y + 150], 30,
                  fill=SURFACE + (255,), outline=SURFACE2 + (255,), width=2)
    hints = [("Hint", ACCENT, "3"), ("Slow", ACCENT3, "2"), ("Skip", ACCENT2, "1")]
    hw = (W - 2 * pad) // 3
    for i, (label, col, n) in enumerate(hints):
        hx = pad + i * hw
        # Coin
        d.ellipse([hx + hw // 2 - 32, y + 24, hx + hw // 2 + 32, y + 88],
                  fill=col + (255,))
        f = _font(36, bold=True)
        nw = d.textlength(n, font=f)
        d.text((hx + hw // 2 - nw / 2, y + 32), n, font=f, fill=BG)
        fl = _font(22, bold=True)
        lw = d.textlength(label, font=fl)
        d.text((hx + hw // 2 - lw / 2, y + 108), label, font=fl, fill=DIM)


def _paint_result(ui):
    """Result screen: trophy + score breakdown + new best badge."""
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 90, int(H * 0.025)), "9:43",
           font=_font(36, bold=True), fill=TEXT)

    y = int(H * 0.08)
    # "NEW BEST" pill
    badge = "NEW BEST"
    f = _font(28, bold=True)
    bw = d.textlength(badge, font=f) + 50
    _rounded_rect(d, [(W - bw) // 2, y, (W + bw) // 2, y + 70], 35,
                  fill=GOLD + (255,))
    d.text(((W - d.textlength(badge, font=f)) // 2, y + 20),
           badge, font=f, fill=BG)
    y += 120

    # Trophy glow
    ui.alpha_composite(_radial_glow(W, H, W // 2, y + 200, GOLD,
                                    max_r=400, alpha_peak=150), (0, 0))
    d = ImageDraw.Draw(ui)
    # Simple trophy shape
    cx = W // 2
    # Cup body
    cup_w = 280
    cup_h = 280
    _rounded_rect(d, [cx - cup_w // 2, y + 60,
                      cx + cup_w // 2, y + 60 + cup_h], 40, fill=GOLD + (255,))
    # Handles
    d.ellipse([cx - cup_w // 2 - 60, y + 100, cx - cup_w // 2 + 20, y + 240],
              outline=GOLD + (255,), width=24)
    d.ellipse([cx + cup_w // 2 - 20, y + 100, cx + cup_w // 2 + 60, y + 240],
              outline=GOLD + (255,), width=24)
    # Star on cup
    f = _font(180, bold=True)
    sw = d.textlength("*", font=f)
    d.text((cx - sw / 2, y + 90), "*", font=f, fill=BG)
    # Base
    _rounded_rect(d, [cx - cup_w // 2 + 30, y + cup_h + 60,
                      cx + cup_w // 2 - 30, y + cup_h + 100],
                  10, fill=GOLD + (255,))
    _rounded_rect(d, [cx - cup_w // 2 - 20, y + cup_h + 100,
                      cx + cup_w // 2 + 20, y + cup_h + 150],
                  14, fill=GOLD + (255,))
    y += cup_h + 210

    # Score big
    f = _font(140, bold=True)
    score = "12,450"
    tw = d.textlength(score, font=f)
    d.text((cx - tw / 2, y), score, font=f, fill=TEXT)
    y += 170
    f = _font(32, bold=True)
    lbl = "SHADE HUNTER  *  LEVEL 14"
    tw = d.textlength(lbl, font=f)
    d.text((cx - tw / 2, y), lbl, font=f, fill=DIM)
    y += 90

    # Breakdown grid
    _rounded_rect(d, [pad, y, W - pad, y + 380], 32,
                  fill=SURFACE + (255,), outline=SURFACE2 + (255,), width=2)
    rows = [
        ("Base", "8,200", TEXT),
        ("Combo x7 bonus", "+2,800", ACCENT2),
        ("Perfect streak", "+1,250", ACCENT),
        ("Coins earned", "+42", GOLD),
    ]
    ry = y + 40
    for name, val, col in rows:
        d.text((pad + 40, ry), name, font=_font(30), fill=DIM)
        fv = _font(34, bold=True)
        vw = d.textlength(val, font=fv)
        d.text((W - pad - 40 - vw, ry), val, font=fv, fill=col)
        ry += 80
    y += 410

    # Buttons
    bh = 140
    # Play again (primary)
    _rounded_rect(d, [pad, y, W - pad, y + bh], 32, fill=ACCENT + (255,))
    f = _font(42, bold=True)
    tw = d.textlength("Play again", font=f)
    d.text(((W - tw) // 2, y + 46), "Play again", font=f, fill=BG)
    y += bh + 24
    # Menu (secondary)
    _rounded_rect(d, [pad, y, W - pad, y + bh], 32,
                  fill=SURFACE + (255,), outline=ACCENT + (255,), width=3)
    tw = d.textlength("Menu", font=f)
    d.text(((W - tw) // 2, y + 46), "Menu", font=f, fill=ACCENT)


def _paint_shop(ui):
    """Shop: hint packs + themes + no-ads."""
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 90, int(H * 0.025)), "9:44",
           font=_font(36, bold=True), fill=TEXT)

    y = int(H * 0.075)
    d.text((pad, y), "SHOP", font=_font(28, bold=True), fill=DIM)
    y += 42
    d.text((pad, y), "Power ups", font=_font(72, bold=True), fill=TEXT)
    y += 120

    # Coin balance
    _rounded_rect(d, [pad, y, W - pad, y + 140], 30,
                  fill=SURFACE + (255,), outline=GOLD + (255,), width=3)
    d.ellipse([pad + 40, y + 35, pad + 110, y + 105], fill=GOLD + (255,))
    d.text((pad + 140, y + 22), "YOUR COINS",
           font=_font(24, bold=True), fill=DIM)
    d.text((pad + 140, y + 58), "428",
           font=_font(58, bold=True), fill=GOLD)
    # Add coins button
    bw = 260
    _rounded_rect(d, [W - pad - 40 - bw, y + 30,
                      W - pad - 40, y + 110], 28, fill=GOLD + (255,))
    f = _font(32, bold=True)
    tw = d.textlength("+ Add coins", font=f)
    d.text((W - pad - 40 - bw + (bw - tw) // 2, y + 56),
           "+ Add coins", font=f, fill=BG)
    y += 180

    # Coin packs
    packs = [
        ("Pocket pack", "100 coins", "$0.99", ACCENT),
        ("Starter pack", "500 coins + 50 bonus", "$3.99", ACCENT3),
        ("Pro pack", "2,000 coins + 400 bonus", "$9.99", ACCENT2),
    ]
    for name, sub, price, col in packs:
        _rounded_rect(d, [pad, y, W - pad, y + 170], 28,
                      fill=SURFACE + (255,), outline=SURFACE2 + (255,), width=2)
        # Coin stack
        for i in range(3):
            d.ellipse([pad + 40, y + 30 + i * 18,
                       pad + 130, y + 100 + i * 18],
                      fill=col + (255,))
        # Text
        d.text((pad + 180, y + 35),
               name, font=_font(38, bold=True), fill=TEXT)
        d.text((pad + 180, y + 90), sub, font=_font(24), fill=DIM)
        # Price
        pw = 180
        _rounded_rect(d, [W - pad - 40 - pw, y + 55,
                          W - pad - 40, y + 125], 26, fill=col + (255,))
        f = _font(30, bold=True)
        tw = d.textlength(price, font=f)
        d.text((W - pad - 40 - pw + (pw - tw) // 2, y + 75),
               price, font=f, fill=BG)
        y += 190

    # No-ads banner
    _rounded_rect(d, [pad, y, W - pad, y + 200], 32,
                  fill=SURFACE + (255,), outline=ACCENT + (255,), width=3)
    d.text((pad + 40, y + 30), "GO PREMIUM",
           font=_font(24, bold=True), fill=ACCENT)
    d.text((pad + 40, y + 68), "Remove ads forever",
           font=_font(38, bold=True), fill=TEXT)
    d.text((pad + 40, y + 124), "One-time purchase. Cloud saves.",
           font=_font(22), fill=DIM)
    # Price pill
    pw = 180
    _rounded_rect(d, [W - pad - 40 - pw, y + 75,
                      W - pad - 40, y + 145], 26, fill=ACCENT + (255,))
    f = _font(30, bold=True)
    tw = d.textlength("$4.99", font=f)
    d.text((W - pad - 40 - pw + (pw - tw) // 2, y + 95),
           "$4.99", font=f, fill=BG)


def _paint_paywall(ui):
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 50, int(H * 0.03)), "X",
           font=_font(60, bold=True), fill=TEXT)

    y = int(H * 0.08)
    _rounded_rect(d, [pad, y, pad + 220, y + 60], 30,
                  fill=(ACCENT[0], ACCENT[1], ACCENT[2], 50))
    d.text((pad + 28, y + 14), "CHROMA+",
           font=_font(24, bold=True), fill=ACCENT)
    y += 100

    d.text((pad, y), "No ads.", font=_font(96, bold=True), fill=TEXT)
    d.text((pad, y + 112), "Unlimited hints.",
           font=_font(96, bold=True), fill=TEXT)
    d.text((pad, y + 224), "Every mode.",
           font=_font(96, bold=True), fill=TEXT)
    y += 380
    d.text((pad, y), "One purchase. Forever yours.",
           font=_font(32), fill=DIM)
    y += 100

    perks = [
        ("No ads, ever", ACCENT),
        ("All 4 game modes", ACCENT3),
        ("+3 exclusive themes", ACCENT2),
        ("Unlimited hints", GOLD),
        ("Cloud saves", SILVER),
    ]
    for title, col in perks:
        cx, cy = pad + 40, y + 40
        d.ellipse([cx - 28, cy - 28, cx + 28, cy + 28], fill=col + (255,))
        d.line([cx - 14, cy + 2, cx - 4, cy + 12], fill=BG, width=6)
        d.line([cx - 4, cy + 12, cx + 16, cy - 10], fill=BG, width=6)
        d.text((pad + 110, y + 20), title, font=_font(34, bold=True), fill=TEXT)
        y += 100

    y += 30
    tiers = [
        ("Chroma+ Lifetime", "Pay once. Keep forever.", "$4.99", True, "BEST DEAL"),
        ("Remove ads only", "Keep the free game.", "$2.99", False, None),
    ]
    for name, desc, price, selected, badge in tiers:
        fill = (ACCENT[0], ACCENT[1], ACCENT[2], 40) if selected else SURFACE + (255,)
        _rounded_rect(d, [pad, y, W - pad, y + 160], 30,
                      fill=fill,
                      outline=ACCENT + (255,) if selected else SURFACE2 + (255,),
                      width=4 if selected else 2)
        cx = pad + 50
        cy = y + 80
        d.ellipse([cx - 24, cy - 24, cx + 24, cy + 24],
                  fill=ACCENT + (255,) if selected else SURFACE + (255,),
                  outline=ACCENT + (255,) if selected else SURFACE2 + (255,), width=4)
        if selected:
            d.line([cx - 10, cy + 2, cx - 2, cy + 10], fill=BG, width=5)
            d.line([cx - 2, cy + 10, cx + 12, cy - 7], fill=BG, width=5)
        name_x = pad + 110
        d.text((name_x, y + 36), name, font=_font(34, bold=True), fill=TEXT)
        if badge:
            nw = _font(34, bold=True).getlength(name)
            bw = _font(18, bold=True).getlength(badge) + 24
            _rounded_rect(d, [int(name_x + nw + 16), y + 40,
                              int(name_x + nw + 16 + bw), y + 76], 18,
                          fill=ACCENT + (255,))
            d.text((int(name_x + nw + 28), y + 46), badge,
                   font=_font(18, bold=True), fill=BG)
        d.text((name_x, y + 88), desc, font=_font(22), fill=DIM)
        pw = _font(38, bold=True).getlength(price)
        d.text((W - pad - 30 - int(pw), y + 58), price,
               font=_font(38, bold=True), fill=TEXT)
        y += 180

    y += 30
    _rounded_rect(d, [pad, y, W - pad, y + 140], 34, fill=ACCENT + (255,))
    f = _font(44, bold=True)
    tw = d.textlength("Unlock ChromaPulse+", font=f)
    d.text(((W - tw) / 2, y + 46), "Unlock ChromaPulse+", font=f, fill=BG)


def render_phone_shot(title, subtitle, painter):
    canvas = _bg(PHONE_W, PHONE_H)
    content_y = _header(canvas, title, subtitle)
    dw = int(PHONE_W * 0.82)
    dh = int(dw * (19.5 / 9))
    device, inner = _device_frame(dw, dh)
    ui = Image.new("RGBA", (inner[2] - inner[0], inner[3] - inner[1]), BG + (255,))
    painter(ui)
    device.paste(ui, (inner[0], inner[1]), ui)
    sh = Image.new("RGBA", device.size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle(
        [20, 40, dw - 20, dh - 20],
        radius=int(min(dw, dh) * 0.09),
        fill=(0, 0, 0, 180),
    )
    sh = sh.filter(ImageFilter.GaussianBlur(50))
    dx = (PHONE_W - dw) // 2
    dy = content_y
    canvas.alpha_composite(sh, (dx, dy))
    canvas.alpha_composite(device, (dx, dy))
    return canvas


def render_feature_graphic():
    w, h = 1024, 500
    canvas = _bg(w, h)
    d = ImageDraw.Draw(canvas)
    if os.path.exists(ICON_PATH):
        icon = Image.open(ICON_PATH).convert("RGBA").resize((220, 220), Image.LANCZOS)
        canvas.alpha_composite(_radial_glow(w, h, 190, 250, ACCENT,
                                            max_r=300, alpha_peak=140))
        canvas.alpha_composite(icon, (80, 140))
    d = ImageDraw.Draw(canvas)
    d.text((340, 150), "ChromaPulse",
           font=_font(78, bold=True), fill=TEXT)
    d.text((340, 240), "Train your color eye.",
           font=_font(36, bold=True), fill=ACCENT)
    d.text((340, 310), "4 color-perception modes.",
           font=_font(30), fill=TEXT)
    d.text((340, 360), "Seconds per round. Endless replay.",
           font=_font(30), fill=DIM)
    return canvas


def render_og_card():
    w, h = 1200, 630
    canvas = _bg(w, h)
    if os.path.exists(ICON_PATH):
        icon = Image.open(ICON_PATH).convert("RGBA").resize((260, 260), Image.LANCZOS)
        canvas.alpha_composite(_radial_glow(w, h, 230, 310, ACCENT3,
                                            max_r=400, alpha_peak=160))
        canvas.alpha_composite(icon, (100, 180))
    d = ImageDraw.Draw(canvas)
    d.text((400, 190), "ChromaPulse",
           font=_font(84, bold=True), fill=TEXT)
    d.text((400, 290), "Train your color eye.",
           font=_font(48, bold=True), fill=ACCENT)
    d.text((400, 360), "4 modes. Seconds per round.",
           font=_font(36), fill=TEXT)
    d.text((400, 410), "Endless replay.",
           font=_font(36), fill=TEXT)
    d.text((400, 500), "nalhamzy.github.io/chromapulse",
           font=_font(28, bold=True), fill=DIM)
    return canvas


def main():
    os.makedirs(os.path.join(OUT, "phone"), exist_ok=True)
    os.makedirs(os.path.join(OUT, "tablet"), exist_ok=True)
    os.makedirs(os.path.join(OUT, "android"), exist_ok=True)

    print("> feature graphic")
    render_feature_graphic().convert("RGB").save(
        os.path.join(OUT, "feature_graphic_1024x500.png"))
    print("> og card")
    render_og_card().convert("RGB").save(
        os.path.join(OUT, "og_card_1200x630.png"))

    shots = [
        ("01_menu", "Four ways to see color.",
         "Pick a mode. Play in seconds.", _paint_menu),
        ("02_gameplay", "Spot the odd tile.",
         "Fast grids. Rising difficulty.", _paint_gameplay),
        ("03_result", "Combos. Streaks. New bests.",
         "Climb the leaderboard.", _paint_result),
        ("04_shop", "Earn coins. Buy hints.",
         "Or skip the grind.", _paint_shop),
        ("05_paywall", "One purchase. Forever.",
         "Chroma+ removes ads & unlocks everything.",
         _paint_paywall),
    ]
    for name, title, sub, painter in shots:
        print(f"> phone/{name}.png")
        img = render_phone_shot(title, sub, painter)
        img.convert("RGB").save(os.path.join(OUT, "phone", f"{name}.png"), optimize=True)

    if os.path.exists(ICON_PATH):
        print("> android/icon-512.png")
        Image.open(ICON_PATH).convert("RGB").resize((512, 512), Image.LANCZOS).save(
            os.path.join(OUT, "android", "icon-512.png"))

    # Tablet shots
    tablet_titles = {
        "01_menu": "Four ways to see color",
        "02_gameplay": "Spot the odd tile",
        "03_result": "Combos. Streaks. New bests",
        "04_shop": "Earn coins. Buy hints",
        "05_paywall": "Chroma+ - one purchase, forever",
    }
    for name, _t, _s, painter in shots:
        print(f"> tablet/{name}.png")
        canvas = _bg(TABLET_W, TABLET_H)
        d = ImageDraw.Draw(canvas)
        title = tablet_titles[name]
        f = _font(130, bold=True)
        tw = d.textlength(title, font=f)
        d.text(((TABLET_W - tw) // 2, int(TABLET_H * 0.05)), title,
               font=f, fill=TEXT)
        dw = int(TABLET_W * 0.58)
        dh = int(dw * (19.5 / 9))
        device, inner = _device_frame(dw, dh)
        ui = Image.new("RGBA", (inner[2] - inner[0], inner[3] - inner[1]), BG + (255,))
        painter(ui)
        device.paste(ui, (inner[0], inner[1]), ui)
        sh = Image.new("RGBA", device.size, (0, 0, 0, 0))
        ImageDraw.Draw(sh).rounded_rectangle(
            [20, 40, dw - 20, dh - 20],
            radius=int(min(dw, dh) * 0.09),
            fill=(0, 0, 0, 180),
        )
        sh = sh.filter(ImageFilter.GaussianBlur(50))
        dx = (TABLET_W - dw) // 2
        dy = int(TABLET_H * 0.18)
        canvas.alpha_composite(sh, (dx, dy))
        canvas.alpha_composite(device, (dx, dy))
        canvas.convert("RGB").save(
            os.path.join(OUT, "tablet", f"{name}.png"), optimize=True)

    print("\nAll ChromaPulse store assets emitted to:")
    print(f"  {OUT}")


if __name__ == "__main__":
    main()
