# Catch Me If You Can
FOR EDUCATIONAL PURPOSES ONLY:
This project demonstrates some "interesting" things you can do with ASM, VBA, Word, HTA, and EXE.

## VBA_Shenanigans
Demonstrating some cool things you can do with VBA inside Word Documents:
1. The ability to directly call exported APIs from Windows DLLs.
2. The ability to dynamically allocate RWX memory and copy/execute data.
3. The ability to dynamically assign a function to raw bytes and execute.
4. The ability to implement custom deobfuscation/decoding from Word Document Headers.
5. The ability to write deobfuscated/decoded data to disk and launch EXEs.
* For added safety, the DOCX does not have the VBA macro in it. You need to put it in there yourself.

## EXE_Shenanigans
Some interesting things you can do with TLS callbacks, debugger detection, and polymorphic code. This was specifically written to be the stage 2 for VBA_Shenanigans.

## HTA_Shenanigans
Simple example of an HTA file that opens a cmd prompt.
