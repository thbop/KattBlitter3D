#ifndef RASTERIZER_H
#define RASTERIZER_H

#include "Window.h"
#include "stdint.h"

typedef struct {
    int32_t x, y;
} i32_vec2;

// typedef struct {
//     int32_t x, y, width, height;
// } i32_rect;

typedef struct {
    uint8_t r, g, b, a;
} u8_color;

__fastcall void DrawPixel( i32_vec2 pos, u8_color color );

__fastcall void DrawRectangle( i32_vec2 pos, i32_vec2 size, u8_color color );


__fastcall void _PlotLineLow( i32_vec2 pos0, i32_vec2 pos1, u8_color color );

#endif