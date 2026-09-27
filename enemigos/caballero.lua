local Enemigo = require("enemigos.enemigo")

local Caballero = setmetatable({}, {__index = Enemigo})
Caballero.__index = Caballero

function Caballero:new(x, y, sala, velocidad, vida, daño, escala)
    local enemigo = Enemigo:new(
        x, y, sala,
        "img/Caballero.png",
        velocidad or 32,
        vida or 140,
        daño or 18,
        escala or 1
    )

    setmetatable(enemigo, Caballero)

    return enemigo
end

return Caballero