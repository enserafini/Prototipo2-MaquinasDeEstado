local sti = require("lib.sti")
local bump = require("lib.bump")
local Camera = require("lib.camera")

local Jugador = require("jugador")
local Esqueleto = require("enemigos.esqueleto")
local Samurai = require("enemigos.samurai")
local Caballero = require("enemigos.caballero")

local ventana = {
    ancho = 1280,
    alto = 720
}

local mapa
local mundo
local jugador
local camara
local enemigos = {}
local salasCompletadas = {}
local bossesMuertos = 0
local juegoGanado = false

local function redondear(numero)
    return math.floor(numero + 0.5)
end

function love.load()
    love.window.setMode(ventana.ancho, ventana.alto)
    love.graphics.setDefaultFilter("nearest", "nearest")

    mapa = sti("mapa/nivel1.lua")
    mundo = bump.newWorld(16)

    -- agrega las paredes del mapa al sistema de colisiones
    if mapa.layers["Paredes"] then
        for _, objeto in ipairs(mapa.layers["Paredes"].objects) do
            if objeto.width and objeto.height and objeto.width > 0 and objeto.height > 0 then
                objeto.es_pared = true
                mundo:add(objeto, objeto.x, objeto.y, objeto.width, objeto.height)
            end
        end
    end

    jugador = Jugador:new(80, 80)
    mundo:add(jugador, jugador.x, jugador.y, jugador.ancho, jugador.alto)

    -- enemigos de la primera sala
    table.insert(enemigos, Esqueleto:new(210, 80, 1))
    table.insert(enemigos, Esqueleto:new(250, 110, 1))

    -- enemigos de la segunda sala
    table.insert(enemigos, Samurai:new(80, 220, 2))
    table.insert(enemigos, Samurai:new(130, 240, 2))
    table.insert(enemigos, Samurai:new(190, 220, 2))
    table.insert(enemigos, Samurai:new(250, 250, 2))

    -- enemigos de la tercera sala
    table.insert(enemigos, Caballero:new(350, 210, 3))
    table.insert(enemigos, Caballero:new(400, 230, 3))
    table.insert(enemigos, Caballero:new(450, 210, 3))
    table.insert(enemigos, Caballero:new(500, 240, 3))
    table.insert(enemigos, Caballero:new(550, 210, 3))
    table.insert(enemigos, Caballero:new(600, 250, 3))

    -- bosses de la sala final
    table.insert(enemigos, Esqueleto:new(430, 70, 4, 28, 250, 40, 2))
    table.insert(enemigos, Samurai:new(500, 90, 4, 32, 300, 45, 2))
    table.insert(enemigos, Caballero:new(570, 70, 4, 25, 350, 50, 2))

    for _, enemigo in ipairs(enemigos) do
        mundo:add(enemigo, enemigo.x, enemigo.y, enemigo.ancho, enemigo.alto)
    end

    camara = Camera(jugador.x + jugador.ancho / 2, jugador.y + jugador.alto / 2, 4)
end

local function obtenerSalaJugador()
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

local function verificarSala(sala)
    if salasCompletadas[sala] then
        return
    end

    local hayEnemigos = false

    for _, enemigo in ipairs(enemigos) do
        if enemigo.sala == sala then
            hayEnemigos = true

            if enemigo.vivo then
                return
            end
        end
    end

    if hayEnemigos then
        jugador.vida = jugador.vidaMaxima
        salasCompletadas[sala] = true
    end
end

local function verificarBosses()
    if juegoGanado then
        return
    end

    local bossesVivos = 0
    local totalBosses = 0

    for _, enemigo in ipairs(enemigos) do
        if enemigo.sala == 4 then
            totalBosses = totalBosses + 1

            if enemigo.vivo then
                bossesVivos = bossesVivos + 1
            end
        end
    end

    local muertos = totalBosses - bossesVivos

    -- cada boss muerto recupera toda la vida del jugador
    if muertos > bossesMuertos then
        bossesMuertos = muertos
        jugador.vida = jugador.vidaMaxima
    end

    if bossesVivos == 0 and totalBosses > 0 then
        juegoGanado = true
        jugador.vida = jugador.vidaMaxima
    end
end

function love.update(dt)
    mapa:update(dt)
    jugador:update(dt, mundo)

    camara:lookAt(
        redondear(jugador.x + jugador.ancho / 2),
        redondear(jugador.y + jugador.alto / 2)
    )

    local sala = obtenerSalaJugador()

    for _, enemigo in ipairs(enemigos) do
        if enemigo.vivo then
            enemigo.activo = enemigo.sala == sala
        else
            enemigo.activo = false
        end

        enemigo:update(dt, mundo, jugador)
    end

    verificarBosses()
    verificarSala(sala)

    local anchoVisible = ventana.ancho / camara.scale
    local altoVisible = ventana.alto / camara.scale

    local mitadAncho = anchoVisible / 2
    local mitadAlto = altoVisible / 2

    local mapaAncho = mapa.width * mapa.tilewidth
    local mapaAlto = mapa.height * mapa.tileheight

    if camara.x < mitadAncho then
        camara.x = mitadAncho
    end

    if camara.y < mitadAlto then
        camara.y = mitadAlto
    end

    if camara.x > mapaAncho - mitadAncho then
        camara.x = mapaAncho - mitadAncho
    end

    if camara.y > mapaAlto - mitadAlto then
        camara.y = mapaAlto - mitadAlto
    end
end

function love.keypressed(tecla)
    if tecla == "space" then
        jugador:atacar()
        golpearEnemigos()
    end
end

function golpearEnemigos()
    if not jugador.vivo then
        return
    end

    for _, enemigo in ipairs(enemigos) do
        if enemigo.vivo and enemigo.activo then
            local dx = enemigo.x - jugador.x
            local dy = enemigo.y - jugador.y
            local distancia = math.sqrt(dx * dx + dy * dy)

            if distancia <= 28 then
                enemigo:recibirDaño(jugador.daño)
            end
        end
    end
end

local function dibujarMapa()
    for _, capa in ipairs(mapa.layers) do
        if capa.type == "tilelayer" and capa.visible ~= false then
            mapa:drawLayer(capa)
        end
    end
end

local function dibujarInterfaz()
    local x = 8
    local y = 5
    local anchoBarra = 150
    local altoBarra = 16

    local porcentaje = jugador.vida / jugador.vidaMaxima

    if porcentaje < 0 then
        porcentaje = 0
    end

    if porcentaje > 1 then
        porcentaje = 1
    end

    local fuente = love.graphics.newFont(11)
    love.graphics.setFont(fuente)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("BARRA DE VIDA", x, y)

    love.graphics.setColor(0.05, 0.05, 0.05, 1)
    love.graphics.rectangle("fill", x - 2, y + 14, anchoBarra + 4, altoBarra + 4)

    love.graphics.setColor(0.15, 0.15, 0.15, 1)
    love.graphics.rectangle("fill", x, y + 16, anchoBarra, altoBarra)

    love.graphics.setColor(0.75, 0.08, 0.08, 1)
    love.graphics.rectangle("fill", x, y + 16, anchoBarra * porcentaje, altoBarra)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y + 16, anchoBarra, altoBarra)

    love.graphics.setColor(1, 1, 1, 1)

    local textoVida = math.floor(jugador.vida) .. " / " .. jugador.vidaMaxima
    local anchoTexto = fuente:getWidth(textoVida)
    local altoTexto = fuente:getHeight()

    love.graphics.print(
        textoVida,
        x + anchoBarra / 2 - anchoTexto / 2,
        y + 16 + altoBarra / 2 - altoTexto / 2
    )

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

function love.draw()
    camara:attach(0, 0, ventana.ancho, ventana.alto)

    dibujarMapa()
    jugador:draw()

    for _, enemigo in ipairs(enemigos) do
        enemigo:draw()
    end

    camara:detach()

    dibujarInterfaz()
end