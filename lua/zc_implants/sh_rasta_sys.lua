if SERVER then
    AddCSLuaFile()
end

ZC_IMPLANTS = ZC_IMPLANTS or {}

ZC_IMPLANTS.CHROMA_VALUES = ZC_IMPLANTS.CHROMA_VALUES or {
    implant_mp3 = 5,
    implant_neurolink_scrap = 8,
    implant_neurolink_diy = 15,
    implant_neurolink_blackmarket = 22,
    implant_neurolink_basic = 18,
    implant_neurolink_military = 28,
    implant_neurolink_militaryplus = 40,
    implant_compass_scrap = 5,
    implant_compass_diy = 10,
    implant_compass_blackmarket = 18,
    implant_compass_1 = 8,
    implant_compass_2 = 12,
    implant_compass_3 = 20,
    implant_nvg = 20,
    implant_thermal = 25,
    implant_cardiac_1 = 18,
    implant_cardiac_2 = 22,
    implant_cardiac_3 = 26,
    implant_cardiac_4 = 30,
    implant_cardiac_5 = 38,
    implant_bloodfilter_1 = 14,
    implant_bloodfilter_2 = 18,
    implant_bloodfilter_3 = 22,
    implant_bloodfilter_4 = 28,
    implant_bloodfilter_5 = 35,
    implant_bloodrefill_1 = 14,
    implant_bloodrefill_2 = 18,
    implant_bloodrefill_3 = 22,
    implant_bloodrefill_4 = 28,
    implant_bloodrefill_5 = 35,
    implant_paindampener_1 = 14,
    implant_paindampener_2 = 18,
    implant_paindampener_3 = 22,
    implant_paindampener_4 = 28,
    implant_paindampener_5 = 35,
    implant_subdermal_scrap = 12,
    implant_subdermal_diy = 18,
    implant_subdermal_blackmarket = 25,
    implant_subdermal_zeta = 20,
    implant_subdermal_osha = 28,
    implant_subdermal_arcom = 35,
    implant_temp = 8,
    implant_adrenal = 20,
    implant_morphine = 22,
    implant_fury13 = 35,
    implant_fury16 = 40,
    implant_airjump_scrap = 12,
    implant_airjump_diy = 18,
    implant_airjump_blackmarket = 25,
    implant_airjump_low = 18,
    implant_airjump_mid = 22,
    implant_airjump_high = 30,
    implant_airjump_black = 38,
    implant_dash_scrap = 12,
    implant_dash_diy = 18,
    implant_dash_blackmarket = 25,
    implant_dash_low = 18,
    implant_dash_2 = 22,
    implant_dash_high = 30,
    implant_dash_4 = 35,
    implant_dash_5 = 42,
    implant_chargejump_scrap = 12,
    implant_chargejump_diy = 18,
    implant_chargejump_blackmarket = 25,
    implant_chargejump_1 = 18,
    implant_chargejump_2 = 22,
    implant_chargejump_3 = 30,
    implant_chargejump_4 = 35,
    implant_chargejump_5 = 42,
    implant_bone_lacing_1 = 18,
    implant_bone_lacing_2 = 22,
    implant_bone_lacing_3 = 28,
    implant_bone_lacing_4 = 35,
    implant_bone_lacing_5 = 42,
    implant_kinetic_1 = 8,
    implant_kinetic_2 = 12,
    implant_kinetic_3 = 18,
    implant_kinetic_4 = 22,
    implant_kinetic_5 = 30,
    implant_synth_lungs_scrap = 12,
    implant_synth_lungs_diy = 18,
    implant_synth_lungs_blackmarket = 25,
    implant_synth_lungs_1 = 18,
    implant_synth_lungs_2 = 22,
    implant_synth_lungs_3 = 28,
    implant_synth_lungs_4 = 35,
    implant_synth_lungs_5 = 42,
    implant_cyberdeck_basic = 0,
    implant_cyberdeck_advanced = 0,
    implant_cyberdeck_pro = 0
}

ZC_IMPLANTS.NETVAR_IMPLANTS = ZC_IMPLANTS.NETVAR_IMPLANTS or {}
for implantId in pairs(ZC_IMPLANTS.CHROMA_VALUES) do
    ZC_IMPLANTS.NETVAR_IMPLANTS[implantId] = true
end

function ZC_IMPLANTS.HasImplant(ply, implantId, pending)
    if not IsValid(ply) or not implantId then return false end
    if pending and pending[implantId] ~= nil then
        return pending[implantId] == true
    end
    return ply:GetNetVar(implantId) == true or (ply.organism and ply.organism[implantId] == true)
end

function ZC_IMPLANTS.CalculateChromaLoad(ply, pending)
    if not IsValid(ply) then return 0 end

    local total = 0
    for implantId, chroma in pairs(ZC_IMPLANTS.CHROMA_VALUES) do
        if ZC_IMPLANTS.HasImplant(ply, implantId, pending) then
            total = total + chroma
        end
    end
    return total
end

ModifierContainer = {}
ModifierContainer.__index = ModifierContainer

function ModifierContainer:New()
    return setmetatable({ modifiers = {} }, self)
end

function ModifierContainer:Add(id, data)
    self.modifiers[id] = data
end

function ModifierContainer:Remove(id)
    self.modifiers[id] = nil
end

function ModifierContainer:ApplyToOrganism(org)
    local values = {}
    for id, mod in pairs(self.modifiers) do
        for k, v in pairs(mod) do
            if type(v) == "table" and v.value ~= nil then
                values[k] = v.value 
            end
        end
    end
    if values.bleedMul then org.bleedingmul = values.bleedMul end
    if values.staminaRangeMul then org.stamina.range = 60 * 3 * values.staminaRangeMul end
    if values.staminaRegenMul then org.stamina.regen = 1 * values.staminaRegenMul end
    if values.temperature then org.temperature = values.temperature end
    if values.heatbuff then org.heatbuff = values.heatbuff end
    if values.warmLoseMul then org.warmLoseMul = values.warmLoseMul end
    if values.maxWarmMul then org.maxWarmMul = values.maxWarmMul end
    if values.pulseRange then
        local minP, maxP = values.pulseRange[1], values.pulseRange[2]
        if minP then org.pulse = math.max(org.pulse, minP) end
        if maxP then org.pulse = math.min(org.pulse, maxP) end
    end
    if values.heartStopImmunity then org.heartstop = false end
    if values.lungsFunction then org.lungsfunction = true end
end

AbilitySystem = {}
AbilitySystem.__index = AbilitySystem

function AbilitySystem:New(owner)
    return setmetatable({
        owner = owner,
        abilities = {},
        cooldowns = {},
        doubleTap = {},
        holdState = {},
    }, self)
end

function AbilitySystem:RegisterAbility(implantId, abilityData)
    local atype = abilityData.type
    local existing = self.abilities[atype]
    if existing and (existing.priority or 0) >= (abilityData.priority or 0) then return end
    self.abilities[atype] = {
        implantId = implantId,
        tier = abilityData.tier,
        priority = abilityData.priority or 0,
        config = ZC_IMPLANTS.AbilityConfig[atype],
    }
end

function AbilitySystem:UnregisterAbility(implantId)
    for atype, data in pairs(self.abilities) do
        if data.implantId == implantId then
            self.abilities[atype] = nil
            break
        end
    end
end

function AbilitySystem:GetActiveTierData(atype)
    local ab = self.abilities[atype]
    if not ab then return nil end
    return ab.config.tiers[ab.tier]
end

function AbilitySystem:OnKeyPress(key)
    for atype, ability in pairs(self.abilities) do
        local cfg = ability.config
        if cfg.directions and table.HasValue(cfg.directions, key) then
            if cfg.doubleTapWindow then
                self:HandleDoubleTap(key, atype, ability)
            elseif cfg.minHoldTime then
                self:StartHold(key, atype, ability)
            elseif atype == "airjump" then
                self:HandleAirJump(key, ability)
            end
        end
    end
end

function AbilitySystem:OnKeyRelease(key)
    for atype, ability in pairs(self.abilities) do
        local cfg = ability.config
        if cfg.directions and table.HasValue(cfg.directions, key) then
            if cfg.minHoldTime and self.holdState[atype] then
                self:ReleaseHold(atype, ability)
            end
        end
    end
end

function AbilitySystem:HandleDoubleTap(key, atype, ability)
    local ply = self.owner
    local tierData = self:GetActiveTierData(atype) if not tierData then return end
    if tierData.groundOnly and not ply:OnGround() then return end
    local now = CurTime()
    if self.cooldowns[atype] and now < self.cooldowns[atype] then return end

    self.doubleTap[atype] = self.doubleTap[atype] or {}
    local lastTap = self.doubleTap[atype][key]
    if lastTap and (now - lastTap) < ability.config.doubleTapWindow then
        self:ExecuteAbility(atype, ability, key)
        self.doubleTap[atype][key] = nil
    else
        self.doubleTap[atype][key] = now
    end
end

function AbilitySystem:HandleAirJump(key, ability)
    local ply = self.owner
    if not IsValid(ply) or not ply:Alive() then return end
    local org = ply.organism
    if not org or org.otrub then return end
    if ply:OnGround() then
        ply._airjumpUsed = false
        return
    end
    if ply._airjumpUsed then return end
    ply._airjumpUsed = true
    self:ExecuteAbility("airjump", ability, key)
end

function AbilitySystem:StartHold(key, atype, ability)
    local ply = self.owner
    if not IsValid(ply) or not ply:Alive() then return end
    local org = ply.organism
    if not org or org.otrub then return end
    if not ply:OnGround() then return end
    ply.chargeStart = CurTime()
    self.holdState[atype] = { start = CurTime(), active = true }
end

function AbilitySystem:ReleaseHold(atype, ability)
    local ply = self.owner
    local holdData = self.holdState[atype]
    holdData.active = false
    local held = CurTime() - holdData.start
    local cfg = ability.config
    if held < cfg.minHoldTime then
        self.holdState[atype] = nil
        return
    end
    if not ply:OnGround() then return end
    self:ExecuteAbility(atype, ability, nil, held)
    self.holdState[atype] = nil
end

function AbilitySystem:ExecuteAbility(atype, ability, directionKey, holdTime)
    local ply = self.owner
    local tierData = self:GetActiveTierData(atype)
    if not tierData then return end

    if tierData.failChance and math.random() < tierData.failChance then
        self:HandleFail(atype, tierData)
        self.cooldowns[atype] = CurTime() + (tierData.cooldown or 1)
        return
    end

    if atype == "dash" then
        local dir = self:GetDirection(directionKey)
        local speed = tierData.speed
        if tierData.randomSpeed then
            speed = math.Rand(speed * (tierData.randomRange[1] or 0.7), speed * (tierData.randomRange[2] or 1.3))
        end
        ply:SetVelocity(dir * speed)
        ply:EmitSound("dash.wav")
        self.cooldowns[atype] = CurTime() + tierData.cooldown
        if tierData.smokeEffect then self:SendFX("smoke") end
    elseif atype == "airjump" then
        local jumpPower = tierData.jumpPower
        if tierData.randomPower then jumpPower = math.Rand(tierData.randomPower[1], tierData.randomPower[2]) end
        ply:EmitSound("airjump.wav")
        local vel = ply:GetVelocity()
        ply:SetVelocity(Vector(vel.x * -0.1, vel.y * -0.1, jumpPower))
        if tierData.effectTrail then self:SendFX("rocket_trail") end
    elseif atype == "chargejump" then
        local cfg = ability.config
        local charge = math.Clamp(holdTime, 0, tierData.maxCharge)
        local upForce = tierData.baseZ + charge * tierData.chargeZ
        if tierData.randomFactor then
            upForce = upForce * math.Rand(tierData.randomFactor[1], tierData.randomFactor[2])
        end
        ply:EmitSound("chargejump.wav")
        ply:SetVelocity(Vector(0,0, upForce))
        if tierData.overheatThreshold and holdTime > tierData.overheatThreshold then
            ply:GetOrganism().painadd = (ply:GetOrganism().painadd or 0) + tierData.overheatPain
        end
        if tierData.effectTrail then self:SendFX("rocket_trail") end
    end
end

function AbilitySystem:HandleFail(atype, tierData)
    local ply = self.owner
    if atype == "dash" and tierData.backfire then
        ply:SetVelocity(-self:GetDirection(nil) * 100 + Vector(0,0,50))
        ply:EmitSound("physics/body/body_medium_impact_soft1.wav")
    elseif atype == "airjump" then
        if tierData.backfire then
            ply:SetVelocity(Vector(0,0,-50))
            ply:EmitSound("physics/body/body_medium_impact_hard1.wav")
        elseif tierData.soundFail then
            ply:EmitSound("buttons/combine_button_locked.wav")
        end
    elseif atype == "chargejump" and tierData.explodeFail then
        ply:SetVelocity(Vector(math.Rand(-300,300), math.Rand(-300,300), math.Rand(100,300)))
        local explosion = ents.Create("env_explosion")
        explosion:SetPos(ply:GetPos())
        explosion:SetOwner(ply)
        explosion:Spawn()
        explosion:SetKeyValue("iMagnitude", "30")
        explosion:Fire("Explode", 0, 0)
    end
end

function AbilitySystem:GetDirection(key)
    local ply = self.owner
    if key == IN_FORWARD then return ply:GetForward()
    elseif key == IN_BACK then return -ply:GetForward()
    elseif key == IN_MOVELEFT then return -ply:GetRight()
    elseif key == IN_MOVERIGHT then return ply:GetRight()
    else return Vector(0,0,0)
    end
end

function AbilitySystem:SendFX(name)
    net.Start("implant_fx")
    net.WriteString(name)
    net.Send(self.owner)
end

function AbilitySystem:SuppressJump(mv)
    for atype, holdData in pairs(self.holdState) do
        if holdData.active then
            local ability = self.abilities[atype]
            if (CurTime() - holdData.start) >= ability.config.minHoldTime then
                mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
            end
        end
    end
end

ZC_IMPLANTS.AbilityConfig = {
    dash = {
        doubleTapWindow = 0.3,
        directions = {IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT},
        tiers = {
            scrap = {
                speed = 700, cooldown = 1.5, groundOnly = true,
                failChance = 0.5, backfire = true
            },
            diy = {
                speed = 600, cooldown = 1.0, groundOnly = true,
                randomSpeed = true, randomRange = {0.7, 1.3},
                failChance = 0.15, misfireChance = 0.15
            },
            black = {
                speed = 500, cooldown = 0.8, groundOnly = true,
                failChance = 0.1, smokeEffect = true
            },
            [1] = { speed = 600,  cooldown = 1.2,  groundOnly = true },
            [2] = { speed = 750,  cooldown = 0.2,  groundOnly = true },
            [3] = { speed = 1200, cooldown = 0.1,  groundOnly = true },
            [4] = { speed = 1000, cooldown = 2.0,  groundOnly = false },
            [5] = { speed = 2000, cooldown = 0.25, groundOnly = false },
        }
    },
    airjump = {
        directions = {IN_JUMP},
        tiers = {
            scrap = {
                jumpPower = 400, failChance = 0.4, backfire = true
            },
            diy = {
                jumpPower = 350, randomPower = {100, 350},
                failChance = 0.2, misfireChance = 0.2
            },
            black = {
                jumpPower = 350, failChance = 0.25,
                soundFail = true, effectTrail = true
            },
            low = { jumpPower = 300 },
            mid = { jumpPower = 430 },
            high = { jumpPower = 600, fallImmunity = true },
            black_tier = { jumpPower = 900, fallImmunity = true },
        },
        fallImmunityCheck = function(ply)
            return ply:GetActiveAbilityTierData("airjump") and ply:GetActiveAbilityTierData("airjump").fallImmunity
        end
    },
    chargejump = {
        minHoldTime = 0.6,
        directions = {IN_JUMP},
        tiers = {
            scrap = {
                maxCharge = 2.0, baseZ = 50, chargeZ = 200,
                failChance = 0.3, explodeFail = true
            },
            diy = {
                maxCharge = 2.5, baseZ = 100, chargeZ = 200,
                randomFactor = {0.3, 2.0}, misfireChance = 0.25
            },
            black = {
                maxCharge = 2.0, baseZ = 80, chargeZ = 250,
                overheatThreshold = 1.2, overheatPain = 30,
                effectTrail = true
            },
            [1] = { maxCharge = 1.0, baseZ = 200, chargeZ = 100 },
            [2] = { maxCharge = 1.5, baseZ = 200, chargeZ = 150 },
            [3] = { maxCharge = 2.0, baseZ = 250, chargeZ = 200 },
            [4] = { maxCharge = 2.5, baseZ = 300, chargeZ = 250 },
            [5] = { maxCharge = 3.0, baseZ = 400, chargeZ = 300 },
        }
    }
}

ZC_IMPLANTS.ImplantTemplates = ZC_IMPLANTS.ImplantTemplates or {}

function ZC_IMPLANTS.RegisterTemplate(id, data)
    data.id = id
    ZC_IMPLANTS.ImplantTemplates[id] = data
end

function ZC_IMPLANTS.GetTemplate(id)
    return ZC_IMPLANTS.ImplantTemplates[id]
end

local plyMeta = FindMetaTable("Player")

function plyMeta:AddImplant(implantId)
    if self.implantInstances[implantId] then return end
    local tmpl = ZC_IMPLANTS.GetTemplate(implantId)
    if not tmpl then return end
    local instance = { id = implantId, template = tmpl, state = {} }
    self.implantInstances[implantId] = instance
    if tmpl.modifiers then
        self.modifiers:Add(implantId, tmpl.modifiers)
    end
    if tmpl.ability then
        self.abilitySystem:RegisterAbility(implantId, tmpl.ability)
    end
    if tmpl.concommand then
        if not _G.ImplantConCommands[tmpl.concommand.name] then
            concommand.Add(tmpl.concommand.name, function(ply, cmd, args)
                if not ply:HasImplant(implantId) then return end
                local inst = ply.implantInstances[implantId]
                if inst.template.concommand.canUse and not inst.template.concommand.canUse(ply) then
                    ply:Notify("CANNOT USE", 1)
                    return
                end
                local cdKey = "impl_cd_" .. implantId .. "_cmd"
                if (ply[cdKey] or 0) > CurTime() then
                    ply:Notify("RECHARGING", 1)
                    return
                end
                ply[cdKey] = CurTime() + (inst.template.concommand.cooldown or 0)
                inst.template.concommand.effect(ply)
            end)
            _G.ImplantConCommands[tmpl.concommand.name] = true
        end
    end
end

function plyMeta:RemoveImplant(implantId)
    local inst = self.implantInstances[implantId]
    if not inst then return end
    self.implantInstances[implantId] = nil
    if inst.template.modifiers then
        self.modifiers:Remove(implantId)
    end
    if inst.template.ability then
        self.abilitySystem:UnregisterAbility(implantId)
    end
end

function plyMeta:HasImplant(id)
    return self.implantInstances[id] ~= nil
end

function plyMeta:GetActiveAbilityTierData(abilityType)
    return self.abilitySystem:GetActiveTierData(abilityType)
end

local function simpleModifier(modTable)
    return { type = "passive", modifiers = modTable }
end

local function cooldownCheck(ply, id, cd)
    local key = "impl_cd_" .. id
    if (ply[key] or 0) > CurTime() then return false end
    ply[key] = CurTime() + cd
    return true
end

ZC_IMPLANTS.RegisterTemplate("temp_regulator", simpleModifier({
    temperature = { value = 36.7 },
    heatbuff = { value = 30 },
    warmLoseMul = { value = -99 },
    maxWarmMul = { value = 99 },
}))

ZC_IMPLANTS.RegisterTemplate("adrenal", {
    type = "passive",
    onThink = function(ply, org, dt, state)
        if org.pain > 30 or org.pulse < 60 or org.blood < 4000 then
            if cooldownCheck(ply, "adrenal_auto", 30) then
                org.adrenalineAdd = org.adrenalineAdd + 3
                ply:Notify("AUTO-INJECTING ADRENALINE", 1)
            end
        end
    end,
    concommand = {
        name = "implant_adrenal_use",
        cooldown = 120,
        effect = function(ply)
            ply:GetOrganism().adrenalineAdd = ply:GetOrganism().adrenalineAdd + 5
            ply:Notify("ADRENALINE", 1)
        end
    }
})

ZC_IMPLANTS.RegisterTemplate("morphine", {
    type = "passive",
    onThink = function(ply, org, dt, state)
        if org.pain > 15 and cooldownCheck(ply, "morphine_cd", 60) then
            org.analgesia = math.min(org.analgesia + 0.3, 1)
            ply:Notify("Critical pain levels detected. Injecting Morphine.", 1)
        end
    end
})

ZC_IMPLANTS.RegisterTemplate("fury13", {
    type = "passive",
    onThink = function(ply, org, dt, state)
        if org.noradrenaline >= 0.4 then return end
        if (org.pulse < 30 or org.blood < 3000) and cooldownCheck(ply, "fury13_auto", 300) then
            org.berserk = org.berserk + 2
            ply:Notify("BERSERK PROTOCOL ACTIVATED", 1)
        end
    end,
    concommand = {
        name = "implant_fury13_use",
        cooldown = 300,
        canUse = function(ply) return ply:GetOrganism().noradrenaline < 0.4 end,
        effect = function(ply)
            ply:GetOrganism().berserk = ply:GetOrganism().berserk + 2
            ply:Notify("BERSERK PROTOCOL ACTIVATED", 1)
        end
    }
})

ZC_IMPLANTS.RegisterTemplate("fury16", {
    type = "passive",
    concommand = {
        name = "implant_fury16_use",
        cooldown = 180,
        canUse = function(ply) return ply:GetOrganism().berserk < 0.4 end,
        effect = function(ply)
            ply:GetOrganism().noradrenaline = ply:GetOrganism().noradrenaline + 1.25
            ply:Notify("NORADRENALINE SURGE", 1)
        end
    }
})

local function createSubdermal(id, protection, scaleDmg, failChance, bleedMul, extra)
    local t = {
        type = "subdermal_armor",
        modifiers = { bleedMul = { value = bleedMul or 1.0 } },
        onDamage = function(org, dmgInfo, hook_info, state)
            local pen = dmgInfo:GetInflictor().bullet and dmgInfo:GetInflictor().bullet.Penetration or 1
            if protection and (protection - pen < 0) then return end
            if failChance and math.random() < failChance then
                dmgInfo:ScaleDamage(1.5)
                return
            end
            dmgInfo:SetDamageType(DMG_CLUB)
            dmgInfo:ScaleDamage(scaleDmg or 1)
            if extra and extra.forceScale then
                dmgInfo:SetDamageForce(dmgInfo:GetDamageForce() * extra.forceScale)
            end
            hook_info.restricted = true
            if extra and extra.bleedOnHit then
                org.bleed = (org.bleed or 0) + extra.bleedOnHit
            end
        end
    }
    if extra and extra.onDamageOverride then
        t.onDamage = extra.onDamageOverride
    end
    return t
end

ZC_IMPLANTS.RegisterTemplate("subdermal_scrap", createSubdermal("subdermal_scrap", 4, 0.85, 0.4, 1.2))
ZC_IMPLANTS.RegisterTemplate("subdermal_diy", createSubdermal("subdermal_diy", nil, nil, nil, 0.8, {
    onDamageOverride = function(org, dmgInfo, hook_info, state)
        local protection = math.random(3, 10)
        local scaleDmg = math.Rand(0.5, 0.9)
        local pen = dmgInfo:GetInflictor().bullet and dmgInfo:GetInflictor().bullet.Penetration or 1
        if protection - pen < 0 then return end
        dmgInfo:SetDamageType(DMG_CLUB)
        dmgInfo:ScaleDamage(scaleDmg)
        hook_info.restricted = true
    end
}))
ZC_IMPLANTS.RegisterTemplate("subdermal_blackmarket", createSubdermal("subdermal_blackmarket", 12, 0.6, nil, 0.3, { bleedOnHit = 0.02 }))
ZC_IMPLANTS.RegisterTemplate("subdermal_arcom", createSubdermal("subdermal_arcom", 14.5, 0.6, nil, 0.1, { forceScale = 0.4 }))
ZC_IMPLANTS.RegisterTemplate("subdermal_osha", createSubdermal("subdermal_osha", 8, 0.7, nil, 0.6))
ZC_IMPLANTS.RegisterTemplate("subdermal_zeta", createSubdermal("subdermal_zeta", 16.5, 0.5, nil, 0.85))

ZC_IMPLANTS.RegisterTemplate("airjump_scrap", {
    type = "ability",
    ability = { type = "airjump", tier = "scrap" }
})
ZC_IMPLANTS.RegisterTemplate("airjump_diy", {
    type = "ability",
    ability = { type = "airjump", tier = "diy" }
})
ZC_IMPLANTS.RegisterTemplate("airjump_blackmarket", {
    type = "ability",
    ability = { type = "airjump", tier = "black" }
})
ZC_IMPLANTS.RegisterTemplate("airjump_low", {
    type = "ability",
    ability = { type = "airjump", tier = "low" }
})
ZC_IMPLANTS.RegisterTemplate("airjump_mid", {
    type = "ability",
    ability = { type = "airjump", tier = "mid" }
})
ZC_IMPLANTS.RegisterTemplate("airjump_high", {
    type = "ability",
    ability = { type = "airjump", tier = "high" }
})
ZC_IMPLANTS.RegisterTemplate("airjump_black", {
    type = "ability",
    ability = { type = "airjump", tier = "black_tier" }
})

ZC_IMPLANTS.RegisterTemplate("dash_scrap", {
    type = "ability",
    ability = { type = "dash", tier = "scrap" }
})
ZC_IMPLANTS.RegisterTemplate("dash_diy", {
    type = "ability",
    ability = { type = "dash", tier = "diy" }
})
ZC_IMPLANTS.RegisterTemplate("dash_blackmarket", {
    type = "ability",
    ability = { type = "dash", tier = "black" }
})
ZC_IMPLANTS.RegisterTemplate("dash_low", {
    type = "ability",
    ability = { type = "dash", tier = 1 }
})
ZC_IMPLANTS.RegisterTemplate("dash_2", {
    type = "ability",
    ability = { type = "dash", tier = 2 }
})
ZC_IMPLANTS.RegisterTemplate("dash_high", {
    type = "ability",
    ability = { type = "dash", tier = 3 }
})
ZC_IMPLANTS.RegisterTemplate("dash_4", {
    type = "ability",
    ability = { type = "dash", tier = 4 }
})
ZC_IMPLANTS.RegisterTemplate("dash_5", {
    type = "ability",
    ability = { type = "dash", tier = 5 }
})

ZC_IMPLANTS.RegisterTemplate("chargejump_scrap", {
    type = "ability",
    ability = { type = "chargejump", tier = "scrap" }
})
ZC_IMPLANTS.RegisterTemplate("chargejump_diy", {
    type = "ability",
    ability = { type = "chargejump", tier = "diy" }
})
ZC_IMPLANTS.RegisterTemplate("chargejump_blackmarket", {
    type = "ability",
    ability = { type = "chargejump", tier = "black" }
})
for i = 1, 5 do
    ZC_IMPLANTS.RegisterTemplate("chargejump_" .. i, {
        type = "ability",
        ability = { type = "chargejump", tier = i }
    })
end

local function boneLacingMod(healRate, dislocationImmunity, extraBones)
    return {
        type = "passive",
        modifiers = {
            boneHealRate = { value = healRate },
            dislocationImmunity = { value = dislocationImmunity or {} },
            extraBones = { value = extraBones or {} }
        }
    }
end
ZC_IMPLANTS.RegisterTemplate("bone_lacing_1", boneLacingMod(1/120))
ZC_IMPLANTS.RegisterTemplate("bone_lacing_2", boneLacingMod(1/90, {rarm=true, larm=true}))
ZC_IMPLANTS.RegisterTemplate("bone_lacing_3", boneLacingMod(1/60, {rarm=true, larm=true, rleg=true, lleg=true, jaw=true}))
ZC_IMPLANTS.RegisterTemplate("bone_lacing_4", boneLacingMod(1/20, {rarm=true, larm=true, rleg=true, lleg=true, jaw=true}, {pelvis=true}))
ZC_IMPLANTS.RegisterTemplate("bone_lacing_5", boneLacingMod(0, {rarm=true, larm=true, rleg=true, lleg=true, jaw=true}, {pelvis=true, spine1=true, spine2=true, spine3=true}))

local function cardiacMod(minPulse, maxPulse, heartStopImmune, lungsFunc)
    return {
        type = "passive",
        modifiers = {
            pulseRange = { value = {minPulse, maxPulse} },
            heartStopImmunity = { value = heartStopImmune or false },
            lungsFunction = { value = lungsFunc or false },
        }
    }
end
ZC_IMPLANTS.RegisterTemplate("cardiac_1", cardiacMod(10, nil, true))
ZC_IMPLANTS.RegisterTemplate("cardiac_2", cardiacMod(10, nil, true))
ZC_IMPLANTS.RegisterTemplate("cardiac_3", cardiacMod(20, 160, true))
ZC_IMPLANTS.RegisterTemplate("cardiac_4", cardiacMod(30, 140, true))
ZC_IMPLANTS.RegisterTemplate("cardiac_5", cardiacMod(40, 120, true, true))

local function bloodFilterMod(coRate, intBleedRate, poisonImmune, instantClear)
    return {
        type = "passive",
        onThink = function(ply, org, dt, state)
            if instantClear then
                org.CO = 0; org.COregen = 0; org.poison4 = nil; org.internalBleed = 0; org.hemotransfusionshock = 0
                return
            end
            org.CO = math.max(org.CO - dt * coRate, 0)
            org.COregen = math.max(org.COregen - dt * coRate, 0)
            org.internalBleed = math.max(org.internalBleed - dt * intBleedRate, 0)
            if poisonImmune then org.poison4 = nil end
        end
    }
end
ZC_IMPLANTS.RegisterTemplate("bloodfilter_1", bloodFilterMod(0.5, 0.5))
ZC_IMPLANTS.RegisterTemplate("bloodfilter_2", bloodFilterMod(1, 1, true))
ZC_IMPLANTS.RegisterTemplate("bloodfilter_3", bloodFilterMod(2, 2, true))
ZC_IMPLANTS.RegisterTemplate("bloodfilter_4", bloodFilterMod(4, 4, true))
ZC_IMPLANTS.RegisterTemplate("bloodfilter_5", bloodFilterMod(nil, nil, true, true))

local function bloodRefillMod(poolSize, regenRate, rechargeTime, bleedThreshold, intBleedThreshold)
    return {
        type = "passive",
        onThink = function(ply, org, dt, state)
            local id = implant_id
            if not id then return end
            local poolKey = "br_pool_" .. id
            local rechargeKey = "br_recharge_" .. id
            ply[poolKey] = ply[poolKey] or poolSize
            if (org.bleed < (bleedThreshold or 0.05)) and (org.internalBleed < (intBleedThreshold or 0.5)) and ply[poolKey] > 0 then
                local regen = math.min(dt * regenRate, ply[poolKey])
                org.blood = math.min(org.blood + regen, 5000)
                ply[poolKey] = ply[poolKey] - regen
            end
            if ply[poolKey] <= 0 then
                ply[rechargeKey] = ply[rechargeKey] or CurTime() + rechargeTime
                if CurTime() > ply[rechargeKey] then
                    ply[poolKey] = poolSize
                    ply[rechargeKey] = nil
                end
            end
        end
    }
end
ZC_IMPLANTS.RegisterTemplate("bloodrefill_1", bloodRefillMod(1000, 10, 120))
ZC_IMPLANTS.RegisterTemplate("bloodrefill_2", bloodRefillMod(2000, 25, 90))
ZC_IMPLANTS.RegisterTemplate("bloodrefill_3", bloodRefillMod(3000, 50, 60))
ZC_IMPLANTS.RegisterTemplate("bloodrefill_4", bloodRefillMod(4000, 80, 60, 0.5, 999))
ZC_IMPLANTS.RegisterTemplate("bloodrefill_5", bloodRefillMod(5000, 120, 60, 999, 999))

local function painDampenerMod(analgesia, shockRed, avgPainRed, painMul, immobRed, disorientRed)
    return {
        type = "passive",
        onThink = function(ply, org, dt, state)
            org.analgesia = math.max(org.analgesia, analgesia)
            org.shock = math.max(org.shock - dt * shockRed, 0)
            if avgPainRed then org.avgpain = math.max(org.avgpain - dt * avgPainRed, 0) end
            if painMul then org.painadd = org.painadd * painMul end
            if immobRed then org.immobilization = math.max(org.immobilization - dt * immobRed, 0) end
            if disorientRed then org.disorientation = math.max(org.disorientation - dt * disorientRed, 0) end
        end
    }
end
ZC_IMPLANTS.RegisterTemplate("paindampener_1", painDampenerMod(0.1, 1))
ZC_IMPLANTS.RegisterTemplate("paindampener_2", painDampenerMod(0.2, 3, 2))
ZC_IMPLANTS.RegisterTemplate("paindampener_3", painDampenerMod(0.4, 6, 4, 0.8))
ZC_IMPLANTS.RegisterTemplate("paindampener_4", painDampenerMod(0.6, 10, 8, 0.5, 5))
ZC_IMPLANTS.RegisterTemplate("paindampener_5", painDampenerMod(0.9, 20, 15, 0.1, 15, 5))

for tier = 1, 5 do
    local chance = ({0.3, 0.5, 0.7, 0.9, 1.0})[tier]
    ZC_IMPLANTS.RegisterTemplate("skull_" .. tier, {
        type = "passive",
        onThink = function(ply, org, dt, state)
            if org.needotrub and math.random() < chance then
                org.needotrub = false
                org.otrub = false
                org.consciousness = math.min(org.consciousness + 0.3, 1)
            end
        end
    })
end

local function synthLungsMod(maxMul, regenMul, neverExhaust, extraThink)
    return {
        type = "passive",
        modifiers = {
            staminaRangeMul = { value = maxMul },
            staminaRegenMul = { value = regenMul },
        },
        onThink = extraThink or function() end
    }
end
ZC_IMPLANTS.RegisterTemplate("synth_lungs_1", synthLungsMod(1.2, 1.05))
ZC_IMPLANTS.RegisterTemplate("synth_lungs_2", synthLungsMod(1.4, 1.2))
ZC_IMPLANTS.RegisterTemplate("synth_lungs_3", synthLungsMod(1.7, 1.2))
ZC_IMPLANTS.RegisterTemplate("synth_lungs_4", synthLungsMod(2.0, 1.3))
ZC_IMPLANTS.RegisterTemplate("synth_lungs_5", synthLungsMod(2.5, 1.4, true, function(ply, org, dt)
    org.stamina[1] = math.max(org.stamina[1], 20)
end))

ZC_IMPLANTS.RegisterTemplate("synth_lungs_scrap", {
    type = "passive",
    modifiers = {
        staminaRangeMul = { value = 1.2 },
        staminaRegenMul = { value = 1.5 },
    },
    onThink = function(ply, org, dt, state)
        local vel = ply:GetVelocity():Length()
        if vel > 400 then
            org.stamina[1] = math.max(org.stamina[1] - dt * 10, 5)
        end
        if math.random(1000) <= 10 then
            org.o2[1] = math.max(org.o2[1] - 10, 0)
        end
        if org.stamina[1] < org.stamina.range * 0.3 then
            org.o2[1] = math.max(org.o2[1] - dt * 3, 0)
            if math.random(100) <= 10 then
                ply:EmitSound("physics/body/body_medium_impact_soft1.wav")
            end
        end
        org.stamina[1] = math.max(org.stamina[1], 5)
    end
})

ZC_IMPLANTS.RegisterTemplate("synth_lungs_diy", {
    type = "passive",
    onThink = function(ply, org, dt, state)
        if not state.timer then state.timer = 0 end
        if CurTime() > state.timer then
            state.timer = CurTime() + math.Rand(10, 30)
            state.boost = math.Rand(0.2, 2.0)
        end
        local boost = state.boost or 1.0
        local base = 60 * 3
        org.stamina.range = base * (1.0 + boost * 0.5)
        org.stamina.regen = 1.0 * boost
        if boost > 1.7 then
            org.painadd = (org.painadd or 0) + dt * 2
        end
        org.stamina[1] = math.max(org.stamina[1], 10)
    end
})

ZC_IMPLANTS.RegisterTemplate("synth_lungs_blackmarket", {
    type = "passive",
    modifiers = {
        staminaRangeMul = { value = 1.8 },
        staminaRegenMul = { value = 1.3 },
    },
    onThink = function(ply, org, dt, state)
        local staminaPct = org.stamina[1] / org.stamina.range
        state.addiction = state.addiction or 0
        if staminaPct > 0.8 then
            state.addiction = state.addiction + dt
        else
            state.addiction = math.max(state.addiction - dt * 2, 0)
        end
        if state.addiction > 30 and org.stamina[1] < 20 then
            org.painadd = (org.painadd or 0) + dt * 5
            org.disorientation = math.min((org.disorientation or 0) + dt * 3, 10)
            if math.random(1000) <= 10 then
                ply:EmitSound("buttons/combine_button_locked.wav")
            end
        end
        org.stamina[1] = math.max(org.stamina[1], 10)
    end
})

local neurolinkIDs = {"neurolink_basic", "neurolink_military", "neurolink_militaryplus", "neurolink_scrap", "neurolink_diy", "neurolink_blackmarket"}
for _, id in ipairs(neurolinkIDs) do
    ZC_IMPLANTS.RegisterTemplate(id, {
        type = "passive",
        neurolink = true
    })
end

-- sh_zc_cyberdeck.lua (пустой)
-- sh_zc_cyberimplants.lua (закомментированный код, сохранён как есть)
--ZC_CYBERDECK.QUICKHACKS = {
--    short_circuit = {
--        name = "Short Circuit",
--        desc = "Наносит урон, увеличивающийся от имплантов жертвы. Накладывает тазер.",
--        ram_cost = 2,
--        cast_time = 0.5,
--        cooldown = 8,
--        range = 1500,
--        visible = true,
--        damage_base = {15, 25, 40},
--        damage_per_chroma = 0.8,
--        taser_duration = {2, 3, 4}
--    },
--    synapse_burnout = {
--        name = "Synapse Burnout",
--        desc = "Критический урон мозгу и поджигание цели.",
--        ram_cost = 3,
--        cast_time = 0.8,
--        cooldown = 12,
--        range = 1200,
--        visible = true,
--        damage_head = {20, 35, 50},
--        burn_damage = {5, 8, 12},
--        burn_duration = {4, 6, 8}
--    },
--    cyberware_shutoff = {
--        name = "Cyberware Shut-off",
--        desc = "Отключает все импланты жертвы на время.",
--        ram_cost = 4,
--        cast_time = 1.0,
--        cooldown = 20,
--        range = 1000,
--        visible = true,
--        disable_duration = {3, 5, 8}
--    },
--    reboot_optics = {
--        name = "Reboot Optics",
--        desc = "Глитчи и ERROR на экране жертвы.",
--        ram_cost = 2,
--        cast_time = 0.3,
--        cooldown = 10,
--        range = 1500,
--        visible = true,
--        glitch_duration = {4, 6, 10},
--        blind_duration = {1, 2, 3}
--    },
--    cyberpsychosis = {
--        name = "Cyberpsychosis",
--        desc = "QTE борьба. При провале - киберпсихоз.",
--        ram_cost = 5,
--        cast_time = 0.5,
--        cooldown = 30,
--        range = 1000,
--        visible = false,
--        qte_rounds = 3,
--        qte_time_base = {2.5, 2.0, 1.5},
--        qte_time_min = {0.8, 0.6, 0.4},
--        qte_decay = 0.85
--    },
--    suicide = {
--        name = "Suicide",
--        desc = "QTE борьба. Проигравший умирает.",
--        ram_cost = 6,
--        cast_time = 1.0,
--        cooldown = 45,
--        range = 800,
--        visible = false,
--        qte_rounds = 4,
--        qte_time_base = {3.0, 2.5, 2.0},
--        qte_time_min = {1.0, 0.8, 0.5},
--        qte_decay = 0.8
--    }
--}

--function ZC_CYBERDECK.GetTier(ply)
--    if not IsValid(ply) then return 0 end
--    if ply:GetNetVar("implant_cyberdeck_pro") then return 3 end
--    if ply:GetNetVar("implant_cyberdeck_advanced") then return 2 end
--    if ply:GetNetVar("implant_cyberdeck_basic") then return 1 end
--    return 0
--end

--function ZC_CYBERDECK.GetTierData(ply)
--    local tier = ZC_CYBERDECK.GetTier(ply)
--    if tier == 0 then return nil end
--    local deck_implant = "implant_cyberdeck_basic"
--    if tier == 2 then deck_implant = "implant_cyberdeck_advanced" end
--    if tier == 3 then deck_implant = "implant_cyberdeck_pro" end
--    return ZC_CYBERDECK.TIERS[deck_implant], tier, deck_implant
--end

--function ZC_CYBERDECK.HasMilitaryOptics(ply)
--    if not IsValid(ply) then return false end
--    return ply:GetNetVar("implant_neurolink_military") or 
--           ply:GetNetVar("implant_neurolink_militaryplus") or
--           ply:GetNetVar("implant_neurolink_blackmarket")
--end

--function ZC_CYBERDECK.CanUseDeck(ply)
--    if not IsValid(ply) then return false end
--    return ZC_CYBERDECK.HasMilitaryOptics(ply) and ZC_CYBERDECK.GetTier(ply) > 0
--end

--print("[Z-City] Cyberdeck shared module loaded")
