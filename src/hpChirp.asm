;***************************************************************************
;* Dateiname            :"hpChirp.asm"
;* Titel                :1MHz
;* Datum                :08.07.2019
;* Version              :1.0
;* Ziel MCU           	:ATtiny84
;***************************************************************************

.include "tn44Adef.inc"

#define _StandAlone_
;#define _BeepTest_ ; bei jedem WatchDog 1 Beep, bei jeder Messung 2 Beep

;***** Globale Definitionen
.equ	true=0
.equ	false=-1
.equ	cTransferCountMax=16+1
.equ	cMesspufferMax=16
.equ	cChirpCounterMax=40
.equ	cMindestFeuchteCounterMax=8
;.equ	cWatchDogCounterMax=225  ;ca 30Minuten
;.equ	cWatchDogCounterMax=112  ;ca 12Minuten
.equ	cWatchDogCounterMax=48  ;ca 5Minuten
;.equ	cWatchDogCounterMax=6
;define LED_K=PB0
.equ	ledK_Port=PortB
.equ	ledK_Pin=PinB
.equ	ledK_DDR=DDRB
.equ	ledK_Bit=0
;define LED_A PB1
.equ	ledA_Port=PortB
.equ	ledA_Pin=PinB
.equ	ledA_DDR=DDRB
.equ	ledA_Bit=1
;define ClockOut 1MHz on PB2 (OC0A)
.equ	ClockOut_Port=PortB
.equ	ClockOut_Pin=PinB
.equ	ClockOut_DDR=DDRB
.equ	ClockOut_Bit=2
;define SeriellDaten (MISO) on PA5
.equ	SeriellDaten_Port=PortA
.equ	SeriellDaten_Pin=PinA
.equ	SeriellDaten_DDR=DDRA
.equ	SeriellDaten_Bit=5
;define SeriellSelect (MOSI) on PA6
.equ	SeriellSelect_Port=PortA
.equ	SeriellSelect_Pin=PinA
.equ	SeriellSelect_DDR=DDRA
.equ	SeriellSelect_Bit=6
;define SeriellClock (CLK) on PA4
.equ	SeriellClock_Port=PortA
.equ	SeriellClock_Pin=PinA
.equ	SeriellClock_DDR=DDRA
.equ	SeriellClock_Bit=4
;define Speaker on PA7
.equ	Speaker_Port=PortA
.equ	Speaker_Pin=PinA
.equ	Speaker_DDR=DDRA
.equ	Speaker_Bit=7

;***** CPU-Register
;r0 bis r3 in MesspufferSummeBilden verwendet
.def rTransferL=r4
.def rTransferH=r5
.def rMesspufferSummeL=r6
.def rMesspufferSummeH=r7
.def rTransferCounter=r16
.def rMesspufferCounter=r17
.def rWaitCounter=r18
.def rChirpCounter=r19
.def rADCL=r20
.def rADCH=r21
.def rWatchDogCounter=r22
;y als Pointer im Messpuffer verwendet
;z als Pointer im Messpuffer verwendet

;***** 	Data
.dseg
sWatchDogCounter: .Byte 1
sMindestFeuchteCounter: .Byte 1
sFeuchteL: .Byte 1
sFeuchteH: .Byte 1
sMindestFeuchteL: .Byte 1
sMindestFeuchteH: .Byte 1
sMesspufferSummeH: .Byte 1
sMesspufferSummeL: .Byte 1
sMesspufferL: .Byte cMesspufferMax
sMesspufferH: .Byte cMesspufferMax
sMist: .Byte 1

.eseg
eMist: .Byte 1

;***** Macro Definitionen
.macro Ausgang_Clock_Release
	cbi SeriellClock_Port,SeriellClock_Bit
	cbi SeriellClock_DDR,SeriellClock_Bit
.endm

.macro Ausgang_Clock_PullDown
	cbi SeriellClock_Port,SeriellClock_Bit
	sbi SeriellClock_DDR,SeriellClock_Bit
.endm

.macro Ausgang_Daten_Release
	cbi SeriellDaten_Port,SeriellDaten_Bit
	cbi SeriellDaten_DDR,SeriellDaten_Bit
.endm

.macro Ausgang_Daten_PullDown
	cbi SeriellDaten_Port,SeriellDaten_Bit
	sbi SeriellDaten_DDR,SeriellDaten_Bit
.endm

.macro DiddelDaddel
	rcall Beep
	ldi rWaitCounter,100 ;100ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,90 ;90ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,80 ;80ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,70 ;70ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,60 ;60ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,50 ;50ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,40 ;40ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,30 ;30ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,30 ;30ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,40 ;40ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,50 ;50ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,60 ;60ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,70 ;70ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,80 ;80ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,90 ;90ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,100 ;100ms
	rcall WaitXms
.endm

.macro LedEin
	sbi ledA_DDR,ledA_Bit
	sbi ledA_Port,ledA_Bit
	sbi ledK_DDR,ledK_Bit
	cbi ledK_Port,ledK_Bit
.endm

.macro LedAus
	sbi ledA_DDR,ledA_Bit
	cbi ledA_Port,ledA_Bit
	sbi ledK_DDR,ledK_Bit
	cbi ledK_Port,ledK_Bit
.endm

.macro SpeakerInit
	sbi Speaker_DDR,Speaker_Bit
	cbi Speaker_Port,Speaker_Bit
	ldi xl,0
	out TCCR0A, xl
	out TCCR0B, xl
	ldi xl,(1<<COM0B1)|(1<<WGM00)
	out TCCR0A,xl
	ldi xl,(1<<CS00)
	out TCCR0B,xl
.endm

.macro ClockOut_starten
	sbi ClockOut_DDR,ClockOut_Bit
	cbi Speaker_Port,Speaker_Bit
	ldi xl,0
	out OCR0A,xl
	ldi xl,(1<<COM0A0)|(1<<WGM01)
	out TCCR0A,xl
	ldi xl,(1<<CS00)
	out TCCR0B,xl
.endm

.macro Timer0_stoppen
	ldi xl,0
	out TCCR0A,xl
	out TCCR0B,xl
	cbi ClockOut_Port,ClockOut_Bit
	cbi Speaker_Port,Speaker_Bit
.endm

.macro FeuchteMessungSetup
	sbi DIDR0,ADC1D
	ldi xl,(1<<MUX0)
	out ADMUX,xl
	ldi xl,(1<<ADEN)+(1<<ADPS2)+(1<<ADPS0)
	out ADCSRA, xl
.endm

.macro Abchalten_was_nicht_gebraucht_wird
	ldi xl, (1<<PRTIM1)+(1<<PRUSI)
	out PRR, xl
.endm

.macro Wachhund_starten_lang
	ldi xl, (1<<WDCE)+(1<<WDE)
	out WDTCSR, xl
	ldi xl, (1<<WDIE)+(1<<WDP3)+(1<<WDP0) ; 8 Sekunden
	out WDTCSR, xl
.endm

.macro Wachhund_starten_kurz
	ldi xl, (1<<WDCE)+(1<<WDE)
	out WDTCSR, xl
	ldi xl, (1<<WDIE)+(1<<WDP2) ; 0.25 Sekunde
	out WDTCSR, xl
.endm

.macro Schlafen_bis_der_Wachhund_bellt
	Ausgang_Clock_Release
	Ausgang_Daten_Release
	LedAus
	sbi Speaker_DDR,Speaker_Bit
	cbi Speaker_Port,Speaker_Bit
	cbi DDRA,1 ; Messeingang
	sbi DDRB,2 ; ClockOut auf Output und LOW
	cbi PortB,2
	sbi DIDR0,ADC0D
	sbi DIDR0,ADC2D
	sbi DIDR0,ADC3D
	ldi xl,0 ;Ref auf VCC, Messung an an ADC1
	out ADMUX, xl
	ldi xl,0 ;ADC disabled
	out ADCSRA,xl
	ldi xl, (1<<PRTIM1)+(1<<PRTIM0)+(1<<PRUSI)+(1<<PRADC) ;Power Reduction: USI, Timer0 und Timer1 abschalten
	out PRR, xl
	ldi xl, (1<<SE)+(1<<SM1)+(1<<SM0) ;PowerDown einschalten, SleepMode einschalten
	out MCUCR, xl
	sleep
.endm

;***** 	Code
.cseg
.org	$0000 ;Reset
	rjmp isr_Reset
.org	EXT_INT0addr ;External Interrupt Request 0
	reti
.org	PCI0addr ;Pin Change Interrupt Request 0
	reti
.org	PCI1addr ;Pin Change Interrupt Request 1
	reti
.org	WATCHDOGaddr ;Watchdog Time-out
	rjmp isr_WatchDog
.org	ICP1addr ;Timer/Counter1 Capture Event
	reti
.org	OC1Aaddr ;Timer/Counter1 Compare Match A
	reti
.org	OC1Baddr ;Timer/Counter1 Compare Match B
	reti
.org	OVF1addr ;Timer/Counter1 Overflow
	reti
.org	OC0Aaddr ;Timer/Counter0 Compare Match A
	reti
.org	OC0Baddr ;Timer/Counter0 Compare Match B
	reti
.org	OVF0addr ;Timer/Counter0 Overflow
	reti
.org	ACIaddr ;Analog Comparator
	reti
.org	ADCCaddr ;ADC Conversion Complete
	reti
.org	ERDYaddr ;EEPROM Ready
	reti
.org	USI_STRaddr ;USI START
	reti
.org	USI_OVFaddr ;USI Overflow
	reti

.cseg
isr_Reset:
	ldi xh,HIGH(RAMEND)
	out SPH,xh
	ldi xl,LOW(RAMEND)
	out SPL,xl
	ldi xl,0
	out PRR,xl
	ldi xl,0
	sts sFeuchteL,xl
	sts sFeuchteH,xl
	sts sMindestFeuchteL,xl
	sts sMindestFeuchteH,xl
	ldi xl,2
	sts sMindestFeuchteCounter,xl
	ldi rChirpCounter,4
	rcall Beep
	ClockOut_starten
	rcall MesspufferLoeschen
	FeuchteMessungSetup
	ldi rWaitCounter,250 ;250ms
.	rcall WaitXms
	ldi rWaitCounter,250 ;250ms
.	rcall WaitXms
	rcall MindestFeuchteMessen
	Timer0_stoppen
	DiddelDaddel
	ldi rWatchDogCounter,1 ; Nur ein Schlafzyklus
	Wachhund_starten_lang
	sei
	sts sWatchDogCounter,rWatchDogCounter
isr_ResetExit:
	Schlafen_bis_der_Wachhund_bellt
	rjmp isr_ResetExit

isr_WatchDog:
	ldi xh,HIGH(RAMEND)
	out SPH,xh
	ldi xl,LOW(RAMEND)
	out SPL,xl
	wdr
	cli
	ldi xl,0
	out PRR,xl
	ldi xl,(0<<WDRF)
	out MCUSR,xl
	rcall ggfSeriellTransfer
	lds rWatchDogCounter,sWatchDogCounter
	dec rWatchDogCounter
	brne isr_WatchDog1
	ldi rWatchDogCounter,cWatchDogCounterMax
  	#ifdef _BeepTest_
	rcall Beep
	ldi rWaitCounter,50 ;50ms
	rcall WaitXms
	rcall Beep
	ldi rWaitCounter,50 ;50ms
	rcall WaitXms
  	#endif
	ClockOut_starten
	FeuchteMessungSetup
	ldi rWaitCounter,250 ;250ms
	rcall WaitXms
	ldi rWaitCounter,250 ;250ms
	rcall WaitXms
	rcall FeuchteMessen
	sts sFeuchteL,rMesspufferSummeL
	sts sFeuchteH,rMesspufferSummeH
	Timer0_stoppen
	Wachhund_starten_lang
	rcall ggfErdeTrocken
	rjmp isr_WatchDog2
isr_WatchDog1:
  	#ifdef _BeepTest_
	rcall Beep
	#endif
 	Wachhund_starten_lang
isr_WatchDog2:
	sts sWatchDogCounter,rWatchDogCounter
	wdr
	sei
isr_WatchDogExit:
	Schlafen_bis_der_Wachhund_bellt
	rjmp isr_WatchDogExit

MindestFeuchteMessen:
	// Nach Reset Feuchte messen und Schaltschwelle setzen
	ldi xl,20
MindestFeuchteMessen1:
	ldi rWaitCounter,250 ;250ms
.	rcall WaitXms
	ldi rWaitCounter,250 ;250ms
.	rcall WaitXms
	rcall FeuchteMessen
	sts sMindestFeuchteL,rMesspufferSummeL
	sts sMindestFeuchteH,rMesspufferSummeH
	dec xl
	brne MindestFeuchteMessen1
	ret

FeuchteMessen:
	push xl
	push xh
	rcall MesspufferSchieben
	sbi ADCSRA,ADSC
FeuchteMessen1:
	sbic ADCSRA,ADSC
	rjmp FeuchteMessen1
	in rADCL,ADCL
	in rADCH,ADCH ;1ste Messung fuer die Tonne
FeuchteMessen2:
	sbic ADCSRA,ADSC
	rjmp FeuchteMessen2
	in rADCL,ADCL
	in rADCH,ADCH
	ldi xl,LOW(1023)
	ldi xh,HIGH(1023)
	sub xl,rADCL
	sbc xh,rADCH
	sts sMesspufferL+cMesspufferMax-1,xl
	sts sMesspufferH+cMesspufferMax-1,xh
	rcall MesspufferSummeBilden
	pop xh
	pop xl
	ret

ggfErdeTrocken:
	lds xl,sFeuchteL
	lds xh,sFeuchteH
	lds yl,sMindestFeuchteL
	lds yh,sMindestFeuchteH
	cp xl,yl
	cpc xh,yh
	brcc ggfErdeTrockenExit
	rcall Chirp
	ldi rWatchDogCounter,1 ; Nur ein Schlafzyklus
	Wachhund_starten_kurz
ggfErdeTrockenExit:
	ret

ggfSeriellTransfer:
	#ifndef _StandAlone_
	cbi SeriellSelect_DDR,SeriellSelect_Bit
	sbi SeriellSelect_Port,SeriellSelect_Bit ;Eingang Select mit Pullup
	nop
	sbic SeriellSelect_Pin,SeriellSelect_Bit
	rjmp ggfSeriellTransferExit
  	Ausgang_Clock_Release
	Ausgang_Daten_Release
	lds xl,sMindestFeuchteCounter
	dec xl
	brne ggfSeriellTransfer1
	ldi xl,cMindestFeuchteCounterMax
	sts sMindestFeuchteCounter,xl
	lds rTransferH,sMindestFeuchteH
	lds rTransferL,sMindestFeuchteL
	ldi xl,LOW(10000)
	ldi xh,HIGH(10000)
	add rTransferL,xl
	adc rTransferH,xh
	rcall SeriellTransfer
	rjmp ggfSeriellTransferExit
ggfSeriellTransfer1:
	sts sMindestFeuchteCounter,xl
	lds rTransferH,sFeuchteH
	lds rTransferL,sFeuchteL
	rcall SeriellTransfer
	#endif
ggfSeriellTransferExit:
	ret

SeriellTransfer:
	ldi rTransferCounter,cTransferCountMax
SeriellTransfer1:
;	sbic SeriellSelect_Pin,SeriellSelect_Bit
;	rjmp SeriellTransferExit
SeriellTransfer1a:
	dec rTransferCounter
	breq SeriellTransferExit
	LedEin
	lsl rTransferL
	rol rTransferH
	brcc SeriellTransfer2
	Ausgang_Daten_Release
	rjmp SeriellTransfer3
SeriellTransfer2:
	Ausgang_Daten_PullDown
SeriellTransfer3:
  	Ausgang_Clock_PullDown
rcall Wait100
  	Ausgang_Clock_Release
	Ausgang_Daten_Release
	rcall Wait100
	rjmp SeriellTransfer1a
SeriellTransferExit:
  	Ausgang_Clock_Release
	Ausgang_Daten_Release
	LedAus
	ret

Beep:
	push xl
	SpeakerInit
	ldi xl,48
	out OCR0B,xl
	ldi rWaitCounter,40 ;40ms
	rcall WaitXms
	Timer0_stoppen
	pop xl
	ret

Chirp:
	dec rChirpCounter
	brne ChirpExit
	ldi rChirpCounter,cChirpCounterMax
	ldi xl,7
Chirp1:
	rcall Beep
	ldi rWaitCounter,40 ;40ms
	rcall WaitXms
	dec xl
	brne Chirp1
ChirpExit:
	ret

MesspufferLoeschen:
	ldi yh,high(sMesspufferL)
	ldi yl,low(sMesspufferL)
	clr r0
	ldi rMesspufferCounter, cMesspufferMax
MesspufferLoeschenA:
	st y+,r0
	dec rMesspufferCounter
	brne MesspufferLoeschenA
	ldi yh,high(sMesspufferH)
	ldi yl,low(sMesspufferH)
	clr r0
	ldi rMesspufferCounter, cMesspufferMax
MesspufferLoeschenB:
	st y+,r0
	dec rMesspufferCounter
	brne MesspufferLoeschenB
	ret

MesspufferSummeBilden:
	ldi yh,high(sMesspufferL)
	ldi yl,low(sMesspufferL)
	ldi zh,high(sMesspufferH)
	ldi zl,low(sMesspufferH)
	clr r2
	clr r3
	ldi rMesspufferCounter,cMesspufferMax
MesspufferSummeBildenA:
	ld r0,y+
	ld r1,z+
	add r2,r0
	adc r3,r1
	dec rMesspufferCounter
	brne MesspufferSummeBildenA
	lsr r3
	ror r2
	lsr r3
	ror r2
	lsr r3
	ror r2
	lsr r3
	ror r2
	mov rMesspufferSummeL,r2
	mov rMesspufferSummeH,r3
	ret

MesspufferSchieben:
	ldi zh,high(sMesspufferL+1)
	ldi zl,low(sMesspufferL+1)
	ldi yh,high(sMesspufferL)
	ldi yl,low(sMesspufferL)
	ldi rMesspufferCounter,cMesspufferMax-1
MesspufferSchiebenA:
	ld r0,z+
	st y+,r0
	dec rMesspufferCounter
	brne MesspufferSchiebenA
	ldi zh,high(sMesspufferH+1)
	ldi zl,low(sMesspufferH+1)
	ldi yh,high(sMesspufferH)
	ldi yl,low(sMesspufferH)
	ldi rMesspufferCounter,cMesspufferMax-1
MesspufferSchiebenB:
	ld r0,z+
	st y+,r0
	dec rMesspufferCounter
	brne MesspufferSchiebenB
	ret

Wait100:
	;100micros Verzoegerungsschleife bei 1MHz Takt
	push rWaitCounter
	nop
	ldi rWaitCounter,$16
Wait100A:
	nop
	dec rWaitCounter
	brne Wait100A
	pop rWaitCounter
	ret

Wait1ms:
	push rWaitCounter
	wdr
	ldi rWaitCounter,$C6 ;$C6 bei 1MHz, $17 bei 128kHz
Wait1ms1:
	wdr
	nop
	dec rWaitCounter
	brne Wait1ms1
	pop rWaitCounter
	ret

WaitXms:
	rcall Wait1ms
	dec rWaitCounter
	brne WaitXms
	ret
