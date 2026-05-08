PlayerInventory = PlayerInventory or {}
util.AddNetworkString("HarvestImplant")
util.AddNetworkString("HarvestOrgan")
util.AddNetworkString("NeurolinkCrack")
util.AddNetworkString("DropImplant")
util.AddNetworkString("zc_nl_boot_fail")
util.AddNetworkString("SyncInventory")
util.AddNetworkString("RequestInventory")
util.AddNetworkString("DropImplant")
util.AddNetworkString("AddToInventory")
util.AddNetworkString("BlackMarketBuy")

-- Temperature Regulator
hook.Add("ZC_BodyTemperature", "implant_temp", function(ply, org, timeValue, changeRate, MaxWarmMul, warmLoseMul)
    if not ply.organism then return end
    if ply.organism.implant_temp ~= true then return end
    org.temperature = 36.7
    org.heatbuff = 30
    return changeRate, MaxWarmMul + 99, warmLoseMul - 99
end)

-- Adrenaline Implant - Auto + Passive
hook.Add("Org Think", "implant_adrenal_passive", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_adrenal then return end
    
    -- auto inject when things start going bad, not just near death
    if org.pain > 30 or org.pulse < 60 or org.blood < 4000 then
        if (owner.implant_adrenal_auto_cd or 0) < CurTime() then
            org.adrenalineAdd = org.adrenalineAdd + 3
            owner:Notify("AUTO-INJECTING ADRENALINE", 1)
            owner.implant_adrenal_auto_cd = CurTime() + 30
        end
    end
end)

-- Adrenaline Implant - Manual
concommand.Add("implant_adrenal_use", function(ply)
    if not ply.organism.implant_adrenal then return end
    if (ply.implant_adrenal_cd or 0) > CurTime() then 
        ply:Notify("RECHARGING ADRENALINE", 1)
        return 
    end
    ply.organism.adrenalineAdd = ply.organism.adrenalineAdd + 5
    ply.implant_adrenal_cd = CurTime() + 120
    ply:Notify("ADRENALINE", 1)
end)

-- Morphine Implant - Auto
hook.Add("Org Think", "implant_morphine", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_morphine then return end
    
    if org.pain > 15 then
        if (owner.implant_morphine_cd or 0) < CurTime() then
            org.analgesia = math.min(org.analgesia + 0.3, 1)
            owner:Notify("Critical pain levels detected. Injecting Morphine.", 1)
            owner.implant_morphine_cd = CurTime() + 60
        end
    end
end)

print("implants loaded")

-- Fury-13 Implant (Berserk) - Auto near death
hook.Add("Org Think", "implant_fury13_auto", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_fury13 then return end
    if org.noradrenaline >= 0.4 then return end -- dont explode
    
    if org.pulse < 30 or org.blood < 3000 then
        if (owner.implant_fury13_auto_cd or 0) < CurTime() then
            org.berserk = org.berserk + 2
            owner:Notify("BERSERK PROTOCOL ACTIVATED", 1)
            owner.implant_fury13_auto_cd = CurTime() + 300 -- 5 min cooldown
        end
    end
end)

-- Fury-13 Implant - Manual
concommand.Add("implant_fury13_use", function(ply)
    if not ply.organism.implant_fury13 then return end
    if ply.organism.noradrenaline >= 0.4 then 
        ply:Notify("WARNING: NORADRENALINE DETECTED. INJECTION ABORTED.", 1)
        return 
    end
    if (ply.implant_fury13_cd or 0) > CurTime() then 
        ply:Notify("RECHARGING", 1)
        return 
    end
    ply.organism.berserk = ply.organism.berserk + 2
    ply.implant_fury13_cd = CurTime() + 300
    ply:Notify("BERSERK PROTOCOL ACTIVATED", 1)
end)

-- Fury-16 Implant - Manual only
concommand.Add("implant_fury16_use", function(ply)
    if not ply.organism.implant_fury16 then return end
    if ply.organism.berserk >= 0.4 then 
        ply:Notify("WARNING: STIM DETECTED. INJECTION ABORTED.", 1)
        return 
    end
    if (ply.implant_fury16_cd or 0) > CurTime() then 
        ply:Notify("RECHARGING", 1)
        return 
    end
    ply.organism.noradrenaline = ply.organism.noradrenaline + 1.25
    ply.implant_fury16_cd = CurTime() + 180 -- 3 min cooldown
    ply:Notify("NORADRENALINE SURGE", 1)
end)

-- Scrap Subdermal Armor - Sometimes works, sometimes hurts more
hook.Add("PreTraceOrganBulletDamage", "implant_subdermal_scrap", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
    local owner = org.owner
    if not IsValid(owner) then return end
    if not org.implant_subdermal_scrap then return end
    
    -- 40% chance to fail completely (double damage)
    if math.random(100) <= 40 then
        dmgInfo:ScaleDamage(1.5)
        return
    end
    
    -- Weak protection when it works
    local protection = 4
    local pen = dmgInfo:GetInflictor().bullet and dmgInfo:GetInflictor().bullet.Penetration or 1
    if protection - pen < 0 then return end
    
    dmgInfo:ScaleDamage(0.85)
    hook_info.restricted = true
end)

-- DIY Subdermal Armor - Unreliable protection values
hook.Add("PreTraceOrganBulletDamage", "implant_subdermal_diy", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
    local owner = org.owner
    if not IsValid(owner) then return end
    if not org.implant_subdermal_diy then return end
    
    -- Random protection every hit
    local protection = math.random(3, 10)
    local scaleDmg = math.Rand(0.5, 0.9)
    
    local pen = dmgInfo:GetInflictor().bullet and dmgInfo:GetInflictor().bullet.Penetration or 1
    if protection - pen < 0 then return end
    
    dmgInfo:SetDamageType(DMG_CLUB)
    dmgInfo:ScaleDamage(scaleDmg)
    hook_info.restricted = true
end)

-- Black Market Subdermal Armor - Good but causes bleeding when hit
hook.Add("PreTraceOrganBulletDamage", "implant_subdermal_blackmarket", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
    local owner = org.owner
    if not IsValid(owner) then return end
    if not org.implant_subdermal_blackmarket then return end
    
    local protection = 12
    local scaleDmg = 0.6
    
    local pen = dmgInfo:GetInflictor().bullet and dmgInfo:GetInflictor().bullet.Penetration or 1
    if protection - pen < 0 then return end
    
    dmgInfo:SetDamageType(DMG_CLUB)
    dmgInfo:ScaleDamage(scaleDmg)
    hook_info.restricted = true
    
    -- Side effect: increases bleeding when hit
    org.bleed = (org.bleed or 0) + 0.02
end)

-- Bleeding effects for Scrap/DIY/Black Market
hook.Add("Org Think", "implant_subdermal_effects_scrap", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if org.implant_subdermal_scrap then org.bleedingmul = 1.2 end  -- More bleeding
    if org.implant_subdermal_diy then org.bleedingmul = 0.8 end    -- Slightly better
    if org.implant_subdermal_blackmarket then org.bleedingmul = 0.3 end  -- Good but not perfect
end)

-- Subdermal Armor - protection values per tier
-- These plug directly into Z-City's damage input system
-- without occupying any armor slot, so real armor stacks freely

hook.Add("PreTraceOrganBulletDamage", "implant_subdermal_protection", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
    local owner = org.owner
    if not IsValid(owner) then return end

    local tier
    if org.implant_subdermal_arcom then
        tier = 3
    elseif org.implant_subdermal_osha then
        tier = 2
    elseif org.implant_subdermal_zeta then
        tier = 1
    end

    if not tier then return end

    local protection = ({14.5, 8, 16.5})[tier]
    local scaleDmg = ({0.6, 0.7, 0.5})[tier]

    local pen = dmgInfo:GetInflictor().bullet and dmgInfo:GetInflictor().bullet.Penetration or 1
    local prot = protection - pen
    if prot < 0 then return end

    dmgInfo:SetDamageType(DMG_CLUB)
    dmgInfo:SetDamageForce(dmgInfo:GetDamageForce() * 0.4)
    dmgInfo:ScaleDamage(scaleDmg)

    hook_info.restricted = true  -- blocks the normal organ damage from also firing
end)

-- Org Think: bleedingmul only
hook.Add("Org Think", "implant_subdermal_effects", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if org.implant_subdermal_arcom then
        org.bleedingmul = 0.1
    elseif org.implant_subdermal_osha then
        org.bleedingmul = 0.6
    elseif org.implant_subdermal_zeta then
        org.bleedingmul = 0.85
    end
end)

-- Scrap Air Jump - Barely works, hurts you
hook.Add("KeyPress", "implant_airjump_scrap", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism or not ply.organism.implant_airjump_scrap then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if ply:OnGround() then ply._scrapAjUsed = false return end
    if ply._scrapAjUsed then return end
    ply._scrapAjUsed = true
    
    if math.random(100) <= 40 then
        -- FAIL: backfire
        ply:SetVelocity(Vector(0, 0, -50))
        ply:EmitSound("physics/body/body_medium_impact_hard1.wav")
    else
        ply:EmitSound("airjump.wav")
        local vel = ply:GetVelocity()
        ply:SetVelocity(Vector(vel.x * -0.1, vel.y * -0.1, math.Rand(80, 400)))
    end
end)

-- DIY Air Jump
hook.Add("KeyPress", "implant_airjump_diy", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism or not ply.organism.implant_airjump_diy then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if ply:OnGround() then ply._diyAjUsed = false return end
    if ply._diyAjUsed then return end
    ply._diyAjUsed = true
    
    ply:EmitSound("airjump.wav")
    local vel = ply:GetVelocity()
    local height = math.Rand(100, 350)
    ply:SetVelocity(Vector(vel.x * -0.1, vel.y * -0.1, height))
    
    -- 20% chance to misfire sideways
    if math.random(100) <= 20 then
        local sideDir = math.random(2) == 1 and ply:GetRight() or -ply:GetRight()
        ply:SetVelocity(ply:GetVelocity() + sideDir * math.Rand(50, 300))
    end
end)

-- Black Market Air Jump
hook.Add("KeyPress", "implant_airjump_blackmarket", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism or not ply.organism.implant_airjump_blackmarket then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if ply:OnGround() then ply._bmAjUsed = false return end
    if ply._bmAjUsed then return end
    ply._bmAjUsed = true
    
    -- 10% chance to fail
    if math.random(100) <= 25 then
    print("BLACK MARKET AIR JUMP FAILED!")
    ply:EmitSound("buttons/combine_button_locked.wav")
    return
end
    
    ply:EmitSound("airjump.wav")
    local vel = ply:GetVelocity()
    ply:SetVelocity(Vector(vel.x * -0.1, vel.y * -0.1, 350))
    
    local pos = ply:GetPos()
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    effectdata:SetNormal(-Vector(0,0,1))
    effectdata:SetScale(0.4)
    util.Effect("eff_jack_rockettrail", effectdata, true, true)
end)

-- Air Jump - Low tier (just double jump)
hook.Add("KeyPress", "implant_airjump_low", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism.implant_airjump_low then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if ply:OnGround() then ply.airjump_used = false return end
    if ply.airjump_used then return end
    ply.airjump_used = true
    local vel = ply:GetVelocity()
    local reduction = -0.1
    ply:EmitSound("airjump.wav")
    ply:SetVelocity(Vector(vel.x * reduction, vel.y * reduction, 300))
end)

-- Air Jump - Mid tier (double jump + fall reduction)
hook.Add("KeyPress", "implant_airjump_mid", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism.implant_airjump_mid then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if ply:OnGround() then ply.airjump_used = false return end
    if ply.airjump_used then return end
    ply.airjump_used = true
    local vel = ply:GetVelocity()
    local reduction = -0.1
    ply:EmitSound("airjump.wav")
    ply:SetVelocity(Vector(vel.x * reduction, vel.y * reduction, 430))
end)

-- Air Jump - High tier (double jump + full fall immunity)
hook.Add("KeyPress", "implant_airjump_high", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism.implant_airjump_high then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if ply:OnGround() then ply.airjump_used = false return end
    if ply.airjump_used then return end
    ply.airjump_used = true
    local vel = ply:GetVelocity()
    local reduction = -0.1
    ply:EmitSound("airjump.wav")
    ply:SetVelocity(Vector(vel.x * reduction, vel.y * reduction, 500))
end)

-- Air Jump - Black tier (double jump + full fall immunity)
hook.Add("KeyPress", "implant_airjump_black", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism.implant_airjump_black then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if ply:OnGround() then ply.airjump_used = false return end
    if ply.airjump_used then return end
    ply.airjump_used = true
    local vel = ply:GetVelocity()
    local reduction = -0.1
    ply:EmitSound("airjump.wav")
    ply:SetVelocity(Vector(vel.x * reduction, vel.y * reduction, 1000))
end)

-- High + Black tier fall protection
hook.Add("OnPlayerHitGround", "implant_airjump_fall_protection", function(ply, inwater, onfloater, speed)
    if not ply.organism then return end
    if ply.organism.implant_airjump_high or ply.organism.implant_airjump_black then
        return true -- cancel fall stun
    end
end)

hook.Add("GetFallDamage", "implant_airjump_no_falldmg", function(ply, speed)
    if not ply.organism then return end
    if ply.organism.implant_airjump_high or ply.organism.implant_airjump_black then
        return 0
    end
end)

-- Scrap Dash - 50% fail (trips you), 50% works
hook.Add("KeyPress", "implant_dash_scrap", function(ply, key)
    if not ply.organism or not ply.organism.implant_dash_scrap then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if not ply:OnGround() then return end
    
    ply._dashTap = ply._dashTap or {}
    ply._dashCD = ply._dashCD or 0
    local now = CurTime()
    if now < ply._dashCD then return end
    
    if ply._dashTap[key] and (now - ply._dashTap[key]) < 0.3 then
        local dir = Vector(0,0,0)
        if key == IN_FORWARD then dir = ply:GetForward() end
        if key == IN_BACK then dir = -ply:GetForward() end
        if key == IN_MOVELEFT then dir = -ply:GetRight() end
        if key == IN_MOVERIGHT then dir = ply:GetRight() end
        
        if dir == Vector(0,0,0) then return end
        
        if math.random(100) <= 50 then
            -- FAIL: trip
            ply:SetVelocity(dir * -100 + Vector(0,0,50))
            ply:EmitSound("physics/body/body_medium_impact_soft1.wav")
        else
            -- Work but weak
            ply:EmitSound("dash.wav")
            ply:SetVelocity(dir * 700)
        end
        
        ply._dashCD = now + 1.5
        ply._dashTap[key] = 0
        return
    end
    ply._dashTap[key] = now
end)

-- DIY Dash - Works but sometimes double-taps itself randomly
hook.Add("KeyPress", "implant_dash_diy", function(ply, key)
    if not ply.organism or not ply.organism.implant_dash_diy then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if not ply:OnGround() then return end
    
    ply._diyDashTap = ply._diyDashTap or {}
    ply._diyDashCD = ply._diyDashCD or 0
    local now = CurTime()
    if now < ply._diyDashCD then return end
    
    if ply._diyDashTap[key] and (now - ply._diyDashTap[key]) < 0.3 then
        local dir = Vector(0,0,0)
        if key == IN_FORWARD then dir = ply:GetForward() end
        if key == IN_BACK then dir = -ply:GetForward() end
        if key == IN_MOVELEFT then dir = -ply:GetRight() end
        if key == IN_MOVERIGHT then dir = ply:GetRight() end
        
        if dir == Vector(0,0,0) then return end
        
        -- Random speed variation
        local speed = math.Rand(600, 900)
        ply:EmitSound("dash.wav")
        ply:SetVelocity(dir * speed)
        
        -- 15% chance to misfire again after 0.5s
        if math.random(100) <= 15 then
            timer.Simple(0.5, function()
                if IsValid(ply) and ply:Alive() then
                    ply:SetVelocity(dir * math.Rand(50, 200))
                    ply:EmitSound("dash.wav")
                end
            end)
        end
        
        ply._diyDashCD = now + 1.0
        ply._diyDashTap[key] = 0
        return
    end
    ply._diyDashTap[key] = now
end)

-- Black Market Dash - Works but leaves smoke and sparks
hook.Add("KeyPress", "implant_dash_blackmarket", function(ply, key)
    if not ply.organism or not ply.organism.implant_dash_blackmarket then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if not ply:OnGround() then return end
    
    ply._bmDashTap = ply._bmDashTap or {}
    ply._bmDashCD = ply._bmDashCD or 0
    local now = CurTime()
    if now < ply._bmDashCD then return end
    
    if ply._bmDashTap[key] and (now - ply._bmDashTap[key]) < 0.3 then
        local dir = Vector(0,0,0)
        if key == IN_FORWARD then dir = ply:GetForward() end
        if key == IN_BACK then dir = -ply:GetForward() end
        if key == IN_MOVELEFT then dir = -ply:GetRight() end
        if key == IN_MOVERIGHT then dir = ply:GetRight() end
        
        if dir == Vector(0,0,0) then return end
        
        ply:EmitSound("dash.wav")
        ply:SetVelocity(dir * 500)
        
        ply._bmDashCD = now + 0.8
        ply._bmDashTap[key] = 0
        return
    end
    ply._bmDashTap[key] = now
end)

--DASH
hook.Add("KeyPress", "implant_dash_low", function(ply, key)
    if not ply.organism.implant_dash_low then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if not ply:OnGround() then return end

    ply._dashTap = ply._dashTap or {}
    ply._dashCD = ply._dashCD or 0

    local now = CurTime()
    if now < ply._dashCD then return end

    if ply._dashTap[key] and (now - ply._dashTap[key]) < 0.3 then
        local dir = Vector(0,0,0)

        if key == IN_FORWARD then dir = ply:GetForward() end
        if key == IN_BACK then dir = -ply:GetForward() end
        if key == IN_MOVELEFT then dir = -ply:GetRight() end
        if key == IN_MOVERIGHT then dir = ply:GetRight() end

        if key == IN_FORWARD or key == IN_BACK or key == IN_MOVELEFT or key == IN_MOVERIGHT then
        ply:EmitSound("dash.wav")
        end
        ply:SetVelocity(dir * 600)

        ply._dashCD = now + 1.2
        ply._dashTap[key] = 0
        return
    end

    ply._dashTap[key] = now
end)

-- Dash Tier 2 (ground only, 500 speed, 1s cd)
hook.Add("KeyPress", "implant_dash_2", function(ply, key)
    if not ply.organism.implant_dash_2 then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if not ply:OnGround() then return end
    ply._dashTap = ply._dashTap or {}
    ply._dashCD = ply._dashCD or 0
    local now = CurTime()
    if now < ply._dashCD then return end
    if ply._dashTap[key] and (now - ply._dashTap[key]) < 0.25 then
        local dir = Vector(0,0,0)
        if key == IN_FORWARD then dir = ply:GetForward() end
        if key == IN_BACK then dir = -ply:GetForward() end
        if key == IN_MOVELEFT then dir = -ply:GetRight() end
        if key == IN_MOVERIGHT then dir = ply:GetRight() end
        if key == IN_FORWARD or key == IN_BACK or key == IN_MOVELEFT or key == IN_MOVERIGHT then
        ply:EmitSound("dash.wav")
        end
        ply:SetVelocity(dir * 750)
        ply._dashCD = now + 0.2
        ply._dashTap[key] = 0
        return
    end
    ply._dashTap[key] = now
end)

-- Dash Tier 3 (ground only, 700 speed, 0.7s cd)
hook.Add("KeyPress", "implant_dash_high", function(ply, key)
    if not ply.organism.implant_dash_high then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if not ply:OnGround() then return end

    ply._dashTap = ply._dashTap or {}
    ply._dashCD = ply._dashCD or 0

    local now = CurTime()
    if now < ply._dashCD then return end

    if ply._dashTap[key] and (now - ply._dashTap[key]) < 0.3 then
        local dir = Vector(0,0,0)

        if key == IN_FORWARD then dir = ply:GetForward() end
        if key == IN_BACK then dir = -ply:GetForward() end
        if key == IN_MOVELEFT then dir = -ply:GetRight() end
        if key == IN_MOVERIGHT then dir = ply:GetRight() end

        if key == IN_FORWARD or key == IN_BACK or key == IN_MOVELEFT or key == IN_MOVERIGHT then
        ply:EmitSound("dash.wav")
        end
        ply:SetVelocity(dir * 1200)

        ply._dashCD = now + 0.1
        ply._dashTap[key] = 0
        return
    end

    ply._dashTap[key] = now
end)

-- Dash Tier 4 (works in air too, 1000 speed, 0.5s cd)
hook.Add("KeyPress", "implant_dash_4", function(ply, key)
    if not ply.organism.implant_dash_4 then return end
    if not ply:Alive() or ply.organism.otrub then return end
    ply._dashTap = ply._dashTap or {}
    ply._dashCD = ply._dashCD or 0
    local now = CurTime()
    if now < ply._dashCD then return end
    if ply._dashTap[key] and (now - ply._dashTap[key]) < 0.25 then
        local dir = Vector(0,0,0)
        if key == IN_FORWARD then dir = ply:GetForward() end
        if key == IN_BACK then dir = -ply:GetForward() end
        if key == IN_MOVELEFT then dir = -ply:GetRight() end
        if key == IN_MOVERIGHT then dir = ply:GetRight() end
        if key == IN_FORWARD or key == IN_BACK or key == IN_MOVELEFT or key == IN_MOVERIGHT then
        ply:EmitSound("dash.wav")
        end
        ply:SetVelocity(dir * 1000)
        ply._dashCD = now + 2
        ply._dashTap[key] = 0
        return
    end
    ply._dashTap[key] = now
end)

-- Dash Tier 5 (air dash, 2000 speed, 0.25s cd, Eclipse-tech)
hook.Add("KeyPress", "implant_dash_5", function(ply, key)
    if not ply.organism.implant_dash_5 then return end
    if not ply:Alive() or ply.organism.otrub then return end
    ply._dashTap = ply._dashTap or {}
    ply._dashCD = ply._dashCD or 0
    local now = CurTime()
    if now < ply._dashCD then return end
    if ply._dashTap[key] and (now - ply._dashTap[key]) < 0.25 then
        local dir = Vector(0,0,0)
        if key == IN_FORWARD then dir = ply:GetForward() end
        if key == IN_BACK then dir = -ply:GetForward() end
        if key == IN_MOVELEFT then dir = -ply:GetRight() end
        if key == IN_MOVERIGHT then dir = ply:GetRight() end
        if key == IN_FORWARD or key == IN_BACK or key == IN_MOVELEFT or key == IN_MOVERIGHT then
        ply:EmitSound("dash.wav")
        end
        ply:SetVelocity(dir * 2000)
        ply._dashCD = now + 0.25
        ply._dashTap[key] = 0
        return
    end
    ply._dashTap[key] = now
end)

-- Scrap Charge Jump - Takes longer, weaker, can explode
local CHARGEJUMP_SCRAP = { maxCharge = 2.0, baseZ = 50, chargeZ = 200 }

hook.Add("KeyRelease", "implant_chargejump_scrap_release", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism or not ply.organism.implant_chargejump_scrap then return end
    ply._scrapChargeActive = false
    if not ply._scrapChargeStart then return end
    local held = CurTime() - ply._scrapChargeStart
    ply._scrapChargeStart = nil
    if held < 0.8 then return end
    if not ply:OnGround() then return end
    
    -- 30% chance to explode
    if math.random(100) <= 30 then
        ply:EmitSound("crack.wav")
        ply:SetVelocity(Vector(math.Rand(-300, 300), math.Rand(-300, 300), math.Rand(100, 300)))
        local explosion = ents.Create("env_explosion")
        explosion:SetPos(ply:GetPos())
        explosion:SetOwner(ply)
        explosion:Spawn()
        explosion:SetKeyValue("iMagnitude", "30")
        explosion:Fire("Explode", 0, 0)
        return
    end
    
    local cfg = CHARGEJUMP_SCRAP
    local charge = math.Clamp(held, 0, cfg.maxCharge)
    local upForce = cfg.baseZ + charge * cfg.chargeZ
    local current = ply:GetVelocity()
    ply:SetVelocity(Vector(current.x, current.y, upForce))  -- Только Z, сохраняем горизонтальную скорость
    ply:EmitSound("chargejump.wav")
end)

-- DIY Charge Jump - Random power
local CHARGEJUMP_DIY = { maxCharge = 2.5, baseZ = 100, chargeZ = 200 }

hook.Add("KeyPress", "implant_chargejump_diy_press", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism or not ply.organism.implant_chargejump_diy then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if not ply:OnGround() then return end
    ply._diyChargeStart = CurTime()
    ply._diyChargeActive = true
end)

hook.Add("SetupMove", "implant_chargejump_diy_suppress", function(ply, mv)
    if not ply._diyChargeActive then return end
    if (CurTime() - ply._diyChargeStart) < 0.6 then return end
    mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
end)

hook.Add("KeyRelease", "implant_chargejump_diy_release", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism or not ply.organism.implant_chargejump_diy then return end
    ply._diyChargeActive = false
    if not ply._diyChargeStart then return end
    local held = CurTime() - ply._diyChargeStart
    ply._diyChargeStart = nil
    if held < 0.6 then return end
    if not ply:OnGround() then return end
    
    local cfg = CHARGEJUMP_DIY
    local charge = math.Clamp(held, 0, cfg.maxCharge)
    local upForce = cfg.baseZ + charge * cfg.chargeZ * math.Rand(0.3, 2)
    ply:SetVelocity(-ply:GetVelocity())
    ply:EmitSound("chargejump.wav")
    ply:SetVelocity(Vector(0, 0, upForce))
    
    -- Sometimes goes sideways
    if math.random(100) <= 25 then
        ply:SetVelocity(ply:GetVelocity() + Vector(math.Rand(-200, 200), math.Rand(-200, 200), 0))
    end
end)

-- Black Market Charge Jump - Works but overheats, can fake you
local CHARGEJUMP_BM = { maxCharge = 2.0, baseZ = 80, chargeZ = 250 }

hook.Add("KeyPress", "implant_chargejump_bm_press", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism or not ply.organism.implant_chargejump_blackmarket then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if not ply:OnGround() then return end
    ply._bmChargeStart = CurTime()
    ply._bmChargeActive = true
end)

hook.Add("SetupMove", "implant_chargejump_bm_suppress", function(ply, mv)
    if not ply._bmChargeActive then return end
    if (CurTime() - ply._bmChargeStart) < 0.5 then return end
    mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
end)

hook.Add("KeyRelease", "implant_chargejump_bm_release", function(ply, key)
    if key ~= IN_JUMP then return end
    if not ply.organism or not ply.organism.implant_chargejump_blackmarket then return end
    ply._bmChargeActive = false
    if not ply._bmChargeStart then return end
    local held = CurTime() - ply._bmChargeStart
    ply._bmChargeStart = nil
    if held < 0.5 then return end
    if not ply:OnGround() then return end
    
    local cfg = CHARGEJUMP_BM
    local charge = math.Clamp(held, 0, cfg.maxCharge)
    local upForce = cfg.baseZ + charge * cfg.chargeZ
    local current = ply:GetVelocity()
    ply:SetVelocity(Vector(current.x, current.y, upForce))
    ply:EmitSound("chargejump.wav")
    
    -- Overheat damage
    if held > 1.2 then
        ply:EmitSound("buttons/combine_button_locked.wav")
        if ply.organism then
            ply.organism.painadd = (ply.organism.painadd or 0) + 30
        end
    end
    
    -- Exhaust effect
    local pos = ply:GetPos()
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    effectdata:SetNormal(-Vector(0,0,1))
    effectdata:SetScale(0.5)
    util.Effect("eff_jack_rockettrail", effectdata, true, true)
end)

-- Charge Jump (5 tiers)
-- Tier config: { maxCharge, baseZ, chargeZ }
local CHARGEJUMP = {
    [1] = { maxCharge = 1.0, baseZ = 200, chargeZ = 100  },
    [2] = { maxCharge = 1.5, baseZ = 200, chargeZ = 150 },
    [3] = { maxCharge = 2.0, baseZ = 250, chargeZ = 200 },
    [4] = { maxCharge = 2.5, baseZ = 300, chargeZ = 250 },
    [5] = { maxCharge = 3.0, baseZ = 400, chargeZ = 300 },
}

local function getChargeJumpTier(ply)
    local org = ply.organism
    if not org then return nil end
    for t = 5, 1, -1 do
        if org["implant_chargejump_" .. t] then return t end
    end
    return nil
end

-- KeyPress: mark intent to charge immediately
hook.Add("KeyPress", "implant_chargejump_press", function(ply, key)
    if key ~= IN_JUMP then return end
    local tier = getChargeJumpTier(ply)
    if not tier then return end
    if not ply:Alive() or ply.organism.otrub then return end
    if not ply:OnGround() then return end
    ply.chargestart = CurTime()
    ply:SetNetVar("chargestart", CurTime())
    ply.chargejump_active = true  -- set immediately for SetupMove
end)

hook.Add("SetupMove", "implant_chargejump_suppress", function(ply, mv)
    if not ply.chargejump_active then return end
    if not ply.chargestart then return end
    if not getChargeJumpTier(ply) then return end
    -- only suppress default jump once player has held long enough
    if (CurTime() - ply.chargestart) < 0.6 then return end
    mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
end)

hook.Add("KeyRelease", "implant_chargejump_release", function(ply, key)
    if key ~= IN_JUMP then return end
    local tier = getChargeJumpTier(ply)
    if not tier then return end

    ply.chargejump_active = false

    if not ply.chargestart then return end
    local held = CurTime() - ply.chargestart
    ply.chargestart = nil

    -- ignore short taps, let the default jump happen naturally
    if held < 0.6 then return end

    if not ply:OnGround() then return end

    local cfg = CHARGEJUMP[tier]
    local charge = math.Clamp(held, 0, cfg.maxCharge)
    local upForce = cfg.baseZ + charge * cfg.chargeZ
    local current = ply:GetVelocity()
    ply:SetVelocity(-current)
    ply:EmitSound("chargejump.wav")
    ply:SetVelocity(Vector(0, 0, upForce))
end)                                                     --короче они работают странно игрок перед заряженным прыжком прыгает ебаный гмод чекает только нажатие а не зажатие но лан

-- Bone Lacing Tier 1 (very slow regen, no dislocation prevention)
hook.Add("Org Think", "implant_bone_lacing_1", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bone_lacing_1 then return end
    org.rarm = math.max(org.rarm - timeValue / 120, 0)
    org.larm = math.max(org.larm - timeValue / 120, 0)
    org.rleg = math.max(org.rleg - timeValue / 120, 0)
    org.lleg = math.max(org.lleg - timeValue / 120, 0)
    org.chest = math.max(org.chest - timeValue / 120, 0)
    org.skull = math.max(org.skull - timeValue / 120, 0)
end)

-- Bone Lacing Tier 2 (faster regen, minor dislocation resistance)
hook.Add("Org Think", "implant_bone_lacing_2", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bone_lacing_2 then return end
    org.rarm = math.max(org.rarm - timeValue / 90, 0)
    org.larm = math.max(org.larm - timeValue / 90, 0)
    org.rleg = math.max(org.rleg - timeValue / 90, 0)
    org.lleg = math.max(org.lleg - timeValue / 90, 0)
    org.chest = math.max(org.chest - timeValue / 90, 0)
    org.skull = math.max(org.skull - timeValue / 90, 0)
    if math.random(100) > 50 then
        org.rarmdislocation = false
        org.larmdislocation = false
    end
end)

-- Bone Lacing Tier 3 (fast regen, prevents dislocations)
hook.Add("Org Think", "implant_bone_lacing_3", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bone_lacing_3 then return end
    org.rarm = math.max(org.rarm - timeValue / 60, 0)
    org.larm = math.max(org.larm - timeValue / 60, 0)
    org.rleg = math.max(org.rleg - timeValue / 60, 0)
    org.lleg = math.max(org.lleg - timeValue / 60, 0)
    org.chest = math.max(org.chest - timeValue / 60, 0)
    org.skull = math.max(org.skull - timeValue / 60, 0)
    org.rarmdislocation = false
    org.larmdislocation = false
    org.rlegdislocation = false
    org.llegdislocation = false
    org.jawdislocation = false
end)

-- Bone Lacing Tier 4 (very fast regen, bones almost never break)
hook.Add("Org Think", "implant_bone_lacing_4", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bone_lacing_4 then return end
    org.rarm = math.max(org.rarm - timeValue / 20, 0)
    org.larm = math.max(org.larm - timeValue / 20, 0)
    org.rleg = math.max(org.rleg - timeValue / 20, 0)
    org.lleg = math.max(org.lleg - timeValue / 20, 0)
    org.chest = math.max(org.chest - timeValue / 20, 0)
    org.skull = math.max(org.skull - timeValue / 20, 0)
    org.pelvis = math.max(org.pelvis - timeValue / 20, 0)
    org.rarmdislocation = false
    org.larmdislocation = false
    org.rlegdislocation = false
    org.llegdislocation = false
    org.jawdislocation = false
end)

-- Bone Lacing Tier 5 (full immunity)
hook.Add("Org Think", "implant_bone_lacing_5", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bone_lacing_5 then return end
    org.rarm = 0
    org.larm = 0
    org.rleg = 0
    org.lleg = 0
    org.chest = 0
    org.skull = 0
    org.jaw = 0
    org.pelvis = 0
    org.spine1 = 0
    org.spine2 = 0
    org.spine3 = 0
    org.rarmdislocation = false
    org.larmdislocation = false
    org.rlegdislocation = false
    org.llegdislocation = false
    org.jawdislocation = false
end)

-- Cardiac Implant Tier 1 (prevents instant heartstop, minimal pulse support)
hook.Add("Org Think", "implant_cardiac_1", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_cardiac_1 then return end
    if org.heartstop then
        org.heartstop = false
        org.pulse = math.max(org.pulse, 10)
    end
end)

-- Cardiac Implant Tier 2 (prevents heartstop, keeps pulse above 10) --upd держит пульс над 30 --upd вернул
hook.Add("Org Think", "implant_cardiac_2", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_cardiac_2 then return end
    if org.heartstop then
        org.heartstop = false
        org.pulse = math.max(org.pulse, 10)
    end
    if org.pulse < 10 then
        org.pulse = math.Approach(org.pulse, 10, timeValue * 3)
    end
end)

-- Cardiac Implant Tier 3
hook.Add("Org Think", "implant_cardiac_3", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_cardiac_3 then return end
    if org.heartstop then
        org.heartstop = false
        org.pulse = math.max(org.pulse, 20)
    end
    org.pulse = math.Clamp(org.pulse, 20, 160)
    org.heartbeat = math.Clamp(org.heartbeat, 30, 160)
end)

-- Cardiac Implant Tier 4
hook.Add("Org Think", "implant_cardiac_4", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_cardiac_4 then return end
    if org.heartstop then
        org.heartstop = false
        org.pulse = math.max(org.pulse, 30)
    end
    org.pulse = math.Clamp(org.pulse, 30, 140)
    org.heartbeat = math.Clamp(org.heartbeat, 45, 140)
end)

-- Cardiac Implant Tier 5
hook.Add("Org Think", "implant_cardiac_5", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_cardiac_5 then return end
    org.heartstop = false
    org.lungsfunction = true
    org.pulse = math.Clamp(org.pulse, 40, 120)
    org.heartbeat = math.Clamp(org.heartbeat, 60, 120)
end)

-- Blood Filter Tier 1 (slow CO reduction, minor poison resistance)
hook.Add("Org Think", "implant_bloodfilter_1", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bloodfilter_1 then return end
    org.CO = math.max(org.CO - timeValue * 0.5, 0)
    org.COregen = math.max(org.COregen - timeValue * 0.5, 0)
    org.internalBleed = math.max(org.internalBleed - timeValue * 0.5, 0)
end)

-- Blood Filter Tier 2 (faster CO reduction, better poison resistance)
hook.Add("Org Think", "implant_bloodfilter_2", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bloodfilter_2 then return end
    org.CO = math.max(org.CO - timeValue * 1, 0)
    org.COregen = math.max(org.COregen - timeValue * 1, 0)
    org.poison4 = nil
    org.internalBleed = math.max(org.internalBleed - timeValue * 1, 0)
end)

-- Blood Filter Tier 3 (good CO reduction, poison immunity, reduced internal bleed)
hook.Add("Org Think", "implant_bloodfilter_3", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bloodfilter_3 then return end
    org.CO = math.max(org.CO - timeValue * 2, 0)
    org.COregen = math.max(org.COregen - timeValue * 2, 0)
    org.poison4 = nil
    org.internalBleed = math.max(org.internalBleed - timeValue * 2, 0)
end)

-- Blood Filter Tier 4 (great CO reduction, poison immunity, eliminates internal bleed)
hook.Add("Org Think", "implant_bloodfilter_4", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bloodfilter_4 then return end
    org.CO = math.max(org.CO - timeValue * 4, 0)
    org.COregen = math.max(org.COregen - timeValue * 4, 0)
    org.poison4 = nil
    org.internalBleed = 0
end)

-- Blood Filter Tier 5 (full blood purification, complete toxin immunity)
hook.Add("Org Think", "implant_bloodfilter_5", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bloodfilter_5 then return end
    org.CO = 0
    org.COregen = 0
    org.poison4 = nil
    org.internalBleed = 0
    org.hemotransfusionshock = 0
end)

-- Blood Refill Tier 1                               -- надо точно будет над балансом подумать
hook.Add("Org Think", "implant_bloodrefill_1", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bloodrefill_1 then return end
    owner.bloodrefill_1_pool = owner.bloodrefill_1_pool or 1000
    if org.bleed < 0.05 and org.internalBleed < 0.5 and owner.bloodrefill_1_pool > 0 then
        local regen = math.min(timeValue * 10, owner.bloodrefill_1_pool)
        org.blood = math.min(org.blood + regen, 5000)
        owner.bloodrefill_1_pool = owner.bloodrefill_1_pool - regen
    end
    if owner.bloodrefill_1_pool <= 0 then
        owner.bloodrefill_1_recharge = owner.bloodrefill_1_recharge or CurTime() + 120
        if CurTime() > owner.bloodrefill_1_recharge then
            owner.bloodrefill_1_pool = 1000
            owner.bloodrefill_1_recharge = nil
        end
    end
end)

-- Blood Refill Tier 2
hook.Add("Org Think", "implant_bloodrefill_2", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bloodrefill_2 then return end
    owner.bloodrefill_2_pool = owner.bloodrefill_2_pool or 2000
    if org.bleed < 0.05 and org.internalBleed < 0.5 and owner.bloodrefill_2_pool > 0 then
        local regen = math.min(timeValue * 25, owner.bloodrefill_2_pool)
        org.blood = math.min(org.blood + regen, 5000)
        owner.bloodrefill_2_pool = owner.bloodrefill_2_pool - regen
    end
    if owner.bloodrefill_2_pool <= 0 then
        owner.bloodrefill_2_recharge = owner.bloodrefill_2_recharge or CurTime() + 90
        if CurTime() > owner.bloodrefill_2_recharge then
            owner.bloodrefill_2_pool = 2000
            owner.bloodrefill_2_recharge = nil
        end
    end
end)

-- Blood Refill Tier 3
hook.Add("Org Think", "implant_bloodrefill_3", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bloodrefill_3 then return end
    owner.bloodrefill_3_pool = owner.bloodrefill_3_pool or 3000
    if org.bleed < 0.05 and org.internalBleed < 0.5 and owner.bloodrefill_3_pool > 0 then
        local regen = math.min(timeValue * 50, owner.bloodrefill_3_pool)
        org.blood = math.min(org.blood + regen, 5000)
        owner.bloodrefill_3_pool = owner.bloodrefill_3_pool - regen
    end
    if owner.bloodrefill_3_pool <= 0 then
        owner.bloodrefill_3_recharge = owner.bloodrefill_3_recharge or CurTime() + 60
        if CurTime() > owner.bloodrefill_3_recharge then
            owner.bloodrefill_3_pool = 3000
            owner.bloodrefill_3_recharge = nil
        end
    end
end)

-- Blood Refill Tier 4
hook.Add("Org Think", "implant_bloodrefill_4", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bloodrefill_4 then return end
    owner.bloodrefill_4_pool = owner.bloodrefill_4_pool or 4000
    if org.bleed < 0.5 and owner.bloodrefill_4_pool > 0 then
        local regen = math.min(timeValue * 80, owner.bloodrefill_4_pool)
        org.blood = math.min(org.blood + regen, 5000)
        owner.bloodrefill_4_pool = owner.bloodrefill_4_pool - regen
    end
    if owner.bloodrefill_4_pool <= 0 then
        owner.bloodrefill_4_recharge = owner.bloodrefill_4_recharge or CurTime() + 60
        if CurTime() > owner.bloodrefill_4_recharge then
            owner.bloodrefill_4_pool = 4000
            owner.bloodrefill_4_recharge = nil
        end
    end
end)

-- Blood Refill Tier 5
hook.Add("Org Think", "implant_bloodrefill_5", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_bloodrefill_5 then return end
    owner.bloodrefill_5_pool = owner.bloodrefill_5_pool or 5000
    if owner.bloodrefill_5_pool > 0 then
        local regen = math.min(timeValue * 120, owner.bloodrefill_5_pool)
        org.blood = math.min(org.blood + regen, 5000)
        owner.bloodrefill_5_pool = owner.bloodrefill_5_pool - regen
    end
    if owner.bloodrefill_5_pool <= 0 then
        owner.bloodrefill_5_recharge = owner.bloodrefill_5_recharge or CurTime() + 60
        if CurTime() > owner.bloodrefill_5_recharge then
            owner.bloodrefill_5_pool = 5000
            owner.bloodrefill_5_recharge = nil
        end
    end
end)

-- Pain Dampener Tier 1 (slight analgesia, minor shock reduction)
hook.Add("Org Think", "implant_paindampener_1", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_paindampener_1 then return end
    org.analgesia = math.max(org.analgesia, 0.1)
    org.shock = math.max(org.shock - timeValue * 1, 0)
end)

-- Pain Dampener Tier 2
hook.Add("Org Think", "implant_paindampener_2", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_paindampener_2 then return end
    org.analgesia = math.max(org.analgesia, 0.2)
    org.shock = math.max(org.shock - timeValue * 3, 0)
    org.avgpain = math.max(org.avgpain - timeValue * 2, 0)
end)

-- Pain Dampener Tier 3
hook.Add("Org Think", "implant_paindampener_3", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_paindampener_3 then return end
    org.analgesia = math.max(org.analgesia, 0.4)
    org.shock = math.max(org.shock - timeValue * 6, 0)
    org.avgpain = math.max(org.avgpain - timeValue * 4, 0)
    org.painadd = org.painadd * 0.8
end)

-- Pain Dampener Tier 4
hook.Add("Org Think", "implant_paindampener_4", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_paindampener_4 then return end
    org.analgesia = math.max(org.analgesia, 0.6)
    org.shock = math.max(org.shock - timeValue * 10, 0)
    org.avgpain = math.max(org.avgpain - timeValue * 8, 0)
    org.painadd = org.painadd * 0.5
    org.immobilization = math.max(org.immobilization - timeValue * 5, 0)
end)

-- Pain Dampener Tier 5 (near immunity)
hook.Add("Org Think", "implant_paindampener_5", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_paindampener_5 then return end
    org.analgesia = math.max(org.analgesia, 0.9)
    org.shock = math.max(org.shock - timeValue * 20, 0)
    org.avgpain = math.max(org.avgpain - timeValue * 15, 0)
    org.painadd = org.painadd * 0.1
    org.immobilization = math.max(org.immobilization - timeValue * 15, 0)
    org.disorientation = math.max(org.disorientation - timeValue * 5, 0)
end)

-- Skull Reinforcement (5 tiers, prevents unconsciousness)
hook.Add("Org Think", "implant_skull_reinforcement", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end

    local tier
    for t = 5, 1, -1 do
        if org["implant_skull_" .. t] then tier = t break end
    end
    if not tier then return end

    local blockChance = { 0.3, 0.5, 0.7, 0.9, 1.0 }

    if org.needotrub and math.random() < blockChance[tier] then
        org.needotrub = false
        org.otrub = false
        org.consciousness = math.min(org.consciousness + 0.3, 1)
    end
end)

-- Scrap Synth Lungs - Chokes, drains stamina, barely works
hook.Add("Org Think", "implant_synth_lungs_scrap", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_synth_lungs_scrap then return end
    
    local base = 60 * 3
    org.stamina.range = base * 1.2  -- Worse than normal
    org.stamina.regen = 1.5        -- Slow regen
    
    -- Drain stamina when moving fast (inefficient lungs)
    local vel = owner:GetVelocity():Length()
    if vel > 400 then
        org.stamina[1] = math.max(org.stamina[1] - timeValue * 10, 5)
    end
    
    -- 20% chance to choke hard (was 15%)
    if math.random(1000) <= 10 then
        org.o2[1] = math.max(org.o2[1] - 10, 0)  -- Was -5, now -10
    end
    
    -- Below 30% stamina = gasping
    if org.stamina[1] < org.stamina.range * 0.3 then
        org.o2[1] = math.max(org.o2[1] - timeValue * 3, 0)
        if math.random(100) <= 10 then
            owner:EmitSound("physics/body/body_medium_impact_soft1.wav")
        end
    end
    
    org.stamina[1] = math.max(org.stamina[1], 5)
end)

-- DIY Synth Lungs - Unstable, sometimes super boost, sometimes nothing
hook.Add("Org Think", "implant_synth_lungs_diy", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_synth_lungs_diy then return end
    
    if not org._diyLungsTimer then org._diyLungsTimer = 0 end
    
    -- Randomly switch between good and bad every 10-30 seconds
    if CurTime() > org._diyLungsTimer then
        org._diyLungsTimer = CurTime() + math.Rand(10, 30)
        org._diyLungsBoost = math.Rand(0.2, 2.0)
    end
    
    local boost = org._diyLungsBoost or 1.0
    local base = 60 * 3
    org.stamina.range = base * (1.0 + boost * 0.5)
    org.stamina.regen = 1.0 * boost
    
    -- Boost too high = pain
    if boost > 1.7 then
        org.painadd = (org.painadd or 0) + timeValue * 2
    end
    
    org.stamina[1] = math.max(org.stamina[1], 10)
end)

-- Black Market Synth Lungs - Great stamina, addictive (withdrawal symptoms)
hook.Add("Org Think", "implant_synth_lungs_blackmarket", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.implant_synth_lungs_blackmarket then return end
    
    local base = 60 * 3
    org.stamina.range = base * 1.8
    org.stamina.regen = 1.3
    
    -- Addiction mechanic: if stamina is high for too long, get withdrawal
    local staminaPct = org.stamina[1] / org.stamina.range
    if staminaPct > 0.8 then
        org._bmLungsAddiction = (org._bmLungsAddiction or 0) + timeValue
    else
        org._bmLungsAddiction = math.max((org._bmLungsAddiction or 0) - timeValue * 2, 0)
    end
    
    -- Withdrawal: pain and disorientation when stamina runs out --хуйня какаято
    if org._bmLungsAddiction > 30 and org.stamina[1] < 20 then
        org.painadd = (org.painadd or 0) + timeValue * 5
        org.disorientation = math.min((org.disorientation or 0) + timeValue * 3, 10)
        if math.random(1000) <= 10 then
            owner:EmitSound("buttons/combine_button_locked.wav")
        end
    end
    
    org.stamina[1] = math.max(org.stamina[1], 10)
end)

-- Synth Lungs (5 tiers, stamina implant)
hook.Add("Org Think", "implant_synth_lungs", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end

    local tier
    for t = 5, 1, -1 do
        if org["implant_synth_lungs_" .. t] then tier = t break end
    end
    if not tier then return end

    -- T1: +20% max stamina, +10% regen
    -- T2: +40% max, +25% regen
    -- T3: +70% max, +50% regen
    -- T4: +100% max, +100% regen
    -- T5: +150% max, +200% regen, never fully exhaust
    local maxMul  = { 1.2, 1.4, 1.7, 2.0, 2.5 }
    local regenMul = { 1.05, 1.2, 1.2, 1.3, 1.4 }

    local base = 60 * 3
    org.stamina.range = base * maxMul[tier]
    org.stamina.regen = 1 * regenMul[tier]

    -- T5: prevent full exhaustion
    if tier == 5 then
        org.stamina[1] = math.max(org.stamina[1], 20)
    end
end)

-- Crack on skull damage (head impacts/falls)
hook.Add("Org Think", "Neurolink_SkullCrack", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    
    local hasNeurolink = owner:GetNetVar("implant_neurolink_basic") or 
                 owner:GetNetVar("implant_neurolink_military") or 
                 owner:GetNetVar("implant_neurolink_militaryplus") or
                 owner:GetNetVar("implant_neurolink_scrap") or
                 owner:GetNetVar("implant_neurolink_diy") or
                 owner:GetNetVar("implant_neurolink_blackmarket")
    if not hasNeurolink then return end
    
    -- Store previous skull value
    org._lastSkull = org._lastSkull or 0
    
    -- If skull just got damaged
    if org.skull > org._lastSkull and org.skull > 0.1 then
        local intensity = math.Clamp(org.skull * 2, 0.05, 0.5)
        
        net.Start("NeurolinkCrack")
        net.WriteFloat(intensity)
        net.Send(owner)
    end
    
    org._lastSkull = org.skull
end)

if SERVER then
    hook.Add("HomigradDamage", "Neurolink_SendCrack", function(ply, dmgInfo, hitgroup, ent)
        if not ply:IsPlayer() or not ply:Alive() then return end
        
        local hasNeurolink = ply.organism and (
    ply.organism.implant_neurolink_basic or 
    ply.organism.implant_neurolink_military or 
    ply.organism.implant_neurolink_militaryplus or
    ply.organism.implant_neurolink_scrap or
    ply.organism.implant_neurolink_diy or
    ply.organism.implant_neurolink_blackmarket
)

        if not hasNeurolink then return end
        
        local intensity = 0
        
        if hitgroup == HITGROUP_HEAD then
            intensity = math.Clamp(dmgInfo:GetDamage() / 80, 0.05, 0.8)
        elseif dmgInfo:IsDamageType(DMG_BLAST) then
            intensity = math.Clamp(dmgInfo:GetDamage() / 100, 0.05, 0.8)
        end
        
        if intensity > 0 then
            net.Start("NeurolinkCrack") --ВСЕ ДОЛЖНО
            net.WriteFloat(intensity)
            net.Send(ply)
        end
    end)
end

function CalculateChromaLoad(ply)
    if ZC_IMPLANTS and ZC_IMPLANTS.CalculateChromaLoad then
        return ZC_IMPLANTS.CalculateChromaLoad(ply)
    end
    return 0
end

local function ResetPsychosis(ply)
    local o = ply.organism
    if not o then return end

    o.psychosisTimer = 0
    o._rageStarted = false
    o._rageTimer = nil
    o._rageKillTimer = nil
end

hook.Add("PlayerDeath", "PsychosisReset", function(ply)
    ResetPsychosis(ply)
end)

hook.Add("PlayerSpawn", "PsychosisResetSpawn", function(ply)
    ResetPsychosis(ply)
    ply:SendLua([[
        if _psyMusic then _psyMusic:Stop() _psyMusic = nil end
    ]])
end)

hook.Add("Org Think", "ChromaLoad_Psychosis", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    
    local load = CalculateChromaLoad(owner)
    owner.chromaLoad = load
    
    if not owner._debugTimer or CurTime() > owner._debugTimer then
        owner._debugTimer = CurTime() + 2
        --print("CHROMA DEBUG: nick=" .. owner:Nick() .. " load=" .. load .. " timer=" .. (org.psychosisTimer or 0))   --дебаг для вычесления хрома лоудааау B)
    end

    if load >= 100 then
    local mult = 1 + math.max((load - 100) * 0.03, 0)

    org.psychosisTimer = (org.psychosisTimer or 0) + timeValue * 0.007 * mult --мультиплаер скорости прогрессирования киберпсихоза если ктото хочет потестить ставьте 0.1 или чето такое
    
-- Psycho phrases
if not org._lastPsychoPhrase or org.psychosisTimer - org._lastPsychoPhrase > 15 then
    local phrases = {
        {20,  "Hm, should probably take some naloxon soon."},
        {25, "Feeling a bit off today."},
        {30, "Gotta remember to take my chroma meds."},
        {35, "Head's starting to hurt..."},
        {40, "Where did I put my naloxon?"},
        {45, "Really need those meds right now."},
        {50, "Where is my naloxon.."},
        {55, "The voices are getting louder."},
        {60, "Where the fuck is my nalox?!"},
        {65, "I can feel the chrome crawling."},
        {70, "Everything is so loud..."},
        {75, "HAHAHA..."},
        {80, "I can see the code behind everything."},
        {85, "I'm a machine.."},
        {90, "Meat is a prison."},
        {91, "Meat... IS weak"},
        {92, "THE FLESH IS A CAGE"},
        {94, "CHROME IS ETERNAL"},
        {95, "...release me..."},              -- почемуто после смерти от психоза и респавна не работают
    } 
    for _, phrase in ipairs(phrases) do
        if org.psychosisTimer >= phrase[1] and (org._lastPhraseLevel or 0) < phrase[1] then
            owner:Notify(phrase[2], 3)
            org._lastPhraseLevel = phrase[1]
            org._lastPsychoPhrase = org.psychosisTimer
        end
    end
end

-- ПСИХОЗ
local t = org.psychosisTimer or 0

-- СТАДИЯ 1 (30+)
if t > 30 and t <= 60 then
    org.disorientation = math.random(0.1, 1)
end

-- СТАДИЯ 2 (60+)
if t > 60 and t <= 80 then
    org.painadd = 0.1
    org.disorientation = math.random(0.5, 1)
    org.shock = math.random(0.1, 0.5)
end

-- СТАДИЯ 3 (80+)
if t > 80 and t < 100 then
    org.painadd = 0.4
    org.disorientation = math.random(0.1, 0.3)
    org.shock = math.random(0.1, 0.5)
    org.immobilization = math.random(0.1, 1)
end


-- РЕЙДЖ СТАРТ            -- переработать надо полная хуйня честно
if org.psychosisTimer >= 97 and not org._rageStarted then
    org._rageKillTimer = CurTime() + 60
    org._rageStarted = true
    org._rageTimer = CurTime() + 30
    org.painadd = 0
    org.disorientation = 0
    org.immobilization = 0
    org.shock = 0
    org.adrenalineAdd = (org.adrenalineAdd or 0) + 20

    owner:Notify("NEED TO KILL", 4)

    timer.Simple(1, function()
        if IsValid(owner) then
            owner:Notify("HUMANS ARE WEAK", 4)
        end
    end)

    -- МУЗЫКА (ВОЗВРАЩАЮ ЕЁ)
    owner:SendLua([[
    if _psyMusic then
        _psyMusic:Stop()
        _psyMusic = nil
    end

    sound.PlayFile("sound/zcity_implants/psycho_music.mp3", "noplay loop", function(station)
        if IsValid(station) then
            station:Play()
            _psyMusic = station
        end
    end)
]])
end


if org._rageStarted then
    local ply = owner

    org._rageKillTimer = org._rageKillTimer or (CurTime() + 60)

    if ply._lastShootTime and CurTime() - ply._lastShootTime < 1 then
        org._rageKillTimer = CurTime() + 60
    end

    local vel = ply:GetVelocity():Length()

    if vel > 220 then
        org._rageKillTimer = CurTime() + 60
    end

    if CurTime() > org._rageKillTimer then
        hg.ExplodeHead(owner)
        return
    end
end

    else
        org.psychosisTimer = 0
    end
end)

hook.Add("EntityFireBullets", "PsychosisShootDetect", function(ent)
    if IsValid(ent) and ent:IsPlayer() then
        ent._lastShootTime = CurTime()
    end
end)

-- ЗАТЫЧКА НАЛОКСОН потом поменять или похуй нет незнаю
hook.Add("Org Think", "Naloxone_PsychosisReset", function(owner, org, timeValue)
    if not owner:IsPlayer() then return end
    if not org.naloxoneadd then return end
    if org.naloxoneadd > 0 then
        org.psychosisTimer = 0 --ахаххахаха чел
    end
end)

include("zcity_implants/server/sv_harvest.lua")
