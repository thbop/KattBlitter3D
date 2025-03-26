#include "KattBlitter3D.h"



bool Initialize() {
    bool ok;
    ok = WindowInitialize("First Test Application", 320, 180);


    return ok;
}

void Update() {

}

void Draw() {
    WindowClear();



    i32_vec2 mpos;
    SDL_GetMouseState(&mpos.x, &mpos.y);
    mpos.x /= WINDOW_RATIO;
    mpos.y /= WINDOW_RATIO;


    // _PlotLineLow(mpos, (i32_vec2){ _window.width>>1, _window.height>>1 }, (u8_color){ 255, 255, 0, 255 });
    DrawLine(mpos, (i32_vec2){ _window.width>>1, _window.height>>1 }, (u8_color){ 0, 255, 255, 255 });


    WindowFlip();
}

void Run() {
    while (_window.running) {
        Update();
        Draw();
    }
}

void Unload() {
    WindowUnload();
}

int main(int argc, char **argv) {
    if ( !Initialize() ) return 1;
    Run();
    Unload();
    return 0;
}