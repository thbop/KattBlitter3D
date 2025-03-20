#ifndef WINDOW_H
#define WINDOW_H

#include "stdio.h"
#include "string.h"
#include "stdlib.h"
#include "stdbool.h"
#include "stdint.h"

#define SDL_MAIN_HANDLED

#include "external/SDL2/SDL.h"


#define WINDOW_RATIO 4

#define W_CHECK_ERROR(test, message) \
    do { \
        if((test)) { \
            fprintf(stderr, "%s\n", (message)); \
            return false; \
        } \
    } while(0)

struct {
    int32_t width, height;
    bool running;

    SDL_Window *window;
    SDL_Renderer *renderer;
    SDL_Texture *texture;
    uint32_t *pixels;
} _window;

bool WindowInitialize( const char *title, const int width, const int height ) {
    _window.width = width;
    _window.height = height;
    _window.running = true;

    W_CHECK_ERROR(SDL_Init(SDL_INIT_VIDEO) != 0, SDL_GetError());
    _window.window = SDL_CreateWindow(
        title,
        SDL_WINDOWPOS_CENTERED_DISPLAY(0),
        SDL_WINDOWPOS_CENTERED_DISPLAY(0),
        width*WINDOW_RATIO, height*WINDOW_RATIO,
        SDL_WINDOW_ALLOW_HIGHDPI
    );
    W_CHECK_ERROR(_window.window == NULL, SDL_GetError());

    _window.renderer = SDL_CreateRenderer(_window.window, -1, SDL_RENDERER_PRESENTVSYNC);
    W_CHECK_ERROR(_window.renderer == NULL, SDL_GetError());

    _window.texture = SDL_CreateTexture(
        _window.renderer,
        SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_STREAMING,
        width, height
    );
    W_CHECK_ERROR(_window.texture == NULL, SDL_GetError());

    _window.pixels = (uint32_t*)calloc(width * height, sizeof(uint32_t));

    return true;
}

void WindowClear() {
    memset(_window.pixels, 0, _window.width*_window.height * sizeof(uint32_t));
}

void WindowFlip() {
    // TODO: Move this to an update section and give the user more access to events
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        switch (event.type) {
            case SDL_QUIT:
                _window.running = false;
                break;
        }
    }

    SDL_UpdateTexture(_window.texture, NULL, _window.pixels, _window.width * sizeof(uint32_t));
    SDL_RenderCopyEx(
        _window.renderer, _window.texture,
        NULL, NULL, 0.0, NULL, SDL_FLIP_NONE
    );
    SDL_RenderPresent(_window.renderer);
}

void WindowUnload() {
    free(_window.pixels);
    SDL_DestroyTexture(_window.texture);
    SDL_DestroyRenderer(_window.renderer);
    SDL_DestroyWindow(_window.window);
    SDL_Quit();
}


#endif