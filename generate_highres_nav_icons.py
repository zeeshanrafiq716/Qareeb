import math
from PIL import Image, ImageDraw

SIZE = 512
PADDING = 40
CANVAS_SIZE = (SIZE, SIZE)

def create_home_icon():
    img = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 512x512 coordinate space
    w, h = SIZE, SIZE
    
    # Draw rounded cottage/pentagon
    # Peak at (w*0.5, h*0.08), right shoulder (w*0.86, h*0.40), right bottom (w*0.83, h*0.92)
    # left bottom (w*0.17, h*0.92), left shoulder (w*0.14, h*0.40)
    # Using smooth polygon with antialiasing by drawing on 4x super-sampled canvas
    ss_size = SIZE * 4
    ss_img = Image.new("RGBA", (ss_size, ss_size), (0, 0, 0, 0))
    ss_draw = ImageDraw.Draw(ss_img)
    sw, sh = ss_size, ss_size
    
    # Peak, right shoulder, right bottom, left bottom, left shoulder
    points = [
        (sw * 0.5, sh * 0.08),
        (sw * 0.86, sh * 0.38),
        (sw * 0.83, sh * 0.90),
        (sw * 0.17, sh * 0.90),
        (sw * 0.14, sh * 0.38),
    ]
    ss_draw.polygon(points, fill=(255, 255, 255, 255))
    
    # Round corners by drawing circles at vertices and thick lines
    corner_r = sw * 0.04
    for pt in points:
        ss_draw.ellipse([pt[0] - corner_r, pt[1] - corner_r, pt[0] + corner_r, pt[1] + corner_r], fill=(255, 255, 255, 255))
    
    # Cutout slit: centered at (sw*0.5, sh*0.72), width sw*0.40, height sh*0.12
    slit_w = sw * 0.40
    slit_h = sh * 0.12
    slit_cx = sw * 0.5
    slit_cy = sh * 0.72
    slit_rect = [slit_cx - slit_w/2, slit_cy - slit_h/2, slit_cx + slit_w/2, slit_cy + slit_h/2]
    ss_draw.rounded_rectangle(slit_rect, radius=slit_h/2, fill=(0, 0, 0, 0))
    
    # Downsample with high-quality Lanczos resampling
    img = ss_img.resize(CANVAS_SIZE, Image.Resampling.LANCZOS)
    return img

def create_request_icon():
    ss_size = SIZE * 4
    ss_img = Image.new("RGBA", (ss_size, ss_size), (0, 0, 0, 0))
    ss_draw = ImageDraw.Draw(ss_img)
    sw, sh = ss_size, ss_size
    stroke_w = int(sw * 0.065)
    
    # Diamond points with rounded corners
    # (sw*0.5, sh*0.10), (sw*0.90, sh*0.50), (sw*0.5, sh*0.90), (sw*0.10, sh*0.50)
    # Draw rounded diamond using path or line segments with round caps
    diamond = [
        (sw * 0.5, sh * 0.10),
        (sw * 0.90, sh * 0.50),
        (sw * 0.5, sh * 0.90),
        (sw * 0.10, sh * 0.50),
        (sw * 0.5, sh * 0.10)
    ]
    ss_draw.line(diamond, fill=(255, 255, 255, 255), width=stroke_w, joint="curve")
    
    # Rounded corners for diamond
    corner_r = stroke_w / 2
    for pt in diamond:
        ss_draw.ellipse([pt[0] - corner_r, pt[1] - corner_r, pt[0] + corner_r, pt[1] + corner_r], fill=(255, 255, 255, 255))
    
    # Inner curved arrow
    # Arc from (sw*0.38, sh*0.62) to (sw*0.64, sh*0.44)
    # Approximate bezier curve
    curve_pts = []
    p0 = (sw * 0.38, sh * 0.62)
    p1 = (sw * 0.40, sh * 0.44)
    p2 = (sw * 0.64, sh * 0.44)
    for i in range(21):
        t = i / 20.0
        x = (1-t)**2 * p0[0] + 2*(1-t)*t * p1[0] + t**2 * p2[0]
        y = (1-t)**2 * p0[1] + 2*(1-t)*t * p1[1] + t**2 * p2[1]
        curve_pts.append((x, y))
    ss_draw.line(curve_pts, fill=(255, 255, 255, 255), width=stroke_w, joint="curve")
    
    # Arrow head: (sw*0.54, sh*0.34) -> (sw*0.65, sh*0.44) -> (sw*0.54, sh*0.54)
    arrow_head = [
        (sw * 0.54, sh * 0.34),
        (sw * 0.65, sh * 0.44),
        (sw * 0.54, sh * 0.54)
    ]
    ss_draw.line(arrow_head, fill=(255, 255, 255, 255), width=stroke_w, joint="curve")
    for pt in arrow_head:
        ss_draw.ellipse([pt[0] - corner_r, pt[1] - corner_r, pt[0] + corner_r, pt[1] + corner_r], fill=(255, 255, 255, 255))

    img = ss_img.resize(CANVAS_SIZE, Image.Resampling.LANCZOS)
    return img

def create_profile_icon():
    ss_size = SIZE * 4
    ss_img = Image.new("RGBA", (ss_size, ss_size), (0, 0, 0, 0))
    ss_draw = ImageDraw.Draw(ss_img)
    sw, sh = ss_size, ss_size
    stroke_w = int(sw * 0.065)
    
    # 1. Head circle: center (sw*0.5, sh*0.30), radius sw*0.17
    cx, cy = sw * 0.5, sh * 0.30
    r = sw * 0.17
    ss_draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(255, 255, 255, 255), width=stroke_w)
    
    # 2. Shoulder dome/arc:
    # From (sw*0.22, sh*0.88) up to shoulders (sw*0.5, sh*0.56) and down to (sw*0.78, sh*0.88)
    shoulder_box = [sw * 0.22, sh * 0.56, sw * 0.78, sh * 1.10]
    ss_draw.arc(shoulder_box, start=180, end=0, fill=(255, 255, 255, 255), width=stroke_w)
    # Bottom straight line
    ss_draw.line([(sw * 0.22, sh * 0.83), (sw * 0.78, sh * 0.83)], fill=(255, 255, 255, 255), width=stroke_w)
    
    img = ss_img.resize(CANVAS_SIZE, Image.Resampling.LANCZOS)
    return img

if __name__ == "__main__":
    home = create_home_icon()
    home.save("mobile/assets/images/Vector1.png", "PNG")
    print("Vector1.png saved at", home.size)
    
    req = create_request_icon()
    req.save("mobile/assets/images/Vector2.png", "PNG")
    print("Vector2.png saved at", req.size)
    
    prof = create_profile_icon()
    prof.save("mobile/assets/images/vector3.png", "PNG")
    print("vector3.png saved at", prof.size)
