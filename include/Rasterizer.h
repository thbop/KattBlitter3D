#ifndef RASTERIZER_H
#define RASTERIZER_H

#include "Window.h"
#include "stdint.h"

typedef struct {
    uint32_t x;
    uint32_t y;
} u32_vec2;

typedef struct {
    uint8_t r, g, b, a;
} u8_color;

__fastcall void RasterizeRectangle( u32_vec2 pos, u32_vec2 size, u8_color color );

__fastcall void _RasterizeLineLow( u32_vec2 pos0, u32_vec2 pos1, u8_color color );

#endif