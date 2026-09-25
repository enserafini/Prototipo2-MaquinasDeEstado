local Enemigo = require("enemigos.enemigo")

local Samurai = setmetatable({}, {__index = Enemigo})
Samurai.__index = Samurai

function Samurai:new(x, y, grande)
    local ancho = 16
    local alto = 16
    local velocidad = 55
    local vida = 70
    local daño = 20

    if grande then
        ancho = 28
        alto = 28
        velocidad = 65
        vida = 140
        daño = 30
    end

    local enemigo = Enemigo:new(
        x,
        y,
        ancho,
        alto,
        velocidad,
        vida,
        daño,
        "img/Samurai.png",
        2
    )

    setmetatable(enemigo, Samurai)

    enemigo.activo = false

    return enemigo
end

return Samurai