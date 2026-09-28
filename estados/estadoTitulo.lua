local Sonidos = require("sonidos")

local EstadoTitulo = {}
EstadoTitulo.__index = EstadoTitulo

function EstadoTitulo:new(maquina)
    local estado = setmetatable({}, EstadoTitulo)

    estado.maquina = maquina
    estado.fondo = love.graphics.newImage("img/fondoInicio.png")
    estado.fuente = love.graphics.newFont("fuentes/font.ttf", 32)

    return estado
end

function EstadoTitulo:entrar()
    Sonidos.reproducirMusica(Sonidos.musicaInicio)
end

function EstadoTitulo:update(dt)
end

function EstadoTitulo:keypressed(tecla)
    if tecla == "return" then
        self.maquina:cambiar(self.maquina.estadoJuego)
    end
end

function EstadoTitulo:draw()
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(self.fondo, 0, 0, 0, love.graphics.getWidth() / self.fondo:getWidth(), love.graphics.getHeight() / self.fondo:getHeight())

    love.graphics.setFont(self.fuente)

    local titulo = "EL TRIO DE GIGANTES"
    local texto = "PRESIONA ENTER PARA JUGAR"

    local anchoTitulo = self.fuente:getWidth(titulo)
    local anchoTexto = self.fuente:getWidth(texto)

    love.graphics.print(titulo, (love.graphics.getWidth() - anchoTitulo) / 2, 80)
    love.graphics.print(texto, (love.graphics.getWidth() - anchoTexto) / 2, 620)
end

return EstadoTitulo