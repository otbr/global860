function onSay(cid, words, param)
if doPlayerRemoveMoney(cid, 1000000) == TRUE then
setPlayerStorageValue(cid,13540,1)
doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Parabens agora voce e vip.")
doSendMagicEffect(getPlayerPosition(cid), 28)
else
doPlayerSendCancel(cid, "Voce precisa de 1kk para comprar Vip.")
doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voce nao tem 1kk para comprar Vip.")
doSendMagicEffect(getPlayerPosition(cid), 2)
end
end