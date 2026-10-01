-- Cair ao tomar tiro na perna (contribuição: .reiffps)

local BONES = {
    [11816] = true, -- Pelvis
    [58271] = true, -- SKEL_L_Thigh
    [63931] = true, -- SKEL_L_Calf
    [14201] = true, -- SKEL_L_Foot
    [2108] = true,  -- SKEL_L_Toe0
    [65245] = true, -- IK_L_Foot
    [57717] = true, -- PH_L_Foot
    [46078] = true, -- MH_L_Knee
    [51826] = true, -- SKEL_R_Thigh
    [36864] = true, -- SKEL_R_Calf
    [52301] = true, -- SKEL_R_Foot
    [20781] = true, -- SKEL_R_Toe0
    [35502] = true, -- IK_R_Foot
    [24806] = true, -- PH_R_Foot
    [16335] = true, -- MH_R_Knee
    [23639] = true, -- RB_L_ThighRoll
    [6442] = true,  -- RB_R_ThighRoll
}

local function knockDown(ped)
    if IsEntityDead(ped) then return false end
    local hit, bone = GetPedLastDamageBone(ped)
    if (hit == 1 or hit == true) and BONES[bone] then
        SetPedToRagdoll(ped, 5000, 5000, 0, false, false, false)
        return true
    end
    return false
end

CreateThread(function()
    while true do
        if not Mri.enabled('damageragdoll') then
            Wait(1000)
        else
            local ped = PlayerPedId()
            if HasEntityBeenDamagedByAnyPed(ped) then
                knockDown(ped)
                ClearEntityLastDamageEntity(ped)
                Wait(0)
            else
                Wait(500)
            end
        end
    end
end)
