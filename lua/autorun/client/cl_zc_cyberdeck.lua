if SERVER then return end

local currentTarget = nil
local qteActive = false
local qteData = nil
local cyberdeckScannerActive = false
local menuAlpha = 0
local menuSlideX = -300

-- дебаг debug
local CYBERDECK_DEBUG = true
local function DebugPrint(...)
    if CYBERDECK_DEBUG then
        print("[Cyberdeck]", ...)
    end
end

-- reboot optics не тестилось и скорее всего не работает
net.Receive("ZC_RebootOptics", function()
    DebugPrint("Received RebootOptics effect")
    local glitch_dur = net.ReadFloat()
    local blind_dur = net.ReadFloat()
    
    local glitch_end = CurTime() + glitch_dur
    local blind_end = CurTime() + blind_dur
    
    hook.Add("RenderScreenspaceEffects", "cyberdeck_reboot_glitch", function()
        if CurTime() > glitch_end then
            hook.Remove("RenderScreenspaceEffects", "cyberdeck_reboot_glitch")
            return
        end
        
        DrawColorModify({
            ["$pp_colour_addr"] = math.sin(CurTime() * 20) * 0.02,
            ["$pp_colour_addg"] = math.cos(CurTime() * 23) * 0.02,
            ["$pp_colour_addb"] = math.sin(CurTime() * 17) * 0.02,
            ["$pp_colour_brightness"] = -0.1,
            ["$pp_colour_contrast"] = 1.3,
            ["$pp_colour_colour"] = 0.7,
        })
        
        if math.random(1, 15) == 1 then
            local x, y = math.random(100, ScrW() - 100), math.random(100, ScrH() - 100)
            draw.SimpleText("ERROR", "NL_Menu_Tiny", x, y, Color(255, 0, 0, 200), TEXT_ALIGN_CENTER)
        end
    end)
    
    if blind_dur > 0 then
        hook.Add("RenderScreenspaceEffects", "cyberdeck_reboot_blind", function()
            if CurTime() > blind_end then
                hook.Remove("RenderScreenspaceEffects", "cyberdeck_reboot_blind")
                return
            end
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end)
    end
end)

-- QTE / по сути должно работать не тестилось
net.Receive("ZC_QTE_Start", function()
    DebugPrint("Received QTE_Start")
    local qte_id = net.ReadString()
    local qte_type = net.ReadString()
    local qte_time = net.ReadFloat()
    local is_my_turn = net.ReadBool()
    
    qteActive = true
    qteData = {
        id = qte_id,
        type = qte_type,
        time_left = qte_time,
        total_time = qte_time,
        is_my_turn = is_my_turn,
        button_pressed = false
    }
    
    surface.PlaySound("buttons/button15.wav")
end)

net.Receive("ZC_QTE_Result", function()
    DebugPrint("Received QTE_Result")
    local qte_id = net.ReadString()
    local failed_ply = net.ReadEntity()
    local result_type = net.ReadString()
    
    qteActive = false
    qteData = nil
    
    if result_type == "cyberpsychosis" then
        surface.PlaySound("zcity_implants/psycho_music.mp3")
    elseif result_type == "suicide_target" then
        surface.PlaySound("buttons/blip1.wav")
    elseif result_type == "suicide_hacker" then
        surface.PlaySound("physics/glass/glass_sheet_break3.wav")
    end
end)

net.Receive("ZC_QuickhackCast", function()
    DebugPrint("Received QuickhackCast")
    local hacker = net.ReadEntity()
    local target = net.ReadEntity()
    local hack_type = net.ReadString()
    
    if hacker == LocalPlayer() then return end
    
    local angle = 0
    hook.Add("HUDPaint", "cyberdeck_cast_indicator", function()
        if not IsValid(target) then
            hook.Remove("HUDPaint", "cyberdeck_cast_indicator")
            return
        end
        
        local scr = target:GetPos():ToScreen()
        if not scr.visible then return end
        
        angle = angle + 0.15
        local radius = 30 + math.sin(angle) * 5
        
        for i = 0, 360, 30 do
            local rad = math.rad(i + angle * 20)
            local x = scr.x + math.cos(rad) * radius
            local y = scr.y + math.sin(rad) * radius
            surface.SetDrawColor(255, 50, 50, 200)
            surface.DrawRect(x - 2, y - 2, 4, 4)
        end
        
        draw.SimpleText("HACKED", "NL_Menu_Tiny", scr.x, scr.y - 40, Color(255, 50, 50, 255), TEXT_ALIGN_CENTER)
    end)
end)

-- кибердека
local function CanUseCyberdeck()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return false end
    
    local has_optics = ply:GetNetVar("implant_neurolink_military") or 
                       ply:GetNetVar("implant_neurolink_militaryplus") or
                       ply:GetNetVar("implant_neurolink_blackmarket")
    
    local has_deck = ply:GetNetVar("implant_cyberdeck_basic") or 
                     ply:GetNetVar("implant_cyberdeck_advanced") or
                     ply:GetNetVar("implant_cyberdeck_pro")
    
    return has_optics and has_deck
end

-- описания
local QUICKHACKS = {
    { id = "short_circuit", name = "SHORT CIRCUIT", desc = "DAMAGE + STUN", cmd = "cyberdeck_short_circuit" },
    { id = "synapse_burnout", name = "SYNAPSE BURNOUT", desc = "HEAD DMG + FIRE", cmd = "cyberdeck_synapse_burnout" },
    { id = "cyberware_shutoff", name = "CYBERWARE SHUT-OFF", desc = "DISABLE IMPLANTS", cmd = "cyberdeck_cyberware_shutoff" },
    { id = "reboot_optics", name = "REBOOT OPTICS", desc = "GLITCH + BLIND", cmd = "cyberdeck_reboot_optics" },
    { id = "cyberpsychosis", name = "CYBERPSYCHOSIS", desc = "QTE - PSYCHOSIS", cmd = "cyberdeck_cyberpsychosis" },
    { id = "suicide", name = "SUICIDE", desc = "QTE - DEATH", cmd = "cyberdeck_suicide" }
}

-- регистр команд
for i, hack in ipairs(QUICKHACKS) do
    concommand.Add(hack.cmd, function(ply, cmd, args)
        DebugPrint("Command executed:", hack.cmd)
        
        if not CanUseCyberdeck() then
            DebugPrint("Cannot use cyberdeck - missing implants")
            return
        end
        if not cyberdeckScannerActive then
            DebugPrint("Scanner not active")
            return
        end
        if not currentTarget then
            DebugPrint("No target selected")
            return
        end
        if qteActive then
            DebugPrint("QTE active, blocking")
            return
        end
        
        DebugPrint("Sending quickhack:", hack.id, "to target:", currentTarget)
        
        net.Start("ZC_QuickhackCast")
            net.WriteEntity(currentTarget)
            net.WriteString(hack.id)
        net.SendToServer()
        
        -- кд
        local cooldown_key = "cyberdeck_cooldown_" .. hack.id
        LocalPlayer()[cooldown_key] = CurTime() + 10
        LocalPlayer()[cooldown_key .. "_start"] = CurTime()
    end)
end

-- меню хаков
local function DrawQuickhackMenu()
    if not cyberdeckScannerActive then return end
    if not CanUseCyberdeck() then return end
    if qteActive then return end
    
    local ply = LocalPlayer()
    local trace = ply:GetEyeTrace()
    local ent = trace.Entity
    
    if not IsValid(ent) or (not ent:IsPlayer() and not ent:IsNPC()) then
        currentTarget = nil
        menuAlpha = math.max(0, menuAlpha - FrameTime() * 500)
        menuSlideX = math.max(-300, menuSlideX - FrameTime() * 800)
        return
    end
    
    if not ent:Alive() then
        currentTarget = nil
        menuAlpha = math.max(0, menuAlpha - FrameTime() * 500)
        menuSlideX = math.max(-300, menuSlideX - FrameTime() * 800)
        return
    end
    
    local dist = ply:GetPos():Distance(ent:GetPos())
    if dist > 1500 then
        currentTarget = nil
        menuAlpha = math.max(0, menuAlpha - FrameTime() * 500)
        menuSlideX = math.max(-300, menuSlideX - FrameTime() * 800)
        return
    end
    
    currentTarget = ent
    
    -- анимация
    menuAlpha = math.min(255, menuAlpha + FrameTime() * 800)
    menuSlideX = math.min(0, menuSlideX + FrameTime() * 800)
    
    local baseX = ScrW() * 0.05
    local x = baseX + menuSlideX
    local y = ScrH() * 0.25
    local btn_w = 280
    local btn_h = 45
    local spacing = 4
    local num_hacks = #QUICKHACKS
    local totalH = (btn_h + spacing) * num_hacks
    
    local alpha = menuAlpha / 255
    
    -- глитчи
    local glitchX = 0
    if math.random(1, 20) == 1 then
        glitchX = math.Rand(-3, 3)
    end
    
    --меню
    draw.RoundedBox(4, x + glitchX - 5, y - 5, btn_w + 10, totalH + 10, Color(15, 5, 5, 220 * alpha))
    surface.SetDrawColor(255, 50, 50, 200 * alpha)
    surface.DrawRect(x + glitchX - 5, y - 5, btn_w + 10, 2)
    draw.SimpleText("QUICKHACKS", "NL_Menu_Title", x + glitchX + btn_w/2, y - 3, Color(255, 80, 80, 255 * alpha), TEXT_ALIGN_CENTER)
    local target_name = ent:IsPlayer() and ent:Nick() or ent:GetClass()
    draw.SimpleText("TARGET: " .. target_name, "NL_Menu_Tiny", x + glitchX + btn_w/2, y + 18, Color(200, 80, 80, 200 * alpha), TEXT_ALIGN_CENTER)
    for i, hack_data in ipairs(QUICKHACKS) do
        local btn_x = x + glitchX
        local btn_y = y + 45 + (btn_h + spacing) * (i - 1)
        local cooldown_key = "cyberdeck_cooldown_" .. hack_data.id
        local cooldown_end = ply[cooldown_key] or 0
        local on_cooldown = cooldown_end > CurTime()
        local cooldown_pct = 0
        if on_cooldown then
            local cooldown_start = ply[cooldown_key .. "_start"] or (cooldown_end - 10)
            cooldown_pct = (cooldown_end - CurTime()) / (cooldown_end - cooldown_start)
            cooldown_pct = math.Clamp(cooldown_pct, 0, 1)
        end
        local bg_color = on_cooldown and Color(40, 20, 20, 180 * alpha) or Color(25, 10, 10, 180 * alpha)
        draw.RoundedBox(2, btn_x, btn_y, btn_w, btn_h, bg_color)
        
        if on_cooldown then
            draw.RoundedBox(2, btn_x, btn_y, btn_w * cooldown_pct, btn_h, Color(0, 0, 0, 100))
        end -- я заебался это делать полоска двигается xdddd lmaooooo
        
        local name_color = on_cooldown and Color(120, 60, 60, 200 * alpha) or Color(255, 100, 100, 255 * alpha)
        draw.SimpleText(hack_data.name, "NL_Menu_Sub", btn_x + 8, btn_y + btn_h/2 - 1, name_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        local desc_color = on_cooldown and Color(80, 40, 40, 150 * alpha) or Color(200, 80, 80, 180 * alpha)
        draw.SimpleText(hack_data.desc, "NL_Menu_Tiny", btn_x + btn_w - 8, btn_y + btn_h/2 + 1, desc_color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    -- глитчи помехи глитчии
    if math.random(1, 10) == 1 and alpha > 0.5 then
        local lineY = y + math.random(0, totalH)
        surface.SetDrawColor(255, 50, 50, 100 * alpha)
        surface.DrawRect(x + glitchX, lineY, btn_w, 1)
    end
end

-- QTE -- неработает не тестилось
local function DrawQTE()
    if not qteActive or not qteData then return end
    
    local x = ScrW() * 0.5
    local y = ScrH() * 0.6
    local bar_width = 400
    local bar_height = 25
    
    local pct = qteData.time_left / qteData.total_time
    local current_width = bar_width * pct
    
    draw.RoundedBox(4, x - bar_width/2 - 3, y - bar_height/2 - 3, bar_width + 6, bar_height + 6, Color(0, 0, 0, 200))
    draw.RoundedBox(2, x - bar_width/2, y - bar_height/2, bar_width, bar_height, Color(40, 10, 10, 255))
    
    local bar_color
    if pct > 0.5 then
        bar_color = Color(255, 50, 50, 255)
    elseif pct > 0.25 then
        bar_color = Color(255, 100, 50, 255)
    else
        bar_color = Color(255, 200, 50, 255)
    end
    
    draw.RoundedBox(2, x - bar_width/2, y - bar_height/2, current_width, bar_height, bar_color)
    
    local status_text = qteData.is_my_turn and "PRESS [E] NOW!" or "WAIT..."
    local status_color = qteData.is_my_turn and Color(255, 255, 255, 255) or Color(150, 150, 150, 200)
    
    draw.SimpleText(status_text, "NL_Menu_Sub", x, y - 35, status_color, TEXT_ALIGN_CENTER)
    
    local type_text = qteData.type == "cyberpsychosis" and "CYBERPSYCHOSIS" or "SUICIDE PROTOCOL"
    draw.SimpleText(type_text, "NL_Menu_Tiny", x, y + 22, Color(255, 100, 100, 200), TEXT_ALIGN_CENTER)
    
    local pulse = math.sin(CurTime() * 10) * 20 + 30
    surface.SetDrawColor(255, 100, 100, pulse)
    surface.DrawOutlinedRect(x - bar_width/2 - 2, y - bar_height/2 - 2, bar_width + 4, bar_height + 4, 2)
end

-- кте инпут
local function HandleQTEInput()
    if not qteActive or not qteData then return end
    
    if qteData.is_my_turn and not qteData.button_pressed then
        qteData.button_pressed = true
        
        net.Start("ZC_QTE_Input")
            net.WriteString(qteData.id)
            net.WriteBool(true)
        net.SendToServer()
    end
end

-- худ
hook.Add("HUDPaint", "cyberdeck_quickhack_menu", function()
    DrawQuickhackMenu()
    DrawQTE()
end)

-- QTE E key
hook.Add("KeyPress", "cyberdeck_qte_e", function(ply, key)
    if key == KEY_E then
        HandleQTEInput()
    end
end)

concommand.Add("cyberdeck_toggle", function()              --заглушка дебильная я не знаю как еще чтоб эроров не было :sad_face: help
    cyberdeckScannerActive = not cyberdeckScannerActive
    DebugPrint("Scanner toggled:", cyberdeckScannerActive)
    if cyberdeckScannerActive then
        surface.PlaySound("buttons/button15.wav")
    else
        menuAlpha = 0
        menuSlideX = -300
        currentTarget = nil
    end
end)

-- Debug command to check status 
concommand.Add("cyberdeck_status", function()
    local ply = LocalPlayer()
    print("=== CYBERDECK STATUS ===")
    print("Scanner Active:", cyberdeckScannerActive)
    print("Can Use:", CanUseCyberdeck())
    print("Has Military Optics:", ply:GetNetVar("implant_neurolink_military") or ply:GetNetVar("implant_neurolink_militaryplus"))
    print("Has Deck Basic:", ply:GetNetVar("implant_cyberdeck_basic"))
    print("Has Deck Advanced:", ply:GetNetVar("implant_cyberdeck_advanced"))
    print("Has Deck Pro:", ply:GetNetVar("implant_cyberdeck_pro"))
    print("Current Target:", currentTarget and currentTarget or "None")
    print("========================")
end)

print("[ZС Cyberware] Cyberdeck client module loaded")
print("[ZC Cyberware] Use 'cyberdeck_status' in console to debug")
