-- Bridge between the passport screen and the server; the server checks permission on every call.

RegisterNUICallback('passportList', function(data, cb)
    cb(lib.callback.await('mri_Qbox:passport:list', false, data.search) or { success = false })
end)

RegisterNUICallback('passportSet', function(data, cb)
    cb(lib.callback.await('mri_Qbox:passport:set', false, data) or { success = false })
end)
