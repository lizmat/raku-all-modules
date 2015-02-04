/*
 * 
 * cc -o Imlib2.o -fPIC -c Imlib2.c
 * cc -shared -s -o Imlib2.so Imlib2.o
 * rm Imlib2.o
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Imlib2.h"

#ifdef WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

DLLEXPORT Imlib_Image p6_create_transparent_image(Imlib_Image source, int alpha) {
	Imlib_Image destination;
	Imlib_Color color_return;
	int x, y, w, h;

	imlib_context_set_image(source);
	w = imlib_image_get_width();
	h = imlib_image_get_height();

	destination = imlib_create_image(w, h);
	imlib_context_set_image(destination);
	imlib_image_clear();
	imlib_image_set_has_alpha(1);

	for (y = 0; y < h; y++) {
		for (x = 0; x < w; x++)  {
			imlib_context_set_image(source);
			imlib_image_query_pixel(x, y, &color_return);
			imlib_context_set_color(color_return.red, color_return.green, color_return.blue, alpha);
			imlib_context_set_image(destination);
			imlib_image_draw_pixel(x, y, 0);
		}
	}

	return destination;
}

DLLEXPORT void p6_imlib_image_query_pixel(int x, int y, int *red, int *green, int *blue, int *alpha) {
	Imlib_Color color_return;

	imlib_image_query_pixel(x, y, &color_return);
	*red = color_return.red;
	*green = color_return.green;
	*blue = color_return.blue;
	*alpha = color_return.alpha;
}


DLLEXPORT Imlib_Border *p6_imlib_init_border(int left, int right, int top, int bottom) {
	Imlib_Border *b = (Imlib_Border*)malloc(sizeof(Imlib_Border));
	
	b->left = left;
	b->right = right;
	b->top = top;
	b->bottom = bottom;
	
	return b;
}

DLLEXPORT void p6_imlib_put_border(Imlib_Border *b, int left, int right, int top, int bottom) {
	b->left = left;
	b->right = right;
	b->top = top;
	b->bottom = bottom;
}

DLLEXPORT int *p6_imlib_get_border(Imlib_Border *b) {
	int *array = malloc(4 * sizeof(int));
	
	array[0] = b->left;
	array[1] = b->right;
	array[2] = b->top;
	array[3] = b->bottom;
	
	return array;
}
