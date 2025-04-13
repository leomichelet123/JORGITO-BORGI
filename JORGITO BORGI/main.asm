.dseg
.org 0x100
salto_contador:				.byte 1  ; Variable para contar las interrupciones del Timer.
salto_indi_CO:				.byte 1
salto_indi_temp:			.byte 1
salto_indi_gases:			.byte 1
salto_indi_humedad:			.byte 1
salto_indi_:				.byte 1
INDICADOR_CO:				.byte 1
INDICADOR_TEMP:				.byte 1
INDICADOR_GASES:			.byte 1
INDICADOR_HUMEDAD:			.byte 1
INDICADOR_PARTICULAS:		.byte 1
ALARMA_CO:					.byte 1
AVISO_CO:					.byte 1
AVISO_BAJA_TEMP:				.byte 1
ALARMA_BAJA_TEMP:			.byte 1
ALARMA_TEMP:					.byte 1
AVISO_TEMP:					.byte 1
ALARMA_GASES:				.byte 1
AVISO_GASES:					.byte 1
ALARMA_HUMEDAD:				.byte 1
AVISO_HUMEDAD:				.byte 1
ALARMA_PARTICULAS:			.byte 1
AVISO_PARTICULAS:			.byte 1
CAMBIA_UMBRALES:			.byte 1
dato_recibido: 				.byte 1
dataRx: 					.byte 1
NUMERORECIBIDO:			.byte 1
.cseg

.ORG	 0x0000
JMP	INICIO

.ORG 0x0018
JMP ISR_TIMER1_COMPB

.ORG 0x0024


; Tabla de clasificaci�n de caracteres
char_table:
    .DB 0, 0, 0, 0, 0, 0, 0, 0 ; Caracteres no v�lidos (0-7)
    .DB 0, 0, 0, 0, 0, 0, 0, 0 ; Caracteres no v�lidos (8-15)
    .DB 0, 0, 0, 0, 0, 0, 0, 0 ; Caracteres no v�lidos (16-23)
    .DB 0, 0, 0, 0, 0, 0, 0, 0 ; Caracteres no v�lidos (24-31)
    .DB 0, 0, 0, 0, 0, 0, 0, 0 ; Espacios y s�mbolos (32-39)
    .DB 1, 1, 1, 1, 1, 1, 1, 1 ; N�meros (48-55)
    .DB 1, 1, 0, 0, 0, 0, 0, 0 ; N�meros (56-63) y otros
    .DB 2, 2, 2, 2, 2, 2, 2, 2 ; Letras may�sculas (65-71)
    .DB 2, 2, 2, 2, 2, 2, 2, 2 ; Letras may�sculas (72-79)
    .DB 2, 2, 2, 2, 2, 2, 2, 2 ; Letras may�sculas (80-87)
    .DB 2, 2, 2, 0, 0, 0, 0, 0 ; Letras may�sculas (88-95) y otros
    .DB 3, 3, 3, 3, 3, 3, 3, 3 ; Letras min�sculas (97-103)
    .DB 3, 3, 3, 3, 3, 3, 3, 3 ; Letras min�sculas (104-111)
    .DB 3, 3, 3, 3, 3, 3, 3, 3 ; Letras min�sculas (112-119)
    .DB 3, 3, 3, 0, 0, 0, 0, 0 ; Letras min�sculas (120-127) y otros
INICIO:

LDS R16, dato_recibido
CPI R16, 0
BREQ VOLVER ; Si no hay dato recibido, espera

LDI R16, 0              ; Inicializar dato_recibido a 0
STS dato_recibido, R16
LDI	R16, HIGH(RAMEND)
OUT	SPH,R16
LDI 	R16, LOW(RAMEND)
OUT	SPL,R16

LDI	R16,0
STS	UCSR0A,R16
LDI	R16,(1<<RXCIE0)|(1<<RXEN0)|(1<<TXEN0)
STS	UCSR0B,R16
LDI	R16,(1<<UCSZ01)|(1<<UCSZ00)
STS	UCSR0C,R16
LDI	R16,103
STS	UBRR0L,R16
LDI	R16,0
STS	UBRR0H,R16
	LDI R22, 204				; Umbral de Alarma CO, 4 VOLT
	STS ALARMA_CO, R22
	LDI R23, 153				; Umbral de Aviso CO, 3 VOLT
	STS AVISO_CO, R23
	LDI R24, 153				; Umbral de Alarma Temperatura en 35 C, 3.0 VOLT
	LDI R16, 21					;Umbral de aviso para baja temperatura, 0.4V
	STS AVISO_BAJA_TEMP,R16
	LDI R17, 15             ;Alarma de baja temperatura 0.3V
	STS ALARMA_BAJA_TEMP,R17 
	STS ALARMA_TEMP, R24
	LDI R25, 153				; Umbral de Aviso Temperatura en 30 C, 3 VOLT
	STS AVISO_TEMP, R25
	LDI R26, 0				; Umbral de Alarma Gases Inflamables
	STS ALARMA_GASES, R26
	LDI R27, 0				; Umbral de Aviso Gases Inflamables
	STS AVISO_GASES, R27
	LDI R28, 87				; Umbral de Alarma Humedad AL 60%,1.7 VOLT
	STS ALARMA_HUMEDAD, R28
	LDI R29, 77				; Umbral de Aviso Humedad AL 50%, 1.5 VOLT
	STS AVISO_HUMEDAD, R29
	LDI R30, 51				; Umbral de Alarma Part?culas, 1 VOLT
	STS ALARMA_PARTICULAS, R30
	LDI R31, 36				; Umbral de Aviso Part?culas, 0.7 VOLT 
	STS AVISO_PARTICULAS, R31 
	LDI    R16,HIGH(RAMEND)
    OUT    SPH,R16
    LDI    R16,LOW(RAMEND)
    OUT    SPL,R16
	;CONFIGURACION ADC
	LDI R16,(1<<DDB0)|(1<<DDB1)|(1<<DDB2)|(1<<DDB3)|(1<<DDB4)|(1<<DDB5)
	OUT DDRB,R16
	LDI	R16,(1<<REFS0)|(1<<ADLAR)
	STS	ADMUX,R16
	LDI R16,(1<<ADEN)|(0<<ADIE)|(0<<ADATE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADSC)
	STS	ADCSRA,R16
	LDI	R16,(1<<ADTS0)|(1<<ADTS2)
	STS	ADCSRB,R16
	LDI	R16,(1<<ADC0D)|(1<<ADC1D)|(1<<ADC2D)|(1<<ADC3D)|(1<<ADC4D)
	STS	DIDR0,R16
	;FIN CONFIGURACION ADC
	;Configuracion como transmisor y receptor
	LDI    R16, (1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0) 
    STS    UCSR0B,R16
	LDI    R16,(1<<UCSZ01)|(1<<UCSZ00) 
    STS    UCSR0C,R16
	; Configuraci?n del baud rate del USART (9600 baud con un reloj de 16 MHz)
	LDI    R16,103
	STS    UBRR0L, R16
	LDI    R16,0
	STS    UBRR0H, R16

    CALL INIT_TIMER
SEI


VOLVER:

    ; Leer la letra recibida en dato_recibido
    LDS R16, dato_recibido ; Cargar la letra recibida en R16

   
    CPI R16,65          ; Comparar con 'A' (Enviar Alarma de CO)
    BREQ ENVIAR_ALARMA_CO

    CPI R16,66           ; Comparar con 'B' (Enviar Alarma de Temperatura)
    BREQ ENVIAR_ALARMA_TEMP

    CPI R16,69           ; Comparar con 'E' (Enviar Alarma de Gases)
    BREQ ENVIAR_ALARMA_GASES

    CPI R16,70           ; Comparar con 'F' (Enviar Alarma de Humedad)
    BREQ ENVIAR_ALARMA_HUMEDAD

    CPI R16,81           ; Comparar con 'Q' (Enviar Alarma de Part�culas)
    BREQ ENVIAR_ALARMA_PARTICULAS

    RJMP SALTO_LINEA           ; Si no coincide con ninguna letra, seguir en el loop

	; Subrutinas para enviar los valores de las alarmas
ENVIAR_ALARMA_CO:
    LDI ZH, HIGH(2*frase0) ; Cargar la direcci�n de la frase "ALARMA DE CO"
    LDI ZL, LOW(2*frase0)
    LDI R17, 26            ; Longitud de la frase
    CALL strings           ; Enviar la frase
    LDS R24, ALARMA_CO     ; Cargar el valor de la alarma de CO
    CALL DESARMAR_ENVIAR   ; Enviar el valor
	CLR R16                ; Limpiar R16
	STS dato_recibido, R16 ; Limpiar dato_recibido
    RJMP SALTO_LINEA

ENVIAR_ALARMA_TEMP:
    LDI ZH, HIGH(2*frase1) ; Cargar la direcci�n de la frase "ALARMA DE TEMPERATURA"
    LDI ZL, LOW(2*frase1)
    LDI R17, 35            ; Longitud de la frase
    CALL strings           ; Enviar la frase
    LDS R24, ALARMA_TEMP   ; Cargar el valor de la alarma de Temperatura
    CALL DESARMAR_ENVIAR   ; Enviar el valor
	CLR R16                ; Limpiar R16
	STS dato_recibido, R16 ; Limpiar dato_recibido
    RJMP SALTO_LINEA

ENVIAR_ALARMA_GASES:
    LDI ZH, HIGH(2*frase2) ; Cargar la direcci�n de la frase "ALARMA DE GASES"
    LDI ZL, LOW(2*frase2)
    LDI R17, 32            ; Longitud de la frase
    CALL strings           ; Enviar la frase
    LDS R24, ALARMA_GASES  ; Cargar el valor de la alarma de Gases
    CALL DESARMAR_ENVIAR   ; Enviar el valor
	CLR R16                ; Limpiar R16
	STS dato_recibido, R16 ; Limpiar dato_recibido
    RJMP SALTO_LINEA

ENVIAR_ALARMA_HUMEDAD:
    LDI ZH, HIGH(2*frase3) ; Cargar la direcci�n de la frase "ALARMA DE HUMEDAD"
    LDI ZL, LOW(2*frase3)
    LDI R17, 34            ; Longitud de la frase
    CALL strings           ; Enviar la frase
    LDS R24, ALARMA_HUMEDAD ; Cargar el valor de la alarma de Humedad
    CALL DESARMAR_ENVIAR   ; Enviar el valor
	CLR R16                ; Limpiar R16
	STS dato_recibido, R16 ; Limpiar dato_recibido
    RJMP SALTO_LINEA

ENVIAR_ALARMA_PARTICULAS:
    LDI ZH, HIGH(2*frase4) ; Cargar la direcci�n de la frase "ALARMA DE PARTICULAS"
    LDI ZL, LOW(2*frase4)
    LDI R17, 38            ; Longitud de la frase
    CALL strings           ; Enviar la frase
    LDS R24, ALARMA_PARTICULAS ; Cargar el valor de la alarma de Part�culas
    CALL DESARMAR_ENVIAR   ; Enviar el valor
	CLR R16                ; Limpiar R16
	STS dato_recibido, R16 ; Limpiar dato_recibido

	SALTO_LINEA:

	 ; Verificar qu� letra se recibi� y enviar el valor correspondiente
    CPI R16,88           ; Comparar con 'X' (Enviar Umbral de CO)
    BREQ ENVIAR_UMBRAL_CO

    CPI R16,89           ; Comparar con 'Y' (Enviar Umbral de Temperatura)
    BREQ ENVIAR_UMBRAL_TEMP

    CPI R16,90           ; Comparar con 'Z' (Enviar Umbral de Gases)
    BREQ ENVIAR_UMBRAL_GASES

    CPI R16,87           ; Comparar con 'W' (Enviar Umbral de Humedad)
    BREQ ENVIAR_UMBRAL_HUMEDAD

    CPI R16,86         ; Comparar con 'V' (Enviar Umbral de Part�culas)
    BREQ ENVIAR_UMBRAL_PARTICULAS

    CLR R16
    STS dato_recibido, R16
	RJMP VOLVER

; Subrutinas para enviar los valores de los umbrales
ENVIAR_UMBRAL_CO:
    LDI ZH, HIGH(2*frase7) ; Cargar la direcci�n de la frase "UMBRAL DE AVISO DE CO"
    LDI ZL, LOW(2*frase7)
    LDI R17, 30            ; Longitud de la frase
    CALL strings           ; Enviar la frase
    LDS R24, AVISO_CO      ; Cargar el valor del umbral de aviso de CO
    CALL DESARMAR_ENVIAR   ; Enviar el valor
	CLR R16                ; Limpiar R16
	STS dato_recibido, R16 ; Limpiar dato_recibido
    RJMP VOLVER

ENVIAR_UMBRAL_TEMP:
    LDI ZH, HIGH(2*frase8) ; Cargar la direcci�n de la frase "UMBRAL DE AVISO DE TEMPERATURA"
    LDI ZL, LOW(2*frase8)
    LDI R17, 35            ; Longitud de la frase
    CALL strings           ; Enviar la frase
    LDS R24, AVISO_TEMP    ; Cargar el valor del umbral de aviso de Temperatura
    CALL DESARMAR_ENVIAR   ; Enviar el valor
	CLR R16                ; Limpiar R16
	STS dato_recibido, R16 ; Limpiar dato_recibido
    RJMP VOLVER

ENVIAR_UMBRAL_GASES:
    LDI ZH, HIGH(2*frase9) ; Cargar la direcci�n de la frase "UMBRAL DE AVISO DE GASES"
    LDI ZL, LOW(2*frase9)
    LDI R17, 32            ; Longitud de la frase
    CALL strings           ; Enviar la frase
    LDS R24, AVISO_GASES   ; Cargar el valor del umbral de aviso de Gases
    CALL DESARMAR_ENVIAR   ; Enviar el valor
	CLR R16                ; Limpiar R16
	STS dato_recibido, R16 ; Limpiar dato_recibido
    RJMP VOLVER

ENVIAR_UMBRAL_HUMEDAD:
    LDI ZH, HIGH(2*frase10) ; Cargar la direcci�n de la frase "UMBRAL DE AVISO DE HUMEDAD"
    LDI ZL, LOW(2*frase10)
    LDI R17, 33            ; Longitud de la frase
    CALL strings           ; Enviar la frase
    LDS R24, AVISO_HUMEDAD ; Cargar el valor del umbral de aviso de Humedad
    CALL DESARMAR_ENVIAR   ; Enviar el valor
	CLR R16                ; Limpiar R16
	STS dato_recibido, R16 ; Limpiar dato_recibido
    RJMP VOLVER

ENVIAR_UMBRAL_PARTICULAS:
    LDI ZH, HIGH(2*frase11) ; Cargar la direcci�n de la frase "UMBRAL DE AVISO DE PARTICULAS"
    LDI ZL, LOW(2*frase11)
    LDI R17, 33            ; Longitud de la frase
    CALL strings           ; Enviar la frase
    LDS R24, AVISO_PARTICULAS ; Cargar el valor del umbral de aviso de Part�culas
    CALL DESARMAR_ENVIAR   ; Enviar el valor
	CLR R16                ; Limpiar R16
	STS dato_recibido, R16 ; Limpiar dato_recibido

RJMP	VOLVER

CONVERTIR_ASCII_A_NUM:
CPI R16, '0'
BRLO ERROR_NUMERO
CPI R16, '9' + 1
BRGE ERROR_NUMERO
LDI R25, 48
SUB R16, R25
RET
ERROR_NUMERO:
    CLR R16
    RET
ISR_TIMER1_COMPB:

	PUSH	R28
	PUSH	R29
	PUSH	R16
	PUSH	R17
	IN		R17,SREG
	PUSH	R17
	
								 ;Comparacion para saber en que indicador guardar

	LDS     R16, ADMUX           ; Leer el valor actual de ADMUX en R16
	ANDI    R16, 0x0f            
					
 


	CPI     R16, 0            ; Comparar el valor con 0
	BREQ    salto_indicador_CO           ; Si es 0, saltar a Store_CO
	CPI     R16, 1             ; Comparar el valor con 1
	BREQ    salto_indicador_temp         ; Si es 1, saltar a Store_temp
	CPI     R16, 2             ; Comparar el valor con 2
	BREQ    salto_indicador_gases        ; Si es 2, saltar a Store_gases
	CPI     R16, 3             ; Comparar el valor con 3
	BREQ    salto_indicador_humedad      ; Si es 3, saltar a Store_humedad
	CPI     R16, 4             ; Comparar el valor con 4
	BREQ    salto_indicador_particulas    ; Si es 4, saltar a Store_particulas
	CLR		R16
	RJMP    CAMBIO_canal



salto_indicador_CO:
	LDS		R29, ADCH
	
    STS     INDICADOR_CO, R29
    SBI     PINB,PINB0            
    SBI		PINB,PINB5
    JMP		Incrementar_ADMUX

salto_indicador_temp:
	LDS R29, ADCH     ; Leer parte alta del valor de conversi?n
	
    STS     INDICADOR_TEMP, R29
    SBI     PINB,PINB1           
    SBI		PINB,PINB5 
    JMP		Incrementar_ADMUX

salto_indicador_gases:
	LDS		R29, ADCH     ; Leer parte alta del valor de conversi?n
	
    STS     INDICADOR_GASES, R29
    SBI     PINB,PINB2            
    SBI		PINB,PINB5
    JMP		Incrementar_ADMUX

salto_indicador_humedad:
	LDS		R29, ADCH     ; Leer parte alta del valor de conversi?n
	
    STS     INDICADOR_HUMEDAD, R29
	SBI     PINB,PINB3            
    SBI		PINB,PINB5
	JMP		Incrementar_ADMUX
    

salto_indicador_particulas:
	LDS		R29, ADCH
	
    STS     INDICADOR_PARTICULAS, R29
    SBI     PINB,PINB4           
    SBI		PINB,PINB5
	LDI     R16, 0             ; Si llegamos a ADC4, volver a ADC0
    JMP CAMBIO_canal

Incrementar_ADMUX:
    INC     R16                 ; Incrementar el canal

	
CAMBIO_Canal:
							 ; Mantener los dem?s bits de ADMUX (referencia de voltaje, ADLAR) y actualizar solo los bits del canal
LDS     R17, ADMUX           ; Cargar el valor actual de ADMUX en un registro temporal
ANDI    R17, 0xF0            ; Mantener los bits de referencia y ADLAR (los bits 7-4)
OR      R17, R16             ; Combinar los bits altos de ADMUX con el nuevo canal (ADC1-ADC4)
STS     ADMUX, R17           ; Guardar el nuevo valor?de?ADMUX

FIN:

LDI R16,(1<<ADEN)|(0<<ADIE)|(0<<ADATE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADSC)
	STS	ADCSRA,R16

	POP     R17 
	OUT		SREG,R17
	POP		R17
	POP		R16
	POP		R29
	POP		R28
	
RETI
	 
ISR_RX:
    PUSH R17
    LDS R17, UDR0 ; Cargar el dato recibido en R17


     CPI R17, 32
    BRLO OTRO_CARACTER
    CPI R17, 128
    BRGE OTRO_CARACTER
    ; Clasificar el car�cter usando la tabla
    LDI ZH, HIGH(char_table)
    LDI ZL, LOW(char_table)
    ADD ZL, R17 ; Ajustar el �ndice
    LPM R18, Z  ; Cargar el valor de la tabla en R18

    ; Clasificar seg�n el valor de la tabla
    CPI R18, 1
    BREQ ES_NUMERO
    CPI R18, 2
    BREQ ES_MAYUSCULA
    CPI R18, 3
    BREQ ES_MINUSCULA
    RJMP OTRO_CARACTER

ES_NUMERO:
    ; Convertir el car�cter num�rico a un valor entero
    CALL CONVERTIR_ASCII_A_NUM
    STS NUMERORECIBIDO, R16 ; Guardar el n�mero recibido
    ; Enviar mensaje "ES NUMERO"
    LDI ZH, HIGH(2*frase12)
    LDI ZL, LOW(2*frase12)
    LDI R17, 13
    CALL strings
    CALL DESARMAR_ENVIAR
    RJMP GUARDAR_NUMERO

ES_MAYUSCULA:
    ; Comparar con letras espec�ficas
    CPI R17, 'C'
    BREQ GUARDAR_UMBRAL_CO
    CPI R17, 'T'
    BREQ GUARDAR_UMBRAL_TEMP
    CPI R17, 'G'
    BREQ GUARDAR_UMBRAL_GASES
    CPI R17, 'H'
    BREQ GUARDAR_UMBRAL_HUMEDAD
    CPI R17, 'P'
    BREQ GUARDAR_UMBRAL_PARTICULAS
    ; Enviar mensaje "ES MAYUSCULA"
    LDI ZH, HIGH(2*frase13)
    LDI ZL, LOW(2*frase13)
    LDI R17, 16
    CALL strings
    RJMP FIN_ISR

ES_MINUSCULA:
    ; Enviar mensaje "ES MINUSCULA"
    LDI ZH, HIGH(2*frase14)
    LDI ZL, LOW(2*frase14)
    LDI R17, 16
    CALL strings
    RJMP FIN_ISR

OTRO_CARACTER:
    ; Enviar mensaje "CARACTER DESCONOCIDO"
    LDI ZH, HIGH(2*frase15)
    LDI ZL, LOW(2*frase15)
    LDI R17, 4
    CALL strings
    RJMP FIN_ISR

FIN_ISR:
    POP R17
    RETI

; Subrutinas para guardar umbrales
GUARDAR_UMBRAL_CO:
    LDS R24, GUARDAR_NUMERO
    STS AVISO_CO, R24
    RJMP FIN_ISR

GUARDAR_UMBRAL_TEMP:
    LDS R24, GUARDAR_NUMERO
    STS AVISO_TEMP, R24
    RJMP FIN_ISR

GUARDAR_UMBRAL_GASES:
    LDS R24, GUARDAR_NUMERO
    STS AVISO_GASES, R24
    RJMP FIN_ISR

GUARDAR_UMBRAL_HUMEDAD:
    LDS R24, GUARDAR_NUMERO
    STS AVISO_HUMEDAD, R24
    RJMP FIN_ISR

GUARDAR_UMBRAL_PARTICULAS:
    LDS R24, GUARDAR_NUMERO
    STS AVISO_PARTICULAS, R24
    RJMP FIN_ISR
    

GUARDAR_NUMERO:
    ; Verificar el valor del contador para determinar qu� d�gito se est� recibiendo
    LDS R16, salto_contador ; Leer el contador desde la RAM

    CPI R16, 1              ; Si el contador es 1, es la centena
    BREQ RECIBIR_CENTENA

    CPI R16, 2              ; Si el contador es 2, es la decena
    BREQ RECIBIR_DECENA

    CPI R16, 3              ; Si el contador es 3, es la unidad
    BREQ RECIBIR_UNIDAD

    RJMP FIN_GUARDAR_NUMERO ; Si el contador no es v�lido, salir

RECIBIR_CENTENA:
    ; Multiplicar el n�mero recibido por 100 y guardarlo en la RAM
    LDS R17, NUMERORECIBIDO ; Cargar el n�mero recibido
    LDI R18, 100            ; Cargar el valor 100
    MUL R17, R18            ; Multiplicar R17 (n�mero recibido) por 100
    MOVW R24, R0            ; Guardar el resultado en R24:R25
    STS GUARDAR_NUMERO, R24 ; Guardar la parte baja en la RAM
    CLR R25                 ; Asegurarse de que la parte alta sea 0
    STS GUARDAR_NUMERO+1, R25
    INC R16                 ; Incrementar el contador
    STS salto_contador, R16 ; Guardar el nuevo valor del contador
    RJMP FIN_GUARDAR_NUMERO

RECIBIR_DECENA:
    ; Multiplicar el n�mero recibido por 10 y sumarlo a la centena
    LDS R17, NUMERORECIBIDO ; Cargar el n�mero recibido
    LDI R18, 10             ; Cargar el valor 10
    MUL R17, R18            ; Multiplicar R17 (n�mero recibido) por 10
    MOVW R22, R0            ; Guardar el resultado en R22:R23
    LDS R24, GUARDAR_NUMERO ; Cargar el valor actual de la RAM
    LDS R25, GUARDAR_NUMERO+1
    ADD R24, R22            ; Sumar la parte baja
    ADC R25, R23            ; Sumar la parte alta con acarreo
    STS GUARDAR_NUMERO, R24 ; Guardar el resultado en la RAM
    STS GUARDAR_NUMERO+1, R25
    INC R16                 ; Incrementar el contador
    STS salto_contador, R16 ; Guardar el nuevo valor del contador
    RJMP FIN_GUARDAR_NUMERO

RECIBIR_UNIDAD:
    ; Sumar el n�mero recibido directamente a la RAM
    LDS R17, NUMERORECIBIDO ; Cargar el n�mero recibido
    LDS R24, GUARDAR_NUMERO ; Cargar el valor actual de la RAM
    LDS R25, GUARDAR_NUMERO+1
    ADD R24, R17            ; Sumar el n�mero recibido
    STS GUARDAR_NUMERO, R24 ; Guardar el resultado en la RAM
    STS GUARDAR_NUMERO+1, R25
    CLR R16                 ; Reiniciar el contador a 0
    STS salto_contador, R16 ; Guardar el nuevo valor del contador
    RJMP FIN_GUARDAR_NUMERO

FIN_GUARDAR_NUMERO:

; Verificar qu� letra est� en dato_recibido para determinar el umbral a modificar
    LDS R16, dato_recibido ; Cargar la letra recibida en R16

    CPI R16,67           ; Comparar con 'C' (Umbral de aviso de CO)
    BREQ GUARDAR_UMBRAL_CO

    CPI R16,84           ; Comparar con 'T' (Umbral de aviso de Temperatura)
    BREQ GUARDAR_UMBRAL_TEMP

    CPI R16,71           ; Comparar con 'G' (Umbral de aviso de Gases)
    BREQ GUARDAR_UMBRAL_GASES

    CPI R16,72           ; Comparar con 'H' (Umbral de aviso de Humedad)
    BREQ GUARDAR_UMBRAL_HUMEDAD

    CPI R16,80           ; Comparar con 'P' (Umbral de aviso de Part�culas)
    BREQ GUARDAR_UMBRAL_PARTICULAS

    RJMP FIN               ; Si no coincide con ninguna letra, salir



strings:
REPETIDOR:
    LPM   R16,Z+
	//Registro UDR0 manda el dato
    STS   UDR0,R16
ESPERAR:
//Espera que UDRE0(bandera) termine de mandar el dato, sino vuelve de nuevo al bucle esperar
    LDS   R16,UCSR0A
    SBRS  R16,UDRE0
    RJMP  ESPERAR
    DEC   R17
    BRNE  REPETIDOR
RET

INIT_TIMER:
    LDI R16, 0 ; Modo CTC 
    STS TCCR1A, R16
    LDI R16, (1<<WGM12)| (1<<CS10)|(1<<CS11)  ; Prescaler 1024
    STS TCCR1B, R16
    LDI R16, 0
    STS TCCR1C, R16
    LDI R16, (1<<OCIE1B)  ; Habilitar la interrupci?n por comparaci?n del Timer 1
    STS TIMSK1, R16
    LDI R16, HIGH(49999)  ; Parte alta del valor
    STS OCR1BH, R16
    LDI R16, LOW(49999)   ; Parte baja del valor
    STS OCR1BL, R16

	LDI R16, HIGH(49999)  ; Parte alta del valor
    STS OCR1AH, R16
    LDI R16, LOW(49999)   ; Parte baja del valor
    STS OCR1AL, R16
 RET
;Subrutina para enviar las mediciones
DESARMAR_ENVIAR:
LDI R22, LOW(100)
CALL DIVISION8
MOV R20, R24
CALL ENVIO_UART
MOV R24, R25

LDI R22, LOW(10)
CALL DIVISION8
MOV R20, R24
CALL ENVIO_UART
MOV R20, R25
CALL ENVIO_UART

LDI R20, 10
CALL ESPERAR_TX
LDI R20, 13
CALL ESPERAR_TX
RET

ENVIO_UART:
        	LDI	R16,48
        	ADD	R20,R16
ESPERAR_TX:
	LDS	R16,UCSR0A
	SBRS	R16,UDRE0
	RJMP	ESPERAR_TX
	STS	UDR0,R20
	RET

