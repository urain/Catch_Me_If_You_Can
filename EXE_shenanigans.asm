PUBLIC MyAsmFunction

.code
MyAsmFunction PROC
push rax
xor rax, rax

checkDebugger:
mov rax, gs:[60h]
mov rax, [rax + 2]
test al, al
jnz fuckUpCode	; if debugger attached, fuck up code

call callHere
callHere:
pop rcx
mov rax, 0FFFFFFFFFFFFF000h
and rcx, rax 
add rcx, 040h ; should be our CatchThisThread func since it's close
call rcx			; call CatchThisThread
jmp myReturn	; if debug not attached, all gucci

fuckUpCode:
mov rax, 1
mov [rcx], al
xor rax, rax
mov rax, 1

myReturn:
pop rax
ret
MyAsmFunction ENDP
END
