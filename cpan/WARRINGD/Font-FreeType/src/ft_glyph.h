#ifndef __FT_GLYPH_H
#define __FT_GLYPH_H

#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_BITMAP_H
#include FT_GLYPH_H
#include FT_OUTLINE_H

DLLEXPORT FT_Bitmap
*ft_glyph_bitmap(FT_BitmapGlyph bm_glyph);

#endif /* __FT_GLYPH_H */
