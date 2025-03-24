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

// Line stuff
// __fastcall void _PlotHLine( i32_vec2 pos0, i32_vec2 pos1, u8_color color );

// __fastcall void _PlotVLine( i32_vec2 pos0, i32_vec2 pos1, u8_color color );

__fastcall void _PlotLineLow( i32_vec2 pos0, i32_vec2 pos1, u8_color color );

__fastcall void _PlotLineHigh( i32_vec2 pos0, i32_vec2 pos1, u8_color color );

void DrawLine( i32_vec2 pos0, i32_vec2 pos1, u8_color color ) {
    if ( abs(pos1.y - pos0.y) < abs(pos1.x - pos0.x) ) {
        if ( pos0.x > pos1.x ) _PlotLineLow(pos1, pos0, color);
        else                   _PlotLineLow(pos0, pos1, color);
    }
    else {
        if ( pos0.y > pos1.y ) _PlotLineHigh(pos1, pos0, color);
        else                   _PlotLineHigh(pos0, pos1, color);
    }
}

#endif