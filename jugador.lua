local Jugador = {}
Jugador.__index = Jugador

function Jugador:new(x, y)
    local jugador = setmetatable({}, Jugador)

    jugador.x = x
    jugador.y = y
    jugador.ancho = 16
    jugador.alto = 16
    jugador.velocidad = 120

    jugador.imagen = love.graphics.newImage("img/Ninja.png")

    return jugador
end

function Jugador:update(dt, mundo)
    local dx = 0
    local dy = 0

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        dx = -self.velocidad * dt
    elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        dx = self.velocidad * dt
    end

    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        dy = -self.velocidad * dt
    elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        dy = self.velocidad * dt
    end

    local x, y = mundo:move(self, self.x + dx, self.y + dy)

    self.x = x
    self.y = y
end

function Jugador:draw()
    love.graphics.draw(self.imagen, self.x, self.y, 0, 16 / self.imagen:getWidth(), 16 / self.imagen:getHeight())
end

return Jugador