local Enemigo = require("enemigos.enemigo")

local Caballero = setmetatable({}, {__index = Enemigo})
Caballero.__index = Caballero

function Caballero:new(x, y, grande)
    local ancho = 16
    local alto = 16
    local velocidad = 40
    local vida = 110
    local daño = 30

    if grande then
        ancho = 32
        alto = 32
        velocidad = 45
        vida = 200
        daño = 45
    end

    local enemigo = Enemigo:new(
        x,
        y,
        ancho,
        alto,
        velocidad,
        vida,
        daño,
        "img/Caballero.png",
        3
    )

    setmetatable(enemigo, Caballero)

    enemigo.activo = false

    return enemigo
end

return Caballero