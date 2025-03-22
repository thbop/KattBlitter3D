#include "KattBlitter3D.h"
#include "time.h"

time_t t, t2;
int counter;

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


    i32_vec2 mpos;
    SDL_GetMouseState(&mpos.x, &mpos.y);
    mpos.x /= WINDOW_RATIO;
    mpos.y /= WINDOW_RATIO;

    t2 = time(NULL)+1;
    counter = 0;

    while (t < t2) {
        t = time(NULL);
        RasterizeRectangle(mpos, (i32_vec2){100, 100}, (u8_color){255, 0, 0, 255});
        counter++;
    }


    printf("%d\n", counter);

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