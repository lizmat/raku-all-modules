#ifndef __FT_OUTLINE_H
#define __FT_OUTLINE_H

#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_OUTLINE_H

typedef enum {
  FT_OUTLINE_OP_NONE,
  FT_OUTLINE_OP_MOVE_TO,
  FT_OUTLINE_OP_LINE_TO,
  FT_OUTLINE_OP_CUBIC_TO,
  FT_OUTLINE_OP_CONIC_TO,
} FT_OUTLINE_OP;

typedef struct {
  int n_points;
  int n_ops;
  int max_points;
  uint8_t *ops;
  double *points;
} ft_shape_t;

#define QEFFT2_NUM(num)  ((double) (num) / 64.0)

DLLEXPORT FT_Error ft_outline_gather(ft_shape_t *data, FT_Outline *outline, int shift, FT_Pos delta, uint8_t conic_opt);

DLLEXPORT void
ft_outline_gather_done(ft_shape_t *shape);

#endif /* __FT_OUTLINE_H */
