local Jugador = {}
Jugador.__index = Jugador

function Jugador:new(x, y)
    local jugador = setmetatable({}, Jugador)

    jugador.x = x
    jugador.y = y
    jugador.ancho = 16
    jugador.alto = 16
    jugador.velocidad = 100

    jugador.vida = 100
    jugador.vidaMaxima = 100
    jugador.vivo = true
    jugador.daño = 30

    jugador.tiempoInvulnerable = 0
    jugador.duracionInvulnerable = 0.7

    jugador.muriendo = false
    jugador.tiempoMuerte = 0
    jugador.duracionMuerte = 0.8

    jugador.imagen = love.graphics.newImage("img/Ninja.png")
    jugador.imagen:setFilter("nearest", "nearest")

    jugador.direccion = "abajo"
    jugador.frame = 1
    jugador.tiempoAnimacion = 0
    jugador.velocidadAnimacion = 0.10

    jugador.atacando = false
    jugador.tiempoAtaque = 0
    jugador.duracionAtaque = 0.6

    jugador.quads = {}
    jugador:crearAnimaciones()

    return jugador
end

function Jugador:crearAnimaciones()
    self.quads.abajo = {}
    self.quads.izquierda = {}
    self.quads.arriba = {}
    self.quads.derecha = {}
    self.quads.ataque = {}
    self.quads.muerte = {}

    local filas = {
        abajo = 1,
        izquierda = 2,
        arriba = 3,
        derecha = 4
    }

    -- cada fila de la imagen corresponde a una direccion
    for nombre, fila in pairs(filas) do
        for i = 1, 4 do
            self.quads[nombre][i] = love.graphics.newQuad(
                (i - 1) * 16,
                (fila - 1) * 16,
                16,
                16,
                self.imagen:getWidth(),
                self.imagen:getHeight()
            )
        end
    end

    -- las ultimas dos filas son para ataque y muerte
    for i = 1, 6 do
        self.quads.ataque[i] = love.graphics.newQuad(
            (i - 1) * 16,
            4 * 16,
            16,
            16,
            self.imagen:getWidth(),
            self.imagen:getHeight()
        )

        self.quads.muerte[i] = love.graphics.newQuad(
            (i - 1) * 16,
            5 * 16,
            16,
            16,
            self.imagen:getWidth(),
            self.imagen:getHeight()
        )
    end
end

function Jugador:update(dt, mundo)
    if self.muriendo then
        self:actualizarMuerte(dt)
        return
    end

    if not self.vivo then
        return
    end

    if self.tiempoInvulnerable > 0 then
        self.tiempoInvulnerable = self.tiempoInvulnerable - dt

        if self.tiempoInvulnerable < 0 then
            self.tiempoInvulnerable = 0
        end
    end

    local dx = 0
    local dy = 0

    if love.keyboard.isDown("w") then
        dy = dy - 1
        self.direccion = "arriba"
    end

    if love.keyboard.isDown("s") then
        dy = dy + 1
        self.direccion = "abajo"
    end

    if love.keyboard.isDown("a") then
        dx = dx - 1
        self.direccion = "izquierda"
    end

    if love.keyboard.isDown("d") then
        dx = dx + 1
        self.direccion = "derecha"
    end

    if dx ~= 0 or dy ~= 0 then
        -- normaliza el movimiento para que diagonal no sea mas rapido
        local distancia = math.sqrt(dx * dx + dy * dy)
        dx = dx / distancia
        dy = dy / distancia

        local nuevoX = self.x + dx * self.velocidad * dt
        local nuevoY = self.y + dy * self.velocidad * dt

        local x, y = mundo:move(self, nuevoX, nuevoY)

        self.x = x
        self.y = y

        if not self.atacando then
            self:actualizarAnimacion(dt)
        end
    else
        if not self.atacando then
            self.frame = 1
            self.tiempoAnimacion = 0
        end
    end

    if self.atacando then
        self:actualizarAtaque(dt)
    end
end

function Jugador:actualizarAnimacion(dt)
    self.tiempoAnimacion = self.tiempoAnimacion + dt

    if self.tiempoAnimacion >= self.velocidadAnimacion then
        self.tiempoAnimacion = self.tiempoAnimacion - self.velocidadAnimacion
        self.frame = self.frame + 1

        if self.frame > 4 then
            self.frame = 1
        end
    end
end

function Jugador:atacar()
    if not self.vivo or self.muriendo or self.atacando then
        return
    end

    self.atacando = true
    self.tiempoAtaque = 0
    self.frame = 1
end

function Jugador:actualizarAtaque(dt)
    self.tiempoAtaque = self.tiempoAtaque + dt

    local progreso = self.tiempoAtaque / self.duracionAtaque
    self.frame = math.floor(progreso * 6) + 1

    if self.frame > 6 then
        self.frame = 6
    end

    if self.tiempoAtaque >= self.duracionAtaque then
        self.atacando = false
        self.tiempoAtaque = 0
        self.frame = 1
    end
end

function Jugador:recibirDaño(daño)
    if not self.vivo or self.muriendo or self.tiempoInvulnerable > 0 then
        return
    end

    self.vida = self.vida - daño

    if self.vida <= 0 then
        self.vida = 0
        self.vivo = false
        self.muriendo = true
        self.atacando = false
        self.tiempoMuerte = 0
        self.frame = 1
        return
    end

    -- evita recibir varios golpes seguidos sin tiempo para reaccionar
    self.tiempoInvulnerable = self.duracionInvulnerable
end

function Jugador:actualizarMuerte(dt)
    self.tiempoMuerte = self.tiempoMuerte + dt

    local progreso = self.tiempoMuerte / self.duracionMuerte
    self.frame = math.floor(progreso * 6) + 1

    if self.frame > 6 then
        self.frame = 6
    end
end

function Jugador:draw()
    local quad
    local escalaX = 1
    local rotacion = 0

    if self.muriendo then
        quad = self.quads.muerte[self.frame]
    elseif self.atacando then
        quad = self.quads.ataque[self.frame]

        if self.direccion == "izquierda" then
            escalaX = -1
        elseif self.direccion == "abajo" then
            rotacion = math.pi / 2
        elseif self.direccion == "arriba" then
            rotacion = -math.pi / 2
        end
    else
        quad = self.quads[self.direccion][self.frame]
    end

    if not quad then
        return
    end

    love.graphics.draw(
        self.imagen,
        quad,
        self.x + 8,
        self.y + 8,
        rotacion,
        escalaX,
        1,
        8,
        8
    )
end

return Jugador