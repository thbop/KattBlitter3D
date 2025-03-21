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


; Sets a pixel
; Args:
;     r10 - x
;     r11 - y
;     r8  - color
SetPixel:
    push rax                          ; rax = position in the buffer to draw
    push r12                          ; r12 = start buffer pos
    push r13                          ; r13 = end buffer pos

    xor rax, rax
    mov eax, dword [rel _window]      ; rax = _window.width
    mov r13, rax                      ; r13 = _window.width
    imul rax, r11                     ; rax = _window.width * y
    add rax, r10                      ; rax = _window.width * y + x
    imul rax, 4                       ; rax = offset from buffer start to pixel (each pixel is 4 bytes)

    imul r13d, [rel _window + 4]      ; r13 = _window.width * _window.height
    imul r13, 4                       ; r13 = offset from buffer start to the end of the buffer

    mov r12, qword [rel _window + 40] ; r12 = _window.pixels (start buffer pos)
    add r13, r12                      ; r13 = end buffer pos
    add rax, r12                      ; rax = pixel pos in the buffer

    cmp rax, r12                      ; if (drawPos < bufferStart)
    jl .ignore                        ;     goto ignore
    cmp rax, r13                      ; if (drawPos > bufferEnd)
    jg .ignore                        ;     goto ignore

    mov [rax], r8                     ; Draw pixel

    .ignore:

    pop r13
    pop r12
    pop rax
    ret

global RasterizeRectangle
; __fastcall void RasterizeRectangle( i32_vec2 pos, i32_vec2 size, u8_color color );
;     rcx = pos (x, y)
;     rdx = size (width, height)
;     r8d = color (r, g, b, a)
RasterizeRectangle:
    ; Create stack frame
    ; push rbp
    ; mov rbp, rsp

    mov r10, 318
    mov r11, 178
    call SetPixel

    ; Exit
    ; mov rsp, rbp
    ; pop rbp
    ret

global _RasterizeLineLow
; __fastcall void _RasterizeLineLow( i32_vec2 pos0, i32_vec2 pos1, u8_color color );
_RasterizeLineLow:

    ret