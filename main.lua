require "dependencias"

ventana = {
    ancho = 160,
    alto = 144,
    escala = 4
}

jugador = nil

function love.load()
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")

    jugador = Jugador(ventana.ancho / 2, ventana.alto / 2, 60)
end

function love.update(dt)
    jugador:Actualizar(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)

    jugador:Dibujar()
end