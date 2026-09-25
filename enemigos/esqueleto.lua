local Enemigo = require("enemigos.enemigo")

local Esqueleto = setmetatable({}, {__index = Enemigo})
Esqueleto.__index = Esqueleto

function Esqueleto:new(x, y, grande)
    local ancho = 16
    local alto = 16
    local velocidad = 65
    local vida = 40
    local daño = 10

    if grande then
        ancho = 28
        alto = 28
        velocidad = 75
        vida = 100
        daño = 20
    end

    local enemigo = Enemigo:new(
        x,
        y,
        ancho,
        alto,
        velocidad,
        vida,
        daño,
        "img/Esqueleto.png",
        1
    )

    setmetatable(enemigo, Esqueleto)

    enemigo.activo = false

    return enemigo
end

return Esqueleto