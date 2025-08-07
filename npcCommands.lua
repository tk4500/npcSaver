require("ndb.lua");
require("dialogs.lua");
local json = require("json.lua");
local npcCommands = {};

npcCommands.saveNpcsToFile = function()
    local npcstxt = tableToStr(Npcs);
    Log.i("npcCommands", npcstxt);
    local file = VHD.openFile("npcs.txt", "w+");
    if not file then
        Log.e("npcCommands", "Erro ao abrir o arquivo npcs.txt para escrita.");
        return;
    end
    file:writeBinary("utf8", npcstxt);
    file:close();
end

local hexnumbers = {
    "#000000",
    "#FFFFFF",
    "#7F7FE1",
    "#7FFF7F",
    "#FF0000",
    "#FF7F7F",
    "#FF7FFF",
    "#FF7F00",
    "#FFFF00",
    "#00FF00",
    "#7FFFFF",
    "#00FFFF",
    "#0000FF",
    "#FF00FF",
    "#7F7F7F",
    "#464646",
    "#000000",
    "#000000",
    "#777777",
    "#010101",
    "#464646",
    "#000000",
    "#6699FF",
    "#F25040",
    "#D45252",
    "#D396DC",
    "#F47193",
    "#6CECB3",
    "#E54C27"
}

local function parsecolor(color)
    if type(color) == "number" then
        color = hexnumbers[color + 1] or "#FFFFFF";
    end
    return color
end


local helpMessage = [[
Comandos disponíveis:
npc help - Mostra a lista de comandos disponíveis.
npc list - Lista todos os NPCs salvos.
npc clear - Remove todos os NPCs salvos.
npc export - Exporta a lista de NPCs salvos.
npc import - Importa NPCs de um arquivo.
npc add <codigo> - Salva o NPC com o codigo especificado.
npc edit <codigo> <atributo>(opcional) - Edita o NPC com o codigo especificado. Se um atributo for fornecido, edita apenas esse atributo.
npc remove <codigo> - Remove o NPC com o codigo especificado.
npc info <codigo> - Mostra informações sobre o NPC com o codigo especificado.
<codigo_do_npc> <mensagem> - Envia uma mensagem com o NPC especificado. O NPC deve estar salvo.
]]
npcCommands.help = { command = '/npc', description = helpMessage }

local function taleMarkEdit(attribute, id, npcName)
    if attribute == "parseCharActions" or attribute == "parseCharEmDashSpeech" or attribute == "parseCharQuotedSpeech" or
        attribute == "parseCommonMarkStrongEmphasis" or attribute == "parseHeadings" or attribute == "parseHorzLines" or
        attribute == "parseInitialCaps" or attribute == "parseOutOfChar" or attribute == "parseSmileys" or
        attribute == "parseURL" or attribute == "trimTexts" then
        Dialogs.confirmYesNo(attribute,
            function(confirmed)
                if confirmed then
                    Npcs[id][npcName].talemarkOptions[attribute] = true;
                    Log.i("npcCommands", attribute .. " ativado para o NPC: " .. npcName);
                else
                    Npcs[id][npcName].talemarkOptions[attribute] = false;
                    Log.i("npcCommands", attribute .. " desativado para o NPC: " .. npcName);
                end
                npcCommands.saveNpcsToFile();
            end
        )
    else
        local promise = Dialogs.asyncSelectTalemarkColor();
        local r, color = pawait(promise);
        local options = Npcs[id][npcName].talemarkOptions[attribute] or {};
        if r then
            options.color = parsecolor(color);
            Log.i("npcCommands", attribute .. " atualizado para o NPC: " .. npcName);
        else
            Log.e("npcCommands", "Seleção de cor cancelada ou inválida.");
        end
        local promisebg = Dialogs.asyncSelectTalemarkColor();
        local r, bgcolor = pawait(promisebg);
        if r then
            options.bkgColor = parsecolor(bgcolor);
            Log.i("npcCommands", attribute .. " atualizado para o NPC: " .. npcName);
        else
            Log.e("npcCommands", "Seleção de cor cancelada ou inválida.");
        end
        Npcs[id][npcName].talemarkOptions[attribute] = options;
        npcCommands.saveNpcsToFile();
        Dialogs.chooseMultiple("Selecione os atributos que você deseja ter", { "bold", "italic", "strikeout", "underline" },
            function(selected, selectedIndexes, selectedText)
                local blockstyle = {
                    color = options.color,
                    bkgColor = options.bkgColor,
                    bold = false,
                    italic = false,
                    strikeout = false,
                    underline = false
                };
                if selected then
                    for i, v in ipairs(selectedText) do
                        blockstyle[v] = true;
                    end
                end
                Npcs[id][npcName].talemarkOptions[attribute] = blockstyle;
                npcCommands.saveNpcsToFile();
            end
        )
    end
end


local function npcEdit(npc, attribute, id, npcName)
    if attribute == 'avatar' then
        Dialogs.selectImageURL(npc.avatar, function(imageURL)
            if imageURL then
                Npcs[id][npcName].impersonation.avatar = imageURL;
                Log.i("npcCommands", "Avatar atualizado para: " .. imageURL);
                npcCommands.saveNpcsToFile();
            end
        end)
    elseif attribute == 'name' then
        Dialogs.inputQuery("NPC ADD", "Digite o nome do NPC:", npcName, function(input)
            if input and input ~= '' then
                Npcs[id][npcName].impersonation.name = input;
                npcCommands.saveNpcsToFile();
            end
            Log.i("npcCommands", "Nome atualizado para: " .. input);
        end)
    elseif attribute == 'gender' then
        Dialogs.choose("Selecione o genero do personagem", { "masculine", "feminine", "neuter" }, function(a, b, gender)
            if gender then
                Npcs[id][npcName].impersonation.gender = gender;
                npcCommands.saveNpcsToFile();
            end
            Log.i("npcCommands", "Gênero atualizado para: " .. gender);
        end);
    elseif attribute == 'talemarkOptions' then
        Dialogs.choose("Selecione o atributo talemark a ser editado", {
            "defaultTextStyle",
            "charActionTextStyle",
            "charEmDashSpeechTextStyle",
            "charQuotedSpeechTextStyle",
            "outOfCharTextStyle",
            "parseCharActions",
            "parseCharEmDashSpeech",
            "parseCharQuotedSpeech",
            "parseCommonMarkStrongEmphasis",
            "parseHeadings",
            "parseHorzLines",
            "parseInitialCaps",
            "parseOutOfChar",
            "parseSmileys",
            "parseURL",
            "trimTexts"
        }, function(a, b, opt)
            if opt then
                taleMarkEdit(opt, id, npcName);
            end
        end)
    else
        Log.e("npcCommands", "Atributo inválido: " .. attribute);
    end
end


npcCommands.handleCommand = function(command, chat, id)
    if command == nil or command == '' then
        chat:writeEx('Comando inválido. Use "npc help" para ver os comandos disponíveis.');
        return;
    end
    if command == 'help' then
        chat:writeEx(helpMessage);
        return;
    end
    if command == 'clear' then
        Npcs[id] = {};
        npcCommands.saveNpcsToFile();
        chat:writeEx('Todos os NPCs foram removidos com sucesso.');
        return;
    end
    if command == 'list' then
        local npcList = Npcs[id];
        if not npcList then
            chat:writeEx('Nenhum NPC salvo.');
            return;
        end
        local response = 'NPCs salvos:\n';
        for name, npc in pairs(npcList) do
            response = response .. '- ' .. name .. '\n';
        end
        chat:writeEx(response);
        return;
    end

    if command == 'export' then
        local npcsJson = json.encode(Npcs[id]);
        local stream = Utils.newMemoryStream();
        stream:writeBinary("utf8", npcsJson);
        stream.position = 0;
        if stream then
            Dialogs.saveFile("salvando o json dos npcs da mesa" .. chat.room.nome, stream, "npcs.json", "application/json", function()
                stream:close();
            end, function()
                stream:close();
            end)
        end
        return;
    end
    if command == 'import' then
        Dialogs.openFile("Importar NPCs", ".json", false, function(files)
            local file = files[1];
            if not file then
                chat:writeEx('Nenhum arquivo selecionado.');
                return;
            end
            local jsonData = {};
            local lidos = file.stream:read(jsonData, file.stream.size)
            if lidos > 0 then
                local result = string.char(table.unpack(jsonData));
                local success, data = pcall(json.decode, result);
                if success then
                    Npcs[id] = data;
                    npcCommands.saveNpcsToFile();
                    Log.i('NPCs carregados com sucesso.');
                else
                    Log.e('Erro ao decodificar o txt: ' .. data);
                end
            else
                Log.e('Erro ao ler o arquivo.');
            end
        end)
        return;
    end

    local type, npc, arg = command:match("^(%S+)%s+(%S+)%s*(.*)$")
    if not type or not npc then
        chat:writeEx('Formato de comando inválido. Use "npc help" para ver os comandos disponíveis.')
        return
    end
    if type == 'add' then
        if not Npcs[id] then
            Npcs[id] = {};
        end
        local npcList = Npcs[id];
        if npcList[npc] then
            chat:writeEx('NPC já existe com esse codigo.');
            return;
        end
        npcList[npc] = {};
        
        npcList[npc].impersonation = {
            mode = "character",
            avatar = "",
            name = npc,
        }
        Dialogs.inputQuery("NPC ADD", "Digite o nome do NPC:", npc, function(input)
            if input and input ~= '' then
                npcList[npc].impersonation.name = input;
            end
            Dialogs.selectImageURL("", function(imageURL)
                if imageURL then
                    npcList[npc].impersonation.avatar = imageURL;
                end
            local promise = Dialogs.asyncSelectTalemarkColor();
            local r, color = pawait(promise);
            local sub = "%[§K"
            if not string.find(input, sub) then
                npcList[npc].impersonation.name = "[§K"..color.."]" .. input;
            end
            npcList[npc].talemarkOptions = {
                defaultTextStyle = {
                color = parsecolor(color),
                bold = true,
            },
            charActionTextStyle = {
                color = parsecolor(color),
                bold = true,
            },
            charEmDashSpeechTextStyle = {
                color = parsecolor(color),
                bold = true,
            },
            charQuotedSpeechTextStyle = {
                color = parsecolor(color),
                bold = true,
            },
            outOfCharTextStyle = {
                color = parsecolor(color),
                bold = true,
            },
            parseInitialCaps = false,
            parseOutOfChar = false,
            parseSmileys = false,
        };
                Npcs[id] = npcList;
                npcCommands.saveNpcsToFile();
            end
            )
        end
        )
        chat:writeEx('NPC adicionado com sucesso.');
        return;
    end
    if type == 'remove' then
        if not Npcs[id] or not Npcs[id][npc] then
            chat:writeEx('NPC não encontrado.');
            return;
        end
        Npcs[id][npc] = nil;
        chat:writeEx('NPC removido com sucesso.');
        npcCommands.saveNpcsToFile();
        return;
    end
    if type == 'edit' then
        if not Npcs[id] or not Npcs[id][npc] then
            chat:writeEx('NPC não encontrado.');
            return;
        end
        local npcData = Npcs[id][npc];
        if arg and arg ~= '' then
            npcEdit(npcData, arg, id, npc);
        else
            Dialogs.choose("Selecione o atributo a ser editado", { "avatar", "name", "gender", "talemarkOptions" },
                function(a, b, attribute)
                    npcEdit(npcData, attribute, id, npc);
                end)
        end
    end

end

npcCommands.sendMessage = function(npc, chat, message)
    chat:asyncSendStd(message, npc)
end


return npcCommands;
