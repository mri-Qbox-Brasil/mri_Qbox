lib.callback.register('mri_Qbox:worldmap:isAdmin', function(source)
    return IsPlayerAceAllowed(source, 'admin')
end)
