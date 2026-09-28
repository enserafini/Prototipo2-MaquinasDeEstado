local Sonidos = require("sonidos")

local Enemigo = {}
Enemigo.__index = Enemigo

function Enemigo:new(x, y, sala, imagen, velocidad, vida, daño, escala)
    local enemigo = setmetatable({}, Enemigo)

    enemigo.x = x
    enemigo.y = y
    enemigo.ancho = 16
    enemigo.alto = 16
    enemigo.velocidad = velocidad
    enemigo.vida = vida
    enemigo.vidaMaxima = vida
    enemigo.daño = daño
    enemigo.escala = escala or 1
    enemigo.sala = sala
    enemigo.activo = false
    enemigo.vivo = true
    enemigo.distanciaAtaque = 22
    enemigo.tiempoEntreAtaques = 0
    enemigo.retrasoAtaque = 0.9
    enemigo.atacando = false
    enemigo.tiempoAtaque = 0
    enemigo.duracionAtaque = 0.45
    enemigo.muriendo = false
    enemigo.tiempoMuerte = 0
    enemigo.duracionMuerte = 0.6
    enemigo.direccion = "abajo"
    enemigo.animacion = "quieto"
    enemigo.frame = 1
    enemigo.tiempoAnimacion = 0
    enemigo.velocidadAnimacion = 0.10

    enemigo.imagen = love.graphics.newImage(imagen)
    enemigo.imagen:setFilter("nearest", "nearest")

    enemigo.sonidoAtaque = Sonidos:cargarEfecto("ataqueEnemigo")
    enemigo.sonidoMuerte = Sonidos:cargarEfecto("muerteEnemigo")

    enemigo.quads = {}
    enemigo:crearAnimaciones()

    return enemigo
end

function Enemigo:crearAnimaciones()
    local filas = {
        abajo = 1,
        izquierda = 2,
        arriba = 3,
        derecha = 4
    }

    for nombre, fila in pairs(filas) do
        self.quads[nombre] = {}

        for i = 1, 4 do
            self.quads[nombre][i] = love.graphics.newQuad((i - 1) * 16, (fila - 1) * 16, 16, 16, self.imagen:getWidth(), self.imagen:getHeight())
        end
    end

    -- guarda los frames de ataque y muerte del sprite
    self.quads.ataque = {}

    for i = 1, 6 do
        self.quads.ataque[i] = love.graphics.newQuad((i - 1) * 16, 4 * 16, 16, 16, self.imagen:getWidth(), self.imagen:getHeight())
    end

    self.quads.muerte = {}

    for i = 1, 6 do
        self.quads.muerte[i] = love.graphics.newQuad((i - 1) * 16, 5 * 16, 16, 16, self.imagen:getWidth(), self.imagen:getHeight())
    end
end

function Enemigo:actualizarDireccion(dx, dy)
    if math.abs(dx) > math.abs(dy) then
        if dx > 0 then
            self.direccion = "derecha"
        else
            self.direccion = "izquierda"
        end
    else
        if dy > 0 then
            self.direccion = "abajo"
        else
            self.direccion = "arriba"
        end
    end
end

function Enemigo:update(dt, mundo, jugador)
    if self.muriendo then
        self:actualizarMuerte(dt)
        return
    end

    if not self.vivo or not self.activo or not jugador.vivo then
        self.animacion = "quieto"
        self.frame = 1
        return
    end

    if self.tiempoEntreAtaques > 0 then
        self.tiempoEntreAtaques = self.tiempoEntreAtaques - dt
    end

    if self.atacando then
        self:actualizarAtaque(dt, jugador)
        return
    end

    local dx = jugador.x - self.x
    local dy = jugador.y - self.y
    local distancia = math.sqrt(dx * dx + dy * dy)

    self:actualizarDireccion(dx, dy)

    if distancia <= self.distanciaAtaque then
        self.animacion = "quieto"
        self.frame = 1

        if self.tiempoEntreAtaques <= 0 then
            self:atacar()
        end

        return
    end

    if distancia > 0 then
        dx = dx / distancia
        dy = dy / distancia

        local nuevoX = self.x + dx * self.velocidad * dt
        local nuevoY = self.y + dy * self.velocidad * dt

        local x, y = mundo:move(self, nuevoX, nuevoY)

        self.x = x
        self.y = y
    end

    self.animacion = "caminar"
    self:actualizarAnimacion(dt)
end

function Enemigo:actualizarAnimacion(dt)
    self.tiempoAnimacion = self.tiempoAnimacion + dt

    if self.tiempoAnimacion >= self.velocidadAnimacion then
        self.tiempoAnimacion = self.tiempoAnimacion - self.velocidadAnimacion
        self.frame = self.frame + 1

        if self.frame > 4 then
            self.frame = 1
        end
    end
end

function Enemigo:atacar()
    if not self.vivo or self.atacando then
        return
    end

    self.atacando = true
    self.animacion = "ataque"
    self.frame = 1
    self.tiempoAtaque = 0

    if self.sonidoAtaque then
        self.sonidoAtaque:stop()
        self.sonidoAtaque:play()
    end
end

function Enemigo:actualizarAtaque(dt, jugador)
    self.tiempoAtaque = self.tiempoAtaque + dt

    local progreso = self.tiempoAtaque / self.duracionAtaque
    self.frame = math.floor(progreso * 6) + 1

    if self.frame > 6 then
        self.frame = 6
    end

    if self.tiempoAtaque >= self.duracionAtaque * 0.45 and not self.yaHizoDaño then
        self.yaHizoDaño = true

        local dx = jugador.x - self.x
        local dy = jugador.y - self.y
        local distancia = math.sqrt(dx * dx + dy * dy)

        if distancia <= self.distanciaAtaque + 6 then
            jugador:recibirDaño(self.daño)
        end
    end

    if self.tiempoAtaque >= self.duracionAtaque then
        self.atacando = false
        self.animacion = "quieto"
        self.frame = 1
        self.tiempoAtaque = 0
        self.yaHizoDaño = false
        self.tiempoEntreAtaques = self.retrasoAtaque
    end
end

function Enemigo:recibirDaño(daño)
    if not self.vivo or self.muriendo then
        return
    end

    self.vida = self.vida - daño

    if self.vida <= 0 then
        self.vida = 0
        self.vivo = false
        self.activo = false
        self.muriendo = true
        self.animacion = "muerte"
        self.frame = 1
        self.tiempoMuerte = 0

        if self.sonidoMuerte then
            self.sonidoMuerte:stop()
            self.sonidoMuerte:play()
        end
    end
end

function Enemigo:actualizarMuerte(dt)
    self.tiempoMuerte = self.tiempoMuerte + dt

    local progreso = self.tiempoMuerte / self.duracionMuerte
    self.frame = math.floor(progreso * 6) + 1

    if self.frame > 6 then
        self.frame = 6
    end
end

function Enemigo:draw()
    if not self.vivo and not self.muriendo then
        return
    end

    local quad

    if self.muriendo then
        quad = self.quads.muerte[self.frame]
    elseif self.atacando then
        quad = self.quads.ataque[self.frame]
    else
        quad = self.quads[self.direccion][self.frame]
    end

    if not quad then
        return
    end

    love.graphics.draw(self.imagen, quad, self.x + 8, self.y + 8, 0, self.escala, self.escala, 8, 8)
end

return Enemigo