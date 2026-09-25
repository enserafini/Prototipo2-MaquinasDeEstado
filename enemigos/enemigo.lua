local Enemigo = {}
Enemigo.__index = Enemigo

function Enemigo:new(x, y, ancho, alto, velocidad, vida, daño, imagen, sala)
    local enemigo = setmetatable({}, Enemigo)

    enemigo.x = x
    enemigo.y = y
    enemigo.ancho = ancho
    enemigo.alto = alto
    enemigo.velocidad = velocidad
    enemigo.vida = vida
    enemigo.daño = daño
    enemigo.imagen = love.graphics.newImage(imagen)
    enemigo.sala = sala
    enemigo.activo = false
    enemigo.distanciaMinima = 18

    return enemigo
end

function Enemigo:update(dt, mundo, jugador)
    if not self.activo then
        return
    end

    local dx = jugador.x - self.x
    local dy = jugador.y - self.y

    local distancia = math.sqrt(dx * dx + dy * dy)

    if distancia <= self.distanciaMinima then
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
end

function Enemigo:moverA(x, y, mundo)
    local nuevoX, nuevoY = mundo:move(self, x, y)

    self.x = nuevoX
    self.y = nuevoY
end

function Enemigo:draw()
    love.graphics.draw(
        self.imagen,
        self.x,
        self.y,
        0,
        self.ancho / self.imagen:getWidth(),
        self.alto / self.imagen:getHeight()
    )
end

return Enemigo