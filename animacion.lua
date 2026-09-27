local Animacion = {}
Animacion.__index = Animacion

function Animacion:new(imagen, fila, cantidadFrames, velocidad)
    local animacion = setmetatable({}, Animacion)

    animacion.imagen = imagen
    animacion.fila = fila
    animacion.cantidadFrames = cantidadFrames
    animacion.velocidad = velocidad

    animacion.frame = 1
    animacion.tiempo = 0
    animacion.quads = {}

    -- guarda cada frame del spritesheet para poder mostrarlo por separado
    for i = 1, cantidadFrames do
        local x = (i - 1) * 16
        local y = (fila - 1) * 16

        animacion.quads[i] = love.graphics.newQuad(x, y, 16, 16, imagen:getWidth(), imagen:getHeight())
    end

    return animacion
end

function Animacion:update(dt)
    self.tiempo = self.tiempo + dt

    if self.tiempo >= self.velocidad then
        self.tiempo = self.tiempo - self.velocidad
        self.frame = self.frame + 1

        if self.frame > self.cantidadFrames then
            self.frame = 1
        end
    end
end

function Animacion:reiniciar()
    self.frame = 1
    self.tiempo = 0
end

function Animacion:draw(x, y)
    love.graphics.draw(self.imagen, self.quads[self.frame], x, y)
end

return Animacion