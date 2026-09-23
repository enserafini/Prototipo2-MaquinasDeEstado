Jugador = Class{}

function Jugador:init(x, y, velocidad)
    self.sprite = love.graphics.newImage("img/Ninja.png")

    self.ancho = self.sprite:getWidth()
    self.alto = self.sprite:getHeight()

    self.origen_x = self.ancho / 2
    self.origen_y = self.alto / 2

    self.x = x
    self.y = y
    self.velocidad = velocidad
end

function Jugador:Actualizar(dt)
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.x = self.x + self.velocidad * dt
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.x = self.x - self.velocidad * dt
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        self.y = self.y + self.velocidad * dt
    elseif love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        self.y = self.y - self.velocidad * dt
    end
end

function Jugador:Dibujar()
    love.graphics.draw(
        self.sprite,
        self.x,
        self.y,
        0,
        1,
        1,
        self.origen_x,
        self.origen_y
    )
end