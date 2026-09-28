local Enemigo = require("enemigos.enemigo")

local Samurai = setmetatable({}, {__index = Enemigo})
Samurai.__index = Samurai

function Samurai:new(x, y, sala, escala)
    local enemigo = Enemigo:new(x, y, sala, "img/Samurai.png", 40, 110, 15, escala or 1)

    setmetatable(enemigo, Samurai)

    return enemigo
end

return Samurai