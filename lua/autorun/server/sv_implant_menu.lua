zc = zc or {}
util.AddNetworkString("zc_implant_set")
util.AddNetworkString("zc_implant_open_target")
util.AddNetworkString("zc_nl_boot")
PlayerInventory = PlayerInventory or {}

local NETVAR_IMPLANTS = (ZC_IMPLANTS and ZC_IMPLANTS.NETVAR_IMPLANTS) or {
    implant_neurolink_scrap        = true,
    implant_neurolink_diy          = true,
    implant_neurolink_blackmarket  = true,
    implant_neurolink_basic        = true,
    implant_neurolink_military     = true,
    implant_neurolink_militaryplus = true,
    implant_compass_1              = true,
    implant_compass_2              = true,
    implant_compass_3              = true,
    implant_cardiac_1              = true,
    implant_cardiac_2              = true,
    implant_cardiac_3              = true,
    implant_cardiac_4              = true,
    implant_cardiac_5              = true,
    implant_bloodfilter_1          = true,
    implant_bloodfilter_2          = true,
    implant_bloodfilter_3          = true,
    implant_bloodfilter_4          = true,
    implant_bloodfilter_5          = true,
    implant_bloodrefill_1          = true,
    implant_bloodrefill_2          = true,
    implant_bloodrefill_3          = true,
    implant_bloodrefill_4          = true,
    implant_bloodrefill_5          = true,
    implant_paindampener_1         = true,
    implant_paindampener_2         = true,
    implant_paindampener_3         = true,
    implant_paindampener_4         = true,
    implant_paindampener_5         = true,
    implant_subdermal_zeta         = true,
    implant_subdermal_osha         = true,
    implant_subdermal_arcom        = true,
    implant_temp                   = true,
    implant_adrenal                = true,
    implant_morphine               = true,
    implant_fury13                 = true,
    implant_fury16                 = true,
    implant_airjump_low            = true,
    implant_airjump_mid            = true,
    implant_airjump_high           = true,
    implant_airjump_black          = true,
    implant_dash_low               = true,
    implant_dash_2                 = true,
    implant_dash_high              = true,
    implant_dash_4                 = true,
    implant_dash_5                 = true,
    implant_chargejump_1           = true,
    implant_chargejump_2           = true,
    implant_chargejump_3           = true,
    implant_chargejump_4           = true,
    implant_chargejump_5           = true,
    implant_bone_lacing_1          = true,
    implant_bone_lacing_2          = true,
    implant_bone_lacing_3          = true,
    implant_bone_lacing_4          = true,
    implant_bone_lacing_5          = true,
    implant_kinetic_1              = true,
    implant_kinetic_2              = true,
    implant_kinetic_3              = true,
    implant_kinetic_4              = true,
    implant_kinetic_5              = true,
    implant_synth_lungs_1          = true,
    implant_synth_lungs_2          = true,
    implant_synth_lungs_3          = true,
    implant_synth_lungs_4          = true,
    implant_synth_lungs_5          = true,
    implant_nvg                    = true,
    implant_thermal                = true,
    implant_compass_scrap          = true,
    implant_compass_diy            = true,
    implant_compass_blackmarket    = true,
    implant_dash_scrap             = true,
    implant_dash_diy               = true,
    implant_dash_blackmarket       = true,
    implant_compass_scrap          = true,
    implant_compass_diy            = true,
    implant_compass_blackmarket    = true,
    implant_airjump_scrap          = true,
    implant_airjump_diy            = true,
    implant_airjump_blackmarket    = true,
    implant_subdermal_scrap        = true,
    implant_subdermal_diy          = true,
    implant_subdermal_blackmarket  = true,
    implant_chargejump_scrap       = true,
    implant_chargejump_diy         = true,
    implant_chargejump_blackmarket = true,
    implant_synth_lungs_scrap      = true,
    implant_synth_lungs_diy        = true,
    implant_synth_lungs_blackmarket = true,
    implant_mp3                    = true,
    implant_cyberdeck_basic        = true,
    implant_cyberdeck_advanced     = true,
    implant_cyberdeck_pro          = true,
}

function zc.SetImplant(ply, implant, value)
    -- nil / false both mean "off"
    local on = (value == true)
    local stored = on and true or nil

    -- Авторитетное состояние на сервере (SetNetVar/GetNetVar у HG часто не читается обратно на SV)
    ply.zc_implants = ply.zc_implants or {}
    if on then
        ply.zc_implants[implant] = true
    else
        ply.zc_implants[implant] = nil
    end

    if NETVAR_IMPLANTS[implant] then
        ply:SetNetVar(implant, stored)
    end

    local function pushOrganism()
        if not IsValid(ply) or not ply.organism then return end
        ply.organism[implant] = stored
    end

    pushOrganism()
    if on then
        for _, t in ipairs({ 0.01, 0.05, 0.1, 0.25, 0.5, 1, 2 }) do
            timer.Simple(t, pushOrganism)
        end
    end
end

hook.Add("Org Init", "zc_restore_implants_org", function(ply, org)
    if not ply.zc_implants then return end

    for implant, _ in pairs(ply.zc_implants) do
        org[implant] = true
    end
end)

net.Receive("zc_implant_set", function(len, sender)
    local target  = net.ReadEntity()
    local implant = net.ReadString()
    local value   = net.ReadBool()

    if not IsValid(target) or not target:IsPlayer() then return end

    local ripper = sender:GetNWBool("zc_ripperdoc")
    if not ripper and sender ~= target then
        sender:Notify("Only a ripperdoc can operate on another patient.", 2)
        return
    end

    -- Удаление импланта (value == false)
    if value == false then
        zc.SetImplant(target, implant, nil)
        net.Start("zc_nl_boot")
        net.Send(target)
        return
    end

    -- Риппер ставит мгновенно
    if ripper then
        zc.SetImplant(target, implant, true)
        net.Start("zc_nl_boot")
        net.Send(target)
        --sender:Notify("Implant installed (ripperdoc).", 2)
        return
    end

    -- Не-риппер: проверяем личный инвентарь
    local inv = PlayerInventory[sender:SteamID()] or {}
    local foundIndex
    for idx, item in ipairs(inv) do
        if item.type == "implant" and item.id == implant then
            foundIndex = idx
            break
        end
    end

    if not foundIndex then
        sender:Notify("You don't have this implant in your inventory.", 2)
        return
    end

    -- Шанс
    if math.random(100) <= 50 then
        -- Успех – удаляем предмет, ставим имплант, показываем загрузку
        table.remove(inv, foundIndex)
        PlayerInventory[sender:SteamID()] = inv
        net.Start("SyncInventory")
        net.WriteString(util.TableToJSON(inv))
        net.Send(sender)

        zc.SetImplant(target, implant, true)
        net.Start("zc_nl_boot")      -- экран загрузки
        net.Send(target)
        --sender:Notify("Implant installed successfully!", 2)
    else
        -- Не работаетxddd (должно не показывать загрузку при провале)
        local org = sender.organism
        if org then
            org.painadd = (org.painadd or 0) + 70
            org.bleed   = (org.bleed or 0) + 2
            org.blood   = math.max((org.blood or 5000) - 1000, 0)
            org.shock   = (org.shock or 0) + 15
            org.disorientation = math.min((org.disorientation or 0) + 10, 25)
        end
        sender:Notify("Installation FAILED!", 3)
    end
end)

hook.Add("KeyPress", "zc_ripperdoc_surgery", function(ply, key)
    if key ~= IN_RELOAD then return end

    local carryent = ply:GetNetVar("carryent")
    if not IsValid(carryent) or not carryent:IsRagdoll() then return end

    local target = hg.RagdollOwner(carryent)
    if not IsValid(target) or not target:IsPlayer() then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.CarryBone then return end
    local bone = carryent:GetBoneName(carryent:TranslatePhysBoneToBone(wep.CarryBone))
    if bone ~= "ValveBiped.Bip01_Spine2" and bone ~= "ValveBiped.Bip01_Spine1" then return end

    net.Start("zc_implant_open_target")
    net.WriteEntity(target)
    net.Send(ply)
end)

hook.Add("HG_PlayerSay", "zc_ripperdoc_class", function(ply, txtTbl, text)
    local clean = string.lower(string.Trim(text))
    if clean == "!ripperdoc" then
        if ply:GetNWBool("zc_ripperdoc", false) then
            ply:SetNWBool("zc_ripperdoc", false)
            ply:ChatPrint("Ripperdoc role removed.")
        else
            ply:SetNWBool("zc_ripperdoc", true)
            ply:ChatPrint("You are now a Ripperdoc.")
        end
        return ""
    end
end)