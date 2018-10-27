
#ifndef H_TOYUNDA_TYPE_H
#define H_TOYUNDA_TYPE_H


struct s_rgba_color
{
	int red;
	int blue;
	int green;
	int alpha;
};

typedef struct s_rgba_color rgba_color_t;

struct s_toyunda_sub {
	unsigned int	start;
	unsigned int	stop;
	char*	text;
	rgba_color_t	color1;
	rgba_color_t	color2;
	rgba_color_t	tmpcolor;

	float	positionx;
	float	positiony;
	float	position2x;
	float	position2y;
	float	fadingpositionx;
	float	fadingpositiony;

	int	size;
	int	size2;
	int fadingsize;

	char*	image;
};

typedef struct s_toyunda_sub toyunda_sub_t;

#define STR_TOYUNDA_LOGO_NONE "none"
#define STR_TOYUNDA_LOGO_DEFAULT "toyunda.tga"
#define STR_TOYUNDA_FONT_DESCRIPTION "Bitstream Vera Sans Mono Bold"
#define INT_TOYUNDA_FONT_SIZE 30
#define INT_TOYUNDA_BASE_HEIGHT 600
#define INT_TOYUNDA_BASE_WIDTH 800

#endif
