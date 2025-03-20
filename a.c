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

    // _window.pixels[_window.width*50 + 50] = 0xFF0000FF;
    RasterizeRectangle((u32_vec2){20, 20}, (u32_vec2){20, 20}, (u8_color){255, 0, 0, 255});

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