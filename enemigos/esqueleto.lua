local Enemigo = require("enemigos.enemigo")

local Esqueleto = setmetatable({}, {__index = Enemigo})
Esqueleto.__index = Esqueleto

function Esqueleto:new(x, y, sala, velocidad, vida, daño, escala)
    local enemigo = Enemigo:new(
        x, y, sala,
        "img/Esqueleto.png",
        velocidad or 34,
        vida or 80,
        daño or 10,
        escala or 1
    )

    setmetatable(enemigo, Esqueleto)

    return enemigo
end

return Esqueleto