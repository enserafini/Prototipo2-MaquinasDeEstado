
local Eventos = require("eventos")

local Interfaz = {}
Interfaz.__index = Interfaz

function Interfaz:new()
    local interfaz = setmetatable({}, Interfaz)

    interfaz.vida = 100
    interfaz.vidaMaxima = 100
    interfaz.salaActual = 1
    interfaz.totalSalas = 4
    interfaz.enemigosDerrotados = 0
    interfaz.jefesDerrotados = 0
    interfaz.totalJefes = 3

    interfaz.fuente = love.graphics.newFont("fuentes/font.ttf", 16)
    interfaz.fuenteTitulo = love.graphics.newFont("fuentes/font.ttf", 18)

    Eventos.on("vida_actualizada", function(vida, vidaMaxima)
        interfaz.vida = vida
        interfaz.vidaMaxima = vidaMaxima
    end)

    Eventos.on("sala_actualizada", function(sala, totalSalas)
        interfaz.salaActual = sala
        interfaz.totalSalas = totalSalas
    end)

    Eventos.on("enemigo_derrotado", function(enemigo)
        if enemigo.sala ~= 4 then
            interfaz.enemigosDerrotados = interfaz.enemigosDerrotados + 1
        end
    end)

    Eventos.on("jefe_derrotado", function()
        interfaz.jefesDerrotados = interfaz.jefesDerrotados + 1
    end)

    return interfaz
end

function Interfaz:reiniciar()
    self.vida = 100
    self.vidaMaxima = 100
    self.salaActual = 1
    self.totalSalas = 4
    self.enemigosDerrotados = 0
    self.jefesDerrotados = 0
end

function Interfaz:dibujar()
    local x = 20
    local y = 20
    local anchoBarra = 220
    local altoBarra = 24

    local porcentaje = 0

    if self.vidaMaxima > 0 then
        porcentaje = self.vida / self.vidaMaxima
    end

    if porcentaje < 0 then porcentaje = 0 end
    if porcentaje > 1 then porcentaje = 1 end

    love.graphics.setFont(self.fuenteTitulo)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("VIDA DEL JUGADOR", x, y)

    love.graphics.setColor(0.15, 0.15, 0.15, 1)
    love.graphics.rectangle("fill", x, y + 27, anchoBarra, altoBarra)

    love.graphics.setColor(0.75, 0.08, 0.08, 1)
    love.graphics.rectangle("fill", x, y + 27, anchoBarra * porcentaje, altoBarra)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y + 27, anchoBarra, altoBarra)

    love.graphics.setFont(self.fuente)
    love.graphics.setColor(1, 1, 1, 1)

    local textoVida = math.floor(self.vida) .. " / " .. self.vidaMaxima
    local anchoTexto = self.fuente:getWidth(textoVida)
    local altoTexto = self.fuente:getHeight()

    love.graphics.print(textoVida, x + anchoBarra / 2 - anchoTexto / 2, y + 29 + (altoBarra - altoTexto) / 2)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("SALA: " .. self.salaActual .. " / " .. self.totalSalas, x, y + 62)
    love.graphics.print("ENEMIGOS DERROTADOS: " .. self.enemigosDerrotados, x, y + 85)
    love.graphics.print("JEFES DERROTADOS: " .. self.jefesDerrotados .. " / " .. self.totalJefes, x, y + 108)

    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
end

return Interfaz
