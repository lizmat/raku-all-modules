#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
/* Get prototype. */
#include "ft_outline.h"

static int add_op(ft_shape_t *shape, FT_OUTLINE_OP op) {
  shape->ops[ shape->n_ops++ ] = (uint8_t) op;
}

static int add_vec(ft_shape_t *shape, const FT_Vector *v) {
  if ( shape->n_points + 2 > shape->max_points) {
    return FT_Err_Cannot_Render_Glyph;
  }
  shape->points[ shape->n_points++ ] = QEFFT2_NUM(v->x);
  shape->points[ shape->n_points++ ] = QEFFT2_NUM(v->y);
  return FT_Err_Ok;
}

static int
take_move_to(const FT_Vector *to, void *user) {
  ft_shape_t *shape = (ft_shape_t *) user;
  add_op(shape, FT_OUTLINE_OP_MOVE_TO);
  return add_vec(shape, to);
}

static int
take_line_to(const FT_Vector *to, void *user) {
  ft_shape_t *shape = (ft_shape_t *) user;
  add_op(shape, FT_OUTLINE_OP_LINE_TO);
  return add_vec(shape, to);
}

static int
take_cubic_to(const FT_Vector *cp1, const FT_Vector *cp2, const FT_Vector *to, void *user) {
  ft_shape_t *shape = (ft_shape_t *) user;
  add_op(shape, FT_OUTLINE_OP_CUBIC_TO);
  add_vec(shape, cp1);
  add_vec(shape, cp2);
  return add_vec(shape, to);
}

static int
take_conic_to(const FT_Vector *cp1, const FT_Vector *to, void *user) {
  ft_shape_t *shape = (ft_shape_t *) user;
  add_op(shape, FT_OUTLINE_OP_CONIC_TO);
  add_vec(shape, cp1);
  return add_vec(shape, to);
}

static void conic_to_cubic(const FT_Vector *cp1, const FT_Vector *to, FT_Vector *cp2) {
  cp2->x = cp1->x + 2.0/3.0 * (to->x - cp1->x);
  cp2->y = cp1->y + 2.0/3.0 * (to->y - cp1->y);
}

static int
take_conic_as_cubic(const FT_Vector *cp1, const FT_Vector *to, void *user) {
  FT_Vector cp2;
  conic_to_cubic(cp1, to, &cp2);
  return take_cubic_to(cp1, &cp2, to, user);
}

DLLEXPORT FT_Error
ft_outline_gather(ft_shape_t *shape, FT_Outline *outline, int shift, FT_Pos delta, uint8_t conic_opt) {
   FT_Outline_Funcs funcs = {
      take_move_to,
      take_line_to,
      (conic_opt
           ? take_conic_to
           : take_conic_as_cubic),
      take_cubic_to,
      shift, delta
   };

   shape->ops = malloc(shape->max_points * sizeof( *(shape->ops) ));
   shape->points = malloc(shape->max_points * sizeof( *(shape->points) ));

   FT_Outline_Decompose(outline, &funcs, shape);
}

DLLEXPORT void
ft_outline_gather_done(ft_shape_t *shape) {
  if (shape->ops) free(shape->ops);
  if (shape->points) free(shape->points);
  shape->ops = NULL;
  shape->points = NULL;
}
