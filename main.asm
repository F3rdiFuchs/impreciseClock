
; PIC16F88 Configuration Bit Settings

; ASM source line config statements

#include "p16F88.inc"

; CONFIG1
; __config 0xFF88
 __CONFIG _CONFIG1, _FOSC_LP & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_ON & _CPD_OFF & _WRT_OFF & _CCPMX_RB0 & _CP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _FCMEN_ON & _IESO_ON

;**************************************************************
; 
w_copy		Equ	0x20		
s_copy		Equ	0x21
m_stat		Equ	0x22
m_round		Equ	0x23
c_roundtime     Equ	0x24
;**************************************************************
;
 ORG     0x00            
 goto    Start
 
;**************************************************************
;Interrupt
 ORG     0x04
 Intvec:
    bcf	INTCON, TMR0IF
    
    movlw  B'00001111'
    movwf TMR0
    
    movwf w_copy	    ; w retten
    swapf STATUS, w	    ; STATUS retten
    bcf	STATUS, RP0	
    movwf s_copy
    
    DECFSZ m_round, 1 ;
    goto Int_end
    goto Tick
    
 Tick:
    BTFSS m_stat,0 
    goto Tick_r
    goto Tick_l
    
Tick_r:

    movlw B'0000010'
    movwf PORTB
    
    movlw B'00111011' ;
    movwf m_round
    
    bsf m_stat,0
    goto Int_end
    
Tick_l:

    movlw B'0000100'
    movwf PORTB
    
    movlw  B'00111011'
    movwf m_round
    
    bcf m_stat,0
    goto Int_end

Int_end:   
    
    swapf	s_copy, w   ; STATUS zurück
    movwf	STATUS 
    swapf	w_copy, f   ; w zurück mit flags
    swapf	w_copy, w
    retfie 
 ;**************************************************************
 ;Hauptprogramm
 Start:
    bsf    STATUS, RP0		; auf Bank 1 umschalten
    movlw  B'00000000'        ; PortB output
    movwf  TRISB
    
    movlw  B'10000100'
    movwf OPTION_REG
    
    movlw  B'00000000'
    movwf m_stat
    
    movlw  B'00111011' ;59
    movwf m_round
     
    bcf    STATUS, RP0    ; auf Bank 0 umschalten
    movlw  B'00000000'
    movwf  PORTB
    
    movlw  B'00001111'
    movwf TMR0

    bsf     INTCON, TMR0IE    ; Timer0 interrupt erlauben
    bsf     INTCON, GIE
    
    goto Loop
    
Loop:
    goto Loop
    
    
    
END