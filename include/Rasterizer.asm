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


; Setup for efficient rasterization
; Args:
;     r10 - start x
;     r11 - start y
; Returns:
;     rax - position in the buffer to draw
;     r10 - x offset (4)
;     r11 - y offset (_window.width * 4)
;     r12 - start buffer pos (for bounds checking)
;     r13 - end buffer pos
SetupRasterizer:
    xor rax, rax
    mov eax, dword [rel _window]      ; rax = _window.width
    mov r13, rax                      ; r13 = _window.width
    imul rax, r11                     ; rax = _window.width * y
    add rax, r10                      ; rax = _window.width * y + x
    shl rax, 2                        ; rax = offset from buffer start to pixel (each pixel is 4 bytes)

    shl r13, 2                       ; r13 = y offset size

    mov r10, 4                        ; r10 = x offset size
    mov r11, r13                      ; r11 = y offset size

    imul r13d, [rel _window + 4]      ; r13 = (y offset * _window.height) = buffer size in bytes

    mov r12, qword [rel _window + 40] ; r12 = _window.pixels (start buffer pos)
    add r13, r12                      ; r13 = end buffer pos
    add rax, r12                      ; rax = pixel pos in the buffer

    ret


; After setting up the pixel rasterizer, this function will actually rasterize pixels
; Args:
;     rax - position in the buffer to draw
;     r12 - start buffer pos (for bounds checking)
;     r13 - end buffer pos
;     r8d - color
; Returns: Args
RasterizePixel:

    cmp rax, r12                      ; if (drawPos < bufferStart)
    jl .ignore                        ;     goto ignore
    cmp rax, r13                      ; if (drawPos > bufferEnd)
    jg .ignore                        ;     goto ignore

    mov [rax], r8d                    ; Draw pixel

    .ignore:

    ret


; Unpacks a vector2 of i32's
; Args:
;     rcx - (x, y)
; Returns:
;     r10d - x
;     r11d - y
_unpack_i32_vec2:
    push rcx

    xor r10, r10
    mov r10d, ecx                     ; r10 = x
    shr rcx, 32
    mov r11, rcx                      ; r11 = y

    pop rcx
    ret

global DrawPixel
; __fastcall void DrawPixel( i32_vec2 pos, u8_color color );
;     rcx - pos (x, y)
;     edx - color
DrawPixel:
    call _unpack_i32_vec2            ; r10 = pos.x
                                     ; r11 = pos.y
    mov r8d, edx                     ; r8d = color

    call SetupRasterizer
    call RasterizePixel


    ret

global DrawRectangle
; __fastcall void DrawRectangle( i32_vec2 pos, i32_vec2 size, u8_color color );
;     rcx - pos (x, y)
;     rdx - size (width, height)
;     r8d - color (r, g, b, a)
DrawRectangle:
    ; Create stack frame
    ; push rbp
    ; mov rbp, rsp

    call _unpack_i32_vec2            ; r10 = pos.x
                                     ; r11 = pos.y

    mov ecx, edx                     ; rcx = width
    shr rdx, 32                      ; rdx = height
    
    add r10, rcx                     ; x   += width (counter)
    add r11, rdx                     ; y   += height (counter)
    mov r15, rcx
    shl r15, 2                       ; r15 = reset width offset
    
    call SetupRasterizer
    sub r11, r15                     ; When we go up a layer, this ensures width is reset
    mov r14, rcx                     ; r14 = reset width counter
    
    .loopY:
        .loopX:
            call RasterizePixel
            sub rax, r10
            dec ecx
            jnz .loopX

        mov ecx, r14d
        
        sub rax, r11
        dec edx
        jnz .loopY



    ; Exit
    ; mov rsp, rbp
    ; pop rbp
    ret

global _PlotLineLow
; __fastcall void _PlotLineLow( i32_vec2 pos0, i32_vec2 pos1, u8_color color );
_PlotLineLow:

    ret