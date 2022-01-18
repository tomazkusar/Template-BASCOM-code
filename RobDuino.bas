'Authors: Tomaz Kusar & David Rihtarsic
'Date: 19.8.2018
'name: RobDuino.bas
'Version 2.2

'include file for robDuino shield.
'Function for ulstrasonic sensor HC SR004
'Procedure for LCD
'procedure for driving servos on pin B1 and B2
'procedure for PWM on port D and B
'procedure for motor drivig with motorX subrutine (direction and power)
'konstatnte za smeri, naprej, nazaj, gor, dol, levo, desno. Konstatnti GOR in DOL se uporabljata tudi za stikala. Spremnjene so vrednosti teh konstatnt

'16. 4. 2020
'popravljena konfiguracija PWM-ja  Enable PWM on Timer0

'11.11.2020
'dopolnjena konfiguracija oinov D0 in D1 kot izhod, èe jih krmilimo s funkcijo PIND.0 = x in PIND.1 = x
'
'*******************************************************************************
'===========================================================+
'Nastavitve                                                 '
'-----------------------------------------------------------+
'-Push Buttons C4&C5
'Const Down = 0                                              'Ko tipko pritisnemo = v log. "0" (zaèetniki naj se ne ukvarjajo s tem)
'Const Up = 1
Const Button_c5_enabled = 1                                 'If C4 = down Then ...
Const Button_c4_enabled = 1
Const Button_c3_enabled = 1                                 'If C4 = down Then ...
Const Button_c2_enabled = 1
Const Button_c1_enabled = 1                                 'If C4 = down Then ...
Const Button_c0_enabled = 1
'motor direction function
Const Motor1_enabled = 0                                    'konstatnte za uporabo funkcije dOutDir
Const Motor2_enabled = 1
Const Motor3_enabled = 1

Const Naprej = 1                                            'konstante za krmiljenje motorjev in stanje tipk
Const Nazaj = 0
Const Levo = 1
Const Desno = 0
Const Ustavi = 2
Const Gor = 1                                               'tudi za tipke
Const Dol = 0

'-LCD
Const Lcd_enabled = 1                                       'Print "text"
'-Servos
Const Servo1_enabled = 0                                    'B1, Servo1 [0..180]
Const Servo2_enabled = 0                                    'B2, servo2 [0..180]
'-PWM
Const Pwm_b3_enabled = 0                                    'B3, Pwm_b3 = [0..255]
Const Pwm_d3_enabled = 0                                    'D3, Pwm_d3 = [0..255]
Const Pwm_d6_enabled = 0                                    'D6, Pwm_d6 = [0..255]
Const Pwm_d5_enabled = 0                                    'D5, Pwm_d5 = [0..255]
Const Pwm_b1_enabled = 0                                    'D3, Pwm_b1 = [0..4095]
Const Pwm_b2_enabled = 0                                    'D3, Pwm_b2 = [0..4095]
'-UZ senzor HC-SRC04
Const Enhcsr04 = 1
'-----------------------------------------------------------+
Config Submode = New
$nocompile                                                  'da se kompajla samo, èe je vkljuèen iz drugega programa, sam file pa se ne kompajla
'===========================================================+
'konfiguracija analogno digitalnega petvornika              |
'-----------------------------------------------------------+
Config Adc = Single , Prescaler = Auto , Reference = Avcc   'Reference = Off
Start Adc                                                   '
Enable Interrupts                                           '
'-----------------------------------------------------------+
config Portd = output
'===========================================================+
'konfiguracija Tipk                                         |
'-----------------------------------------------------------+
#if Button_c0_enabled                                       '
   Config Portc.0 = Input                                   '
   Portc.0 = 1                                              '
   C0 Alias Pinc.0                                          '
#endif
'------------------------------------------------------------
#if Button_c1_enabled                                       '
   Config Portc.1 = Input                                   '
   Portc.1 = 1                                              '
   C1 Alias Pinc.1                                          '
#endif
'------------------------------------------------------------
#if Button_c2_enabled                                       '
   Config Portc.2 = Input                                   '
   Portc.2 = 1                                              '
   C2 Alias Pinc.2                                          '
#endif
'------------------------------------------------------------
#if Button_c3_enabled                                       '
   Config Portc.3 = Input                                   '
   Portc.3 = 1                                              '
   C3 Alias Pinc.3                                          '
#endif

#if Button_c4_enabled                                       '
   Config Portc.4 = Input                                   '
   Portc.4 = 1                                              '
   C4 Alias Pinc.4                                          '
#endif                                                      '
'-----------------------------------------------------------+
#if Button_c5_enabled                                       '
   Config Portc.5 = Input                                   '
   Portc.5 = 1                                              '
   C5 Alias Pinc.5                                          '
#endif                                                      '
'-----------------------------------------------------------+
'===========================================================+
'konfiguracija LCDja                                        |
'-----------------------------------------------------------+
#if Lcd_enabled = 1                                         '
   Config Lcdpin = Pin , Db4 = Portb.5 , Db5 = Portb.1 , Db6 = Portb.4 , Db7 = Portb.0 , E = Portb.2 , Rs = Portb.3
   Config Lcd = 16 * 1a                                     '
   Initlcd                                                  '
   Waitus 4                                                 '
#endif
                                                '
'-----------------------------------------------------------+
'===========================================================+
'Enable PWM on Timer0                                       |
'-----------------------------------------------------------+
#if Pwm_d5_enabled = 1 Or Pwm_d6_enabled = 1                '
   Tccr0a = &B0000_0011                                     'Wgm22:0 = 011 = fast PWM
   Tccr0b = &B0000_0011                                     '64 prescaler                           'wgm22 =0 , CLK prescaler = 1..7 -> 1,8,32,64,128,256,1024
#endif                                                      '
'-----------------------------------------------------------+
'Enable PWM0 on D6 = OC0A                                   |
'-----------------------------------------------------------+
#if Pwm_d6_enabled = 1                                      '
   Config Portd.6 = Output                                  '
   Tccr0a.7 = 1                                             'enable timrt 0 on d3=OC0A
   Pwm_d6 Alias Ocr0a                                       '
   Pwm_d6 = 127                                             '
#endif                                                      '
'-----------------------------------------------------------+
'Enable PWM0 on D5 = OC0B                                   |
'-----------------------------------------------------------+
#if Pwm_d5_enabled = 1                                      '
   Config Portd.5 = Output                                  '
   Tccr0a.5 = 1                                             'enable timrt 0 on D5=OC0b
   Pwm_d5 Alias Ocr0b                                       '
   Pwm_d5 = 127                                             '
#endif                                                      '
'-----------------------------------------------------------+
'===========================================================+
'Enable Timer1 for servos or PWM                            |
'-----------------------------------------------------------+
#if Servo1_enabled = 1 Or Servo2_enabled = 1 Or Pwm_b1_enabled = 1 Or Pwm_b2_enabled = 1
   Tccr1a = &B_0000_0010                                    '&HA2=&B1010_0010 'Com1a1 = 1 , Com1a0 = 0 , Com1b1 = 1 , Com1b0 = 0
   Tccr1b = &B_0001_1011                                    '&H1B=0001_1011   'WGM13 = 1, WGM12 = 1, CS11 = 1, CS10 = 1
   Icr1 = 4095                                              'f cca. 50Hz  (tocno bi bilo 4999, a zaradi PWNja = 4095)
#endif                                                      '


#if Motor1_enabled = 1 Or Motor2_enabled = 1 Or Motor3_enabled = 1
 'enable PWM on timer 0
 Tccr0a = &B0000_0011                                       'Wgm22:0 = 011 = fast PWM
 Tccr0b = &B0000_0011                                       '64 prescaler
 'enable PWM on timer 2
 Tccr2a = &B0000_0011                                       'Wgm22:0 = 011 = fast PWM
 Tccr2b = &B0000_0011                                       'wgm22 =0 , CLK prescaler = 1..7 -> 1,8,32,64,128,256,1024

#endif


#if Motor1_enabled = 1
    Config Portd.2 = Output
    Config Portd.3 = Output
    Declare Sub Motor1(byval Direction As Byte , Byval Moc As Byte)
    Tccr2a.5 = 1
    Sub Motor1(byval Direction As Byte , Byval Moc As Byte)
        Select Case Direction
               Case 0 :
                    Portd.2 = 1
                    Ocr2b = 255 - Moc
               Case 1 :
                    Portd.2 = 0
                    Ocr2b = Moc
               Case 2 :
                    Ocr2b = 0
                    Portd.2 = 0
        End Select
    End Sub
#endif

#if Motor2_enabled = 1
    Config Portd.4 = Output
    Config Portd.5 = Output
    Declare Sub Motor2(byval Direction As Byte , Byval Moc As Byte)
    Tccr0a.5 = 1
    Sub Motor2(byval Direction As Byte , Byval Moc As Byte)
        Select Case Direction
               Case 0 :
                    Portd.4 = 1
                    Ocr0b = 255 - Moc
               Case 1 :
                    Portd.4 = 0
                    Ocr0b = Moc
               Case 2 :
                    Ocr0b = 0
                    Portd.4 = 0
        End Select
    End Sub
#endif

#if Motor3_enabled = 1
    Config Portd.6 = Output
    Config Portd.7 = Output
    Declare Sub Motor3(byval Direction As Byte , Byval Moc As Byte)
    Tccr0a.7 = 1
    Sub Motor3(byval Direction As Byte , Byval Moc As Byte)
        Select Case Direction
               Case 0 :
                    Ocr0a = Moc
                    Portd.7 = 0
               Case 1 :
                    Ocr0a = 255 - Moc
                    Portd.7 = 1
               Case 2 :
                    Ocr0a = 0
                    Portd.7 = 0
        End Select
    End Sub
#endif


'-----------------------------------------------------------+
'Enable Servo 1                                             |
'-----------------------------------------------------------+
#if Servo1_enabled = 1                                      '
   Tccr1a.7 = 1                                             '
   Dim Servo1_offset As Integer                             '
   Servo1_offset = 0                                        '
   Config Portb.1 = Output                                  '
   Declare Sub Servo1(byval Pos1 As Byte)                   '
   Servo1_pulse Alias Ocr1a                                 '
   Sub Servo1(byval Pos1 As Byte)                           '
      Dim New_ocr1a As Word                                 '
      New_ocr1a = Pos1                                      '
      Shift New_ocr1a , Left                                '
      New_ocr1a = New_ocr1a + 180                           '
      New_ocr1a = New_ocr1a + Servo1_offset                 '
      Ocr1a = New_ocr1a                                     '
   End Sub                                                  '
#endif                                                      '
'-----------------------------------------------------------+
'Enable Servo 2                                             |
'-----------------------------------------------------------+
#if Servo2_enabled = 1                                      '
   Tccr1a.5 = 1                                             '
   Dim Servo2_offset As Integer                             '
   Servo2_offset = 0                                        '
   Config Portb.2 = Output                                  '
   Declare Sub Servo2(byval Pos2 As Byte)                   '
   Servo2_pulse Alias Ocr1b                                 '
   Sub Servo2(byval Pos2 As Byte)                           '
      Dim New_ocr1b As Word                                 '
      New_ocr1b = Pos2                                      '
      Shift New_ocr1b , Left                                '
      New_ocr1b = New_ocr1b + 180                           '
      New_ocr1b = New_ocr1b + Servo2_offset                 '
      Ocr1b = New_ocr1b                                     '
   End Sub                                                  '
#endif                                                      '
'-----------------------------------------------------------+
'Enable PWM1 on B1 = OC1A                                   |
'-----------------------------------------------------------+
#if Pwm_b1_enabled = 1                                      '
   Config Portb.1 = Output                                  '
   Tccr1a.7 = 1                                             'enable timrt 1 on b1=OC1A
   Pwm_b1 Alias Ocr1a                                       '
   Pwm_b1 = 127                                             '
#endif                                                      '
'-----------------------------------------------------------+
'Enable PWM1 on B2 = OC1b                                   |
'-----------------------------------------------------------+
#if Pwm_b2_enabled = 1                                      '
   Config Portb.2 = Output                                  '
   Tccr1a.5 = 1                                             'enable timrt 1 on b1=OC1A
   Pwm_b2 Alias Ocr1b                                       '
   Pwm_b2 = 127                                             '
#endif                                                      '
'-----------------------------------------------------------+
'===========================================================+
'Enable PWM on Timer2                                       |
'-----------------------------------------------------------+
#if Pwm_b3_enabled = 1 Or Pwm_d3_enabled = 1                '
   Tccr2a = &B0000_0011                                     'Wgm22:0 = 011 = fast PWM
   Tccr2b = &B0000_0011                                     'wgm22 =0 , CLK prescaler = 1..7 -> 1,8,32,64,128,256,1024
#endif                                                      '
'-----------------------------------------------------------+
'Enable PWM2 on B3 = OC2A                                   |
'-----------------------------------------------------------+
#if Pwm_b3_enabled = 1                                      '
   Config Portb.3 = Output                                  '
   Tccr2a.7 = 1                                             'enable timrt 2 on B3=OC2A
   Pwm_b3 Alias Ocr2a                                       '
   Pwm_b3 = 127                                             '
#endif                                                      '
'-----------------------------------------------------------+
'Enable PWM2 on D3 = OC2B                                   |
'-----------------------------------------------------------+
#if Pwm_d3_enabled = 1                                      '
   Config Portd.3 = Output                                  '
   Tccr2a.5 = 1                                             'enable timrt 2 on D3=OC2b
   Pwm_d3 Alias Ocr2b                                       '
   Pwm_d3 = 127                                             '
#endif                                                      '
'-----------------------------------------------------------+
'===========================================================+
'Conflicts of use                                           |
'-----------------------------------------------------------+
#if Lcd_enabled And(servo1_enabled Or Servo2_enabled )
   Debug On
   $baud = 115200
   Debug "LCD and Servo are using the same pin!"
   Debug "Choose either of it..."
#endif
#if Lcd_enabled And(pwm_b1_enabled Or Pwm_b2_enabled Or Pwm_b3_enabled)
   Debug On
   $baud = 115200
   Debug "LCD and PWM are using the same pin!"
   Debug "Choose either of it..."
#endif

'*******************************************************************************
#if Enhcsr04 = 1
'funkcija za merjenje z ultrazvoènim slednikom HC-SR04
Dim D As Word
Dim Mm As Word
Dim Cm As Word
Config Portc.3 = Output                                     'izberemo trig  pin
Config Portc.2 = Input                                      'izberemo echo  pin

Declare Function Izmeriuz_mm() As Word

Function Izmeriuz_mm() As Word
   Mm = 0
   Pulseout Portc , 3 , 20
   Pulsein D , Pinc , 2 , 1

   D = D * 10
   Mm = D / 6                                               'pretvorba v mm
   'Cm = D / 58
   'Shift Mm , Right , 1                                     'pretvorba v cm
   Izmeriuz_mm = Mm
   'perioda vzorèenja ne sme biti manjša od 50ms, zato prepreèimo prezgodnjo meritev
   'Waitms 50
End Function
#endif