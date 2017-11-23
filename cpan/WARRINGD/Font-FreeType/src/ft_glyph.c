#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
/* Get prototype. */
#include "ft_glyph.h"

DLLEXPORT FT_Bitmap
*ft_glyph_bitmap(FT_BitmapGlyph bm_glyph) {
  return &(bm_glyph->bitmap);
}

DLLEXPORT FT_Outline
*ft_glyph_outline(FT_OutlineGlyph ol_glyph) {
  return &(ol_glyph->outline);
}


