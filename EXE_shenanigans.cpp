/*
' This binary has a TLS callback which checks for a debugger 
' via the PEB. If a debugger is found then it finds the address of 
' main and VirtualProtects the page to ERW. It then writes 0x01 
' to the first byte at that address and re-protects the memory with 
' the original protections. This essentially breaks the assembly 
' language at that location and causes a fault when executing. 
' If you execute the binary outside of a debugger, the TLS will call 
' a subfunction which prints "...catch this string", returns to TLS, goes 
' to main, prints "...you didn't catch the string", and then infinite loops.
*/
#include "stdafx.h"
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <cstdlib>
#include <Windows.h>

extern "C" int MyAsmFunction(void*);

#pragma optimize( "", off) // disables optimizations which cause this to be removed since it has no refs. 
						   // it is called by doing math in the asm function
void CatchThisThread() {
	std::cout << "Hey This Is The String You Need To Catch...\n" << std::endl;
	return;
}
#pragma optimize( "", on)

int main()
{
	//HANDLE myThread = CreateThread(0, 0, (LPTHREAD_START_ROUTINE)CatchThisThread, 0, 0, 0);
	//WaitForSingleObject(myThread, -1);
	std::cout << "Hey You Didn't Catch The String\n" << std::endl;
	while (TRUE) {
		continue;
	}
    return 0;
}


void NTAPI tls_callback1(PVOID DLLHandle, DWORD dwReason, PVOID) {
	// modify code if debugger is present
	DWORD myProts = 0;
	int xxx = VirtualProtect((void*)&main, 1024, 0x40, &myProts);
	MyAsmFunction((void*)&main);// , (void*)&CatchThisThread); // rcx, rdx
	xxx = VirtualProtect((void*)&main, 1024, myProts, &myProts);
	return;
}

#pragma comment (linker, "/INCLUDE:_tls_used")
#pragma comment (linker, "/INCLUDE:p_tls_callback1")
#pragma const_seg(push)
#pragma const_seg(".CRT$XLAAA")
EXTERN_C const PIMAGE_TLS_CALLBACK p_tls_callback1 = tls_callback1;
#pragma const_seg(pop)
