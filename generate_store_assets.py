import os
import math
import shutil
from PIL import Image, ImageDraw, ImageFont, ImageFilter

PROJECT_ROOT = r'c:\src\on-vocab'
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
      and extends the bottom bar background color (238, 237, 243) down to the bottom (2811).
    - 'ailab': the ad is at the very bottom (y: 2620..2811). Fills it with the page background color (249, 250, 252).
    - 'card': no ad banner present.
    """
    im = Image.open(img_path).convert('RGBA')
    w, h = im.size
    
    if screen_type in ('home', 'stats'):
        # Ad is y: 2327..2514. Bottom bar is y: 2515..2811 (height 296)
        bottom_bar = im.crop((0, 2515, w, h))
        im.paste(bottom_bar, (0, 2327))
        draw = ImageDraw.Draw(im)
        draw.rectangle([(0, 2327 + bottom_bar.height), (w, h)], fill=(238, 237, 243, 255))
    elif screen_type == 'ailab':
        # Ad is y: 2620..2811
        draw = ImageDraw.Draw(im)
        draw.rectangle([(0, 2620), (w, h)], fill=(249, 250, 252, 255))
        
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
    draw.rounded_rectangle([(bezel, bezel), (bezel + screen_w, bezel + screen_h)], radius=int(corner_radius * 0.8), outline=(50, 50, 62, 130), width=1)
    
    # Punch-hole camera (centered at top)
    cam_r = max(4, int(target_w * 0.013))
    cam_x = frame_w // 2
    cam_y = bezel + int(target_w * 0.033)
    draw.ellipse([(cam_x - cam_r, cam_y - cam_r), (cam_x + cam_r, cam_y + cam_r)], fill=(4, 4, 5, 255), outline=(32, 32, 38, 180), width=1)
    draw.ellipse([(cam_x - 2, cam_y - 2), (cam_x - 1, cam_y - 1)], fill=(50, 70, 110, 200))
    
    # Shadow
    shadow_margin = shadow_blur + 25
    total_w = frame_w + shadow_margin * 2
    total_h = frame_h + shadow_margin * 2
    
    shadow_img = Image.new('RGBA', (total_w, total_h), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow_img)
    s_draw.rounded_rectangle(
        [(shadow_margin + 2, shadow_margin + 16), (shadow_margin + frame_w - 2, shadow_margin + frame_h + 16)],
        radius=corner_radius,
        fill=(0, 0, 0, shadow_opacity)
    )
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(shadow_blur))
    shadow_img.paste(frame, (shadow_margin, shadow_margin), frame)
    
    return shadow_img, shadow_margin

def render_background_gradient(w, h, top_color, bot_color, glow_color=None, glow_center=None, glow_radius=400):
    """Renders a smooth vertical gradient with optional radial ambient glow."""
    base = Image.new('RGB', (w, h))
    for y in range(h):
        t = y / (h - 1)
        r = int(top_color[0] * (1 - t) + bot_color[0] * t)
        g = int(top_color[1] * (1 - t) + bot_color[1] * t)
        b = int(top_color[2] * (1 - t) + bot_color[2] * t)
        ImageDraw.Draw(base).line([(0, y), (w, y)], fill=(r, g, b))
        
    if glow_color and glow_center:
        glow = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        g_draw = ImageDraw.Draw(glow)
        cx, cy = glow_center
        steps = 40
        for i in range(steps, 0, -1):
            rad = int(glow_radius * (i / steps))
            alpha = int(glow_color[3] * (1 - (i / steps)**1.4))
            g_draw.ellipse(
                [(cx - rad, cy - rad), (cx + rad, cy + rad)],
                fill=(glow_color[0], glow_color[1], glow_color[2], alpha)
            )
        glow = glow.filter(ImageFilter.GaussianBlur(45))
        base.paste(glow, (0, 0), glow)
        
    return base

def draw_centered_text(draw, y, text, font, fill, canvas_w=1080):
    """Draws horizontally centered text and returns bounding box bottom."""
    bbox = font.getbbox(text)
    w = bbox[2] - bbox[0]
    x = (canvas_w - w) // 2
    draw.text((x, y), text, font=font, fill=fill)
    return y + (bbox[3] - bbox[1])

def generate_store_screenshot(screenshot_path, tag, title, subtitle, font_bold_path, font_reg_path, screen_type, output_path):
    """Generates a 1080x1920 Google Play Store screenshot with phone mockup."""
    W, H = 1080, 1920
    
    # Premium deep slate & indigo glow background
    bg = render_background_gradient(
        W, H,
        top_color=(15, 23, 42),
        bot_color=(10, 15, 28),
        glow_color=(79, 70, 229, 65),
        glow_center=(540, 360),
        glow_radius=480
    )
    
    draw = ImageDraw.Draw(bg)
    font_tag = ImageFont.truetype(font_bold_path, 25)
    font_title = ImageFont.truetype(font_bold_path, 48)
    font_sub = ImageFont.truetype(font_reg_path, 25)
    
    # 1. Tag Pill
    tag_bbox = font_tag.getbbox(tag)
    tag_w = tag_bbox[2] - tag_bbox[0] + 36
    tag_h = 42
    tag_x = (W - tag_w) // 2
    tag_y = 96
    
    pill_img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    p_draw = ImageDraw.Draw(pill_img)
    p_draw.rounded_rectangle(
        [(tag_x, tag_y), (tag_x + tag_w, tag_y + tag_h)],
        radius=21,
        fill=(79, 70, 229, 45),
        outline=(99, 102, 241, 180),
        width=1
    )
    bg.paste(pill_img, (0, 0), pill_img)
    
    draw = ImageDraw.Draw(bg)
    text_x = tag_x + 18
    text_y = tag_y + 7
    draw.text((text_x, text_y), tag, font=font_tag, fill=(199, 210, 254))
    
    # 2. Main Title
    title_y = tag_y + tag_h + 30
    draw_centered_text(draw, title_y, title, font_title, (255, 255, 255))
    
    # 3. Subtitle
    sub_y = title_y + 74
    draw_centered_text(draw, sub_y, subtitle, font_sub, (203, 213, 225))
    
    # 4. Phone Mockup
    clean_ss = clean_screenshot(screenshot_path, screen_type=screen_type)
    phone_img, s_margin = create_phone_mockup(clean_ss, target_w=710, corner_radius=46, bezel=13, shadow_blur=35, shadow_opacity=180)
    
    phone_w, phone_h = phone_img.size
    paste_x = (W - phone_w) // 2
    paste_y = 430 - s_margin
    
    bg.paste(phone_img, (paste_x, paste_y), phone_img)
    bg.save(output_path, 'PNG', optimize=True)
    print(f'Screenshot saved: {output_path}')

def generate_feature_graphic(screen1_path, screen2_path, app_name, slogan, bullets, badge_text, font_bold_path, font_reg_path, output_path):
    """
    Generates a 1024x500 Google Play Store Feature Graphic with 2 phone mockups,
    app icon, app name, slogan, and key feature bullets.
    """
    W, H = 1024, 500
    
    # Background: Premium deep dark theme with indigo & coral warmth
    bg = render_background_gradient(
        W, H,
        top_color=(15, 23, 42),
        bot_color=(10, 15, 28),
        glow_color=(99, 102, 241, 65),
        glow_center=(780, 250),
        glow_radius=420
    )
    
    # Secondary coral glow on right
    coral_glow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    cg_draw = ImageDraw.Draw(coral_glow)
    cg_draw.ellipse([(700, 150), (1020, 480)], fill=(255, 112, 67, 30))
    coral_glow = coral_glow.filter(ImageFilter.GaussianBlur(60))
    bg.paste(coral_glow, (0, 0), coral_glow)
    
    # Left glow for icon/title
    left_glow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    lg_draw = ImageDraw.Draw(left_glow)
    lg_draw.ellipse([(40, 40), (400, 400)], fill=(79, 70, 229, 25))
    left_glow = left_glow.filter(ImageFilter.GaussianBlur(55))
    bg.paste(left_glow, (0, 0), left_glow)
    
    # Left Content: App Icon + Typography
    # 1. App Icon
    if os.path.exists(ICON_PATH):
        raw_icon = Image.open(ICON_PATH).convert('RGBA')
        icon_size = 72
        icon_img = raw_icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        icon_mask = create_rounded_mask((icon_size, icon_size), radius=18)
        
        # Icon shadow
        icon_bg = Image.new('RGBA', (icon_size + 12, icon_size + 12), (0, 0, 0, 0))
        ib_draw = ImageDraw.Draw(icon_bg)
        ib_draw.rounded_rectangle([(4, 4), (icon_size + 8, icon_size + 8)], radius=19, fill=(0, 0, 0, 150))
        icon_bg = icon_bg.filter(ImageFilter.GaussianBlur(6))
        
        icon_plate = Image.new('RGBA', (icon_size, icon_size), (0, 0, 0, 0))
        icon_plate.paste(icon_img, (0, 0), icon_mask)
        ip_draw = ImageDraw.Draw(icon_plate)
        ip_draw.rounded_rectangle([(0, 0), (icon_size - 1, icon_size - 1)], radius=18, outline=(99, 102, 241, 190), width=1)
        
        bg.paste(icon_bg, (50, 46), icon_bg)
        bg.paste(icon_plate, (54, 50), icon_plate)
        
    # Fonts
    font_name = ImageFont.truetype(font_bold_path, 34)
    font_slogan = ImageFont.truetype(font_bold_path, 20)
    font_bullet = ImageFont.truetype(font_reg_path, 17)
    font_badge = ImageFont.truetype(font_bold_path, 13)
    
    draw = ImageDraw.Draw(bg)
    
    # App Name (Next to Icon)
    name_x = 142
    name_y = 66
    draw.text((name_x, name_y), app_name, font=font_name, fill=(255, 255, 255))
    
    # Slogan / Tagline
    slogan_x = 54
    slogan_y = 144
    draw.text((slogan_x, slogan_y), slogan, font=font_slogan, fill=(255, 140, 100))
    
    # Decorative line
    draw.line([(54, 184), (480, 184)], fill=(50, 52, 65, 255), width=1)
    
    # Feature Bullet Points with Vector Checkmarks
    bullet_y = 206
    for b in bullets:
        # Checkbox background
        box_x = 54
        box_y = bullet_y
        draw.rounded_rectangle([(box_x, box_y), (box_x + 22, box_y + 22)], radius=5, fill=(79, 70, 229, 45), outline=(99, 102, 241, 190), width=1)
        
        # Crisp Vector Checkmark
        draw_vector_checkmark(draw, cx=box_x + 11, cy=box_y + 11, color=(165, 180, 252), stroke_w=2)
        
        # Bullet Text
        draw.text((box_x + 34, box_y + 1), b, font=font_bullet, fill=(226, 232, 240))
        bullet_y += 44
        
    # Bottom Rating Badge Pill (Vector Star + Text)
    badge_x = 54
    badge_y = 368
    badge_bbox = font_badge.getbbox(badge_text)
    badge_text_w = badge_bbox[2] - badge_bbox[0]
    badge_w = badge_text_w + 58
    badge_h = 38
    draw.rounded_rectangle([(badge_x, badge_y), (badge_x + badge_w, badge_y + badge_h)], radius=8, fill=(30, 35, 55, 220), outline=(79, 70, 229, 180), width=1)
    
    # Vector Gold Star
    draw_star(draw, cx=badge_x + 22, cy=badge_y + 19, r=8, fill=(255, 190, 60))
    # Badge Text
    draw.text((badge_x + 38, badge_y + 11), badge_text, font=font_badge, fill=(255, 210, 120))
    
    # Right Side: 2 Phone Mockups floating smoothly
    # Back Phone (Screen 1 - Home screen, target_w = 185)
    clean_ss1 = clean_screenshot(screen1_path, screen_type='home')
    phone1, m1 = create_phone_mockup(clean_ss1, target_w=185, corner_radius=25, bezel=8, shadow_blur=22, shadow_opacity=150)
    
    # Front Phone (Screen 2 - Flashcard screen, target_w = 200)
    clean_ss2 = clean_screenshot(screen2_path, screen_type='card')
    phone2, m2 = create_phone_mockup(clean_ss2, target_w=200, corner_radius=27, bezel=9, shadow_blur=28, shadow_opacity=190)
    
    # Paste Back phone
    p1_x = 545 - m1
    p1_y = 52 - m1
    bg.paste(phone1, (p1_x, p1_y), phone1)
    
    # Paste Front phone (overlapping)
    p2_x = 725 - m2
    p2_y = 42 - m2
    bg.paste(phone2, (p2_x, p2_y), phone2)
    
    # Save as 24-bit PNG
    bg.save(output_path, 'PNG', optimize=True)
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
            'Screenshot_20261015_185440_OnVocab.jpg',
            '매일 10단어 SRS',
            '작심삼일을 넘어 매일 완성하는 단어 습관',
            '하루 10단어로 부담 없이 채우는 실전 일본어 어휘력',
            'home',
            'screenshot_1_home.png'
        ),
        (
            'Screenshot_20261015_185447_OnVocab.jpg',
            '스마트 플래시카드',
            '후리가나 & 원어민 발음으로 생생한 암기',
            '탭하여 뜻 확인, AI 실전문장과 음성으로 확실하게',
            'card',
            'screenshot_2_card.png'
        ),
        (
            'Screenshot_20261015_185502_OnVocab.jpg',
            'AI 실전 랩',
            'AI가 만드는 1분 단문 독해 & 청해 퀴즈',
            '외운 단어를 문맥 속에서 바로 읽고 듣는 실전 훈련',
            'ailab',
            'screenshot_3_ailab.png'
        ),
        (
            'Screenshot_20261015_185507_OnVocab.jpg',
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
        os.path.join(IMGS_DIR, 'Screenshot_20261015_185440_OnVocab.jpg'),
        os.path.join(IMGS_DIR, 'Screenshot_20261015_185447_OnVocab.jpg'),
        app_name="작심삼일본어",
        slogan="매일 10단어로 끝내는 일본어 단어 완벽 마스터",
        bullets=[
            "망각 곡선 기반 매일 10단어 SRS 암기 시스템",
            "실전 AI 1분 JLPT 단문 독해 & 청해 퀴즈",
            "JLPT 급수별 · 비즈니스 · 여행 테마별 맞춤 학습"
        ],
        badge_text="4.9  •  작심삼일 일본어",
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
            'Screenshot_20261015_185514_OnVocab.jpg',
            '毎日10単語 SRS',
            '三日坊主を卒業！続く単語学習ルーティン',
            '無理のない分量で確実に身につく間隔反復暗記',
            'home',
            'screenshot_1_home.png'
        ),
        (
            'Screenshot_20261015_185518_OnVocab.jpg',
            '実践フラッシュカード',
            'ふりがな・ネイティブ音声でスマートに記憶',
            'タップで意味確認、AI実例文とリスニングで定着',
            'card',
            'screenshot_2_card.png'
        ),
        (
            'Screenshot_20261015_185523_OnVocab.jpg',
            'AI実践ラボ',
            'AIがリアルタイム生成する1分読解＆聴解',
            '学んだ単語を文脈で理解！JLPT形式の即答クイズ',
            'ailab',
            'screenshot_3_ailab.png'
        ),
        (
            'Screenshot_20261015_185527_OnVocab.jpg',
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
        os.path.join(IMGS_DIR, 'Screenshot_20261015_185514_OnVocab.jpg'),
        os.path.join(IMGS_DIR, 'Screenshot_20261015_185518_OnVocab.jpg'),
        app_name="三日坊主日本語",
        slogan="毎日10単語！忘却曲線ベースの語彙定着システム",
        bullets=[
            "忘却曲線を科学したSRS間隔反復学習システム",
            "AIが生成する1分JLPT短文読解＆聴解クイズ",
            "JLPTレベル別・テーマ別（ビジネス・旅行・IT）収録"
        ],
        badge_text="4.9  •  三日坊主日本語",
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
            'Screenshot_20261015_185533_OnVocab.jpg',
            'DAILY 10 WORDS SRS',
            'Build Lasting Habits Beyond Day 3',
            'Effortless daily vocabulary memorization with smart repetition',
            'home',
            'screenshot_1_home.png'
        ),
        (
            'Screenshot_20261015_185537_OnVocab.jpg',
            'SMART FLASHCARDS',
            'Furigana, Audio & AI Context Sentences',
            'Tap to reveal meanings and listen with native pronunciation',
            'card',
            'screenshot_2_card.png'
        ),
        (
            'Screenshot_20261015_185546_OnVocab.jpg',
            'AI PRACTICE LAB',
            '1-Min AI Reading & Listening Challenges',
            'Contextual comprehension quizzes tailored to your JLPT level',
            'ailab',
            'screenshot_3_ailab.png'
        ),
        (
            'Screenshot_20261015_185605_OnVocab.jpg',
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
        os.path.join(IMGS_DIR, 'Screenshot_20261015_185533_OnVocab.jpg'),
        os.path.join(IMGS_DIR, 'Screenshot_20261015_185537_OnVocab.jpg'),
        app_name="OnVocab",
        slogan="Master Japanese Vocabulary with Daily 10 Words",
        bullets=[
            "Science-backed Spaced Repetition (SRS) flashcards",
            "AI-generated 1-minute JLPT reading & listening quizzes",
            "JLPT N5-N1 levels and practical themes (Business, Travel, IT)"
        ],
        badge_text="4.9  •  AI JAPANESE VOCAB",
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
