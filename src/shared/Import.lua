local t = {}
for _,module in pairs(script.Parent:GetChildren()) do
    if module.Name == 'Import' then continue end
    t[module.Name] = require(module)
end
return t