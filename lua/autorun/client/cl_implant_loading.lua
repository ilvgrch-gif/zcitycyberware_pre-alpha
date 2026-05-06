-- шрифты спизжены с зсити
surface.CreateFont("NL_OSLarge", {
    font = "Ari-W9500",
    size = ScreenScale(500),
    extended = true,
    weight = 400,
})

surface.CreateFont("NL_OSMedium", {
    font = "Ari-W9500",
    size = ScreenScale(10),
    extended = true,
    weight = 400,
})

surface.CreateFont("NL_OSSmall", {
    font = "Ari-W9500",
    size = ScreenScale(5),
    extended = true,
    weight = 400,
})

surface.CreateFont("NL_OSMatrix", {
    font = "Ari-W9500",
    size = ScreenScale(10),
    extended = true,
    weight = 400,
})

local cyan      = Color(0, 230, 230)
local cyandark  = Color(0, 40, 50)
local cyanfaint = Color(0, 120, 140)
local cyanglow  = Color(0, 255, 255)
local gradient_l = Material("vgui/gradient-l")

local sw, sh = ScrW(), ScrH()

local PANEL = {}

local BootStages = {
    [1] = {"UNREGISTERED IMPLANT"},
    [2] = {"UNREGISTERED IMPLANT", "Initializing neural bridge..."},
    [3] = {"UNREGISTERED IMPLANT", "Initializing neural bridge...", "HARDWARE INTEGRITY CHECK:"},
    [4] = {
        "UNREGISTERED IMPLANT",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
    },
    [5] = {
        "UNREGISTERED IMPLANT",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ MODULE NOT FOUND",
        "  CYBERIMPLANT OUT ............ MODULE NOT FOUND",
    },
    [6] = {
        "IMPLANT REGISTERED",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ MODULE NOT FOUND",
        "  CYBERIMPLANT OUT ............ MODULE NOT FOUND",
        "Memory scan .................. COMPLETE",
    },
    [7] = {
        "IMPLANT REGISTERED",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ MODULE NOT FOUND",
        "  CYBERIMPLANT OUT ............ MODULE NOT FOUND",
        "Memory scan .................. COMPLETE",
        "Implant calibration .......... IN PROGRESS",
    },
    [8] = {
        "IMPLANT REGISTERED",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ LINK ESTABLISHED",
        "  CYBERIMPLANT OUT ............ LINK ESTABLISHED",
        "Memory scan .................. COMPLETE",
        "Implant calibration .......... COMPLETE",
    },
    [9] = {
        "IMPLANT REGISTERED",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ LINK ESTABLISHED",
        "  CYBERIMPLANT OUT ............ LINK ESTABLISHED",
        "Memory scan .................. COMPLETE",
        "Implant calibration .......... COMPLETE",
        "Binding organism table ...",
    },
    [10] = {
        "INITIALIZING",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ LINK ESTABLISHED",
        "  CYBERIMPLANT OUT ............ LINK ESTABLISHED",
        "Memory scan .................. COMPLETE",
        "Implant calibration .......... COMPLETE",
        "Binding organism table ...",
        "echo \"INSTALLATION FINISHED\"", --????чеэто
    },
}

function PANEL:Init()
    system.FlashWindow()

    sound.PlayFile("sound/zbattle/startup2.ogg", "", function() end)
    sound.PlayFile("sound/zbattle/startup_scan.ogg", "", function() end)
    timer.Simple(4.4, function()
    sound.PlayFile("sound/zbattle/scan_flash.ogg", "", function() end)
    end)

    self.progress   = 0
    self.alpha      = 255
    self.alphagrid  = 255
    self.blur       = 5
    self.done       = false
    self.flash      = 0
    self.initAnim   = 0
    self.initAnim2  = 0
    self.haveanicedayalpha = 0
    self.BootStage  = 1

    self:SetSize(sw, sh)
    self:RequestFocus()

    if IsValid(hg.implantload) then hg.implantload:Remove() end
    hg.implantload = self

    self:CreateAnimation(2.5, {
        index = 5,
        target = { blur = 0 },
        easing = "linear",
        bIgnoreConfig = true,
    })

    timer.Simple(2, function()
        if not IsValid(self) then return end
        self:CreateAnimation(0.5, {
            index = 10,
            target = { progress = math.Rand(0.01, 0.1) },
            easing = "outQuint",
            bIgnoreConfig = true,
            OnComplete = function()
                self:CreateAnimation(1.5, {
                    index = 11,
                    target = { progress = math.Rand(0.6, 0.9) },
                    easing = "linear",
                    bIgnoreConfig = true,
                    OnComplete = function()
                        self:CreateAnimation(1, {
                            index = 12,
                            target = { progress = 1 },
                            easing = "outQuint",
                            bIgnoreConfig = true,
                            OnComplete = function()
                                timer.Simple(0.5, function()
                                    if IsValid(self) then self:Close() end
                                end)
                            end
                        })
                    end
                })
            end
        })
    end)

    -- init animations
    self:CreateAnimation(1, {
        index = 20,
        target = { initAnim = 1 },
        easing = "linear",
        bIgnoreConfig = true,
        OnComplete = function()
            self:CreateAnimation(10, {
                index = 21,
                target = { initAnim2 = 1 },
                easing = "linear",
                bIgnoreConfig = true,
            })
        end
    })

    --спизжено с кода фурри с зсити да
    local BootTimes = { 1, 2, 2.2, 2.5, 2.7, 4.2, 4.3, 4.9, 6.2, 6.5 }
    for k, v in ipairs(BootTimes) do
        timer.Simple(v, function()
            if IsValid(self) then self.BootStage = k end
        end)
    end

    self.matrixX      = 80
    self.matrixY      = 42 + 10
    self.CursorLength = 10

    self.TextArray = {}
    self.RandomAlpha = {}
    self.RandomFlash = {}
    self.RandomDelay = {}

    for x = 1, self.matrixX do
        self.RandomDelay[x] = RealTime() + 3 + math.Rand(0, 0.1)
        self.TextArray[x]   = {}
        self.RandomAlpha[x] = {}
        self.RandomFlash[x] = {}
        for y = 1, self.matrixY do
            self.TextArray[x][y]   = math.random(0, 2) == 2 and "1" or "0"
            self.RandomAlpha[x][y] = math.Rand(0.5, 1)
            self.RandomFlash[x][y] = math.random(1, 10) == 1 or nil
        end
    end

    timer.Simple(4.9, function()
        if not IsValid(self) then return end
        self.flash = 1
        for x = 1, self.matrixX do
            for y = 1, self.matrixY do
                if self.RandomFlash[x][y] then
                    self.TextArray[x][y] = self.TextArray[x][y] == "0" and "1" or "0"
                end
            end
        end
        self:CreateAnimation(2, {
            index = 40,
            target = { flash = 0 },
            easing = "outQuint",
            bIgnoreConfig = true
        })
    end)
end

function PANEL:Close()

    sound.PlayFile("sound/zbattle/login.wav", "", function() end)

    self.done = true
    self.alpha = 255
    self.haveanicedayalpha = 255

    timer.Simple(1, function()
        if not IsValid(self) then return end
        self:CreateAnimation(1, {
            index = 2,
            target = { alpha = 0 },
            easing = "linear",
            bIgnoreConfig = true,
            Think = function() self:SetAlpha(self.alpha) end,
            OnComplete = function()
                self:CreateAnimation(5, {
                    index = 4,
                    target = { haveanicedayalpha = 0 },
                    easing = "outQuint",
                    bIgnoreConfig = true,
                    Think = function() self:SetAlpha(self.alpha) end,
                    OnComplete = function() self:Remove() end
                })
            end
        })
    end)

    self:CreateAnimation(1, {
        index = 3,
        target = { alphagrid = 0 },
        easing = "linear",
        bIgnoreConfig = true,
    })
end

function PANEL:DrawMatrix()
    local init2          = self.initAnim2
    local BootUpProgress = self.progress
    local MatrixCursorPos = math.Round((1 - BootUpProgress) * (self.matrixY + 1))

    if self.alpha <= 0 then return end

    for x = 1, self.matrixX do
        for y = 1, self.matrixY do
            local posX = sw / self.matrixX * (x - 1)
            local posY = sh / (self.matrixY - self.CursorLength) * ((y - self.CursorLength) - 1)

            if posY > sh or posY < 0 then continue end

            local alpha = init2 * self.RandomAlpha[x][y]
            local pos   = MatrixCursorPos

            if y == pos then
                draw.GlowingText(self.TextArray[x][y], "NL_OSMatrix", posX, posY,
                    ColorAlpha(cyan, alpha * 255),
                    ColorAlpha(cyandark, alpha * 255),
                    ColorAlpha(cyanfaint, alpha * 255))
            else
                local color
               if y < pos then
                    color = ColorAlpha(cyandark, 8 * alpha)
               else
                 color = ColorAlpha(cyan, math.Clamp(180 - ((y - pos) * (180 / self.CursorLength)), 8, 180) * alpha)
            end
                draw.SimpleText(self.TextArray[x][y], "NL_OSMatrix", posX, posY, color)
            end

            if self.flash >= 0 and self.RandomFlash[x][y] then
                draw.GlowingText("▓", "NL_OSMatrix", posX, posY + ScreenScale(3),
                    ColorAlpha(cyan, self.flash * alpha * 255),
                    ColorAlpha(cyandark, self.flash * alpha * 255),
                    ColorAlpha(cyanfaint, self.flash * alpha * 255))
            end
        end
    end
end

function PANEL:Paint()
    local BootUpProgress = self.progress
    local init           = self.initAnim
    local init2          = self.initAnim2 * 10

    surface.SetDrawColor(0, 0, 0, init * 255)
    surface.DrawRect(-10, -10, sw + 10, sh + 10)

    local xbars, ybars = 17, 30
    surface.SetDrawColor(0, 180, 200, 0.6 * self.alphagrid / 255)
    for i = 1, ybars + 1 do
        surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
    end
    for i = 1, xbars + 1 do
        surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
    end

    self:DrawMatrix()

    local text = "Scanning..."
    local trim = 12 + (math.Round(CurTime()) % 3)
    text = string.Left(text, trim)

    -- rainbow shimmer layer like the furry OwOS
    local rainbow = HSVToColor(CurTime() * 50 % 360, 0.6, 0.9)
    draw.GlowingText("NEUROLINK", "NL_OSLarge",
    sw * 0.5 + ScreenScale(1), sh * 0.3 + ScreenScale(1),
    ColorAlpha(rainbow, 80 * init2),
    ColorAlpha(rainbow, 10 * init2),
    ColorAlpha(rainbow, 2 * init2),
    TEXT_ALIGN_CENTER)
    draw.GlowingText("NEUROLINK", "NL_OSLarge",
    sw * 0.5, sh * 0.3,
    ColorAlpha(cyanglow, 255 * init2),
    ColorAlpha(cyan, 200 * init2),
    ColorAlpha(cyandark, 80 * init2),
    TEXT_ALIGN_CENTER)

    draw.GlowingText(text, "NL_OSMedium",
        sw * 0.4, sh * 0.485,
        ColorAlpha(cyan, 255 * init2),
        ColorAlpha(cyandark, 50 * init2),
        ColorAlpha(cyanfaint, 10 * init2))

    -- percentage
    draw.GlowingText(math.Round(BootUpProgress * 100) .. "%", "NL_OSSmall",
        sw * 0.6, sh * 0.5,
        ColorAlpha(cyan, 255 * init2),
        ColorAlpha(cyandark, 50 * init2),
        ColorAlpha(cyanfaint, 10 * init2),
        TEXT_ALIGN_RIGHT)

    -- progress bar
    surface.SetDrawColor(ColorAlpha(color_black, 100 * init2))
    surface.DrawRect(sw * 0.4, sh * 0.52, sw * 0.2, sh * 0.02)

    surface.SetDrawColor(ColorAlpha(cyan, 255 * init2))
    surface.DrawRect(sw * 0.4, sh * 0.52, sw * 0.2 * BootUpProgress, sh * 0.02)

    surface.SetDrawColor(0, 200, 220, 255 * init2)
    surface.SetMaterial(gradient_l)
    surface.DrawTexturedRect(sw * 0.4, sh * 0.52, sw * 0.2 * BootUpProgress, sh * 0.02)

    surface.SetDrawColor(ColorAlpha(cyan, 255 * init2))
    surface.DrawOutlinedRect(sw * 0.4 - 5, sh * 0.52 - 5, sw * 0.2 + 10, sh * 0.02 + 10)

    local stages = BootStages[self.BootStage] or BootStages[1]
    for i, line in ipairs(stages) do
        draw.SimpleText(line, "NL_OSSmall",
            sw * 0.012,
            sh * 0.05 + (i - 1) * ScreenScale(5),
            ColorAlpha(cyan, 255 * init2),
            TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

local pp_tab = {
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"]   = 1,
}

hook.Add("RenderScreenspaceEffects", "implantload_pp", function()
    if IsValid(hg.implantload) and hg.implantload.alpha ~= 255 then
        pp_tab["$pp_colour_brightness"] = hg.implantload.alpha / 255
        DrawColorModify(pp_tab)

        local alpha = hg.implantload.haveanicedayalpha
        draw.SimpleText("INSTALLATION COMPLETE.", "NL_OSMedium",
            sw * 0.5 + 2, sh * 0.8 + 2,
            ColorAlpha(color_black, 255 * alpha),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("INSTALLATION COMPLETE.", "NL_OSMedium",
            sw * 0.5, sh * 0.8,
            ColorAlpha(cyan, 255 * alpha),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)

vgui.Register("ZC_ImplantLoading", PANEL, "EditablePanel")

hook.Add("HUDPaint", "Neurolink_ChargeJumpBar", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply.chargestart then return end
    
    local hasNeurolink = ply:GetNetVar("implant_neurolink_basic") or 
                         ply:GetNetVar("implant_neurolink_military") or 
                         ply:GetNetVar("implant_neurolink_militaryplus")
    if not hasNeurolink then return end
    
    local chargeTime = CurTime() - ply.chargestart
    local maxCharge = 3.0
    local progress = math.Clamp(chargeTime / maxCharge, 0, 1)
    
    local barW = ScrW() * 0.3
    local barH = ScreenScale(4)
    local barX = ScrW() * 0.5 - barW * 0.5
    local barY = ScrH() * 0.85
    
    -- Background
    draw.RoundedBox(2, barX, barY, barW, barH, Color(20, 5, 8, 200))
    
    -- Progress
    local fillColor = progress >= 1 and Color(255, 180, 20, 255) or Color(255, 40, 60, 255)
    draw.RoundedBox(2, barX, barY, barW * progress, barH, fillColor)
    
    -- Border
    surface.SetDrawColor(255, 40, 60, 150)
    surface.DrawRect(barX, barY, barW, 1)
    surface.DrawRect(barX, barY + barH, barW, 1)
    
    -- Label
    if progress > 0.1 then
        draw.DrawText("CHARGING", "NL_Menu_Tiny", barX + barW * 0.5, barY - ScreenScale(6),
            Color(255, 100, 100, 200), TEXT_ALIGN_CENTER)
    end
end)

print("[ZC CYBERWARE] implant loading screen loaded")