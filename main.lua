local MaquinaEstado = require("maquinaEstados")
local Sonidos = require("sonidos")

local EstadoTitulo = require("estados.estadoTitulo")
local EstadoJugar = require("estados.estadoJugar")
local EstadoVictoria = require("estados.estadoVictoria")
local EstadoDerrota = require("estados.estadoDerrota")

local maquina

function love.load()

    love.window.setMode(1280, 720)

    Sonidos.iniciar()

    maquina = MaquinaEstado:new()

    maquina.estadoJuego = EstadoJugar:new(maquina)
    maquina.estadoVictoria = EstadoVictoria:new(maquina)
    maquina.estadoDerrota = EstadoDerrota:new(maquina)

    local titulo = EstadoTitulo:new(maquina)

    maquina:iniciar(titulo)
end

function love.update(dt)
    maquina:update(dt)
end

function love.keypressed(tecla)
    maquina:keypressed(tecla)
end

function love.draw()
    maquina:draw()
end