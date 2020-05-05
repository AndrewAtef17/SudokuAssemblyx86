INCLUDE Irvine32.inc
INCLUDE macros.inc
BUFFER_SIZE = 500
.data
	;Used For Drawing the Board
	numberline BYTE "        1    2    3    4    5    6    7    8    9 ",0

    BoardString1  BYTE "     " , 201 , 205 , 3 dup(205) , 209 , 205 , 3 dup(205) , 209 , 205 , 3 dup(205) , 203 , 205 , 3 dup(205) , 209 , 205
			      BYTE 3 dup(205) , 209 , 205 , 3 dup(205) , 203 , 205 , 3 dup(205) , 209 , 205 , 3 dup(205) , 209 , 205 , 3 dup(205) , 187, 0
	RowString     BYTE "   ? " , 186 , 32 , " " , 2 dup(32) , 179 , 32 , " " , 2 dup(32) , 179 , 32 , " " , 2 dup(32) , 186 , 32 , " " , 2 dup(32) , 179 , " " 
			      BYTE 3 dup(32)  , 179 , 32 , " " , 2 dup(32) , 186 , 32 , " " , 2 dup(32) , 179 , 32 , " " , 2 dup(32) , 179 , 32 , " " , 2 dup(32) , 186, 0     
    BoardString2  BYTE "     " , 199 , 196 , 3 dup(196) , 197 , 196 , 3 dup(196) , 197 , 196 , 3 dup(196) , 215 , 196 , 3 dup(196) , 197 , 196
			      BYTE 3 dup(196) , 197 , 196 , 3 dup(196) , 215 , 196 , 3 dup(196) , 197 , 196 , 3 dup(196) , 197 , 196 , 3 dup(196) , 182, 0    
    BoardString3  BYTE "     " , 204 , 205 , 3 dup(205) , 216 , 205 , 3 dup(205) , 216 , 205 , 3 dup(205) , 206 , 205 , 3 dup(205) , 216 , 205
			      BYTE 3 dup(205) , 216 , 205 , 3 dup(205) , 206 , 205 , 3 dup(205) , 216 , 205 , 3 dup(205) , 216 , 205 , 3 dup(205) , 185, 0
    BoardString4  BYTE "     " , 200 , 205 , 3 dup(205) , 207 , 205 , 3 dup(205) , 207 , 205 , 3 dup(205) , 202 , 205 , 3 dup(205) , 207 , 205
				  BYTE 3 dup(205) , 207 , 205 , 3 dup(205) , 202 , 205 , 3 dup(205) , 207 , 205 , 3 dup(205) , 207 , 205 , 3 dup(205) , 188, 0
	;mult used for the 2d array index
	;buffer recieves the text from text file , savetemp saves the text in the file
	;unsolved , solvd , color used for the boards and coloring the cells
	mult dword 9
    buffer byte BUFFER_SIZE dup(?)
	unsolved byte BUFFER_SIZE dup(?)
	solved byte BUFFER_SIZE dup(?)
	color byte BUFFER_SIZE dup(?)
	savetemp byte BUFFER_SIZE dup(?)
	;2d array index, filehandle for errors in reading and saving file
    index dword ?
	fileHandle HANDLE ?
	;text file names:
	filename byte "Levels/diff_?_?.txt",0
	answerfile byte "Levels/diff_?_?_solved.txt",0
	oldgamefile byte "LastGame/continue.txt",0
	oldgameunsolved byte "LastGame/unsolved.txt",0
	oldgamesolved byte "LastGame/solved.txt",0
	str1 BYTE "Cannot create file",0dh,0ah,0
	savedfileoffset dword ? ;saves the file name offset to use in the save file procedure
	choice dword ? 	;choice is bool to save if user load or start new game
	auto_complete dword 0 ;bool if the player choose to end the board

	;Used to save the correct and false counters and the time in mins,seconds:
	numIn_CorrectAns byte 0, 0, 0, 0
	strOutput byte 16 dup(0)
	numofdigits dword 0
	loadcounter byte "LastGame/counters.txt",0
	loadcounterbool dword 0
	savecounterbool dword 0
	num_cells_left dword 0
	startTime DWORD ?
	endTime DWORD ?
	mstos DWORD 1000
	sectomin DWORD 60
.code

main PROC

call starting_game
call ingame_choices

    exit
main ENDP

;-----------------------------------------------------------------------------------------------------------------------------------
;Gives Choice of Starting new board or loading the previous board
;1-if user choice was to start new board he will get another choice of Difficulty level
;when he chooses the difficuly level it will call Randomize which give a random board of 3 each level 
;then it will load the board and its answer in the 2d arrays using ReadF function
;2- if the user choice was to load the old board it will load the part-solved board and its answer and the old scores and time taken
;it will calculate the number of cells left in both choices
;if you choose numbers other than the 2 choices it will return to the choices again.
;-----------------------------------------------------------------------------------------------------------------------------------
starting_game proc

wrongchoice:
mWrite<"-Press 1 to start a new game",0dh,0ah>
mWrite<"-Press 2 to load a previous game",0dh,0ah>
call readdec
cmp eax,1
JNZ else2 ;if ==1
;CHOOSING DIFFICULTY
mov choice , 1
mWrite <"Enter Difficulty choice",0dh,0ah>
mWrite <"1- Easy",0dh,0ah>
mWrite <"2- Meduium",0dh,0ah>
mWrite <"3- Hard",0dh,0ah>
call readdec
add eax,48
mov filename[12],al
mov answerfile[12],al
;RANDOMIZING
call Randomize
mov eax,3               
call RandomRange
add eax,49
mov filename[14],al
mov answerfile[14],al
mov edx,OFFSET filename
mov esi,offset unsolved
call readF
mov edx,OFFSET filename
mov esi,offset color
call readF
mov edx,OFFSET answerfile
mov esi,offset solved
call readF
jmp start


else2: ;else if == 2
cmp eax,2
JNZ wrongchoice
mov choice , 2 
mov edx,OFFSET oldgameunsolved
mov esi,offset color
call readF
mov edx,OFFSET oldgamefile
mov esi,offset unsolved
call readF
mov edx,OFFSET oldgamesolved
mov esi,offset solved
call readF
mov edx,OFFSET loadcounter
mov loadcounterbool,1
call readF
mov loadcounterbool,0
start:
call print
call numcells
ret
starting_game endp

;-----------------------------------------------------------------------------------------------------------------------------------
;Gives the in-games choices after starting the game and loading the board
;onces you start this procedure then the begin time starts
;1- is to end the game and print solved cells giving you number of mistakes and number of right answers and the time taken since you started
;it calls print procedure giving it the bool of auto complete = 1
;2- is to clear the current board to its original and resets the counters and time
;it calls readF to read the unsolved file and replace the current one then calculates the number of remaining cells of the clean board
;3- is to give an answer to a cell it calls change procedure then checks the number of remaining cells 
;if its = 0 then you won and will print the final results
;4- Calculates the time taken using calculate time procedure then Saves the current board and stats in the LastGame file and exit the game calling saveF
;if you choose numbers other than the 4 choices it will return to the choices again.
;-----------------------------------------------------------------------------------------------------------------------------------
ingame_choices proc
call GetMseconds ; get start time
mov startTime,eax
Whileloop:
mWrite<"-Press 1 to print the finished board",0dh,0ah>
mWrite<"-Press 2 to clear the board to the initial Sudoku board",0dh,0ah>
mWrite<"-Press 3 to edit a cell in the board",0dh,0ah>
mWrite<"-Press 4 to Save and exit",0dh,0ah>
call readdec
cmp eax,1
JNZ else2 ;if ==1 stop time and calculate it, print,save and exit
call calculatetime
mov auto_complete,1
call clrscr
call print
jmp save_exit


else2:
cmp eax,2
JNZ else3 ;if ==2
mov eax, choice
cmp eax, 1
jnz oldgame ;if its new game load from the sudoku boards
mov edx,OFFSET filename
mov esi,offset unsolved
jmp continn
oldgame: ;else load from lastgame
mov edx,OFFSET oldgameunsolved
mov esi,offset unsolved
continn: ;clearing the counters and priting the board
mov numIn_CorrectAns, 0
mov numIn_CorrectAns + 1, 0
mov numIn_CorrectAns + 2, 0
mov numIn_CorrectAns + 3, 0
call readF
call numcells
call clrscr
call print
jmp Whileloop



else3:
cmp eax,3
JNZ else4 ;if ==3 ,change a cell
push ecx
call change
mov eax , num_cells_left ;checking if you win by number of cells left
cmp eax ,0
JNZ StillPlaying
call calculatetime
mov auto_complete,1 ;for printing counters
call clrscr
call print
mwrite <"YOU WIN!!!!!!">
jmp save_exit
StillPlaying:
pop ecx
jmp Whileloop




else4:
cmp eax,4
JNZ Whileloop ;if!=4 go back to choices
call calculatetime
save_exit:  ;savedfileffset carries the offset of the boards to save in the file after checking the filename without errors
mov edx , offset unsolved
mov savedfileoffset, edx
mov edx , offset oldgamefile
call saveF
mov edx , offset color
mov savedfileoffset, edx
mov edx , offset oldgameunsolved
call saveF
mov edx , offset solved
mov savedfileoffset, edx
mov edx , offset oldgamesolved
call saveF
mov edx , offset loadcounter
mov savecounterbool , 1
call saveF
ret
ingame_choices endp

;-----------------------------------------------------------------------------------------------------------------------------------------------
;Reads file giving offset of its name then it checks for errors using eax as Handle if it has no errors
;it takes the offset of the destination and checks for errors if it has no errors then it goes to that memory
;using the offset of Buffer array to always carry whats on the file
;then it checks for the loadcounterbool if its = 0 then it loads a board takes it from the file
;add the buffer in the esi register which carries the offset of the desitination array
;if the bool = 1 then it loads the counters and time take of the old board in the buffer and change them to integers using readCounters procedure
;------------------------------------------------------------------------------------------------------------------------------------------------
readF proc

call OpenInputFile
mov fileHandle,eax
; Check for errors.
cmp eax,INVALID_HANDLE_VALUE ; error opening file?
jne file_ok ; no: skip
mWrite <"Cannot open file",0dh,0ah>
jmp exitt ; and quit
file_ok:
; Read the file into a buffer.
mov edx,OFFSET buffer
mov ecx,BUFFER_SIZE
call ReadFromFile
jnc check_buffer_size ; error reading?
mWrite "Error reading file. " ; yes: show error message
call WriteWindowsMsg
call CloseFile
jmp exitt
check_buffer_size:
cmp eax,BUFFER_SIZE ; buffer large enough?
jb buf_size_ok ; yes
mWrite <"Error: Buffer too small for the file",0dh,0ah>
jmp exitt ; and quit
buf_size_ok:
mov buffer[eax],0 ; insert null terminator

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;LOADS THE COUNTERS IF LOADCOUNTERBOOL = 1
mov eax,loadcounterbool
cmp  eax,1
JNZ close_file
mov edx,offset buffer
call readCounters
mov numIn_correctans, al
call readCounters
mov numIn_correctans[1], al
call readCounters
mov numIn_correctans[2], al
call readCounters
mov numIn_correctans[3], al
mov eax,fileHandle
call CloseFile
jmp exitt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
close_file:
mov eax,fileHandle
call CloseFile

;else it takes 97 from the board 81 cells + 2*9 more bits for the end lines
;so this loop removs the 2*9 and changing the 0s to spaces for better looking board
mov ecx, 97
mov edx, offset buffer
L1:
	mov al, [edx]
	CMP al,57
	ja wronginput
	CMP al,48
	jb wronginput
	CMP al,48
	jnz notzero
	mov al,32
	notzero:
	mov [esi],al
	inc esi
	wronginput:
	inc edx
loop L1
exitt:
ret
readF endp

;-----------------------------------------------------------------------------------------------------------------------------------------------
;Saves file giving offset of its name then it checks for errors using eax as Handle if it has no errors
;it takes the offset of the destination from savedfileoffet variable and saves in the file
;if save counterbool = 1 it will go saving the counters and time if its = 0 will save the boards in the LastGame files
;------------------------------------------------------------------------------------------------------------------------------------------------
saveF proc
;getting offset of the name of file in edx from before the call
call CreateOutputFile
mov fileHandle,eax
; Check for errors.
cmp eax, INVALID_HANDLE_VALUE ; error found?
jne file_ok ; no: skip
mov edx,OFFSET str1 ; display error
call WriteString
jmp quit
file_ok:
; Write the buffer to the output file.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;COUNTERS SAVING if bool = 1
mov eax, savecounterbool
cmp eax,1
JNZ NotSavingCounters
mov eax, 0
mov al, numIn_correctans
call saveCounters
mov eax, 0
mov al, numIn_correctans[1]
call saveCounters
mov eax, 0
mov al, numIn_correctans[2]
call saveCounters
mov eax, 0
mov al, numIn_correctans[3]
call saveCounters
call CloseFile
jmp quit
;///////////////////////////////////////////////////////////////

;else returning the spaces to 0s and adding the endlines again to save the board in the text file as we got it from the file
;so takes the 81 bytes back to 97 bytes
NotSavingCounters:
mov edx, savedfileoffset
mov ecx ,9
mov eax,0
mov esi,0
L:
push ecx
mov ecx,9
L2:
mov al,[edx]
cmp al,32
jnz notspace
mov savetemp[esi],48
jmp contt
notspace:
mov savetemp[esi],al
contt:
inc edx
inc esi
loop L2
mov savetemp[esi],0Dh
inc esi
mov savetemp[esi],0Ah
inc esi
pop ecx
loop L

mov eax,fileHandle
mov edx, offset savetemp
mov ecx,97
call WriteToFile
call CloseFile
quit:
ret
saveF endp

;------------------------------------------------------------------------------------------------------------------------------------------------
;Changes a cell by giving 3 decimals from 0 - 9 which are row number and column number and cell value
;checks if its unchangeable cell then it updates the right/wrong moves counter (right or wrong) and updates the sudoku board then call print
;------------------------------------------------------------------------------------------------------------------------------------------------
change proc
wronginput:
mWrite <"Enter only from 1-9 Numbers: ",0dh,0ah>
mWrite "Enter Row Number: "
;checks every input that its fom 0-9 or it go back to wronginput label
;accesing index by taking the row number and dec by 1 as its 0-index based then multiplying by 9 for acccessing the row and adding the 2nd input-1 to access the column
call readdec
	CMP eax,9
	ja wronginput
	CMP eax,1
	jb wronginput
	dec eax
	mul mult
	mov index,eax
mWrite "Enter Column Number: "
call readdec
	CMP eax,9
	ja wronginput
	CMP eax,1
	jb wronginput
	dec eax
	add index,eax
mWrite "Enter the answer: "
call readint
	CMP eax,9
	ja wronginput
	CMP eax,1
	jb wronginput
	add al,48
mov edx,index
;if its already solved or built in sudoku will warn him and return to the ingame_choices procedure
push eax
mov al , unsolved[edx]
cmp al , 32
JZ notsolvedyet
call clrscr
call print
mov eax, 0Eh
call SetTextColor
mWrite <"This cell is Unchangeable!!(already been answerd or built with the sukoku board)",0dh,0Ah>
mov eax,white
call SetTextColor
pop eax
jmp exitt

notsolvedyet:
pop eax
;compares the answer with the solved board if its true it will add to the unsolved board and inc the correct counter 
;if its false wont update and inc the false counter and return to the ingame_choices procedure
cmp al,solved[edx] 
JNZ elseee 
mov unsolved[edx], al
call clrscr
call print
mov eax,green
call SetTextColor
mWrite<"THIS MOVE IS CORRECT!!!",0dh,0ah>
mov eax,white
call SetTextColor
dec num_cells_left
inc numIn_CorrectAns
jmp exitt
elseee:
call clrscr
call print
mov eax,red
call SetTextColor
mWrite<"THIS MOVE IS FALSE!!!",0dh,0ah>
mov eax,white
call SetTextColor
inc numIn_CorrectAns[1]
exitt:
ret
change endp
;---------------------------------------------------------------------------------------------------
;draws the sudoku board by printing its strings
;calls RowLoop to add to the Row string the values of every row
;calls MakeColors to print the cells with colors (red for correct /blue if end game and cells left)
;----------------------------------------------------------------------------------------------------
print PROC
	push ecx
	push ebx
	mov esi,offset unsolved
	mov ebx,0
    call Crlf
    call Crlf
	mov eax,green
	call SetTextColor
	mov edx,OFFSET numberline
    call WriteString
	mov eax,white
	call SetTextColor
    call Crlf
    mov edx,OFFSET BoardString1
    call WriteString
    call Crlf
	call RowLoop
	mov RowString[3],49 ;for drawing the vertical numberline
	call MakeColors
    mov edx,OFFSET BoardString2
    call WriteString
    call Crlf
	call RowLoop
	mov RowString[3],50
    call MakeColors
    mov edx,OFFSET BoardString2
    call WriteString
    call Crlf
	call RowLoop
	mov RowString[3],51
    call MakeColors
    mov edx,OFFSET BoardString3
    call WriteString
    call Crlf
	call RowLoop
	mov RowString[3],52
    call MakeColors
    mov edx,OFFSET BoardString2
    call WriteString
    call Crlf
	call RowLoop
	mov RowString[3],53
    call MakeColors
    mov edx,OFFSET BoardString2
    call WriteString
    call Crlf
	call RowLoop
	mov RowString[3],54
    call MakeColors
    mov edx,OFFSET BoardString3
    call WriteString
    call Crlf
	call RowLoop
	mov RowString[3],55
    call MakeColors
    mov edx,OFFSET BoardString2
    call WriteString
    call Crlf
	call RowLoop
	mov RowString[3],56
    call MakeColors
    mov edx,OFFSET BoardString2
    call WriteString
    call Crlf
	call RowLoop
	mov RowString[3],57
    call MakeColors
    mov edx,OFFSET BoardString4
    call WriteString
    call Crlf
	;if auto_complete = 1 then it will print the counters and time taken and cells left
	mov eax, auto_complete
	cmp eax, 1
	JNZ exitttt
	 call Crlf
	mWrite "Your number of correct tirals: "
	mov al, numIn_CorrectAns
	call Writedec
    call Crlf
	mWrite "Your number of Incorrect tirals: "
	mov al, numIn_CorrectAns[1]
	call Writedec
    call Crlf
	mWrite "Number of Cells Left: "
	mov eax, num_cells_left
	call Writedec
    call Crlf
	mWrite "Time Taken: "
	mov al, numIn_CorrectAns[2]
	call Writedec
	mWrite " mins "
	mov al, numIn_CorrectAns[3]
	call Writedec
	mWrite " secs"
    call Crlf
	exitttt:

	pop ebx
	pop ecx
    ret
print ENDP

;----------------------------------------------------
;loop the Row string to add the values of every row
;----------------------------------------------------
RowLoop proc
	mov ecx,9
	mov edx,7
    L:
        MOV al,[esi]
		mov RowString[edx], al
        inc esi
		add edx,5
    loop L
	 mov edx,OFFSET RowString
ret
RowLoop endp

;--------------------------------------------------------------------------------------
;draws every row and color the cells (red for correct /blue if end game and cells left)
;---------------------------------------------------------------------------------------
MakeColors proc uses esi
	mov ecx,5
	mov esi,0
	mov eax,green
	call SetTextColor
	L1:
	mov al,[edx]
	call writechar
	inc edx
	loop L1
	mov eax,white
	call SetTextColor
	mov ecx,2
	L2:
	mov al,[edx]
	call writechar
	inc edx
	loop L2


	mov ecx,9
	OuterLoop:
	push ecx
	cmp color[ebx]," "
	JNZ elseq ;if ==" "
	;IF AUTO COMPLETE WILL PRINT SOLVED RED AND UNSOLVED BLUE
	mov eax,auto_complete
	cmp eax,1
	JNZ notautocomplete
	mov al,solved[ebx]
	cmp unsolved[ebx] ,al
	JNZ elseqq ;if ==" "
	mov eax,red
	call SetTextColor
	jmp contt
	elseqq:
	mov eax,9h
	call SetTextColor
	mov al , solved[ebx]
	call writechar
	jmp conttt

	;IF AUTO COMPLETE = 0 WILL PRINT RED FOR ANSWERED ONLY
	notautocomplete:
	mov eax,red
	call SetTextColor ;RED BAS
	jmp contt

	
	elseq: ;else Print in white
	contt:
	mov al, [edx]
	call writechar
	conttt:
	inc edx
	inc ebx
	mov ecx,4
	mov eax,white
	call SetTextColor
	innerloop:
	mov al,[edx]
	call writechar
	inc edx
	loop innerloop
	pop ecx
	loop Outerloop
	call crlf
ret
MakeColors endp

;-----------------------------------------------------------------
;turn char to integer and returns the int value in the al register
;-----------------------------------------------------------------
readCounters proc
push ecx
push ebx
push edx ;our string

mov ecx, 0
add edx, numofdigits
mov ebx, 0
xor eax, eax ; zero a "result so far"
top:
mov cl, [edx] ; get a character
inc ebx
inc edx ; ready for next one
cmp ecx, '0' ; valid?
jb done
cmp ecx, '9'
ja done
sub ecx, '0' ; "convert" character to number
imul eax, 10 ; multiply "result so far" by ten
add eax, ecx ; add in current digit
jmp top ; until done
done:
add numofdigits, ebx

pop edx
pop ebx
pop ecx
ret
readCounters endp

;-----------------------------------------------------------------------------------
;turn integer to char and adds the char value in strOutput then saves it in the file
;-----------------------------------------------------------------------------------
saveCounters proc

push eax
push ecx
push edx
push ebx
push esi

mov ecx, 10
mov ebx, 0

divide:
xor edx, edx
div ecx
push edx		;it is a digit in range [0..9]
inc ebx	        ;Count it
test eax, eax
jnz divide		;EAX is not zero - so, continue...

; Now POP them all using BX as a counter
mov ecx, ebx
mov esi, OFFSET strOutput


get_digit:
pop edx
add edx, '0'

; Save it in the buffer
mov [esi], dl
inc esi
loop get_digit

mov eax, fileHandle
mov edx,OFFSET strOutput
inc ebx
mov ecx, ebx
mov byte PTR[esi], 0Ah
call WriteToFile

pop eax
pop ecx
pop edx
pop ebx
pop esi

ret
saveCounters endp

;------------------------------------------------------------
;loops the unsolved array to count number of cells unanswerd
;------------------------------------------------------------
numcells proc uses ecx edx eax
mov num_cells_left, 0
mov eax,0
mov ecx,81
mov edx,offset unsolved
L:
mov al,[edx]
cmp al, 32
JNZ cont
inc num_cells_left
cont:
inc edx
loop L
ret
numcells endp

;------------------------------------------------------------------------------------------------------------------------
;stops the time counter and returns the time taken in the numIn_CorrectAns[2] for mins , numIn_CorrectAns[3] for seconds
;------------------------------------------------------------------------------------------------------------------------
calculatetime proc
call GetMseconds ; get stop time
sub eax,startTime ; calculate the elapsed time
mov endTime,eax ; save the elapsed time
mov edx,0
div mstos
mov edx,0
div sectomin
add numIn_CorrectAns +2,al
add numIn_CorrectAns +3,dl
mov edx, 0
mov eax, 0
mov al ,numIn_CorrectAns[3]
div sectomin
add numIn_CorrectAns +2,al
mov numIn_CorrectAns +3,dl 
ret
calculatetime endp

END main