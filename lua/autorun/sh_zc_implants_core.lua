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
