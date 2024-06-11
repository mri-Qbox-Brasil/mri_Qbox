local function createTable(sql)
    return MySQL.Sync.execute(sql)
end

exports('CreateTable', createTable)

local function insertData(sql, data)
    return MySQL.insert(sql, data)
end

exports('InsertData', insertData)

local function updateData(sql, params)
    return MySQL.update.await(sql, params)
end

exports('UpdateData', updateData)

local function fetchData(sql, params)
    return MySQL.query.await(sql, params)
end

exports('FetchData', fetchData)
