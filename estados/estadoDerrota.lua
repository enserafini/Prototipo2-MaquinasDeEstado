local Sonidos = require("sonidos")

local EstadoDerrota = {}
EstadoDerrota.__index = EstadoDerrota

function EstadoDerrota:new(maquina)
    local estado = setmetatable({}, EstadoDerrota)

    estado.maquina = maquina
    estado.fondo = love.graphics.newImage("img/fondoDerrota.png")
    estado.fuente = love.graphics.newFont("fuentes/font.ttf", 32)

    return estado
end

function EstadoDerrota:entrar()
    Sonidos.reproducirMusica(Sonidos.musicaDerrota)
end

function EstadoDerrota:update(dt)
end

function EstadoDerrota:keypressed(tecla)
    if tecla == "return" then
        self.maquina:cambiar(self.maquina.estadoJuego)
    end
end

function EstadoDerrota:draw()
    love.graphics.setColor(1, 1, 1, 1)

    -- ajusta el fondo al tamaño de la ventana
    love.graphics.draw(self.fondo, 0, 0, 0, love.graphics.getWidth() / self.fondo:getWidth(), love.graphics.getHeight() / self.fondo:getHeight())

    love.graphics.setFont(self.fuente)

    local titulo = "DERROTA"
    local texto = "PRESIONA ENTER PARA INTENTAR DE NUEVO"

    local anchoTitulo = self.fuente:getWidth(titulo)
    local anchoTexto = self.fuente:getWidth(texto)

    love.graphics.print(titulo, (love.graphics.getWidth() - anchoTitulo) / 2, 80)
    love.graphics.print(texto, (love.graphics.getWidth() - anchoTexto) / 2, 620)
end

return EstadoDerrota