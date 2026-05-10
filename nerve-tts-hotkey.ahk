; Nerve TTS - AutoHotKey Quick Speak
; CapsLock+C: Copy selected text → paste into Nerve TTS → play
; Requires: Nerve TTS PWA installed in Edge
;
; INSTALL: Put this in your Startup folder or run manually.
; If Nerve TTS isn't open, it will open it first.

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; ============================================
; CONFIG - adjust these if needed
; ============================================
; The PWA window title (check Task Manager if different)
TTS_WINDOW_TITLE := "Nerve TTS"
; Fallback: if PWA not found, open this URL
TTS_URL := "https://nerve-tts.pages.dev/index.html"
; Or local file path if not deployed:
; TTS_URL := "D:\GitHub\nerve-tts-pwa\index.html"

; ============================================
; CapsLock + C = Quick Speak
; ============================================
CapsLock & c::
    ; Save current clipboard
    ClipSaved := ClipboardAll
    Clipboard := ""
    
    ; Copy selected text
    Send, ^c
    ClipWait, 2
    if (ErrorLevel) {
        ToolTip, No text selected
        Sleep, 1500
        ToolTip
        Clipboard := ClipSaved
        return
    }
    
    CopiedText := Clipboard
    
    ; Find or launch Nerve TTS
    IfWinExist, %TTS_WINDOW_TITLE%
    {
        WinActivate
    }
    else
    {
        ; Try to find by partial title
        SetTitleMatchMode, 2
        IfWinExist, Nerve TTS
        {
            WinActivate
        }
        else
        {
            ; Launch the PWA/URL
            Run, %TTS_URL%
            WinWait, Nerve TTS,, 5
            if (ErrorLevel) {
                ToolTip, Could not open Nerve TTS
                Sleep, 2000
                ToolTip
                Clipboard := ClipSaved
                return
            }
            WinActivate
            Sleep, 1000  ; Wait for page to load
        }
    }
    
    Sleep, 200
    
    ; Focus the textarea and paste
    ; The textarea has id="textInput" - we'll click it then paste
    Send, {Tab}  ; Focus first focusable element (the textarea)
    Sleep, 100
    
    ; Select all existing text and replace with new
    Send, ^a
    Sleep, 50
    
    ; Set clipboard to the copied text
    Clipboard := CopiedText
    Send, ^v
    Sleep, 100
    
    ; Hit Ctrl+Enter to play
    Send, ^{Enter}
    
    ; Restore original clipboard after a beat
    Sleep, 500
    Clipboard := ClipSaved
    
    ToolTip, ⚡ Speaking...
    Sleep, 1500
    ToolTip
return

; ============================================
; CapsLock + X = Stop speaking
; ============================================
CapsLock & x::
    SetTitleMatchMode, 2
    IfWinExist, Nerve TTS
    {
        WinActivate
        Sleep, 100
        Send, {Escape}
    }
return

; ============================================
; Prevent CapsLock from toggling when used as modifier
; ============================================
CapsLock::return
