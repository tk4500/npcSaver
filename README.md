# Gerenciador de NPCs para Firecast (npc_manager)

![Firecast](https://img.shields.io/badge/Plataforma-RRPG%20Firecast-orange) 
![Linguagem](https://img.shields.io/badge/Linguagem-LUA-blue)

Este é um plugin para a plataforma **RRPG Firecast**, desenvolvido para permitir que mestres criem, gerenciem e utilizem NPCs (Personagens Não-Jogadores) para enviar mensagens no chat de forma prática e imersiva. O plugin salva os dados dos NPCs por mesa, garantindo que suas configurações persistam entre as sessões.

## Funcionalidades Principais

*   **Criação e Persistência de NPCs**: Crie NPCs com nome, avatar, gênero e configurações de texto personalizadas. Todos os NPCs são salvos automaticamente e recarregados quando a mesa é aberta.
*   **Envio de Mensagens Personalizadas**: Envie mensagens no chat se passando por qualquer um dos seus NPCs salvos com um comando simples: `/<codigo_do_npc> <mensagem>`.
*   **Edição Interativa**: Edite os atributos de um NPC (nome, avatar, gênero) através de diálogos interativos dentro do Firecast, sem precisar mexer em arquivos de texto.
*   **Customização Avançada com Talemark**: Personalize a aparência das mensagens de cada NPC, definindo cores de texto, fundo e estilos (negrito, itálico, etc.) através de um menu de edição detalhado.
*   **Gerenciamento Completo via Chat**: Adicione, remova, liste e edite seus NPCs usando comandos de chat simples e intuitivos.
*   **Importação e Exportação**: Faça backup de toda a sua lista de NPCs em um arquivo `.txt` e importe-a facilmente em outras mesas ou compartilhe com outros mestres.

## Instalação do Plugin

1.  Baixe o arquivo `output/npcSaver.rpk` deste repositório.
2.  No RRPG Firecast, vá até o menu **Plugins**.
3.  Clique em **Instalar** e selecione o arquivo `.rpk` que você acabou de baixar.
4.  O plugin será ativado automaticamente. Não há interface visual; todo o gerenciamento é feito por comandos de chat.

## Como Usar o Plugin

O controle do plugin é feito inteiramente através de comandos de chat. O comando principal é `/npc`.

### Comandos de Gerenciamento

| Comando | Descrição |
| :--- | :--- |
| `npc help` | Mostra a lista completa de comandos disponíveis. |
| `npc list` | Lista todos os NPCs salvos na mesa atual. |
| `npc add <codigo>` | Inicia o processo de criação de um novo NPC com o `<codigo>` especificado. Você será guiado por diálogos para definir nome de exibição, avatar e gênero. |
| `npc edit <codigo>` | Abre um menu para escolher qual atributo do NPC `<codigo>` você deseja editar (nome, avatar, gênero ou opções de texto). |
| `npc edit <codigo> <atributo>` | Edita diretamente um atributo específico. Atributos válidos: `name`, `avatar`, `gender`, `talemarkOptions`. |
| `npc remove <codigo>` | Remove permanentemente o NPC com o `<codigo>` especificado. |
| `npc info <codigo>` | (Em desenvolvimento) Mostra informações detalhadas sobre um NPC. |
| `npc clear` | Remove **todos** os NPCs salvos na mesa. **Use com cuidado!** |

### Enviando Mensagens como um NPC

Depois de criar um NPC, basta digitar o codigo dele como um comando de chat para enviar uma mensagem.
Atenção, o codigo do npc deve possuir apenas 3 digitos, qualquer valor diferente não será possivel de utilizar.

**Sintaxe:** `/<codigo_do_npc> <sua mensagem aqui>`

**Exemplo:**
Se você criou um NPC com o codigo `GuF` e nome `Guard Fletcher` , o comando abaixo enviará a mensagem como se fosse ele:
```
/GuF Cidadão, identifique-se!
```

### Importação e Exportação

*   **`npc export`**: Gera um arquivo `npcs.txt` com os dados de todos os seus NPCs. Uma janela de "Salvar" será aberta para que você possa guardar o backup.
*   **`npc import`**: Abre uma janela para você selecionar um arquivo `npcs.txt` para importar. Os NPCs do arquivo substituirão os existentes na mesa.

## Para Desenvolvedores

*   **`main.lua`**: Ponto de entrada do plugin. É responsável por escutar os eventos de chat (`HandleChatCommand` e `ListChatCommands`), carregar os dados dos NPCs do arquivo `npcs.txt` e direcionar os comandos para o módulo de lógica.
*   **`npcCommands.lua`**: Contém toda a lógica do plugin, incluindo a análise dos comandos, as funções de adicionar, editar, remover, listar, importar/exportar e enviar mensagens. Também gerencia os diálogos interativos (`Dialogs API`) para uma experiência de usuário mais fluida.
*   **Persistência**: Os dados de todos os NPCs são serializados e salvos no arquivo `npcs.txt`, localizado dentro do HD Virtual do plugin, garantindo que as informações não se percam.