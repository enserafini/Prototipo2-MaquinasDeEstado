local Enemigo = require("enemigos.enemigo")

local Samurai = setmetatable({}, {__index = Enemigo})
Samurai.__index = Samurai

function Samurai:new(x, y, sala, velocidad, vida, daño, escala)
    local enemigo = Enemigo:new(
        x, y, sala,
        "img/Samurai.png",
        velocidad or 40,
        vida or 110,
        daño or 15,
        escala or 1
    )

    setmetatable(enemigo, Samurai)

    return enemigo
end

return Samurai