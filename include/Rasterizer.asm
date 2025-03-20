

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
; __fastcall void RasterizeRectangle( uint32_t x, uint32_t y, uint32_t size, uint32_t color );
;     ecx = x
;     edx = y
;     r8d = size (width, height)
;     r9d = color (r, g, b, a)
RasterizeRectangle:
    ; Create stack frame
    ; push rbp
    ; mov rbp, rsp

    ; Setup pixel pointer
    xor rbx, rbx                      ; rbx = 0 (just in case... hopefully nothing important in there)
    mov ebx, dword [rel _window]      ; ebx = _window.width
    mov eax, edx                      ; eax = y
    imul eax, ebx                     ; eax = y * _window.width
    add eax, ecx                      ; eax = y * _window.width + x
    imul eax, 4                       ; Ensure we're addressing colors as uint32_t's
    add rax, qword [rel _window + 40] ; eax += _window.pixels

    ; Setup loop
    mov r12d, r8d                     ; r12d = size
    shr r12d, 16
    imul r12d, 4                      ; r12w = width = i
    mov r13w, r12w                    ; Store width to be reset each row iteration

    and r8, 0xFFFF
    imul ebx, 4
    imul r8w, bx                     ; r8w  = height = j

    
.loop_y:
    .loop_x:
        add rax, r8                  ; This is cheesy, but whatever
        add rax, r12
        mov [rax], r9d               ; Draw the pixel
        sub rax, r8                  ; Clean up
        sub rax, r12

        sub r12w, 4                  ; i--
        jnz .loop_x
    
    mov r12w, r13w                   ; i = width
    sub r8w, bx                      ; j--
    jnz .loop_y

    ; Exit
    ; mov rsp, rbp
    ; pop rbp
    ret