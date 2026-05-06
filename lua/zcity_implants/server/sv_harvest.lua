-- Harvest organs / implants from bodies (client UI finishes, then sends these nets).
-- Requires: AddToInventory from sv_inventory.lua; network strings registered in sv_implants.lua.

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
