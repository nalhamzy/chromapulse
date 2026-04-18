"""ChromaPulse icon generator.

Produces a 1024x1024 brand icon at:
  assets/icon/icon_source.png            (source for flutter_launcher_icons)
  ios/.../Icon-App-1024x1024@1x.png      (App Store marketing icon)
  store_assets/android/icon-512.png      (Play Store hi-res icon)

Concept: 2x2 grid of vibrant color tiles on a dark gradient ground, with a
soft neon glow underneath. Mirrors the core gameplay (matching color tiles)
and reads cleanly at every size from 16px up. The bottom-right tile is a
slightly off shade — a subtle "spot the odd tile" Easter egg for fans.
"""
from __future__ import annotations
import os
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SOURCE_OUT = os.path.join(ROOT, "assets", "icon", "icon_source.png")
IOS_OUT = os.path.join(
    ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset",
    "Icon-App-1024x1024@1x.png",
)
STORE_OUT = os.path.join(ROOT, "store_assets", "android", "icon-512.png")

SIZE = 1024

# Brand palette (lib/core/constants/app_colors.dart)
BG_DARK = (10, 10, 15)
BG_MID = (28, 28, 50)
MINT = (0, 255, 170)
CORAL = (255, 51, 102)
PURPLE = (123, 97, 255)
GOLD = (255, 215, 0)


def _radial_glow(w, h, cx, cy, color, max_r, alpha_peak=160, steps=28):
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(steps):
        t = 1 - i / steps
        a = int(alpha_peak * t * t)
        rr = int(max_r * (1 - i / steps))
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr],
                  fill=(color[0], color[1], color[2], a))
    return layer.filter(ImageFilter.GaussianBlur(max_r // 5))


def _vertical_gradient(w, h, top, bottom):
    base = Image.new("RGBA", (w, h), bottom + (255,))
    grad = Image.new("RGBA", (1, h))
    for y in range(h):
        t = y / max(h - 1, 1)
        r = int(top[0] * (1 - t) + bottom[0] * t)
        g = int(top[1] * (1 - t) + bottom[1] * t)
        b = int(top[2] * (1 - t) + bottom[2] * t)
        grad.putpixel((0, y), (r, g, b, 255))
    base.paste(grad.resize((w, h)))
    return base


def _round_mask(w, h, radius):
    m = Image.new("L", (w, h), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, w, h], radius=radius, fill=255)
    return m


def _shaded_tile(w, h, base_color, highlight_alpha=70, shadow_alpha=70):
    """A color tile with a subtle vertical gradient for depth."""
    img = Image.new("RGBA", (w, h), base_color + (255,))
    # Highlight (top-left) overlay
    hl = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(hl)
    for i in range(40):
        t = 1 - i / 40
        a = int(highlight_alpha * t)
        d.ellipse([-w * 0.3 + i * 4, -h * 0.3 + i * 4,
                   w * 0.6 + i * 4, h * 0.6 + i * 4],
                  fill=(255, 255, 255, a))
    hl = hl.filter(ImageFilter.GaussianBlur(60))
    img.alpha_composite(hl)
    # Shadow (bottom-right)
    sh = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d2 = ImageDraw.Draw(sh)
    d2.ellipse([w * 0.3, h * 0.3, w * 1.4, h * 1.4],
               fill=(0, 0, 0, shadow_alpha))
    sh = sh.filter(ImageFilter.GaussianBlur(80))
    img.alpha_composite(sh)
    return img


def render_icon(size=SIZE):
    # ----- Background: deep gradient + dual neon glows -----
    bg = _vertical_gradient(size, size, BG_MID, BG_DARK)
    bg.alpha_composite(_radial_glow(size, size,
                                    int(size * 0.30), int(size * 0.32),
                                    PURPLE, max_r=int(size * 0.85),
                                    alpha_peak=140))
    bg.alpha_composite(_radial_glow(size, size,
                                    int(size * 0.72), int(size * 0.72),
                                    MINT, max_r=int(size * 0.85),
                                    alpha_peak=110))

    # ----- Tiles: 2x2 with gap, all rounded, on shared rounded backplate -----
    # Backplate gives a unified card silhouette so it reads as one mark.
    plate_pad = int(size * 0.18)
    plate_box = (plate_pad, plate_pad, size - plate_pad, size - plate_pad)
    plate_w = plate_box[2] - plate_box[0]
    plate_radius = int(plate_w * 0.18)

    # Soft glow under the plate so the mark "lifts" off the dark bg
    plate_glow = _radial_glow(size, size, size // 2, int(size * 0.55),
                              MINT, max_r=int(size * 0.55), alpha_peak=120)
    bg.alpha_composite(plate_glow)

    # Subtle dark plate behind tiles to anchor them visually
    plate_back = Image.new("RGBA", (plate_w, plate_w), (0, 0, 0, 0))
    pd = ImageDraw.Draw(plate_back)
    pd.rounded_rectangle([0, 0, plate_w, plate_w],
                         radius=plate_radius,
                         fill=(8, 8, 14, 220))
    bg.alpha_composite(plate_back, (plate_box[0], plate_box[1]))

    # 2x2 tile grid
    gap = int(plate_w * 0.05)
    tile_size = (plate_w - gap) // 2
    tile_radius = int(tile_size * 0.22)

    # Tiles: (color, slight off-shade flag)
    # Bottom-right tile is the "odd one out" - subtly brighter purple
    tiles = [
        [MINT, (255, 92, 122)],          # top-row : mint, coral
        [PURPLE, (147, 121, 255)],       # bot-row : purple, off-purple
    ]

    for row in range(2):
        for col in range(2):
            color = tiles[row][col]
            tile = _shaded_tile(tile_size, tile_size, color)
            mask = _round_mask(tile_size, tile_size, tile_radius)

            tx = plate_box[0] + col * (tile_size + gap)
            ty = plate_box[1] + row * (tile_size + gap)

            # Tile shadow (slight offset, soft)
            shadow = Image.new("RGBA", (tile_size + 60, tile_size + 60),
                               (0, 0, 0, 0))
            sd = ImageDraw.Draw(shadow)
            sd.rounded_rectangle(
                [30, 30 + 18, tile_size + 30, tile_size + 30 + 18],
                radius=tile_radius,
                fill=(color[0] // 4, color[1] // 4, color[2] // 4, 200),
            )
            shadow = shadow.filter(ImageFilter.GaussianBlur(28))
            bg.alpha_composite(shadow, (tx - 30, ty - 30))

            # Tile itself
            shaped = Image.new("RGBA", (tile_size, tile_size), (0, 0, 0, 0))
            shaped.paste(tile, (0, 0), mask)
            bg.alpha_composite(shaped, (tx, ty))

            # Inner highlight stroke for crispness
            sd2 = ImageDraw.Draw(bg)
            # Bright edge (1px) at top-left
            sd2.rounded_rectangle(
                [tx, ty, tx + tile_size, ty + tile_size],
                radius=tile_radius,
                outline=(255, 255, 255, 90), width=2,
            )

    # ----- Centered "pulse" dot at the tile seam -----
    cx = plate_box[0] + tile_size + gap // 2
    cy = plate_box[1] + tile_size + gap // 2
    pulse_r = int(plate_w * 0.055)
    # Tight mint glow (much smaller + lower alpha so it doesn't muddy tiles)
    bg.alpha_composite(_radial_glow(size, size, cx, cy, MINT,
                                    max_r=int(plate_w * 0.18),
                                    alpha_peak=140))
    pd = ImageDraw.Draw(bg)
    # Mint outer ring
    ring_r = int(pulse_r * 1.6)
    pd.ellipse([cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r],
               fill=MINT + (255,))
    # White core
    pd.ellipse([cx - pulse_r, cy - pulse_r, cx + pulse_r, cy + pulse_r],
               fill=(255, 255, 255, 255))

    return bg


def render_for_ios_no_alpha(img):
    """App Store requires opaque RGB. Composite onto solid bg color."""
    flat = Image.new("RGB", img.size, BG_DARK)
    flat.paste(img.convert("RGBA"), (0, 0), img.convert("RGBA"))
    return flat


def main():
    icon = render_icon(SIZE)

    # 1) Source for flutter_launcher_icons
    os.makedirs(os.path.dirname(SOURCE_OUT), exist_ok=True)
    icon.save(SOURCE_OUT, optimize=True)
    print(f"> {os.path.relpath(SOURCE_OUT, ROOT)}")

    # 2) iOS App Store marketing icon (no alpha)
    os.makedirs(os.path.dirname(IOS_OUT), exist_ok=True)
    render_for_ios_no_alpha(icon).save(IOS_OUT, optimize=True)
    print(f"> {os.path.relpath(IOS_OUT, ROOT)}")

    # 3) Play Store hi-res 512 icon
    os.makedirs(os.path.dirname(STORE_OUT), exist_ok=True)
    icon.resize((512, 512), Image.LANCZOS).convert("RGB").save(
        STORE_OUT, optimize=True)
    print(f"> {os.path.relpath(STORE_OUT, ROOT)}")

    print("\nIcon generated. Next:")
    print("  flutter pub get")
    print("  flutter pub run flutter_launcher_icons")
    print("  python tools/gen_store_assets.py   # refresh screenshots")


if __name__ == "__main__":
    main()
