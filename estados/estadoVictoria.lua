local Sonidos = require("sonidos")

local EstadoVictoria = {}
EstadoVictoria.__index = EstadoVictoria

function EstadoVictoria:new(maquina)
    local estado = setmetatable({}, EstadoVictoria)

    estado.maquina = maquina
    estado.fondo = love.graphics.newImage("img/fondoVictoria.png")
    estado.fuente = love.graphics.newFont("fuentes/font.ttf", 32)

    return estado
end

function EstadoVictoria:entrar()
    Sonidos.reproducirMusica(Sonidos.musicaVictoria)
end

function EstadoVictoria:update(dt)
end

function EstadoVictoria:keypressed(tecla)
    if tecla == "return" then
        self.maquina:cambiar(self.maquina.estadoJuego)
    end
end

function EstadoVictoria:draw()
    love.graphics.setColor(1, 1, 1, 1)

    -- ajusta el fondo al tamaño de la ventana
    love.graphics.draw(self.fondo, 0, 0, 0, love.graphics.getWidth() / self.fondo:getWidth(), love.graphics.getHeight() / self.fondo:getHeight())

    love.graphics.setFont(self.fuente)

    local titulo = "VICTORIA"
    local texto = "PRESIONA ENTER PARA VOLVER A JUGAR"

    local anchoTitulo = self.fuente:getWidth(titulo)
    local anchoTexto = self.fuente:getWidth(texto)

    love.graphics.print(titulo, (love.graphics.getWidth() - anchoTitulo) / 2, 80)
    love.graphics.print(texto, (love.graphics.getWidth() - anchoTexto) / 2, 620)
end

return EstadoVictoria