local MaquinaEstado = {}
MaquinaEstado.__index = MaquinaEstado

function MaquinaEstado:new()
    local maquina = setmetatable({}, MaquinaEstado)

    maquina.estado = nil
    maquina.siguienteEstado = nil
    maquina.transicionando = false
    maquina.fade = 0
    maquina.velocidadFade = 2.5
    maquina.fadeEntrada = true

    return maquina
end

function MaquinaEstado:cambiar(estado)
    if self.transicionando then
        return
    end

    self.siguienteEstado = estado
    self.transicionando = true
    self.fadeEntrada = false
end

function MaquinaEstado:iniciar(estado)
    self.estado = estado
    self.transicionando = true
    self.fade = 1
    self.fadeEntrada = true

    if self.estado.entrar then
        self.estado:entrar()
    end
end

function MaquinaEstado:update(dt)
    if self.transicionando then
        if self.fadeEntrada then
            self.fade = self.fade - self.velocidadFade * dt

            if self.fade <= 0 then
                self.fade = 0
                self.transicionando = false
            end
        else
            self.fade = self.fade + self.velocidadFade * dt

            if self.fade >= 1 then
                self.fade = 1

                if self.estado.salir then
                    self.estado:salir()
                end

                self.estado = self.siguienteEstado
                self.siguienteEstado = nil

                if self.estado.entrar then
                    self.estado:entrar()
                end

                self.fadeEntrada = true
            end
        end

        return
    end

    if self.estado and self.estado.update then
        self.estado:update(dt)
    end
end

function MaquinaEstado:keypressed(tecla)
    if self.transicionando then
        return
    end

    if self.estado and self.estado.keypressed then
        self.estado:keypressed(tecla)
    end
end

function MaquinaEstado:draw()
    if self.estado and self.estado.draw then
        self.estado:draw()
    end

    if self.fade > 0 then
        love.graphics.setColor(0, 0, 0, self.fade)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return MaquinaEstado