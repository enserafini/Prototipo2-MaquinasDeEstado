local sti = require("lib.sti")
local bump = require("lib.bump")
local Camera = require("lib.camera")

local Sonidos = require("sonidos")

local Jugador = require("jugador")
local Esqueleto = require("enemigos.esqueleto")
local Samurai = require("enemigos.samurai")
local Caballero = require("enemigos.caballero")

local EstadoJugar = {}
EstadoJugar.__index = EstadoJugar

function EstadoJugar:new(maquina, ventana)
    local estado = setmetatable({}, EstadoJugar)

    estado.maquina = maquina
    estado.ventana = ventana
    estado.mapa = nil
    estado.mundo = nil
    estado.jugador = nil
    estado.camara = nil
    estado.enemigos = {}
    estado.salasCompletadas = {}
    estado.bossesMuertos = 0

    return estado
end

function EstadoJugar:entrar()
    Sonidos.reproducirMusica(Sonidos.musicaJuego)

    self.mapa = sti("mapa/nivel1.lua")
    self.mundo = bump.newWorld(16)
    self.jugador = Jugador:new(80, 80)

    self.enemigos = {}
    self.salasCompletadas = {}
    self.bossesMuertos = 0

    self:crearParedes()
    self:crearJugador()
    self:crearEnemigos()

    self.camara = Camera(self.jugador.x + self.jugador.ancho / 2, self.jugador.y + self.jugador.alto / 2, 4)
end

function EstadoJugar:crearParedes()
    if not self.mapa.layers["Paredes"] then
        return
    end

    for _, objeto in ipairs(self.mapa.layers["Paredes"].objects) do
        if objeto.width and objeto.height and objeto.width > 0 and objeto.height > 0 then
            objeto.es_pared = true
            self.mundo:add(objeto, objeto.x, objeto.y, objeto.width, objeto.height)
        end
    end
end

function EstadoJugar:crearJugador()
    self.mundo:add(self.jugador, self.jugador.x, self.jugador.y, self.jugador.ancho, self.jugador.alto)
end

function EstadoJugar:crearEnemigos()
    table.insert(self.enemigos, Esqueleto:new(210, 80, 1))
    table.insert(self.enemigos, Esqueleto:new(250, 110, 1))

    table.insert(self.enemigos, Samurai:new(80, 220, 2))
    table.insert(self.enemigos, Samurai:new(130, 240, 2))
    table.insert(self.enemigos, Samurai:new(190, 220, 2))
    table.insert(self.enemigos, Samurai:new(250, 250, 2))

    table.insert(self.enemigos, Caballero:new(350, 210, 3))
    table.insert(self.enemigos, Caballero:new(400, 230, 3))
    table.insert(self.enemigos, Caballero:new(450, 210, 3))
    table.insert(self.enemigos, Caballero:new(500, 240, 3))
    table.insert(self.enemigos, Caballero:new(550, 210, 3))
    table.insert(self.enemigos, Caballero:new(600, 250, 3))

    local boss1 = Esqueleto:new(430, 70, 4, 2)
    boss1.velocidad = 25
    boss1.vida = 250
    boss1.vidaMaxima = 250
    boss1.daño = 40

    local boss2 = Samurai:new(500, 90, 4, 2)
    boss2.velocidad = 28
    boss2.vida = 300
    boss2.vidaMaxima = 300
    boss2.daño = 45

    local boss3 = Caballero:new(570, 70, 4, 2)
    boss3.velocidad = 22
    boss3.vida = 350
    boss3.vidaMaxima = 350
    boss3.daño = 50

    table.insert(self.enemigos, boss1)
    table.insert(self.enemigos, boss2)
    table.insert(self.enemigos, boss3)

    for _, enemigo in ipairs(self.enemigos) do
        self.mundo:add(enemigo, enemigo.x, enemigo.y, enemigo.ancho, enemigo.alto)
    end
end

function EstadoJugar:obtenerSalaJugador()
    local x = self.jugador.x + self.jugador.ancho / 2
    local y = self.jugador.y + self.jugador.alto / 2

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

function EstadoJugar:verificarSala(sala)
    if self.salasCompletadas[sala] then
        return
    end

    local hayEnemigos = false

    for _, enemigo in ipairs(self.enemigos) do
        if enemigo.sala == sala then
            hayEnemigos = true

            if enemigo.vivo then
                return
            end
        end
    end

    if hayEnemigos then
        self.jugador.vida = self.jugador.vidaMaxima
        self.salasCompletadas[sala] = true
    end
end

function EstadoJugar:verificarBosses()
    local bossesVivos = 0
    local totalBosses = 0

    for _, enemigo in ipairs(self.enemigos) do
        if enemigo.sala == 4 then
            totalBosses = totalBosses + 1

            if enemigo.vivo then
                bossesVivos = bossesVivos + 1
            end
        end
    end

    if totalBosses == 0 then
        return false
    end

    local muertos = totalBosses - bossesVivos

    if muertos > self.bossesMuertos then
        self.bossesMuertos = muertos
        self.jugador.vida = self.jugador.vidaMaxima
    end

    if bossesVivos == 0 then
        self.jugador.vida = self.jugador.vidaMaxima
        self.jugador.vivo = true
        self.jugador.muriendo = false
        self.jugador.atacando = false
        self.jugador.tiempoMuerte = 0
        self.jugador.frame = 1

        self.maquina:cambiar(self.maquina.estadoVictoria)

        return true
    end

    return false
end

function EstadoJugar:update(dt)
    self.mapa:update(dt)

    if self.maquina.siguienteEstado == self.maquina.estadoVictoria then
        return
    end

    if self.jugador.muriendo then
        self.jugador:update(dt, self.mundo)

        if not self.jugador.vivo then
            self.maquina:cambiar(self.maquina.estadoDerrota)
        end

        return
    end

    self.jugador:update(dt, self.mundo)

    local sala = self:obtenerSalaJugador()

    for _, enemigo in ipairs(self.enemigos) do
        if enemigo.vivo then
            enemigo.activo = enemigo.sala == sala
        else
            enemigo.activo = false
        end

        enemigo:update(dt, self.mundo, self.jugador)
    end

    self:verificarSala(sala)

    if self:verificarBosses() then
        return
    end

    if not self.jugador.vivo then
        self.maquina:cambiar(self.maquina.estadoDerrota)
        return
    end

    self.camara:lookAt(
        math.floor(self.jugador.x + self.jugador.ancho / 2 + 0.5),
        math.floor(self.jugador.y + self.jugador.alto / 2 + 0.5)
    )

    self:limitarCamara()
end

function EstadoJugar:limitarCamara()
    local ancho = love.graphics.getWidth()
    local alto = love.graphics.getHeight()
    local anchoVisible = ancho / self.camara.scale
    local altoVisible = alto / self.camara.scale
    local mitadAncho = anchoVisible / 2
    local mitadAlto = altoVisible / 2

    local mapaAncho = self.mapa.width * self.mapa.tilewidth
    local mapaAlto = self.mapa.height * self.mapa.tileheight

    if self.camara.x < mitadAncho then
        self.camara.x = mitadAncho
    end

    if self.camara.y < mitadAlto then
        self.camara.y = mitadAlto
    end

    if self.camara.x > mapaAncho - mitadAncho then
        self.camara.x = mapaAncho - mitadAncho
    end

    if self.camara.y > mapaAlto - mitadAlto then
        self.camara.y = mapaAlto - mitadAlto
    end
end

function EstadoJugar:keypressed(tecla)
    if tecla == "space" then
        self.jugador:atacar()
        self:golpearEnemigos()
    end
end

function EstadoJugar:golpearEnemigos()
    if not self.jugador.vivo or self.jugador.muriendo then
        return
    end

    for _, enemigo in ipairs(self.enemigos) do
        if enemigo.vivo and enemigo.activo then
            local dx = enemigo.x - self.jugador.x
            local dy = enemigo.y - self.jugador.y
            local distancia = math.sqrt(dx * dx + dy * dy)

            if distancia <= 28 then
                enemigo:recibirDaño(self.jugador.daño)
            end
        end
    end

    self:verificarBosses()
end

function EstadoJugar:dibujarMapa()
    for _, capa in ipairs(self.mapa.layers) do
        if capa.type == "tilelayer" and capa.visible ~= false then
            self.mapa:drawLayer(capa)
        end
    end
end

function EstadoJugar:dibujarInterfaz()
    local x = 8
    local y = 5
    local anchoBarra = 150
    local altoBarra = 16

    local porcentaje = self.jugador.vida / self.jugador.vidaMaxima

    if porcentaje < 0 then
        porcentaje = 0
    end

    if porcentaje > 1 then
        porcentaje = 1
    end

    local fuente = love.graphics.newFont("fuentes/font.ttf", 11)
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

    local textoVida = math.floor(self.jugador.vida) .. " / " .. self.jugador.vidaMaxima
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

function EstadoJugar:draw()
    self.camara:attach(0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    self:dibujarMapa()
    self.jugador:draw()

    for _, enemigo in ipairs(self.enemigos) do
        enemigo:draw()
    end

    self.camara:detach()
    self:dibujarInterfaz()
end

function EstadoJugar:salir()
end

return EstadoJugar