function onSay(cid, words, param, channel)
        if os.time() > getPlayerStorageValue(cid, 14001) then
                setPlayerStorageValue(cid, 14001, os.time()+180)
                local file = io.open('data/logs/log.txt','a')
                file:write(getCreatureName(cid)..": "..tostring(param).."\n")
                file:close()
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING,'Mensagem enviada com sucesso.')
        else
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING,'Voc� n�o pode mandar outra mensagem ainda. Falta(m) '..(math.ceil((getPlayerStorageValue(cid, 14001)-os.time())/60)+1)..' minuto(s) para voc� poder mandar uma nova mensagem.')
        end
return TRUE
end