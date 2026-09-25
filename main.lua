local sti = require("lib.sti")
local bump = require("lib.bump")
local Camera = require("lib.camera")
local Jugador = require("jugador")

local mapa
local mundo
local jugador
local camara

function love.load()
    love.window.setMode(640, 320)

    mapa = sti("mapa/nivel1.lua")
    mundo = bump.newWorld(64)

    for _, objeto in ipairs(mapa.layers["Paredes"].objects) do
        if objeto.x and objeto.y and objeto.width and objeto.height then
            mundo:add(objeto, objeto.x, objeto.y, objeto.width, objeto.height)
        end
    end

    jugador = Jugador:new(80, 80)
    mundo:add(jugador, jugador.x, jugador.y, jugador.ancho, jugador.alto)

    camara = Camera()
end

function love.update(dt)
    jugador:update(dt, mundo)

    local x = jugador.x + jugador.ancho / 2
    local y = jugador.y + jugador.alto / 2

    local anchoMapa = mapa.width * mapa.tilewidth
    local altoMapa = mapa.height * mapa.tileheight

    local anchoPantalla = love.graphics.getWidth()
    local altoPantalla = love.graphics.getHeight()

    if anchoMapa <= anchoPantalla then
        x = anchoMapa / 2
    else
        if x < anchoPantalla / 2 then
            x = anchoPantalla / 2
        elseif x > anchoMapa - anchoPantalla / 2 then
            x = anchoMapa - anchoPantalla / 2
        end
    end

    if altoMapa <= altoPantalla then
        y = altoMapa / 2
    else
        if y < altoPantalla / 2 then
            y = altoPantalla / 2
        elseif y > altoMapa - altoPantalla / 2 then
            y = altoMapa - altoPantalla / 2
        end
    end

    camara:lookAt(x, y)
end

function love.draw()
    camara:attach()

    mapa:draw()
    jugador:draw()

    camara:detach()
end