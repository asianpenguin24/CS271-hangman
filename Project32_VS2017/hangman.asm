;Author: Jeremy Udarbe & Hannah Armstrong
;Date Due: 3/9/2020
;Course/ProjectID: CS-271	Group Project
;Description: hangman.asm - user plays hangman

INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

;Hannah TODO: block commenting, intro, outro, and play again operation



.data
	;ASCII art
	
	lives5		BYTE	"+------+       ",10,"|      |       ",10,"|              ",10,"|              ",10,"|              ",10,"|              ",10,"+------------+",0

	lives4		BYTE	"+------+       ",10,"|      |       ",10,"|      O       ",10,"|              ",10,"|              ",10,"|              ",10,"+------------+",0
	
	lives3		BYTE	"+------+       ",10,"|      |       ",10,"|      O       ",10,"|     /|       ",10,"|              ",10,"|              ",10,"+------------+",0
		
	lives2		BYTE	"+------+       ",10,"|      |       ",10,"|      O       ",10,"|     /|\      ",10,"|              ",10,"|              ",10,"+------------+",0
			
	lives1		BYTE	"+------+       ",10,"|      |       ",10,"|      O       ",10,"|     /|\      ",10,"|     /        ",10,"|              ",10,"+------------+",0

	lives0		BYTE	"+------+       ",10,"|      |       ",10,"|      O       ",10,"|     /|\      ",10,"|     / \      ",10,"|              ",10,"+------------+",0

	lives		DWORD	OFFSET LIVES0, OFFSET LIVES1, OFFSET LIVES2, OFFSET LIVES3, OFFSET LIVES4, OFFSET LIVES5


	;intro
	intro1		BYTE	"WELCOME TO HANGMAN!",0

	;outro
	outro1		BYTE	"THANKS FOR PLAYING!",0

	;gamestate
	gewinnen	BYTE	"You win hangman!",0		;I ran out of words so I started using German
	verloren	BYTE	"You killed him!",0
	livesleft	BYTE	"LIVES REMAINING: ",0
	letused		BYTE	"Letters used: ",0

	;constants
	word1		BYTE	"stack",0		;4
	word2		BYTE	"string",0		;3
	word3		BYTE	"integer",0		;2
	word4		BYTE	"float",0		;1
	word5		BYTE	"boolean",0		;0
	space		DWORD	'-'


	;dynamics
	winstate	DWORD	?
	matches		DWORD	?
	numlives	DWORD	?
	gameword	DWORD	?
	wordlength	DWORD	?
	numround	DWORD	?
	usedchars	BYTE	100	DUP(0)
	wordlist	BYTE	5	DUP(0)
	spacelist	BYTE	10	DUP(0)


.code
main PROC
	;Seed random number generator
	call	Randomize
	playagain:
	;------------------------------move words into an array of words
	push	OFFSET		wordlist	;28
	push	OFFSET		word1		;24
	push	OFFSET		word2		;20
	push	OFFSET		word3		;16
	push	OFFSET		word4		;12
	push	OFFSET		word5		;8
	call	fillwords

	;------------------------------generate random integer which selects index of array, moves the chosen word into variable gameword
	push	OFFSET		wordlist	;12
	push	OFFSET		gameword	;8
	call	getword

	;------------------------------gets length of word
	push	OFFSET		wordlength	;12
	push	gameword				;8
	call	getlength

	;------------------------------fill array with spaces according to length of word chosen
	push	OFFSET		spacelist	;12
	push	wordlength				;8
	call	fillspaces
	
	;------------------------------gameplay: for loop with limit 5, compare input char with word array
	push	OFFSET		letused		;20
	push	OFFSET		livesleft	;16
	push	OFFSET		gewinnen	;12
	push	OFFSET		verloren	;8
	call	gameplay

invoke ExitProcess,0			;exit to operating system
main ENDP

;**********************************
;Description:
;Receives:
;Returns:
;Preconditions:
;Registers changed:
;**********************************
;introduction PROC
;	;push address of ebp and mov contents of stack
;	push	ebp
;	mov		ebp, esp
;	
;	pop		ebp
;	ret		;space used
;introduction ENDP

;generate array
fillwords	PROC
push	ebp
mov		ebp, esp

mov		edi, [ebp+28]

mov		edx, [ebp+8]
mov		[edi], edx
add		edi, 4

mov		edx, [ebp+12]
mov		[edi], edx
add		edi, 4

mov		edx, [ebp+16]
mov		[edi], edx
add		edi, 4

mov		edx, [ebp+20]
mov		[edi], edx
add		edi, 4

mov		edx, [ebp+24]
mov		[edi], edx
add		edi, 4

pop		ebp
ret		24
fillwords	ENDP

;get word used for game from word array
getword		PROC
push	ebp
mov		ebp, esp

mov		edi, [ebp+12]	;array of words
mov		eax, 5
call	RandomRange
mov		ebx, 4
mul		ebx
add		edi, eax
mov		edx, [edi]
mov		esi, [ebp+8]	;chosen word
mov		[esi], edx		;move the string into ebx

call	WriteString		;----------------------------------------------------temp debug
call	crlf

pop		ebp
ret		8
getword		ENDP

;count number of characters in a string
getlength	PROC
push	ebp
mov		ebp, esp

mov		edi, [ebp+8]
mov		edx, edi

mov		eax, 0
loopstring:				;loop through string incrementing eax and next char until null char
mov		dl, [edi]
cmp		dl, 0
je		endstring
add		edi, 1
add		eax, 1
jmp	loopstring

endstring:
mov		ebx, [ebp+12]
mov		[ebx], eax
pop		ebp
ret		8
getlength ENDP

;move spaces into array for user to guess
fillspaces	PROC
push	ebp
mov		ebp, esp

mov		edi, [ebp+12]		;array of spaces
mov		dl, 45		;space
mov		ecx, [ebp+8]		;wordlengh

fillarray2:
mov		[edi], dl
add		edi, 1
loop	fillarray2

mov		dl, 0
mov		[edi], dl

pop		ebp
ret		12
fillspaces	ENDP

;user actually plays game
gameplay	PROC
push	ebp
mov		ebp, esp

;------------------------------initialize lives and round number
mov		numlives, 5
mov		numround, 1
mov		winstate, 0

gameloop:
;------------------------------print lives left
mov		edx, [ebp+16]
call	writestring
mov		eax, numlives
call	writedec
call	crlf
;------------------------------print hangman corresponding to lives left
push	numlives			;8
call	printman
;------------------------------print word progress
push	OFFSET	spacelist	;12
push	wordlength			;8
call	printprog
;------------------------------gamestate
cmp		numlives, 0
je		lose
;------------------------------gamestate check if progress string has no dashes
push	OFFSET	spacelist	;16
push	wordlength			;12
push	winstate			;8
call	checkwin
cmp		winstate, 1
je		win
;------------------------------print used letters
mov		edx, [ebp+20]
call	writestring
push	OFFSET	usedchars	;12
push	numround			;8
call	printused
;------------------------------get user character input
push	numlives			;28
push	numround			;24
push	gameword			;20
push	wordlength			;16
push	OFFSET	usedchars	;12
push	OFFSET	spacelist	;8
call	userinput
;------------------------------loop new round
add		numround, 1
call	clrscr
jmp		gameloop

lose:
	mov		edx, [ebp+8]
	call	writestring
	call	crlf
	jmp		endgame
win:
	mov		edx, [ebp+12]
	call	writestring
	call	crlf
	jmp		endgame
endgame:
pop		ebp
ret		16
gameplay	ENDP

;prints the hangman ascii art according to lives left
printman	PROC
push	ebp
mov		ebp, esp

mov		eax, [ebp+8]
mov		ebx, OFFSET lives
mov		ecx, 4
mul		ecx
add		eax, ebx
mov		edx, [eax]
call	WriteString
call	crlf
call	crlf

pop		ebp
ret		4
printman	ENDP

;prints the progress/letters filled
printprog	PROC
push	ebp
mov		ebp, esp

mov		edi, [ebp+12]	;string (array of chars)
mov		ecx, [ebp+8]	;word length
progress:
mov		al, [edi]
call	WriteChar
mov		al, 32
call	WriteChar
add		edi, 1
loop progress
call	crlf
call	crlf

pop		ebp
ret		8
printprog	ENDP

;prints used letters into string
printused	PROC
push	ebp
mov		ebp, esp
mov		edi, [ebp+12]	;usedletters
mov		ecx, [ebp+8]	;roundnum
usedloop:
mov		al, [edi]
call	writechar
mov		al, 32
call	writechar
add		edi, 1
loop usedloop

pop		ebp
ret		8
printused	ENDP

;does a lot of stuff
userinput	PROC
push	ebp
mov		ebp, esp
mov		esi, [ebp+12]	;array used chars
mov		edi, [ebp+20]	;gameword
mov		ecx, [ebp+16]	;wordlength
mov		eax, [ebp+24]	;round number
add		esi, eax
call	readchar		;user input stored in al
mov		bl, al
mov		[esi], bl	;move the input char into an array of used input chars
mov		esi, [ebp+8]	;progress string/array of chars
add		esi, ecx
mov		matches, 0
compareinput:
	mov		al, [edi]
	cmp		bl, al
	je		charmatch
	jmp		endcomp
	charmatch:
		add		matches, 1
		sub		esi, ecx
		mov		[esi], bl		;replaces the matched char into progress string
		add		esi, ecx		;this does a fucky wucky for some reason
	endcomp:
	add		edi, 1
	loop	compareinput
cmp		matches, 0			;if no matches found, reduce life
jne		playerclear
sub		numlives, 1
playerclear:
pop		ebp
ret		24
userinput	ENDP

checkwin	PROC
push	ebp
mov		ebp, esp
mov		edi, [ebp+16]	;progress string
mov		ecx, [ebp+12]	;word length
checkdash:
mov		al, [edi]
mov		bl, 45
cmp		al, bl
je		continue
add		edi, 1
loop	checkdash
mov		winstate, 1
continue:
pop		ebp
ret		12
checkwin	ENDP

END main


