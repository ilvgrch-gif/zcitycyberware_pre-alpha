-- https://github.com/uzelezz123/Z-City/blob/main/lua/weapons/rasta.lua
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik1_base"
SWEP.PrintName = "Tablet"
SWEP.Instructions = ""
SWEP.Category = "Weapons - Other"
SWEP.Instructions = "Just a tablet"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_phone")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_phone"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.WorldModel = "models/nirrti/tablet/tablet_sfm.mdl"
SWEP.ViewModel = ""
SWEP.HoldType = "normal"

SWEP.setrhik = true
SWEP.setlhik = true

SWEP.LHPos = Vector(0,-6.6,0)
SWEP.LHAng = Angle(0,0,180)

SWEP.RHPosOffset = Vector(0,0,-7.6)
SWEP.RHAngOffset = Angle(0,15,-90)

SWEP.LHPosOffset = Vector(0,0,-0.4)
SWEP.LHAngOffset = Angle(5,0,15)

SWEP.handPos = Vector(0,0,0)
SWEP.handAng = Angle(0,0,0)

SWEP.UsePistolHold = false

SWEP.offsetVec = Vector(5,-7,-1)
SWEP.offsetAng = Angle(0,90,195)   

SWEP.HeadPosOffset = Vector(15,1.7,-5)
SWEP.HeadAngOffset = Angle(-90,0,-90)

SWEP.BaseBone = "ValveBiped.Bip01_Head1"

SWEP.HoldLH = "normal"
SWEP.HoldRH = "normal"

SWEP.HoldClampMax = 35
SWEP.HoldClampMin = 35

SWEP.Skin = 1

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()
    
end

local BlackList = {
    ["weapon_fists"] = true,
    ["weapon_medkit"] = true,
    ["gmod_tool"] = true,
    ["weapon_physgun"] = true,
    ["npc_swarm"] = true,
    ["hg_brassknuckles"] = true,
    ["zbox_lootbox"] = true,
    ["npc_swarm_mother"] = true,
    ["npc_swarm_sentinel"] = true,
    ["npc_swarm_sentry"] = true,
    ["necrosis"] = true,
    ["necrosisrange"] = true,
    ["ent_hg_cyanide_plotnypih"] = true,
    ["weapon_traitor_poison3"] = true,
    ["weapon_shield"] = true,
    ["weapon_traitor_poison1"] = true,
    ["weapon_traitor_poison2"] = true,
    ["weapon_traitor_suit"] = true,
    ["weapon_musket"] = true,
    ["weapon_flintlock"] = true,
    ["rasta"] = true,
    ["weapon_tpik1_base"] = true,
    ["weapon_thaumaturgic_arm"] = true,
    ["weapon_hg_slam"] = true,
    ["weapon_claymore"] = true,
    ["weapon_ash12"] = true,
    ["weapon_hands_sh"] = true
}

local CategoresAllowed = {
    ["Weapons - Pistols"] = true,
    ["Weapons - Machineguns"] = true,
    ["Weapons - Assault Rifles"] = true,
    --["Weapons - Grenade Launchers"] = true,
    --["Weapons - Other"] = true,
    ["Weapons - Melee"] = true,
    ["Weapons - Shotguns"] = true,
    ["Weapons - Sniper Rifles"] = true,
    ["Weapons - Explosive"] = true,
    ["Medicine"] = true,
    ["ZCity Other"] = true,
    ["ZCity Ammo"] = true,
    ["ZCity Armor"] = true,
    ["ZCity Attachments Grips"] = true,
    ["ZCity Attachments Magwells"] = true,
    ["ZCity Attachments Muzzles"] = true,
    ["ZCity Attachments Sights"] = true,
    ["ZCity Attachments Underbarrel"] = true,
    ["Other"] = true,
}

local KgInTime = 40

if SERVER then
    util.AddNetworkString("Deliver")

    net.Receive("Deliver",function( len, ply )
        local wep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon() or false
        if not wep or wep:GetClass() ~= "rasta" then return end
        ply.DeliverCD = ply.DeliverCD or 0
        if ply.DeliverCD > CurTime() then wep:AddNotificate("You can't exucute new deliver. Wait "..( math.Round((ply.DeliverCD - CurTime())/300, 1)).. " min" ) return end

        local Cart = net.ReadTable()
        local CartWeight = 0
        
        for k, item in pairs(Cart) do
            if not item or not item[1] then wep:AddNotificate("No.") return end
            local entStore = scripted_ents.GetStored(item[1])
            local entTbl = weapons.GetStored(item[1]) or (entStore and entStore.t) or nil
            CartWeight = CartWeight + 5
            if not entTbl or not CategoresAllowed[entTbl.Category] then wep:AddNotificate("No.") return end
            if not item[1] or BlackList[item[1]] then wep:AddNotificate("No.") return end
        end

        if CartWeight > 140 then wep:AddNotificate("Too much weight to ship.") return end

        local Time = (CartWeight/KgInTime)*60
        if Time == 0 then wep:AddNotificate("First, get stuff in your cart.") return end

        local pos = hg.eyeTrace(ply).HitPos
        local tr = util.TraceLine({
            start = pos,
            endpos = pos + Vector(0,0,1) * 9999999,
            mask = MASK_SOLID_BRUSHONLY,
        })
        if tr.HitSky then
            wep:AddNotificate("Your order is being assembled, please wait.")
            timer.Create(ply:EntIndex().."_Deliver",Time,1,function()
                wep:AddNotificate("Your package arrived. You have 5 minutes to pick up your stuff.")
                --ply:ChatPrint("Weapon was called, estimated time of delivery 5-7 seconds.")
                if not IsValid(ply) then return end
                local ent = ents.Create("zbox_lootbox")
                ent:SetMaterial("models/mat_jack_aidbox")
                ent:SetModel("models/props_junk/wood_crate001a.mdl")
                ent:SetPos(tr.HitPos + tr.HitNormal * 15)
                ent:Spawn()

                for k,item in pairs(Cart) do
                    ent.Loot = ent.Loot or {}
                    ent.Loot[#ent.Loot + 1] = { class = item[1] }
                end

                timer.Simple(300,function()
                    if not IsValid(ent) then return end
                    ent:Remove()
                end)
            end)

            ply.DeliverCD = CurTime() + Time
        else
            wep:AddNotificate("We can't deliver it to you until you're outside.")
        end

    end)

    function SWEP:AddNotificate(txt, isFunc)
        isFunc = isFunc or false
        if self:GetOwner():IsPlayer() then
            net.Start("Deliver")
                net.WriteString( txt )
                net.WriteEntity( self )
            net.Send(self:GetOwner())
        end

        self:EmitSound("garrysmod/content_downloaded.wav",40,100,1)
    end
end

if SERVER then return end

net.Receive("Deliver",function()
    local txt = net.ReadString()
    local ent = net.ReadEntity()

    ent:AddNotificate(txt,os.date("%H:%M | "))
end)

SWEP.CartIndex = "none"
SWEP.CartWeight = 0

SWEP.Cart = {}

local function addDiliverPanel(panel,tbl,swep)
    local button = vgui.Create( "DButton", panel )
    button:Dock( TOP )
    button:SetSize( 0,55 )
    button:SetText( tbl[2].." | "..tbl[3].." kg" )
    button.Weight = tbl[3]
    button.ClassName = tbl[1]
    button:DockMargin( 6, 10, 11, 0 )
    button:SetFont("ZCity_Tiny")

    function button:DoClick()
        swep.Cart[tbl[4]] = nil
        self:Remove()
    end

    button:SetContentAlignment(5)
end

function SWEP:CreateMenu()
    if IsValid(self.menu) then self.menu:Remove() end
    self.menu = vgui.Create( "DFrame" )
    self.menu:SetSize( 625, 468 )
    -- Если б я мог поменять хтмл говно я бы сделал лучше
    --self.menu:Center()
    self.menu:SetPos( 0, 0 )
    self.menu:SetTitle("Order menu")
    self.menu:SetDraggable(false)
    local tablet = self
    function self.menu:Think()
        local wep = IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon() or false
        if not wep or wep:GetClass() ~= "rasta" then
            if tablet.MouseHasControl then
                gui.EnableScreenClicker(false)
                tablet.MouseHasControl = false
            end
            --self:Remove() 
        end
        if not IsValid(tablet) then
            gui.EnableScreenClicker(false)
            self:Remove()
        end
    end

    hook.Add("OnShowZCityPause","CloseDerma",function()
        if self.MouseHasControl then
            gui.EnableScreenClicker(false)
            self.menu:SetMouseInputEnabled( false )
            self.menu:SetKeyboardInputEnabled( false )
            self.MouseHasControl = false
            --hook.Remove("OnPauseMenuShow","CloseDerma")
            return false
        end
    end)

    self.menu.bNoBackgroundBlur = true
    self.menu.NoBlur = true
    --SWEP.menu:Center()
    --SWEP.menu:MakePopup()
    local swep = self
    local toolbar = vgui.Create( "DPanel", self.menu )
    toolbar:Dock( TOP )
    toolbar:SetSize(0,30)

    local LBLRich = vgui.Create( "DLabel", toolbar )
    LBLRich:Dock(FILL)
    LBLRich:DockMargin(0,0,0,0)
    LBLRich:SetFont("ZCity_Fixed_SuperTiny")
    LBLRich:SetContentAlignment(5)

    self.LastNotifyText = self.LastNotifyText or ""
    self.LastNotifyTime = self.LastNotifyTime or 0
    function LBLRich:Think()
        if not IsValid(swep) then return end
        if swep.LastNotifyTime < CurTime() then swep.LastNotifyText = "" end
        self:SetText(os.date("%H:%M")..swep.LastNotifyText)
    end
    
    local sheet = vgui.Create( "DPropertySheet", self.menu )
    sheet:Dock( FILL )

    local Deliver = vgui.Create( "DPanel", sheet )
    Deliver:SetParent( sheet ) 

        local LeftPanel = vgui.Create( "DPanel", Deliver )
        LeftPanel:SetParent( Deliver ) 
        LeftPanel:Dock(LEFT)
        LeftPanel:SetSize(200,0)

            local LBLRich = vgui.Create( "DLabel", LeftPanel )
            LBLRich:Dock(TOP)
            LBLRich:DockMargin(10,10,10,5)
            LBLRich:SetFont("ZCity_Fixed_Tiny")
            LBLRich:SetContentAlignment(7)
            
            function LBLRich:Think()
                if not IsValid(swep) then return end
                self:SetText([[Cart: #]]..(swep:EntIndex()*123)..[[

Weight: ]]..swep.CartWeight..[[/140 kg
Arrive: ]]..(swep.CartWeight/KgInTime)..[[ Min

Cost: Free]])
                swep.CartWeight = 0
                for k, item in pairs(swep.Cart) do
                    swep.CartWeight = swep.CartWeight + item[3]
                end
                
            end

            local button = vgui.Create( "DButton", LeftPanel )
            button:Dock( BOTTOM )
            button:SetSize( 0,55 )
            button:SetText( "Order" )
            button:DockMargin( 10, 5, 10, 10 )
            button:SetColor(color_green)
            button:SetFont("ZCity_Tiny")



        local RightPanel = vgui.Create( "DScrollPanel", Deliver )
        RightPanel:SetParent( Deliver )
        RightPanel:Dock( FILL )   

            function button:DoClick()

                net.Start("Deliver")
                    net.WriteTable(swep.Cart)
                net.SendToServer()

                timer.Simple(0.1,function()
                    swep.LastID = 0
                    table.Empty( swep.Cart )
                end)

                RightPanel:Remove()

                RightPanel = vgui.Create( "DScrollPanel", Deliver )
                RightPanel:SetParent( Deliver )
                RightPanel:Dock( FILL ) 
            end

        for k, item in pairs(self.Cart) do
            addDiliverPanel( RightPanel, item, self )
        end

    
    sheet:AddSheet( "Deliver", Deliver )

    local Categores = {}

    for k, guns in pairs(weapons.GetList()) do
        local gun = weapons.Get(guns.ClassName)
        local Category = gun.Category or nil
        if not Category then continue end
        if not gun.Spawnable or gun.AdminOnly then continue end
        if BlackList[gun.ClassName] then continue end
        --print(Category)
        if not CategoresAllowed[Category] then continue end

        local Names = gun.PrintName

        Categores[ Category ] = Categores[ Category ] or {}
        Categores[ Category ][ guns.ClassName ] = { guns.ClassName, gun.PrintName }
    end 

    for k, ent in pairs(scripted_ents.GetList()) do
        local rent = ent["t"]
        --PrintTable(ent)
        if not rent then continue end
        local Category = rent.Category or "Other"
        if not Category then continue end
        if not rent.Spawnable or rent.AdminOnly then continue end
        if BlackList[rent.ClassName] then continue end
        --print(Category)
        if not CategoresAllowed[Category] then continue end

        local Names = ent.PrintName

        Categores[ Category ] = Categores[ Category ] or {}
        Categores[ Category ][ rent.ClassName ] = { rent.ClassName, rent.PrintName }
    end

    local sheetDeliver = vgui.Create( "DPropertySheet", sheetDeliver )
    sheetDeliver:Dock( FILL )
    
        for k,Category in pairs(Categores) do
            local Shop = vgui.Create( "DScrollPanel", sheetDeliver )
            Shop:SetParent( sheetDeliver )
            Shop:Dock( FILL )   

            for i,gun in pairs(Category) do
                local button = vgui.Create( "DButton", Shop )
                button:Dock( TOP )
                button:SetSize( 0,55 )
                button:SetText( gun[2] or "Gun" )
                button.Weight = 5
                button:DockMargin( 5, 0, 5, 5 )
                button:SetFont("ZCity_Fixed_Tiny")

                local swep = self
                function button:DoClick()
                    swep.LastID = swep.LastID or 0
                    local id = (swep.LastID + 1).."ID"
                    --print(id)
                    swep.Cart[id] = {gun[1],gun[2],self.Weight, id, k}
                    addDiliverPanel( RightPanel, {gun[1],gun[2],self.Weight, id}, swep )
                    swep.LastID = swep.LastID + 1
                end

                button:SetContentAlignment(5)
            end

            sheetDeliver:AddSheet( string.StartsWith(k, "Weapons") and string.sub(k,11) or k, Shop )
        end

    sheet:AddSheet( "Shop", sheetDeliver )

    
    --for k, v in SortedPairsByMemberValue( spawnmenu.GetCreationTabs(), "Order" ) do
    --    if k ~= "#spawnmenu.category.weapons" and k ~= "#spawnmenu.category.entities" then continue end
--
    --    local panel = v.Function()
    --    panel:SetParent( sheet )
    --    panel.bNoBackgroundBlur = true
    --    panel.NoBlur = true
    --
    --    sheet:AddSheet( k, panel, v.Icon )
    --end
    --Ultra ShitPost
    local html = vgui.Create("HTML",sheet)
    html:SetParent( sheet )
    --html:Dock(FILL)
    html:OpenURL("https://google.com/?persist_app=1&app=m")
    html.HTMLPosX = 0
    html.HTMLPosY = 0
    -- ПРОСТИТЕ ЗА ЖУТКИЙ КОСТЫЛЬ, НО ОНО РАБОТАЕТ!!!
    function html:OnCursorMoved( X, Y )
        self.HTMLPosX = X
        self.HTMLPosY = Y
    end


    function html:PaintOver(w,h)
        if tablet.MouseHasControl then
            draw.RoundedBox(0,self.HTMLPosX-3,self.HTMLPosY-3,6,6,ColorAlpha(color_black,250))
            draw.RoundedBox(0,self.HTMLPosX-2.5,self.HTMLPosY-2.5,5,5,ColorAlpha(color_white,250))
        end
    end

    --function html:PaintOver(w,h)
    --    
    --end

    sheet:AddSheet( "Browser", html )

    self.NotifiyPan = vgui.Create( "DPanel", sheet )
    self.NotifiyPan:SetParent( sheet ) 

-- chernii rynook
local BlackMarket = vgui.Create("DScrollPanel", sheetDeliver)
BlackMarket:SetParent(sheetDeliver)
BlackMarket:Dock(FILL)

-- Helper function to add items
local function AddMarketItem(parent, name, price, weight, class, isRare)
    local button = vgui.Create("DButton", parent)
    button:Dock(TOP)
    button:SetSize(0, 45)
    button.Weight = weight
    button.ClassName = class
    button:DockMargin(5, 3, 5, 3)
    button:SetFont("ZCity_Fixed_SuperTiny")
    
    local rareStar = isRare and " ★" or ""
    button:SetText(name .. rareStar .. " | " .. price .. "$ | " .. weight .. "kg")
    
    if isRare then
        button:SetColor(Color(255, 200, 50))
    end
    
net.Receive("BlackMarketBuy", function(len, ply)
    local class = net.ReadString()
    local name = net.ReadString()
    local price = net.ReadFloat()
    -- Проверка дене
    local wallet = tonumber(ply:GetNWString("WalletMoney") or "0") or 0
    if wallet < price then ply:Notify("Not enough money!", 2) return end
    ply:SetNWString("WalletMoney", tostring(wallet - price))

    AddToInventory(ply, {
        type = class:find("harvest_") and "organ" or "implant",
        id = class,
        name = name,
        timestamp = os.time()
    })
    --ply:Notify("Purchased " .. name .. " – added to inventory.", 2)
end)
    
    function button:DoClick()
    net.Start("BlackMarketBuy")
    net.WriteString(class)
    net.WriteString(name)
    net.WriteFloat(price)
    net.SendToServer()
    
    swep.LastID = swep.LastID or 0
    local id = (swep.LastID + 1) .. "ID"
    swep.Cart[id] = {class, name, weight, id, "Black Market"}
    addDiliverPanel(RightPanel, {class, name, weight, id}, swep)
    swep.LastID = swep.LastID + 1
end
    button:SetContentAlignment(5)
end

-- GENERATE BLACK MARKET ITEMS (randomized each time menu opens)
local marketItems = {}

-- Scrap implants (COMMON - appear often)
local scrapImplants = {
    {"implant_neurolink_scrap", "Scrap NeuroLink", "Found in a dumpster. Barely works.", 3, 50},
    {"implant_compass_scrap", "Scrap Compass", "Points somewhere. Probably.", 2, 30},
    {"implant_airjump_scrap", "Scrap Air Jump", "Might hurt you instead.", 4, 40},
    {"implant_dash_scrap", "Scrap Dash", "50% trip chance.", 4, 35},
    {"implant_chargejump_scrap", "Scrap Charge Jump", "30% explode rate.", 5, 45},
    {"implant_subdermal_scrap", "Scrap Subdermal Armor", "40% fail. Double damage.", 6, 55},
    {"implant_synth_lungs_scrap", "Scrap Synth Lungs", "Sometimes chokes you.", 4, 40},
}

-- DIY implants (UNCOMMON)
local diyImplants = {
    {"implant_neurolink_diy", "DIY NeuroLink", "Made in a garage.", 3, 120},
    {"implant_compass_diy", "DIY Compass", "Slow but works.", 2, 80},
    {"implant_airjump_diy", "DIY Air Jump", "Random height.", 4, 100},
    {"implant_dash_diy", "DIY Dash", "Random speed.", 4, 90},
    {"implant_chargejump_diy", "DIY Charge Jump", "Sometimes sideways.", 5, 110},
    {"implant_subdermal_diy", "DIY Subdermal Armor", "Random protection.", 6, 130},
    {"implant_synth_lungs_diy", "DIY Synth Lungs", "Unstable boost.", 4, 100},
}

-- Black Market implants (RARE)
local bmImplants = {
    {"implant_neurolink_blackmarket", "Black Market NeuroLink", "Stolen corpo tech.", 3, 250},
    {"implant_compass_blackmarket", "Black Market Compass", "Fake contacts included.", 2, 180},
    {"implant_airjump_blackmarket", "Black Market Air Jump", "Exhaust trail.", 4, 220},
    {"implant_dash_blackmarket", "Black Market Dash", "Smoke and sparks.", 4, 200},
    {"implant_chargejump_blackmarket", "Black Market Charge Jump", "Overheats.", 5, 240},
    {"implant_subdermal_blackmarket", "Black Market Armor", "Bleeding side effect.", 6, 280},
    {"implant_synth_lungs_blackmarket", "Black Market Synth Lungs", "Addictive.", 4, 220},
}

-- Normal implants (VERY RARE)
local normalImplants = {
    {"implant_neurolink_basic", "NeuroLink Basic", "Standard HUD.", 3, 500},
    {"implant_compass_1", "Compass T1", "Cardinal directions.", 2, 200},
    {"implant_airjump_low", "Air Jump T1", "Low boost.", 4, 300},
    {"implant_dash_low", "Dash T1", "Short dash.", 4, 250},
    {"implant_chargejump_1", "Charge Jump T1", "Basic charge.", 5, 350},
    {"implant_subdermal_zeta", "ZetaTech Armor", "Light armor.", 6, 400},
    {"implant_synth_lungs_1", "Synth Lungs T1", "+20% stamina.", 4, 300},
}

-- Organs (from harvesting)
local organsForSale = {
    {"harvest_brain", "Brain (Harvested)", "Still warm.", 2, 300, true},
    {"harvest_heart", "Heart (Harvested)", "Could restart.", 2, 350, true},
    {"harvest_liver", "Liver (Harvested)", "Filtered toxins.", 2, 250, true},
    {"harvest_lungs", "Lungs (Harvested)", "Still pink.", 3, 280, true},
    {"harvest_stomach", "Stomach (Harvested)", "Empty.", 2, 150, true},
    {"harvest_intestines", "Intestines (Harvested)", "Don't ask.", 2, 100, true},
}
-- Generate market: Mostly junk, sometimes scrap, rarely better
local seed = math.random(1, 1000)

-- Always add some scrap implants
for i = 1, math.random(6, 12) do
    local item = scrapImplants[math.random(#scrapImplants)]
    table.insert(marketItems, {item[1], item[2], item[3], item[4], item[5], false}) -- [class, name, desc, weight, price, isRare]
end

-- Sometimes DIY)
if math.random(100) <= 80 then
    for i = 1, math.random(3, 6) do
        local item = diyImplants[math.random(#diyImplants)]
        table.insert(marketItems, {item[1], item[2], item[3], item[4], item[5], false})
    end
end

-- Rarely Black Market
if math.random(100) <= 40 then
    local item = bmImplants[math.random(#bmImplants)]
    table.insert(marketItems, {item[1], item[2], item[3], item[4], item[5], true})
end

-- Very rarely normal implant
if math.random(100) <= 5 then
    local item = normalImplants[math.random(#normalImplants)]
    table.insert(marketItems, {item[1], item[2], item[3], item[4], item[5], true})
end

if math.random(100) <= 2 then
    local rareTiers = {
        {"implant_neurolink_military", "NeuroLink Military", "Combat OS v2.1", 3, 2000},
        {"implant_airjump_high", "Air Jump T3", "High boost", 4, 1500},
        {"implant_dash_high", "Dash T3", "Long dash", 4, 1200},
        {"implant_subdermal_arcom", "ARCOM Armor", "Heavy plating", 6, 2500},
        {"implant_synth_lungs_3", "Synth Lungs T3", "Good capacity", 4, 1800},
    }
    local item = rareTiers[math.random(#rareTiers)]
    table.insert(marketItems, {item[1], item[2], item[3], item[4], item[5], true})
end

-- Sometimes organs
if math.random(100) <= 20 then
    for i = 1, math.random(1, 2) do
        local item = organsForSale[math.random(#organsForSale)]
        table.insert(marketItems, {item[1], item[2], item[3], item[4], item[5], true})
    end
end

net.Receive("BlackMarketBuy", function(len, ply)
    local class = net.ReadString()
    local name = net.ReadString()
    local price = net.ReadFloat()
    
    local wallet = tonumber(ply:GetNWString("WalletMoney") or "0") or 0
    if wallet < price then ply:Notify("Not enough money!", 2) return end
    ply:SetNWString("WalletMoney", tostring(wallet - price))

    -- Check if it's an entity
    local entStore = scripted_ents.GetStored(class)
    if entStore then
        local ent = ents.Create(class)
        ent:SetPos(ply:GetPos() + Vector(0, 0, 50))
        ent:Spawn()
        ply:Notify("Purchased " .. name .. " - delivered to your feet", 2)
        return
    end
    
    -- Otherwise it's an implant/organ - add to inventory
    local json = PlayerInventory[ply:SteamID()] or "[]"
    local inv = util.JSONToTable(json)
    table.insert(inv, {
        type = class:find("harvest_") and "organ" or "implant",
        id = class,
        name = name,
        timestamp = os.time()
    })
    PlayerInventory[ply:SteamID()] = util.TableToJSON(inv)
    net.Start("SyncInventory")
    net.WriteString(util.TableToJSON(inv))
    net.Send(ply)
    
    ply:Notify("Purchased " .. name, 2)
end)

-- Add all generated items to the panel
for _, item in ipairs(marketItems) do
    AddMarketItem(BlackMarket, item[2], item[5], item[4], item[1], item[6])
end

sheet:AddSheet("Black Market", BlackMarket)



    sheet:AddSheet( "Notifications", self.NotifiyPan )

end

function SWEP:AddNotificate(text,time)
    if not IsValid(self.NotifiyPan) then return end
    local button = vgui.Create( "DButton", self.NotifiyPan )
    button:Dock( TOP )
    button:SetSize( 0,45 )
    button:SetText( time..(isfunction(text) and text() or text) )

    function button:Think()
        button:SetText( time..(isfunction(text) and text() or text) )
    end

    button:DockMargin( 6, 5, 6, 2.5 )
    button:SetFont("ZCity_Fixed_SuperTiny")

    function button:DoClick()
        self:Remove()
    end

    button:SetContentAlignment(5)

    self.LastNotifyText = isfunction(text) and text() or text
    self.LastNotifyText = " | "..self.LastNotifyText
    self.LastNotifyTime = CurTime() + 5
end

--if SWEP.menu then SWEP.menu:Remove() end
--SWEP.menu = vgui.Create( "DFrame" )
--SWEP.menu:SetSize( 1000, 650 )
--SWEP.menu.bNoBackgroundBlur = true
--SWEP.menu.NoBlur = true
----SWEP.menu:Center()
----SWEP.menu:MakePopup()
--
--local sheet = vgui.Create( "DPropertySheet", SWEP.menu )
--sheet:Dock( FILL )
--sheet.bNoBackgroundBlur = true
--sheet.NoBlur = true
--
--for k, v in SortedPairsByMemberValue( spawnmenu.GetCreationTabs(), "Order" ) do
--    local panel = v.Function()
--    panel:SetParent( sheet )
--    panel.bNoBackgroundBlur = true
--    panel.NoBlur = true
--
--    sheet:AddSheet( k, panel, v.Icon )
--end

function SWEP:PrimaryAttack()
    if IsValid(self.menu) then
        self.menu:SetMouseInputEnabled( true )
        self.menu:MakePopup(  )
        self.MouseHasControl = true
        gui.EnableScreenClicker(true)
    end
end

function SWEP:AddDrawModel(ent)
    if not IsValid(self.menu) then self:CreateMenu() end
    if IsValid(self:GetOwner()) and not self:GetOwner() == LocalPlayer() then return end
    local pos, ang = ent:GetRenderOrigin(), ent:GetRenderAngles()
    pos = pos + ang:Up() * 1.2 + ang:Forward() * -5 + ang:Right() * -3.5
    local scale = 0.0151
    vgui.Start3D2D(pos,ang,scale)
        self.menu:Paint3D2D()
        --local posx, posy = vgui.getCursorPos3D2D()
        --draw.RoundedBox(0,(posx/scale)-3.5,(posy/scale)-3.5,7,7,color_black)
        --draw.RoundedBox(0,(posx/scale)-2.5,(posy/scale)-2.5,5,5,color_white)
    vgui.End3D2D()
end
