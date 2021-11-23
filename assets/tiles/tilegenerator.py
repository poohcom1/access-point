from PIL import Image
import numpy as np

import sys

from numpy.lib.shape_base import tile


mask = Image.open("isotest.png")
tileset = Image.open("isowall-18.png")
width = tileset.size[0]
height = tileset.size[1]

x_size = mask.size[0]
y_size = mask.size[1]

# Generate mask array
mask_array = []

for y in range(mask.size[1]):
    mask_array.append([])
    for x in range(mask.size[0]):
        mask_array[y].append(mask.getpixel((x, y)))

mask_array = np.array(mask_array)

output_pixels = np.zeros((height*2, width, 4), dtype=np.uint8)

for i in range(width//x_size):
    for j in range(height//y_size * 2):
        ind = 0

        y_offset = round(j / 2 * y_size)
        x_offset = round(i * x_size) if j % 2 != 0 else int(i * x_size + x_size//2)

    
        for y in range(y_offset, min(y_offset + y_size, height)):
            for x in range(x_offset, min(x_offset + x_size, width)):

                if mask.getpixel((x-x_offset, y-y_offset)) != (0, 0, 0, 0):
                    output_pixels[j * y_size + y - y_offset][i * x_size + x - x_offset] = tileset.getpixel((x, y))

            ind += 1
        
    
    
image = Image.fromarray(output_pixels)
image.save("test/full.png")
