-------------------------------------------------------
--------- Resource = "jig_chamados" (/chamar que verifica chama o player mais próximo!)
--------- Autor = jigsaw
--------- Github = https://github.com/jigbr
--------- Discord = jigsaw#2247
--------- Loja Discord = https://discord.gg/7xzbUeU
-------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-- INTEGRAÇÃO VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- /CHAMAR
-----------------------------------------------------------------------------------------------------------------------------------------

local empregos = { -- Aqui você pode adicionar novos grupos que poderão ser chamados utilizando esse mesmo sistema, primeiro você insere o argumento usado para chamar e depois a permissão respectiva.
    ['mec'] = {perm = 'mecanico.permissao'}, 
    ['samu'] = {perm = 'samu.permissao'},
}

RegisterCommand("chamar", function(source, args)
    if args[1] and empregos[args[1]] then
        local users = vRP.getUsersByPermission(empregos[args[1]].perm)
        local pcds = GetEntityCoords(GetPlayerPed(source))
        local identity = vRP.getUserIdentity(vRP.getUserId(source))
        if table.count(users) == 0 then
            TriggerClientEvent("Notify", source, 'negado', 'Não existe pessoas trabalhando nesse emprego no momento.') return
        end
        TriggerClientEvent("Notify", source, 'sucesso', 'Chamado feito com sucesso, aguarde!')
        local sorted = {}
        for user_id,source in pairs(users) do
            local cds = GetEntityCoords(GetPlayerPed(source))
            local distance = #(cds - pcds)
            table.insert(sorted, { id = parseInt(user_id), source = source, distance = distance })
        end
        table.sort(sorted, function(a,b) return a.distance < b.distance end)
        for _,user in pairs(sorted) do
            if source and vRP.request(user.source, 'Deseja aceitar o chamado de ' ..identity.name.. '?', 10) then
                TriggerClientEvent("Notify", source, 'sucesso', 'Chamado aceito por <b>' .. vRP.getUserIdentity(user.id).name .. '</b>, Aguarde no local!')
                vRPclient.playSound(source,"Event_Message_Purple","GTAO_FM_Events_Soundset")
                vRPclient._setGPS(user.source, pcds.x, pcds.y)
                return             
            end  
        end
        TriggerClientEvent("Notify", source, 'negado', 'Todos os trabalhadores estão ocupados! Tente novamente mais tarde!' )
    end
end)

function table.count(t)
    local c = 0
    for k,v in pairs(t) do c = c+1 end
    return c
end
-----------------------------------------------------------------------------------------------------------------------------------------
