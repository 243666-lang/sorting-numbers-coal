.model small
.stack 100h

.data
       ;Messages
   msg1 db "Enter array size (1-20): $"
   msg2 db 0dh,0ah,"Enter numbers (0-99):$"
   msg3 db 0dh,0ah,0dh,0ah,"Sorted Array: $"
   msg_sort db 0dh,0ah,0dh,0ah,"Choose sorting algorithm:$"
   msg1_sort db 0dh,0ah,"1. Bubble Sort$"
   msg2_sort db 0dh,0ah,"2. Selection Sort$"
   msg3_sort db 0dh,0ah,"3. Insertion Sort$"
   msg_sort_order db 0dh,0ah,0dh,0ah,"Choose sorting order:$"
   msg1_order db 0dh,0ah,"1. Ascending$"
   msg2_order db 0dh,0ah,"2. Descending$"
   msg3_order db 0dh,0ah,"3. Even-First$" 
   msg4_order db 0dh,0ah,"4. Odd-First$"
   msg_choice_algo db 0dh,0ah,"Enter choice (1-3): $"
   msg_choice_order db 0dh,0ah,"Enter choice (1-4): $"
   msg_mem_before db 0dh,0ah,0dh,0ah,"=== MEMORY BEFORE SORTING ===$"
   msg_mem_after db 0dh,0ah,0dh,0ah,"=== MEMORY AFTER SORTING ===$"
   msg_index db 0dh,0ah,"Index : Value$"
   msg_invalid_choice db 0dh,0ah,"Invalid choice!$"
   msg_invalid_num db 0dh,0ah,"Invalid! Enter 0-99.$"
   msg_inc db 0dh,0ah,"Pattern: Strictly Increasing$"
   msg_dec db 0dh,0ah,"Pattern: Strictly Decreasing$"
   msg_random db 0dh,0ah,"Pattern: Random/Mixed$"
   msg_freq_header db 0dh,0ah,0dh,0ah,"=== FREQUENCY ANALYSIS ===$"
   msg_stats_header db 0dh,0ah,0dh,0ah,"=== STATISTICS ===$"
   msg_min db 0dh,0ah,"Minimum: $"
   msg_max db 0dh,0ah,"Maximum: $"
   msg_sum db 0dh,0ah,"Sum: $"
   msg_avg db 0dh,0ah,"Average: $"
   msg_enter_num db 0dh,0ah,"Number $"
   msg_colon db ": $"
   msg_times db " times$"
   visited db 21 dup(0)
       
       ;Data Storage
   array db 21 dup(?)
   temp_array db 21 dup(?)
   size db ?
   sort_algo db ?
   sort_order db ?

.code

;=== UTILITY PROCEDURES ===

;Print newline
print_newline proc
    push ax
    push dx
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    int 21h
    pop dx
    pop ax
    ret
print_newline endp

;Read 2-digit number (0-99) into AL
read_number proc
    push bx
    push cx
    push dx
    
    xor bx, bx
    xor cx, cx
    
read_digit_loop:
    mov ah, 01h
    int 21h
    
    cmp al, 0Dh
    je read_done
    
    cmp al, '0'
    jb read_digit_loop
    cmp al, '9'
    ja read_digit_loop
    
    sub al, '0'
    
    ; BX = BX * 10 + digit
    push ax
    mov ax, bx
    mov bx, 10
    mul bx
    mov bx, ax
    pop ax
    
    xor ah, ah
    add bx, ax
    
    cmp bx, 99
    ja read_overflow
    
    jmp read_digit_loop
    
read_overflow:
    sub bx, ax
    jmp read_digit_loop
    
read_done:
    mov al, bl
    pop dx
    pop cx
    pop bx
    ret
    
read_number endp

;Print 2-digit number from AL (0-99)
print_number proc
    push ax
    push bx
    push dx
    
    xor ah, ah
    mov bl, 10
    div bl
    
    cmp al, 0
    je print_ones
    push ax
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    pop ax
    
print_ones:
    mov al, ah
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
    pop dx
    pop bx
    pop ax
    ret
print_number endp

;Print 16-bit number from AX (0-65535)
print_number_16bit proc
    push ax
    push bx
    push cx
    push dx
    
    cmp ax, 0
    jne start_print
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp end_print
    
start_print:
    mov bx, 10
    xor cx, cx
    
divide_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne divide_loop
    
print_digits:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_digits
    
end_print:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_number_16bit endp

;Swap array[SI] with array[DI]
swap proc
    push ax
    mov al, array[si]
    xchg al, array[di]
    mov array[si], al
    pop ax
    ret
swap endp

;=== DISPLAY PROCEDURES ===

;Display memory layout
display_memory proc
    push ax
    push bx
    push cx
    push dx
    push si

    lea dx, msg_index
    mov ah, 09h
    int 21h

    xor si, si
    xor bl, bl
    mov cl, size

next_mem:
    call print_newline
    
    mov al, bl
    call print_number
    
    lea dx, msg_colon
    mov ah, 09h
    int 21h
    
    mov al, array[si]
    call print_number

    inc bl
    inc si
    dec cl
    jnz next_mem

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_memory endp

;Display statistics
display_statistics proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    lea dx, msg_stats_header
    mov ah, 09h
    int 21h
    
    mov si, 0
    mov al, array[si]
    mov bl, al
    mov bh, al
    xor dx, dx
    mov cl, size
    
stats_loop:
    mov al, array[si]
    
    cmp al, bl
    jae check_max
    mov bl, al
    
check_max:
    cmp al, bh
    jbe update_sum
    mov bh, al
    
update_sum:
    xor ah, ah
    add dx, ax
    
    inc si
    dec cl
    jnz stats_loop
    
    lea dx, msg_min
    mov ah, 09h
    int 21h
    mov al, bl
    call print_number
    
    lea dx, msg_max
    mov ah, 09h
    int 21h
    mov al, bh
    call print_number
    
    lea dx, msg_sum
    mov ah, 09h
    int 21h
    mov ax, dx
    call print_number_16bit
    
    ; Calculate average
    push dx
    mov al, size
    xor ah, ah
    mov bx, ax
    pop ax
    xor dx, dx
    div bx
    
    lea dx, msg_avg
    push ax
    mov ah, 09h
    int 21h
    pop ax
    call print_number_16bit
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_statistics endp

;=== ANALYSIS PROCEDURES ===

;Pattern Detection
pattern_check proc
    push ax
    push bx
    push cx
    push si

    mov si, 0
    mov cl, size
    cmp cl, 1
    jle pattern_random
    
    mov al, array[si]
    mov bl, al
    inc si
    dec cl
    
check_inc_loop:
    cmp cl, 0
    je pattern_inc_done
    mov al, array[si]
    cmp al, bl
    jbe pattern_inc_fail
    mov bl, al
    inc si
    dec cl
    jmp check_inc_loop
    
pattern_inc_done:
    lea dx, msg_inc
    mov ah, 09h
    int 21h
    jmp pattern_exit
    
pattern_inc_fail:
    mov si, 0
    mov cl, size
    mov al, array[si]
    mov bl, al
    inc si
    dec cl
    
check_dec_loop:
    cmp cl, 0
    je pattern_dec_done
    mov al, array[si]
    cmp al, bl
    jae pattern_random
    mov bl, al
    inc si
    dec cl
    jmp check_dec_loop
    
pattern_dec_done:
    lea dx, msg_dec
    mov ah, 09h
    int 21h
    jmp pattern_exit
    
pattern_random:
    lea dx, msg_random
    mov ah, 09h
    int 21h

pattern_exit:
    pop si
    pop cx
    pop bx
    pop ax
    ret
pattern_check endp

;Frequency Analysis
frequency_analysis proc
   push ax
   push bx
   push cx
   push dx
   push si
   push di

   lea dx, msg_freq_header
   mov ah, 09h
   int 21h

   mov cx, 21
   mov di, 0
clear_visited:
   mov visited[di], 0
   inc di
   loop clear_visited

   mov cl, size
   xor si, si

outer_freq:
   mov ch, 0
   cmp si, cx
   jae freq_done

   cmp visited[si], 1
   je next_outer

   mov al, array[si]
   mov bl, 1
   mov visited[si], 1

   mov di, si
   inc di

inner_freq:
   mov ch, 0
   cmp di, cx
   jae print_freq
   
   mov ah, array[di]
   cmp ah, al
   jne skip_inner
   inc bl
   mov visited[di], 1
   
skip_inner:
   inc di
   jmp inner_freq

print_freq:
   call print_newline
   push ax
   call print_number
   
   lea dx, msg_colon
   mov ah, 09h
   int 21h
   
   mov al, bl
   call print_number
   
   lea dx, msg_times
   mov ah, 09h
   int 21h
   
   pop ax

next_outer:
   inc si
   jmp outer_freq

freq_done:
   pop di
   pop si
   pop dx
   pop cx
   pop bx
   pop ax
   ret
frequency_analysis endp

;=== SORTING PROCEDURES ===

;Even-First Sorting
even_odd_sort proc
    push ax
    push bx
    push cx
    push si
    push di

    mov cl, size
    mov ch, 0
    xor si, si
    xor di, di

collect_even:
   cmp si, cx
   jae collect_odd_start
   mov al, array[si]
   test al, 1
   jnz skip_even_collect
   mov temp_array[di], al
   inc di
skip_even_collect:
   inc si
   jmp collect_even

collect_odd_start:
   xor si, si
collect_odd:
   cmp si, cx
   jae copy_back_start
   mov al, array[si]
   test al, 1
   jz skip_odd_collect
   mov temp_array[di], al
   inc di
skip_odd_collect:
   inc si
   jmp collect_odd

copy_back_start:
   xor si, si
copy_back:
   cmp si, cx
   jae done_eo
   mov al, temp_array[si]
   mov array[si], al
   inc si
   jmp copy_back

done_eo:
   pop di
   pop si
   pop cx
   pop bx
   pop ax
   ret
even_odd_sort endp

;Odd-First Sorting
odd_even_sort proc
    push ax
    push bx
    push cx
    push si
    push di

    mov cl, size
    mov ch, 0
    xor si, si
    xor di, di

collect_odd_first:
   cmp si, cx
   jae collect_even_second_start
   mov al, array[si]
   test al, 1
   jz skip_odd_first_collect
   mov temp_array[di], al
   inc di
skip_odd_first_collect:
   inc si
   jmp collect_odd_first

collect_even_second_start:
   xor si, si
collect_even_second:
   cmp si, cx
   jae copy_back_oe_start
   mov al, array[si]
   test al, 1
   jnz skip_even_second_collect
   mov temp_array[di], al
   inc di
skip_even_second_collect:
   inc si
   jmp collect_even_second

copy_back_oe_start:
   xor si, si
copy_back_oe:
   cmp si, cx
   jae done_oe
   mov al, temp_array[si]
   mov array[si], al
   inc si
   jmp copy_back_oe

done_oe:
   pop di
   pop si
   pop cx
   pop bx
   pop ax
   ret
odd_even_sort endp

;Bubble Sort
bubble_sort_proc:
    mov cl, size
    dec cl

bubble_outer:
    cmp cl, 0
    je after_sort
    mov si, 0
    mov ch, cl

bubble_inner:
    mov al, array[si]
    mov di, si
    inc di
    mov bl, array[di]

    cmp sort_order, 1
    jne bubble_desc

    cmp al, bl
    jbe no_swap_bubble
    call swap
    jmp no_swap_bubble

bubble_desc:
    cmp sort_order, 2
    jne no_swap_bubble
    cmp al, bl
    jae no_swap_bubble
    call swap

no_swap_bubble:
    inc si
    dec ch
    jnz bubble_inner

    dec cl
    jmp bubble_outer

;Selection Sort
selection_sort_proc:
    mov cl, 0

sel_outer:
    mov al, size
    dec al
    cmp cl, al
    jae after_sort

    mov bl, cl
    mov ch, cl
    inc ch

sel_inner:
    cmp ch, size
    jae sel_swap

    mov al, ch
    mov ah, 0
    mov si, ax
    mov al, array[si]

    mov dl, bl
    mov dh, 0
    mov di, dx
    mov dl, array[di]

    cmp sort_order, 1
    jne sel_desc
    cmp al, dl
    jge sel_next
    mov bl, ch
    jmp sel_next

sel_desc:
    cmp sort_order, 2
    jne sel_next
    cmp al, dl
    jle sel_next
    mov bl, ch

sel_next:
    inc ch
    jmp sel_inner

sel_swap:
    cmp bl, cl
    je sel_continue
    mov al, cl
    mov ah, 0
    mov si, ax
    mov al, bl
    mov ah, 0
    mov di, ax
    call swap

sel_continue:
    inc cl
    jmp sel_outer

;Insertion Sort
insertion_sort_proc:
    mov cl, 1

ins_outer:
    cmp cl, size
    jae after_sort

    mov al, cl
    mov ah, 0
    mov si, ax
    mov al, array[si]

    mov ch, cl
    dec ch

ins_inner:
    cmp ch, 0FFh
    je ins_place

    mov dl, ch
    mov dh, 0
    mov di, dx
    mov bl, array[di]

    cmp sort_order, 1
    jne ins_desc
    cmp bl, al
    jbe ins_place

    inc di
    mov array[di], bl
    dec ch
    jmp ins_inner

ins_desc:
    cmp sort_order, 2
    jne ins_place
    cmp bl, al
    jae ins_place
    inc di
    mov array[di], bl
    dec ch
    jmp ins_inner

ins_place:
    mov dl, ch
    inc dl
    mov dh, 0
    mov di, dx
    mov array[di], al

    inc cl
    jmp ins_outer

after_sort:
    cmp sort_order, 3
    je even_first
    cmp sort_order, 4
    je odd_first
    jmp skip_even_odd
    
even_first:
    call even_odd_sort
    jmp skip_even_odd
    
odd_first:
    call odd_even_sort
    
skip_even_odd:
    lea dx, msg_mem_after
    mov ah, 09h
    int 21h
    call display_memory
    call pattern_check
    call display_statistics
    call frequency_analysis
    
    lea dx, msg3
    mov ah, 09h
    int 21h
    
    mov si, 0
    mov cl, size
    
display_loop:
    cmp cl, 0
    je done_display
    
    mov al, array[si]
    call print_number
    
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    inc si
    dec cl
    jnz display_loop
    
done_display:
    call print_newline
    jmp exit_program

;=== MAIN PROGRAM ===
main proc
    mov ax, @data
    mov ds, ax
    
input_size:
    lea dx, msg1
    mov ah, 09h
    int 21h
    
    call read_number
    mov size, al
    
    cmp size, 1
    jb input_size
    cmp size, 20
    ja input_size
    
    lea dx, msg2
    mov ah, 09h
    int 21h
    
    mov cl, size
    mov si, 0
    xor bl, bl
    
input_loop:
    lea dx, msg_enter_num
    mov ah, 09h
    int 21h
    
    inc bl
    mov al, bl
    call print_number
    
    lea dx, msg_colon
    mov ah, 09h
    int 21h
    
    call read_number
    mov array[si], al
    
    inc si
    dec cl
    jnz input_loop
    
    lea dx, msg_sort
    mov ah, 09h
    int 21h
    
    lea dx, msg1_sort
    mov ah, 09h
    int 21h
    
    lea dx, msg2_sort
    mov ah, 09h
    int 21h
    
    lea dx, msg3_sort
    mov ah, 09h
    int 21h
    
    lea dx, msg_choice_algo
    mov ah, 09h
    int 21h
    
    mov ah, 01h
    int 21h
    sub al, '0'
    mov sort_algo, al
    
    cmp sort_algo, 1
    jb invalid_choice
    cmp sort_algo, 3
    ja invalid_choice
    
    lea dx, msg_sort_order
    mov ah, 09h
    int 21h
    
    lea dx, msg1_order
    mov ah, 09h
    int 21h
    
    lea dx, msg2_order
    mov ah, 09h
    int 21h
    
    lea dx, msg3_order
    mov ah, 09h
    int 21h
    
    lea dx, msg4_order
    mov ah, 09h
    int 21h
    
    lea dx, msg_choice_order
    mov ah, 09h
    int 21h
    
    mov ah, 01h
    int 21h
    sub al, '0'
    mov sort_order, al
    
    cmp sort_order, 1
    jb invalid_choice
    cmp sort_order, 4
    ja invalid_choice     
    
    lea dx, msg_mem_before
    mov ah, 09h
    int 21h
    call display_memory
    
    cmp sort_algo, 1
    je bubble_sort_proc
    cmp sort_algo, 2
    je selection_sort_proc
    cmp sort_algo, 3
    je insertion_sort_proc
    
invalid_choice:
    lea dx, msg_invalid_choice
    mov ah, 09h
    int 21h
    jmp exit_program
    
exit_program:
    call print_newline
    mov ah, 4ch
    int 21h
    
main endp
end main