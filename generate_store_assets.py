import os
import math
import shutil
from PIL import Image, ImageDraw, ImageFont, ImageFilter

PROJECT_ROOT = r'c:\src\on-korean'
IMGS_DIR = os.path.join(PROJECT_ROOT, 'imgs')
OUTPUT_DIR = os.path.join(PROJECT_ROOT, 'store_assets')
ONBOARDING_DIR = os.path.join(PROJECT_ROOT, 'assets', 'onboarding')
ICON_PATH = os.path.join(PROJECT_ROOT, 'store_icon_512.png')

# Fonts
FONT_KO_BOLD = r'C:\Windows\Fonts\malgunbd.ttf'
FONT_KO_REG = r'C:\Windows\Fonts\malgun.ttf'
FONT_EN_BOLD = r'C:\Windows\Fonts\segoeuib.ttf'
FONT_EN_REG = r'C:\Windows\Fonts\segoeui.ttf'
FONT_JA_BOLD = r'C:\Windows\Fonts\meiryob.ttc'
FONT_JA_REG = r'C:\Windows\Fonts\meiryo.ttc'

def clean_screenshot(img_path, screen_type='card'):
    """
    Loads screenshot and cleanly removes ad banners:
    - 'home' / 'stats': shifts the bottom navigation bar (y: 2515..2811) up to y=2327 to cover the ad banner,
      and extends the bottom bar background color down to the bottom (2811).
    - 'ailab' / 'card': the ad is at the very bottom (y: 2620..2811). Fills it with the page background color.
    """
    im = Image.open(img_path).convert('RGBA')
    w, h = im.size
    
    if screen_type in ('home', 'stats'):
        # Ad is y: 2327..2514. Bottom bar is y: 2515..2811 (height 296)
        nav_bg = im.getpixel((50, 2750))
        bottom_bar = im.crop((0, 2515, w, h))
        im.paste(bottom_bar, (0, 2327))
        draw = ImageDraw.Draw(im)
        draw.rectangle([(0, 2327 + bottom_bar.height), (w, h)], fill=nav_bg)
    elif screen_type in ('ailab', 'card'):
        # Ad is y: 2620..2811
        page_bg = im.getpixel((50, 2550))
        draw = ImageDraw.Draw(im)
        draw.rectangle([(0, 2620), (w, h)], fill=page_bg)
        
    return im

def create_rounded_mask(size, radius):
    """Creates a high-quality anti-aliased rounded rectangle mask."""
    scale = 4
    w, h = size[0] * scale, size[1] * scale
    r = radius * scale
    mask = Image.new('L', (w, h), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), (w, h)], radius=r, fill=255)
    return mask.resize(size, Image.Resampling.LANCZOS)

def draw_star(draw, cx, cy, r, fill):
    """Draws a 5-pointed star polygon centered at (cx, cy)."""
    points = []
    for i in range(10):
        angle = i * math.pi / 5 - math.pi / 2
        radius = r if i % 2 == 0 else r * 0.42
        x = cx + radius * math.cos(angle)
        y = cy + radius * math.sin(angle)
        points.append((x, y))
    draw.polygon(points, fill=fill)

def draw_vector_checkmark(draw, cx, cy, color, stroke_w=2):
    """Draws a crisp anti-aliased checkmark icon centered at (cx, cy)."""
    p1 = (cx - 4, cy - 1)
    p2 = (cx - 1, cy + 3)
    p3 = (cx + 5, cy - 4)
    draw.line([p1, p2, p3], fill=color, width=stroke_w, joint='curve')

def create_phone_mockup(screenshot, target_w=710, corner_radius=46, bezel=13, shadow_blur=35, shadow_opacity=180):
    """
    Renders a sleek modern smartphone frame around the screenshot with realistic bezels,
    punch-hole camera, and subtle reflection.
    """
    orig_w, orig_h = screenshot.size
    aspect = orig_h / orig_w
    screen_w = target_w
    screen_h = int(screen_w * aspect)
    
    resized_screen = screenshot.resize((screen_w, screen_h), Image.Resampling.LANCZOS)
    screen_mask = create_rounded_mask((screen_w, screen_h), radius=int(corner_radius * 0.8))
    
    frame_w = screen_w + bezel * 2
    frame_h = screen_h + bezel * 2
    
    frame = Image.new('RGBA', (frame_w, frame_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(frame)
    
    # Outer metallic rim
    draw.rounded_rectangle([(0, 0), (frame_w, frame_h)], radius=corner_radius, fill=(26, 26, 32, 255), outline=(72, 72, 88, 255), width=2)
    # Inner dark bezel
    draw.rounded_rectangle([(3, 3), (frame_w - 3, frame_h - 3)], radius=corner_radius - 2, fill=(10, 10, 12, 255))
    
    # Paste masked screen
    frame.paste(resized_screen, (bezel, bezel), screen_mask)
    
    # Subtle inner border for glass effect
    draw = ImageDraw.Draw(frame)
    draw.rounded_rectangle([(bezel, bezel), (bezel + screen_w, bezel + screen_h)], radius=int(corner_radius * 0.8), outline=(255, 255, 255, 30), width=1)
    
    # Camera punch-hole
    cam_r = 7
    cam_x = frame_w // 2
    cam_y = bezel + 22
    draw.ellipse([(cam_x - cam_r, cam_y - cam_r), (cam_x + cam_r, cam_y + cam_r)], fill=(12, 12, 16, 255), outline=(35, 35, 45, 255), width=1)
    draw.ellipse([(cam_x - 2, cam_y - 2), (cam_x + 2, cam_y + 2)], fill=(20, 25, 45, 200)) # camera lens tint
    
    # Generate shadow
    shadow_margin = shadow_blur * 2
    shadow_w = frame_w + shadow_margin * 2
    shadow_h = frame_h + shadow_margin * 2
    
    shadow_layer = Image.new('RGBA', (shadow_w, shadow_h), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    shadow_draw.rounded_rectangle(
        [(shadow_margin, shadow_margin + 12), (shadow_margin + frame_w, shadow_margin + frame_h + 12)],
        radius=corner_radius,
        fill=(0, 0, 0, shadow_opacity)
    )
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(shadow_blur))
    
    # Composite frame over shadow
    mockup = shadow_layer
    mockup.paste(frame, (shadow_margin, shadow_margin), frame)
    return mockup, shadow_margin

def generate_store_screenshot(
    screenshot_path,
    badge_text,
    title_text,
    subtitle_text,
    font_bold_path,
    font_reg_path,
    screen_type,
    output_path,
    canvas_w=1080,
    canvas_h=1920
):
    """
    Composes a 1080x1920 Google Play store screenshot with:
    - Premium deep indigo-slate vertical gradient background
    - Pill badge with glowing accent border
    - Clear bold typographic hierarchy
    - Centered modern phone mockup
    """
    canvas = Image.new('RGBA', (canvas_w, canvas_h), (0, 0, 0, 255))
    draw = ImageDraw.Draw(canvas)
    
    # Background gradient: Deep slate (16, 24, 40) -> Rich navy (11, 15, 29)
    for y in range(canvas_h):
        t = y / float(canvas_h)
        r = int(16 * (1 - t) + 9 * t)
        g = int(24 * (1 - t) + 13 * t)
        b = int(40 * (1 - t) + 24 * t)
        draw.line([(0, y), (canvas_w, y)], fill=(r, g, b, 255))
        
    # Top subtle radial glow
    glow = Image.new('RGBA', (canvas_w, 600), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse([(-200, -300), (canvas_w + 200, 500)], fill=(79, 70, 229, 38))
    glow = glow.filter(ImageFilter.GaussianBlur(90))
    canvas.paste(glow, (0, 0), glow)
    
    draw = ImageDraw.Draw(canvas)
    
    # Fonts
    badge_font = ImageFont.truetype(font_bold_path, 28)
    title_font = ImageFont.truetype(font_bold_path, 54)
    sub_font = ImageFont.truetype(font_reg_path, 32)
    
    # 1. Pill Badge
    bbox = badge_font.getbbox(badge_text)
    bw = bbox[2] - bbox[0]
    bh = bbox[3] - bbox[1]
    
    pad_x = 24
    pad_y = 12
    badge_w = bw + pad_x * 2
    badge_h = bh + pad_y * 2
    badge_x = (canvas_w - badge_w) // 2
    badge_y = 125
    
    draw.rounded_rectangle(
        [(badge_x, badge_y), (badge_x + badge_w, badge_y + badge_h)],
        radius=badge_h // 2,
        fill=(30, 41, 59, 230),
        outline=(99, 102, 241, 200),
        width=2
    )
    draw.text((badge_x + pad_x, badge_y + pad_y - 2), badge_text, font=badge_font, fill=(199, 210, 254, 255))
    
    # 2. Main Title (White)
    t_bbox = title_font.getbbox(title_text)
    tw = t_bbox[2] - t_bbox[0]
    draw.text(((canvas_w - tw) // 2, badge_y + badge_h + 28), title_text, font=title_font, fill=(255, 255, 255, 255))
    
    # 3. Subtitle (Subtle Slate/Silver)
    s_bbox = sub_font.getbbox(subtitle_text)
    sw = s_bbox[2] - s_bbox[0]
    draw.text(((canvas_w - sw) // 2, badge_y + badge_h + 104), subtitle_text, font=sub_font, fill=(156, 163, 175, 255))
    
    # 4. Clean and assemble phone mockup
    raw_ss = clean_screenshot(screenshot_path, screen_type)
    mockup, shadow_margin = create_phone_mockup(raw_ss, target_w=730, corner_radius=48, bezel=14)
    
    # Center phone mockup horizontally, anchor starting at y=450
    mockup_x = (canvas_w - mockup.width) // 2
    mockup_y = 425
    canvas.paste(mockup, (mockup_x, mockup_y), mockup)
    
    # Save optimized PNG
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    canvas.convert('RGB').save(output_path, 'PNG', optimize=True)
    print(f'Screenshot saved: {output_path}')

def generate_feature_graphic(
    screenshot_1_path,
    screenshot_2_path,
    app_name,
    slogan,
    bullets,
    badge_text,
    font_bold_path,
    font_reg_path,
    output_path,
    canvas_w=1024,
    canvas_h=500
):
    """
    Renders Google Play 1024x500 Feature Graphic with:
    - Left side: High-contrast title, rating/badge, value propositions with checkmarks
    - Right side: 2 stylish angled phone mockups
    - Sleek dark background with ambient glow
    """
    canvas = Image.new('RGBA', (canvas_w, canvas_h), (0, 0, 0, 255))
    draw = ImageDraw.Draw(canvas)
    
    # Gradient background: rich deep slate -> indigo dark
    for x in range(canvas_w):
        t = x / float(canvas_w)
        r = int(15 * (1 - t) + 11 * t)
        g = int(23 * (1 - t) + 15 * t)
        b = int(42 * (1 - t) + 32 * t)
        draw.line([(x, 0), (x, canvas_h)], fill=(r, g, b, 255))
        
    # Ambient corner light
    light = Image.new('RGBA', (600, 500), (0, 0, 0, 0))
    light_draw = ImageDraw.Draw(light)
    light_draw.ellipse([(-150, -100), (500, 400)], fill=(79, 70, 229, 45))
    light = light.filter(ImageFilter.GaussianBlur(100))
    canvas.paste(light, (0, 0), light)
    
    draw = ImageDraw.Draw(canvas)
    
    # 1. Left Hero Branding
    brand_x = 58
    
    # App Icon (if exists)
    curr_y = 52
    if os.path.exists(ICON_PATH):
        try:
            icon_img = Image.open(ICON_PATH).convert('RGBA').resize((76, 76), Image.Resampling.LANCZOS)
            icon_mask = create_rounded_mask((76, 76), radius=18)
            canvas.paste(icon_img, (brand_x, curr_y), icon_mask)
            
            # App Name beside icon
            app_font = ImageFont.truetype(font_bold_path, 38)
            draw.text((brand_x + 94, curr_y + 4), app_name, font=app_font, fill=(255, 255, 255, 255))
            
            # Badge pill below app name
            pill_font = ImageFont.truetype(font_bold_path, 16)
            pill_bbox = pill_font.getbbox(badge_text)
            pw = pill_bbox[2] - pill_bbox[0] + 32
            ph = pill_bbox[3] - pill_bbox[1] + 10
            
            draw.rounded_rectangle(
                [(brand_x + 94, curr_y + 46), (brand_x + 94 + pw, curr_y + 46 + ph)],
                radius=ph // 2,
                fill=(30, 41, 59, 230),
                outline=(99, 102, 241, 200),
                width=1
            )
            # Star icon inside pill
            draw_star(draw, brand_x + 106, curr_y + 46 + ph // 2, 5, fill=(251, 191, 36, 255))
            draw.text((brand_x + 118, curr_y + 47), badge_text, font=pill_font, fill=(224, 231, 255, 255))
            
            curr_y += 102
        except Exception as e:
            print(f"Error loading icon for feature graphic: {e}")
            curr_y += 20
            
    # Slogan Title
    slogan_font = ImageFont.truetype(font_bold_path, 25)
    draw.text((brand_x, curr_y), slogan, font=slogan_font, fill=(248, 250, 252, 255))
    curr_y += 48
    
    # Horizontal divider line
    draw.line([(brand_x, curr_y), (brand_x + 440, curr_y)], fill=(51, 65, 85, 255), width=1)
    curr_y += 24
    
    # Value proposition bullets
    bullet_font = ImageFont.truetype(font_reg_path, 18)
    for b_text in bullets:
        # Checkmark pill
        chk_r = 10
        chk_cx = brand_x + chk_r
        chk_cy = curr_y + 11
        draw.ellipse([(chk_cx - chk_r, chk_cy - chk_r), (chk_cx + chk_r, chk_cy + chk_r)], fill=(49, 46, 129, 255), outline=(99, 102, 241, 255))
        draw_vector_checkmark(draw, chk_cx, chk_cy, color=(165, 180, 252, 255), stroke_w=2)
        
        draw.text((brand_x + 30, curr_y), b_text, font=bullet_font, fill=(203, 213, 225, 255))
        curr_y += 34
        
    # 2. Right Side: 2 Sleek Floating Phone Mockups
    ss2 = clean_screenshot(screenshot_2_path, 'card')
    phone2, _ = create_phone_mockup(ss2, target_w=230, corner_radius=22, bezel=6, shadow_blur=20, shadow_opacity=190)
    phone2_rot = phone2.rotate(8, resample=Image.Resampling.BICUBIC, expand=True)
    canvas.paste(phone2_rot, (735, 45), phone2_rot)
    
    ss1 = clean_screenshot(screenshot_1_path, 'home')
    phone1, _ = create_phone_mockup(ss1, target_w=248, corner_radius=24, bezel=7, shadow_blur=28, shadow_opacity=220)
    phone1_rot = phone1.rotate(-6, resample=Image.Resampling.BICUBIC, expand=True)
    canvas.paste(phone1_rot, (530, 25), phone1_rot)
    
    # Save optimized PNG
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    canvas.convert('RGB').save(output_path, 'PNG', optimize=True)
    print(f'Feature graphic saved: {output_path}')

def main():
    for lang in ['ko', 'en', 'ja']:
        os.makedirs(os.path.join(OUTPUT_DIR, lang), exist_ok=True)
        os.makedirs(os.path.join(ONBOARDING_DIR, lang), exist_ok=True)
        
    # ----------------------------------------------------
    # 1. KOREAN (한국어)
    # ----------------------------------------------------
    ko_ss = [
        (
            'Screenshot_20261024_142509_OnKorean.jpg',
            '매일 10단어 SRS',
            '작심삼일을 넘어 매일 완성하는 한국어 습관',
            '하루 10단어로 부담 없이 채우는 실전 한국어 어휘력',
            'home',
            'screenshot_1_home.png'
        ),
        (
            'Screenshot_20261024_142517_OnKorean.jpg',
            '스마트 플래시카드',
            '원어민 발음 & AI 실전 예문으로 생생한 암기',
            '탭하여 뜻 확인, AI 문맥 예문과 한국어 음성으로 확실하게',
            'card',
            'screenshot_2_card.png'
        ),
        (
            'Screenshot_20261024_142527_OnKorean.jpg',
            'AI 실전 랩',
            'AI가 만드는 1분 단문 독해 & 청해 퀴즈',
            '외운 단어를 문맥 속에서 바로 읽고 듣는 실전 훈련',
            'ailab',
            'screenshot_3_ailab.png'
        ),
        (
            'Screenshot_20261024_142533_OnKorean.jpg',
            '오답노트 & 학습통계',
            '틀린 단어 완벽 복습 & 7일 성장 그래프',
            '카테고리별 달성률과 연속 학습 스트릭으로 동기부여',
            'stats',
            'screenshot_4_stats.png'
        )
    ]
    
    print("\n--- Generating KOREAN Store & Onboarding Assets ---")
    for i, (src, tag, title, sub, st, out_name) in enumerate(ko_ss):
        in_p = os.path.join(IMGS_DIR, src)
        out_p = os.path.join(OUTPUT_DIR, 'ko', out_name)
        generate_store_screenshot(in_p, tag, title, sub, FONT_KO_BOLD, FONT_KO_REG, st, out_p)
        shutil.copy2(out_p, os.path.join(ONBOARDING_DIR, 'ko', f'slide_{i+1}.png'))
        shutil.copy2(out_p, os.path.join(ONBOARDING_DIR, 'ko', out_name))
        
    generate_feature_graphic(
        os.path.join(IMGS_DIR, 'Screenshot_20261024_142509_OnKorean.jpg'),
        os.path.join(IMGS_DIR, 'Screenshot_20261024_142517_OnKorean.jpg'),
        app_name="작심삼일 한국어",
        slogan="매일 10단어로 끝내는 한국어 단어 완벽 마스터",
        bullets=[
            "망각 곡선 기반 매일 10단어 SRS 암기 시스템",
            "실전 AI 1분 한국어 단문 독해 & 청해 퀴즈",
            "한글 기초부터 TOPIK I·II, K-드라마 실전 회화까지"
        ],
        badge_text="4.9  •  작심삼일 한국어",
        font_bold_path=FONT_KO_BOLD,
        font_reg_path=FONT_KO_REG,
        output_path=os.path.join(OUTPUT_DIR, 'ko', 'feature_graphic_1024x500.png')
    )
    shutil.copy2(
        os.path.join(OUTPUT_DIR, 'ko', 'feature_graphic_1024x500.png'),
        os.path.join(ONBOARDING_DIR, 'ko', 'feature_graphic_1024x500.png')
    )

    # ----------------------------------------------------
    # 2. JAPANESE (일본어)
    # ----------------------------------------------------
    ja_ss = [
        (
            'Screenshot_20261024_142428_OnKorean.jpg',
            '毎日10単語 SRS',
            '三日坊主を卒業！続くハングル学習ルーティン',
            '無理のない分量で確実に身につく間隔反復暗記',
            'home',
            'screenshot_1_home.png'
        ),
        (
            'Screenshot_20261024_142437_OnKorean.jpg',
            '実践フラッシュカード',
            'ネイティブ音声＆AI実例文でスマートに記憶',
            'タップで意味確認、AI例文とリスニングで定着',
            'card',
            'screenshot_2_card.png'
        ),
        (
            'Screenshot_20261024_142452_OnKorean.jpg',
            'AI実践ラボ',
            'AIがリアルタイム生成する1分読解＆聴解',
            '学んだ単語を文脈で理解！TOPIK形式の即答クイズ',
            'ailab',
            'screenshot_3_ailab.png'
        ),
        (
            'Screenshot_20261024_142459_OnKorean.jpg',
            '学習統計＆復習ノート',
            '直近7日間の学習推移と弱点克服ノート',
            '暗記達成率と連続学習ストリークでモチベーションUP',
            'stats',
            'screenshot_4_stats.png'
        )
    ]
    
    print("\n--- Generating JAPANESE Store & Onboarding Assets ---")
    for i, (src, tag, title, sub, st, out_name) in enumerate(ja_ss):
        in_p = os.path.join(IMGS_DIR, src)
        out_p = os.path.join(OUTPUT_DIR, 'ja', out_name)
        generate_store_screenshot(in_p, tag, title, sub, FONT_JA_BOLD, FONT_JA_REG, st, out_p)
        shutil.copy2(out_p, os.path.join(ONBOARDING_DIR, 'ja', f'slide_{i+1}.png'))
        shutil.copy2(out_p, os.path.join(ONBOARDING_DIR, 'ja', out_name))
        
    generate_feature_graphic(
        os.path.join(IMGS_DIR, 'Screenshot_20261024_142428_OnKorean.jpg'),
        os.path.join(IMGS_DIR, 'Screenshot_20261024_142437_OnKorean.jpg'),
        app_name="三日坊主韓国語",
        slogan="毎日10単語！忘却曲線ベースのハングル単語定着システム",
        bullets=[
            "忘却曲線を科学したSRS間隔反復学習システム",
            "AIが生成する1分韓国語短文読解＆聴解クイズ",
            "ハングル基礎・TOPIK I·II・K-POP＆ドラマ日常会話収録"
        ],
        badge_text="4.9  •  三日坊主韓国語",
        font_bold_path=FONT_JA_BOLD,
        font_reg_path=FONT_JA_REG,
        output_path=os.path.join(OUTPUT_DIR, 'ja', 'feature_graphic_1024x500.png')
    )
    shutil.copy2(
        os.path.join(OUTPUT_DIR, 'ja', 'feature_graphic_1024x500.png'),
        os.path.join(ONBOARDING_DIR, 'ja', 'feature_graphic_1024x500.png')
    )

    # ----------------------------------------------------
    # 3. ENGLISH (영어)
    # ----------------------------------------------------
    en_ss = [
        (
            'Screenshot_20261024_142246_OnKorean.jpg',
            'DAILY 10 WORDS SRS',
            'Build Lasting Habits Beyond Day 3',
            'Effortless daily vocabulary memorization with smart repetition',
            'home',
            'screenshot_1_home.png'
        ),
        (
            'Screenshot_20261024_142406_OnKorean.jpg',
            'SMART FLASHCARDS',
            'Native Audio & AI Context Sentences',
            'Tap to reveal meanings and listen with native pronunciation',
            'card',
            'screenshot_2_card.png'
        ),
        (
            'Screenshot_20261024_142302_OnKorean.jpg',
            'AI PRACTICE LAB',
            '1-Min AI Reading & Listening Challenges',
            'Contextual comprehension quizzes tailored to your TOPIK level',
            'ailab',
            'screenshot_3_ailab.png'
        ),
        (
            'Screenshot_20261024_142414_OnKorean.jpg',
            'ANALYTICS & REVIEW',
            'Mastery Analytics & Smart Review Queue',
            'Track 7-day study trends and turn weak spots into strengths',
            'stats',
            'screenshot_4_stats.png'
        )
    ]
    
    print("\n--- Generating ENGLISH Store & Onboarding Assets ---")
    for i, (src, tag, title, sub, st, out_name) in enumerate(en_ss):
        in_p = os.path.join(IMGS_DIR, src)
        out_p = os.path.join(OUTPUT_DIR, 'en', out_name)
        generate_store_screenshot(in_p, tag, title, sub, FONT_EN_BOLD, FONT_EN_REG, st, out_p)
        shutil.copy2(out_p, os.path.join(ONBOARDING_DIR, 'en', f'slide_{i+1}.png'))
        shutil.copy2(out_p, os.path.join(ONBOARDING_DIR, 'en', out_name))
        
    generate_feature_graphic(
        os.path.join(IMGS_DIR, 'Screenshot_20261024_142246_OnKorean.jpg'),
        os.path.join(IMGS_DIR, 'Screenshot_20261024_142406_OnKorean.jpg'),
        app_name="OnKorean",
        slogan="Master Korean Vocabulary with Daily 10 Words",
        bullets=[
            "Science-backed Spaced Repetition (SRS) flashcards",
            "AI-generated 1-minute reading & listening quizzes",
            "Hangul Basics, TOPIK I·II, K-Drama & Real-Life Phrases"
        ],
        badge_text="4.9  •  AI KOREAN VOCAB",
        font_bold_path=FONT_EN_BOLD,
        font_reg_path=FONT_EN_REG,
        output_path=os.path.join(OUTPUT_DIR, 'en', 'feature_graphic_1024x500.png')
    )
    shutil.copy2(
        os.path.join(OUTPUT_DIR, 'en', 'feature_graphic_1024x500.png'),
        os.path.join(ONBOARDING_DIR, 'en', 'feature_graphic_1024x500.png')
    )

    print("\n[SUCCESS] All Store Assets and Onboarding Assets Generated Successfully!")

if __name__ == '__main__':
    main()
