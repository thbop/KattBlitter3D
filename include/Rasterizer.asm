; This isn't supposed to be readable, I'm just trying to avoid using additional memory.
; If I were being serious, there would be a ton more stack operations...

section .text



extern _window
; struct {
;     int32_t width, height;
;     bool running;

;     SDL_Window *window;
;     SDL_Renderer *renderer;
;     SDL_Texture *texture;
;     uint32_t *pixels;
; } _window;

; Some fastcall-like calling convention
; Args:
;     rcx
;     rdx
;     r8
;     r9



global RasterizeRectangle
; __fastcall void RasterizeRectangle( u32_vec2 pos, u32_vec2 size, u8_color color );
;     rcx = pos (x, y)
;     rdx = size (width, height)
;     r8d = color (r, g, b, a)
RasterizeRectangle:
    ; Create stack frame
    ; push rbp
    ; mov rbp, rsp

    ; Decode pos
    mov r9, rcx
    shr r9, 32                        ; r9d  = x

    ; Decode size
    mov r10, rdx
    shr r10, 32                       ; r10d = width

    ; Setup pixel pointer
    mov ebx, dword [rel _window]      ; ebx  = _window.width 

    mov eax, ecx                      ; eax  = y
    imul eax, ebx                     ; eax  = y * _window.width
    add eax, r9d                      ; eax  = y * _window.width + x
    imul eax, 4                       ; Ensure we're addressing colors as uint32_t's
    add rax, qword [rel _window + 40] ; eax  += _window.pixels

    ; Setup iterator offsets
    ; Here I multiply many offsets by 4 so that 32 colors
    ; are navigated correctly within memory.
    imul r10d, 4
    mov r11d, r10d                    ; Store width for later
    imul edx, ebx
    imul edx, 4
    imul ebx, 4

.loop_y:
    .loop_x:
        add rax, r10                  ; This is cheesy, but whatever
        add rax, rdx
        mov [rax], r8d                ; Draw the pixel
        sub rax, r10                  ; Clean up
        sub rax, rdx

        sub r10d, 4                   ; i--
        jnz .loop_x
    
    mov r10d, r11d                    ; i  = width
    sub edx, ebx                      ; j--
    jnz .loop_y

    ; Exit
    ; mov rsp, rbp
    ; pop rbp
    ret

global _RasterizeLineLow
; __fastcall void _RasterizeLineLow( u32_vec2 pos0, u32_vec2 pos1, u8_color color );
_RasterizeLineLow:

    ret