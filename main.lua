local sti = require("lib.sti")
local bump = require("lib.bump")
local Camera = require("lib.camera")
local Jugador = require("jugador")

local Esqueleto = require("enemigos.esqueleto")
local Samurai = require("enemigos.samurai")
local Caballero = require("enemigos.caballero")

local mapa
local mundo
local jugador
local camara

local esqueletos = {}
local samurais = {}
local caballeros = {}

local esqueletoFinal
local samuraiFinal
local caballeroFinal


function love.load()
    love.window.setMode(640, 320)

    mapa = sti("mapa/nivel1.lua")

    mundo = bump.newWorld(64)

    for _, objeto in ipairs(mapa.layers["Paredes"].objects) do
        if type(objeto.x) == "number"
        and type(objeto.y) == "number"
        and type(objeto.width) == "number"
        and type(objeto.height) == "number" then

            mundo:add(
                objeto,
                objeto.x,
                objeto.y,
                objeto.width,
                objeto.height
            )
        end
    end

    jugador = Jugador:new(80, 80)

    mundo:add(
        jugador,
        jugador.x,
        jugador.y,
        jugador.ancho,
        jugador.alto
    )


    -- Sala 1: 2 esqueletos

    esqueletos[1] = Esqueleto:new(100, 70)
    esqueletos[2] = Esqueleto:new(160, 110)

    for _, enemigo in ipairs(esqueletos) do
        mundo:add(
            enemigo,
            enemigo.x,
            enemigo.y,
            enemigo.ancho,
            enemigo.alto
        )
    end


    -- Sala 2: 4 samuráis

    samurais[1] = Samurai:new(60, 210)
    samurais[2] = Samurai:new(140, 210)
    samurais[3] = Samurai:new(100, 250)
    samurais[4] = Samurai:new(180, 250)

    for _, enemigo in ipairs(samurais) do
        mundo:add(
            enemigo,
            enemigo.x,
            enemigo.y,
            enemigo.ancho,
            enemigo.alto
        )
    end


    -- Sala 3: 6 caballeros

    caballeros[1] = Caballero:new(380, 210)
    caballeros[2] = Caballero:new(440, 210)
    caballeros[3] = Caballero:new(500, 210)
    caballeros[4] = Caballero:new(400, 260)
    caballeros[5] = Caballero:new(460, 260)
    caballeros[6] = Caballero:new(520, 260)

    for _, enemigo in ipairs(caballeros) do
        mundo:add(
            enemigo,
            enemigo.x,
            enemigo.y,
            enemigo.ancho,
            enemigo.alto
        )
    end


    -- Sala 4: un enemigo grande de cada tipo

    esqueletoFinal = Esqueleto:new(400, 70, true)
    samuraiFinal = Samurai:new(500, 70, true)
    caballeroFinal = Caballero:new(450, 115, true)

    mundo:add(
        esqueletoFinal,
        esqueletoFinal.x,
        esqueletoFinal.y,
        esqueletoFinal.ancho,
        esqueletoFinal.alto
    )

    mundo:add(
        samuraiFinal,
        samuraiFinal.x,
        samuraiFinal.y,
        samuraiFinal.ancho,
        samuraiFinal.alto
    )

    mundo:add(
        caballeroFinal,
        caballeroFinal.x,
        caballeroFinal.y,
        caballeroFinal.ancho,
        caballeroFinal.alto
    )


    camara = Camera()
end


function love.update(dt)
    jugador:update(dt, mundo)

    actualizarEnemigos(dt)

    actualizarCamara()
end


function actualizarEnemigos(dt)
    local sala = obtenerSalaJugador()


    for _, enemigo in ipairs(esqueletos) do
        enemigo.activo = sala == 1
        enemigo:update(dt, mundo, jugador)
    end


    for _, enemigo in ipairs(samurais) do
        enemigo.activo = sala == 2
        enemigo:update(dt, mundo, jugador)
    end


    for _, enemigo in ipairs(caballeros) do
        enemigo.activo = sala == 3
        enemigo:update(dt, mundo, jugador)
    end


    esqueletoFinal.activo = sala == 4
    samuraiFinal.activo = sala == 4
    caballeroFinal.activo = sala == 4

    esqueletoFinal:update(dt, mundo, jugador)
    samuraiFinal:update(dt, mundo, jugador)
    caballeroFinal:update(dt, mundo, jugador)
end


function obtenerSalaJugador()
    local x = jugador.x + jugador.ancho / 2
    local y = jugador.y + jugador.alto / 2

    if x < 320 and y < 160 then
        return 1
    end

    if x < 320 and y >= 160 then
        return 2
    end

    if x >= 320 and y >= 160 then
        return 3
    end

    return 4
end


function actualizarCamara()
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
        end

        if x > anchoMapa - anchoPantalla / 2 then
            x = anchoMapa - anchoPantalla / 2
        end
    end

    if altoMapa <= altoPantalla then
        y = altoMapa / 2
    else
        if y < altoPantalla / 2 then
            y = altoPantalla / 2
        end

        if y > altoMapa - altoPantalla / 2 then
            y = altoMapa - altoPantalla / 2
        end
    end

    camara:lookAt(x, y)
end


function love.draw()
    camara:attach()

    mapa:draw()

    jugador:draw()


    for _, enemigo in ipairs(esqueletos) do
        enemigo:draw()
    end

    for _, enemigo in ipairs(samurais) do
        enemigo:draw()
    end

    for _, enemigo in ipairs(caballeros) do
        enemigo:draw()
    end


    esqueletoFinal:draw()
    samuraiFinal:draw()
    caballeroFinal:draw()


    camara:detach()
end