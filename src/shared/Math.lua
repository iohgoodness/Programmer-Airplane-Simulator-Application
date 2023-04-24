
--# common abbreviations
local ABBREVIATIONS = {
    "K", -- 4 digits
    "M", -- 7 digits
    "B", -- 10 digits
    "t", -- 13 digits
    "q", -- 16 digits
    "Q", -- 19 digits
    "s", -- 22 digits
    "S", -- 25 digits
    "o", -- 28 digits
    "n", -- 31 digits
    "d", -- 34 digits
    "U", -- 37 digits
    "D", -- 40 digits
}

return {
    --# more "common/cartoonish way to abbreviate"
    Abbreviate = function(n)
        n = tonumber(n)
        if not n then assert(n,'failed to be abbreviated') return nil end

        local neg = false
        if n < 0 then neg = true end

        n = math.abs(n)
        if n < 1000 then
            n = (math.floor(n * 100))/100
            if neg then return ('-' .. tostring(n)) end
            return tostring(n)
        end

        local digits = math.floor(math.log10(n)) + 1
        local index = math.min(#ABBREVIATIONS, math.floor((digits - 1) / 3))
        local front = n / math.pow(10, index * 3)

        local sign = false and '-' or ''

        local x = string.format(sign .. "%.2f%s", front, ABBREVIATIONS[index])
        local s = string.gsub(x, '.00%a', x:sub(x:len(), x:len()) )
        local a,b = string.find(s, '%p%d0%a')
        if a and b then
            return string.sub(s, 1, a+1) .. string.sub(s, b, string.len(s))
        end
        return s
    end,

    ConvertToCommas = function(number)
        if not tonumber(number) then return nil end
        --# fun regex sourced here (https://stackoverflow.com/a/10992898)
        local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
        int = int:reverse():gsub("(%d%d%d)", "%1,")
        return minus .. int:reverse():gsub("^,", "") .. fraction
    end,

    --# bezier function for fun floating effect of UI money animations
    QuadBezier = function(t, p0, p1, p2)
        local l1 = p0 + (p1 - p0) * t
        local l2 = p1 + (p2 - p1) * t
        local quad = l1 + (l2 - l1) * t
        return quad
    end,
}