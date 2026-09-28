local Sonidos = {}

function Sonidos.buscarArchivo(a, b)
    local nombre = b or a
    local archivos = love.filesystem.getDirectoryItems("sonidos")

    for _, archivo in ipairs(archivos) do
        local nombreArchivo = archivo:match("(.+)%.[^%.]+$")

        if nombreArchivo == nombre then
            return "sonidos/" .. archivo
        end
    end

    print("No se encontro el archivo de sonido: " .. tostring(nombre))

    return nil
end

function Sonidos:cargarEfecto(nombre)
    local ruta = Sonidos.buscarArchivo(nombre)

    if not ruta then
        return nil
    end

    return love.audio.newSource(ruta, "static")
end

function Sonidos:cargarMusica(nombre)
    local ruta = Sonidos.buscarArchivo(nombre)

    if not ruta then
        return nil
    end

    local musica = love.audio.newSource(ruta, "stream")
    musica:setLooping(true)

    return musica
end

function Sonidos.detenerMusicas()
    if Sonidos.musicaInicio then
        Sonidos.musicaInicio:stop()
    end

    if Sonidos.musicaJuego then
        Sonidos.musicaJuego:stop()
    end

    if Sonidos.musicaVictoria then
        Sonidos.musicaVictoria:stop()
    end

    if Sonidos.musicaDerrota then
        Sonidos.musicaDerrota:stop()
    end
end

function Sonidos.reproducirMusica(musica)
    Sonidos.detenerMusicas()

    if musica then
        musica:stop()
        musica:play()
    end
end

function Sonidos.reproducirEfecto(efecto)
    if efecto then
        efecto:stop()
        efecto:play()
    end
end

function Sonidos.iniciar()
    Sonidos.ataqueJugador = Sonidos:cargarEfecto("ataqueJugador")
    Sonidos.muerteJugador = Sonidos:cargarEfecto("muerteJugador")
    Sonidos.ataqueEnemigo = Sonidos:cargarEfecto("ataqueEnemigo")
    Sonidos.muerteEnemigo = Sonidos:cargarEfecto("muerteEnemigo")

    Sonidos.musicaInicio = Sonidos:cargarMusica("musicaInicio")
    Sonidos.musicaJuego = Sonidos:cargarMusica("musicaJuego")
    Sonidos.musicaVictoria = Sonidos:cargarMusica("musicaVictoria")
    Sonidos.musicaDerrota = Sonidos:cargarMusica("musicaDerrota")
end

return Sonidos