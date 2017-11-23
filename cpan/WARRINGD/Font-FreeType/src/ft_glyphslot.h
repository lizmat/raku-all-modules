#ifndef __FT_GLYPHSLOT_H
#define __FT_GLYPHSLOT_H

#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_GLYPH_H

DLLEXPORT FT_Glyph_Metrics
*ft_glyphslot_metrics(FT_GlyphSlot glyphslot);

#endif /* __FT_GLYPHSLOT_H */
