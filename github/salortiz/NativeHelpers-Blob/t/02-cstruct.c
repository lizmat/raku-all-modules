#include <stdio.h>

#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
typedef long long int64_t;
#define PF "0x%p"
#else
#define DLLEXPORT extern
#include <stdint.h>
#define PF "%p"
#endif

typedef struct point3d_t {
    int64_t x;
    int64_t y;
    int64_t z;
} Point3D;

DLLEXPORT char *myaddr(Point3D *points) {
    static char buff[20];
    sprintf(buff, PF, points);
    return buff;
}

DLLEXPORT char *shown(Point3D *arr, int idx) {
    static char buff[100];
    sprintf(buff, "x:%lld, y:%lld, z:%lld", arr[idx].x, arr[idx].y, arr[idx].z);
    return buff;
}
