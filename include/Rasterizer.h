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

__fastcall void RasterizeRectangle( i32_vec2 pos, i32_vec2 size, u8_color color );


void RasterizeRectangleC( i32_vec2 pos, i32_vec2 size, u8_color color ) {
    for ( int j = 0; j < size.y; j++ ) 
        for ( int i = 0; i < size.x; i++ )
            if (
                0 <= (pos.x + i) && (pos.x + i) <= _window.width &&
                0 <= (pos.y + j) && (pos.y + j) <= _window.height
            )
                _window.pixels[(j + pos.y) * _window.width + i + pos.x] = *(uint32_t*)&color;
}

__fastcall void _RasterizeLineLow( i32_vec2 pos0, i32_vec2 pos1, u8_color color );

#endif