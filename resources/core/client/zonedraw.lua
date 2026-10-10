-- Zone drawer shared by every MRI resource: exports.mri_Qbox:DrawZone(opts).

local drawing = false

local function aim()
    local from = GetGameplayCamCoord()
    local rot = math.rad(1) * GetGameplayCamRot(2)
    local dir = vec3(-math.sin(rot.z) * math.abs(math.cos(rot.x)), math.cos(rot.z) * math.abs(math.cos(rot.x)), math.sin(rot.x))
    local to = from + dir * 150.0
    -- The legacy ray answers in the same frame, so cursor and walls never lag behind.
    local _, hit, coords = GetShapeTestResult(StartShapeTestRay(from.x, from.y, from.z, to.x, to.y, to.z, 1 | 16, cache.ped, 0))
    -- hit is a number from some natives and a boolean from others.
    if hit == 1 or hit == true then return coords end
end

local function quad(a, b, c, d, r, g, bl, alpha)
    -- Both windings, so the wall shows from inside and outside.
    DrawPoly(a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z, r, g, bl, alpha)
    DrawPoly(c.x, c.y, c.z, b.x, b.y, b.z, a.x, a.y, a.z, r, g, bl, alpha)
    DrawPoly(a.x, a.y, a.z, c.x, c.y, c.z, d.x, d.y, d.z, r, g, bl, alpha)
    DrawPoly(d.x, d.y, d.z, c.x, c.y, c.z, a.x, a.y, a.z, r, g, bl, alpha)
end

---One wall from the bottom point p to q, height tall.
local function wall(p, q, height, color, alpha)
    local up = vec3(0.0, 0.0, height)
    local p2, q2 = p + up, q + up
    quad(p, q, q2, p2, color[1], color[2], color[3], alpha)
    DrawLine(p.x, p.y, p.z, q.x, q.y, q.z, color[1], color[2], color[3], 255)
    DrawLine(p2.x, p2.y, p2.z, q2.x, q2.y, q2.z, color[1], color[2], color[3], 255)
    DrawLine(p.x, p.y, p.z, p2.x, p2.y, p2.z, color[1], color[2], color[3], 255)
end

local function accent()
    local hex = GetConvar('mri:color', '#00E699'):match('^#(%x%x%x%x%x%x)') or '00E699'
    return { tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16) }
end

local function help(title, count, height)
    lib.showTextUI(('%s  \n[Clique] marcar canto: %d  \n[Rodinha] altura: %.1f m  \n[Backspace] desfazer  \n[R] recomeçar  \n[Enter] concluir  \n[Esc] cancelar'):format(title, count, height), {
        position = 'left-center',
        icon = 'fa-solid fa-draw-polygon',
    })
end

local round = function(n) return math.floor(n * 100 + 0.5) / 100 end

local function run(opts)
    if drawing then return end
    drawing = true
    opts = type(opts) == 'table' and opts or {}
    local height = tonumber(opts.thickness) or 6.0
    -- How far the zone reaches under the floor, so a point on the ground is always inside.
    local below = tonumber(opts.below) or 1.0
    local minPoints = tonumber(opts.minPoints) or 3
    local title = opts.title or 'Desenhando a zona'
    local color = type(opts.color) == 'table' and opts.color or accent()

    local bottom = {}
    for i, p in ipairs(type(opts.points) == 'table' and opts.points or {}) do
        bottom[i] = vec3(p.x, p.y, p.z - height / 2)
    end
    help(title, #bottom, height)

    local result
    while drawing do
        Wait(0)
        for _, control in ipairs({ 24, 25, 47, 140, 141, 142, 143, 200, 257 }) do DisableControlAction(0, control, true) end

        local cursor = aim()
        local cursorBottom = cursor and cursor - vec3(0.0, 0.0, below)
        if cursor then
            DrawMarker(28, cursor.x, cursor.y, cursor.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, color[1], color[2], color[3], 220, false, false, 2, false, nil, nil, false)
        end

        local n = #bottom
        for i = 1, n - 1 do wall(bottom[i], bottom[i + 1], height, color, 60) end
        if n > 0 then
            if cursorBottom then
                -- Live edges: the last corner to the cursor and the cursor back to the first.
                wall(bottom[n], cursorBottom, height, { 255, 255, 255 }, 35)
                if n > 1 then wall(cursorBottom, bottom[1], height, { 255, 255, 255 }, 20) end
            elseif n > 2 then
                wall(bottom[n], bottom[1], height, color, 60)
            end
        end

        if IsDisabledControlJustReleased(0, 24) and cursorBottom then
            bottom[n + 1] = cursorBottom
            help(title, #bottom, height)
        elseif IsControlJustReleased(0, 241) then
            height = math.min(height + 0.5, 50.0)
            help(title, n, height)
        elseif IsControlJustReleased(0, 242) then
            height = math.max(height - 0.5, 1.0)
            help(title, n, height)
        elseif IsControlJustReleased(0, 194) and n > 0 then
            bottom[n] = nil
            help(title, #bottom, height)
        elseif IsControlJustReleased(0, 45) then
            bottom = {}
            help(title, 0, height)
        elseif IsControlJustReleased(0, 201) then
            if n >= minPoints then
                local points = {}
                for i, p in ipairs(bottom) do
                    points[i] = { x = round(p.x), y = round(p.y), z = round(p.z + height / 2) }
                end
                result = { points = points, thickness = height }
                drawing = false
            else
                lib.notify({ description = ('Marque pelo menos %d cantos.'):format(minPoints), type = 'error' })
            end
        elseif IsDisabledControlJustReleased(0, 200) then
            drawing = false
        end
    end

    lib.hideTextUI()
    return result
end

---Draws a ground polygon (points at mid height, as ox_lib poly zones expect); answers through cb, since a waiting export cannot yield into another resource.
---@param opts? { points?: { x: number, y: number, z: number }[], thickness?: number, below?: number, minPoints?: number, title?: string, color?: integer[] }
---@param cb fun(zone: { points: { x: number, y: number, z: number }[], thickness: number }?)
---@return boolean started false when a drawing is already running
local function DrawZone(opts, cb)
    if drawing then return false end
    CreateThread(function()
        local zone = run(opts)
        if cb then cb(zone) end
    end)
    return true
end

exports('DrawZone', DrawZone)
exports('IsDrawingZone', function() return drawing end)
exports('CancelDrawZone', function() drawing = false end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and drawing then lib.hideTextUI() end
end)
