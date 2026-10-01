-- Cópia local da config dos módulos, mantida pela statebag global que o server
-- publica. Ler GlobalState a cada frame desserializa tudo de novo; a cópia não.
-- Mudou um módulo: Mri.applyChange liga, desliga ou reaplica o que ele registrou.

Mri.current = GlobalState[Mri.STATE_KEY] or {}

AddStateBagChangeHandler(Mri.STATE_KEY, 'global', function(_, _, value)
    local previous = Mri.current
    Mri.current = type(value) == 'table' and value or {}
    for _, id in ipairs(Mri.order) do
        Mri.applyChange(id, previous[id])
    end
    TriggerEvent('mri_Qbox:configChanged')
end)
