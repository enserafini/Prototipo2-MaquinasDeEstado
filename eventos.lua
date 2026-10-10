
local Eventos = {}

Eventos.oyentes = {}

function Eventos.on(nombre_evento, callback)
    if not Eventos.oyentes[nombre_evento] then
        Eventos.oyentes[nombre_evento] = {}
    end

    table.insert(Eventos.oyentes[nombre_evento], callback)
end

function Eventos.emitir(nombre_evento, ...)
    local lista = Eventos.oyentes[nombre_evento]

    if not lista then
        return
    end

    for _, callback in ipairs(lista) do
        callback(...)
    end
end

function Eventos.limpiar(nombre_evento)
    if nombre_evento then
        Eventos.oyentes[nombre_evento] = nil
    else
        Eventos.oyentes = {}
    end
end

return Eventos
