AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Implant Chip"
ENT.Spawnable = false
ENT.Model = "models/items/battery.mdl"

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then phys:Wake() end
    end
end

if SERVER then
    function ENT:Use(activator)
        if not activator:IsPlayer() then return end
        if CurTime() < (self:GetNWFloat("DropTime", 0)) and activator == self:GetNWEntity("Dropper", nil) then return end
        local item = {
            type = self:GetNWString("ItemType"),
            id = self:GetNWString("ItemID"),
            name = self:GetNWString("ItemName"),
            timestamp = os.time()
        }
        AddToInventory(activator, item)
        self:Remove()
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end 