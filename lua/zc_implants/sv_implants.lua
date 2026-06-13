zc = zc or {}
include("sh_rasta_sys.lua")
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

-- =====================================================
-- Исходник: sv_inventory.lua
-- =====================================================
net.Receive("SellImplant", function(len, ply)
    local index = net.ReadUInt(8)
    local inv = PlayerInventory[ply:SteamID()] or {}
    local item = inv[index]
    if not item then
        ply:Notify("Invalid item.", 2)
        return
    end

    local price = 0
    if item.type == "implant" then
        price = IMPLANT_PRICES[item.id] or 100  -- если нет цены, продаём за 100
    else
        price = ORGAN_PRICES[item.id] or 80     -- для органов – фиксированная или 80 по умолчанию
    end

    table.remove(inv, index)
    PlayerInventory[ply:SteamID()] = inv
    net.Start("SyncInventory")
    net.WriteString(util.TableToJSON(inv))
    net.Send(ply)

    local wallet = tonumber(ply:GetNWString("WalletMoney") or "0") or 0
    ply:SetNWString("WalletMoney", tostring(wallet + price))
    ply:Notify("Sold " .. item.name .. " for $" .. price .. ".", 2)
end)

net.Receive("BlackMarketBuy", function(len, ply)
    print("SERVER: BlackMarketBuy from", ply:Nick())
    local class = net.ReadString()
    local name = net.ReadString()
    local price = net.ReadFloat()

    local wallet = tonumber(ply:GetNWString("WalletMoney") or "0") or 0
    if wallet < price then
        ply:Notify("Not enough money!", 2)
        return
    end
    ply:SetNWString("WalletMoney", tostring(wallet - price))

    AddToInventory(ply, {
        type = class:find("harvest_") and "organ" or "implant",
        id = class,
        name = name,
        timestamp = os.time()
    })
    ply:Notify("Purchased " .. name .. " – added to inventory.", 2)
end)

function AddToInventory(ply, item)
    local inv = PlayerInventory[ply:SteamID()] or {}
    table.insert(inv, item)
    PlayerInventory[ply:SteamID()] = inv
    net.Start("SyncInventory")
    net.WriteString(util.TableToJSON(inv))
    net.Send(ply)
end


util.AddNetworkString("HarvestImplant")
util.AddNetworkString("HarvestOrgan")
util.AddNetworkString("NeurolinkCrack")
util.AddNetworkString("DropImplant")
util.AddNetworkString("zc_nl_boot_fail")
util.AddNetworkString("SyncInventory")
util.AddNetworkString("RequestInventory")
util.AddNetworkString("AddToInventory")
util.AddNetworkString("BlackMarketBuy")
util.AddNetworkString("implant_fx")



_G.ImplantConCommands = _G.ImplantConCommands or {}

local plyMeta = FindMetaTable("Player")
plyMeta.implantInstances = plyMeta.implantInstances or {}

function plyMeta:InitializeImplantSystems()
    self.implantInstances = self.implantInstances or {}
    self.modifiers = self.modifiers or ModifierContainer:New()
    self.abilitySystem = self.abilitySystem or AbilitySystem:New(self)
end

hook.Add("PlayerInitialSpawn", "implants_init", function(ply)
    ply:InitializeImplantSystems()
end)

hook.Add("Org Think", "ZC_Implants_Think", function(owner, org, dt)
    if not owner:IsPlayer() or not owner:Alive() then return end
    owner:InitializeImplantSystems() 
    owner.modifiers:ApplyToOrganism(org)
    for id, inst in pairs(owner.implantInstances) do
        if inst.template.onThink then
            inst.template.onThink(owner, org, dt, inst.state)
        end
    end

    local healRate = owner.modifiers.modifiers["bone_lacing"] and owner.modifiers.modifiers["bone_lacing"].boneHealRate
    if healRate then
        for _, bone in ipairs({"rarm","larm","rleg","lleg","chest","skull","pelvis"}) do
            if org[bone] then org[bone] = math.max(org[bone] - dt * healRate, 0) end
        end
        local imm = owner.modifiers.modifiers["bone_lacing"] and owner.modifiers.modifiers["bone_lacing"].dislocationImmunity
        if imm then
            for part, _ in pairs(imm) do
                org[part.."dislocation"] = false
            end
        end
    end

    local hasNeurolink = false
    for _, inst in pairs(owner.implantInstances) do
        if inst.template.neurolink then hasNeurolink = true break end
    end
    if hasNeurolink then
        local lastSkull = owner._lastSkull or 0
        if org.skull > lastSkull and org.skull > 0.1 then
            net.Start("NeurolinkCrack")
            net.WriteFloat(math.Clamp(org.skull*2, 0.05, 0.5))
            net.Send(owner)
        end
        owner._lastSkull = org.skull
    end
end)

hook.Add("PreTraceOrganBulletDamage", "ZC_Implants_Damage", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
    local owner = org.owner
    if not IsValid(owner) or not owner.implantInstances then return end
    for _, inst in pairs(owner.implantInstances) do
        if inst.template.onDamage then
            inst.template.onDamage(org, dmgInfo, hook_info, inst.state)
        end
    end
end)

hook.Add("KeyPress", "ZC_Implants_KeyPress", function(ply, key)
    if not ply.abilitySystem then return end
    ply.abilitySystem:OnKeyPress(key)
end)

hook.Add("KeyRelease", "ZC_Implants_KeyRelease", function(ply, key)
    if not ply.abilitySystem then return end
    ply.abilitySystem:OnKeyRelease(key)
end)

hook.Add("SetupMove", "ZC_Implants_SuppressJump", function(ply, mv)
    if ply.abilitySystem then ply.abilitySystem:SuppressJump(mv) end
end)

hook.Add("OnPlayerHitGround", "ZC_Implants_FallProtection", function(ply, inwater, onfloater, speed)
    if ply:GetActiveAbilityTierData("airjump") and ply:GetActiveAbilityTierData("airjump").fallImmunity then
        return true
    end
end)
hook.Add("GetFallDamage", "ZC_Implants_NoFallDmg", function(ply, speed)
    if ply:GetActiveAbilityTierData("airjump") and ply:GetActiveAbilityTierData("airjump").fallImmunity then
        return 0
    end
end)


net.Receive("HarvestOrgan", function(len, ply)
    local target = net.ReadEntity()
    local organID = net.ReadString()
    if not IsValid(target) or not target:IsPlayer() then return end
    if not target.organism then return end
    local org = target.organism

    if organID == "larm" then org.larmamputated = true
    elseif organID == "rarm" then org.rarmamputated = true
    elseif organID == "lleg" then org.llegamputated = true
    elseif organID == "rleg" then org.rlegamputated = true
    elseif organID == "skull" or organID == "brain" then org.headamputated = true
    end

    org[organID] = 1
    org.bleed = 2
    org.blood = 2000
    org.painadd = 80

    if hg.organism.Vomit then hg.organism.Vomit(target) end

    org.harvestedOrgans = org.harvestedOrgans or {}
    org.harvestedOrgans[organID] = true

    AddToInventory(ply, {
        type = "organ",
        id = organID,
        name = organID:gsub("_", " "):upper(),
        timestamp = os.time()
    })

    ply:Notify("Extracted " .. organID, 2)
end)

net.Receive("HarvestImplant", function(len, ply)
    local target = net.ReadEntity()
    local implantID = net.ReadString()
    if not IsValid(target) or not target:IsPlayer() then return end
    if not target.organism then return end

    if zc and zc.SetImplant then
        zc.SetImplant(target, implantID, nil)
    else
        target.organism[implantID] = nil
        target:SetNetVar(implantID, nil)
        if target.zc_implants then target.zc_implants[implantID] = nil end
    end

    local org = target.organism
    org.painadd = (org.painadd or 0) + 40
    org.bleed = (org.bleed or 0) + 0.5

    AddToInventory(ply, {
        type = "implant",
        id = implantID,
        name = implantID:gsub("implant_", ""):gsub("_", " "):upper(),
        timestamp = os.time()
    })

    ply:Notify("Extracted implant: " .. implantID, 2)
end)


local States = {
    stable = {
        update = function(ply, org, dt, data)
            if data.chromaLoad >= 100 then
                data.timer = (data.timer or 0) + dt * 0.007 * (1 + math.max(data.chromaLoad - 100, 0) * 0.03)
                if data.timer > 30 then return "stage1" end
            else
                data.timer = 0
            end
        end
    },
    stage1 = {
        update = function(ply, org, dt, data)
            org.disorientation = math.random(0.1, 1)
            if data.timer > 60 then return "stage2" end
        end
    },
    stage2 = {
        update = function(ply, org, dt, data)
            org.painadd = 0.1
            org.disorientation = math.random(0.5, 1)
            org.shock = math.random(0.1, 0.5)
            if data.timer > 80 then return "stage3" end
        end
    },
    stage3 = {
        update = function(ply, org, dt, data)
            org.painadd = 0.4
            org.disorientation = math.random(0.1, 0.3)
            org.shock = math.random(0.1, 0.5)
            org.immobilization = math.random(0.1, 1)
            if data.timer >= 97 then return "rage" end
        end
    },
    rage = {
        enter = function(ply, org, data)
            data.killDeadline = CurTime() + 60
            data.rageStarted = true
            org.painadd = 0; org.disorientation = 0; org.immobilization = 0; org.shock = 0
            org.adrenalineAdd = (org.adrenalineAdd or 0) + 20
            ply:Notify("NEED TO KILL", 4)
            ply:SendLua([[ if _psyMusic then _psyMusic:Stop() end
                sound.PlayFile("sound/zcity_implants/psycho_music.mp3", "noplay loop", function(station)
                    if IsValid(station) then station:Play() _psyMusic = station end
                end)]])
        end,
        update = function(ply, org, dt, data)
            if CurTime() > data.killDeadline then
                hg.ExplodeHead(ply)
                return "dead"
            end
            if ply._lastShootTime and CurTime() - ply._lastShootTime < 1 then
                data.killDeadline = CurTime() + 60
            end
            if ply:GetVelocity():Length() > 220 then
                data.killDeadline = CurTime() + 60
            end
        end
    },
    dead = {}
}

local plyPsychosisData = {}

hook.Add("Org Think", "ZC_Implants_Psychosis", function(owner, org, dt)
    if not owner:IsPlayer() or not owner:Alive() then return end
    local data = plyPsychosisData[owner] or { state = "stable", timer = 0, chromaLoad = ZC_IMPLANTS.CalculateChromaLoad(owner) }
    data.chromaLoad = ZC_IMPLANTS.CalculateChromaLoad(owner)
    owner.chromaLoad = data.chromaLoad

    local stateHandler = States[data.state]
    if stateHandler and stateHandler.update then
        local newState = stateHandler.update(owner, org, dt, data)
        if newState then
            data.state = newState
            if States[newState].enter then
                States[newState].enter(owner, org, data)
            end
        end
    end
    plyPsychosisData[owner] = data
end)

hook.Add("PlayerDeath", "ZC_PsychosisReset", function(ply)
    plyPsychosisData[ply] = nil
    ply:SendLua("if _psyMusic then _psyMusic:Stop() _psyMusic = nil end")
end)

hook.Add("PlayerSpawn", "ZC_PsychosisResetSpawn", function(ply)
    plyPsychosisData[ply] = nil
    ply:SendLua("if _psyMusic then _psyMusic:Stop() _psyMusic = nil end")
end)
-- Пока наксолин, но нужно сделать кастом 
hook.Add("Org Think", "ZC_Naloxone_Reset", function(owner, org, dt)
    if org.naloxoneadd and org.naloxoneadd > 0 then
        if plyPsychosisData[owner] then
            plyPsychosisData[owner].timer = 0
            plyPsychosisData[owner].state = "stable"
        end
    end
end)