;
; led-blink.asm
;
; Created: 2025/11/30 13:48:43
; Author : smi
;
.device ATtiny10
.cseg
.org 0x0000

RESET:
    ; --- システムクロック設定 (8MHz) ---
    LDI     r16, 0xD8       ; CCP解除キー
    OUT     CCP, r16
    LDI     r16, 0x00       ; 分周なし
    OUT     CLKPSR, r16

    ; --- スタックポインタ設定 ---
	LDI		r16, high(RAMEND)
	OUT     SPH, r16
	LDI		r16, low(RAMEND)
	OUT		SPL, r16

    ; --- I/O設定 ---
    LDI     r16, (1 << PB0)       ; PB0を出力設定
    OUT     DDRB, r16

	; --- タイマー0設定 (CTCモードで1Hzを作る) ---
    ; 目標: 0.5秒ごとに反転 (1Hz)
    ; クロック: 8,000,000 Hz
    ; プリスケーラ: 1024 (一番遅くする)
    ; タイマー速度: 8,000,000 / 1024 = 7812.5 Hz (1秒間に7812.5カウント)
    ; 0.5秒カウント数: 7812.5 / 2 = 約3906

    ; 1. カウント上限値 (OCR0A) を設定
    ; 3906 = 0x0F42
    LDI     r16, 0x0F       ; High byte
    OUT     OCR0AH, r16
    LDI     r16, 0x42       ; Low byte
    OUT     OCR0AL, r16

    ; 2. TCCR0A設定
    ; COM0A1:0 = 01 (比較一致でOC0A/PB0をトグル反転)
    ; WGM01:0  = 00 (CTCモードの一部)
    LDI     r16, (1 << COM0A0)
    OUT     TCCR0A, r16

    ; 3. TCCR0B設定
    ; WGM03:2 = 01 (CTCモード Mode 4)
    ; CS02:0  = 101 (プリスケーラ 1024)
    LDI     r16, (1 << WGM02) | (1 << CS02) | (1 << CS00)
    OUT     TCCR0B, r16

    ; --- ポインタ初期化 ---

    ; --- メインループ ---
loop:

	rjmp	loop