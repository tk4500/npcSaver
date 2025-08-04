require("firecast.lua");
local npcCommands = require("npcCommands.lua");

Npcs = {};

Firecast.listen('HandleChatCommand',
    function(message)
        local id = message.room.codigoInterno;
        if #message.command == 3 then
            if message.command == 'npc' then
                if Npcs[id] == nil then
                    Npcs[id] = {};
                end
                npcCommands.handleCommand(message.parameter, message.chat, id);
                message.response = { handled = true }
            else
                if Npcs[id] == nil then
                    Npcs[id] = {};
                end
                local npc = Npcs[id];
                if npc[message.command] ~= nil then
                    npcCommands.sendMessage(npc[message.command], message.chat, message.parameter);
                    message.response = { handled = true }
                end
            end
        end
    end
)
Firecast.listen('ListChatCommands',
    function(message)
        message.response = {npcCommands.help};
    end
)
if not VHD.fileExists("npcs.txt") then
    VHD.openFile("npcs.txt", "w");
end

local test = VHD.openFile("npcs.txt");
if test then
    local txtData = {}
    local lidos = test:read(txtData, test.size)
    if lidos > 0 then
        local result = string.char(table.unpack(txtData));
        local success, data = pcall(strToTable, result);
        if success then
            Npcs = data;
            Log.i('NPCs carregados com sucesso.');
        else
            Log.e('Erro ao decodificar o txt: ' .. data);
        end
    else
        Log.e('Erro ao ler o arquivo.');
    end
else
    Log.e('Arquivo não encontrado ou inválido.');
end