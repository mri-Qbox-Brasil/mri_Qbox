local function CanCarryItem(itemName, amount)

  local itemWeight = exports.ox_inventory:Items(itemName).weight
  local currentWeight = exports.ox_inventory:GetPlayerWeight()
  local maxWeight = exports.ox_inventory:GetPlayerMaxWeight()
  local additionalWeight = itemWeight * amount
  local totalWeight = currentWeight + additionalWeight

  return totalWeight <= maxWeight
end

exports('CanCarryItem', CanCarryItem)