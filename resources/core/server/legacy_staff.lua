-- The old /staff role (metadata.staff) keeps working until mri_Qadmin moves it into its Permissions groups.
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local player = exports.qbx_core:GetPlayer(source)
    local role = player and player.PlayerData.metadata.staff
    if type(role) == 'string' and role:match('^group%.[%w_]+$') then
        lib.addPrincipal(source, role)
    end
end)
