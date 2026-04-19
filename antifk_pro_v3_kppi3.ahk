; =====================================================
;  ROBLOX ANTI-AFK PRO v3.0
;  Made by kppi3
;  discord.gg/uZSKgra347
; =====================================================

#Persistent
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1

; ---------- GLOBALS ----------
global timerRunning   := false
global intervalMs     := 900000
global webhookURL     := ""
global logLines       := ""
global totalJumps     := 0
global sessionStart   := A_Now
global screenshotDir  := A_ScriptDir . "\screenshots"
global discordLink    := "https://discord.gg/uZSKgra347"
global hDiscordBtn    := 0

; =====================================================
;  TRAY
; =====================================================
Menu, Tray, NoStandard
Menu, Tray, Add, Open Panel,  ShowMain
Menu, Tray, Add, Discord,     OpenDiscord
Menu, Tray, Add, Exit,        DoExit
Menu, Tray, Tip, Anti-AFK PRO by kppi3

; =====================================================
;  MAIN GUI
; =====================================================
Gui, Main:New, +AlwaysOnTop -Resize +LastFound
Gui, Main:Color, 080810

; === HEADER BAR background ===
Gui, Main:Add, Text, x0 y0 w590 h70 Background0d0d1f,

; Title
Gui, Main:Font, s22 bold c00d4ff, Segoe UI
Gui, Main:Add, Text, x18 y8, ANTI-AFK
Gui, Main:Font, s22 bold cff3cac, Segoe UI
Gui, Main:Add, Text, x192 y8, PRO

; made by kppi3 - bigger, bright
Gui, Main:Font, s12 bold cffe566, Segoe UI
Gui, Main:Add, Text, x18 y44, made by kppi3

; v3.0 tag
Gui, Main:Font, s8 norm c333366, Segoe UI
Gui, Main:Add, Text, x145 y52, v3.0

; Discord logo button (drawn as picture + label trick)
; We use a Button with custom label - AHK cant render SVG natively
; so we draw the Discord "blurple" rounded rect + "D" glyph via button
Gui, Main:Font, s9 bold cffffff, Segoe UI
Gui, Main:Add, Button, x488 y14 w88 h40 gOpenDiscord vBtnDiscord,
; We will paint the Discord logo on it via WM_PAINT workaround below
; For now label stays empty - we draw it after show

; Accent line
Gui, Main:Add, Text, x0 y70 w590 h2 Background5865f2,

; =====================================================
;  LEFT COLUMN - JUMP SETTINGS
; =====================================================
Gui, Main:Font, s8 bold c00d4ff, Segoe UI
Gui, Main:Add, Text, x16 y86, JUMP SETTINGS

Gui, Main:Font, s8 norm c555577, Segoe UI
Gui, Main:Add, Text, x16 y104, Interval
Gui, Main:Font, s9 bold cffffff, Segoe UI
Gui, Main:Add, ComboBox, x16 y120 w95 vIntervalChoice gOnIntervalChange AltSubmit, 5 min|10 min|15 min|20 min|30 min
GuiControl, Main:Choose, IntervalChoice, 3

Gui, Main:Font, s8 norm c555577, Segoe UI
Gui, Main:Add, Text, x16 y154, Jump style
Gui, Main:Font, s9 bold cffffff, Segoe UI
Gui, Main:Add, ComboBox, x16 y170 w180 vJumpVariant, 1 Jump|2 Jumps|3 Jumps|Jump + Rotate|Crouch + Jump|Random Mix
GuiControl, Main:Choose, JumpVariant, 1

Gui, Main:Font, s8 norm c555577, Segoe UI
Gui, Main:Add, Text, x16 y206, Delay between jumps (ms)
Gui, Main:Font, s9 cffffff, Segoe UI
Gui, Main:Add, Edit, x16 y222 w65 h22 vJumpDelay Background0f0f20 cffffff, 130
Gui, Main:Font, s8 norm c333366, Segoe UI
Gui, Main:Add, Text, x86 y224, ms

Gui, Main:Font, s8 norm caaaacc, Segoe UI
Gui, Main:Add, CheckBox, x16 y252 vRandomize    Checked0 caaaacc, Randomize delay (+/- 60ms)
Gui, Main:Add, CheckBox, x16 y272 vAntiPattern  Checked1 caaaacc, Anti-pattern mode (vary timing)
Gui, Main:Add, CheckBox, x16 y292 vSendChat     Checked0 caaaacc gOnChatToggle, Send chat after jump
Gui, Main:Font, s8 norm c2a2a4a, Courier New
Gui, Main:Add, Edit, x16 y312 w180 h20 vChatMsg Background0a0a1a c555577 Disabled, .

; Divider
Gui, Main:Add, Text, x210 y84 w1 h252 Background1a1a38,

; =====================================================
;  RIGHT COLUMN - DISCORD WEBHOOK
; =====================================================
Gui, Main:Font, s8 bold c5865f2, Segoe UI
Gui, Main:Add, Text, x222 y86, DISCORD WEBHOOK

Gui, Main:Font, s8 norm c555577, Segoe UI
Gui, Main:Add, Text, x222 y104, Webhook URL
Gui, Main:Font, s8 norm cffffff, Courier New
Gui, Main:Add, Edit, x222 y120 w352 h40 vWebhookInput Background0a0a1a cffffff,

Gui, Main:Font, s8 bold c5865f2, Segoe UI
Gui, Main:Add, Text, x222 y168, Embed fields:
Gui, Main:Font, s8 norm caaaacc, Segoe UI
Gui, Main:Add, CheckBox, x222 y186 vOptTime      Checked1, Timestamp
Gui, Main:Add, CheckBox, x360 y186 vOptWindows   Checked1, Window count
Gui, Main:Add, CheckBox, x222 y204 vOptVariantW  Checked1, Jump variant
Gui, Main:Add, CheckBox, x360 y204 vOptJumpCount Checked1, Total jumps
Gui, Main:Add, CheckBox, x222 y222 vOptSession   Checked1, Session time
Gui, Main:Add, CheckBox, x360 y222 vOptUsername  Checked0, PC username

Gui, Main:Font, s8 bold c00d4ff, Segoe UI
Gui, Main:Add, Text, x222 y248, Screenshot options:
Gui, Main:Font, s8 norm caaaacc, Segoe UI
Gui, Main:Add, CheckBox, x222 y266 vOptScreenshot Checked0 gOnSSToggle, Capture window on jump
Gui, Main:Add, CheckBox, x222 y284 vOptSSDiscord  Checked0, Attach PNG to Discord message
Gui, Main:Font, s7 norm c252545, Segoe UI
Gui, Main:Add, Text, x222 y304, Saves to /screenshots  |  requires Windows 10+

; =====================================================
;  SEPARATOR
; =====================================================
Gui, Main:Add, Text, x0 y342 w590 h1 Background151530,

; =====================================================
;  BUTTONS
; =====================================================
Gui, Main:Font, s9 bold c000000, Segoe UI
Gui, Main:Add, Button, x16  y352 w145 h38 gStartStop  vBtnStart,  START
Gui, Main:Add, Button, x170 y352 w105 h38 gTestJump,              TEST JUMP
Gui, Main:Add, Button, x284 y352 w120 h38 gOpenSSFolder,          SCREENSHOTS
Gui, Main:Add, Button, x414 y352 w82  h38 gClearLog,              CLEAR LOG
Gui, Main:Add, Button, x506 y352 w68  h38 gTestWebhook,           TEST WH

; =====================================================
;  STATUS STRIP
; =====================================================
Gui, Main:Add, Text, x0 y400 w590 h26 Background090918,
Gui, Main:Font, s8 norm c333355, Segoe UI
Gui, Main:Add, Text, x12 y407, STATUS:
Gui, Main:Font, s8 bold c888888, Segoe UI
Gui, Main:Add, Text, x72 y407 w55 vStatusText, IDLE
Gui, Main:Font, s8 norm c333355, Segoe UI
Gui, Main:Add, Text, x140 y407, JUMPS:
Gui, Main:Font, s8 bold c00d4ff, Segoe UI
Gui, Main:Add, Text, x186 y407 w40 vJumpCounter, 0
Gui, Main:Font, s8 norm c333355, Segoe UI
Gui, Main:Add, Text, x238 y407, WINDOWS:
Gui, Main:Font, s8 bold cff3cac, Segoe UI
Gui, Main:Add, Text, x298 y407 w30 vWinCounter, 0
Gui, Main:Font, s8 norm c333355, Segoe UI
Gui, Main:Add, Text, x344 y407, SESSION:
Gui, Main:Font, s8 bold c00ff88, Segoe UI
Gui, Main:Add, Text, x398 y407 w160 vSessionTime, 00:00:00

; =====================================================
;  LOG
; =====================================================
Gui, Main:Add, Text, x0 y426 w590 h1 Background151530,
Gui, Main:Font, s7 norm c222244, Segoe UI
Gui, Main:Add, Text, x12 y430, ACTIVITY LOG
Gui, Main:Font, s7 norm c00ff88, Courier New
Gui, Main:Add, Edit, x0 y446 w590 h112 vLogBox ReadOnly Background04040e c00ff88,

; =====================================================
;  FOOTER
; =====================================================
Gui, Main:Add, Text, x0 y558 w590 h24 Background090918,
Gui, Main:Font, s7 norm c222244, Segoe UI
Gui, Main:Add, Text, x12 y563, Anti-AFK PRO v3.0  |  made by kppi3  |  Win+Esc to exit
Gui, Main:Font, s7 norm c5865f2, Segoe UI
Gui, Main:Add, Text, x458 y563 gOpenDiscord, discord.gg/uZSKgra347

Gui, Main:Show, w590 h582, Anti-AFK PRO v3.0 by kppi3

; Paint Discord logo on button after window shown
SetTimer, DrawDiscordBtn, -200
SetTimer, UpdateSession, 1000
AddLog("[BOOT] Anti-AFK PRO v3.0  --  made by kppi3")
AddLog("[INFO] Paste your webhook URL and press START.")
return

; =====================================================
;  DISCORD BUTTON LABEL
; =====================================================
DrawDiscordBtn:
    GuiControl, Main:, BtnDiscord, Join Discord
return

; =====================================================
;  CHAT TOGGLE
; =====================================================
OnChatToggle:
    GuiControlGet, SendChat
    if (SendChat)
        GuiControl, Main:Enable, ChatMsg
    else
        GuiControl, Main:Disable, ChatMsg
return

; =====================================================
;  SESSION TIMER
; =====================================================
UpdateSession:
    if (!timerRunning)
        return
    EnvSub, diff, %sessionStart%, Seconds
    diff := Abs(diff)
    h := diff // 3600
    m := Mod(diff, 3600) // 60
    s := Mod(diff, 60)
    GuiControl, Main:, SessionTime,
        % (h<10?"0":"") . h . ":" . (m<10?"0":"") . m . ":" . (s<10?"0":"") . s
return

; =====================================================
;  INTERVAL CHANGE
; =====================================================
OnIntervalChange:
    GuiControlGet, IntervalChoice
    arr := [300000, 600000, 900000, 1200000, 1800000]
    intervalMs := arr[IntervalChoice]
    if (timerRunning)
        SetTimer, AntyAFK, %intervalMs%
return

; =====================================================
;  SCREENSHOT TOGGLE
; =====================================================
OnSSToggle:
    GuiControlGet, OptScreenshot
    if (OptScreenshot) {
        if !FileExist(screenshotDir)
            FileCreateDir, %screenshotDir%
        AddLog("[SS]  Folder: " . screenshotDir)
    }
return

; =====================================================
;  OPEN DISCORD
; =====================================================
OpenDiscord:
    Run, %discordLink%
return

; =====================================================
;  START / STOP
; =====================================================
StartStop:
    GuiControlGet, WebhookInput
    webhookURL := Trim(WebhookInput)

    if (!timerRunning) {
        timerRunning := true
        sessionStart := A_Now
        SetTimer, AntyAFK, %intervalMs%
        GuiControl, Main:, BtnStart, STOP
        GuiControl, Main:, StatusText, ACTIVE
        mins := [5,10,15,20,30][IntervalChoice ? IntervalChoice : 3]
        AddLog("[ON]  Started  --  interval: " . mins . " min")
        if (webhookURL != "") {
            AddLog("[WH]  Webhook OK")
            SendStartNotify()
        } else {
            AddLog("[WH]  No webhook set (Discord disabled)")
        }
    } else {
        timerRunning := false
        SetTimer, AntyAFK, Off
        GuiControl, Main:, BtnStart, START
        GuiControl, Main:, StatusText, IDLE
        AddLog("[OFF] Stopped  --  total jumps: " . totalJumps)
    }
return

; =====================================================
;  TEST JUMP
; =====================================================
TestJump:
    AddLog("[TEST] Running test jump...")
    GoSub, DoJump
return

; =====================================================
;  TEST WEBHOOK
; =====================================================
TestWebhook:
    GuiControlGet, WebhookInput
    webhookURL := Trim(WebhookInput)
    if (webhookURL = "") {
        AddLog("[ERR]  No webhook URL entered!")
        return
    }
    AddLog("[TEST] Sending test webhook...")
    payload := "{""embeds"":[{""title"":"":white_check_mark: Webhook Test"",""description"":""Anti-AFK PRO v3.0 is connected!\n\nMade by **kppi3**"",""color"":5793266,""footer"":{""text"":""Anti-AFK PRO v3.0 by kppi3""}}]}"
    tmpFile := A_Temp . "\ahk_test_wh.json"
    FileDelete, %tmpFile%
    FileAppend, %payload%, %tmpFile%
    Run, %ComSpec% /c curl -s -X POST -H "Content-Type: application/json" -d @"%tmpFile%" "%webhookURL%",, Hide
    AddLog("[WH]  Test sent!")
return

; =====================================================
;  CLEAR LOG
; =====================================================
ClearLog:
    logLines := ""
    GuiControl, Main:, LogBox,
return

; =====================================================
;  OPEN SCREENSHOTS FOLDER
; =====================================================
OpenSSFolder:
    if !FileExist(screenshotDir)
        FileCreateDir, %screenshotDir%
    Run, explorer.exe "%screenshotDir%"
return

; =====================================================
;  TIMER
; =====================================================
AntyAFK:
    GoSub, DoJump
return

; =====================================================
;  JUMP LOGIC
; =====================================================
DoJump:
    GuiControlGet, JumpVariant
    GuiControlGet, JumpDelay
    GuiControlGet, Randomize
    GuiControlGet, AntiPattern
    GuiControlGet, SendChat
    GuiControlGet, ChatMsg
    GuiControlGet, OptScreenshot
    GuiControlGet, OptSSDiscord
    GuiControlGet, OptTime
    GuiControlGet, OptWindows
    GuiControlGet, OptVariantW
    GuiControlGet, OptJumpCount
    GuiControlGet, OptSession
    GuiControlGet, OptUsername

    baseDelay := JumpDelay + 0
    WinGet, activeWin, ID, A
    WinGet, robloxList, List, ahk_exe RobloxPlayerBeta.exe
    count := robloxList

    GuiControl, Main:, WinCounter, %count%

    if (count = 0) {
        AddLog("[WARN] No Roblox windows found!")
        return
    }

    screenshotPaths := []
    FormatTime, ts,,      yyyyMMdd_HHmmss
    FormatTime, timeDisp,, HH:mm:ss

    Loop, %count%
    {
        hwnd := robloxList%A_Index%
        WinActivate, ahk_id %hwnd%
        WinWaitActive, ahk_id %hwnd%,, 2
        if ErrorLevel
            continue

        d := baseDelay
        if (Randomize) {
            Random, rnd, -60, 60
            d := d + rnd
        }
        if (AntiPattern) {
            Random, ap, 0, 80
            d := d + ap
        }
        if (d < 50)
            d := 50

        ; JUMP VARIANTS
        if (JumpVariant = "1 Jump") {
            Send, {Space down}
            Sleep, 110
            Send, {Space up}

        } else if (JumpVariant = "2 Jumps") {
            Loop, 2 {
                Send, {Space down}
                Sleep, 110
                Send, {Space up}
                Sleep, %d%
            }
        } else if (JumpVariant = "3 Jumps") {
            Loop, 3 {
                Send, {Space down}
                Sleep, 110
                Send, {Space up}
                Sleep, %d%
            }
        } else if (JumpVariant = "Jump + Rotate") {
            Send, {Space down}
            Sleep, 110
            Send, {Space up}
            Sleep, 180
            Send, {d down}
            Sleep, 680
            Send, {d up}
        } else if (JumpVariant = "Crouch + Jump") {
            Send, {LControl down}
            Sleep, 160
            Send, {LControl up}
            Sleep, 150
            Send, {Space down}
            Sleep, 110
            Send, {Space up}
        } else {
            Random, ri, 1, 4
            if (ri = 1) {
                Send, {Space down}
                Sleep, 110
                Send, {Space up}
            } else if (ri = 2) {
                Loop, 2 {
                    Send, {Space down}
                    Sleep, 110
                    Send, {Space up}
                    Sleep, %d%
                }
            } else if (ri = 3) {
                Send, {Space down}
                Sleep, 110
                Send, {Space up}
                Sleep, 200
                Send, {d down}
                Sleep, 500
                Send, {d up}
            } else {
                Send, {LControl down}
                Sleep, 140
                Send, {LControl up}
                Sleep, 120
                Send, {Space down}
                Sleep, 110
                Send, {Space up}
            }
        }

        ; CHAT
        if (SendChat && ChatMsg != "" && ChatMsg != ".") {
            Sleep, 400
            Send, {/ down}
            Sleep, 50
            Send, {/ up}
            Sleep, 200
            Send, %ChatMsg%
            Sleep, 100
            Send, {Enter}
        }

        Sleep, 350

        ; SCREENSHOT
        if (OptScreenshot) {
            if !FileExist(screenshotDir)
                FileCreateDir, %screenshotDir%
            imgPath := screenshotDir . "\jump_w" . A_Index . "_" . ts . ".png"
            WinGetPos, wx, wy, ww, wh, ahk_id %hwnd%
            psCmd := "powershell -WindowStyle Hidden -Command ""Add-Type -AssemblyName System.Windows.Forms,System.Drawing; $b=New-Object System.Drawing.Bitmap(" . ww . "," . wh . "); $g=[System.Drawing.Graphics]::FromImage($b); $g.CopyFromScreen(" . wx . "," . wy . ",0,0,[System.Drawing.Size]::new(" . ww . "," . wh . ")); $b.Save('" . imgPath . "'); $g.Dispose(); $b.Dispose()"""
            Run, %psCmd%,, Hide
            Sleep, 950
            screenshotPaths.Push(imgPath)
            AddLog("[SS]  Captured window " . A_Index . " -> " . "jump_w" . A_Index . "_" . ts . ".png")
        }
    }

    WinActivate, ahk_id %activeWin%
    totalJumps++
    GuiControl, Main:, JumpCounter, %totalJumps%
    AddLog("[JUMP] " . timeDisp . "  |  " . count . " window(s)  |  " . JumpVariant . "  |  #" . totalJumps)

    if (webhookURL != "")
        SendDiscordJump(count, JumpVariant, timeDisp, OptTime, OptWindows, OptVariantW, OptJumpCount, OptSession, OptUsername, OptSSDiscord, screenshotPaths)
return

; =====================================================
;  DISCORD: START NOTIFY
; =====================================================
SendStartNotify() {
    global webhookURL
    payload := "{""embeds"":[{""title"":"":green_circle:  Anti-AFK Session Started"",""description"":""Monitoring started on **" . A_ComputerName . "**\nReady to keep your accounts active!"",""color"":3066993,""footer"":{""text"":""Anti-AFK PRO v3.0  |  made by kppi3""}}]}"
    tmpFile := A_Temp . "\ahk_start.json"
    FileDelete, %tmpFile%
    FileAppend, %payload%, %tmpFile%
    Run, %ComSpec% /c curl -s -X POST -H "Content-Type: application/json" -d @"%tmpFile%" "%webhookURL%",, Hide
}

; =====================================================
;  DISCORD: JUMP NOTIFY
; =====================================================
SendDiscordJump(winCount, variant, timeStr, doTime, doWin, doVariant, doTotal, doSession, doUser, doSS, ssPaths) {
    global webhookURL, totalJumps, sessionStart

    fields := "["
    if (doTime)
        fields .= "{""name"":"":alarm_clock: Time"",""value"":""`" . timeStr . "`"",""inline"":true},"
    if (doWin)
        fields .= "{""name"":"":desktop_computer: Windows"",""value"":""`" . winCount . "`"",""inline"":true},"
    if (doVariant)
        fields .= "{""name"":"":athletic_shoe: Jump Style"",""value"":""`" . variant . "`"",""inline"":true},"
    if (doTotal)
        fields .= "{""name"":"":bar_chart: Total Jumps"",""value"":""`" . totalJumps . "`"",""inline"":true},"
    if (doSession) {
        EnvSub, diff, %sessionStart%, Seconds
        diff := Abs(diff)
        sessionStr := (diff//3600 < 10 ? "0" : "") . diff//3600 . ":" . (Mod(diff,3600)//60 < 10 ? "0" : "") . Mod(diff,3600)//60 . ":" . (Mod(diff,60) < 10 ? "0" : "") . Mod(diff,60)
        fields .= "{""name"":"":timer: Session"",""value"":""`" . sessionStr . "`"",""inline"":true},"
    }
    if (doUser)
        fields .= "{""name"":"":bust_in_silhouette: User"",""value"":""`" . A_UserName . "`"",""inline"":true},"

    StringTrimRight, fields, fields, 1
    fields .= "]"

    hasImg  := (doSS && ssPaths.MaxIndex() > 0)
    imgNote := hasImg ? "\n:camera: " . ssPaths.MaxIndex() . " screenshot(s) attached" : ""

    payload := "{""embeds"":[{""title"":"":joystick:  Jump Fired!"",""description"":""Anti-AFK activated on **" . winCount . "** Roblox window(s)" . imgNote . """,""color"":16711935,""fields"":" . fields . ",""footer"":{""text"":""Anti-AFK PRO v3.0  |  made by kppi3""}}]}"

    tmpFile := A_Temp . "\ahk_jump_payload.json"
    FileDelete, %tmpFile%
    FileAppend, %payload%, %tmpFile%
    Run, %ComSpec% /c curl -s -X POST -H "Content-Type: application/json" -d @"%tmpFile%" "%webhookURL%",, Hide
    Sleep, 500

    if (hasImg) {
        Loop, % ssPaths.MaxIndex()
        {
            imgFile := ssPaths[A_Index]
            tries := 0
            while (!FileExist(imgFile) && tries < 20) {
                Sleep, 350
                tries++
            }
            if FileExist(imgFile) {
                Run, %ComSpec% /c curl -s -X POST -F "file=@%imgFile%" "%webhookURL%",, Hide
                Sleep, 700
            }
        }
    }
}

; =====================================================
;  ADD LOG
; =====================================================
AddLog(msg) {
    global logLines
    logLines .= msg . "`n"
    lines := StrSplit(logLines, "`n")
    total := lines.MaxIndex()
    if (total > 24) {
        logLines := ""
        Loop, % total - 1 {
            if (A_Index > total - 20)
                logLines .= lines[A_Index] . "`n"
        }
    }
    GuiControl, Main:, LogBox, %logLines%
}

; =====================================================
;  WINDOW / EXIT
; =====================================================
GuiClose:
    Gui, Main:Hide
return

ShowMain:
    Gui, Main:Show
return

DoExit:
#Escape::
    ExitApp
