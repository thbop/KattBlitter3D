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
;     r8d - color
DrawRectangle:

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

    ret


global _PlotLineLow
; https://github.com/thbop/TinyGames/blob/main/shapes.h#L11
; __fastcall void _PlotLineLow( i32_vec2 pos0, i32_vec2 pos1, u8_color color );
;     rcx - pos0 (x0, y0)
;     rdx - pos1 (x1, y1)
;     r8d - color
_PlotLineLow:
    call _unpack_i32_vec2            ; r10 = x0
                                     ; r11 = y0
    mov ecx, edx                     ; rcx = x1
    shr rdx, 32                      ; rdx = y1
    push rcx                         ; push x1
    push r10                         ; push x0

    sub rcx, r10                     ; rcx = dx = x1 - x0
    sub rdx, r11                     ; rdx = dy = y1 - y0
    mov r9, 1                        ; r9  = yi = 1
    
    cmp rdx, 0
    jge .positive                    ; if ( dy < 0 )
        neg r9                       ;     r9  = yi = -1
        neg rdx                      ;     rdx = dy = -dy
    .positive:
    
    mov rax, rdx                     ; rax = dy
    sub rax, rcx                     ; rax = dy - dx
    shl rax, 1                       ; rax = 2 * (dy - dx)
    
    shl rdx, 1                       ; rdx = 2 * dy
    mov rbx, rdx                     ; rbx = 2 * dy (delta D 1)
    
    sub rdx, rcx                     ; rdx = D = (2 * dy) - dx
    mov rcx, rax                     ; rcx = 2 * (dy - dx) (delta D 0)

    pop r14                          ; r14 = x = x0
    
    call SetupRasterizer
                                     ; 4  = x delta
    imul r9, r11                     ; r9 = y delta

    pop r10                          ; r10 = x1

    .plotLoop:                       ; for ( x = x0; x < x1; x++ )
        cmp r14, r10
        jge .exitLoop                ; x < x1 (for)

        call RasterizePixel

        cmp rdx, 0
        jle .negative                ; if ( D > 0 )
            add rax, r9              ;     y += yi (sorta)
            add rdx, rcx             ;     D += 2 * (dy - dx)
        jmp .endif
        .negative:                   ; else
            add rdx, rbx             ;     D += 2 * dy
        .endif:


        inc r14
        add rax, 4                   ; x++ (for)
        jmp .plotLoop

    .exitLoop:
    
    ret

global _PlotLineHigh
; https://github.com/thbop/TinyGames/blob/main/shapes.h#L37
; __fastcall void _PlotLineHigh( i32_vec2 pos0, i32_vec2 pos1, u8_color color );
;     rcx - pos0 (x0, y0)
;     rdx - pos1 (x1, y1)
;     r8d - color
_PlotLineHigh:
    call _unpack_i32_vec2            ; r10 = x0
                                     ; r11 = y0
    mov ecx, edx                     ; rcx = x1
    shr rdx, 32                      ; rdx = y1
    push rdx                         ; push y1
    push r11                         ; push y0

    sub rcx, r10                     ; rcx = dx = x1 - x0
    sub rdx, r11                     ; rdx = dy = y1 - y0
    mov r9, 1                        ; r9  = xi = 1
    
    cmp rcx, 0
    jge .positive                    ; if ( dx < 0 )
        neg r9                       ;     r9  = xi = -1
        neg rcx                      ;     rcx = dx = -dx
    .positive:
    
    mov rax, rcx                     ; rax = dx
    sub rax, rdx                     ; rax = dx - dy
    shl rax, 1                       ; rax = 2 * (dx - dy)
    
    shl rcx, 1                       ; rcx = 2 * dx
    mov rbx, rcx                     ; rbx = 2 * dx (delta D 1)
    
    sub rcx, rdx                     ; rcx = D = (2 * dx) - dy
    mov rdx, rax                     ; rdx = 2 * (dx - dy) (delta D 0)

    pop r14                          ; r14 = y = y0
    
    call SetupRasterizer
    imul r9, r10                     ; r9  = x delta
                                     ; r11 = y delta

    pop r10                          ; r10 = y1

    .plotLoop:                       ; for ( y = y0; y < y1; y++ )
        cmp r14, r10
        jge .exitLoop                ; y < y1 (for)

        call RasterizePixel

        cmp rcx, 0
        jle .negative                ; if ( D > 0 )
            add rax, r9              ;     x += xi (sorta)
            add rcx, rdx             ;     D += 2 * (dx - dy)
        jmp .endif
        .negative:                   ; else
            add rcx, rbx             ;     D += 2 * dy
        .endif:


        inc r14
        add rax, r11                 ; y++ (for)
        jmp .plotLoop

    .exitLoop:
    
    ret