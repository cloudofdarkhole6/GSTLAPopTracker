# I used Pillow 13.x for this (for ImageText), which you will probably have to install manually
from PIL import Image, ImageDraw, ImageFont, ImageText
import os
import math

dir_path = os.path.dirname(os.path.realpath(__file__))

# Change this to wherever your fonts are, my installed ones were in an AppData folder for example
PATH_TO_FONTS = r""

font_size = 18

# This uses DejaVu Sans, it's the PopTracker font and is widely available anywhere to install
font = ImageFont.truetype(PATH_TO_FONTS+r"\DejaVuSans.ttf",font_size)
font_bold = ImageFont.truetype(PATH_TO_FONTS+r"\DejaVuSans-Bold.ttf",font_size)

# These just add some space around the text so it looks cleaner, no real reason to edit these
x_padding = round(font_size * 0.3)
y_padding = round(font_size * 0.15)

def sanitize_filename(filename):
    keepcharacters = (' ','.','_')
    return "".join(c for c in filename if c.isalnum() or c in keepcharacters).rstrip().replace(" ","_")

def get_expected_image_width(text: ImageText.Text) -> int:
    return math.ceil(text.get_length() + (2 * x_padding))

def create_text_image(text_to_create: str, width: int = 0) -> None:
    text = ImageText.Text(text_to_create, font)

    # This weird ascent descent thing is used instead of something like 'bottom - top' for height, I tried that initially but the text looked "off"
    # Tailed letters like 'y' or 'g' change our perception of how text is centered, this should account for that
    ascent, descent = font.getmetrics()
    height = ascent + descent

    height_total = height + (2 * y_padding)
    width_total = get_expected_image_width(text)

    if width > 0:
        width_total = width

    im = Image.new("RGBA", (width_total, height_total))
    d = ImageDraw.Draw(im)
    d.text((x_padding, y_padding), text, "#FFFFFFFF")
    image_name = sanitize_filename(f"text_{text_to_create}")
    im.save(f"{dir_path}/images/{image_name}.png")

def read_text_to_generate():
    with open(f"{dir_path}/text_to_generate.txt") as file:
        for line in file:
            parts = line.replace("\n","").split(",")
            if len(parts) == 1:
                create_text_image(parts[0])
            elif len(parts) > 1:
                first = parts[0]
                prefix = f"{first}:"
                words = [f"{prefix} {suffix}" for suffix in parts[1:]]
                # This max_expected_width is for something like "Item Shuffle: All Items" and "Item Shuffle: Chests & Tablets"
                # Making the shorter one have the image width of the longest one prevents blurry stretching in PopTracker
                max_expected_width = max(get_expected_image_width(ImageText.Text(word, font)) for word in words)
                for word in words:
                    create_text_image(word, max_expected_width)

if __name__ == '__main__':
    read_text_to_generate()
