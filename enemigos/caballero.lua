local Enemigo = require("enemigos.enemigo")

local Caballero = setmetatable({}, {__index = Enemigo})
Caballero.__index = Caballero

function Caballero:new(x, y, sala, escala)
    local enemigo = Enemigo:new(x, y, sala, "img/Caballero.png", 32, 140, 10, escala or 1)

    setmetatable(enemigo, Caballero)

    return enemigo
end

return Caballero