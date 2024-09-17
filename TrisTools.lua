script_name('TrisTools')
script_author('ilklme')
script_version('1.2 beta')
require('lib.moonloader')
local sf = require('sampfuncs')
local dlstatus = require('lib.moonloader').download_status
script_properties('work-in-pause')
--[ БИБЛИОТЕКИ ] --
local Matrix3X3 = require("matrix3x3")
local dlstatus = require('moonloader').download_status
local Vector3D = require("vector3d")
local imgui = require('mimgui')
local ffi = require('ffi')
local MonetLua = require('MoonMonet')
local encoding = require "encoding"
local faicons = require('fAwesome6')
local sampev = require('lib.samp.events')
local inicfg = require('inicfg')
local memory = require('memory')
local vkeys = require('vkeys')
local hotkey = require('mimgui_hotkeys')
local d3dx9_43 = ffi.load("d3dx9_43.dll")
--[ НАСТРОЙКИ СКРИПТА ] --
function kejir()
    (""):†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()
    (""):†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()
    (""):†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()
    (""):†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()
    (""):†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()():†()
end
local downloadAccept = false
local update_state = false
local stColor = 0x1a8bdb
local windowsOpen = false
local fTimeProcessed = os.clock()
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local Font = {}

update_state = false -- Если переменная == true, значит начнётся обновление.
update_found = false -- Если будет true, будет доступна команда /update.

local script_vers = 1.0
local script_vers_text = "1.2 beta" -- Название нашей версии. В будущем будем её выводить ползователю.

local update_url = 'https://raw.githubusercontent.com/mirron4k/auto-update/main/update.ini' -- Путь к ini файлу. Позже нам понадобиться.
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = 'https://github.com/mirron4k/auto-update/raw/main/TrisTools.lua' -- Путь скрипту.
local script_path = thisScript().path

function check_update() -- Создаём функцию которая будет проверять наличие обновлений при запуске скрипта.
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then -- Сверяем версию в скрипте и в ini файле на github
                sampAddChatMessage("{FFFFFF}Имеется {32CD32}новая {FFFFFF}версия скрипта. Версия: {32CD32}"..updateIni.info.vers_text..". {FFFFFF}/update что-бы обновить", 0xFF0000) -- Сообщаем о новой версии.
                update_found = true -- если обновление найдено, ставим переменной значение true
            end
            os.remove(update_path)
        end
    end)
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    check_update()

    if update_found then -- Если найдено обновление, регистрируем команду /update.
        sampRegisterChatCommand('update', function()
            update_state = true
        end)
    else
        sampAddChatMessage('{FFFFFF}Нету доступных обновлений!')
    end

    while true do
        wait(0)
  
        if update_state then -- Если человек напишет /update и обновлени есть, начнётся скаачивание скрипта.
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("{FFFFFF}Скрипт {32CD32}успешно {FFFFFF}обновлён.", 0xFF0000)
                end
            end)
            break
        end
  
    end 
end

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..' ' or '')..'%H:%M:%S', time + timezone_offset)
end

local font = renderCreateFont("Arial", 10, FCR_BOLD + FCR_BORDER)
local wr_font_name = "Arial"
local wr_font_size = 10
local wr_font = {
	renderCreateFont(wr_font_name, wr_font_size, 5)
}
local RadarPlayerPopup = { id = 'none', name = 'none', lvl = 'none', ping = 'none' }
encoding.default = 'CP1251'
u8 = encoding.UTF8
local CCamera = 0xB6F028
local cursor = false
local bullets = {}
local spawnProcess = false
local LiteTools_Commands = {
    {cmd=('/amenu'), desc=u8'Открыть меню скрипта'},
    {cmd=('/ot'), desc=u8'Открыть Авто-Репорт'},
    {cmd=('/aconsole'), desc=u8('Открыть Админ-Консоль')},
    {cmd=('/copynick'), desc=u8('Скопировать ник игрока')},
    {cmd=('/ainvis'), desc=u8('Уйти в режим невидимки')},
    {cmd=('/az'), desc=u8('Телепорт в админ-зону. Используйте /az [id], чтобы телепортировать игрока.')},
    {cmd=('/target'), desc=u8('Поставить таргет на игрока. Нужен для биндера.')},
    {cmd=('/ltaz'), desc=u8('Телепорт в LiteTools-Зону')},
    {cmd=('/spawncars'), desc=u8("Заспавнить авто")},
    {cmd=('{ff0000}!{ffffff} /avig'), desc=u8('Выдать а-выговор администратору по ID/Нику.')},
    {cmd=('{ff0000}!{ffffff} /aunvig'), desc=u8('Снять а-выговор администратору по ID/Нику.')},
    {cmd=('{ff0000}!{ffffff} /makeadmin'), desc=u8('Выдать админку по ID/Нику.')}
}


local forma = {
    active = false,
    stop = false,
    etrue = false,
    efalse = false
}

local define = {
    check = false,
    list = {}
}

local fulldostup = {
    user = new.char[128](""),
    commands = {
        var = {
            '/gzcolor',
            '/ghetto',
            '/makeleader',
            '/offleader',
            '/makeadmin',
            '/avig',
            '/aunvig',
            '/banip',
            '/makehelper',
            '/offhelper'
        },
        id = 0,
        uuid = new.int(0)
    },
    online = {
        var = {
            u8"В сети",
            u8"Не в сети"
        },
        id = 0,
        uuid = new.int(0)
    }
}
fulldostup.commands.id = imgui.new['const char*'][#fulldostup.commands.var](fulldostup.commands.var) 
fulldostup.online.id = imgui.new['const char*'][#fulldostup.online.var](fulldostup.online.var)


local setstat = {
    user = new.char[128](""),
    value = new.char[128](""),
    types = {
        var = {
            [u8'Уровень'] = 1,
            [u8'Законопослушность'] = 2,
            [u8'Материалы'] = 3,
            [u8'Убийства'] = 5,
            [u8'Номер Телефона'] = 6,
            [u8'EXP'] = 7,
            [u8'Номер Бизнеса'] = 8,
            [u8'VIP [1-3]'] = 9,
            [u8'Работа игрока'] = 11,
            [u8'Деньги в Банке'] = 13,
            [u8'Баланс Мобильного'] = 14,
            [u8'Деньги'] = 15,
            [u8'Аптечки'] = 17,
            [u8'Член Организации'] = 18, 
            [u8'Навык Бокса'] = 19,
            [u8'Время Бокса'] = 20,
            [u8'Стиль Box'] = 21,
            [u8'Стиль Kong-Fu'] = 22, 
            [u8'Стиль KickBox'] = 23,
            [u8'Уважение'] = 24, 
            [u8'Бег'] = 25,
            [u8'Машина 1 слот'] = 26,
            [u8'Машина 2 слот'] = 27,
            [u8'Машина 3 слот'] = 28,
            [u8'Машина 4 слот'] = 29,
            [u8'Машина 5 слот'] = 30,
            [u8'Наркозависимость'] = 31,
            [u8'Фрак.скин'] = 32,
            [u8'В браке с'] = 33,
            [u8'Процы'] = 34,
            [u8'Время банка'] = 35,
            [u8'Доступ /ban'] = 36,
            [u8'Доступ /warn'] = 37
        },
        pr_var = {
            u8'Уровень',
            u8'Законопослушность',
            u8'Материалы',
            u8'Убийства',
            u8'Номер Телефона',
            u8'EXP',
            u8'Номер Бизнеса',
            u8'VIP [1-3]',
            u8'Работа игрока',
            u8'Деньги в Банке',
            u8'Баланс Мобильного',
            u8'Деньги',
            u8'Аптечки',
            u8'Член Организации', 
            u8'Навык Бокса',
            u8'Время Бокса',
            u8'Стиль Box',
            u8'Стиль Kong-Fu', 
            u8'Стиль KickBox',
            u8'Уважение', 
            u8'Бег',
            u8'Машина 1 слот',
            u8'Машина 2 слот',
            u8'Машина 3 слот',
            u8'Машина 4 слот',
            u8'Машина 5 слот',
            u8'Наркозависимость',
            u8'Фрак.скин',
            u8'В браке с',
            u8'Процы',
            u8'Время банка',
            u8'Доступ /ban',
            u8'Доступ /warn'
        },
        id = 0,
        uuid = new.int(0)
    }
}
setstat.types.id = imgui.new['const char*'][#setstat.types.pr_var](setstat.types.pr_var)


local windowDrawList = new.bool(true)
local veh = {
    action = false,
    time = os.time(),
    car = '',
    id = 0,
    c1 = 0,
    c2 = 0,
    act = false
}
if not doesDirectoryExist(getWorkingDirectory() .. '\\TrisTools') then createDirectory(getWorkingDirectory() .. '\\TrisTools') end
if not doesDirectoryExist(getGameDirectory()..'\\moonloader\\config') then createDirectory(getGameDirectory()..'\\moonloader\\config') end
if not doesDirectoryExist(getWorkingDirectory()..'\\TrisTools\\Fonts') then createDirectory(getWorkingDirectory()..'\\TrisTools\\Fonts') end


local cjson = { } do
    cjson.read = function(filename)
        local f = io.open(getWorkingDirectory() .. "\\TrisTools\\"..filename, 'r')
        local table = decodeJson(f:read('*a'))
        f:close()
        return table
    end
    cjson.write = function(table, filename)
        local file = io.open(getWorkingDirectory() .. "\\TrisTools\\"..filename, 'w')
        file:write(encodeJson(table))
        file:close()
    end
    cjson.load = function(table,filename)
        if not doesFileExist(getWorkingDirectory() .. "\\TrisTools\\"..filename) then
            cjson.write(table, filename)
            return table
        else
            return cjson.read(filename)
        end
    end
end

local jcfg = cjson.load({
    active = true,
    colors = {0.393, 0.668, 0.787, 1}
}, "settings.json")

function config()
    local con = {}

    function con:get_default_table()
        local config_data = {
            default = {
                version = 100, -- будет пополняться с сотым, это бета
                settings = {
                    enabled_bullets_in_screen = true,
                },
                my_bullets = {
                    draw = true,
                    draw_polygon = true,
                    thickness = 1.4,
                    timer = 3,
                    step_alpha = 0.01,
                    circle_radius = 4,
                    degree_polygon = 15,
                    transition = 0.2,
                    col_vec4 = {
                        -----     Red  Gre  Blu  Alp
                        stats = { 0.8, 0.8, 0.8, 0.7 }, -- statis.object
                        ped   = { 1.0, 0.4, 0.4, 0.7 }, -- ped
                        car   = { 0.8, 0.8, 0.0, 0.7 }, -- car
                        dynam = { 0.0, 0.8, 0.8, 0.7 }, -- dynam.object?
                    }
                },
                other_bullets = {
                    draw = true,
                    draw_polygon = true,
                    thickness = 1.4,
                    timer = 3,
                    step_alpha = 0.01,
                    circle_radius = 4,
                    degree_polygon = 15,
                    transition = 0.2,
                    col_vec4 = {
                        stats = { 0.8, 0.8, 0.8, 0.7 },
                        ped =   { 1.0, 0.4, 0.4, 0.7 },
                        car =   { 0.8, 0.8, 0.0, 0.7 },
                        dynam = { 0.0, 0.8, 0.8, 0.7 },
                    }
                },
            },
            folderpath_config = getWorkingDirectory()..'\\config',
            filepath_json = getWorkingDirectory()..'\\config\\SpainBulletTracers.json'
        }
        return config_data
    end

    function con:check()
        local def = config():get_default_table()
        if not doesDirectoryExist(def.folderpath_config) then createDirectory(def.folderpath_config) end
        if doesFileExist(def.filepath_json) then
            local file = io.open(def.filepath_json, "r+")
            local json_string = file:read("*a")
            file:close()
            local config_json = decodeJson(json_string)

            if config_json.version ~= def.default.version then
                config_json.version = def.default.version
                config_json = config():update(config_json, def.default)
                config():save(config_json)
            end
        else
            local file = io.open(def.filepath_json, "w")
            file:write(encodeJson(def.default))
            file:flush()
            file:close()
        end
    end

    function con:load()
        local file = io.open(config():get_default_table().filepath_json, "r+")
        local json_string = file:read("*a")
        file:close()
        return decodeJson(json_string)
    end

    function con:save(tabl)
        local file = io.open(config():get_default_table().filepath_json, "w")
        file:write(encodeJson(tabl))
        file:flush()
        file:close()
    end

    function con:update(config, default) --! ресурсивная функа
        local function compareTables(t1, t2)
            for key, value in pairs(t1) do
                if type(value) == "table" then
                    if not compareTables(t1[key], t2[key]) then
                        return false
                    end
                elseif type(t2[key]) == nil or type(t1[key]) ~= type(t2[key]) or t1[key] ~= t2[key] then
                    return false
                end
            end
            return true
        end

        -- Добавить, если ключ default в config не создан
        for key, value in pairs(default) do
            if config[key] == nil then
                config[key] = value
            elseif type(value) == "table" then
                if type(config[key]) == "table" then
                    config[key] = config():update(config[key], value)
                end
            end
        end

        -- Удалить, если ключ config в default не существует
        for key, value in pairs(config) do
            if default[key] == nil then
                config[key] = nil
            elseif type(value) == "table" then
                if type(default[key]) == "table" then
                    config[key] = config():update(config[key], default[key])
                end
            end
        end

        -- Проверить, если есть ключ и типы одинаковые, то не изменить
        for key, value in pairs(config) do
            if default[key] ~= nil and type(value) ~= "table" and type(value) == type(default[key]) and value == default[key] then
                config[key] = value
            end
        end

        return config
    end

    function con:convert_to_imgui(config)
        local ig = {}
        ig.version = new.int(config.version)
        ig.settings = {
            enabled_bullets_in_screen = new.bool(config.settings.enabled_bullets_in_screen),
        }
        ig.my_bullets = {
            draw = new.bool(config.my_bullets.draw),
            draw_polygon = new.bool(config.my_bullets.draw_polygon),
            thickness = new.float(config.my_bullets.thickness),
            timer = new.float(config.my_bullets.timer),
            step_alpha = new.float(config.my_bullets.step_alpha),
            circle_radius = new.float(config.my_bullets.circle_radius),
            degree_polygon = new.int(config.my_bullets.degree_polygon),
            transition = new.float(config.my_bullets.transition),
            col_vec4 = {
                stats = new.float[4](config.my_bullets.col_vec4.stats),
                ped = new.float[4](config.my_bullets.col_vec4.ped),
                car = new.float[4](config.my_bullets.col_vec4.car),
                dynam = new.float[4](config.my_bullets.col_vec4.dynam),
            }
        }
        ig.other_bullets = {
            draw = new.bool(config.other_bullets.draw),
            draw_polygon = new.bool(config.other_bullets.draw_polygon),
            thickness = new.float(config.other_bullets.thickness),
            timer = new.float(config.other_bullets.timer),
            step_alpha = new.float(config.other_bullets.step_alpha),
            circle_radius = new.float(config.other_bullets.circle_radius),
            degree_polygon = new.int(config.other_bullets.degree_polygon),
            transition = new.float(config.other_bullets.transition),
            col_vec4 = {
                stats = new.float[4](config.other_bullets.col_vec4.stats),
                ped = new.float[4](config.other_bullets.col_vec4.ped),
                car = new.float[4](config.other_bullets.col_vec4.car),
                dynam = new.float[4](config.other_bullets.col_vec4.dynam),
            }
        }
        return ig
    end

    function con:convert_to_table(ig)
        local config = {}
        config.version = ig.version[0]
        config.settings = {
            enabled_bullets_in_screen = ig.settings.enabled_bullets_in_screen[0],
        }
        config.my_bullets = {
            draw = ig.my_bullets.draw[0],
            thickness = ig.my_bullets.thickness[0],
            timer = ig.my_bullets.timer[0],
            step_alpha = ig.my_bullets.step_alpha[0],
            circle_radius = ig.my_bullets.circle_radius[0],
            degree_polygon = ig.my_bullets.degree_polygon[0],
            draw_polygon = ig.my_bullets.draw_polygon[0],
            transition = ig.my_bullets.transition[0],
            col_vec4 = {
                stats = { ig.my_bullets.col_vec4.stats[0], ig.my_bullets.col_vec4.stats[1], ig.my_bullets.col_vec4.stats[2], ig.my_bullets.col_vec4.stats[3] },
                ped =   { ig.my_bullets.col_vec4.ped[0],   ig.my_bullets.col_vec4.ped[1],   ig.my_bullets.col_vec4.ped[2],   ig.my_bullets.col_vec4.ped[3]   },
                car =   { ig.my_bullets.col_vec4.car[0],   ig.my_bullets.col_vec4.car[1],   ig.my_bullets.col_vec4.car[2],   ig.my_bullets.col_vec4.car[3]   },
                dynam = { ig.my_bullets.col_vec4.dynam[0], ig.my_bullets.col_vec4.dynam[1], ig.my_bullets.col_vec4.dynam[2], ig.my_bullets.col_vec4.dynam[3] },
            }
        }
        config.other_bullets = {
            draw = ig.other_bullets.draw[0],
            thickness = ig.other_bullets.thickness[0],
            timer = ig.other_bullets.timer[0],
            step_alpha = ig.other_bullets.step_alpha[0],
            circle_radius = ig.other_bullets.circle_radius[0],
            degree_polygon = ig.other_bullets.degree_polygon[0],
            draw_polygon = ig.other_bullets.draw_polygon[0],
            transition = ig.other_bullets.transition[0],
            col_vec4 = {
                stats = { ig.other_bullets.col_vec4.stats[0], ig.other_bullets.col_vec4.stats[1], ig.other_bullets.col_vec4.stats[2], ig.other_bullets.col_vec4.stats[3] },
                ped =   { ig.other_bullets.col_vec4.ped[0],   ig.other_bullets.col_vec4.ped[1],   ig.other_bullets.col_vec4.ped[2],   ig.other_bullets.col_vec4.ped[3]   },
                car =   { ig.other_bullets.col_vec4.car[0],   ig.other_bullets.col_vec4.car[1],   ig.other_bullets.col_vec4.car[2],   ig.other_bullets.col_vec4.car[3]   },
                dynam = { ig.other_bullets.col_vec4.dynam[0], ig.other_bullets.col_vec4.dynam[1], ig.other_bullets.col_vec4.dynam[2], ig.other_bullets.col_vec4.dynam[3] },
            }
        }
        return config
    end

    return con
end

config():check()
local config_table = config():load()
local config_imgui = config():convert_to_imgui(config_table)



local aconsole = {
    log = {},
    commands = {
        ['/help'] = 'Commands list:\n/reload - Reloading the script\n/jp - Issue JetPack\n/relax - The character relaxed\n/kill - The character will die\n/fuck - The character will become a tractor driver'
    },
    func = {
        ['/jp'] = function()    taskJetpack(PLAYER_PED) end,
        ['/relax'] = function()   taskScratchHead(PLAYER_PED) end,
        ['/fuck'] = function()   console():fuck()  end,
        ['/kill'] = function()  taskDie(PLAYER_PED) end,
        ['/reload'] = function()    thisScript():reload()   end
    },
    newMessage = false,
    fuck = false
}




function console()
    local f = {}
    function f:fuck()
        aconsole.fuck = not aconsole.fuck 
        if aconsole.fuck then
            console():message('Enter the command again to stop the process.', 0)
        else
            clearCharTasksImmediately(PLAYER_PED)
        end
    end
    function f:getConsole()
        return aconsole.log
    end
    function f:message(text, role)
        if role == 0 then
            table.insert(aconsole.log, u8('LT: '..text))
            
        else
            table.insert(aconsole.log, u8('>> '..text))
            
        end 
    end
    function f:command(cmd)
        if console():find_command(cmd) then
            console():message(aconsole.commands[cmd], 0)
        elseif console():find_function(cmd) then
            for k,v in pairs(aconsole.func) do
                if k == cmd then
                    v()
                    console():message('The command is executed.', 0)
                end
            end
        else
            console():message('Unknown command. Try /help.', 0)
        end
    end
    function f:find_function(cmd)
        for k,v in pairs(aconsole.func) do
            if k == cmd then
                return true
            end
        end
        return false
    end
    function f:find_command(cmd)
        for k,v in pairs(aconsole.commands) do
            if k == cmd then
                return true
            end
        end
        return false
    end
    return f
end

local cursor = false
ffi.cdef [[
    typedef int BOOL;
    typedef unsigned long HANDLE;
    typedef HANDLE HWND;
    typedef int bInvert;
 
    HWND GetActiveWindow(void);

    BOOL FlashWindow(HWND hWnd, BOOL bInvert);
]]

local IDcars = {
    [400] = 'Landstalker',
    [401] = 'Bravura',
    [402] = 'Buffalo',
    [403] = 'Linerunner',
    [404] = 'Perenniel',
    [405] = 'Sentinel',
    [406] = 'Dumper',
    [407] = 'Firetruck',
    [408] = 'Trashmaster',
    [409] = 'Stretch',
    [410] = 'Manana',
    [411] = 'Infernus',
    [412] = 'Voodoo',
    [413] = 'Pony',
    [414] = 'Mule',
    [415] = 'Cheetah',
    [416] = 'Ambulance',
    [417] = 'Leviathan',
    [418] = 'Moonbeam',
    [419] = 'Esperanto',
    [420] = 'Taxi',
    [421] = 'Washington',
    [422] = 'Bobcat',
    [423] = 'Mr Whoopee',
    [424] = 'BF Injection',
    [425] = 'Hunter',
    [426] = 'Premier',
    [427] = 'Enforcer',
    [428] = 'Securicar',
    [429] = 'Banshee',
    [430] = 'Predator',
    [431] = 'Bus',
    [432] = 'Rhino',
    [433] = 'Barracks',
    [434] = 'Hotknife',
    [435] = 'Article Trailer',
    [436] = 'Previon',
    [437] = 'Coach',
    [438] = 'Cabbie',
    [439] = 'Stallion',
    [440] = 'Rumpo',
    [441] = 'RC Bandit',
    [442] = 'Romero',
    [443] = 'Packer',
    [444] = 'Monster',
    [445] = 'Admiral',
    [446] = 'Squallo',
    [447] = 'Seasparrow',
    [448] = 'Pizzaboy',
    [449] = 'Tram',
    [450] = 'Article Trailer 2',
    [451] = 'Turismo',
    [452] = 'Speeder',
    [453] = 'Reefer',
    [454] = 'Tropic',
    [455] = 'Flatbed',
    [456] = 'Yankee',
    [457] = 'Caddy',
    [458] = 'Solair',
    [459] = 'Berkley\'s RC',
    [460] = 'Skimmer',
    [461] = 'PCJ-600',
    [462] = 'Faggio',
    [463] = 'Freeway',
    [464] = 'RC Baron',
    [465] = 'RC Raider',
    [466] = 'Glendale',
    [467] = 'Oceanic',
    [468] = 'Sanchez',
    [469] = 'Sparrow',
    [470] = 'Patriot',
    [471] = 'Quad',
    [472] = 'Coastguard',
    [473] = 'Dinghy',
    [474] = 'Hermes',
    [475] = 'Sabre',
    [476] = 'Rustler',
    [477] = 'ZR-350',
    [478] = 'Walton',
    [479] = 'Regina',
    [480] = 'Comet',
    [481] = 'BMX',
    [482] = 'Burrito',
    [483] = 'Camper',
    [484] = 'Marquis',
    [485] = 'Baggage',
    [486] = 'Dozer',
    [487] = 'Maverick',
    [488] = 'SAN News Maverick',
    [489] = 'Rancher',
    [490] = 'FBI Rancher',
    [491] = 'Virgo',
    [492] = 'Greenwood',
    [493] = 'Jetmax',
    [494] = 'Hotring Racer',
    [495] = 'Sandking',
    [496] = 'Blista Compact',
    [497] = 'Police Maverick',
    [498] = 'Boxville',
    [499] = 'Benson',
    [500] = 'Mesa',
    [501] = 'RC Goblin',
    [502] = 'Hotring Racer A',
    [503] = 'Hotring Racer B',
    [504] = 'Bloodring Banger',
    [505] = 'Rancher',
    [506] = 'Super GT',
    [507] = 'Elegant',
    [508] = 'Journey',
    [509] = 'Bike',
    [510] = 'Mountain Bike',
    [511] = 'Beagle',
    [512] = 'Cropduster',
    [513] = 'Stuntplane',
    [514] = 'Tanker',
    [515] = 'Roadtrain',
    [516] = 'Nebula',
    [517] = 'Majestic',
    [518] = 'Buccaneer',
    [519] = 'Shamal',
    [520] = 'Hydra',
    [521] = 'FCR-900',
    [522] = 'NRG-500',
    [523] = 'HPV1000',
    [524] = 'Cement Truck',
    [525] = 'Towtruck',
    [526] = 'Fortune',
    [527] = 'Cadrona',
    [528] = 'FBI Truck',
    [529] = 'Willard',
    [530] = 'Forklift',
    [531] = 'Tractor',
    [532] = 'Combine Harvester',
    [533] = 'Feltzer',
    [534] = 'Remington',
    [535] = 'Slamvan',
    [536] = 'Blade',
    [537] = 'Freight (Train)',
    [538] = 'Brownstreak (Train)',
    [539] = 'Vortex',
    [540] = 'Vincent',
    [541] = 'Bullet',
    [542] = 'Clover',
    [543] = 'Sadler',
    [544] = 'Firetruck LA',
    [545] = 'Hustler',
    [546] = 'Intruder',
    [547] = 'Primo',
    [548] = 'Cargobob',
    [549] = 'Tampa',
    [550] = 'Sunrise',
    [551] = 'Merit',
    [552] = 'Utility Van',
    [553] = 'Nevada',
    [554] = 'Yosemite',
    [555] = 'Windsor',
    [556] = 'Monster A',
    [557] = 'Monster B',
    [558] = 'Uranus',
    [559] = 'Jester',
    [560] = 'Sultan',
    [561] = 'Stratum',
    [562] = 'Elegy',
    [563] = 'Raindance',
    [564] = 'RC Tiger',
    [565] = 'Flash',
    [566] = 'Tahoma',
    [567] = 'Savanna',
    [568] = 'Bandito',
    [569] = 'Freight Flat Trailer',
    [570] = 'Streak Trailer',
    [571] = 'Kart',
    [572] = 'Mower',
    [573] = 'Dune',
    [574] = 'Sweeper',
    [575] = 'Broadway',
    [576] = 'Tornado',
    [577] = 'AT400',
    [578] = 'DFT-30',
    [579] = 'Huntley',
    [580] = 'Stafford',
    [581] = 'BF-400',
    [582] = 'Newsvan',
    [583] = 'Tug',
    [584] = 'Petrol Trailer',
    [585] = 'Emperor',
    [586] = 'Wayfarer',
    [587] = 'Euros',
    [588] = 'Hotdog',
    [589] = 'Club',
    [590] = 'Freight Box Trailer',
    [591] = 'Article Trailer 3',
    [592] = 'Andromada',
    [593] = 'Dodo',
    [594] = 'RC Cam',
    [595] = 'Launch',
    [596] = 'Police Car (LSPD)',
    [597] = 'Police Car (SFPD)',
    [598] = 'Police Car (LVPD)',
    [599] = 'Police Ranger',
    [600] = 'Picador',
    [601] = 'S.W.A.T.',
    [602] = 'Alpha',
    [603] = 'Phoenix',
    [604] = 'Glendale Shit',
    [605] = 'Sadler Shit',
    [606] = 'Baggage Trailer A',
    [607] = 'Baggage Trailer B',
    [608] = 'Tug Stairs Trailer',
    [609] = 'Boxville',
    [610] = 'Farm Trailer',
    [611] = 'Utility Trailer'
}
local sessionOnline = new.int(0)
local sessionAfk = new.int(0)
local sessionFull = new.int(0)
local sessionForms = 0
local sessionReports = 0


do
    local bit = require 'bit'

    function join_argb(a, r, g, b)
        local argb = b  -- b
        argb = bit.bor(argb, bit.lshift(g, 8))  -- g
        argb = bit.bor(argb, bit.lshift(r, 16)) -- r
        argb = bit.bor(argb, bit.lshift(a, 24)) -- a
        return argb
    end

    function explode_argb(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end


    local function ARGBtoRGB(color) return bit.band(color, 0xFFFFFF) end

    function ColorAccentsAdapter(color)
        local a, r, g, b = explode_argb(color)
        local ret = {a = a, r = r, g = g, b = b}
        function ret:apply_alpha(alpha) self.a = alpha return self end
        function ret:as_u32() return join_argb(self.a, self.b, self.g, self.r) end
        function ret:as_vec4() return imgui.ImVec4(self.r / 255, self.g / 255, self.b / 255, self.a / 255) end
        function ret:as_vec4_table() return {self.r / 255, self.g / 255, self.b / 255, self.a / 255} end
        function ret:as_argb() return join_argb(self.a, self.r, self.g, self.b) end
        function ret:as_rgba() return join_argb(self.r, self.g, self.b, self.a) end
        function ret:as_chat() return string.format("%06X", ARGBtoRGB(join_argb(self.a, self.r, self.g, self.b))) end
        function ret:argb_to_rgb() return ARGBtoRGB(join_argb(self.a, self.r, self.g, self.b)) end
        return ret
    end

    
end
-- [[ RADARHACK ]] -- 
do
    ffi.cdef('struct CVector2D {float x, y;}')
    local CRadar_TransformRealWorldPointToRadarSpace = ffi.cast('void (__cdecl*)(struct CVector2D*, struct CVector2D*)', 0x583530)
    local CRadar_TransformRadarPointToScreenSpace = ffi.cast('void (__cdecl*)(struct CVector2D*, struct CVector2D*)', 0x583480)
    local CRadar_IsPointInsideRadar = ffi.cast('bool (__cdecl*)(struct CVector2D*)', 0x584D40)

    function TransformRealWorldPointToRadarSpace(x, y)
        local RetVal = ffi.new('struct CVector2D', {0, 0})
        CRadar_TransformRealWorldPointToRadarSpace(RetVal, ffi.new('struct CVector2D', {x, y}))
        return RetVal.x, RetVal.y
    end

    function TransformRadarPointToScreenSpace(x, y)
        local RetVal = ffi.new('struct CVector2D', {0, 0})
        CRadar_TransformRadarPointToScreenSpace(RetVal, ffi.new('struct CVector2D', {x, y}))
        return RetVal.x, RetVal.y
    end

    function IsPointInsideRadar(x, y)
        return CRadar_IsPointInsideRadar(ffi.new('struct CVector2D', {x, y}))
    end
end
local fastHelp = {
    mode = 1,
    activeSpawn = false,
    activeLock = false,
    pos = {}
}
local cur_time = os.time()
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local iniFile = 'SpainSettings.ini'

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
local spectate = {
    position = {},
    process_teleport = false,
    count = 0,
    command = ''
}
local LOAD_IMAGES = {
    VEHICLES = {}
}

if not doesFileExist(getWorkingDirectory() .. '\\TrisTools\\RulesAdmins.json') then 
    local List = {
        ['JAIL'] = {
            ['DM'] = 15,
            ['DB'] = 15,
            ['SK'] = 15,
            ['TK'] = 15,
            ['PG'] = 10,
            ['NonRP'] = 15,
            ['Багоюз'] = 30,
            ['Стрельба с пассажирки'] = 10,
            ['Cop In Ghetto'] = 10,
            ['Масс. DM'] = 30,
            ['Нет опры на розыск'] = 20,
            ['Обычные читы'] = 30,
            ['Читы во фракции'] = 30,
            ["Помеха РП"] = 10
        }, 
        ['MUTE'] = {
            ['Флуд'] = 10,
            ['Оск.Игроков'] = 15,
            ['Оск.Администрации'] = 30,
            ['Упоминание родных'] = 30,
            ['Оск.Родных'] = 60,
            ['Бред (/d)'] = 10
        },
        ['RMUTE'] = {
            ['Флуд'] = 10,
            ['Оск.Игроков'] = 15,
            ['Оск.Администрации'] = 30,
            ['Упоминание родных'] = 30,
            ['Оск.Родных'] = 60,
            ['Бред (/d)'] = 10
        },
        ['WARN'] = {
            ['OFF от ареста'] = 1,
            ['Отказ от проверки'] = 1,
            ['Читы на проверке'] = 1
        },
        ['BAN'] = {
            ['Читы в ДМГ'] = 3,
            ['Реклама'] = 999,
            ['Неадекват. Опис. Персонажа'] = 2
        }
    }
    local file = io.open(getWorkingDirectory() .. '\\TrisTools\\RulesAdmins.json', "w")
    file:write(encodeJson(List))
    file:flush()
    file:close()
end
function rules()
    local f = {}
    function f:read()
        local f = io.open(getWorkingDirectory() .. '\\TrisTools\\RulesAdmins.json', 'r')
        local table = decodeJson(f:read('*a'))
        f:close()
        return table
    end

    function f:write(table)
        local file = io.open(getWorkingDirectory() .. '\\TrisTools\\RulesAdmins.json', 'w')
        file:write(encodeJson(table))
        file:close()
    end
    return f
end

function json()
    local f = {}
    function f:read(filename)
        local f = io.open(filename, 'r')
        if f then
            local table = decodeJson(f:read('*a'))
            f:close()
            return table
        else
            return -1
        end
    end
    function f:write(table, filename)
        local file = io.open(filename, 'w')
        file:write(encodeJson(table))
        file:close()
    end
    return f
end


local checkerList = {}
local checkerInputs = {
    nicks = {},
    name = {},
    action = {},
    font = {},
    fontsize = {},
    fontflags = {},
    fontname = {},
    IsDistance = {},
    color = {},
    unicalName = {},
    unicalNameBool = {}
}
local changePosition = {
    bubble = false,
    reconInfoPunish = false,
    reconInfoStats = false,
    reconInfoNakaz = false,
    reconInfoLogger = false,
    playerStats = false,
    renderAdmins = false,
    renderLogger = false
}
local binderCfg = {
    list = {},
    active = {},
    text = {},
    name = {},
    key = {},
    command = {},
    func = {},
    wait = {},
    activeFrame = {}
}







function checker()
    local f = {}
    local name = getWorkingDirectory() .. '\\TrisTools\\playersChecker.json'
    function f:getValidationNick(table,nick)
        local ptable = json():read(name)
        for k,v in pairs(ptable[table]) do
            if v == nick then
                return true
            end
        end
        return false
    end
    function f:exist()
        if not doesFileExist(name) then
            local List = {
                ['1'] = {"Juggernaut_Classic"},
                ['Settings'] = {
                    ['1'] = {
                        ['name'] = 'Чекер 1',
                        ['action'] = false,
                        ['style'] = {
                            ['font'] = 'Segoe UI',
                            ['fontsize'] = 10,
                            ['fontflags'] = 13
                        },
                        ['IsDistance'] = {["Juggernaut_Classic"] = true},
                        ['color'] = {["Juggernaut_Classic"] = true},
                        ['unicalName'] = {["Juggernaut_Classic"] = 'Бог'},
                        ['unicalNameBool'] = {["Juggernaut_Classic"] = true},
                        ['pos'] = {
                            ['x'] = 1000,
                            ['y'] = 800
                        },
                    },
                }
            }
            json():write(List, name)
        end
    end
    
    function f:deleteTable(table)
        local ptable = json():read(name)
        ptable[table] = nil
        ptable['Settings'][table] = nil
        json():write(ptable,name)
        checker():update()
    end
    function f:getList()
        local table = json():read(name)
        for k,v in pairs(table) do
            if k ~= 'Settings' then
                checkerInputs.name[k] = new.char[128](u8(table['Settings'][k]['name']))
                checkerInputs.nicks[k] = new.char[256]('')
                checkerInputs.action[k] = new.bool(table['Settings'][k]['action'])
                checkerInputs.font[k] = renderCreateFont(table['Settings'][k]['style']['font'], table['Settings'][k]['style']['fontsize'], table['Settings'][k]['style']['fontflags'])
                checkerInputs.fontsize[k] = new.int(table['Settings'][k]['style']['fontsize'])
                checkerInputs.fontflags[k] = new.int(table['Settings'][k]['style']['fontflags'])
                checkerInputs.fontname[k] = new.char[256](table['Settings'][k]['style']['font'])
                checkerInputs.IsDistance[k] = {}
                checkerInputs.color[k] = {}
                checkerInputs.unicalName[k] = {}
                checkerInputs.unicalNameBool[k] = {}
                changePosition[k] = false 
                for _,r in pairs(table['Settings'][k]['IsDistance']) do
                    checkerInputs.IsDistance[k][_] = new.bool(r)
                end
                for _,r in pairs(table['Settings'][k]['color']) do
                    checkerInputs.color[k][_] = new.bool(r)
                end
                for _,r in pairs(table['Settings'][k]['unicalName']) do
                    checkerInputs.unicalName[k][_] = new.char[256](u8(r))
                end
                for _,r in pairs(table['Settings'][k]['unicalNameBool']) do
                    checkerInputs.unicalNameBool[k][_] = new.bool(r)
                end
            end
            
        end
        return table
    end
    function f:updateExcept(except, delete, stnew)
        local table = json():read(name)
        local delete = delete or 0
        local stnew = stnew or 0
        if delete == 1 then 
            checkerList = table
        else
            for k,v in pairs(table) do
                if k == except then
                    checkerInputs.name[k] = new.char[128](u8(table['Settings'][k]['name']))
                    checkerInputs.nicks[k] = new.char[256]('')
                    checkerInputs.action[k] = new.bool(table['Settings'][k]['action'])
                    checkerInputs.font[k] = renderCreateFont(table['Settings'][k]['style']['font'], table['Settings'][k]['style']['fontsize'], table['Settings'][k]['style']['fontflags'])
                    checkerInputs.fontsize[k] = new.int(table['Settings'][k]['style']['fontsize'])
                    checkerInputs.fontflags[k] = new.int(table['Settings'][k]['style']['fontflags'])
                    checkerInputs.fontname[k] = new.char[256](table['Settings'][k]['style']['font'])
                    checkerInputs.IsDistance[k] = {}
                    checkerInputs.color[k] = {}
                    changePosition[k] = false
                    checkerList = table
                    checkerInputs.unicalName[k] = {}
                    checkerInputs.unicalNameBool[k] = {}
                    changePosition[k] = false
                    for _,r in pairs(table['Settings'][k]['IsDistance']) do
                        checkerInputs.IsDistance[k][_] = new.bool(r)
                    end
                    for _,r in pairs(table['Settings'][k]['color']) do
                        checkerInputs.color[k][_] = new.bool(r)
                    end
                    for _,r in pairs(table['Settings'][k]['unicalName']) do
                        checkerInputs.unicalName[k][_] = new.char[256](u8(r))
                    end
                    for _,r in pairs(table['Settings'][k]['unicalNameBool']) do
                        checkerInputs.unicalNameBool[k][_] = new.bool(r)
                    end
                end 
                
            end
            
        end
    end
    function f:newTable(count)
        count = tostring(count)
        local table = json():read(name)
        table[count] = {}
        table['Settings'][count] = {
            ['name'] = 'Чекер '..count,
            ['action'] = false,
            ['style'] = {
                ['font'] = 'Segoe UI',
                ['fontsize'] = 10,
                ['fontflags'] = 13
            },
            ['IsDistance'] = {},
            ['color'] = {},
            ['unicalName'] = {},
            ['unicalNameBool'] = {},
            ['pos'] = {
                ['x'] = 1000,
                ['y'] = 800
            }
        }
        json():write(table, name)
        checker():updateExcept(count, nil, 1)
    end
    function f:update()
        checkerList = checker():getList()
    end
    function f:rename(table, text)
        local ptable = json():read(name)
        ptable['Settings'][table]['name'] = text
        json():write(ptable, name)
        checker():updateExcept(table)
    end
    function f:add(nametable, nick)
        local ptable = json():read(name)
        table.insert(ptable[nametable], nick)
        ptable['Settings'][nametable]['unicalName'][nick] = ''
        ptable['Settings'][nametable]['unicalNameBool'][nick] = false
        ptable['Settings'][nametable]['IsDistance'][nick] = true
        ptable['Settings'][nametable]['color'][nick] = true
        json():write(ptable, name)
        checker():updateExcept(nametable)
    end
    function f:delete(nametable, nick)
        local ptable = json():read(name)
        local index = get_table_element_index(ptable[nametable], nick)
        table.remove(ptable[nametable], index)
        ptable['Settings'][nametable]['unicalName'][nick] = nil
        ptable['Settings'][nametable]['unicalNameBool'][nick] = nil
        ptable['Settings'][nametable]['IsDistance'][nick] = nil
        ptable['Settings'][nametable]['color'][nick] = nil
        json():write(ptable, name)
        checker():updateExcept(nametable, 1)
    end
    function f:action(table, bool)
        local ptable = json():read(name)
        ptable['Settings'][table]['action'] = bool
        json():write(ptable, name)
        checker():updateExcept(table)
    end
    function f:setStyle(table, tstyle, value)
        local ptable = json():read(name)
        ptable['Settings'][table]['style'][tstyle] = value
        json():write(ptable, name)
        checker():updateExcept(table)
    end
    function f:setPosition(table, x,y)
        local ptable = json():read(name)
        ptable['Settings'][table]['pos'] = {
            ['x'] = x,
            ['y'] = y
        }
        json():write(ptable, name)
        checker():updateExcept(table)
    end
    function f:setIsDistance(table, bool, nick)
        local ptable = json():read(name)
        ptable['Settings'][table]['IsDistance'][nick] = bool
        json():write(ptable, name)
        checker():updateExcept(table)
    end
    function f:setColornick(table, bool, nick)
        local ptable = json():read(name)
        ptable['Settings'][table]['color'][nick] = bool
        json():write(ptable, name)
        checker():updateExcept(table)
    end
    function f:setUnicalName(table, nick, unick)
        local ptable = json():read(name)
        ptable['Settings'][table]['unicalName'][nick] = unick
        json():write(ptable, name)
        checker():updateExcept(table)
    end
    function f:setUnicalNameBool(table, nick, bool)
        local ptable = json():read(name)
        ptable['Settings'][table]['unicalNameBool'][nick] = bool
        json():write(ptable, name)
        checker():updateExcept(table)
    end
    return f
end
checker():exist()
checker():update()


local punishList = {}
local punishInputs = {}
if doesFileExist(getWorkingDirectory() .. '\\TrisTools\\RulesAdmins.json') then
    punishList = rules():read()
    for k,v in pairs(punishList) do
        for _,r in pairs(v) do
            punishInputs[_] = new.int(tonumber(r))
        end
    end
end
local faiconsReport = {
    name = {
        u8'Нет', 'HEART', 'EXCLAMATION', 'CLIPBOARD', 'PAPERCLIP', 'GIFT', 'FIRE', 'FILE', 'BELL', 'BUG', 'EYE', 'LEMON', 'SHOP', 'QUOTE_LEFT', 'USER_SECRET', 'PENCIL'
    },
    id = 0,
    uuid = new.int(0)
}


faiconsReport.id = imgui.new['const char*'][#faiconsReport.name](faiconsReport.name)
local ini = inicfg.load({
    render = {
        renderAdminsTeam = false,
        renderCoolDown = 5,
        font = 'Arial',
        fontsize = 10,
        fontflag = 13
    },
    forms = {
        kick=true,
        mute=true,
        jail=true,
        unjail=true,
        ban=true,
        warn=true,
        skick=true,
        unban=true,
        unwarn=true,
        banip=true,
        offban=true,
        offwarn=true,
        unrmute=true,
        sban=true,
        iban=true,
        rmute=true,
        sp=true,
        spawn=true,
        ptp=true,
        money=true,
        setskin=true,
        sethp=true,
        makehelper=true,
        uval=true,
        givedonate=true,
        agiverank=true
    },
    set = {
        x = 500,
        y = 500,
        iconsize = 20,
        fontname = "Arial",
        fontsize = 9,
        fontflag = 13,
        showid = false,
        alignment = 1,
        indent = 20
    },
    onDay = {
        today = os.date("%a"),
        online = 0,
        afk = 0,
        full = 0,
        forms = 0,
        reports = 0
    },
    putStatis = {
        name = true,
        lvl = true,
        ping = true,
        health = true,
        onlineDay = true,
        onlineSession = true,
        afkDay = true,
        afkSession = true,
        reportDay = true,
        reportSession = true,
        date = true
    },
    whcars = {
        enabled = false,
        distance = true,
        statusDoor = true
    },
    style = {
        keyLoggerFon = 100
    },
    main = {
        InWater = false,
        infinityRun = false,
        noBike = false,
        newTempLeader = false,
        zzveh = true,
        customfov = false,
        customfov_value = 120.00000762939,
        enabledForms = true,
        formsTimeOut = 10,
        pos_render_admins_x = 500,
        pos_render_admins_y = 500,
        warnState = false,
        customKillList = false,
        keyLoggerFon = false,
        reconInfoLogger = false,
        gmCar = false,
        StatsCenteredText = false,
        StatsEnabled = false,
        bulletTracers = false,
        fastHelp = false,
        reconInfoNakaz = true,
        modifyIwep = false,
        radarhack = false,
        reconInfoStats = true,
        typeInfoBar = 1,
        changeReconDistance = false,
        reconInfoPunish = true,
        pushReport = false,
        translateEnglishCommand = false,
        azSpawn = true,
        togphoneSpawn = true,
        visualSkin = false,
        oldSkinModel = 0,
        clickWarp = true,
        clickWarpForPeople = false,
        autoAlogin = false,
        autoAloginPassword = '',
        reactionMention = false,
        typeAirBrake = 1,
        speed_airbrake = 1,
        enabledSpeedHack = true,
        bubblePosX = 10,
        bubblePosY = 250,
        enabledAirBrake = true,
        enabledWallHack = false,
        enabledSkeletallWallHack = false,
        skeletWidth = 1,
        skeletalColor = 65997,
        pushTrueRegister = false,
        limitPageSize = 13,
        maxPagesBubble = 500,
        enabledBubbleBox = false,
        bubbleBoxName = 'Admin Chat',
        pos_recon_punish_x = 904,
        pos_recon_punish_y = 1017, 
        pos_recon_stats_x = 1695,
        pos_recon_stats_y = 510,
        pos_recon_nakaz_x = 1263,
        pos_recon_nakaz_y = 963,
        pos_stats_x = 1000,
        pos_stats_y = 800,
        pos_recon_logger_x = 500,
        pos_recon_logger_y = 500,
        wSpeedHackSlider = 194,
        pos_logger_x = 500,
        pos_logger_y = 500
    },
    auth = {
        adminLVL = 0,
        active = false
    },
    hotkey = {
        airbrake = '[]',
        autoreport = '[]',
        admintools = '[]',
        wallhack = '[]',
        wallhackCar = '[]',
        globalCursor = '[]',
        formaTrue = '[75]',
        formaFalse = '[80]',
        reconOff = '[]'
    },
    warnings = {
        teamkill = false,
        proaim = false,
        invisible = false,
        speedhack = false,
        badVehicle = false,
        crasher = false,
        playerJoin = false,
        playerQuit = false
    }
}, iniFile)
if not doesFileExist('moonloader\\config\\SpainSettings.ini') then inicfg.save(ini, iniFile) end

function binder()
    local f = {}
    local file_name = getWorkingDirectory() .. '\\TrisTools\\binder.json'
    function f:exist()
        if not doesFileExist(file_name) then
            local List = {
                ['1'] = {
                    ['name'] = 'Бинд #1',
                    ['key'] = '[]',
                    ['command'] = '/bind1',
                    ['text'] = 'Привет\nЭто первый бинд!',
                    ['active'] = false,
                    ['wait'] = 1
                }
            }
            json():write(List, file_name)
        end
        
    end
    function f:getTargetId()
        if targetId ~= nil then
            return targetId
        else
            return -1
        end
    end
    
    function f:deleteBind(table)
        local ptable = json():read(file_name)
        ptable[table] = nil
        json():write(ptable, file_name)
        binder():getList()
    end
    function f:split(text)
        local tableh = {}
        for line in text:gmatch("[^\n]+") do
            if line ~= '' then
                table.insert(tableh, line)
            end
        end 
        return tableh
    end
    function f:setText(atable, text)
        local string = ''
        local tkeys = {}
        for line in text:gmatch("[^\n]+") do
            table.insert(tkeys, line)
        end
        local count = get_table_count(tkeys)
        local num = 0
        local ret = num ~= count
        for line in text:gmatch("[^\n]+") do
            if line ~= '' then
                num = num + 1
                ret = num ~= count
                string = string .. line .. (ret and '\n' or '')
            end
        end
        local ptable = json():read(file_name)
        ptable[atable]['text'] = string
        json():write(ptable, file_name)
    end
            
    function f:getList()
        binderCfg.list = json():read(file_name)
    end
    function f:update()
        local table = json():read(file_name)
        for k,v in pairs(table) do
            binderCfg.active[k] = new.bool(table[k]['active'])
            binderCfg.text[k] = new.char[128](u8(table[k]['text']))
            binderCfg.name[k] = new.char[256](u8(table[k]['name']))
            binderCfg.command[k] = new.char[256](u8(table[k]['command']))
            binderCfg.key[k] = hotkey.RegisterHotKey('##hotkey_'..k, false, decodeJson(table[k]['key']), function() if ini.auth.active then handler_hotkeys(k)  end   end)
            binderCfg.activeFrame[k] = new.bool(false)
            binderCfg.wait[k] = new.int(table[k]['wait'])
            binderCfg.list = table
        end
    end
    function f:updateExcept(except, newh, ar)
        local table = json():read(file_name)
        for k,v in pairs(table) do
            if k == except then
                binderCfg.active[k] = new.bool(table[k]['active'])
                binderCfg.text[k] = new.char[128](u8(table[k]['text']))
                binderCfg.name[k] = new.char[256](u8(table[k]['name']))
                binderCfg.command[k] = new.char[256](u8(table[k]['command']))
                binderCfg.wait[k] = new.int(table[k]['wait'])
                if ar == 1 then binderCfg.activeFrame[k] = new.bool(false) end
                binderCfg.list = table
                if newh == 1 then binderCfg.key[k] = hotkey.RegisterHotKey('##hotkey_'..k, false, decodeJson(table[k]['key']), function() if ini.auth.active then handler_hotkeys(k)  end   end) end
            end
        end
    end
    function f:newBind() 
        local ptable = json():read(file_name)
        local count = '0'
        for i=1, 999999 do
            if ptable[tostring(i)] == nil then
                count = tostring(i)
                break
            end
        end
        ptable[count] = {
            ['name'] = 'Бинд #'..count,
            ['key'] = '[]',
            ['command'] = '',
            ['text'] = '',
            ['active'] = false,
            ['wait'] = 1
        }
        json():write(ptable, file_name)
        binder():updateExcept(tostring(count), 1, 1)
    end
    function f:setParam(table, param, bool)
        local ptable = json():read(file_name)
        ptable[table][param] = bool
        json():write(ptable, file_name)
        binder():updateExcept(table)
    end
    function f:rename(table, name)
        local ptable = json():read(file_name)
        ptable[table]['name'] = name
        json():write(ptable, file_name)
        binder():updateExcept(table)
    end
    function f:resetHotKey(table, hotkey)
        local ptable = json():read(file_name)
        ptable[table]['key'] = hotkey
        json():write(ptable, file_name)
    end
    function f:save(table)
        local ptable = json():read(file_name)
        ptable[table]['active'] = binderCfg.active[table][0]
        ptable[table]['command'] = u8:decode(str(binderCfg.command[table]))
        ptable[table]['name'] = u8:decode(str(binderCfg.name[table]))
        ptable[table]['wait'] = binderCfg.wait[table][0]
        json():write(ptable, file_name)
        binder():updateExcept(table)
    end
    return f
end
binder():exist()
binder():update()
local autoreportCfg = {
    button = {},
    text = {},
    active = {},
    list = {},
    activeFrame = {},
    iconInt = {}
}
function autoreport()
    local f = {}
    local file_name = getWorkingDirectory() .. '\\TrisTools\\autoreport.json'
    function f:exist()
        if not doesFileExist(file_name) then
            json():write({}, file_name)
        end
    end
    function f:update()
        local table = json():read(file_name)
        for k,v in pairs(table) do
            autoreportCfg.button[k] = new.char[128](u8(table[k]['button']))
            autoreportCfg.text[k] = new.char[128](u8(table[k]['text']))
            autoreportCfg.iconInt[k] = new.int(table[k]['iconInt'])
            autoreportCfg.active[k] = new.bool(v)
            autoreportCfg.activeFrame[k] = new.bool(false)
            autoreportCfg.list = table
        end
    end
    function f:updateExcept(except, newh)
        local table = json():read(file_name)
        for k,v in pairs(table) do
            if k == except then
                autoreportCfg.button[k] = new.char[128](u8(table[k]['button']))
                autoreportCfg.text[k] = new.char[128](u8(table[k]['text']))
                autoreportCfg.iconInt[k] = new.int(table[k]['iconInt'])
                autoreportCfg.active[k] = new.bool(v)
                if newh == 1 then autoreportCfg.activeFrame[k] = new.bool(false) end
                autoreportCfg.list = table
            end
        end
    end
    function f:save(table)
        local ptable = json():read(file_name)
        ptable[table]['active'] = autoreportCfg.active[table][0]
        ptable[table]['button'] = u8:decode(str(autoreportCfg.button[table]))
        ptable[table]['text'] = u8:decode(str(autoreportCfg.text[table]))
        if faiconsReport.uuid[0] == 0 then
            ptable[table]['icon'] = 'not'
        else
            ptable[table]['icon'] = faiconsReport.name[faiconsReport.uuid[0] + 1]
            ptable[table]['iconInt'] = faiconsReport.uuid[0]
        end
        json():write(ptable, file_name)
        autoreport():updateExcept(table)
    end
    function f:newButton()
        local ptable = json():read(file_name)
        local count = '0'
        for i=1, 999999 do
            if ptable[tostring(i)] == nil then
                count = tostring(i)
                break
            end
        end
        ptable[count] = {
            ['button'] = 'Кнопка #'..count,
            ['text'] = '',
            ['active'] = false,
            ['icon'] = 'not',
            ['iconInt'] = 0
        }
        json():write(ptable, file_name)
        autoreport():updateExcept(tostring(count), 1)
    end
    function f:getList()
        autoreportCfg.list = json():read(file_name)
    end
    function f:deleteButton(table)
        local ptable = json():read(file_name)
        ptable[table] = nil
        json():write(ptable, file_name)
        autoreport():getList()
    end
    function f:setActive(table, bool)
        local ptable = json():read(file_name)
        ptable[table]['active'] = bool
        json():write(ptable, file_name)
    end
    return f
end
autoreport():exist()
autoreport():update()
ffi.cdef[[
    struct kill_list_entry {
        char killer[25];
        char victim[25];
        uint32_t killer_color;
        uint32_t victim_color;
        uint8_t weapon_id;
    } __attribute__ ((packed));

    struct kill_list_information {
        int is_enabled;
        struct kill_list_entry entries[5];
        int longest_nick_length;
        int offset_x;
        int offset_y;
        void* d3d_font;
        void* weapon_font1;
        void* weapon_font2;
        void* sprite;
        void* d3d_device;
        int unk1;
        void* unk2;
        void* unk3;
    } __attribute__ ((packed));
]]

ffi.cdef [[
typedef struct stRECT
{
    int left, top, right, bottom;
} RECT;

typedef struct stID3DXFont
{
    struct ID3DXFont_vtbl* vtbl;
} ID3DXFont;

struct ID3DXFont_vtbl
{
        void* QueryInterface; // STDMETHOD(QueryInterface)(THIS_ REFIID iid, LPVOID *ppv) PURE;
    void* AddRef; // STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    uint32_t (__stdcall * Release)(ID3DXFont* font); // STDMETHOD_(ULONG, Release)(THIS) PURE;

    // ID3DXFont
    void* GetDevice; // STDMETHOD(GetDevice)(THIS_ LPDIRECT3DDEVICE9 *ppDevice) PURE;
    void* GetDescA; // STDMETHOD(GetDescA)(THIS_ D3DXFONT_DESCA *pDesc) PURE;
    void* GetDescW; // STDMETHOD(GetDescW)(THIS_ D3DXFONT_DESCW *pDesc) PURE;
    void* GetTextMetricsA; // STDMETHOD_(BOOL, GetTextMetricsA)(THIS_ TEXTMETRICA *pTextMetrics) PURE;
    void* GetTextMetricsW; // STDMETHOD_(BOOL, GetTextMetricsW)(THIS_ TEXTMETRICW *pTextMetrics) PURE;

    void* GetDC; // STDMETHOD_(HDC, GetDC)(THIS) PURE;
    void* GetGlyphData; // STDMETHOD(GetGlyphData)(THIS_ UINT Glyph, LPDIRECT3DTEXTURE9 *ppTexture, RECT *pBlackBox, POINT *pCellInc) PURE;

    void* PreloadCharacters; // STDMETHOD(PreloadCharacters)(THIS_ UINT First, UINT Last) PURE;
    void* PreloadGlyphs; // STDMETHOD(PreloadGlyphs)(THIS_ UINT First, UINT Last) PURE;
    void* PreloadTextA; // STDMETHOD(PreloadTextA)(THIS_ LPCSTR pString, INT Count) PURE;
    void* PreloadTextW; // STDMETHOD(PreloadTextW)(THIS_ LPCWSTR pString, INT Count) PURE;

    int (__stdcall * DrawTextA)(ID3DXFont* font, void* pSprite, const char* pString, int Count, RECT* pRect, uint32_t Format, uint32_t Color); // STDMETHOD_(INT, DrawTextA)(THIS_ LPD3DXSPRITE pSprite, LPCSTR pString, INT Count, LPRECT pRect, DWORD Format, D3DCOLOR Color) PURE;
    void* DrawTextW; // STDMETHOD_(INT, DrawTextW)(THIS_ LPD3DXSPRITE pSprite, LPCWSTR pString, INT Count, LPRECT pRect, DWORD Format, D3DCOLOR Color) PURE;

    void (__stdcall * OnLostDevice)(ID3DXFont* font); // STDMETHOD(OnLostDevice)(THIS) PURE;
    void (__stdcall * OnResetDevice)(ID3DXFont* font); // STDMETHOD(OnResetDevice)(THIS) PURE;
};

uint32_t D3DXCreateFontA(void* pDevice, int Height, uint32_t Width, uint32_t Weight, uint32_t MipLevels, bool Italic, uint32_t CharSet, uint32_t OutputPrecision, uint32_t Quality, uint32_t PitchAndFamily, const char* pFaceName, ID3DXFont** ppFont);
]]

local temp_adminLVL = {
    active = false,
    adminLVL = 0
}
local klID = {
    Background = -1,
    Unarmed = 0,
    Knuckles = 1,
    Golf = 2,
    Stick = 3,
    Knife = 4,
    Bat = 5,
    Shovel = 6,
    Cue = 7,
    Katana = 8,
    Chainsaw = 9,
    Dildo1 = 10,
    Dildo2 = 11,
    Dildo3 = 12,
    Dildo4 = 13,
    Flowers = 14,
    Cane = 15,
    Grenade = 16,
    Gas = 17,
    Molotov = 18,
    Pistol = 22,
    Slicend = 23,
    Eagle = 24,
    Shotgun = 25,
    Sawnoff = 26,
    Combat = 27,
    Uzi = 28,
    Mp5 = 29,
    Ak47 = 30,
    M4 = 31,
    Tec9 = 32,
    Rifle = 33,
    Sniper = 34,
    RPG = 35,
    Launcher = 36,
    Flame = 37,
    Minigun = 38,
    Sachet = 39,
    Detonator = 40,
    Spray = 41,
    Extinguisher = 42,
    Goggles1 = 44,
    Goggles2 = 45,
    Parachute = 46,
    Vehicle = 49,
    Helicopter = 50,
    Explosion = 51,
    Drowned	= 53,
    Splat = 54,
    Suicide = 255,
}

local RenderGun = {
    [klID.Background] = 71,
    [klID.Unarmed] = 37,
    [klID.Knuckles] = 66,
    [klID.Golf] = 62,
    [klID.Stick] = 40,
    [klID.Knife] = 67,
    [klID.Bat] = 63,
    [klID.Shovel] = 38,
    [klID.Cue] = 34,
    [klID.Katana] = 33,
    [klID.Chainsaw] = 49,
    [klID.Dildo1] = 69,
    [klID.Dildo2] = 69,
    [klID.Dildo3] = 69,
    [klID.Dildo4] = 69,
    [klID.Flowers] = 36,
    [klID.Cane] = 35,
    [klID.Grenade] = 64,
    [klID.Gas] = 68,
    [klID.Molotov] = 39,
    [klID.Pistol] = 54,
    [klID.Slicend] = 50,
    [klID.Eagle] = 51,
    [klID.Shotgun] = 61,
    [klID.Sawnoff] = 48,
    [klID.Combat] = 43,
    [klID.Uzi] = 73,
    [klID.Mp5] = 56,
    [klID.Ak47] = 72,
    [klID.M4] = 53,
    [klID.Tec9] = 55,
    [klID.Rifle] = 46,
    [klID.Sniper] = 65,
    [klID.RPG] = 52,
    [klID.Launcher] = 41,
    [klID.Flame] = 42,
    [klID.Minigun] = 70,
    [klID.Sachet] = 60,
    [klID.Detonator] = 59,
    [klID.Spray] = 47,
    [klID.Extinguisher] = 44,
    [klID.Goggles1] = 45,
    [klID.Goggles2] = 45,
    [klID.Parachute] = 58,
    [klID.Explosion] = 81,
    [klID.Helicopter] = 82,
    [klID.Suicide] = 79,
    [klID.Drowned] = 79,
    [klID.Vehicle] = 76,
    [klID.Splat] = 75,
}
local kl = {
    window = imgui.new.bool(),
    imgui_showid = imgui.new.bool(ini.set.showid),
    imgui_indent = imgui.new.int(ini.set.indent),
    imgui_fontname = imgui.new.char[128](ini.set.fontname),
    imgui_fontsize = imgui.new.int(ini.set.fontsize),
    imgui_fontflag = imgui.new.int(ini.set.fontflag),
    imgui_iconsize = imgui.new.int(ini.set.iconsize),
    alignment = imgui.new.int(ini.set.alignment),
    item_list = {"Left", "Middle", "Right"},
    
    font = renderCreateFont(ini.set.fontname, ini.set.fontsize, ini.set.fontflag)
}
kl.ImItems = imgui.new["const char*"][#kl.item_list](kl.item_list)
local windows = {
    AdminTools = imgui.new.bool(false),
    reportPanel = imgui.new.bool(false),
    GhettoPanel = new.bool(false),
    playerStats = new.bool(false),
    keyLogger = new.bool(false),
    aconsole = new.bool(false),
    recon = {
        punish = new.bool(false),
        stats = new.bool(false),
        nakaz = new.bool(false)
    },
    nakazList = {
        ['JAIL'] = new.bool(false),
        ['MUTE'] = new.bool(false),
        ['WARN'] = new.bool(false),
        ['BAN'] = new.bool(false),
        ['SBAN'] = new.bool(false),
        ['RMUTE'] = new.bool(false)
    }
}
local menuItem = 1
local menuButtons = {
    {name=u8('>   Настройки'), faicons('APPLE_WHOLE'), i = 1},
    {name=u8('>   Админ ПО'), faicons('CODE'), i = 2},
    {name=u8('>   Режим Слежки'), faicons('BINOCULARS'), i = 3},
    {name=u8('>   Авто-Репорт'), faicons('ROBOT'), i = 8},
    {name=u8('>   Команды'), faicons('TERMINAL'), i = 9},
    {name=u8('>   Мониторинг'), faicons('DESKTOP'), i = 4},
    {name=u8('>   Формы'), faicons('TAG'), i = 6},
    {name=u8('>   Чекер'), faicons('LIST'), i = 5},
    {name=u8('>   Биндер'), faicons('PAPERCLIP'), i = 7},
    {name=u8(">   Лог обновлений"), faicons("CLIPBOARD"), i = 11}
}
local headerButtons = 1
local report = {
   
    players = {}
}

local blacklist = {
    'SMS',
    'AFK',
    'На паузе:'
}
local adminMonitor = {
    active = false,
    admins = {},
    time = os.time(),
    font = renderCreateFont(ini.render.font, ini.render.fontsize, ini.render.fontflag),
    AFK = 0,
    RECON = 0
}
ffi.cdef[[
    struct stGangzone
    {
        float    fPosition[4];
        uint32_t    dwColor;
        uint32_t    dwAltColor;
    };
    struct stGangzonePool
    {
        struct stGangzone    *pGangzone[1024];
        int iIsListed[1024];
    };
]]
local elements = {
    forms = {
        kick = new.bool(ini.forms.kick),
        mute = new.bool(ini.forms.mute),
        jail=new.bool(ini.forms.jail),
        unjail=new.bool(ini.forms.unjail),
        ban=new.bool(ini.forms.ban),
        warn=new.bool(ini.forms.warn),
        skick=new.bool(ini.forms.skick),
        unban=new.bool(ini.forms.unban),
        unwarn=new.bool(ini.forms.unwarn),
        banip=new.bool(ini.forms.banip),
        offban=new.bool(ini.forms.offban),
        offwarn=new.bool(ini.forms.offwarn),
        sban=new.bool(ini.forms.sban),
        iban=new.bool(ini.forms.iban),
        rmute=new.bool(ini.forms.rmute),
        sp=new.bool(ini.forms.sp),
        unrmute=new.bool(ini.forms.unrmute),
        spawn=new.bool(ini.forms.spawn),
        ptp=new.bool(ini.forms.ptp),
        money=new.bool(ini.forms.money),
        setskin=new.bool(ini.forms.setskin),
        sethp=new.bool(ini.forms.sethp),
        makehelper=new.bool(ini.forms.makehelper),
        uval=new.bool(ini.forms.uval),
        givedonate=new.bool(ini.forms.givedonate),
        agiverank=new.bool(ini.forms.agiverank)
    },
    putStatis = {
        name = new.bool(ini.putStatis.name),
        lvl = new.bool(ini.putStatis.lvl),
        ping = new.bool(ini.putStatis.ping),
        health = new.bool(ini.putStatis.health),
        onlineDay = new.bool(ini.putStatis.onlineDay),
        onlineSession = new.bool(ini.putStatis.onlineSession),
        afkDay = new.bool(ini.putStatis.afkDay),
        afkSession = new.bool(ini.putStatis.afkSession),
        reportDay = new.bool(ini.putStatis.reportDay),
        reportSession = new.bool(ini.putStatis.reportSession),
        date = new.bool(ini.putStatis.date)
    },
    whcars = {
        distance = new.bool(ini.whcars.distance),
        statusDoor = new.bool(ini.whcars.statusDoor),
        enabled = new.bool(ini.whcars.enabled)
    },
    input = {
        reportAnswer = imgui.new.char[128](''),
        autoAloginPassword = imgui.new.char[128](tostring(ini.main.autoAloginPassword)),
        bubbleBoxName = imgui.new.char[128](ini.main.bubbleBoxName),
        console = new.char[128](''),
        renderFont = new.char[128](ini.render.font)
    },
    toggle = {
        renderAdminsTeam = new.bool(ini.render.renderAdminsTeam),
        InWater = new.bool(ini.main.InWater),
        infinityRun = new.bool(ini.main.infinityRun),
        gmCar = new.bool(ini.main.gmCar),
        noBike = new.bool(ini.main.noBike),
        newTempLeader = new.bool(ini.main.newTempLeader),
        zzveh = new.bool(ini.main.zzveh),
        enabledForms = new.bool(ini.main.enabledForms),
        customKillList = new.bool(ini.main.customKillList),
        keyLoggerFon = new.bool(ini.main.keyLoggerFon),
        reconInfoLogger = new.bool(ini.main.reconInfoLogger),
        StatsEnabled = new.bool(ini.main.StatsEnabled),
        StatsCenteredText = new.bool(ini.main.StatsCenteredText),
        bulletTracers = new.bool(ini.main.bulletTracers),
        fastHelp = new.bool(ini.main.fastHelp),
        reconInfoNakaz = new.bool(ini.main.reconInfoNakaz),
        customfov = new.bool(ini.main.customfov),
        modifyIwep = new.bool(ini.main.modifyIwep),
        reconInfoStats = new.bool(ini.main.reconInfoStats),
        reconInfoPunish = new.bool(ini.main.reconInfoPunish),
        pushReport = new.bool(ini.main.pushReport),
        translateEnglishCommand = new.bool(ini.main.translateEnglishCommand),
        azSpawn = new.bool(ini.main.azSpawn),
        togphoneSpawn = new.bool(ini.main.togphoneSpawn),
        visualSkin = new.bool(ini.main.visualSkin),
        clickWarp = new.bool(ini.main.clickWarp),
        clickWarpForPeople = new.bool(ini.main.clickWarpForPeople),
        autoAlogin = new.bool(ini.main.autoAlogin),
        reactionMention = new.bool(ini.main.reactionMention),
        enabledAirBrake = new.bool(ini.main.enabledAirBrake),
        enabledSpeedHack = new.bool(ini.main.enabledSpeedHack),
        enabledWallHack = new.bool(ini.main.enabledWallHack),
        enabledSkeletallWallHack = new.bool(ini.main.enabledSkeletallWallHack),
        pushTrueRegister = new.bool(ini.main.pushTrueRegister),
        enabledBubbleBox = new.bool(ini.main.enabledBubbleBox),
        radarhack = new.bool(ini.main.radarhack),
        changeReconDistance = new.bool(ini.main.changeReconDistance)
    },
    int = {
        renderFontSize = new.int(ini.render.fontsize),
        renderFontFlag = new.int(ini.render.fontflag),
        renderCoolDown = new.int(ini.render.renderCoolDown),
        typeInfoBar = new.int(ini.main.typeInfoBar),
        visualSkin = new.int(0),
        typeAirBrake = new.int(ini.main.typeAirBrake),
        skeletWidth = new.int(ini.main.skeletWidth),
        limitPageSize = new.int(ini.main.limitPageSize),
        maxPagesBubble = new.int(ini.main.maxPagesBubble),
        playerHealth = new.int(100),
        colorCar = new.int(0),
        customfov_value = new.float(ini.main.customfov_value),
        IDcar = new.int(400),
        formsTimeOut = new.int(ini.main.formsTimeOut),
        wSpeedHackSlider = new.float(ini.main.wSpeedHackSlider)
    },
    float = {
        skeletalColor = new.float[4](explode_argb(ini.main.skeletalColor))
    },
    warnings = {
        teamkill = new.bool(ini.warnings.teamkill),
        proaim = new.bool(ini.warnings.proaim),
        invisible = new.bool(ini.warnings.invisible),
        speedhack = new.bool(ini.warnings.speedhack),
        badVehicle = new.bool(ini.warnings.badVehicle),
        crasher = new.bool(ini.warnings.crasher),
        playerJoin = new.bool(ini.warnings.playerJoin),
        playerQuit = new.bool(ini.warnings.playerQuit)
    }
}

local tCars = {
    name = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
        "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection", "Hunter",
        "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
        "RCBandit", "Romero","Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
        "Yankee", "Caddy", "Solair", "Berkley'sRCVan", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
        "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
        "Dozer", "Maverick", "NewsChopper", "Rancher", "FBIRancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "BlistaCompact", "PoliceMaverick",
        "Boxvillde", "Benson", "Mesa", "RCGoblin", "HotringRacerA", "HotringRacerB", "BloodringBanger", "Rancher", "SuperGT", "Elegant", "Journey", "Bike",
        "MountainBike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "hydra", "FCR-900", "NRG-500", "HPV1000",
        "CementTruck", "TowTruck", "Fortune", "Cadrona", "FBITruck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight",
        "Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
        "Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
        "FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "NewsVan",
        "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "FreightBox", "Trailer", "Andromada", "Dodo", "RCCam", "Launch", "PoliceCar", "PoliceCar",
        "PoliceCar", "PoliceRanger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "GlendaleShit", "SadlerShit", "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller",
        "UtilityTrailer"},
    id = 0,
    uuid = new.int(0)
}
tCars.id = imgui.new['const char*'][#tCars.name](tCars.name)




local reportButtons = {
    {name=u8("Работать по ID"), func = function(id, pm, nick) if pm:find('(%d+)') then   sampSendChat('/re '..pm:match('(%d+)'))  wait(1000)  
        sampSendChat('/pm '..id..' Уважаемый игрок, начинаю работу по вашей жалобе!')  refresh_current_report()    end end},
    
    {name=u8('Помочь игроку'), icon=faicons('HANDSHAKE_ANGLE'), func = function(id,pm,nick)     windows.reportPanel[0] = false  sampSendChat('/goto '..id)  wait(1500)  
        sampSendChat('/pm '..id..' Уважаемый игрок, сейчас попробую вам помочь!')   refresh_current_report()    end},

    {name=u8('Следить'), icon=faicons('CAMERA_CCTV'), func = function(id,pm,nick) windows.reportPanel[0] = false  sampSendChat('/re '..id)    wait(1500)  
        sampSendChat('/pm '..id..' Уважаемый игрок, начинаю работу по вашей жалобе!') refresh_current_report() end},

    {name=u8('Передать в /a'), icon=faicons('COMMENT'), func = function(id,pm,nick)      sampSendChat('/a Жалоба от '..nick..'['..id..']: '..pm) wait(1500)  
        sampSendChat('/pm '..id..' Уважаемый игрок, передал вашу жалобу!')  refresh_current_report()     end},

    {name=u8('AZ'), icon=faicons('BUILDING_COLUMNS'), func = function(id,pm,nick)  
        az()    wait(1000)  sampSendChat('/gethere '..id)   wait(1500)  sampSendChat('/pm '..id..' Уважаемый игрок, сейчас попробую вам помочь!')   refresh_current_report()        end},

    {name=u8('Приятной игры'), icon=faicons('GIFT'), func = function(id,pm,nick)    
        sampSendChat('/pm '..id..' Уважаемый игрок, приятного времяпровождения на нашем сервере!') refresh_current_report()        end},
    {name=u8('Отказ авто'), icon=faicons('HOUSE_USER'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, администрация не выдает авто просто так.')  refresh_current_report()        end},
    {name=u8('Укажите ID'), icon=faicons('LOCATION_DOT'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, просьба указать ID нарушителя.')  refresh_current_report()        end},
    {name=u8('ЖБ форум'), icon=faicons('USER_TIE'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, вы можете оставить жалобу на нашем форуме.')  refresh_current_report()        end},
    {name=u8('Нет инфы'), icon=faicons('USER_POLICE'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, не владеем данной информацией.')  refresh_current_report()        end},
    {name=u8('Ожидайте'), icon=faicons('BUG'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, просьба проявить терпение.')  refresh_current_report()        end},
	{name=u8('РП путем'), icon=faicons('BUG'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, совершите данное действие РП Путем.')  refresh_current_report()        end},
	{name=u8('В интернете'), icon=faicons('BUG'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, узнайте данную информацию в интернете.')  refresh_current_report()        end},
	{name=u8('Отказано'), icon=faicons('BUG'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, то что вы просите, не может быть исполнено.')  refresh_current_report()        end},
	{name=u8('Отказ денег'), icon=faicons('BUG'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, администрация не выдает денежные средства.')  refresh_current_report()        end},
	{name=u8('Да'), icon=faicons('BUG'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, именно так.')  refresh_current_report()        end},
	{name=u8('Нет'), icon=faicons('BUG'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, никак нет.')  refresh_current_report()        end},
	{name=u8('Не ТПшим'), icon=faicons('BUG'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, администрация не телепортирует.')  refresh_current_report()        end},
	{name=u8('Не ТПшимся'), icon=faicons('BUG'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, администрация не телепортируется.')  refresh_current_report()        end},
	{name=u8('Наказан'), icon=faicons('BUG'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, нарушитель был наказан.')  refresh_current_report()        end},
	{name=u8('Учтем'), icon=faicons('BUG'), func = function(id,pm,nick)   
        sampSendChat('/pm '..id..' Уважаемый игрок, администрация учет Ваше пожелание/предложение.')  refresh_current_report()        end}, 
}
local reconButtons = {
    {name = ('ReconOFF'), func = function(id)   sampSendChat('/re off') end},
    {name = ('GETSTATS'), func = function(id)   sampSendChat('/getstats '..id)  end},
    {name = ('WEAP'), func = function(id)   sampSendChat('/iwep '..id)  end},
    {name = ('AZ'), func = function(id) sampSendChat('/re off') wait(1500)  az()    wait(1000)  sampSendChat('/gethere '..id)   end},
    {name = ('SLAP'), func = function(id)   sampSendChat('/slap '..id)  end},
    {name = ('FREEZE'), func = function(id) sampSendChat('/freeze '..id) end},
    {name = ('UNFREEZE'),   func = function(id) sampSendChat('/unfreeze '..id)  end},
    {name = ('SETHP'),  func = function(id) imgui.OpenPopup('SETHP')    end},
    {name = ('Машина'), func = function(id) imgui.OpenPopup('VEH')  end},
    {name = ('AGL'), func = function(id)    sampSendChat('/agl '..id)   end},
    {name = ('SPAWN'), func =   function(id)    sampSendChat('/spawn '..id) end},
    {name = ('GOTO'), func =    function(id)    sampSendChat('/re off') wait(1500)  sampSendChat('/goto '..id)  end},
    {name = ('GM'), func =  function(id)    sampSendChat('/gm '..id)    end},
    {name = ('OFFSTATS'), func =    function(id)    sampSendChat('/getoffstats '..sampGetPlayerNickname(id))  end},
    {name = ('ТП на дорогу'), func =    function(id)    doroga(id)  end}
}



local keyLogger = {
    target = -1,
    table = {
        ['onfoot'] = {},
        ['vehicle'] = {}
    },
    playerId = -1,
    fon = new.int(ini.style.keyLoggerFon)
}
local reportAnswerProcess = {}
local reportUUID = {}
local AI_PAGE = {}
local AI_HEADERBUT = {}
local AI_TOGGLE = {}
local AI_PICTURE = {}
local rInfo = {
    state = false,
    id = -1,
    dist = 2,
    fraction = nil,
    playerTimes = nil,
    time = os.time(),
    que = false,
    update_recon = false
}
local exColor = {
    windowBg = new.float[4](0, 0, 0, 0)
}
local themeStyles = {
    65997, 16777421, 16777677, 65741
}
local toggleSettings = {
    
    {name = ('Push-Репорт'), func = ('pushReport'), hintText = 'Пуш-Уведомление при новом репорте.'},
    
    {name = ('Команды на Английском'), func = ('translateEnglishCommand'), hintText = ('При вводе команды с префиксом (/) будет заменять русские символы на английские.')},
    
    {name = ('ClickWarp'), func = ('clickWarp'),    
        hintText = 'При нажатии колёсика мыши появится курсор, с помощью которого можно телепортироваться по карте.', helpPopup = ('clickWarp')},
    
    {name = ('Дальний чат'), func = ('enabledBubbleBox'), hintText = ('Вы сможете видеть чат намного дальше обычного.'), helpPopup = ('enabledBubbleBox')},
    {name = ('Изменение дистанции в реконе'), func = ('changeReconDistance'), hintText = ('Находясь в реконе, зажав клавишу Z и крутя колесиком мыши, вы сможете изменять дистанцию до игрока.')},
    {name = ('Модифицированный /iwep ID'), func = ('modifyIwep'), hintText = ('В панели /iwep ID вместо id оружия отображается название оружия, изменен стиль.')},
    {name = ('Меню взаимодействия с игроками'), func = ('fastHelp'), hintText = ('При нажатии ПКМ появится круг взаимодействия.\nЕсть два типа взаимодействия:\n- Игрок\n-Транспорт\nПереключение на клавишу E.')},
}



local softMenuItem = 1
local softMenu = {
    "AirBrake",
    "SpeedHack",
    "WH на игроков",
    "WH на транспорт",
    "RadarHack",
    "Bullet Tracers",
    "Custom KillList",
    "Infinity Run",
    "No Bike Fall",
    "InWater Hack",
    "GM on Car"
}
local cursorEnabled = false
ffi.cdef[[
    struct stKillEntry
    {
        char					szKiller[25];
        char					szVictim[25];
        uint32_t				clKillerColor; // D3DCOLOR
        uint32_t				clVictimColor; // D3DCOLOR
        uint8_t					byteType;
    } __attribute__ ((packed));

    struct stKillInfo
    {
        int						iEnabled;
        struct stKillEntry		killEntry[5];
        int 					iLongestNickLength;
        int 					iOffsetX;
        int 					iOffsetY;
        void			    	*pD3DFont; // ID3DXFont
        void		    		*pWeaponFont1; // ID3DXFont
        void		   	    	*pWeaponFont2; // ID3DXFont
        void					*pSprite;
        void					*pD3DDevice;
        int 					iAuxFontInited;
        void 		    		*pAuxFont1; // ID3DXFont
        void 			    	*pAuxFont2; // ID3DXFont
    } __attribute__ ((packed));
]]

function getWeapon(weapon)
    local names = {
    [0] = "Fist",
    [1] = "Brass Knuckles",
    [2] = "Golf Club",
    [3] = "Nightstick",
    [4] = "Knife",
    [5] = "Baseball Bat",
    [6] = "Shovel",
    [7] = "Pool Cue",
    [8] = "Katana",
    [9] = "Chainsaw",
    [10] = "Purple Dildo",
    [11] = "Dildo",
    [12] = "Vibrator",
    [13] = "Silver Vibrator",
    [14] = "Flowers",
    [15] = "Cane",
    [16] = "Grenade",
    [17] = "Tear Gas",
    [18] = "Molotov Cocktail",
    [22] = "9mm",
    [23] = "Silenced 9mm",
    [24] = "Desert Eagle",
    [25] = "Shotgun",
    [26] = "Sawnoff Shotgun",
    [27] = "Combat Shotgun",
    [28] = "Micro SMG/Uzi",
    [29] = "MP5",
    [30] = "AK-47",
    [31] = "M4",
    [32] = "Tec-9",
    [33] = "Country Rifle",
    [34] = "Sniper Rifle",
    [35] = "RPG",
    [36] = "HS Rocket",
    [37] = "Flamethrower",
    [38] = "Minigun",
    [39] = "Satchel Charge",
    [40] = "Detonator",
    [41] = "Spraycan",
    [42] = "Fire Extinguisher",
    [43] = "Camera",
    [44] = "Night Vis Goggles",
    [45] = "Thermal Goggles",
    [46] = "Parachute",
    [49] = 'Vehicle',
    [50] = 'Helicopter Blades'}
    if not names[weapon] then return "None" end
    return names[weapon]
end
local statsElements = {
    {name = ('Ник / ID'), text = ('{myname}[{myid}]'), func = ('name')},
    {name = ('LVL админ-прав'), text = ('LVL: '..ini.auth.adminLVL or ''), func = ('lvl')},
    {name = ('Пинг'), text = ('Пинг: {ping}'), func = ('ping')},
    {name = ('Здоровье'), text = ('Здоровье: {health}'), func = ('health')},
    {name = ('Онлайн за день'), text = ('Онлайн за день: '..get_clock(ini.onDay.online)), func = ('onlineDay')},
    {name = ('Онлайн за сеанс'), text = ('Онлайн за сеанс: '..get_clock(sessionOnline[0])), func = ('onlineSession')},
    {name = ('АФК за день'), text = ('АФК за день: '..get_clock(ini.onDay.afk)), func = ('afkDay')},
    {name = ('АФК за сеанс'), text = ('АФК за сеанс: '..get_clock(sessionAfk[0])), func = ('afkSession')},
    {name = ('Репорты за день'), text = ('Репорты за день: '..ini.onDay.reports), func = ('reportDay')},
    {name = ('Репорты за сеанс'), text = ('Репорты за сеанс: '..sessionReports), func = ('reportSession')},
    {name = ('Дата и время'), text = ('Дата и время: '..os.date('%x')..' '..os.date('%H:%M:%S')), func = ('date')}
}
local dayFull = new.int(ini.onDay.full)
local enAirBrake = false
local listForColorTheme = {}
listForColorTheme.FLOAT4_COLOR = new.float[4](jcfg["colors"][1], jcfg["colors"][2], jcfg["colors"][3], jcfg["colors"][4]) -- float[4]
listForColorTheme.OUR_COLOR = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(listForColorTheme.FLOAT4_COLOR[2], listForColorTheme.FLOAT4_COLOR[1], listForColorTheme.FLOAT4_COLOR[0], listForColorTheme.FLOAT4_COLOR[3])) -- BBGGRRAA => AARRGGBB
listForColorTheme.ret = MonetLua.buildColors(listForColorTheme.OUR_COLOR, 0.8, true)
function message()
    local f = {}
    function f:info(text)
        sampAddChatMessage(string.format("[  {%s}TrisTools | Информация{FFFFFF}   ] " .. text, string.sub(bit.tohex(ColorAccentsAdapter(listForColorTheme.ret.accent1.color_500):as_argb()), 3, 8)), -1)
    end
    function f:error(text)
        sampAddChatMessage(string.format("[  {%s}TrisTools | Ошибка{ffffff}   ] " .. text, string.sub(bit.tohex(ColorAccentsAdapter(listForColorTheme.ret.accent1.color_700):as_argb()), 3, 8)), -1)
    end
    function f:warning(text, ...)
        sampAddChatMessage(string.format("[  {%s}TrisTools | Warning{ffffff}   ] " .. text, string.sub(bit.tohex(ColorAccentsAdapter(listForColorTheme.ret.accent1.color_800):as_argb()), 3, 8), ...), -1)
    end
    function f:alogin(text, ...)
        sampAddChatMessage(string.format("[  {%s}TrisTools | ALogin{ffffff}   ] " .. text, string.sub(bit.tohex(ColorAccentsAdapter(listForColorTheme.ret.accent1.color_400):as_argb()), 3, 8), ...), -1)
    end
    function f:notify(text, types, time, addType, addText)
        if notify then
            notify.newNotify(tostring('>> LiteTools <<\n'..text), time, tonumber(types))
            local addTypeA = addType or 0
            if addTypeA == 1 then
                local text = addText or ''
                if text ~= '' then
                    if types == 1 or types == 2 then
                        sampAddChatMessage(string.format("[  {%s}TrisTools | Информация{FFFFFF}   ] " .. text, string.sub(bit.tohex(ColorAccentsAdapter(listForColorTheme.ret.accent1.color_500):as_argb()), 3, 8)), -1)
                    elseif types == 3 then
                        sampAddChatMessage(string.format("[  {%s}TrisTools | Ошибка{ffffff}   ] " .. text, string.sub(bit.tohex(ColorAccentsAdapter(listForColorTheme.ret.accent1.color_700):as_argb()), 3, 8)), -1)
                    end
                end
            end
        else
            sampAddChatMessage(string.format("[  {%s}TrisTools | Информация{FFFFFF}   ] " .. text, string.sub(bit.tohex(ColorAccentsAdapter(listForColorTheme.ret.accent1.color_500):as_argb()), 3, 8)), -1)
        end
    end
    return f
end
function sampev.onShowDialog(dialogId, style, title, bt1, bt2, text)
    if temp_adminLVL.active then
        if title:find('Статистика') then
            for line in text:gmatch("[^\n]+") do
                line = line:gsub('{......}', '')
              
                if line:find('Административный уровень:(.*)') then
                    local lvl = line:match('Административный уровень:(.*)')
                    lvl = lvl:gsub(' ', '')
                    
                    if tonumber(lvl) ~= nil then
                        if tonumber(lvl) > 0 then
                            ini.auth.adminLVL = tonumber(lvl)
                            ini.auth.active = true
                        else
                            message():error("Вы не являетесь администратором!")
                            thisScript():unload()
                        end
                    end
                end
            end
            return false
        end
    end
    if define.check then
        if title:find('%{......%}Репорт') then
            for line in text:gmatch("[^\n]+") do
                line = line:gsub('{......}', '')
                if line:find('%d+. (.*)%[(%d+)%] %| Жалоба: (.*)') then
                    local rnick, rid, rtext = line:match('%d+. (.*)%[(%d+)%] %| Жалоба: (.*)')
                    if rnick ~= 'Spain_Bot' then
                        print(("LOG: DEFINE.LIST + 1 {%s, %s, %s}"):format(rnick, rid, rtext))
                        define.list[#define.list + 1] = {nick=rnick, id=rid, text=rtext}
                    end
                end
            end
            return false
        end
    end
    if elements.toggle.modifyIwep[0] then
        if title:find('%{......%}Информация оружия') then
            local nick = ''
            local fist = false
            for line in text:gmatch("[^\n]+") do
                line = line:gsub('{......}', ' ')
                line = line:gsub('\t', ' ')
                if line:find('Игрок:%s+(.*)') then
                    nick = line:match('Игрок:%s+(.*)')
                    text = text:gsub(line, '')
                end
                if line:find('%d+%s+Weapon:%s+(%d+)%s+Ammo:%s+(%d+)') then
                    local arg, ammo = line:match('%d+%s+Weapon:%s+(%d+)%s+Ammo:%s+(%d+)')
                    local wep = getWeapon(tonumber(arg))
                    text = text:gsub('%d+%s+Weapon:%s+'..arg..'%s+Ammo:%s+'..ammo, wep..'['..ammo..']')
                end
            end
            
            text = text .. '\n \nЭто модификация /iwep by tfornik.'
            return { dialogId, 2, title:match('({......})')..'Информация об оружии: '..nick, bt1, bt2, title:match('({......})')..'Оружие[Патроны]\n{ffffff}'..text }
        end
    end
    if title:find('{2ED2FF}Статистика игрока') then
        for line in text:gmatch("[^\n]+") do
            line = line:gsub('{......}', ' ')
            line = line:gsub('\t', '')
            if line:find('Часов в игре: (.*)') and rInfo.playerTimes == nil then
                if rInfo.id ~= -1 and rInfo.state and rInfo.playerTimes == nil then
                    rInfo.playerTimes = line:match('Часов в игре: (.*)')
                    return false
                end
            end
            if line:find('Организация: (.*)') and rInfo.fraction == nil then
                if rInfo.id ~= -1 and rInfo.state and rInfo.fraction == nil then
                    rInfo.fraction = line:match('Организация: (.*)')
                    return false
                end
            end        
        end
    end
    if elements.toggle.autoAlogin[0] then
        if elements.input.autoAloginPassword[0] ~= 0 then
            if dialogId == 2934 then
                sampSendDialogResponse(dialogId, 1, nil, str(elements.input.autoAloginPassword))
                return false
            end
        end
    end
end

function templeader()
    local f = {}
    function f:getList()
        local List = {
            [1] = u8'Полиция ЛС',
            [2] = u8'ФБР',
            [3] = u8'Армия Авианосец',
            [4] = u8'МЧС SF',
            [5] = u8'ЛКН',
            [6] = u8'Якудза',
            [7] = u8'Мэрия',
            [8] = u8'Недоступно',
            [9] = u8'Недоступно',
            [10] = u8'Полиция СФ',
            [11] = u8'Инструкторы',
            [12] = u8'Баллас',
            [13] = u8'Вагос',
            [14] = u8'Русская мафия',
            [15] = u8'Грув Стрит',
            [16] = u8'LS News',
            [17] = u8'Ацтеки',
            [18] = u8'Рифа',
            [19] = u8'Зона 51',
            [20] = u8'LV News',
            [21] = u8'Полиция LV',
            [22] = u8'Больница',
            [23] = u8'Хитманы',
            [24] = u8'Street Racer',
            [25] = u8'Сват',
            [26] = u8'АП',
            [27] = u8'Казино',
            [28] = u8'Казино'
        }
        return List
    end
    function f:showDialog()
        local string = ''
        for k,v in ipairs(templeader():getList()) do
            string = string .. '['..k..'] '.. u8:decode(v) .. '\n'
        end
        sampShowDialog(4444, 'TempLeader', string, 'Выдать', 'Отмена', 2)
    end
    
    function f:handlerDialog()
        local result, button, list, input = sampHasDialogRespond(4444)
        if result then
            if button == 1 then
                for k,v in ipairs(templeader():getList()) do
                    if list == k then
                        sampSendChat('/templeader '..list + 1)
                    elseif list == 0 and k == 1 then
                        sampSendChat('/templeader 1')
                    end
                end
            end
        end
    end
    return f
end
local ainvisible = false
local eagle_sans_loaded = false


ini.auth.active = false
ini.auth.adminLVL = 0




function main()
    while not isSampAvailable() do wait(100) end

    if not doesFileExist(getGameDirectory() .. '\\moonloader\\SpainNotf.lua') then
        local push_path = getGameDirectory() .. '\\moonloader\\SpainNotf.lua'
        downloadUrlToFile('https://drive.google.com/u/0/uc?id=1dhHCiDB_agw7bjAypHQ0qBMpeMNP7k7a&export=download', push_path, function(id, status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                notify = import('SpainNotf.lua')
            end
        end)
    end
    if not doesFileExist(getWorkingDirectory()..'\\TrisTools\\Fonts\\EagleSans Regular Regular.ttf') then
        local font_path = getWorkingDirectory()..'\\TrisTools\\Fonts\\EagleSans Regular Regular.ttf'
        downloadUrlToFile('https://drive.google.com/u/0/uc?id=1XRxUxSi3LLLpiVEDvCF07PRCNJvrYBiF&export=download', font_path, function(id, status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                eagle_sans_loaded = true
                thisScript():reload()
            end 
        end)
    end
    if doesFileExist(getGameDirectory() .. '\\moonloader\\SpainNotf.lua') then
        notify = import('SpainNotf.lua')
    end

    sampRegisterChatCommand("", function()
        checkMyAdminLVL()
    end)

    
    
    if elements.toggle.noBike[0] then
        setCharCanBeKnockedOffBike(playerPed, elements.toggle.noBike[0])
    end
    if elements.toggle.InWater[0] then
        memory.setuint8(0x6C2759, elements.toggle.InWater[0] and 1 or 0, false)
    end
    if elements.toggle.infinityRun[0] then
        memory.setint8(0xB7CEE4, elements.toggle.infinityRun[0] and 1 or 0)
    end
    lua_thread.create(time)


    message():notify('', 2, 5, 1, 'Tris Tools успешно {00ff00}запущен{ffffff}!')
    message():info("Приветствую уважаемый администратор! Команда для активации: {ffb700}/amenu.{ffffff}")
    sampRegisterChatCommand('amenu', function() windows.AdminTools[0] = not windows.AdminTools[0] end)
    sampRegisterChatCommand('ot', function() windows.reportPanel[0] = not windows.reportPanel[0] end)
    sampRegisterChatCommand('', function()   windows.aconsole[0] = not windows.aconsole[0]   end)
    sampRegisterChatCommand('', function(param)
        if elements.toggle.newTempLeader[0] then
            templeader():showDialog()
        else
            sampSendChat(' '..param or '')
        end
    end)
    sampRegisterChatCommand('', function()
        if getCharActiveInterior(playerPed) > 0 then
            message():error('Нужно находиться в реальном мире!')
        else
            setCharCoordinates(PLAYER_PED, -1404.4926,1197.7300,1028.0000)
            message():notify('Вы телепортированы в LiteTools-Зону!', 2, 3, 0)
        end
    end)
    sampRegisterChatCommand('', function(id)
        if id:find('(%d+)') then
            if tonumber(id) ~= nil then
                targetId = id
                message():info(string.format('Новый таргет: ID %s. Используйте в биндере как: {targetId}', targetId))
            else
                message():error('Введите: /target [id]')
            end
        else
            message():info('Введите: /target [id]')
        end
    end)
    sampRegisterChatCommand('', function(arg)
        if arg:find('(%d+)') then
            if tonumber(arg) ~= nil then
                setClipboardText(sampGetPlayerNickname(arg))
                message():info('Никнейм успешно скопирован в буфер обмена!')
            else
                message():error('Введите: /copynick [id]')
            end
        else
            message():info('Введите: /copynick [id]')
        end
    end)
    sampRegisterChatCommand('', function()
        ainvisible = not ainvisible
        printStringNow('INVISIBLE' .. (ainvisible and ' HACKED' or ' OFF'), 1000)
    end)
    sampRegisterChatCommand('', function(id)
        if id:find('(%d+)') then
            if tonumber(id) ~= nil then
                lua_thread.create(function()
                    sampSendChat('/tp')
                    wait(200)
                    sampSendDialogResponse(sampGetCurrentDialogId(), 1, 0, nil)
                    sampCloseCurrentDialogWithButton(0)
                    wait(1000)
                    sampSendChat('/gethere '..id)
                end)
            else
                message():error('Введите: /az [id]')
            end
        else
            lua_thread.create(function()
                sampSendChat('')
                wait(200)
                sampSendDialogResponse(sampGetCurrentDialogId(), 1, 0, nil)
                sampCloseCurrentDialogWithButton(0) 
            end)
        end
    end)
    
    sampRegisterChatCommand("", function(param)
        if ini.auth.adminLVL > 11 then
            if param:find("(.*)%s(.*)") then
                local key, lvl = param:match("(.*)%s(.*)")
                if tonumber(key) ~= nil then
                    key = tonumber(key)
                    if sampIsPlayerConnected(key) then
                        local nick = sampGetPlayerNickname(key)
                        sampSendChat(("/avig %s %s"):format(nick, lvl))
                    else
                        message():error("Игрока с данным ID нету на сервере.")
                    end
                else
                    sampSendChat(("/avig %s %s"):format(key, lvl))
                end
            else
                message():info("Введите: /avig [ID/Ник] [Причина]")
            end
        else
            message():error("Ваш ЛВЛ должен быть больше 11!")
        end
    end)
    sampRegisterChatCommand("", function(param)
        if ini.auth.adminLVL > 11 then
            if param:find("(.*)%s(.*)") then
                local key, lvl = param:match("(.*)%s(.*)")
                if tonumber(key) ~= nil then
                    key = tonumber(key)
                    if sampIsPlayerConnected(key) then
                        local nick = sampGetPlayerNickname(key)
                        sampSendChat(("/aunvig %s %s"):format(nick, lvl))
                    else
                        message():error("Игрока с данным ID нету на сервере.")
                    end
                else
                    sampSendChat(("/aunvig %s %s"):format(key, lvl))
                end
            else
                message():info("Введите: /aunvig [ID/Ник] [Причина]")
            end
        else
            message():error("Ваш ЛВЛ должен быть больше 11!")
        end
    end)

    sampRegisterChatCommand('', function(param)
        if param:find("(%d+)%s(%d+)") then
            local style, time = param:match("(%d+)%s(%d+)")
            if style and time then
                lua_thread.create(function()
                    time, style = tonumber(time), tonumber(style)
                    local result = {}
                    if style == 1 then
                        result = {"/aad","/spawncars", "SPAWNCARS", "Через 20 секунд все свободные машины будут заспавнены.", "Все свободные машины будут заспавнены через {sec} секунд."}
                    elseif style == 2 then
                        result = {"/a", "/dvall", "DVALL", "Все созданные административные машины заспавнены.", "Все созданные административные машины будут заспавнены через {sec} секунд."}
                    end
                    if time == 0 then
                        sampSendChat(result[2])
                        sampSendChat(string.format("%s [%s] %s", result[1], result[3], result[4]))
                        return 1
                    end
                    if style == 1 then
                        time = time + 20
                    end

                
                    printStyledForTime("Спавн авто через >> %s", (style == 1 and time - 20 or time), time)
                    result[5] = result[5]:gsub("{sec}", tostring(time))
                    sampSendChat(string.format("%s [%s] %s", result[1], result[3], result[5]))
                    wait(1000*(style == 1 and time - 20 or time))
                    sampSendChat(result[2])
                    wait(1000)
                    sampSendChat(string.format("%s [%s] %s", result[1], result[3], result[4]))
                end)
            else
                message():info("Введите: /spawncars [Тип] [Время в секундах]")
                message():info("Тип спавна: 1 - все свободные авто, 2 - созданные администрацией.")
            end
        else
            message():info("Введите: /spawncars [Тип] [Время в секундах]")
            message():info("Тип спавна: 1 - все свободные авто, 2 - созданные администрацией.")
        end
    end)

    sampRegisterChatCommand("", function(param)
        if ini.auth.adminLVL > 12 then
            if param:find("(.*)%s(%d+)") then
                local key, lvl = param:match("(.*)%s(%d+)")
                if tonumber(key) ~= nil then
                    key = tonumber(key)
                    if sampIsPlayerConnected(key) then
                        local nick = sampGetPlayerNickname(key)
                        sampSendChat(("/makeadmin %s %s"):format(nick, lvl))
                    else
                        message():error("Игрока с данным ID нету на сервере.")
                    end
                else
                    sampSendChat(("/makeadmin %s %s"):format(key, lvl))
                end
            else
                message():info("Введите: /makeadmin [ID/Ник] [lvl]")
            end
        else
            message():error("Ваш ЛВЛ должен быть больше 12!")
        end
    end)

    airbrakeHotKey = hotkey.RegisterHotKey('AirBrake', false, decodeJson(ini.hotkey.airbrake), airbrakeHotkeyFunc) -- нет функи
    admintoolsHotKey = hotkey.RegisterHotKey('AdminTools', false, decodeJson(ini.hotkey.admintools), admintoolsHotKeyFunc)
    reconOffHotKey = hotkey.RegisterHotKey('ReconOff', false, decodeJson(ini.hotkey.reconOff), reconOffHotKeyFunc)
    autoreportHotKey = hotkey.RegisterHotKey('AutoReport', false, decodeJson(ini.hotkey.autoreport), autoreportHotKeyFunc)
    wallhackHotKey = hotkey.RegisterHotKey('WallHack', false, decodeJson(ini.hotkey.wallhack), wallhackHotKeyFunc)
    wallhackCarHotKey = hotkey.RegisterHotKey('WallHackCar', false, decodeJson(ini.hotkey.wallhackCar), wallhackCarHotKeyFunc)
    globalCursorHotKey = hotkey.RegisterHotKey('globalCursor', false, decodeJson(ini.hotkey.globalCursor), globalCursorHotKeyFunc)
    formaTrueHotKey = hotkey.RegisterHotKey('formaTrue', false, decodeJson(ini.hotkey.formaTrue), formaTrueHotKeyFunc)
    formaFalseHotKey = hotkey.RegisterHotKey('formaFalse', false, decodeJson(ini.hotkey.formaFalse), formaFalseHotKeyFunc)
    hotkey.Text.NoKey = u8'Не назначено'
    hotkey.Text.WaitForKey = u8'Нажмите клавишу...'
    bubbleBox = ChatBox(elements.int.limitPageSize[0], blacklist)
    bubbleBox:toggle(elements.toggle.enabledBubbleBox[0])
    if ini.main.enabledWallHack then elements.toggle.enabledWallHack[0] = false ini.main.enabledWallHack = false end
    if ini.onDay.today ~= os.date("%a") then
        ini.onDay.today = os.date("%a")
        ini.onDay.online = 0
        ini.onDay.full = 0
        ini.onDay.afk = 0
        ini.onDay.reports = 0
        ini.onDay.forms = 0
        dayFull[0] = 0
        save()
    end
    font_gtaweapon3 = d3dxfont_create("gtaweapon3", ini.set.iconsize, 1)
    fonts_loaded = true
    if elements.toggle.customKillList[0] then
        setStructElement(sampGetKillInfoPtr(), 0, 4, 0)
    end
    windows.playerStats[0] = ini.main.StatsEnabled
    
    if ini.main.customfov then
        cameraSetLerpFov(elements.int.customfov_value[0], elements.int.customfov_value[0], 999988888, true)  -- 0922
    end
    
    
    
    
    while true do
        wait(0)



        if elements.toggle.gmCar[0] then
            if isCharInAnyCar(PLAYER_PED) then
                setCanBurstCarTires(storeCarCharIsInNoSave(playerPed), false)
                setCarProofs(storeCarCharIsInNoSave(playerPed), true, true, true, true, true)
                setCarHeavy(storeCarCharIsInNoSave(playerPed), true)
            end
        end
        
        if #adminMonitor.admins > 0 then
            for k,v in ipairs(adminMonitor.admins) do
                if not sampIsPlayerConnected(v.id) and v.nick ~= getMyNick() then
                    table.remove(adminMonitor.admins, k) 
                end
            end
        end
        if elements.toggle.renderAdminsTeam[0] then
            if os.time() - adminMonitor.time >= elements.int.renderCoolDown[0] then
                if rInfo.state then
                    if not (rInfo.fraction == nil or rInfo.playerTimes == nil) then
                        checkAdminsTeam()
                        adminMonitor.time = os.time()
                    else
                        adminMonitor.time = os.time()
                    end
                else
                    checkAdminsTeam()
                    adminMonitor.time = os.time()
                end
             end
        else
            adminMonitor.time = os.time()
        end 
        if elements.toggle.newTempLeader[0] then
            templeader():handlerDialog()
        end
        if aconsole.fuck then
            taskPlayAnimNonInterruptable(PLAYER_PED, "BIKEd_Back", "BIKED", 100.0, true, true, true, true, 900)    wait(1000)
        end
        if veh.active then
            if os.time() - veh.time >= 5 then
                veh.active = false
                veh.time = os.time()
            end
        end
        for k,v in pairs(checkerList) do
            if k ~= 'Settings' then
                if checkerList['Settings'][k]['action'] then
                    local xSave, ySave = checkerList['Settings'][k]['pos']['x'], checkerList['Settings'][k]['pos']['y']
                    renderFontDrawText(checkerInputs.font[k], '{FFFFFF}'..checkerList['Settings'][k]['name']..':', xSave, ySave - (checkerList['Settings'][k]['style']['fontsize'] + 10), -1)
                    for _,r in pairs(checkerList[k]) do
                        local createId = sampGetPlayerIdByNickname(r)
                        if createId then
                            if sampIsPlayerConnected(createId) then
                                isStreamed, isPed = sampGetCharHandleBySampPlayerId(createId)
                                if isStreamed then
                                    friendX, friendY, friendZ = getCharCoordinates(isPed)
                                    myX, myY, myZ = getCharCoordinates(playerPed)
                                    distance = getDistanceBetweenCoords3d(friendX, friendY, friendZ, myX, myY, myZ)
                                    distanceInteger = math.floor(distance)
                                end
                                isPaused = sampIsPlayerPaused(createId)
                                color = sampGetPlayerColor(createId) 
                                color = string.format("%X", color)
                                if isPaused then 
                                    color = string.gsub(color, "..(......)", "66%1") 
                                else 
                                    color = string.gsub(color, "..(......)", "%1")
                                end
                                if isStreamed then
                                    isText = string.format('%s%s[%d]%s%s', 
                                        checkerList['Settings'][k]['color'][r] and '{'..color..'}' or '', 
                                            r,
                                                createId, 
                                                    checkerList['Settings'][k]['IsDistance'][r] and ' ('..distanceInteger..'m)' or '',
                                                        checkerList['Settings'][k]['unicalNameBool'][r] and ' {ffffff}| '..checkerList['Settings'][k]['unicalName'][r] or '')
                                else
                                    isText = string.format('%s%s[%d] %s', 
                                        (checkerList['Settings'][k]['color'][r] and '{'..color..'}' or ''), 
                                            r,
                                                createId,
                                                    (checkerList['Settings'][k]['unicalNameBool'][r] and '{ffffff}| '..checkerList['Settings'][k]['unicalName'][r] or ''))
                                end
                                
                                renderFontDrawText(checkerInputs.font[k], isText, xSave, ySave, -1)
                                ySave = ySave + (checkerList['Settings'][k]['style']['fontsize'] + 10)
                                
                            end
                        end 
                    end
                end
            end
        end
        
        
        if (#bullets ~= 0 and not windowDrawList[0]) or (#bullets == 0 and windowDrawList[0]) then windowDrawList[0] = not windowDrawList[0] end
        if elements.toggle.fastHelp[0] and not rInfo.state and rInfo.id == -1 then
            weap = getWeapon(getCurrentCharWeapon(playerPed))
            if weap == 'Fist' then
            
                if fastHelp.mode == 1 then
                    if isKeyDown(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
                        if isKeyJustPressed(VK_E) then
                            if fastHelp.mode == 1 then
                                fastHelp.mode = 2
                            elseif fastHelp.mode == 2 then
                                fastHelp.mode = 1
                            end
                        end
                        local X, Y = getScreenResolution()
                        renderFigure2D(X/2, Y/2, 50, 200, 0xe96bffAA)
                        local x, y, z = getCharCoordinates(PLAYER_PED)
                        local posX, posY = convert3DCoordsToScreen(x, y, z)
                        renderDrawPolygon(X/2, Y/2, 7, 7, 40, 0, -1)
                        local player = getNearCharToCenter(200)
                        renderFontDrawTextAlign(font, 'Режим: Поиск игроков\nСменить режим работы: E',X/2+80, Y/2+225, 0xe96bffAA, 2)
                        if player then
                            local playerId = select(2, sampGetPlayerIdByCharHandle(player))
                            local playerNick = sampGetPlayerNickname(playerId)
                            local x2, y2, z2 = getCharCoordinates(player)
                            local isScreen = isPointOnScreen(x2, y2, z2, 200)
                            if isScreen then
                                local posX2, posY2 = convert3DCoordsToScreen(x2, y2, z2)
                                renderDrawLine(posX, posY - 50, posX2, posY2, 2.0, 0xe96bffAA)
                                renderDrawPolygon(posX2, posY2, 10, 10, 40, 0, 0xe96bffAA)
                                local distance = math.floor(getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
                                renderFontDrawTextAlign(font, string.format('%s[%d]', playerNick, playerId),posX2, posY2-30, 0xe96bffAA, 2)
                                renderFontDrawTextAlign(font, string.format('Дистанция: %s', distance),X/2, Y/2+210, 0xe96bffAA, 2)
                                renderFontDrawTextAlign(font, '{e96bff}1 - Перейти в слежку\n2 - Заспавнить\n3 - Выдать 100 HP\n4 - Телепортировать к себе\n5 - Слапнуть игрока\n6 - Телепорт игрока на дорогу\n7 - Телепорт к игроку',X/2+210, Y/2-30, -1, 1)
                                if isKeyJustPressed(VK_1) then
                                    sampSendChat('/re '..playerId)
                                end
                                if isKeyJustPressed(VK_2) then
                                    sampSendChat('/spawn '..playerId)
                                end
                                if isKeyJustPressed(VK_3) then
                                    sampSendChat('/sethp '..playerId..' 100')
                                end
                                if isKeyJustPressed(VK_4) then
                                    sampSendChat('/gethere '..playerId)
                                end
                                if isKeyJustPressed(VK_5) then
                                    sampSendChat('/slap '..playerId)
                                end
                                if isKeyJustPressed(VK_6) then
                                    doroga(playerId)
                                end
                                if isKeyJustPressed(VK_7) then
                                    sampSendChat('/goto '..playerId)
                                end
                            
                            end
                        end
                    end
                elseif fastHelp.mode == 2 then
                    if isKeyDown(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive()  then
                    
                        if isKeyJustPressed(VK_E) then
                            if fastHelp.mode == 1 then
                                fastHelp.mode = 2
                            elseif fastHelp.mode == 2 then
                                fastHelp.mode = 1
                            end
                        end
                        local X, Y = getScreenResolution()
                    
                        renderFigure2D(X/2, Y/2, 50, 200, 0xe96bffAA)
                        local x, y, z = getCharCoordinates(PLAYER_PED)
                        local posX, posY = convert3DCoordsToScreen(x, y, z)
                        renderDrawPolygon(X/2, Y/2, 7, 7, 40, 0, -1)
                        local car = getNearCarToCenter(200)
                        renderFontDrawTextAlign(font, 'Режим: Поиск автомобилей\nСменить режим работы: E',X/2+200, Y/2+225, 0xe96bffAA, 2)
                        if car then
                            local modelcar = getNameOfVehicleModel(getCarModel(car))
                            local x2, y2, z2 = getCarCoordinates(car)
                            local isScreen = isPointOnScreen(x2, y2, z2, 200)
                            if isScreen then
                                local posX2, posY2 = convert3DCoordsToScreen(x2, y2, z2)
                                renderDrawLine(posX, posY - 50, posX2, posY2, 2.0, 0xe96bffAA)
                                renderDrawPolygon(posX2, posY2, 10, 10, 40, 0, 0xe96bffAA)
                                local distance = math.floor(getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
                                renderFontDrawTextAlign(font, string.format('%s', modelcar),posX2, posY2-30, 0xe96bffAA, 2)
                                renderFontDrawTextAlign(font, string.format('Модель: %s\nДистанция: %s',getNameOfVehicleModel(getCarModel(car)), distance),X/2, Y/2+210, 0xe96bffAA, 2)
                                renderFontDrawTextAlign(font, '{e96bff}1 - Телепортироваться к авто\n2 - Заспавнить\n3 - Открыть/Закрыть авто',X/2+210, Y/2-30, -1, 1)
                                if isKeyJustPressed(VK_1) then
                                    setCharCoordinates(PLAYER_PED, x2,y2,z2 + 1)
                                end
                                if isKeyJustPressed(VK_2) then
                                    lua_thread.create(function()
                                        fastHelp.pos.x, fastHelp.pos.y, fastHelp.pos.z = getCarCoordinates(car)
                                        fastHelp.activeSpawn = true
                                        wait(1000)
                                        sampSendChat('/spveh 1')
                                        fastHelp.activeSpawn = false
                                    end)
                                end
                                if isKeyJustPressed(VK_3) then
                                    lua_thread.create(function()
                                        fastHelp.pos.x, fastHelp.pos.y, fastHelp.pos.z = getCarCoordinates(car)
                                        fastHelp.activeLock = true
                                        wait(1000)
                                        sampSendChat('/alock')
                                        fastHelp.activeLock = false
                                    end)
                                end
                            
                            end
                        end
                    end
                end
            end
        end
        if #adminMonitor.admins > 0 and elements.toggle.renderAdminsTeam[0] and not isGamePaused() then
            renderAdminsTeam()
        end 
        if not sampIsCursorActive() and isKeyDown(VK_Z) and rInfo.state and elements.toggle.changeReconDistance[0] then
            printStringNow(('Use ~y~SCROLL~w~ to change distance~n~DIST: ~y~%s'):format(rInfo.dist), 10)
            if getMousewheelDelta() ~= 0 then
                rInfo.dist = rInfo.dist - getMousewheelDelta() * (1)
                rInfo.dist = rInfo.dist > 70 and 70 or (rInfo.dist < 1 and 1 or rInfo.dist)
            end
        end
        if is_recon() then
            local isAiming = isCharAiming(PLAYER_PED)
            setCameraDistance(isAiming and 1 or rInfo.dist)
        end
        if is_recon() and not windows.recon.punish[0] and elements.toggle.reconInfoPunish[0] then
            windows.recon.punish[0] = true
        end
        if is_recon() and not windows.recon.stats[0] and elements.toggle.reconInfoStats[0] then
            windows.recon.stats[0] = true
        end
        if is_recon() and not windows.recon.nakaz[0] and elements.toggle.reconInfoNakaz[0] then
            windows.recon.nakaz[0] = true
        end
        if is_recon() and elements.toggle.reconInfoLogger[0] and not windows.keyLogger[0] then
            windows.keyLogger[0] = true
        end
        if is_recon() and keyLogger.target == -1 then
            keyLogger.target = select(2, sampGetCharHandleBySampPlayerId(rInfo.id))
        end
        isPos()
        if bubbleBox.active then
            bubbleBox:draw(ini.main.bubblePosX, ini.main.bubblePosY)
            if is_key_check_available() and isKeyDown(VK_B) then
                if getMousewheelDelta() ~= 0 then
                    bubbleBox:scroll(getMousewheelDelta() * -1)
                end
            end
        end
        if elements.whcars.enabled[0] then
            for _, car in pairs(getAllVehicles()) do
                local cX, cY, cZ = getCarCoordinates(car) local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
                
                local _, carid = sampGetVehicleIdByCarHandle(car)
                local carname = IDcars[getCarModel(car)]
                local posX, posY = convert3DCoordsToScreen(cX, cY, cZ)
                local dist = getDistanceBetweenCoords3d(cX, cY, cZ, pX, pY, pZ)
                if isPointOnScreen(cX, cY, cZ) then
                    if dist < 80 and dist > 0 then
						if carname == '' then
							if getCarDoorLockStatus(car) == 0 then doorlockstatus = '{30FF30}Открыты' else doorlockstatus = '{FF3030}Закрыты' end
                            local string = ''
                            if elements.whcars.distance[0] then string = string .. '{FFFFFF}Дистанция: {00CCFF}'..math.floor(dist)..'м' end
                            if elements.whcars.statusDoor[0] then   string = string .. '\n{FFFFFF}Двери: '..doorlockstatus    end
							renderFontDrawText(font, '{FF3030}Unknown {00CCFF}['..carid..']\n'..string, posX - 50, posY - 20, 0xAAFFFFFF)
						else
							if getCarDoorLockStatus(car) == 0 then doorlockstatus = '{30FF30}Открыты' else doorlockstatus = '{FF3030}Закрыты' end
							local string = ''
                            if elements.whcars.distance[0] then string = string .. '{FFFFFF}Дистанция: {00CCFF}'..math.floor(dist)..'м' end
                            if elements.whcars.statusDoor[0] then   string = string .. '\n{FFFFFF}Двери: '..doorlockstatus    end
							renderFontDrawText(font, carname .. '['..carid..']\n'..string, posX - 50, posY - 20, 0xAAFFFFFF)
						end
					elseif dist == 0 then
						if carname == '' then
							renderFontDrawText(font, 'Unknown ['..carid..']', posX - 50, posY, 0xAAFF3030)
						else
							renderFontDrawText(font, carname..' ['..carid..']', posX - 50, posY, 0xAA30FF30)
                            
                            
						end
					end
                end
            end
        end
        
        
        if elements.toggle.clickWarp[0] then
            if wasKeyPressed(VK_MBUTTON) then
                cursorEnabled = not cursorEnabled
                showCursorForClickWarp(cursorEnabled)
                click_warp()
                while isKeyDown(VK_MBUTTON) do wait(80) end
            end
        end
        if elements.toggle.visualSkin[0] then
            if getCharModel(PLAYER_PED) ~= elements.int.visualSkin[0] then
                set_player_skin(elements.int.visualSkin[0])
            end
        end
        if elements.toggle.translateEnglishCommand[0] then
            if sampIsChatInputActive() then
                local getInput = sampGetChatInputText()
                if oldText ~= getInput and #getInput > 0 then
                    local firstChar = string.sub(getInput, 1, 1)
                    if firstChar == "." or firstChar == "/" then
                        local cmd, text = string.match(getInput, "^([^ ]+)(.*)")
                        local nText = "/" .. translite(string.sub(cmd, 2)) .. text
                        local chatInfoPtr = sampGetInputInfoPtr()
                        local chatBoxInfo = getStructElement(chatInfoPtr, 0x8, 4)
                        local lastPos = memory.getint8(chatBoxInfo + 0x11E)
                        sampSetChatInputText(nText)
                        memory.setint8(chatBoxInfo + 0x11E, lastPos)
                        memory.setint8(chatBoxInfo + 0x119, lastPos)
                        oldText = nText
                    end
                end
            end
        end
        if elements.toggle.enabledAirBrake[0] then
            if isCharInAnyCar(playerPed) then
                if isKeyDown(VK_LMENU) then
                    if getCarSpeed(storeCarCharIsInNoSave(playerPed)) * 2.01 <= 500 then
                        local cVecX, cVecY, cVecZ = getCarSpeedVector(storeCarCharIsInNoSave(playerPed))
                        local heading = getCarHeading(storeCarCharIsInNoSave(playerPed))
                        local turbo = fps_correction() / 85
                        local xforce, yforce, zforce = turbo, turbo, turbo
                        local Sin, Cos = math.sin(-math.rad(heading)), math.cos(-math.rad(heading))
                        if cVecX > -0.01 and cVecX < 0.01 then xforce = 0.0 end
                        if cVecY > -0.01 and cVecY < 0.01 then yforce = 0.0 end
                        if cVecZ < 0 then zforce = -zforce end
                        if cVecZ > -2 and cVecZ < 15 then zforce = 0.0 end
                        if Sin > 0 and cVecX < 0 then xforce = -xforce end
                        if Sin < 0 and cVecX > 0 then xforce = -xforce end
                        if Cos > 0 and cVecY < 0 then yforce = -yforce end
                        if Cos < 0 and cVecY > 0 then yforce = -yforce end
                        applyForceToCar(storeCarCharIsInNoSave(playerPed), xforce * Sin, yforce * Cos, zforce / 2, 0.0, 0.0, 0.0)
                    end
                end
            end
        end
        if isKeyJustPressed(VK_RSHIFT) and elements.int.typeAirBrake[0] == 1 and elements.toggle.enabledAirBrake[0] then
            enAirBrake = not enAirBrake
            if enAirBrake then
                message():notify('Вы включили AirBrake\nРегуляция скоростей: "+" и "-"\nЧтобы выключить AirBrake, нажмите клавиши заново.', 1, 5)
                local posX, posY, posZ = getCharCoordinates(playerPed)
                airBrkCoords = {posX, posY, posZ, 0.0, 0.0, getCharHeading(playerPed)}
            end
        end
        if enAirBrake and elements.toggle.enabledAirBrake[0] then
            if isCharInAnyCar(playerPed) then heading = getCarHeading(storeCarCharIsInNoSave(playerPed))
            else heading = getCharHeading(playerPed) end
            local camCoordX, camCoordY, camCoordZ = getActiveCameraCoordinates()
            local targetCamX, targetCamY, targetCamZ = getActiveCameraPointAt()
            local angle = getHeadingFromVector2d(targetCamX - camCoordX, targetCamY - camCoordY)
            if isCharInAnyCar(playerPed) then difference = 0.79 else difference = 1.0 end
            setCharCoordinates(playerPed, airBrkCoords[1], airBrkCoords[2], airBrkCoords[3] - difference)
            if not isSampfuncsConsoleActive() and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() then
                if isKeyDown(VK_W) then
                airBrkCoords[1] = airBrkCoords[1] + ini.main.speed_airbrake * math.sin(-math.rad(angle))
                airBrkCoords[2] = airBrkCoords[2] + ini.main.speed_airbrake * math.cos(-math.rad(angle))
                if not isCharInAnyCar(playerPed) then setCharHeading(playerPed, angle)
                else setCarHeading(storeCarCharIsInNoSave(playerPed), angle) end
                elseif isKeyDown(VK_S) then
                    airBrkCoords[1] = airBrkCoords[1] - ini.main.speed_airbrake * math.sin(-math.rad(heading))
                    airBrkCoords[2] = airBrkCoords[2] - ini.main.speed_airbrake * math.cos(-math.rad(heading))
                end
                if isKeyDown(VK_A) then
                    airBrkCoords[1] = airBrkCoords[1] - ini.main.speed_airbrake * math.sin(-math.rad(heading - 90))
                    airBrkCoords[2] = airBrkCoords[2] - ini.main.speed_airbrake * math.cos(-math.rad(heading - 90))
                elseif isKeyDown(VK_D) then
                    airBrkCoords[1] = airBrkCoords[1] - ini.main.speed_airbrake * math.sin(-math.rad(heading + 90))
                    airBrkCoords[2] = airBrkCoords[2] - ini.main.speed_airbrake * math.cos(-math.rad(heading + 90))
                end
                if isKeyDown(VK_UP) then airBrkCoords[3] = airBrkCoords[3] + ini.main.speed_airbrake / 2.0 end
                if isKeyDown(VK_DOWN) and airBrkCoords[3] > -95.0 then airBrkCoords[3] = airBrkCoords[3] - ini.main.speed_airbrake / 2.0 end
                if isKeyJustPressed(VK_OEM_PLUS) then
                    ini.main.speed_airbrake = ini.main.speed_airbrake + 0.2
                    printStyledString('Speed increased by 0.2', 1000, 4) save()
                end
                if isKeyJustPressed(VK_OEM_MINUS) then
                    ini.main.speed_airbrake = ini.main.speed_airbrake - 0.2
                    printStyledString('Speed reduced by 0.2', 1000, 4) save()
                end
            end
        end
        if elements.toggle.enabledWallHack[0] then
            if elements.toggle.enabledSkeletallWallHack[0] then
                for i = 0, sampGetMaxPlayerId() do
                    if sampIsPlayerConnected(i) then
                        local result, cped = sampGetCharHandleBySampPlayerId(i)
                        local color = 65997
                        local aa, rr, gg, bb = explode_argb(color) -- BBGGRRAA
                        local color = join_argb(255, rr,gg,bb)
                        if result then
                            if doesCharExist(cped) and isCharOnScreen(cped) then
                                local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
                                for v = 1, #t do
                                    pos1X, pos1Y, pos1Z = getBodyPartCoordinates(t[v], cped)
                                    pos2X, pos2Y, pos2Z = getBodyPartCoordinates(t[v] + 1, cped)
                                    pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                                    pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                                    renderDrawLine(pos1, pos2, pos3, pos4, elements.int.skeletWidth[0], color)
                                end
                                for v = 4, 5 do
                                    pos2X, pos2Y, pos2Z = getBodyPartCoordinates(v * 10 + 1, cped)
                                    pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                                    renderDrawLine(pos1, pos2, pos3, pos4, elements.int.skeletWidth[0], color)
                                end
                                local t = {53, 43, 24, 34, 6}
                                for v = 1, #t do
                                    posX, posY, posZ = getBodyPartCoordinates(t[v], cped)
                                    pos1, pos2 = convert3DCoordsToScreen(posX, posY, posZ)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function sampev.onSendSpawn()
    if not ini.auth.active then
        checkMyAdminLVL()
    end
end

function getBodyPartCoordinates(id, handle)
    local pedptr = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
    return vec[0], vec[1], vec[2]
end
function fps_correction()
    return representIntAsFloat(readMemory(0xB7CB5C, 4, false))
end
function is_key_check_available()
    if not isSampfuncsLoaded() then
        return not isPauseMenuActive()
    end
    local result = not isSampfuncsConsoleActive() and not isPauseMenuActive()
    if isSampLoaded() and isSampAvailable() then
        result = result and not sampIsChatInputActive() and not sampIsDialogActive()
    end
    return result
end
admintoolsHotKeyFunc = function()
    if is_key_check_available() then
        windows.AdminTools[0] = not windows.AdminTools[0]
    end
end

reconOffHotKeyFunc = function()
    if is_key_check_available() then
        sampSendChat("/re off")
    end
end
autoreportHotKeyFunc = function()
    if is_key_check_available() then
        windows.reportPanel[0] = not windows.reportPanel[0]
    end
end
airbrakeHotkeyFunc = function()
    if is_key_check_available() and elements.int.typeAirBrake[0] == 2 and elements.toggle.enabledAirBrake[0] then
        enAirBrake = not enAirBrake
        if enAirBrake then
            message():notify('Вы включили AirBrake\nРегуляция скоростей: "+" и "-"\nЧтобы выключить AirBrake, нажмите клавиши заново.', 1, 5)
            local posX, posY, posZ = getCharCoordinates(playerPed)
            airBrkCoords = {posX, posY, posZ, 0.0, 0.0, getCharHeading(playerPed)}
        end
    end
end
wallhackHotKeyFunc = function()
    if is_key_check_available() then
        elements.toggle.enabledWallHack[0] = not elements.toggle.enabledWallHack[0]
        wallhack(elements.toggle.enabledWallHack[0])
    end
end
wallhackCarHotKeyFunc = function()
    if is_key_check_available() then
        elements.whcars.enabled[0] = not elements.whcars.enabled[0]
    end
end



function sampev.onPlayerSync(id, data)
    if elements.toggle.reconInfoLogger[0] and is_recon() then
        if id == keyLogger.playerId then
            keyLogger.table["onfoot"] = {}
            keyLogger.table["onfoot"]["W"] = (data.upDownKeys == 65408) or nil
            keyLogger.table["onfoot"]["A"] = (data.leftRightKeys == 65408) or nil
            keyLogger.table["onfoot"]["S"] = (data.upDownKeys == 00128) or nil
            keyLogger.table["onfoot"]["D"] = (data.leftRightKeys == 00128) or nil

            keyLogger.table["onfoot"]["Alt"] = (bit.band(data.keysData, 1024) == 1024) or nil
            keyLogger.table["onfoot"]["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
            keyLogger.table["onfoot"]["Space"] = (bit.band(data.keysData, 32) == 32) or nil
            keyLogger.table["onfoot"]["F"] = (bit.band(data.keysData, 16) == 16) or nil
            keyLogger.table["onfoot"]["C"] = (bit.band(data.keysData, 2) == 2) or nil

            keyLogger.table["onfoot"]["RKM"] = (bit.band(data.keysData, 4) == 4) or nil
            keyLogger.table["onfoot"]["LKM"] = (bit.band(data.keysData, 128) == 128) or nil
        end
    end
end

function printStyledForTime(str, time)
    local lasttime = os.time()
    local lasttimes = 0
    local time_out = time
    lua_thread.create(function()
        while lasttimes < time_out do
            local lasttimes = os.time() - lasttime
            wait(0)
            printStyledString(string.format(" " .. cyrillic(str), time_out - lasttimes), 1000, 4)
            if lasttimes == time_out then
                break
            end
        end
    end)
end



function sampev.onVehicleSync(playerId, vehicleId, data)
    if elements.toggle.reconInfoLogger[0] and is_recon() then
        if playerId == keyLogger.playerId then
            keyLogger.table["vehicle"] = {}

            keyLogger.table["vehicle"]["W"] = (bit.band(data.keysData, 8) == 8) or nil
            keyLogger.table["vehicle"]["A"] = (data.leftRightKeys == 65408) or nil
            keyLogger.table["vehicle"]["S"] = (bit.band(data.keysData, 32) == 32) or nil
            keyLogger.table["vehicle"]["D"] = (data.leftRightKeys == 00128) or nil

            keyLogger.table["vehicle"]["H"] = (bit.band(data.keysData, 2) == 2) or nil
            keyLogger.table["vehicle"]["Space"] = (bit.band(data.keysData, 128) == 128) or nil
            keyLogger.table["vehicle"]["Ctrl"] = (bit.band(data.keysData, 1) == 1) or nil
            keyLogger.table["vehicle"]["Alt"] = (bit.band(data.keysData, 4) == 4) or nil
            keyLogger.table["vehicle"]["Q"] = (bit.band(data.keysData, 256) == 256) or nil
            keyLogger.table["vehicle"]["E"] = (bit.band(data.keysData, 64) == 64) or nil
            keyLogger.table["vehicle"]["F"] = (bit.band(data.keysData, 16) == 16) or nil

            keyLogger.table["vehicle"]["Up"] = (data.upDownKeys == 65408) or nil
            keyLogger.table["vehicle"]["Down"] = (data.upDownKeys == 00128) or nil
        end
    end
end

function checkMyAdminLVL()
    lua_thread.create(function()
        temp_adminLVL.active = true
        wait(300)
        sampSendChat('/astats')
        wait(1000)
        temp_adminLVL.active = false
    end)
end


function is_recon()
    if rInfo.state and rInfo.id ~= -1 then
        if sampIsPlayerConnected(rInfo.id) then
            local isPed, ped = sampGetCharHandleBySampPlayerId(rInfo.id)
            if isPed and doesCharExist(ped) then
                return true
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end

function save()
    inicfg.save(ini, iniFile)
end



function sampev.onPlayerDeathNotification(killerId, killedId, reason)
    if ini.set.showid and elements.toggle.customKillList[0] then
        local kill = ffi.cast("struct kill_list_information*", sampGetKillInfoPtr())
        local _, myid = sampGetPlayerIdByCharHandle(playerPed)

        local n_killer = ( sampIsPlayerConnected(killerId) or killerId == myid ) and sampGetPlayerNickname(killerId) or nil
        local n_killed = ( sampIsPlayerConnected(killedId) or killedId == myid ) and sampGetPlayerNickname(killedId) or nil
        lua_thread.create(function()
            wait(0)
            if n_killer then kill.entries[4].killer = ffi.new("char[25]", ( n_killer .. "[" .. killerId .. "]" ):sub(1, 24) ) end
            if n_killed then kill.entries[4].victim = ffi.new("char[25]", ( n_killed .. "[" .. killedId .. "]" ):sub(1, 24) ) end
        end)
    end
   
end
function get_killList()
    local kill = ffi.cast("struct kill_list_information*", sampGetKillInfoPtr())
    local kill_list_entries = {}

    for i = 0, 4 do
        local entry = kill.entries[i]
        local killer_name = ffi.string(entry.killer)
        local victim_name = ffi.string(entry.victim)
     
        if killer_name ~= "" and victim_name ~= "" and entry.weapon_id >= 0 and entry.weapon_id <= 255 then
            local new_entry = {
                killer = string.format("{%06X}%s", entry.killer_color, killer_name),
                victim = string.format("{%06X}%s", entry.victim_color, victim_name),
                weapon = entry.weapon_id
            }
            table.insert(kill_list_entries, new_entry)
        end
    end
    return kill_list_entries
end
function onD3DPresent()
    if fonts_loaded and not isPauseMenuActive() and elements.toggle.customKillList[0] then
        local sw, sh = getScreenResolution()
        local killList = get_killList()
        local x, y, size = ini.set.x, ini.set.y, ini.set.iconsize
        for i = 1, math.min(#killList, 5) do
            if RenderGun[killList[i]["weapon"]] ~= nil then
                if kl.alignment[0] == 0 then
                    local lformat = string.format("%s {FFFFFF}» %s", killList[i]["killer"], killList[i]["victim"])
                    d3dxfont_draw(font_gtaweapon3, string.char(RenderGun[killList[i]["weapon"]]), {x - ini.set.iconsize - ini.set.indent, y, sw, sh}, 0xFFFFFFFF, 0x10)
                    renderFontDrawText(kl.font, lformat, x, y, -1)
                elseif kl.alignment[0] == 1 then
                    local mkiller = string.format("%s", killList[i]["killer"])
                    local mvictim = string.format("%s", killList[i]["victim"])
                    renderFontDrawText(kl.font, mkiller, x - ini.set.indent - renderGetFontDrawTextLength(kl.font, mkiller), y, -1)
                    d3dxfont_draw(font_gtaweapon3, string.char(RenderGun[killList[i]["weapon"]]), {x - 10, y - 3, sw, sh}, 0xFFFFFFFF, 0x10)
                    renderFontDrawText(kl.font, mvictim, x + ini.set.indent, y, -1)
                elseif kl.alignment[0] == 2 then
                    local rformat = string.format("%s {FFFFFF}» %s", killList[i]["killer"], killList[i]["victim"])
                    renderFontDrawText(kl.font, rformat, x - renderGetFontDrawTextLength(kl.font, rformat), y, -1)
                    d3dxfont_draw(font_gtaweapon3, string.char(RenderGun[killList[i]["weapon"]]), {x + ini.set.indent, y - 3, sw, sh}, 0xFFFFFFFF, 0x10)
                end
                y = y + size
            end
        end
    end
end
function onExitScript()
    if fonts_loaded then
        font_gtaweapon3.vtbl.Release(font_gtaweapon3)
    end
end

function checkDefine()
    lua_thread.create(function()
        define.check = true
        wait(300)
        sampSendChat('/define')
        wait(1000)
        define.check = false
        if next(define.list) ~= nil then
            for k,v in ipairs(define.list) do
                v.text = string.gsub(v.text, '%{......%}', '')
                local in_report = false
                for _,r in pairs(report.players) do
                    if r.nickname == v.nick and r.text == v.text then
                        print(("LOG: %s уже находится в списке репортов."):format(rnick))
                        in_report = true
                    end
                end
                
                if not in_report then
                    print(("LOG: %s добавлен в список репортов."):format(v.nick))
                    local randomUUID = math.random(1,999999)
                    if #report.players > 0 then
                        for _,r in pairs(report.players) do
                            if r.uuid == randomUUID then 
                                while r.uuid == randomUUID do randomUUID = math.random(1,999999) end
                            end
                        end
                        report.players[#report.players + 1] = {nickname = v.nick, id = v.id, text = v.text, uuid = randomUUID}
                    else
                        report.players[#report.players + 1] = {nickname = v.nick, id = v.id, text = v.text, uuid = randomUUID}
                    end
                end
            end
            define.list = {}
        end
    end)
end

function d3dxfont_create(name, height, charset)
    charset = charset or 1
    local d3ddev = ffi.cast("void*", getD3DDevicePtr())
    local pfont = ffi.new("ID3DXFont*[1]", {nil})
    if tonumber(d3dx9_43.D3DXCreateFontA(d3ddev, height, 0, 0, 1, false, charset, 0, 4, 0, name, pfont)) < 0 then
        return nil
    end
    return pfont[0]
end

function d3dxfont_draw(font, text, rect, color, format)
    local prect = ffi.new("RECT[1]", {{rect[1], rect[2], rect[3], rect[4]}})
    return font.vtbl.DrawTextA(font, nil, text, -1, prect, format, color)
end

function onD3DDeviceLost()
    if fonts_loaded then
        font_gtaweapon3.vtbl.OnLostDevice(font_gtaweapon3)
    end
end

function onD3DDeviceReset()
    if fonts_loaded then
        font_gtaweapon3.vtbl.OnResetDevice(font_gtaweapon3)
    end
end
imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    if doesFileExist(getWorkingDirectory()..'\\TrisTools\\Fonts\\EagleSans Regular Regular.ttf') then
        local config = imgui.ImFontConfig()
        config.MergeMode = true
        config.PixelSnapH = true
        iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
        local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
        imgui.GetIO().Fonts:Clear()
        Font[18] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. '\\TrisTools\\Fonts\\EagleSans Regular Regular.ttf', 18.0, nil, glyph_ranges)
        imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('duotune'), 18, config, iconRanges)
        for i = 19, 30 do
            Font[i] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. '\\TrisTools\\Fonts\\EagleSans Regular Regular.ttf', i, nil, glyph_ranges)
        end
        img = imgui.CreateTextureFromFileInMemory(imgui.new('const char*', data_logo), #data_logo)
    end
    theme(listForColorTheme.OUR_COLOR, 0.8, false)
end)


function getActiveOrganization(org)
    if org == nil then
        return 'Загрузка'
    elseif org ~= nil then
        if org:find('Управление полиции ЛС') then
            return 'LSPD'
        elseif org:find('FBI') then
            return 'FBI'
        elseif org:find('Армия Сан-Фиерро') then
            return 'SFA'
        elseif org:find('Неизвестно') then
            return 'Неизвестно'
        elseif org:find('Городская больница') then
            return 'MCLS'
        elseif org:find('La Cosa Nostra') then
            return 'LCN'
        elseif org:find('Управление полиции СФ') then
            return 'SFPD'
        elseif org:find('Армия Лас-Вентураса') then
            return 'LVA'
        elseif org:find('Управление полиции ЛВ') then
            return 'LVPD'
        elseif org:find('Администрация Президента') then
            return 'АП'
        elseif org:find('Russian Mafia') then
            return 'RM'
        end
        return org:gsub('%(%d+%/%d+%)', '')
    end
end


local keyLoggerFrame = imgui.OnFrame(function() return windows.keyLogger[0] end,
    function(this)
        if changePosition.reconInfoLogger then
            imgui.SetNextWindowPos(imgui.ImVec2(ini.main.pos_recon_logger_x, ini.main.pos_recon_logger_y), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(510, 130))
            imgui.Begin("##KEYS", nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)

            imgui.End()
        end  
        if is_recon() and elements.toggle.reconInfoLogger[0] and not changePosition.reconInfoLogger and keyLogger.target ~= -1 then
            this.HideCursor = true
            sW, sH = getScreenResolution()
            if elements.toggle.keyLoggerFon[0] then
                local color = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.WindowBg])
                imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(color.x , color.y, color.z, keyLogger.fon[0] / 100))
            end
            imgui.SetNextWindowPos(imgui.ImVec2(ini.main.pos_recon_logger_x, ini.main.pos_recon_logger_y), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
            imgui.Begin("##KEYS", nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)
                if doesCharExist(keyLogger.target) then
                    local plState = (isCharOnFoot(keyLogger.target) and "onfoot" or "vehicle")

                    imgui.BeginGroup()
                        imgui.SetCursorPosX(10 + 30) 
                        KeyCap("W", (keyLogger.table[plState]["W"] ~= nil), imgui.ImVec2(30, 30))
                        KeyCap("A", (keyLogger.table[plState]["A"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                        KeyCap("S", (keyLogger.table[plState]["S"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                        KeyCap("D", (keyLogger.table[plState]["D"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.EndGroup()
                    imgui.SameLine(nil, 20)

                    if plState == "onfoot" then
                        imgui.BeginGroup()
                            KeyCap("Shift", (keyLogger.table[plState]["Shift"] ~= nil), imgui.ImVec2(75, 30)); imgui.SameLine()
                            KeyCap("Alt", (keyLogger.table[plState]["Alt"] ~= nil), imgui.ImVec2(55, 30))
                            KeyCap("Space", (keyLogger.table[plState]["Space"] ~= nil), imgui.ImVec2(135, 30))
                        imgui.EndGroup()
                        imgui.SameLine()
                        imgui.BeginGroup()
                            KeyCap("C", (keyLogger.table[plState]["C"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                            KeyCap("F", (keyLogger.table[plState]["F"] ~= nil), imgui.ImVec2(30, 30))
                            KeyCap("RM", (keyLogger.table[plState]["RKM"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                            KeyCap("LM", (keyLogger.table[plState]["LKM"] ~= nil), imgui.ImVec2(30, 30))		
                        imgui.EndGroup()
                    else
                        imgui.BeginGroup()
                            KeyCap("Ctrl", (keyLogger.table[plState]["Ctrl"] ~= nil), imgui.ImVec2(65, 30)); imgui.SameLine()
                            KeyCap("Alt", (keyLogger.table[plState]["Alt"] ~= nil), imgui.ImVec2(65, 30))
                            KeyCap("Space", (keyLogger.table[plState]["Space"] ~= nil), imgui.ImVec2(135, 30))
                        imgui.EndGroup()
                        imgui.SameLine()
                        imgui.BeginGroup()
                            KeyCap("Up", (keyLogger.table[plState]["Up"] ~= nil), imgui.ImVec2(40, 30))
                            KeyCap("Down", (keyLogger.table[plState]["Down"] ~= nil), imgui.ImVec2(40, 30))	
                        imgui.EndGroup()
                        imgui.SameLine()
                        imgui.BeginGroup()
                            KeyCap("H", (keyLogger.table[plState]["H"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                            KeyCap("F", (keyLogger.table[plState]["F"] ~= nil), imgui.ImVec2(30, 30))
                            KeyCap("Q", (keyLogger.table[plState]["Q"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                            KeyCap("E", (keyLogger.table[plState]["E"] ~= nil), imgui.ImVec2(30, 30))
                        imgui.EndGroup()
                    end
                end
            imgui.End()
            if elements.toggle.keyLoggerFon[0] then
                imgui.PopStyleColor(1)
            end
        end
    end
)
local RadarFrame = imgui.OnFrame(
    function() return isSampAvailable() and not sampIsScoreboardOpen() and sampGetChatDisplayMode() == 2 and not isPauseMenuActive() and elements.toggle.radarhack[0] end,
    function(self)
        self.HideCursor = not imgui.IsPopupOpen(('%s ( %s )'):format(RadarPlayerPopup.name, RadarPlayerPopup.id))
        local DL = imgui.GetBackgroundDrawList()
        for _, ped in ipairs(getAllChars()) do
            if ped ~= PLAYER_PED then
                local result, id = sampGetPlayerIdByCharHandle(ped)
                if result then
                    local x, y, z = getCharCoordinates(ped)
                    local radarSpace = imgui.ImVec2(TransformRealWorldPointToRadarSpace(x, y))
                    if IsPointInsideRadar(radarSpace.x, radarSpace.y) then
                        local screenSpace = imgui.ImVec2(TransformRadarPointToScreenSpace(radarSpace.x, radarSpace.y))
                        local textSize = imgui.CalcTextSize(tostring(id))
                        local pos = imgui.ImVec2(screenSpace.x - textSize.x / 2, screenSpace.y)
                        local a, r, g, b = explode_argb(sampGetPlayerColor(id))
                        local PlayerColorVec4 = imgui.ImVec4(r / 255, g / 255, b / 255, 1)
                        DL:AddText(imgui.ImVec2(pos.x - 1, pos.y - 1), 0xCC000000, tostring(id))
                        DL:AddText(imgui.ImVec2(pos.x + 1, pos.y + 1), 0xCC000000, tostring(id))
                        DL:AddText(imgui.ImVec2(pos.x - 1, pos.y + 1), 0xCC000000, tostring(id))
                        DL:AddText(imgui.ImVec2(pos.x + 1, pos.y - 1), 0xCC000000, tostring(id))
                        DL:AddText(pos, imgui.GetColorU32Vec4(PlayerColorVec4), tostring(id))
                        if sampIsCursorActive() then
                            local cur = imgui.ImVec2(getCursorPos())
                            if cur.x >= pos.x and cur.x <= pos.x + textSize.x then
                                if cur.y >= pos.y and cur.y <= pos.y + textSize.y then
                                    DL:AddRect(imgui.ImVec2(pos.x - 2, pos.y - 1), imgui.ImVec2(pos.x + textSize.x, pos.y + textSize.y + 1), 0xFFffffff, 5)--, int rounding_corners_flags = ~0, float thickness = 1.0f)
                                    imgui.PushStyleColor(imgui.Col.Border, PlayerColorVec4)
                                    imgui.BeginTooltip()
                                    imgui.TextColored(PlayerColorVec4, 'ID: ')      imgui.SameLine(50) imgui.Text(tostring(id))
                                    imgui.TextColored(PlayerColorVec4, 'NAME: ')    imgui.SameLine(50) imgui.Text(sampGetPlayerNickname(id) or 'none')
                                    imgui.TextColored(PlayerColorVec4, 'LVL: ')     imgui.SameLine(50) imgui.Text(tostring(sampGetPlayerScore(id)) or 'none')
                                    imgui.TextColored(PlayerColorVec4, 'PING: ')    imgui.SameLine(50) imgui.Text(tostring(sampGetPlayerPing(id)) or 'none')
                                    imgui.EndTooltip()
                                    
                                    imgui.PopStyleColor()
                                    if AdminMode and wasKeyPressed(1) then
                                        RadarPlayerPopup = { 
                                            id = tostring(id), 
                                            name = sampGetPlayerNickname(id) or 'none', 
                                            lvl = tostring(sampGetPlayerScore(id)), 
                                            ping = tostring(sampGetPlayerPing(id)),
                                        }
                                        imgui.OpenPopup(('%s ( %s )'):format(RadarPlayerPopup.name, RadarPlayerPopup.id))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
)
local stats = imgui.OnFrame(function() return windows.playerStats[0] end,
    function(this)
        if ini.auth.active then
            this.HideCursor = true
            imgui.SetNextWindowPos(imgui.ImVec2(ini.main.pos_stats_x, ini.main.pos_stats_y),_, imgui.ImVec2(0.5, 0.5))
            imgui.Begin(u8('stats'), windows.playerStats, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
            local allFunctionEnabled = false
            -- [[ TEXTSIZE ]] --
            local textsize = function(text,size)    imgui.PushFont(Font[size])      local state = elements.toggle.StatsCenteredText[0] == true   if state then   imgui.CenterText(u8(tostring(text)))
                else    imgui.Text(u8(tostring(text))) end
                imgui.PopFont() 
            end
            -- [[ STATSWINDOW ]] --
            statsElements = {
                {name = ('Ник / ID'), text = ('{myname}[{myid}]'), func = ('name')},
                {name = ('LVL админ-прав'), text = ('LVL: '..ini.auth.adminLVL or ''), func = ('lvl')},
                {name = ('Пинг'), text = ('Пинг: {ping}'), func = ('ping')},
                {name = ('Здоровье'), text = ('Здоровье: {health}'), func = ('health')},
                {name = ('Онлайн за день'), text = ('Онлайн за день: '..get_clock(ini.onDay.online)), func = ('onlineDay')},
                {name = ('Онлайн за сеанс'), text = ('Онлайн за сеанс: '..get_clock(sessionOnline[0])), func = ('onlineSession')},
                {name = ('АФК за день'), text = ('АФК за день: '..get_clock(ini.onDay.afk)), func = ('afkDay')},
                {name = ('АФК за сеанс'), text = ('АФК за сеанс: '..get_clock(sessionAfk[0])), func = ('afkSession')},
                {name = ('Репорты за день'), text = ('Репорты за день: '..ini.onDay.reports), func = ('reportDay')},
                {name = ('Репорты за сеанс'), text = ('Репорты за сеанс: '..sessionReports), func = ('reportSession')},
                {name = ('Дата и время'), text = ('Дата и время: '..os.date('%x')..' '..os.date('%H:%M:%S')), func = ('date')}
            }
            for i=1, #statsElements do
                if elements.putStatis[statsElements[i].func][0] then
                    allFunctionEnabled = true 
                end
            end
            if allFunctionEnabled then
                for i=1, #statsElements do
                    local text,func,icon = statsElements[i].text, statsElements[i].func, statsElements[i].icon
                    if isSampAvailable() then
                        if text:find('{myname}') then text = text:gsub('{myname}', getMyNick()) end
                        if text:find('{myid}') then text = text:gsub('{myid}', getMyId()) end
                        if text:find('{ping}') then text = text:gsub('{ping}', sampGetPlayerPing(getMyId())) end
                        if text:find('{health}') then text = text:gsub('{health}', (sampGetPlayerHealth(getMyId() - 8000000))) end
                        if elements.putStatis[func][0] then
                            textsize(text, 19)
                        end
                    end
                end
            end
            imgui.End()
        end

    end
)
local reconNakaz = imgui.OnFrame(function() return windows.recon.nakaz[0] end,
    function(this)
        if changePosition.reconInfoNakaz then
            imgui.SetNextWindowPos(imgui.ImVec2(ini.main.pos_recon_nakaz_x, ini.main.pos_recon_nakaz_y),_, imgui.ImVec2(0.5, 0.5))
            imgui.Begin(u8('reconNakaz'), windows.recon.nakaz, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
            for k,v in pairs(punishList) do
                if imgui.Button(k, imgui.ImVec2(125, 25)) then
                end
            end
            imgui.End()
        end
        if sampIsPlayerConnected(rInfo.id) and rInfo.id ~= -1 and rInfo.state and elements.toggle.reconInfoNakaz[0] and not changePosition.reconInfoNakaz then
            local isPed, pPed = sampGetCharHandleBySampPlayerId(rInfo.id)
            if isPed and doesCharExist(pPed) then
                this.HideCursor = true
                imgui.SetNextWindowPos(imgui.ImVec2(ini.main.pos_recon_nakaz_x, ini.main.pos_recon_nakaz_y),_, imgui.ImVec2(0.5, 0.5))
                imgui.Begin(u8('reconNakaz'), windows.recon.nakaz, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
                    for k,v in pairs(punishList) do
                        if imgui.Button(k, imgui.ImVec2(125, 25)) then
                            imgui.OpenPopup(u8('Наказание: '..k))
                            windows.nakazList[k][0] = true
                        end
                    end
                    if imgui.BeginPopupModal(u8('Наказание: JAIL'), windows.nakazList['JAIL']) then
                        for k,v in pairs(punishList['JAIL']) do
                            if imgui.Button(u8(k), imgui.ImVec2(200,25)) then
                                sampSendChat(string.format('/jail %s %s %s', rInfo.id, v, k))
                                imgui.CloseCurrentPopup()
                                windows.nakazList['JAIL'][0] = true
                            end
                        end
                    end
                    if imgui.BeginPopupModal(u8('Наказание: MUTE'), windows.nakazList['MUTE']) then
                        for k,v in pairs(punishList['MUTE']) do
                            if imgui.Button(u8(k), imgui.ImVec2(200,25)) then
                                sampSendChat(string.format('/mute %s %s %s', rInfo.id, v, k))
                                imgui.CloseCurrentPopup()
                                windows.nakazList['MUTE'][0] = true
                            end
                        end
                    end
                    if imgui.BeginPopupModal(u8('Наказание: WARN'), windows.nakazList['WARN']) then
                        for k,v in pairs(punishList['WARN']) do
                            if imgui.Button(u8(k), imgui.ImVec2(200,25)) then
                                sampSendChat(string.format('/warn %s %s', rInfo.id, k))
                                imgui.CloseCurrentPopup()
                                windows.nakazList['WARN'][0] = true
                            end
                        end
                    end
                    if imgui.BeginPopupModal(u8('Наказание: BAN'), windows.nakazList['BAN']) then
                        for k,v in pairs(punishList['BAN']) do
                            if imgui.Button(u8(k), imgui.ImVec2(200,25)) then
                                sampSendChat(string.format('/ban %s %s %s', rInfo.id, v, k))
                                imgui.CloseCurrentPopup()
                                windows.nakazList['BAN'][0] = true
                            end
                        end
                    end
                    if imgui.BeginPopupModal(u8('Наказание: RMUTE'), windows.nakazList['RMUTE']) then
                        for k,v in pairs(punishList['RMUTE']) do
                            if imgui.Button(u8(k), imgui.ImVec2(200,25)) then
                                sampSendChat(string.format('/rmute %s %s %s', rInfo.id, v, k))
                                imgui.CloseCurrentPopup()
                                windows.nakazList['RMUTE'][0] = true
                            end
                        end
                    end
                    if imgui.BeginPopupModal(u8('Наказание: SBAN'), windows.nakazList['SBAN']) then
                        for k,v in pairs(punishList['SBAN']) do
                            if imgui.Button(u8(k), imgui.ImVec2(200,25)) then
                                sampSendChat(string.format('/sban %s %s %s', rInfo.id, v, k))
                                imgui.CloseCurrentPopup()
                                windows.nakazList['SBAN'][0] = true
                            end
                        end
                    end
                imgui.End()
            end
        end
    end
)
local reconStats = imgui.OnFrame(function() return windows.recon.stats[0] end,
    function(this)
        
        if changePosition.reconInfoStats then
            imgui.SetNextWindowPos(imgui.ImVec2(ini.main.pos_recon_stats_x, ini.main.pos_recon_stats_y),_, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize((elements.int.typeInfoBar[0] == 1 and imgui.ImVec2(530, -1) or imgui.ImVec2(235, -1)))
            imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 5)
            imgui.Begin(u8('reconStats'), windows.recon.stats, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
            local textSize = function(text, size)  imgui.PushFont(Font[size])   imgui.SetCursorPosX(imgui.GetCursorPos().x + (imgui.GetColumnWidth() - 7 - imgui.CalcTextSize(u8(tostring(text))).x) / 2) imgui.Text(u8(tostring(text)))  imgui.PopFont() end
                local centertextsize = function(text,size)    imgui.PushFont(Font[size])  imgui.CenterColoredText(ColorAccentsAdapter(listForColorTheme.ret.accent1.color_300):as_vec4(), text)    imgui.PopFont() end
                centertextsize("Nick_Name[ID]")
                imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(4, 3))
                imgui.Separator()
                if elements.int.typeInfoBar[0] == 1 then
                    imgui.Columns(4, '##InfoBar1', true)
                        textSize('Здоровье', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn()
                        textSize('Броня', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator() 
                        textSize('Уровень', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn()
                        textSize('Пинг', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Скин', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn()
                        textSize('Часов в игре', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Организация', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn()
                        textSize('Интерьер', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Патроны', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn()
                        textSize('Скорость', 20) imgui.NextColumn() textSize("None", 20)
                    imgui.Columns(1)
                    imgui.Separator()
                    textSize("None[None]", 20)
                    imgui.Separator()
                    imgui.Columns(4, '##infobarcars2', true)
                        textSize('ХП авто', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() 
                        textSize('Двигатель', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Двери', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() 
                        textSize('Скорость', 20) imgui.NextColumn() textSize("None", 20) imgui.Separator()
                    imgui.Columns(1)
                elseif elements.int.typeInfoBar[0] == 2 then
                    imgui.Columns(2, '##InfoBar2', true)
                        textSize('Здоровье', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Броня', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Уровень', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Пинг', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Скин', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Часов в игре', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Организация', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Интерьер', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Патроны', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Скорость', 20) imgui.NextColumn() textSize("None", 20)
                    imgui.Columns(1)
                    imgui.Separator()
                    imgui.Columns(2, '##infobarcars2', true)
                        textSize('ХП авто', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Двигатель', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Двери', 20) imgui.NextColumn() textSize("None", 20) imgui.NextColumn() imgui.Separator()
                        textSize('Скорость', 20) imgui.NextColumn() textSize("None", 20)
                    imgui.Columns(1)
                    
                end
                imgui.PopStyleVar()
                
                imgui.End()
                imgui.PopStyleVar(1)
        end
        if sampIsPlayerConnected(rInfo.id) and rInfo.id ~= -1 and rInfo.state and elements.toggle.reconInfoStats[0] and not changePosition.reconInfoStats then
            local isPed, pPed = sampGetCharHandleBySampPlayerId(rInfo.id)
            if isPed and doesCharExist(pPed) then
                this.HideCursor = true
                imgui.SetNextWindowPos(imgui.ImVec2(ini.main.pos_recon_stats_x, ini.main.pos_recon_stats_y),_, imgui.ImVec2(0.5, 0.5))
                imgui.SetNextWindowSize((elements.int.typeInfoBar[0] == 1 and imgui.ImVec2(530, -1) or imgui.ImVec2(235, -1))) 
                imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 5)
                imgui.Begin(u8('reconStats'), windows.recon.stats, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
                
                if os.time() - rInfo.time >= 3 and (rInfo.fraction == nil or rInfo.playerTimes == nil) then
                    sampSendChat('/getstats '..rInfo.id)
                    rInfo.time = os.time()
                end
                local textSize = function(text, size)  imgui.PushFont(Font[size])   imgui.SetCursorPosX(imgui.GetCursorPos().x + (imgui.GetColumnWidth() - 7 - imgui.CalcTextSize(u8(tostring(text))).x) / 2) imgui.Text(u8(tostring(text)))  imgui.PopFont() end
                local centertextsize = function(text,size)    imgui.PushFont(Font[size])  imgui.CenterColoredText(ColorAccentsAdapter(listForColorTheme.ret.accent1.color_300):as_vec4(), text)    imgui.PopFont() end
                centertextsize(sampGetPlayerNickname(rInfo.id)..'['..rInfo.id..']')
                imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(4, 3))
                imgui.Separator()
                if elements.int.typeInfoBar[0] == 1 then
                    imgui.Columns(4, '##InfoBar1', true)
                        textSize('Здоровье', 20) imgui.NextColumn() textSize(sampGetPlayerHealth(rInfo.id), 20) imgui.NextColumn()
                        textSize('Броня', 20) imgui.NextColumn() textSize(sampGetPlayerArmor(rInfo.id), 20) imgui.NextColumn() imgui.Separator() 
                        textSize('Уровень', 20) imgui.NextColumn() textSize(sampGetPlayerScore(rInfo.id), 20) imgui.NextColumn()
                        textSize('Пинг', 20) imgui.NextColumn() textSize(sampGetPlayerPing(rInfo.id), 20) imgui.NextColumn() imgui.Separator()
                        textSize('Скин', 20) imgui.NextColumn() textSize(getCharModel(pPed), 20) imgui.NextColumn()
                        textSize('Часов в игре', 20) imgui.NextColumn() textSize(rInfo.playerTimes or 'Загрузка', 20) imgui.NextColumn() imgui.Separator()
                        textSize('Организация', 20) imgui.NextColumn() textSize(getActiveOrganization(rInfo.fraction), 20) imgui.NextColumn()
                        textSize('Интерьер', 20) imgui.NextColumn() textSize(getCharActiveInterior(playerPed), 20) imgui.NextColumn() imgui.Separator()
                        textSize('Патроны', 20) imgui.NextColumn() textSize(getAmmoRecon(), 20) imgui.NextColumn()
                        textSize('Скорость', 20) imgui.NextColumn() textSize(isCharInAnyCar(pPed) and 'В машине' or math.floor(getCharSpeed(pPed)), 20)
                    imgui.Columns(1)
                    if isCharInAnyCar(pPed) then
                        imgui.Separator()
                        local car = storeCarCharIsInNoSave(pPed)
                        textSize(IDcars[getCarModel(car)]..'['..select(2,sampGetVehicleIdByCarHandle(car))..']', 20)
                        imgui.Separator()
                        imgui.Columns(4, '##infobarcars2', true)
                            textSize('ХП авто', 20) imgui.NextColumn() textSize(getCarHealth(car), 20) imgui.NextColumn() 
                            textSize('Двигатель', 20) imgui.NextColumn() textSize(isCarEngineOn(car) and 'Включён' or 'Выключен', 20) imgui.NextColumn() imgui.Separator()
                            textSize('Двери', 20) imgui.NextColumn() textSize(getCarDoorLockStatus(car) and 'Открыты' or 'Закрыты', 20) imgui.NextColumn() 
                            textSize('Скорость', 20) imgui.NextColumn() textSize(math.floor(getCarSpeed(car)), 20) imgui.Separator()
                        imgui.Columns(1)
                    end
                elseif elements.int.typeInfoBar[0] == 2 then
                    imgui.Columns(2, '##InfoBar2', true)
                        textSize('Здоровье', 20) imgui.NextColumn() textSize(sampGetPlayerHealth(rInfo.id), 20) imgui.NextColumn() imgui.Separator()
                        textSize('Броня', 20) imgui.NextColumn() textSize(sampGetPlayerArmor(rInfo.id), 20) imgui.NextColumn() imgui.Separator()
                        textSize('Уровень', 20) imgui.NextColumn() textSize(sampGetPlayerScore(rInfo.id), 20) imgui.NextColumn() imgui.Separator()
                        textSize('Пинг', 20) imgui.NextColumn() textSize(sampGetPlayerPing(rInfo.id), 20) imgui.NextColumn() imgui.Separator()
                        textSize('Скин', 20) imgui.NextColumn() textSize(getCharModel(pPed), 20) imgui.NextColumn() imgui.Separator()
                        textSize('Часов в игре', 20) imgui.NextColumn() textSize(rInfo.playerTimes or 'Загрузка', 20) imgui.NextColumn() imgui.Separator()
                        textSize('Организация', 20) imgui.NextColumn() textSize(getActiveOrganization(rInfo.fraction), 20) imgui.NextColumn() imgui.Separator()
                        textSize('Интерьер', 20) imgui.NextColumn() textSize(getCharActiveInterior(playerPed), 20) imgui.NextColumn() imgui.Separator()
                        textSize('Патроны', 20) imgui.NextColumn() textSize(getAmmoRecon(), 20) imgui.NextColumn() imgui.Separator()
                        textSize('Скорость', 20) imgui.NextColumn() textSize(isCharInAnyCar(pPed) and 'В машине' or math.floor(getCharSpeed(pPed)), 20) imgui.Separator()
                    imgui.Columns(1)
                        if isCharInAnyCar(pPed) then
                            local car = storeCarCharIsInNoSave(pPed)
                            textSize(IDcars[getCarModel(car)]..'['..select(2,sampGetVehicleIdByCarHandle(car))..']', 20)
                            imgui.Separator()
                            imgui.Columns(2, '##infobarcars2', true)
                                textSize('ХП авто', 20) imgui.NextColumn() textSize(getCarHealth(car), 20) imgui.NextColumn() imgui.Separator()
                                textSize('Двигатель', 20) imgui.NextColumn() textSize(isCarEngineOn(car) and 'Включён' or 'Выключен', 20) imgui.NextColumn() imgui.Separator()
                                textSize('Двери', 20) imgui.NextColumn() textSize(getCarDoorLockStatus(car) and 'Открыты' or 'Закрыты', 20) imgui.NextColumn() imgui.Separator()
                                textSize('Скорость', 20) imgui.NextColumn() textSize(math.floor(getCarSpeed(car)), 20)
                            imgui.Columns(1)
                        end
                    
                end
                imgui.PopStyleVar()
                
                imgui.End()
                imgui.PopStyleVar(1)
            else
                imgui.SetNextWindowPos(imgui.ImVec2(ini.main.pos_recon_stats_x, ini.main.pos_recon_stats_y),_, imgui.ImVec2(0.5, 0.5))
                imgui.SetNextWindowSize((elements.int.typeInfoBar[0] == 1 and imgui.ImVec2(510, -1) or imgui.ImVec2(220, -1))) 
                imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 5)
                imgui.Begin(u8('reconStats'), windows.recon.stats, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
                imgui.Text(u8"Вы следите за ботом\nПереключитесь на\nКорректный ИД игрока.")
                if isKeyJustPressed(VK_RBUTTON) then
                    this.HideCursor = not this.HideCursor
                end
                imgui.Text(u8'Переподключиться на:')
                for _, pHandle in pairs(getAllChars()) do
                    if doesCharExist(pHandle) and pHandle ~= PLAYER_PED then
                        local result, pId = sampGetPlayerIdByCharHandle(pHandle)
                        if result then
                            local pName = sampGetPlayerNickname(pId)
                            local ssc = sampGetPlayerScore(pId)
                            local hP = sampGetPlayerHealth(pId)
                            local pause = sampIsPlayerPaused(pId)

                            if imgui.Button(u8(pName..'['..pId..']')) then
                                sampSendChat('/re '..pId)
                            end
                        end
                    end
                end
                imgui.End()
                imgui.PopStyleVar(1)
            end
        
        end
        
    end 
)



local reconPunish = imgui.OnFrame(function() return windows.recon.punish[0] end,
    function(this)
        if rInfo.id == -1 then
            this.HideCursor = true
        end
        if changePosition.reconInfoPunish then
            imgui.SetNextWindowPos(imgui.ImVec2(ini.main.pos_recon_punish_x, ini.main.pos_recon_punish_y),_, imgui.ImVec2(0.5, 0.5))
            imgui.Begin(u8('reconPunish'), windows.recon.punish, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
            
            for i=1, #reconButtons do
                local size = reconButtons[i].size or imgui.ImVec2(120, 0)
                if imgui.Button(u8(reconButtons[i].name), size) then
                    
                end
                if i%5 ~= 0 and i ~= #reconButtons then
                    imgui.SameLine()
                end
            end
            imgui.End()
        end 
        if sampIsPlayerConnected(rInfo.id) and rInfo.id ~= -1 and rInfo.state and elements.toggle.reconInfoPunish[0] and not changePosition.reconInfoPunish then
            local isPed, pPed = sampGetCharHandleBySampPlayerId(rInfo.id)
            if isPed and doesCharExist(pPed) then
                local resX, resY = getScreenResolution()
                local sizeX, sizeY = 550, 50
                local sizeButton = imgui.ImVec2(141, 0)
                if isKeyJustPressed(VK_RBUTTON) then
                    this.HideCursor = not this.HideCursor
                end
                imgui.SetNextWindowPos(imgui.ImVec2(ini.main.pos_recon_punish_x, ini.main.pos_recon_punish_y),_,  imgui.ImVec2(0.5, 0.5))
                imgui.Begin(u8('reconPunish'), windows.recon.punish, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
                local textsize = function(text,size)    imgui.PushFont(Font[size])  imgui.Text(u8(text))    imgui.PopFont() end
                local clbutton = function(text, color)  
                    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(color.x, color.y, color.z, color.w / 2))  
                    
                    local button = imgui.Button(tostring(text), imgui.ImVec2(30,-1))     
                    imgui.PopStyleColor(1)      
                    return button   
                end
                if isKeyJustPressed(VK_SPACE) and is_key_check_available() then
                    rInfo.update_recon = true
                    sampSendChat('/re '..rInfo.id)
                    printStringNow('UPDATE RECON', 5000)
                end
                if clbutton('<<', ColorAccentsAdapter(listForColorTheme.ret.accent1.color_500):as_vec4()) then
                    if rInfo.id > 0 then
                        sampSendChat('/re '..rInfo.id - 1)
                    else
                        message():error('Достигнут максимально возможный ID для уменьшения!')
                    end
                end imgui.SameLine()
                imgui.BeginGroup()
                for i=1, #reconButtons do
                    local size = reconButtons[i].size or imgui.ImVec2(120, 0)
                    if imgui.Button(u8(reconButtons[i].name), size) then
                        lua_thread.create(function()
                            reconButtons[i].func(rInfo.id)
                        end)
                    end
                    if i%5 ~= 0 and i ~= #reconButtons then
                        imgui.SameLine()
                    end
                end
                
                imgui.EndGroup()
                imgui.SameLine()    
                if clbutton('>>', ColorAccentsAdapter(listForColorTheme.ret.accent1.color_500):as_vec4()) then
                    if rInfo.id < sampGetMaxPlayerId(false) then
                        sampSendChat('/re '..rInfo.id + 1)
                    else
                        message():error('Достигнут максимально возможный ID для увеличения!')
                    end
                end
                if imgui.BeginPopupModal('SETHP', _) then
                    textsize('Сколько нужно выдать ХП', 19)
                    imgui.PushItemWidth(-1)
                    imgui.SliderInt('##hphealth', elements.int.playerHealth, 0, 100)
                    imgui.PopItemWidth()
                    if imgui.Button(u8('Выдать'), imgui.ImVec2(-1,25)) then
                        sampSendChat('/sethp '..rInfo.id..' '..elements.int.playerHealth[0])
                    end
                    if imgui.Button(u8('Закрыть'), imgui.ImVec2(-1,25)) then
                        imgui.CloseCurrentPopup()
                    end
                end
                if imgui.BeginPopupModal('VEH', _) then
                    textsize('Выберите цвет', 20)
                    imgui.InputInt('###ggColors', elements.int.colorCar) 
                        textsize('Выберите авто', 20)
                        imgui.PushItemWidth(-1)
                        imgui.Combo('##comboveh', tCars.uuid, tCars.id, #tCars.name)
                        imgui.PopItemWidth()
                        if imgui.Button(u8('Выдать'), imgui.ImVec2(-1,25)) then
                            sampSendChat('/veh '..(tCars.uuid[0] + 400)..' '..elements.int.colorCar[0]..' '..elements.int.colorCar[0])
                        end
                        textsize('или', 20)
                        imgui.PushItemWidth(-1)
                        imgui.InputInt('##inputveh', elements.int.IDcar)
                        imgui.PopItemWidth()
                        if imgui.Button(u8('Bыдать'), imgui.ImVec2(-1,25)) then
                            sampSendChat('/veh '..elements.int.IDcar[0]..' '..elements.int.colorCar[0]..' '..elements.int.colorCar[0])
                        end
                        if imgui.Button(u8('Закрыть'), imgui.ImVec2(-1, 25)) then
                            imgui.CloseCurrentPopup()
                        end
                        
                end
                

                imgui.End()
            
            end
        end
        
    end
)
local aconsoleFrame = imgui.OnFrame(function()   return windows.aconsole[0]  end,
    function(this)
        local resX, resY = getScreenResolution()
        
        
        imgui.SetNextWindowPos(imgui.ImVec2(resX/2, resY/1.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(350, 250), imgui.Cond.FirstUseEver)
        imgui.Begin(u8('ADMIN-CONSOLE'), windows.aconsole, imgui.WindowFlags.AlwaysAutoResize)
        local textsize = function(text,size)    imgui.PushFont(Font[size])  imgui.TextWrapped(text)    imgui.PopFont() end
        imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 3.0)
        imgui.BeginChild("##console_log", imgui.ImVec2(346, 204), true, imgui.WindowFlags.NoScrollbar)
        
        for k,v in pairs(console():getConsole()) do
            textsize(v, 18)
            imgui.SetScrollHereY()
        end
        imgui.EndChild()
        imgui.PopStyleVar(1)
        imgui.PushItemWidth(325)
        imgui.InputTextWithHint('####aconsole_input', u8('Please, write you command!'), elements.input.console, 128)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button(faicons('ANGLE_RIGHT'), imgui.ImVec2(17, 0)) then 
            if #str(elements.input.console) ~= 0 then
                console():message(str(elements.input.console), 1)
                console():command(str(elements.input.console))
                imgui.StrCopy(elements.input.console, '')
            end
        end
        
        imgui.End()
    end
)

local reportMenu = imgui.OnFrame(function() return windows.reportPanel[0] end,
    function(window)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 550, 50
        local sizeButton = imgui.ImVec2(141, 0)
        
        imgui.SetNextWindowPos(imgui.ImVec2(resX/2, resY/1.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        
        imgui.Begin(u8('Жалоба/Вопрос'), windows.reportPanel, imgui.WindowFlags.AlwaysAutoResize)
        local textsize = function(text,size)    imgui.PushFont(Font[size])  imgui.Text(u8(text))    imgui.PopFont() end
        if #report.players > 0 then
            imgui.Text(u8('Отправитель: '..report.players[1].nickname..'['..report.players[1].id..']'))
            imgui.SameLine()
            imgui.IconHelpButton(faicons('EYE'), 'Следить за игроком', function()
                sampSendChat('/re '..report.players[1].id) 
            end)
            imgui.SameLine()
            imgui.IconHelpButton(faicons('COPY'), 'Скопировать информацию о репорте', function()
                imgui.LogToClipboard()
                imgui.LogText(u8(string.format('Жалоба от %s[%s]: %s', report.players[1].nickname, report.players[1].id, report.players[1].text)))
                imgui.LogFinish()
            end)
            imgui.SameLine(525)
            imgui.PushFont(Font[17])
            imgui.TextColoredRGB(u8(sampGetPlayerIdByNickname(report.players[1].nickname) ~= -1 and "{00ff00}В сети" or "{ff0000}Не в сети"))
            imgui.PopFont()
        end
        do
            imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 6.0)
            if imgui.BeginChild('##i_report', imgui.ImVec2(575, 40), true, imgui.WindowFlags.AlwaysAutoResize) then
                if #report.players > 0 then
                    imgui.PushTextWrapPos(500)
                    imgui.TextUnformatted(u8(report.players[1].text))
                    imgui.PopTextWrapPos()
                end

                imgui.EndChild()
            end
            imgui.PopStyleVar(1)
        end
        imgui.PushItemWidth(575)
        imgui.InputTextWithHint('##ReportAnswer', u8('Введите ответ'), elements.input.reportAnswer, ffi.sizeof(elements.input.reportAnswer))
        imgui.PopItemWidth()
        if #reportAnswerProcess > 0 then
            for k,v in pairs(reportAnswerProcess) do
                if v.reportUUID == report.players[1].uuid and v.text == report.players[1].text then
                    textsize(v.nick..' уже ответил на эту жалобу. Лучше пропустите её.', 19)
                end
            end
        end
        do
            imgui.BeginGroup()
                for i=1, #reportButtons do
                    
                    if imgui.Button(reportButtons[i].name, sizeButton) then
                        if #report.players > 0 then
                            lua_thread.create(function()
                                reportButtons[i].func(report.players[1].id, report.players[1].text, report.players[1].nickname)
                            end)
                        else
                            message():error('Репортов нет.')
                        end
                    end
                    if i%4 ~= 0 and i ~= #reportButtons then
                        imgui.SameLine()
                    end
                end
                
            imgui.EndGroup()
            
            imgui.BeginGroup()
                local num = 0
                imgui.Separator()
                for i=1, get_table_max(autoreportCfg.list, 'ua') do
                    local k = tostring(i)
                    if autoreportCfg.list[k] then
                        num = num + 1
                        local icons = autoreportCfg.list[k]['icon'] ~= 'not' and faicons(autoreportCfg.list[k]['icon']) or ''
                        if imgui.Button(icons..'  '..str(autoreportCfg.button[k]), sizeButton) then
                            if #report.players > 0 then
                                sampSendChat('/pm '..report.players[1].id..' '..u8:decode(str(autoreportCfg.text[k])))
                                refresh_current_report()
                            else
                                message():error('Репортов нет.')
                            end
                        end
                        if num%4 ~= 0 then
                            imgui.SameLine()
                        end
                    end
                end
                
            imgui.EndGroup()
            if get_table_count(autoreportCfg.list) ~= 0 then
                imgui.Separator()
            end
            
            if imgui.NeactiveButton(u8('Ответить'), imgui.ImVec2(158, 0), #ffi.string(elements.input.reportAnswer) == 0) then
                if #report.players > 0 then
                    if #ffi.string(elements.input.reportAnswer) ~= 0 then
                        
                        sampSendChat('/pm '..report.players[1].id..' '..u8:decode(ffi.string(elements.input.reportAnswer)))
                        refresh_current_report()
                    else
                        message():error('Вы не ввели ответ.')
                    end
                else
                    message():error('Репортов нет.')
                end
            end
            
            imgui.SameLine(423)
            if imgui.Button(u8('Пропустить'), imgui.ImVec2(158, 0)) then
                if #report.players > 0 then
                    refresh_current_report()
                else
                    message():error('Репортов нет.')
                end
            end
        end
        
        imgui.End()

    end
)
local mainMenu = imgui.OnFrame(function() return windows.AdminTools[0] end,
    function(this)
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(900, 605), imgui.Cond.FirstUseEver)
        imgui.Begin('Tris Tools', windows.AdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
        local textcolored = function(text, size)  imgui.PushFont(Font[size])  imgui.TextColored(ColorAccentsAdapter(listForColorTheme.ret.accent1.color_300):as_vec4(), text)  imgui.PopFont() end
        local textsize = function(text,size)    imgui.PushFont(Font[size])  imgui.Text(u8(text))    imgui.PopFont() end
        local centertextsize = function(text,size)    imgui.PushFont(Font[size])  imgui.CenterColoredText(ColorAccentsAdapter(listForColorTheme.ret.accent1.color_300):as_vec4(), text)    imgui.PopFont() end
        local centertextsizenocol = function(text,size)    imgui.PushFont(Font[size])  imgui.CenterText(text)    imgui.PopFont() end
        local textdisabled = function(text,size)    imgui.PushFont(Font[size])  imgui.TextDisabled(u8(text))    imgui.PopFont() end
        imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 0.0)
        imgui.PushStyleColor(imgui.Col.ChildBg, ColorAccentsAdapter(listForColorTheme.ret.accent1.color_600):as_vec4())
        if imgui.BeginChild('##MenuBar', imgui.ImVec2(195, -1), false, imgui.WindowFlags.AlwaysAutoResize) then
            do
                imgui.SetCursorPos(imgui.ImVec2(55, 10))
                imgui.Picture('##LogoPicture', img, imgui.ImVec2(1, 1), _, 'Full Size')
                imgui.SetCursorPosY(100)
                imgui.Menu()
            end
            imgui.EndChild()
        end 
        imgui.PopStyleColor(1)
        
        imgui.SameLine(195, _)
        
        if imgui.BeginChild('##RightBar', imgui.ImVec2(-1,-1), false, imgui.WindowFlags.NoScrollbar) then
            imgui.SetCursorPos(imgui.ImVec2(5,5))
            if menuItem == 1 then
                imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 6.0)
                imgui.SetCursorPosX(5)
                imgui.BeginChild('##AutoRetake', imgui.ImVec2(335, 125), false)
                textcolored(u8('Информация'), 21)
                imgui.PushFont(Font[20])
                imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x + 10, imgui.GetCursorPos().y - 4))
                imgui.TextColoredRGB(u8('{CECECE}Ник:{ffffff} '..getMyNick()))
                imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x + 10, imgui.GetCursorPos().y - 2))
                imgui.TextColoredRGB(u8('{CECECE}Версия:{ffffff} '..thisScript().version))
                imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x + 10, imgui.GetCursorPos().y - 1))
                imgui.TextColoredRGB(u8('{CECECE}Cтиль интерфейса:{ffffff} '))
                imgui.PopFont()
                -- textcolored(u8('Стиль интерфейса'), 21)
                
                imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x + 160, imgui.GetCursorPos().y - 27))
                
                if imgui.ColorEdit3('##wha', listForColorTheme.FLOAT4_COLOR, imgui.ColorEditFlags.NoAlpha + imgui.ColorEditFlags.NoDragDrop + imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.PickerHueWheel) then
                    listForColorTheme.OUR_COLOR = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(listForColorTheme.FLOAT4_COLOR[2], listForColorTheme.FLOAT4_COLOR[1], listForColorTheme.FLOAT4_COLOR[0], listForColorTheme.FLOAT4_COLOR[3])) -- BBGGRRAA => AARRGGBB
                    listForColorTheme.ret = MonetLua.buildColors(listForColorTheme.OUR_COLOR, 1, false)
                    jcfg["colors"][1], jcfg["colors"][2], jcfg["colors"][3], jcfg["colors"][4] = listForColorTheme.FLOAT4_COLOR[0], listForColorTheme.FLOAT4_COLOR[1], listForColorTheme.FLOAT4_COLOR[2], listForColorTheme.FLOAT4_COLOR[3]
                    jcfg["active"] = false
                    cjson.write(jcfg, "settings.json")
                    theme(listForColorTheme.OUR_COLOR, 0.8, false)
                end
                imgui.EndChild()
                imgui.SameLine()
                imgui.BeginChild('##DopINFA', imgui.ImVec2(325, 125), false)
                textcolored(u8('Прочее'), 21)
                imgui.PushFont(Font[20])
                imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x + 10, imgui.GetCursorPos().y - 4))
                imgui.TextColoredRGB(u8("{cecece}Автор скрипта: {ff0000}")) imgui.SameLine() if imgui.Text("vk.com/ilklme") then os.execute("opera.exe vk.com/tfornik") end
                imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x + 10, imgui.GetCursorPos().y - 2))
                imgui.TextColoredRGB(u8("{cecece}Поддержка: {ff0000}")) imgui.SameLine() if imgui.Text("vk.com/c_r_s_s") then os.execute("opera.exe vk.com/c_r_s_s") end
                imgui.PopFont()
                imgui.EndChild()
                imgui.SetCursorPosX(5)
                if imgui.BeginChild('##ToggleSettings', imgui.ImVec2(335, 0), false) then
                    textcolored(u8('Основные настройки'), 21)
                    for i=1, #toggleSettings do
                        if imgui.ToggleButton(toggleSettings[i].name, elements.toggle[toggleSettings[i].func], toggleSettings[i].hintText, toggleSettings[i].exText) then
                           
                            if toggleSettings[i].func == 'enabledBubbleBox' then
                                bubbleBox:toggle(elements.toggle[toggleSettings[i].func][0])
                            end
                            ini.main[toggleSettings[i].func] = elements.toggle[toggleSettings[i].func][0]
                            save()

                            if toggleSettings[i].func == 'customfov' then
                                if not elements.toggle[toggleSettings[i].func][0] then
                                    cameraSetLerpFov( 90,  90, 999988888, true)
                                else
                                    cameraSetLerpFov(elements.int.customfov_value[0], elements.int.customfov_value[0], 999988888, true)
                                end
                            end
                        end
                        if elements.toggle[toggleSettings[i].func][0] then
                            if toggleSettings[i].helpPopup ~= nil then 
                                imgui.SameLine()
                                imgui.HelpGear('Нажмите, чтобы настроить', function()
                                    imgui.OpenPopup(toggleSettings[i].helpPopup)
                                end)
                            end
                        end
                    end
                    

                    if imgui.BeginPopup("customfov") then
                        textsize('Настройка FOV', 19)
                        if imgui.SliderFloat('##fov', elements.int.customfov_value, 30, 150) then
                            cameraSetLerpFov(elements.int.customfov_value[0], elements.int.customfov_value[0], 999988888, true)  -- 0922
                            ini.main.customfov_value = elements.int.customfov_value[0]
                            save()
                        end
                        imgui.EndPopup()
                    end

                    if imgui.BeginPopup('visualSkin') then
                        textsize('Введите номер скина.', 19)
                        if imgui.InputInt(u8('##sliderVisualSkin'), elements.int.visualSkin) then
                            if elements.int.visualSkin[0] < 0 then
                                message():error('ID скина не может быть меньше 0!')
                                elements.int.visualSkin[0] = 0
                            elseif elements.int.visualSkin[0] > 311 then
                                message():error('ID скина не может быть больше 311!')
                                elements.int.visualSkin[0] = 311
                            else
                                set_player_skin(elements.int.visualSkin[0])
                            end
                        end 
                        if imgui.Button(u8('Close'), imgui.ImVec2(-1, 25)) then
                            imgui.CloseCurrentPopup()
                        end
                        imgui.EndPopup()
                    end
                    if imgui.BeginPopup('clickWarp') then
                        if imgui.ToggleButton('Взаимодействие с игроками при наведении', elements.toggle.clickWarpForPeople) then
                            ini.main.clickWarpForPeople = elements.toggle.clickWarpForPeople[0]
                            save()
                        end
                        if imgui.Button(u8('Close'), imgui.ImVec2(-1, 25)) then
                            imgui.CloseCurrentPopup()
                        end
                        imgui.EndPopup()
                    end
                    if imgui.BeginPopup('autoAlogin') then
                        if ini.main.autoAloginPassword ~= '' then
                            textsize('Ваш админ-пароль: ', 19) imgui.SameLine() textcolored(tostring(ini.main.autoAloginPassword), 19)
                        end
                        imgui.InputTextWithHint('##AdminPassword', u8('Введите админ-пароль'), elements.input.autoAloginPassword, sizeof(elements.input.autoAloginPassword))
                        if imgui.Button('Save', imgui.ImVec2(-1, 25)) then
                            
                            if elements.input.autoAloginPassword[0] ~= 0 then
                                if tonumber(str(elements.input.autoAloginPassword)) ~= nil then
                                    message():notify('Пароль успешно сохранён!', 2, 5, 1, 'Обязательно перепроверьте свой пароль.')
                                    ini.main.autoAloginPassword = str(elements.input.autoAloginPassword)
                                    save()
                                else
                                    message():notify('Пароль должен состоять из чисел.', 3, 5, 1, 'Пароль должен состоять из чисел.')
                                end
                            else
                                message():notify('Введите админ-пароль', 3,5,1,'Чтобы включить функцию, введите админ-пароль.')
                            end
                        end
                        if imgui.Button(u8('Close'), imgui.ImVec2(-1, 25)) then
                            imgui.CloseCurrentPopup()
                        end
                        imgui.EndPopup()
                    end
                    if imgui.BeginPopup('enabledBubbleBox') then
                        textsize('Название для чата', 18)
                        if imgui.InputTextWithHint('##nameBubbleBox', u8('Введите название для чата'), elements.input.bubbleBoxName, sizeof(elements.input.bubbleBoxName)) then
                            ini.main.bubbleBoxName = str(elements.input.bubbleBoxName)
                            save()
                        end
                        
                        textsize('Позиция чата', 18)
                        if imgui.Button(u8"Изменить", imgui.ImVec2(-1, 25)) then
                            changePosition.bubble = true
                            windows.AdminTools[0] = false
                            message():notify('Для сохранения позиции нажмите 1\nДля отмены нажмите 2', 2, 5, 1, 'Для сохранения позиции - нажмите 1, для отмены - нажмите 2.')
                        end
                        textsize('Максимальное количество строк в странице', 18)
                        if imgui.InputInt("##PrintInt", elements.int.limitPageSize) then
                            if elements.int.limitPageSize[0] >= 5 and elements.int.limitPageSize[0] <= 30 then
                                ini.main.limitPageSize = elements.int.limitPageSize[0]
                                save()
                            else
                                if elements.int.limitPageSize[0] < 5 then elements.int.limitPageSize[0] = 5 end
                                if elements.int.limitPageSize[0] > 30 then elements.int.limitPageSize[0] = 30 end
                            end
                        end
                        textsize('Максимальное количество строк', 19)
                        if imgui.InputInt("##maxPages", elements.int.maxPagesBubble) then
                            if elements.int.maxPagesBubble[0] >= 100 and elements.int.maxPagesBubble[0] <= 1000 then
                                ini.main.maxPagesBubble = elements.int.maxPagesBubble[0]
                                save()
                            else
                                if elements.int.maxPagesBubble[0] < 100 then elements.int.maxPagesBubble[0] = 100 end
                                if elements.int.maxPagesBubble[0] > 1000 then elements.int.maxPagesBubble[0] = 1000 end
                            end
                        end
                        textsize(' * Чтобы листать чат, зажмите B и крутите колёсико мыши.', 19)
                        imgui.EndPopup()
                    end

                    imgui.EndChild()
                end
                imgui.SameLine()
                if imgui.BeginChild('##HoTkeySettings', imgui.ImVec2(imgui.GetWindowWidth() - 345,0), false) then
                    textcolored(u8('Горячие клавиши'), 21)
                    textdisabled('Чтобы отменить, нажмите BackScape', 20)
                    if admintoolsHotKey:ShowHotKey(imgui.ImVec2(150, 25)) then -- отображаем второй хоткей, укажем размер во 2 параметре
                        ini.hotkey.admintools = encodeJson(admintoolsHotKey:GetHotKey())
                        save()
                    end imgui.SameLine() textsize('Открытие Tools', 19)
                    if autoreportHotKey:ShowHotKey(imgui.ImVec2(150, 25)) then -- отображаем второй хоткей, укажем размер во 2 параметре
                        ini.hotkey.autoreport = encodeJson(autoreportHotKey:GetHotKey())
                        save()
                    end imgui.SameLine() textsize('Авто-Репорт', 19)
                    if globalCursorHotKey:ShowHotKey(imgui.ImVec2(150, 25)) then -- отображаем второй хоткей, укажем размер во 2 параметре
                        ini.hotkey.globalCursor = encodeJson(globalCursorHotKey:GetHotKey())
                        save()
                    end imgui.SameLine() textsize('Глобальный курсор', 19)
                    if reconOffHotKey:ShowHotKey(imgui.ImVec2(150, 25)) then -- отображаем второй хоткей, укажем размер во 2 параметре
                        ini.hotkey.reconOff = encodeJson(reconOffHotKey:GetHotKey())
                        save()
                    end imgui.SameLine() textsize('Выйти из слежки', 19)
                    
                    
                    imgui.EndChild()
                end
                imgui.PopStyleVar(1)
            end
            if menuItem == 2 then
                centertextsize('Админский Полезный Софт', 21)
                imgui.SetCursorPosX(5)
                if imgui.BeginChild('##SoftMenu', imgui.ImVec2(197, 220), false) then
                    textcolored(u8('Выберите чит'), 21)
                    
                    imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(4, 2))
                    for i=1, #softMenu do
                        if imgui.GradientSelectable(u8(softMenu[i]), imgui.ImVec2(190, 23), softMenuItem == i) then softMenuItem = i end
                    end 
                    imgui.PopStyleVar(1)
                    imgui.EndChild()
                end
                imgui.SameLine()
                imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 8.0)
                if imgui.BeginChild('##SoftMenuRed', imgui.ImVec2((imgui.GetWindowWidth() - 197) - 15, 220), true, imgui.WindowFlags.NoScrollbar) then
                    if softMenuItem == 11 then
                        centertextsize(u8('GM on Car'), 21)
                        centertextsizenocol(u8('Ваш автомобиль становится неубиваемым.'), 18)
                        if imgui.ToggleButton('Состояние##GmOnCar', elements.toggle.gmCar) then
                            ini.main.gmCar = elements.toggle.gmCar[0]
                            save()
                        end
                    end
                    if softMenuItem == 10 then
                        centertextsize(u8('InWater Hack'), 21)
                        centertextsizenocol(u8('Персонаж получает возможность передвигаться под водой'), 18)
                        if imgui.ToggleButton('Состояние##InWater', elements.toggle.InWater) then
                            ini.main.InWater = elements.toggle.InWater[0]
                            memory.setuint8(0x6C2759, elements.toggle.InWater[0] and 1 or 0, false)
                            save()
                        end
                    end
                    if softMenuItem == 9 then
                        centertextsize(u8('No Bike Fall'), 21)
                        centertextsizenocol(u8('Вы не будете падать с мотоцикла при столкновениях'), 18)
                        if imgui.ToggleButton('Состояние##NoBike', elements.toggle.noBike) then
                            ini.main.noBike = elements.toggle.noBike[0]
                            setCharCanBeKnockedOffBike(playerPed, elements.toggle.noBike[0])
                            save()
                        end
                    end
                    if softMenuItem == 8 then
                        centertextsize(u8('InfinityRun'), 21)
                        centertextsizenocol(u8('Бесконечный бег без отдышки'), 18)
                        if imgui.ToggleButton('Состояние##InfinityRun', elements.toggle.infinityRun) then
                            ini.main.infinityRun = elements.toggle.infinityRun[0]
                            memory.setint8(0xB7CEE4, elements.toggle.infinityRun[0] and 1 or 0)
                            save()
                        end
                    end
                    if softMenuItem == 7 then
                        centertextsize(u8('Custom KillList'),21)
                        centertextsizenocol(u8('Кастомный список убийств'), 18)
                        if imgui.ToggleButton('Состояние##CustomKills', elements.toggle.customKillList) then
                            setStructElement(sampGetKillInfoPtr(), 0, 4, elements.toggle.customKillList[0] and 0 or 1)
                            ini.main.customKillList = elements.toggle.customKillList[0]
                            
                            save()
                        end
                        if imgui.Button(u8(' Изменить позицию##killlist'), imgui.ImVec2(-1, 25)) then
                            message():notify('Для сохранения позиции - нажмите 1.\nДля отмены - нажмите 2.', 2, 5, 1, 'Для сохранения позиции - нажмите 1, для отмены - нажмите 2.')
                            lua_thread.create(function()
                                windows.AdminTools[0] = false
                                while not isKeyJustPressed(49) and not isKeyJustPressed(50) do wait(0)
                                    sampSetCursorMode(4)
                                    ini.set.x, ini.set.y = getCursorPos()
                                    
                                end
                                if isKeyJustPressed(49) then
                                    windows.AdminTools[0] = true
                                    message():info('Настройки успешно сохранены')
                                    sampSetCursorMode(0)
                                    save()
                                end
                                if isKeyJustPressed(50) then
                                    message():info('Вы успешно отменили смену позиции')
                                end
                            end)
                        end
                        
                        imgui.PushItemWidth(150)

                        if imgui.Checkbox("###Показывать ID", kl.imgui_showid) then
                            ini.set.showid = not ini.set.showid
                            save()
                        end imgui.SameLine() textsize('Показывать ID', 18)

                        

                        if imgui.InputText("##klFontName", kl.imgui_fontname, 128) then
                            ini.set.fontname = ffi.string(kl.imgui_fontname)
                            kl.font = renderCreateFont(ini.set.fontname, ini.set.fontsize, ini.set.fontflag)
                            save()
                        end imgui.SameLine() textsize('Шрифт', 18)

                        if imgui.InputInt("##klFontSize", kl.imgui_fontsize) then
                            ini.set.fontsize = kl.imgui_fontsize[0]
                            kl.font = renderCreateFont(ini.set.fontname, ini.set.fontsize, ini.set.fontflag)
                            save()
                        end imgui.SameLine() textsize('Размер Шрифта', 18)

                        if imgui.InputInt("##klFontFlag", kl.imgui_fontflag) then
                            ini.set.fontflag = kl.imgui_fontflag[0]
                            kl.font = renderCreateFont(ini.set.fontname, ini.set.fontsize, ini.set.fontflag)
                            save()
                        end imgui.SameLine() textsize('FontFlag', 18)

                        if imgui.InputInt("##klIconSize", kl.imgui_iconsize) then
                            if fonts_loaded then
                                ini.set.iconsize = kl.imgui_iconsize[0]
                                font_gtaweapon3.vtbl.Release(font_gtaweapon3)
                                font_gtaweapon3 = d3dxfont_create("gtaweapon3", ini.set.iconsize, 1)
                                save()
                            end
                        end imgui.SameLine() textsize('Размер Иконок', 18)

                        

                        imgui.PopItemWidth()
                    end
                    if softMenuItem == 6 then
                        centertextsize(u8('Bullet Tracers'), 21) imgui.SameLine() imgui.IconHelpButton(faicons('AT'), 'Создатель данного чита: @kyrtion', function() end)
                        centertextsizenocol(u8('Подсвечивание траектории пуль линиями на экране'), 18)
                        local size = {x = imgui.GetWindowSize().x-imgui.GetStyle().WindowPadding.x, y = imgui.GetWindowSize().y-imgui.GetStyle().WindowPadding.y}
                        local sl = imgui.SameLine
                        local sniw = imgui.SetNextItemWidth
                        if imgui.ToggleButton('Состояние##BulletTracers', elements.toggle.bulletTracers) then
                            ini.main.bulletTracers = elements.toggle.bulletTracers[0]
                            save()
                        end
                        imgui.Spacing()
                        do
                            if imgui.Button(faicons('LINK_SIMPLE')..u8('  Настройка своих пуль'), imgui.ImVec2(-1, 25)) then
                                imgui.OpenPopup(u8('Настройка своих пуль'))
                            end
                            if imgui.BeginPopup(u8('Настройка своих пуль')) then
                                imgui.CenterText(u8'Настройка своих пуль')
                                imgui.Separator()
                                imgui.BeginGroup()
                                    sniw(100); imgui.DragFloat(u8'Время задержки трейсера##mySettings', config_imgui.my_bullets.timer, 0.01, 0.01, 10, '%.2f')
                                    sniw(100); imgui.DragFloat(u8'Время появление до попадании##mySettings', config_imgui.my_bullets.transition, 0.01, 0, 2, '%.2f')
                                    sniw(100); imgui.DragFloat(u8'Шаг исчезнование##mySettings', config_imgui.my_bullets.step_alpha, 0.001, 0.001, 0.5, '%.3f')
                                    sniw(100); imgui.DragFloat(u8'Толщина линий##mySettings', config_imgui.my_bullets.thickness, 0.1, 1, 10, '%.2f')
                                    sniw(100); imgui.DragFloat(u8'Размер окончания трейсера##mySettings', config_imgui.my_bullets.circle_radius, 0.2, 0, 15, '%.2f')
                                    sniw(100); imgui.DragInt(u8'Количество углов на окончаниях##mySettings', config_imgui.my_bullets.degree_polygon, 0.2, 3, 40)
                                imgui.EndGroup(); sl(_, 20);
                                imgui.BeginGroup()
                                    imgui.Checkbox(u8'Отрисовку своих пуль', config_imgui.my_bullets.draw)
                                    imgui.Checkbox(u8'Окончания у линий', config_imgui.my_bullets.draw_polygon)
                                    imgui.ColorEdit4('##mySettings__Player', config_imgui.my_bullets.col_vec4.ped, imgui.ColorEditFlags.NoInputs); sl(); imgui.Text(u8'Игрок')
                                    imgui.ColorEdit4('##mySettings__Car', config_imgui.my_bullets.col_vec4.car, imgui.ColorEditFlags.NoInputs); sl(); imgui.Text(u8'Машина')
                                    imgui.ColorEdit4('##mySettings__Stats', config_imgui.my_bullets.col_vec4.stats, imgui.ColorEditFlags.NoInputs); sl(); imgui.Text(u8'Статический объект')
                                    imgui.ColorEdit4('##mySettings__Dynam', config_imgui.my_bullets.col_vec4.dynam, imgui.ColorEditFlags.NoInputs); sl(); imgui.Text(u8'Динамический объект')
                                imgui.EndGroup()
                                imgui.EndPopup()
                            end
                            if imgui.Button(faicons('LINK_SIMPLE')..u8('  Настройка чужих пуль'), imgui.ImVec2(-1, 25)) then
                                imgui.OpenPopup(u8('Настройка чужих пуль'))
                            end
                            if imgui.BeginPopup(u8('Настройка чужих пуль')) then
                                imgui.CenterText(u8'Настройка чужих пуль')
                                imgui.Separator()
                                imgui.BeginGroup()
                                    sniw(100); imgui.DragFloat(u8'Время задержки трейсера##otherSettings', config_imgui.other_bullets.timer, 0.01, 0.01, 10, '%.2f')
                                    sniw(100); imgui.DragFloat(u8'Время появление до попадании##otherSettings', config_imgui.other_bullets.transition, 0.01, 0, 2, '%.2f')
                                    sniw(100); imgui.DragFloat(u8'Шаг исчезнование##otherSettings', config_imgui.other_bullets.step_alpha, 0.001, 0.001, 0.5, '%.3f')
                                    sniw(100); imgui.DragFloat(u8'Толщина линий##otherSettings', config_imgui.other_bullets.thickness, 0.1, 1, 10, '%.2f')
                                    sniw(100); imgui.DragFloat(u8'Размер окончания трейсера##otherSettings', config_imgui.other_bullets.circle_radius, 0.2, 0, 15, '%.2f')
                                    sniw(100); imgui.DragInt(u8'Количество углов на окончаниях##otherSettings', config_imgui.other_bullets.degree_polygon, 0.2, 3, 40)
                                imgui.EndGroup(); sl(_, 20);
                                imgui.BeginGroup()
                                    imgui.Checkbox(u8'Отрисовку чужих пуль', config_imgui.other_bullets.draw)
                                    imgui.Checkbox(u8'Окончания у линий', config_imgui.other_bullets.draw_polygon)
                                    imgui.ColorEdit4('##otherSettings__Player', config_imgui.other_bullets.col_vec4.ped, imgui.ColorEditFlags.NoInputs); sl(); imgui.Text(u8'Игрок')
                                    imgui.ColorEdit4('##otherSettings__Car', config_imgui.other_bullets.col_vec4.car, imgui.ColorEditFlags.NoInputs); sl(); imgui.Text(u8'Машина')
                                    imgui.ColorEdit4('##otherSettings__Stats', config_imgui.other_bullets.col_vec4.stats, imgui.ColorEditFlags.NoInputs); sl(); imgui.Text(u8'Статический объект')
                                    imgui.ColorEdit4('##otherSettings__Dynam', config_imgui.other_bullets.col_vec4.dynam, imgui.ColorEditFlags.NoInputs); sl(); imgui.Text(u8'Динамический объект')
                                imgui.EndGroup()
                                
                                imgui.EndPopup()
                            end


                            imgui.ToggleButton('Проходить пули сквозь экран', config_imgui.settings.enabled_bullets_in_screen) sl(); imgui.HelpMarker(u8('Может быть нестабильно'))

                            if imgui.Button(u8'Сохранить', imgui.ImVec2(size.x/3 - imgui.GetStyle().ItemSpacing.x - 1/3, 0)) then
                                config():save(config():convert_to_table(config_imgui))
                                message():info('Успешно сохранено!')
                            end
                            
                        end
                    end
                    if softMenuItem == 5 then
                        centertextsize(u8('RadarHack'), 21)
                        centertextsizenocol(u8('Чит отображает на карте ID игроков,\n с которыми можно взаимодействовать.'), 18)
                        
                        if imgui.ToggleButton('Состояние##RadarHack', elements.toggle.radarhack) then
                            ini.main.radarhack = elements.toggle.radarhack[0]
                            save()
                        end
                    
                        
                    end
                    if softMenuItem == 1 then
                        centertextsize(u8('AirBrake'), 21)
                        centertextsizenocol(u8('Чит на полёт на ногах'), 18)
                        if imgui.ToggleButton('Состояние##AirBrake', elements.toggle.enabledAirBrake) then
                            ini.main.enabledAirBrake = elements.toggle.enabledAirBrake[0]
                            save()
                        end
                        if elements.toggle.enabledAirBrake[0] then
                            if imgui.RadioButtonBoolH(u8('Активация на SHIFT'),elements.int.typeAirBrake[0] == 1,ColorAccentsAdapter(listForColorTheme.ret.accent1.color_600):as_vec4(), ColorAccentsAdapter(listForColorTheme.ret.accent1.color_800):as_vec4()) then
                                elements.int.typeAirBrake[0] = 1
                                ini.main.typeAirBrake = elements.int.typeAirBrake[0]
                                save()
                            end
                            imgui.Spacing()
                            if imgui.RadioButtonBoolH(u8('Своя клавиша'),elements.int.typeAirBrake[0] == 2,ColorAccentsAdapter(listForColorTheme.ret.accent1.color_600):as_vec4(), ColorAccentsAdapter(listForColorTheme.ret.accent1.color_800):as_vec4()) then
                                elements.int.typeAirBrake[0] = 2
                                ini.main.typeAirBrake = elements.int.typeAirBrake[0]
                                save()
                            end
                            
                            if elements.int.typeAirBrake[0] == 2 then
                                imgui.Spacing()
                                if airbrakeHotKey:ShowHotKey(imgui.ImVec2(200, 25)) then -- отображаем второй хоткей, укажем размер во 2 параметре
                                    ini.hotkey.airbrake = encodeJson(airbrakeHotKey:GetHotKey())
                                    save()
                                end 
                            end
                        end
                    end
            
                    if softMenuItem == 2 then
                        centertextsize(u8('SpeedHack'), 21)
                        centertextsizenocol(u8('Ускоряет ваш автомобиль\nАктивация: ALT'), 18)
                        if imgui.ToggleButton('Состояние##SpeedHACK', elements.toggle.enabledSpeedHack) then
                            ini.main.enabledSpeedHack = elements.toggle.enabledSpeedHack[0]
                            save()
                        end
                    end
                    if softMenuItem == 3 then
                        centertextsize('WH на игроков', 21)
                        centertextsizenocol(u8('Позволяет видеть других через стены'), 18)
                        if imgui.ToggleButton('Состояние##WallHack', elements.toggle.enabledWallHack) then
                            wallhack(elements.toggle.enabledWallHack[0])
                            save()
                        end imgui.SameLine(imgui.GetWindowWidth() - 165)
                        if wallhackHotKey:ShowHotKey(imgui.ImVec2(150, 25)) then
                            ini.hotkey.wallhack = encodeJson(wallhackHotKey:GetHotKey())
                            save()
                        end imgui.SameLine()
                        imgui.Spacing()
                        if imgui.ToggleButton('Skeletal WallHack', elements.toggle.enabledSkeletallWallHack) then
                            ini.main.enabledSkeletallWallHack = elements.toggle.enabledSkeletallWallHack[0]
                            save()
                        end imgui.SameLine() imgui.HelpMarker(u8('Позволяет видеть скелеты игроков'))
                        textsize('Толщина линий', 19)
                        if imgui.SliderInt('####WIDTHWH', elements.int.skeletWidth, 1, 10) then
                            ini.main.skeletWidth = elements.int.skeletWidth[0]
                            save()
                        end
                        
                    end
                    if softMenuItem == 4 then
                        centertextsize('WH на транспорт')
                        centertextsizenocol(u8('Позволяет видеть информацию о т/с через стены'), 18)
                        if wallhackCarHotKey:ShowHotKey(imgui.ImVec2(150, 25)) then
                            ini.hotkey.wallhackCar = encodeJson(wallhackCarHotKey:GetHotKey())
                            save()
                        end imgui.SameLine() textsize('Состояние', 19)
                        if imgui.ToggleButton('Отображать дистанцию', elements.whcars.distance) then
                            ini.whcars.distance = elements.whcars.distance[0]
                            save()
                        end
                        if imgui.ToggleButton('Отображать статус дверей', elements.whcars.statusDoor) then
                            ini.whcars.statusDoor = elements.whcars.statusDoor[0]
                            save()
                        end
                    end 
                    imgui.EndChild()
                end
                
                imgui.PopStyleVar(1)
            end
            if menuItem == 3 then
                centertextsize('Режим Слежки', 21)
                imgui.SetCursorPosX(5)
                imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 8.0)
                if imgui.BeginChild('##reconInfoPunish', imgui.ImVec2(250,90), true) then
                    textcolored(u8('Панель быстрых действий'), 21)
                    if imgui.ToggleButton('Состояние панели##reconInfoPunish', elements.toggle.reconInfoPunish) then
                        ini.main.reconInfoPunish = elements.toggle.reconInfoPunish[0]
                        save()
                    end
                    if imgui.Button(u8(' Изменить позицию##reconInfoPunish'), imgui.ImVec2(-1, 25)) then
                        changePosition.reconInfoPunish = true
                        windows.AdminTools[0] = false
                        message():notify('Для сохранения позиции - нажмите 1.\nДля отмены - нажмите 2.', 2, 5, 1, 'Для сохранения позиции - нажмите 1, для отмены - нажмите 2.')
                    end
                    imgui.EndChild()
                end
                imgui.SameLine()
                if imgui.BeginChild('##reconInfoStats', imgui.ImVec2((imgui.GetWindowWidth() - 250) - 15, 166), true) then
                    textcolored(u8('Информационная панель'), 21)
                    if imgui.ToggleButton('Состояние панели##reconInfoStats', elements.toggle.reconInfoStats) then
                        ini.main.reconInfoStats = elements.toggle.reconInfoStats[0]
                        save()
                    end
                    textsize('Выберите тип панели:', 20)
                    if imgui.RadioButtonBoolH(u8('Горизонтальный'),elements.int.typeInfoBar[0] == 1,ColorAccentsAdapter(listForColorTheme.ret.accent1.color_600):as_vec4(), ColorAccentsAdapter(listForColorTheme.ret.accent1.color_800):as_vec4()) then
                        elements.int.typeInfoBar[0] = 1
                        ini.main.typeInfoBar = 1
                        save()
                    end imgui.Spacing()
                    if imgui.RadioButtonBoolH(u8('Вертикальный'),elements.int.typeInfoBar[0] == 2,ColorAccentsAdapter(listForColorTheme.ret.accent1.color_600):as_vec4(), ColorAccentsAdapter(listForColorTheme.ret.accent1.color_800):as_vec4()) then
                        elements.int.typeInfoBar[0] = 2
                        ini.main.typeInfoBar = 2
                        save()
                    end
                    imgui.Spacing()
                    if imgui.Button(u8(' Изменить позицию##reconInfoStats'), imgui.ImVec2(-1, 25)) then
                        changePosition.reconInfoStats = true
                        windows.AdminTools[0] = false
                        message():notify('Для сохранения позиции - нажмите 1.\nДля отмены - нажмите 2.', 2, 5, 1, 'Для сохранения позиции - нажмите 1, для отмены - нажмите 2.')
                    end
                    imgui.EndChild() 
                end
                imgui.SetCursorPos(imgui.ImVec2(5, 125))
                if imgui.BeginChild('##KeyLogger', imgui.ImVec2(250, (imgui.GetWindowHeight() - 125) - 5), true, imgui.WindowFlags.NoScrollWithMouse) then
                    textcolored(u8('KeyLogger'), 21)
                    if imgui.ToggleButton('Состояние панели##keylogger', elements.toggle.reconInfoLogger) then
                        ini.main.reconInfoLogger = elements.toggle.reconInfoLogger[0]
                        save()
                    end
                    if imgui.ToggleButton('Регулировать прозрачность фона', elements.toggle.keyLoggerFon) then
                        ini.main.keyLoggerFon = elements.toggle.keyLoggerFon[0]
                        save()
                    end
                    if elements.toggle.keyLoggerFon[0] then
                        imgui.Spacing()
                        textsize('Регуляция фона', 20)
                        imgui.PushItemWidth(-1)
                        if imgui.SliderInt('##keyloggerFont', keyLogger.fon, 0, 100) then
                            ini.style.keyLoggerFon = keyLogger.fon[0]
                            save()
                        end
                    end
                    if imgui.Button(u8(' Изменить позицию##keylogger'), imgui.ImVec2(-1, 25)) then
                        changePosition.reconInfoLogger = true
                        windows.AdminTools[0] = false
                        message():notify('Для сохранения позиции - нажмите 1.\nДля отмены - нажмите 2.', 2, 5, 1, 'Для сохранения позиции - нажмите 1, для отмены - нажмите 2.')
                    end
                    imgui.EndChild()
                end
                imgui.SetCursorPos(imgui.ImVec2(260,200))
                if imgui.BeginChild('##ReconNakaz', imgui.ImVec2((imgui.GetWindowWidth() - 250) - 15, (imgui.GetWindowHeight() - 200) - 5), true, imgui.WindowFlags.NoScrollWithMouse) then
                    local ctext = textsize
                    textcolored(u8('Панель наказаний'), 21)
                    if imgui.ToggleButton('Состояние панели##reconnakaz', elements.toggle.reconInfoNakaz) then
                        ini.main.reconInfoNakaz = elements.toggle.reconInfoNakaz[0]
                        save()
                    end
                    
                    if imgui.Button(u8(' Изменить позицию##reconnakaz'), imgui.ImVec2(-1, 25)) then
                        changePosition.reconInfoNakaz = true
                        windows.AdminTools[0] = false
                        message():notify('Для сохранения позиции - нажмите 1.\nДля отмены - нажмите 2.', 2, 5, 1, 'Для сохранения позиции - нажмите 1, для отмены - нажмите 2.')
                    end
                    imgui.Separator()
                    for k,v in pairs(punishList) do
                        if k ~= 'WARN' then
                            if imgui.Button(u8('  Настроить наказания для: '..k), imgui.ImVec2(-1, 25)) then
                                imgui.OpenPopup(k)
                                windows.nakazList[k][0] = true
                            end
                        end
                    end 
                    imgui.Separator()
                    local num = 0
                    if imgui.BeginPopupModal('JAIL', windows.nakazList['JAIL']) then
                        imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(4,3))
                        for k,v in pairs(punishList['JAIL']) do
                            num = num + 1
                            ctext(k, 21) imgui.SameLine(210)
                            imgui.PushItemWidth(150)
                            if imgui.InputInt('##input'..k, punishInputs[k]) then
                                if punishInputs[k][0] > 0 and punishInputs[k][0] < 60 then
                                    punishList['JAIL'][k] = punishInputs[k][0]
                                    rules():write(punishList)
                                else
                                    punishInputs[k][0] = v
                                end
                            end
                            imgui.PopItemWidth()
                            if num ~= 18 then
                                imgui.Separator()
                            end
                        end
                        imgui.PopStyleVar(1)
                        imgui.EndPopup()
                    end
                    if imgui.BeginPopupModal('MUTE', windows.nakazList['MUTE']) then
                        imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(4,3))
                        for k,v in pairs(punishList['MUTE']) do
                            num = num + 1
                            ctext(k, 21) imgui.SameLine(210)
                            imgui.PushItemWidth(150)
                            if imgui.InputInt('##input'..k, punishInputs[k]) then
                                if punishInputs[k][0] > 0 and punishInputs[k][0] < 60 then
                                    punishList['MUTE'][k] = punishInputs[k][0]
                                    rules():write(punishList)
                                else
                                    punishInputs[k][0] = v
                                end
                            end
                            imgui.PopItemWidth()
                            if num ~= 14 then
                                imgui.Separator()
                            end
                        end
                        imgui.PopStyleVar(1)
                        imgui.EndPopup()
                    end
                    
                    if imgui.BeginPopupModal('RMUTE', windows.nakazList['RMUTE']) then
                        imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(4,3))
                        for k,v in pairs(punishList['RMUTE']) do
                            num = num + 1
                            ctext(k, 20) imgui.SameLine(210)
                            imgui.PushItemWidth(150)
                            if imgui.InputInt('##input'..k, punishInputs[k]) then
                                if punishInputs[k][0] > 0 and punishInputs[k][0] < 60 then
                                    punishList['RMUTE'][k] = punishInputs[k][0]
                                    rules():write(punishList)
                                else
                                    punishInputs[k][0] = v
                                end
                            end
                            imgui.PopItemWidth()
                            if num ~= 14 then
                                imgui.Separator()
                            end
                        end
                        imgui.PopStyleVar(1)
                        imgui.EndPopup()
                    end
                    if imgui.BeginPopupModal('BAN', windows.nakazList['BAN']) then
                        imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(4,3))
                        for k,v in pairs(punishList['BAN']) do
                            num = num + 1
                            ctext(k, 20) imgui.SameLine(235)
                            imgui.PushItemWidth(150)
                            if imgui.InputInt('##input'..k, punishInputs[k]) then
                                if punishInputs[k][0] > 0 and punishInputs[k][0] < 60 then
                                    punishList['BAN'][k] = punishInputs[k][0]
                                    rules():write(punishList)
                                else
                                    punishInputs[k][0] = v
                                end
                            end
                            imgui.PopItemWidth()
                            if num ~= 7 then
                                imgui.Separator()
                            end
                        end
                        imgui.PopStyleVar(1)
                        imgui.EndPopup()
                    end
                    imgui.EndChild()
                end
                
                imgui.PopStyleVar(1)
            end
            if menuItem == 4 then
                centertextsize('Мониторинг', 21)
                imgui.SetCursorPosX(5)
                imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 8.0)
                textcolored(u8('Мониторинг статистики'), 20)
                imgui.SetCursorPosX(5)
                imgui.BeginChild('###Monitoring_Stats', imgui.ImVec2(imgui.GetWindowWidth() - 10, 270), true)
                if imgui.ToggleButton('Состояние##playerStats', windows.playerStats) then
                    ini.main.StatsEnabled = windows.playerStats[0]
                    save()
                end 
                if imgui.ToggleButton('Центрирование текста', elements.toggle.StatsCenteredText) then
                    ini.main.StatsCenteredText = elements.toggle.StatsCenteredText[0]
                    save()
                end
                if imgui.Button(u8('  Изменить позицию##playerStats'), imgui.ImVec2(-1,25)) then
                    windowsOpen = false
                    changePosition.playerStats = true
                    windows.AdminTools[0] = false
                    
                    message():notify('Для сохранения позиции - нажмите 1.\nДля отмены - нажмите 2.', 2, 5, 1, 'Для сохранения позиции - нажмите 1, для отмены - нажмите 2.')
                end
                
                imgui.Separator()
                imgui.Columns(2, '##statssse', false)
                for i=1, #statsElements do
                    
                    if imgui.Checkbox(u8(statsElements[i].name), elements.putStatis[statsElements[i].func]) then
                        ini.putStatis[statsElements[i].func] = elements.putStatis[statsElements[i].func][0]
                        save()
                    end 
                    if i ~= #statsElements then
                        imgui.NextColumn()
                    end
                    
                end
                imgui.Columns(1)
                imgui.EndChild()
                imgui.SetCursorPosX(5)
                textcolored(u8('Мониторинг администрации'), 20)
                imgui.SetCursorPosX(5)
                imgui.BeginChild('###Monitoring_Admins', imgui.ImVec2(imgui.GetWindowWidth() - 10, 0), true)
                if imgui.ToggleButton('Состояние##renderAdminsTeam', elements.toggle.renderAdminsTeam) then
                    ini.render.renderAdminsTeam = elements.toggle.renderAdminsTeam[0]
                    save()
                end
                if imgui.Button(u8('  Изменить позицию##renderAdmins'), imgui.ImVec2(-1,25)) then
                    windowsOpen = false
                    changePosition.renderAdmins = true
                    windows.AdminTools[0] = false
                    
                    message():notify('Для сохранения позиции - нажмите 1.\nДля отмены - нажмите 2.', 2, 5, 1, 'Для сохранения позиции - нажмите 1, для отмены - нажмите 2.')
                end
                imgui.PushItemWidth(150)
                if imgui.SliderInt('###slider_monitoring_admins_cooldown', elements.int.renderCoolDown, 5, 60) then
                    ini.render.renderCoolDown = elements.int.renderCoolDown[0]
                    save()
                imgui.Spacing()
                end imgui.SameLine() textsize('Частота обновления рендера. Рекомендуемое - 5 секунд.', 19)
                textcolored(u8('Настройка шрифтов'), 19)
                imgui.InputText('##Input_Font_Monitoring', elements.input.renderFont, sizeof(elements.input.renderFont))
                imgui.SameLine()    textsize('Шрифт', 19)
                imgui.InputInt('##Input_FontSize_Monitoring', elements.int.renderFontSize)
                imgui.SameLine()    textsize('Размер шрифта', 19)
                imgui.InputInt('##Input_FontFlag_Monitoring', elements.int.renderFontFlag)
                imgui.SameLine()    textsize('FontFlags', 19)
                imgui.PopItemWidth()
                if imgui.Button(u8('Сохранить шрифты'), imgui.ImVec2(150, 25)) then
                    ini.render.font = str(elements.input.renderFont)
                    ini.render.fontsize = elements.int.renderFontSize[0]
                    ini.render.fontflag = elements.int.renderFontFlag[0]
                    save()
                    adminMonitor.font = renderCreateFont(ini.render.font,ini.render.fontsize,ini.render.fontflag)
                end
                imgui.EndChild()
                imgui.PopStyleVar(1)
                
                    
                
            end
            if menuItem == 5 then
                centertextsize('Настройка чекера игроков', 21)
                local input_name = {}
                imgui.SetCursorPosX(5)
                imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 8.0)
                imgui.BeginChild('###CheckerMenu', imgui.ImVec2(240, 0), true)
                textcolored(u8'Выберите чекер:', 21)
                if imgui.Button(u8('Добавить')) then
                    local count = get_table_count(checkerList, 'Settings')
                    checker():newTable(count + 1)
                end
                local max = get_table_max(checkerList, 'Settings')
                for i=1, max do
                    local k = tostring(i)
                    if checkerList[k] then
                        if imgui.Button(u8(checkerList['Settings'][k]['name']), imgui.ImVec2(200,25)) then
                            checkerMenuItem = k
                        end imgui.SameLine() imgui.IconHelpButton(faicons('MINUS'), 'Нажмите, чтобы удалить\nЯчейка: '..checkerList['Settings'][k]['name'], function() checker():deleteTable(k) 
                            checkerMenuItem = nil
                        end)
                    end
                end
                imgui.EndChild()
                imgui.SameLine()
                imgui.BeginChild('###checkerSettings', imgui.ImVec2(0, 0), true)
                if checkerMenuItem ~= nil then
                    textcolored(u8'Настройка чекера: '..u8(checkerList['Settings'][checkerMenuItem]['name']), 21) 
                else 
                    textcolored(u8'Настройка чекера',21)
                end
                    
                    for k,v in pairs(checkerList) do
                        if k ~= 'Settings' then
                            if checkerMenuItem == k then
                                if imgui.ToggleButton('Состояние##checkerInputsAction', checkerInputs.action[k]) then
                                    checker():action(k, checkerInputs.action[k][0])
                                end
                                if checkerInputs.action[k][0] then
                                    if imgui.Button(u8(' Изменить позицию##checker_'..k), imgui.ImVec2(-1, 25)) then 
                                        message():notify('Для сохранения позиции - нажмите 1.\nДля отмены - нажмите 2.', 2, 5, 1, 'Для сохранения позиции - нажмите 1, для отмены - нажмите 2.')
                                        changePosition[k] = true
                                        windows.AdminTools[0] = false
                                    end
                                    imgui.Spacing()
                                    textsize('Название чекера', 20)
                                    imgui.InputText('##check_name'..k, checkerInputs.name[k], 128) imgui.SameLine() imgui.IconHelpButton(('+'), 'Нажмите, чтобы сохранить', function()
                                        checker():rename(k, u8:decode(str(checkerInputs.name[k])))
                                    end)
                                    textsize('Настройка шрифтов', 20)
                                    imgui.PushItemWidth(150)
                                    imgui.InputText('###check_fontname_'..k, checkerInputs.fontname[k], 256) imgui.SameLine() imgui.IconHelpButton(('+'), 'Нажмите, чтобы сохранить', function()
                                        checker():setStyle(k, 'font', str(checkerInputs.fontname[k]))
                                    end) imgui.SameLine() textsize('Шрифт', 19)
                                    
                                    if imgui.InputInt('###check_fontsize_'..k, checkerInputs.fontsize[k]) then
                                        checker():setStyle(k, 'fontsize', checkerInputs.fontsize[k][0])
                                    end imgui.SameLine() textsize('Размер шрифта', 19)
                                    
                                    if imgui.InputInt('###check_fontflags_'..k, checkerInputs.fontflags[k]) then
                                        checker():setStyle(k, 'fontflags', checkerInputs.fontflags[k][0]) 
                                    end imgui.SameLine() textsize('FontFlags', 19)
                                    imgui.PopItemWidth()
                                    imgui.Spacing()
                                    textsize('Настройка ников', 20)
                                    if imgui.Button(u8('Добавить')) then
                                        imgui.OpenPopup('new'..k)
                                    end
                                    if imgui.BeginPopup('new'..k) then
                                        textsize('Введите ник игрока:', 21)
                                        imgui.InputText('##new_nick_'..k, checkerInputs.nicks[k], 256)
                                        if imgui.Button(u8'Добавить', imgui.ImVec2(-1,25)) then
                                            if #str(checkerInputs.nicks[k]) ~= 0 then
                                                if not checker():getValidationNick(k,u8:decode(str(checkerInputs.nicks[k]))) then 
                                                    checker():add(k, u8:decode(str(checkerInputs.nicks[k]))) 
                                                else
                                                    message():notify('Такой ник уже существует в чекере!', 3, 5, 1, 'Такой ник уже существует в чекере!')
                                                end
                                            else
                                                message():notify('Вы не ввели ник.', 3, 5, 1, 'Введите ник!')
                                            end
                                        end
                                        imgui.EndPopup()
                                    end
                                    imgui.Spacing()
                                    for _,r in pairs(checkerList[k]) do
                                        imgui.Text(r)
                                        imgui.SameLine()
                                        
                                        imgui.IconHelpButton(('+'), 'Нажмите, чтобы настроить рендер ника', function()
                                            imgui.OpenPopup('##redact_isds_'..k..'_'..r)
                                        end)
                                        imgui.SameLine()
                                        imgui.IconHelpButton(('-'), 'Нажмите, чтобы удалить ник из чекера', function()
                                            checker():delete(k, r)
                                        end)
                                        if imgui.BeginPopup('##redact_isds_'..k..'_'..r) then
                                            if imgui.ToggleButton('Отображать дистанцию', checkerInputs.IsDistance[k][r]) then
                                                checker():setIsDistance(k, checkerInputs.IsDistance[k][r][0], r)
                                            end
                                            if imgui.ToggleButton('Использовать цвет ника', checkerInputs.color[k][r]) then
                                                checker():setColornick(k, checkerInputs.color[k][r][0], r)
                                            end
                                            if imgui.ToggleButton('Дополнительное имя', checkerInputs.unicalNameBool[k][r]) then
                                                checker():setUnicalNameBool(k, r, checkerInputs.unicalNameBool[k][r][0]) 
                                            end
                                            if checkerInputs.unicalNameBool[k][r][0] then
                                                imgui.PushItemWidth(200)
                                                imgui.InputText('##present_name_'..r..'_'..k, checkerInputs.unicalName[k][r], 256)
                                                imgui.PopItemWidth()
                                                imgui.SameLine()
                                                imgui.IconHelpButton(('+'), 'Нажмите, чтобы сохранить', function()
                                                    checker():setUnicalName(k, r, u8:decode(str(checkerInputs.unicalName[k][r])))
                                                end)
                                            end
                                            imgui.EndPopup()
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                imgui.EndChild()
                imgui.PopStyleVar()
            end
            if menuItem == 6 then
                centertextsize('Формы', 21)
                imgui.SetCursorPosX(5)
                imgui.BeginGroup()
                if imgui.ToggleButton('Состояние##EnabledForms', elements.toggle.enabledForms) then
                    ini.main.enabledForms = elements.toggle.enabledForms[0]
                    save()
                end
                if imgui.SliderInt('##timeoutforms', elements.int.formsTimeOut, 0, 60) then
                    ini.main.formsTimeOut = elements.int.formsTimeOut[0]
                    save()
                end imgui.SameLine() textsize('Время ожидания формы', 20)
                if formaTrueHotKey:ShowHotKey(imgui.ImVec2(150, 25)) then
                    ini.hotkey.formaTrue = encodeJson(formaTrueHotKey:GetHotKey())
                    save()
                end imgui.SameLine()    textsize('Принять форму', 20)
                if formaFalseHotKey:ShowHotKey(imgui.ImVec2(150, 25)) then
                    ini.hotkey.formaFalse = encodeJson(formaFalseHotKey:GetHotKey())
                    save()
                end imgui.SameLine()    textsize('Пропустить форму', 20)
                if imgui.Button(u8('Настроить формы под уровень админ-прав'), imgui.ImVec2(-1, 30)) then
                    setFormsWithLvl()
                end
                
                imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 8.0)
                imgui.BeginChild('##formsenabled', imgui.ImVec2(0,0), true)
                
                local count = get_table_count(ini.forms)
                local num = 0
                textsize('Формы', 20) imgui.SameLine(335) textsize('Статус', 20)
                imgui.Separator()
                imgui.Columns(2, '##formscolumns', false)
                for k,v in pairs(ini.forms) do
                    num = num + 1
                    
                    textsize('/'..k, 19) 
                    imgui.NextColumn()
                    
                    if imgui.ToggleButton('###forma_'..k, elements.forms[k]) then
                        ini.forms[k] = elements.forms[k][0]
                        save()
                    end
                    if num ~= count then
                        imgui.NextColumn()
                        imgui.Separator()
                    end
                end
                imgui.Columns(1)
                imgui.EndChild()
                imgui.PopStyleVar()
                imgui.EndGroup()
            end
            if menuItem == 7 then 
                centertextsize('Настройка биндера', 21)
                local ctext = function(text)  imgui.PushFont(Font[19])   imgui.SetCursorPosX(imgui.GetCursorPos().x + (imgui.GetColumnWidth() - 7 - imgui.CalcTextSize(u8(tostring(text))).x) / 2) imgui.Text(u8(tostring(text)))  imgui.PopFont() end
                local ctext1 = function(text)  imgui.PushFont(Font[19])   imgui.SetCursorPosX(imgui.GetCursorPos().x + (imgui.GetColumnWidth() - 7 - imgui.CalcTextSize(u8(tostring(text))).x) / 2) imgui.TextDisabled(u8(tostring(text)))  imgui.PopFont() end
                imgui.SetCursorPosX(5)
                imgui.BeginGroup()
                imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 6.0)
                if imgui.Button(u8('Добавить')) then
                    binder():newBind()
                end
                imgui.PopStyleVar(1)
                imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 8.0)
                imgui.BeginChild('####bindermenueee33', imgui.ImVec2(0,0), true)
                imgui.Columns(5, '##BinderMenu', false)
                -- imgui.SetColumnWidth(-1, 100)
                local count = get_table_count(binderCfg.list)
                local num = 0
                local lastnum = 0
                imgui.SetCursorPosY(imgui.GetCursorPos().y + 2)
                
                imgui.IconHelpButton(('#'), 'Номер бинда', function() end, true) imgui.SetColumnWidth(-1, 50)
                imgui.NextColumn()
                imgui.SetCursorPosY(imgui.GetCursorPos().y + 2)
                imgui.IconHelpButton(('on/off'), 'Состояние бинда', function() end, true) imgui.SetColumnWidth(-1, 50)
                imgui.NextColumn()
                ctext1('Клавиша') imgui.SetColumnWidth(-1, 100)
                imgui.NextColumn()
                ctext1('Название бинда') imgui.SetColumnWidth(-1, 330)
                imgui.NextColumn() 
                ctext1('Действия') imgui.SetColumnWidth(-1, 160)
                imgui.NextColumn()
                if count > 0 then
                    local max = get_table_max(binderCfg.list, 'xui')
                    for i=1, max do
                        local k = tostring(i)
                        if binderCfg.list[k] ~= nil then
                            imgui.Separator()
                            ctext(k) imgui.SetColumnWidth(-1, 50)
                            imgui.NextColumn()
                            
                            if imgui.ToggleButton('###active_'..k, binderCfg.active[k]) then
                                binder():setParam(k, 'active', binderCfg.active[k][0])
                            end imgui.SetColumnWidth(-1, 50)
                            imgui.NextColumn()
                            ctext(name_hotkey(binderCfg.key[k])) imgui.SetColumnWidth(-1, 100)
                            imgui.NextColumn()
                            imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x + 1, imgui.GetCursorPos().y + 2))
                            ctext(binderCfg.list[k]['name'])
                            imgui.SetColumnWidth(-1, 330)
                            imgui.NextColumn()
                            imgui.SetColumnWidth(-1, 160)
                            imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x - 9, imgui.GetCursorPos().y + 4))
                            imgui.IconHelpButton(('+'), 'Нажмите, чтобы редактировать', function() 
                                imgui.OpenPopup('##Popup_Settings_'..k)
                                binderCfg.activeFrame[k][0] = true
                            end, true)
                            imgui.SameLine()
                            imgui.IconHelpButton(('-'), 'Нажмите, чтобы удалить', function()
                                binderCfg.key[k]:RemoveHotKey()
                                binder():deleteBind(k)
                            end, false, false) 
                            
                            imgui.NextColumn()
                        end
                    end
                end
                imgui.Columns(1)
                if count > 0 then
                    for k,v in pairs(binderCfg.list) do
                        if imgui.BeginPopupModal('##Popup_Settings_'..k, binderCfg.activeFrame[k], imgui.WindowFlags.NoResize) then
                            centertextsize(binderCfg.list[k]['name'], 21)
                            imgui.Separator()
                            textsize('Описание', 20)
                            imgui.PushItemWidth(400)
                            imgui.InputText('##InputText_name_set_'..k, binderCfg.name[k], 256)
                            imgui.PopItemWidth()
                            textsize('Активация', 20)
                            if binderCfg.key[k]:ShowHotKey(imgui.ImVec2(183, 25)) then
                                binder():resetHotKey(k, encodeJson(binderCfg.key[k]:GetHotKey()))
                            end imgui.SameLine() textsize('или', 19) 
                            imgui.SameLine() imgui.PushItemWidth(183) imgui.InputTextWithHint('####inputtext_command_set_'..k, u8('Команда'), binderCfg.command[k], 256) imgui.PopItemWidth()
                            textsize('Задержка', 20)
                            imgui.PushItemWidth(100)
                            imgui.InputInt('###InputInt_wait_set_'..k, binderCfg.wait[k],0,0)
                            imgui.PopItemWidth() imgui.SameLine() textsize('в секундах', 19)
                            local binder_vars = {
                                '{id} - Вернёт ваш ID',
                                '{nick} - Вернёт ваш NickName',
                                '{alvl} - Вернёт ваш Админ-ЛВЛ',
                                '{ping} - Вернёт ваш Пинг',
                                '{report:nick} - Вернёт NickName из последнего репорта',
                                '{report:id} - Вернёт ID из последнего репорта',
                                '{report:text} - Вернёт текст последнего репорта',
                                '{report:answer} - Вернёт ваш введённый ответ в репорт',
                                '/local *text* - Вернёт просто белую строку, не будет отправлять в чат.',
                                '/enter *text* - Вернёт текст в чат, но не отправит его',
                                '{targetId} - Вернёт ID затаргеченного игрока. Для таргета: /target [ID]'
                            }
                            local binder_string = ''
                            for i=1, #binder_vars do
                                binder_string = binder_string .. binder_vars[i] .. '\n'
                            end
                            textsize('Настройка текста ') imgui.SameLine() imgui.IconHelpButton(faicons('CIRCLE_INFO'), 
                                'В биндере можно использовать паттерны:\n' .. binder_string, function() end)
                            imgui.PushItemWidth(-1)
                            imgui.InputTextMultiline(u8"##unput_test_xtcfg_"..k, binderCfg.text[k], 256)
                            imgui.PopItemWidth()
                            if imgui.Button(u8('Сохранить'), imgui.ImVec2(-1,30)) then
                                if #str(binderCfg.text[k]) ~= 0 then
                                    binder():setText(k, u8:decode(str(binderCfg.text[k])))
                                    binderCfg.activeFrame[k][0] = false
                                    imgui.CloseCurrentPopup()
                                else
                                    binder():setText(k, "")
                                    binderCfg.activeFrame[k][0] = false
                                    imgui.CloseCurrentPopup()
                                end
                                binder():save(k)
                            end
                            imgui.EndPopup()
                        end
                    end
                end
                imgui.EndChild()
                imgui.PopStyleVar(1)
                
                imgui.EndGroup()
            end 
            if menuItem == 8 then
                centertextsize('Настройка авто-репорта', 21)
                local ctext = function(text)  imgui.PushFont(Font[19])   imgui.SetCursorPosX(imgui.GetCursorPos().x + (imgui.GetColumnWidth() - 7 - imgui.CalcTextSize(u8(tostring(text))).x) / 2) imgui.Text(u8(tostring(text)))  imgui.PopFont() end
                local ctext1 = function(text)  imgui.PushFont(Font[19])   imgui.SetCursorPosX(imgui.GetCursorPos().x + (imgui.GetColumnWidth() - 7 - imgui.CalcTextSize(u8(tostring(text))).x) / 2) imgui.TextDisabled(u8(tostring(text)))  imgui.PopFont() end
                
                imgui.SetCursorPosX(5)
                imgui.BeginGroup()
                imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 6.0)
                if imgui.Button(u8('Добавить')) then
                    autoreport():newButton()
                end
                imgui.PopStyleVar(1)
                imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 8.0)
                imgui.BeginChild('####settingsAutoReport', imgui.ImVec2(0,0), true)
                    imgui.Columns(5, '##colunsautoreport', false)
                    imgui.SetCursorPosY(imgui.GetCursorPos().y + 2)
                    imgui.IconHelpButton(('#'), 'Номер кнопки', function() end, true) imgui.SetColumnWidth(-1, 50)
                    imgui.NextColumn()
                    ctext1('') imgui.SetColumnWidth(-1, 75)
                    imgui.NextColumn()
                    ctext1('Кнопка') imgui.SetColumnWidth(-1, 130)
                    imgui.NextColumn()
                    ctext1('Текст') imgui.SetColumnWidth(-1, 355)
                    imgui.NextColumn()
                    ctext1('Действия')
                    imgui.NextColumn()
                    if get_table_count(autoreportCfg.list) ~= 0 then
                        for i = 1, get_table_max(autoreportCfg.list, 'ura') do
                            local k = tostring(i)
                            if autoreportCfg.list[k] then
                                imgui.Separator()
                                ctext1(k) imgui.SetColumnWidth(-1, 50)
                                imgui.NextColumn()
                                local icons = autoreportCfg.list[k]['icon'] ~= 'not' and faicons(autoreportCfg.list[k]['icon']) or ''
                                imgui.SetCursorPosX(imgui.GetCursorPos().x + (imgui.GetColumnWidth() - 7 - imgui.CalcTextSize(icons).x) / 2)
                                imgui.SetCursorPosY(imgui.GetCursorPos().y + 3)
                                imgui.Text(icons)
                                imgui.SetColumnWidth(-1, 75)
                                imgui.NextColumn()
                                ctext(autoreportCfg.list[k]['button']) imgui.SetColumnWidth(-1, 130)
                                imgui.NextColumn()
                                ctext(autoreportCfg.list[k]['text']) imgui.SetColumnWidth(-1, 355)
                                imgui.NextColumn()
                                imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x - 9, imgui.GetCursorPos().y + 2))
                                imgui.IconHelpButton(('+'), 'Нажмите, чтобы редактировать', function()
                                    imgui.OpenPopup('##AutoReport_Settings_'..k)
                                    autoreportCfg.activeFrame[k][0] = true
                                    faiconsReport.uuid[0] = autoreportCfg.iconInt[k][0]
                                end, true) imgui.SameLine()
                                imgui.IconHelpButton(('-'), 'Нажмите, чтобы удалить', function()
                                    autoreport():deleteButton(k)
                                end, false, false)
                                imgui.NextColumn()
                            end

                        end
                    end
                    imgui.Columns(1)
                    for k,v in pairs(autoreportCfg.list) do
                        if imgui.BeginPopupModal('##AutoReport_Settings_'..k, autoreportCfg.activeFrame[k], imgui.WindowFlags.NoResize) then
                            centertextsize(autoreportCfg.list[k]['button'], 21)
                            imgui.Separator()
                            textsize('Название', 20)
                            imgui.PushItemWidth(225)
                            imgui.InputText('###AutoReport_Settings_Input_'..k, autoreportCfg.button[k], 128) 
                            imgui.PopItemWidth()
                            imgui.Separator()
                            textsize('Текст, который будет отправляться', 20)
                            imgui.PushItemWidth(450)
                            imgui.InputText('###AutoReport_Settings_InputText_'..k, autoreportCfg.text[k], 128)
                            imgui.PopItemWidth()
                            if imgui.Button(u8('Сохранить'), imgui.ImVec2(-1,30)) then
                                autoreport():save(k)
                            end
                            imgui.EndPopup()
                        end
                    end
                imgui.EndChild()
                imgui.PopStyleVar(1)
                imgui.EndGroup()
            end
            if menuItem == 9 then
                centertextsize('Команды тулса', 21)
                imgui.SetCursorPosX(5)
                imgui.BeginGroup()
                imgui.PushFont(Font[19])
                    imgui.TextColoredRGB(u8('{ff0000}!{ffffff} - команды для старшей администрации'))
                imgui.PopFont()
                imgui.Spacing()
                imgui.Spacing()
                for i=1, #LiteTools_Commands do
                    local k,v = LiteTools_Commands[i].cmd, LiteTools_Commands[i].desc
                    imgui.PushFont(Font[19])
                    imgui.TextColoredRGB(k..' - {CECECE}'..v)
                    imgui.PopFont()
                end
                imgui.EndGroup()
                
               
            end
            

            if menuItem == 11 then
                centertextsize('Лог обновлений', 21)
                imgui.SetCursorPosX(5)
                imgui.BeginGroup()
                if imgui.CollapsingHeader(u8("Обновление 1.2 beta")) then
                    if imgui.BeginChild("##update_1.3", imgui.ImVec2(-1, 105), true) then
                        textsize(
                            "-  Оптимизирован код\n"
                            .. "- Убраны ненужные функции\n"
                            .. "- Убраны различные иконки\n", 
                            10
                        )
                        imgui.EndChild()
                    end
                end
                imgui.EndGroup()
            end
        
            do
                imgui.SetCursorPos(imgui.ImVec2(687 - 10, 1))
                imgui.CloseButton('##CloseButton', windows.AdminTools, 20, 12)
            end
            
            imgui.EndChild()
        end
        imgui.PopStyleVar(1)
        imgui.End()

    end
)



function get_table_element(table, index)
    local num = 0
    for k,v in pairs(table) do
        num = num + 1
        if num == index then
            return k,v
        end
    end
    return nil
end
function imgui.HelpButton(title, text)
    imgui.Button(u8(title))
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(u8(text))
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end
function int2float(integer)
    return integer + 0.0
end


function set_player_skin(skin)
    local BS = raknetNewBitStream()
    raknetBitStreamWriteInt32(BS, getMyId())
    raknetBitStreamWriteInt32(BS, skin)
    raknetEmulRpcReceiveBitStream(153, BS)
    raknetDeleteBitStream(BS)
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local col = imgui.Col
    
    local designText = function(text__)
        local pos = imgui.GetCursorPos()
        if sampGetChatDisplayMode() == 2 then
            for i = 1, 1 --[[Степень тени]] do
                imgui.SetCursorPos(imgui.ImVec2(pos.x + i, pos.y))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x - i, pos.y))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y + i))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y - i))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
            end
        end
        imgui.SetCursorPos(pos)
    end
    
    
    
    local text = text:gsub('{(%x%x%x%x%x%x)}', '{%1FF}')

    local color = colors[col.Text]
    local start = 1
    local a, b = text:find('{........}', start)   
    
    while a do
        local t = text:sub(start, a - 1)
        if #t > 0 then
            designText(t)
            imgui.TextColored(color, t)
            imgui.SameLine(nil, 0)
        end

        local clr = text:sub(a + 1, b - 1)
        if clr:upper() == 'STANDART' then color = colors[col.Text]
        else
            clr = tonumber(clr, 16)
            if clr then
                local r = bit.band(bit.rshift(clr, 24), 0xFF)
                local g = bit.band(bit.rshift(clr, 16), 0xFF)
                local b = bit.band(bit.rshift(clr, 8), 0xFF)
                local a = bit.band(clr, 0xFF)
                color = imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
            end
        end

        start = b + 1
        a, b = text:find('{........}', start)
    end
    imgui.NewLine()
    if #text >= start then
        imgui.SameLine(nil, 0)
        designText(text:sub(start))
        imgui.TextColored(color, text:sub(start))
    end
end

function sampev.onPlayerChatBubble(playerId, color, distance, duration, message)
    if sampIsPlayerConnected(playerId) and bubbleBox then
        bubbleBox:add_message(playerId, color, distance, message)
    end
end
function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function onExitScript(booleanTrue)
    if bubbleBox then bubbleBox:free() end
end
function sampev.onShowMenu()
	if rInfo.id ~= -1 then
		return false
	end
end
function sampev.onHideMenu()
	if rInfo.id ~= -1 then
		return false
	end
end
function sampev.onTogglePlayerSpectating(state)
	rInfo.state = state
	if not state then
		rInfo.id = -1
    end
end
function sampev.onShowTextDraw(id, data)
    if is_recon() then
		lua_thread.create(function()
			while true do
				wait(0)
                local notTD = {2139, 2140, 2141, 2142, 2143, 2144, 2145}
                for k,v in pairs(notTD) do
                    if id == v then
                        sampTextdrawDelete(id)
                    end
                end
				break
			end
		end)
	end
end
function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
 end
function sampev.onSendCommand(cmd)
    if cmd:find("%/a%s+(.*)") then
        local text = cmd:match("%/a%s+(.*)")
        if text:find("@(%d+)") then
            local id = text:match("@(%d+)")
            if sampIsPlayerConnected(id) then
                text = text:gsub("@"..id, sampGetPlayerNickname(id))
                sampSendChat("/a "..text)
                return false
            else
                message():error("Данного игрока нет на сервере!")
                return false
            end
        end
    end
    if cmd:find('^/veh%s(%d+)%s(%d+)%s(%d+)') and not veh.act and elements.toggle.zzveh[0] then
        veh.id, veh.c1, veh.c2 = cmd:match('^/veh%s(%d+)%s(%d+)%s(%d+)')
        veh.active = true
        veh.time = os.time()
        veh.car = cmd
    end
    for k,v in pairs(binderCfg.list) do
        if string.starts(cmd, '/') then
            if cmd == binderCfg.list[k]['command'] then
                if binderCfg.list[k]['active'] then
                    if #str(binderCfg.text[k]) ~= 0 then
                        lua_thread.create(function()
                            local ar = {nick='nil', id=0, text='nil'}
                            if report.players[1] ~= nil then
                                ar = {nick=report.players[1].nickname, id=report.players[1].id, text=report.players[1].text}
                            end
                            local binder_var = {
                                ['{id}'] = getMyId(),
                                ['{nick}'] = getMyNick(),
                                ['{alvl}'] = ini.auth.adminLVL,
                                ['{ping}'] = sampGetPlayerPing(getMyId()),
                                ['{report:nick}'] = ar.nick,
                                ['{report:id}'] = ar.id,
                                ['{report:text}'] = ar.text,
                                ['{report:answer}'] = u8:decode(ffi.string(elements.input.reportAnswer)) or "-1",
                                ['{targetId}'] = binder():getTargetId()
                            }
                            for _,r in pairs(binder():split(u8:decode(str(binderCfg.text[k])))) do
                                for k,v in pairs(binder_var) do
                                    r = r:gsub(k, tostring(v))
                                end
                                if r:find('^%/local ') then
                                    r = r:gsub('^%/local ', '')
                                    sampAddChatMessage(r, -1)
                                elseif r:find('^%/enter ') then
                                    r = r:gsub('^%/enter ', '')
                                    sampSetChatInputEnabled(true)
                                    sampSetChatInputText(r)
                                else
                                    sampSendChat(r)
                                end
                                wait(tonumber(binderCfg.wait[k][0]) .. '000')
                            end
                        end)
                    end
                end
            end
        end
    end
    if cmd:find('/re%s+(%d+)') then
        rID = cmd:match('/re%s+(%d+)')
        if rID:len() > -1 and rID:len() < 4 then
            if not rInfo.update_recon then
                rInfo.id = tonumber(rID)
                rInfo.time = os.time()
                rInfo.fraction = nil
                rInfo.playerTimes = nil
                rInfo.que = false
                keyLogger.target = select(2, sampGetCharHandleBySampPlayerId(rInfo.id))
                keyLogger.playerId = rInfo.id
                message():info('Вы зашли в рекон. Выйти: /re off, чтобы включить курсор: ПКМ.')
            else
                rInfo.update_recon = false
            end
        else
            message():error('Укажите правильный ID!')
        end
        
    elseif cmd:find('/RE%s+(%d+)') then
        rID = cmd:match('/RE%s+(%d+)')
        if rID:len() > -1 and rID:len() < 4 then
            if not rInfo.update_recon then
                rInfo.id = tonumber(rID)
                rInfo.time = os.time()
                rInfo.fraction = nil
                rInfo.playerTimes = nil
                rInfo.que = false
                message():info('Вы зашли в рекон. Выйти: /re off, чтобы включить курсор: ПКМ.')
            else
                rInfo.update_recon = false
            end
        else
            message():error('Укажите правильный ID!')
        end
    end
    if cmd == '/re off' then
        rInfo = {
            state = false,
            id = -1,
            dist = 2,
            fraction = nil,
            playerTimes = 0,
            que = false,
            update_recon = false
        }
        keyLogger = {
            playerId = -1,
            target = -1,
            table = {
                ['onfoot'] = {},
                ['vehicle'] = {}
            },
            fon = new.int(ini.style.keyLoggerFon)
        }
    end
    if rID then
        enAirBrake = false
    end
    
end



function checkAdminsTeam()
    lua_thread.create(function()
        adminMonitor.active = true
        wait(300)
        sampSendChat('/admins')
        adminMonitor.AFK = 0
        adminMonitor.RECON = 0
        wait(1000)
        adminMonitor.active = false
    end)
end

function get_distance_to_player(playerId)
    if sampIsPlayerConnected(playerId) then
        local result, ped = sampGetCharHandleBySampPlayerId(playerId)
        if result and doesCharExist(ped) then
            local myX, myY, myZ = getCharCoordinates(playerPed)
            local playerX, playerY, playerZ = getCharCoordinates(ped)
            return getDistanceBetweenCoords3d(myX, myY, myZ, playerX, playerY, playerZ)
        end
    end
    return nil
end
function bgra_to_argb(bgra)
    local b, g, r, a = explode_argb(bgra)
    return join_argb(a, r, g, b)
end

function set_argb_alpha(color, alpha)
        local _, r, g, b = explode_argb(color)
        return join_argb(alpha, r, g, b)
end

function get_argb_alpha(color)
    local alpha = explode_argb(color)
    return alpha
end

function argb_to_rgb(argb)
    return bit.band(argb, 0xFFFFFF)
end
function cyrillic(text)
    local convtbl = {[230]=155,[231]=159,[247]=164,[234]=107,[250]=144,[251]=168,[254]=171,[253]=170,[255]=172,[224]=97,[240]=112,[241]=99,[226]=162,[228]=154,[225]=151,[227]=153,[248]=165,[243]=121,[184]=101,[235]=158,[238]=111,[245]=120,[233]=157,[242]=166,[239]=163,[244]=63,[237]=174,[229]=101,[246]=36,[236]=175,[232]=156,[249]=161,[252]=169,[215]=141,[202]=75,[204]=77,[220]=146,[221]=147,[222]=148,[192]=65,[193]=128,[209]=67,[194]=139,[195]=130,[197]=69,[206]=79,[213]=88,[168]=69,[223]=149,[207]=140,[203]=135,[201]=133,[199]=136,[196]=131,[208]=80,[200]=133,[198]=132,[210]=143,[211]=89,[216]=142,[212]=129,[214]=137,[205]=72,[217]=138,[218]=167,[219]=145}
    local result = {}
    for i = 1, #text do
        local c = text:byte(i)
        result[i] = string.char(convtbl[c] or c)
    end
    return table.concat(result)
end

function sampev.onServerMessage(color, text)
    if define.check then
        if text:find("^Список жалоб пуст") then
            message():info("Список жалоб пуст.")
            return false
        end
    end
    if text:find("^Вы изменили уровень админ%-прав с (%d+) на (%d+) у (.*)") then
        local old_lvl, new_lvl, nick = text:match("^Вы изменили уровень админ%-прав с (%d+) на (%d+) у (.*)")
        message():info(("Вы изменили уровень админ-прав у {cecece}%s{ffffff} с {cecece}%s {ffffff}на {cecece}%s"):format(nick, old_lvl, new_lvl))
        return false
    end
    if text:find('^Репорт от (.*)%[(%d+)%]%: %{......%}(.*)') then
        local Rnickname, Rid, RtextP = text:match('^Репорт от (.*)%[(%d+)%]%: %{......%}(.*)')
        RtextP = string.gsub(RtextP, '%{......%}', '')
        local randomUUID = math.random(1,999999)
        if #report.players > 0 then
            for k,v in pairs(report.players) do
                if v.uuid == randomUUID then 
                    while v.uuid == randomUUID do randomUUID = math.random(1,999999) end
                end
            end
            report.players[#report.players + 1] = {nickname = Rnickname, id = Rid, text = RtextP, uuid = randomUUID}
        else
            report.players[#report.players + 1] = {nickname = Rnickname, id = Rid, text = RtextP, uuid = randomUUID}
        end
        if elements.toggle.pushReport[0] then
            message():notify('Репорт от '..Rnickname..'['..Rid..']\nТекст: '..RtextP, 1, 3)
        end
	end
    if #report.players > 0 then
        if color == -1343295745 then
            for k, v in pairs(report.players) do
                if k == 1 then
                    if text:find('%[.%] (.*)%[(%d+)%] ответил игроку '..report.players[1].nickname..'%['..report.players[1].id..'%]: (.*)') then
                        local nick,id,text = text:match('%[.%] (.*)%[(%d+)%] ответил игроку '..report.players[1].nickname..'%['..report.players[1].id..'%]: (.*)')
                        local result = false
                        if #reportAnswerProcess > 0 then
                            for k,v in pairs(reportAnswerProcess) do
                                for _,r in pairs(report.players) do
                                    if v.reportUUID == r.uuid then
                                        result = true
                                    end
                                end
                            end
                            if not result then
                                reportAnswerProcess[#reportAnswerProcess + 1] = {nick=nick,id=id,text=text, textP = report.players[1].text, reportUUID = report.players[1].uuid }
                            end
                        else
                            reportAnswerProcess[#reportAnswerProcess + 1] = {nick=nick,id=id,text=text, textP = report.players[1].text, reportUUID = report.players[1].uuid }
                        end
                        if not windows.reportPanel[0] then
                            refresh_current_report()
                        end
                    end
                elseif k > 1 then
                    if text:find('%[.%] (.*)%[(%d+)%] ответил игроку '..report.players[k].nickname..'%['..report.players[k].id..'%]: (.*)') then

                        table.remove(report.players, k)
                    end
                end
            end
        end
    end
    if text:find('^Запрещенно создавать машину в зеленой зоне') and veh.active then
        createCarInZZ(veh.car)
        veh.active = false
        return false
    end
    if elements.toggle.enabledForms[0] then
        for k,v in pairs(ini.forms) do
            if text:match(".*%[.*%] "..getMyNick().."%["..getMyId().."%]%: /"..k.."%s") then
                return true
            else
                if text:match(".*%[.*%] (.*)%[(%d+)%]%: /"..k.."%s") then
                    if v == true then
                        local nick, id, text = text:match(".*%[.*%] (.*)%[(%d+)%]%: /"..k.."%s(.*)")
                        message():info('Форма от '..nick..'. Команда: /'..k..' '..text)
                        message():info('Чтобы её принять >> '..name_hotkey(formaTrueHotKey)..' <<')
                        message():info('Чтобы её отклонить >> '..name_hotkey(formaFalseHotKey)..' <<')
                        lua_thread.create(function()
                            lasttime = os.time()
                            lasttimes = 0
                            time_out = elements.int.formsTimeOut[0]
                            forma.active = true
                            while lasttimes < time_out do
                                lasttimes = os.time() - lasttime
                                wait(0)
                                if forma.stop then
                                    printStyledString(cyrillic('Форму принял другой администратор'), 1000, 4)
                                    forma.stop = false
                                    break
                                end
                                if forma.etrue then
                                    printStyledString(cyrillic('Форма принята'), 1000, 4)
                                    sampSendChat('/'..k..' '..text..' // '..nick)
                                    wait(1500)
                                    sampSendChat('/a [Forma] +')
                                    forma.etrue = false
                                    forma.active = false
                                    break
                                end
                                if forma.efalse then
                                    printStyledString(cyrillic('Форма отклонена'), 1000, 4)
                                    forma.efalse = false
                                    forma.active = false
                                    sampSendChat('/a [Forma] -')
                                    break
                                end
                                printStyledString(cyrillic("АДМИН-ФОРМА " .. time_out - lasttimes .. " СЕКУНД"), 1000, 4)
                                if lasttimes == time_out then
                                    forma.active = false
                                    printStyledString(cyrillic("Форма пропущена"), 1000, 4)
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
    if forma.active then
        if text:find('^%[.*%] (.*)%[(%d+)%]%: %[Forma%] %+') or text:find('^%[.*%] (.*)%[(%d+)%]%: %[Forma%] %- True. Command: .*') then
            forma.active = false
            forma.stop = true
        end
    end
    if text:find('^Пожалуйста, не флудите') then
        return false
    end
    if text:find('%{FFFF00%}%| %{FFFFFF%}Вы (.*) двери этого транспортного средства') then
        local arg = text:match('%{FFFF00%}%| %{FFFFFF%}Вы (.*) двери этого транспортного средства')
        local status = arg:find('открыли')
        message():info(string.format('Машина %s', status and '{00ff00}открыта.' or '{ff0000}закрыта.'))
        return false
    end
    if text:find('^Для того, чтобы закончить слежку за игроком, введите: \'/re off\'') then
        return false
    end
    if text:find('Администрация в сети') and adminMonitor.active then return false end
    if text:find('^(.*)%[(%d+)%] %((%d+) lvl%)') and not text:find('^(.*)%[(%d+)%] %((%d+) lvl%) %{37b20e%}%> /re (%d+)') and not text:find('^(.*)%[(%d+)%] %((%d+) lvl%) %{dc2603%}AFK') then
        if adminMonitor.active then
            local nick, id, lvl = text:match('^(.*)%[(%d+)%] %((%d+) lvl%)') 
            local result = false
            for k,v in pairs(adminMonitor.admins) do
                if v.nick == nick then
                    result = true
                    table.remove(adminMonitor.admins, k)
                    table.insert(adminMonitor.admins, {
                        nick=nick,
                        id=id,
                        lvl=lvl,
                        action = 'not',
                        reId=1111
                    })
                end
            end
            if not result then
                table.insert(adminMonitor.admins, {
                    nick=nick,
                    id=id,
                    lvl=lvl,
                    action = 'not',
                    reId=1111
                })
            end
            return false
        end
    elseif text:find('^(.*)%[(%d+)%] %((%d+) lvl%) %{37b20e%}%> %/re (%d+)') then
        if adminMonitor.active then
            local nick, id, lvl, reId = text:match('^(.*)%[(%d+)%] %((%d+) lvl%) %{37b20e%}%> /re (%d+)')                
            
            local result = false
            for k,v in pairs(adminMonitor.admins) do
                if v.nick == nick then
                    result = true
                    if v.action ~= 're' then
                        
                        table.remove(adminMonitor.admins, k)
                        table.insert(adminMonitor.admins, {
                            nick=nick,
                            id=id,
                            lvl=lvl,
                            action = 're',
                            reId=reId
                        })
                        adminMonitor.RECON = adminMonitor.RECON + 1
                    else
                        adminMonitor.RECON = adminMonitor.RECON + 1
                    end
                end
            end
            if not result then
                table.insert(adminMonitor.admins, {
                    nick=nick,
                    id=id,
                    lvl=lvl,
                    action = 're',
                    reId=reId
                })
                adminMonitor.RECON = adminMonitor.RECON + 1
            end
            return false
        end
    elseif text:find('^(.*)%[(%d+)%] %((%d+) lvl%) %{dc2603%}AFK') then
        if adminMonitor.active then
            local nick,id,lvl = text:match('^(.*)%[(%d+)%] %((%d+) lvl%) %{dc2603%}AFK')                
            local result = false
            for k,v in pairs(adminMonitor.admins) do
                if v.nick == nick then
                    result = true
                    if v.action ~= 'AFK' then
                        
                        table.remove(adminMonitor.admins, k)
                        table.insert(adminMonitor.admins, {
                            nick=nick,
                            id=id,
                            lvl=lvl,
                            action = 'AFK',
                            reId=1111
                        })
                        adminMonitor.AFK = adminMonitor.AFK + 1
                    else
                        adminMonitor.AFK = adminMonitor.AFK + 1
                    end
                end
                
            end
            if not result then
                table.insert(adminMonitor.admins, {
                    nick=nick,
                    id=id,
                    lvl=lvl,
                    action = 'AFK',
                    reId=1111
                })
                adminMonitor.AFK = adminMonitor.AFK + 1
            end
            
            return false
        end
    end
    if text:find('^%[(.*)%] (.*)%[(%d+)%]: (.*)') and color == -4622081 then
        local aprefix, anick, aid, atext = text:match('^%[(.*)%] (.*)%[(%d+)%]: (.*)')
        if elements.toggle.reactionMention[0] then
            local mynick = string.rlower(getMyNick())
            if string.rlower(atext):find('@'..mynick) and string.rlower(anick) ~= mynick then
                message():notify('Вас упомянули в чате!', 2, 5, 1, string.format('Администратор %s[%s] упомянул вас в чате!', anick, aid))
            end
        end
    end
    if text:find('%[.*%] '..getMyNick()..'%['..getMyId()..'%] ответил игроку (.*)%[(%d+)%]: (.*)') then
        ini.onDay.reports = ini.onDay.reports + 1
        sessionReports = sessionReports + 1
        save()
    end
    if text:find('%[.*%] '..getMyNick()..'%['..getMyId()..'%] авторизовался как администратор (%d+) уровня') then
        local lvl = text:match('%[.*%] '..getMyNick()..'%['..getMyId()..'%] авторизовался как администратор (%d+) уровня')
        ini.auth.adminLVL = tonumber(lvl)
        ini.auth.active = true 
        save()
        if elements.toggle.togphoneSpawn[0] then
            lua_thread.create(function()
                while spawnProcess do wait(100) end
                wait(1000)
                sampSendChat('/agm')
            end)
        end 
    end
end
function get_table_count(table,except)
    local count = 0
    if type(table) == 'table' then
        for k,v in pairs(table) do
            if except ~= nil then
                if k ~= except then
                    count = count + 1
                end
            else
                count = count + 1
            end
        end
    end
    return count
end
function get_table_max(table,except)
    local num = 0
    for k,v in pairs(table) do
        if except ~= nil and k ~= except then
            if tonumber(k) > num then
                num = tonumber(k)
            end
        end
    end
    return num
end

function sortPairs(t,f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end
function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end
function get_table_element_index(table, except)
    local num = 0
    for k,v in pairs(table) do
        num = num + 1
        if v == except then
            return num
        end
    end
end
function find_nick(nick)
    local num = 0
    for k,v in pairs(adminMonitor.admins) do
        num = num + 1
        if v.nick == except then
            return num
        end
    end
end
local frameDrawList = imgui.OnFrame(
    function() return windowDrawList[0] end, -- если указать "#bullets ~= 0", то курсор появляется и пропадет при выстрелов на первом запуске скрипта
    function(self)
        function bringFloatTo(from, dest, start_time, duration) -- спс космо за функи
            local timer = os.clock() - start_time
            if timer >= 0 and timer <= duration then
                local count = timer / (duration / 100)
                return from + (count * (dest - from) / 100)
            end
            return (timer > duration) and dest or from
        end
        self.HideCursor = true
        local dl = imgui.GetBackgroundDrawList()
        local resX, resY = getScreenResolution()

        for i=#bullets, 1, -1 do
            local target_offset = {
                x = bringFloatTo(bullets[i].origin.x, bullets[i].target.x, bullets[i].clock, bullets[i].transition),
                y = bringFloatTo(bullets[i].origin.y, bullets[i].target.y, bullets[i].clock, bullets[i].transition),
                z = bringFloatTo(bullets[i].origin.z, bullets[i].target.z, bullets[i].clock, bullets[i].transition)
            }

            local _, oX, oY, oZ, _, _ = convert3DCoordsToScreenEx(bullets[i].origin.x, bullets[i].origin.y, bullets[i].origin.z)
            local _, tX, tY, tZ, _, _ = convert3DCoordsToScreenEx(target_offset.x, target_offset.y, target_offset.z)
            -- local result, object = findAllRandomObjectsInSphere(target_offset.x, target_offset.y, target_offset.z, 1, false)
            -- if result then chat.log('DETECTED WALLSHOT - ID: %d - MODEL ID: %d', bullets[i].id, getObjectModel(object)) end
            local col4u32 = imgui.ImVec4(bullets[i].col4[0], bullets[i].col4[1], bullets[i].col4[2], bullets[i].alpha)

            if config_imgui.settings.enabled_bullets_in_screen[0] then
                if oZ > 0 and tZ > 0 then -- default
                    dl:AddLine(imgui.ImVec2(oX, oY), imgui.ImVec2(tX, tY), imgui.GetColorU32Vec4(col4u32), bullets[i].thickness)
                    if bullets[i].draw_polygon then
                        dl:AddCircleFilled(imgui.ImVec2(tX, tY), bullets[i].circle_radius, imgui.GetColorU32Vec4(col4u32), bullets[i].degree_polygon)
                    end
                elseif oZ <= 0 and tZ > 0 then -- fix origin coords --! default circle
                    local newPos = getFixScreenPos(target_offset, bullets[i].origin, tZ)
                    local _, oX, oY, oZ, _, _ = convert3DCoordsToScreenEx(newPos.x, newPos.y, newPos.z)
                    dl:AddLine(imgui.ImVec2(oX, oY), imgui.ImVec2(tX, tY), imgui.GetColorU32Vec4(col4u32), bullets[i].thickness)
                    if bullets[i].draw_polygon then dl:AddCircleFilled(imgui.ImVec2(tX, tY), bullets[i].circle_radius, imgui.GetColorU32Vec4(col4u32), bullets[i].degree_polygon) end
                elseif oZ > 0 and tZ <= 0 then -- fix target coords --! dont draw circle
                    local newPos = getFixScreenPos(bullets[i].origin, target_offset, oZ)
                    local _, tX, tY, tZ, _, _ = convert3DCoordsToScreenEx(newPos.x, newPos.y, newPos.z)
                    dl:AddLine(imgui.ImVec2(oX, oY), imgui.ImVec2(tX, tY), imgui.GetColorU32Vec4(col4u32), bullets[i].thickness)
                end
            else
                if tZ > 0 then
                    if oZ > 0 then dl:AddLine(imgui.ImVec2(oX, oY), imgui.ImVec2(tX, tY), imgui.GetColorU32Vec4(col4u32), bullets[i].thickness) end
                    if bullets[i].draw_polygon then dl:AddCircleFilled(imgui.ImVec2(tX, tY), bullets[i].circle_radius, imgui.GetColorU32Vec4(col4u32), bullets[i].degree_polygon) end
                end
            end

            -- Плавное исчезновение
            if (os.clock() - bullets[i].clock > bullets[i].timer) and (bullets[i].alpha > 0) then
                bullets[i].alpha = bullets[i].alpha - bullets[i].step_alpha
            end
            -- Удаляем пуль, если альфа ниже 0
            if bullets[i].alpha < 0 then
                table.remove(bullets, i)
                if #bullets == 0 then break end
            end
        end

    end
)
function cyrillic(text)
    local convtbl = {[230]=155,[231]=159,[247]=164,[234]=107,[250]=144,[251]=168,[254]=171,[253]=170,[255]=172,[224]=97,[240]=112,[241]=99,[226]=162,[228]=154,[225]=151,[227]=153,[248]=165,[243]=121,[184]=101,[235]=158,[238]=111,[245]=120,[233]=157,[242]=166,[239]=163,[244]=63,[237]=174,[229]=101,[246]=36,[236]=175,[232]=156,[249]=161,[252]=169,[215]=141,[202]=75,[204]=77,[220]=146,[221]=147,[222]=148,[192]=65,[193]=128,[209]=67,[194]=139,[195]=130,[197]=69,[206]=79,[213]=88,[168]=69,[223]=149,[207]=140,[203]=135,[201]=133,[199]=136,[196]=131,[208]=80,[200]=133,[198]=132,[210]=143,[211]=89,[216]=142,[212]=129,[214]=137,[205]=72,[217]=138,[218]=167,[219]=145}
    local result = {}
    for i = 1, #text do
        local c = text:byte(i)
        result[i] = string.char(convtbl[c] or c)
    end
    return table.concat(result)
end
ChatBox = function(pagesize, blacklist)
    local obj = {
      pagesize = elements.int.limitPageSize[0],
          active = false,
          font = nil,
          messages = {},
          blacklist = blacklist,
          firstMessage = 0,
          currentMessage = 0,
    }

      function obj:initialize()
          if self.font == nil then
              self.font = renderCreateFont('Verdana', 8, FCR_BORDER + FCR_BOLD)
          end
      end

      function obj:free()
          if self.font ~= nil then
              renderReleaseFont(self.font)
              self.font = nil
          end
      end

      function obj:toggle(show)
          self:initialize()
          self.active = show
      end

    function obj:draw(x, y)
          local add_text_draw = function(text, color)
              renderFontDrawText(self.font, text, x, y, color)
              y = y + renderGetFontDrawHeight(self.font)
          end

          -- draw caption
      add_text_draw(u8:decode(str(elements.input.bubbleBoxName))..':', 0xFFE4D8CC)

          -- draw page indicator
          if #self.messages == 0 then return end
          local cur = self.currentMessage
          local to = cur + math.min(self.pagesize, #self.messages) - 1
          add_text_draw(string.format("%d/%d", to, #self.messages), 0xFFE4D8CC)

          -- draw messages
          x = x + 4
          for i = cur, to do
              local it = self.messages[i]
              add_text_draw(
                  string.format("{E4E4E4}[%s] (%.1fm) {%06X}%s{D4D4D4}({EEEEEE}%d{D4D4D4}): {%06X}%s",
                      it.time,
                      it.dist,
                      argb_to_rgb(it.playerColor),
                      it.nickname,
                      it.playerId,
                      argb_to_rgb(it.color),
                      it.text),
                  it.color)
          end
    end

      function obj:add_message(playerId, color, distance, text)
          -- ignore blacklisted messages
          if self:is_text_blacklisted(text) then return end

          -- process only streamed in players
          local dist = get_distance_to_player(playerId)
          if dist ~= nil then
              color = bgra_to_argb(color)
              if dist > distance then color = set_argb_alpha(color, 0xA0)
              else color = set_argb_alpha(color, 0xF0)
              end
              table.insert(self.messages, {
                  playerId = playerId,
                  nickname = sampGetPlayerNickname(playerId),
                  color = color,
                  playerColor = sampGetPlayerColor(playerId),
                  dist = dist,
                  distLimit = distance,
                  text = text,
                  time = os.date('%X')})

              -- limit message list
              if #self.messages > elements.int.maxPagesBubble[0] then
                  self.messages[self.firstMessage] = nil
                  self.firstMessage = #self.messages - elements.int.maxPagesBubble[0]
              else
                  self.firstMessage = 1
              end
              self:scroll(1)
          end
      end

      function obj:is_text_blacklisted(text)
          for _, t in pairs(self.blacklist) do
              if string.match(text, t) then
                  return true
              end
          end
          return false
      end

      function obj:scroll(n)
          self.currentMessage = self.currentMessage + n
          if self.currentMessage < self.firstMessage then
              self.currentMessage = self.firstMessage
          else
              local max = math.max(#self.messages, self.pagesize) + 1 - self.pagesize
              if self.currentMessage > max then
                  self.currentMessage = max
              end
          end
      end

    setmetatable(obj, {})
    return obj
end
function az()
    lua_thread.create(function()
        sampSendChat('/tp')
        wait(200)
        sampSendDialogResponse(sampGetCurrentDialogId(), 1, 0, nil)
        sampCloseCurrentDialogWithButton(0)
    end)
end
addEventHandler('onWindowMessage', function(msg, param)
    if msg == 0x0100 and param == VK_Z then
        consumeWindowMessage(true, false)
    elseif msg == 0x020a and isKeyDown(VK_Z) then
        consumeWindowMessage(true, false)
    end
end)
function isCharAiming(ped)
    return memory.getint8(getCharPointer(ped) + 0x528, false) == 19
end
function setCameraDistance(distance)
    memory.setuint8(CCamera + 0x38, 1)
	memory.setuint8(CCamera + 0x39, 1)
	memory.setfloat(CCamera + 0xD4, distance)
	memory.setfloat(CCamera + 0xD8, distance)
	memory.setfloat(CCamera + 0xC0, distance)
	memory.setfloat(CCamera + 0xC4, distance)
end
function time()
    startTime = os.time()
    while true do
        wait(1000)
        if ini.auth.active then
            nowTime = os.date("%H:%M:%S", os.time())

            sessionOnline[0] = sessionOnline[0] + 1
            sessionFull[0] = os.time() - startTime
            sessionAfk[0] = sessionFull[0] - sessionOnline[0]
            

            ini.onDay.online = ini.onDay.online + 1
            ini.onDay.full = dayFull[0] + sessionFull[0]
            ini.onDay.afk = ini.onDay.full - ini.onDay.online

        else
            startTime = startTime + 1
        end
    end
end
function isPos()
    if changePosition.renderLogger then
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        ini.main.pos_logger_x, ini.main.pos_logger_y = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            
            message():info('Настройки успешно сохранены.')
            
            changePosition.renderLogger = false
            windows.AdminTools[0] = true
            
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            changePosition.renderLogger = false
            
            message():info('Вы успешно отменили смену позиции.')
            
            windows.AdminTools[0] = true
            
        end
    end

    if changePosition.playerStats then
        if not windows.playerStats[0] then
            windows.playerStats[0] = true
            windowsOpen = true
        end
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        ini.main.pos_stats_x, ini.main.pos_stats_y = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            
            message():info('Настройки успешно сохранены.')
            if windows.playerStats[0] and windowsOpen then
                windows.playerStats[0] = false
            end
            changePosition.playerStats = false
            windows.AdminTools[0] = true
            
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            changePosition.playerStats = false
            if windows.playerStats[0] and windowsOpen then
                windows.playerStats[0] = false
            end
            message():info('Вы успешно отменили смену позиции.')
            
            windows.AdminTools[0] = true
            
        end
    end
    if changePosition.renderAdmins then
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        ini.main.pos_render_admins_x, ini.main.pos_render_admins_y = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            
            message():info('Настройки успешно сохранены.')
            
            changePosition.renderAdmins = false
            windows.AdminTools[0] = true
            
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            changePosition.renderAdmins = false
            
            message():info('Вы успешно отменили смену позиции.')
            
            windows.AdminTools[0] = true
            
        end
    end
    if changePosition.bubble then
        showCursor(true, false)
        bubbleBox:toggle(true)
        local mouseX, mouseY = getCursorPos()
        ini.main.bubblePosX, ini.main.bubblePosY = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            message():info('Настройки успешно сохранены.')
            changePosition.bubble = false
            windows.AdminTools[0] = true
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            changePosition.bubble = false
            bubbleBox:toggle(false)
            message():info('Вы успешно отменили смену позиции.')
            windows.AdminTools[0] = true
        end
    end
    if changePosition.reconInfoPunish then
        if not windows.recon.punish[0] then
            windows.recon.punish[0] = true
        end
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        ini.main.pos_recon_punish_x, ini.main.pos_recon_punish_y = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            if windows.recon.punish[0] and not rInfo.state then
                windows.recon.punish[0] = false
            end
            message():info('Настройки успешно сохранены.')
            
            changePosition.reconInfoPunish = false
            windows.AdminTools[0] = true
            
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            changePosition.reconInfoPunish = false
            if windows.recon.punish[0] and not rInfo.state then
                windows.recon.punish[0] = false
            end
            message():info('Вы успешно отменили смену позиции.')
            
            windows.AdminTools[0] = true
            
        end
    end
    if changePosition.reconInfoStats then
        if not windows.recon.stats[0] then
            windows.recon.stats[0] = true
        end
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        ini.main.pos_recon_stats_x, ini.main.pos_recon_stats_y = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            if windows.recon.stats[0] and not rInfo.state then
                windows.recon.stats[0] = false
            end
            message():info('Настройки успешно сохранены.')
            
            changePosition.reconInfoStats = false
            windows.AdminTools[0] = true
            
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            changePosition.reconInfoStats = false
            if windows.recon.stats[0] and not rInfo.state then
                windows.recon.stats[0] = false
            end
            message():info('Вы успешно отменили смену позиции.')
            
            windows.AdminTools[0] = true
            
        end
    end
    if changePosition.reconInfoLogger then
        if not windows.keyLogger[0] then
            windows.keyLogger[0] = true
        end
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        ini.main.pos_recon_logger_x, ini.main.pos_recon_logger_y = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            if windows.keyLogger[0] and not rInfo.state then
                windows.keyLogger[0] = false
            end
            message():info('Настройки успешно сохранены.')
            
            changePosition.reconInfoLogger = false
            windows.AdminTools[0] = true
            
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            changePosition.reconInfoLogger = false
            if windows.keyLogger[0] and not is_recon() then
                windows.keyLogger[0] = false
            end
            message():info('Вы успешно отменили смену позиции.')
            
            windows.AdminTools[0] = true
            
        end
    end
    if changePosition.reconInfoNakaz then
        if not windows.recon.nakaz[0] then
            windows.recon.nakaz[0] = true
        end
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        ini.main.pos_recon_nakaz_x, ini.main.pos_recon_nakaz_y = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            if windows.recon.nakaz[0] and not rInfo.state then
                windows.recon.nakaz[0] = false
            end
            message():info('Настройки успешно сохранены.')
            
            changePosition.reconInfoNakaz = false
            windows.AdminTools[0] = true
            
            save()
        end
        if isKeyJustPressed(50) then
            showCursor(false, false)
            changePosition.reconInfoNakaz = false
            if windows.recon.nakaz[0] and not rInfo.state then
                windows.recon.nakaz[0] = false
            end
            message():info('Вы успешно отменили смену позиции.')
            
            windows.AdminTools[0] = true
            
        end
    end
    for k,v in pairs(checkerList) do
        if changePosition[k] then
            showCursor(true, false)
            local mouseX, mouseY = getCursorPos()
            checkerList['Settings'][k]['pos']['x'], checkerList['Settings'][k]['pos']['y'] = mouseX, mouseY
            if isKeyJustPressed(49) then
                showCursor(false, false)
                checker():setPosition(k, checkerList['Settings'][k]['pos']['x'], checkerList['Settings'][k]['pos']['y'])
                message():info('Настройки успешно сохранены.')
                changePosition[k] = false
                windows.AdminTools[0] = true
            end
            if isKeyJustPressed(50) then
                showCursor(false, false)
                checker():updateExcept(k)
                message():info('Вы успешно отменили смену позиции!')
                changePosition[k] = false
                windows.AdminTools[0] = true
            end
        end
    end
end
function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
		return -1
end
function getMyNick()
    while not isSampAvailable() do wait(100) end
    local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if result then
        local nick = sampGetPlayerNickname(id)
        return nick
    end
end
function handler_hotkeys(func)
    for k,v in pairs(binderCfg.list) do
        if k == func then
            if binderCfg.list[k]['active'] then 
                if #str(binderCfg.text[k]) ~= 0 then
                    lua_thread.create(function()
                        local ar = {nick='nil', id=0, text='nil'}
                        if report.players[1] ~= nil then
                            ar = {nick=report.players[1].nickname, id=report.players[1].id, text=report.players[1].text}
                        end
                        local binder_var = {
                            ['{id}'] = getMyId(),
                            ['{nick}'] = getMyNick(),
                            ['{alvl}'] = ini.auth.adminLVL,
                            ['{ping}'] = sampGetPlayerPing(getMyId()),
                            ['{report:nick}'] = ar.nick,
                            ['{report:id}'] = ar.id,
                            ['{report:text}'] = ar.text,
                            ['{report:answer}'] = u8:decode(ffi.string(elements.input.reportAnswer)) or "-1",
                            ['{targetId}'] = binder():getTargetId()
                        }
                        for _,r in pairs(binder():split(u8:decode(str(binderCfg.text[k])))) do
                            for k,v in pairs(binder_var) do
                                r = r:gsub(k, tostring(v))
                            end
                            if r:find('^%/local ') then
                                r = r:gsub('^%/local ', '')
                                sampAddChatMessage(r, -1)
                            elseif r:find('^%/enter ') then
                                r = r:gsub('^%/enter ', '')
                                sampSetChatInputText(r)
                                sampSetChatInputEnabled(true)
                            else
                                sampSendChat(r)
                            end
                            wait(tonumber(binderCfg.wait[k][0]) .. '000')
                        end
                    end)
                end
            end
        end
    end
end
function getMyId()
    local result, id = sampGetPlayerIdByCharHandle(playerPed)
    if result then
        return id
    end
end
function refresh_current_report()
    if #reportAnswerProcess > 0 then
        for k,v in pairs(reportAnswerProcess) do
            for _,r in pairs(report.players) do
                if v.reportUUID == r.uuid then
                    table.remove(reportAnswerProcess, k)
                end
            end
        end
    end
    table.remove(report.players, 1)
    imgui.StrCopy(elements.input.reportAnswer, '')
    
end
function formaTrueHotKeyFunc()
    if is_key_check_available() and forma.active then
        forma.etrue = true
    end
end
function formaFalseHotKeyFunc()
    if is_key_check_available() and forma.active then
        forma.efalse = true
    end
end

function translite(text)
    local chars = {
        ["й"] = "q", ["ц"] = "w", ["у"] = "e", ["к"] = "r", ["е"] = "t", ["н"] = "y", ["г"] = "u", ["ш"] = "i", ["щ"] = "o", ["з"] = "p", ["х"] = "[", ["ъ"] = "]", ["ф"] = "a",
        ["ы"] = "s", ["в"] = "d", ["а"] = "f", ["п"] = "g", ["р"] = "h", ["о"] = "j", ["л"] = "k", ["д"] = "l", ["ж"] = ";", ["э"] = "'", ["я"] = "z", ["ч"] = "x", ["с"] = "c", ["м"] = "v",
        ["и"] = "b", ["т"] = "n", ["ь"] = "m", ["б"] = ",", ["ю"] = ".", ["Й"] = "Q", ["Ц"] = "W", ["У"] = "E", ["К"] = "R", ["Е"] = "T", ["Н"] = "Y", ["Г"] = "U", ["Ш"] = "I",
        ["Щ"] = "O", ["З"] = "P", ["Х"] = "{", ["Ъ"] = "}", ["Ф"] = "A", ["Ы"] = "S", ["В"] = "D", ["А"] = "F", ["П"] = "G", ["Р"] = "H", ["О"] = "J", ["Л"] = "K", ["Д"] = "L",
        ["Ж"] = ":", ["Э"] = "\"", ["Я"] = "Z", ["Ч"] = "X", ["С"] = "C", ["М"] = "V", ["И"] = "B", ["Т"] = "N", ["Ь"] = "M", ["Б"] = "<", ["Ю"] = ">"
    }
    for k, v in pairs(chars) do
        text = string.gsub(text, k, v)
    end
    return text
end

function createCarInZZ(car)
    lua_thread.create(function()
        local x, y, z = getCharCoordinates(PLAYER_PED)
        veh.act = true
        wait(1050)
        sampSendChat('/veh '..veh.id..' '..veh.c1..' '..veh.c2)
        wait(500)
        veh.act = false
        setCharCoordinates(PLAYER_PED, x,y,z)
    end)
end
function theme(our_color, power, show_shades)
    -- listForColorTheme.our_color, 1, false
    local vec2, vec4 = imgui.ImVec2, imgui.ImVec4
    imgui.SwitchContext()
    local st = imgui.GetStyle()
    local cl = st.Colors
    local fl = imgui.Col

    local to_vec4 = function(color)
        return ColorAccentsAdapter(color):as_vec4()
    end

    local palette = MonetLua.buildColors(our_color, power, show_shades)
    -- local dark_palette = MonetLua.buildColors(our_color, power+0.3, show_shades)

    st.WindowPadding = vec2(5, 5)
    st.WindowRounding = 6.0
    st.WindowBorderSize = 0
    -- st.WindowMinSize = ImVec2
    st.WindowTitleAlign = vec2(0.5, 0.5)
    -- st.WindowMenuButtonPosition = imGuiDirs
    st.ChildRounding = 7.0
    st.ChildBorderSize = 2.0
    st.PopupRounding = 5.0
    st.PopupBorderSize = 1.0
    st.FramePadding = vec2(5, 4)
    st.FrameRounding = 3.0
    -- st.FrameBorderSize = float
    st.ItemSpacing = vec2(4, 4)
    -- st.ItemInnerSpacing = vec2(100, 100)
    -- st.TouchExtraPadding = vec2(10, 10)
    -- st.IndentSpacing = float
    -- st.ColumnsMinSpacing = float
    -- st.ScrollbarSize = float
    -- st.ScrollbarRounding = float
    st.GrabMinSize = 9
    st.GrabRounding = 15
    -- st.TabRounding = float
    -- st.TabBorderSize = float
    -- st.ColorButtonPosition = ImGuiDir
    st.ButtonTextAlign = vec2(0.5, 0.5)
    st.SelectableTextAlign = vec2(0.5, 0.5)
    -- st.DisplayWindowPadding = vec2(10, 10)
    -- st.DisplaySafeAreaPadding = vec2(10, 10)
    -- st.AntiAliasedLines = bool;
    -- st.AntiAliasedFill = bool;
    -- st.CurveTessellationTol = float
    cl[fl.Text] =                to_vec4(palette.accent2.color_50)
    cl[fl.TextDisabled] =        to_vec4(palette.accent1.color_600)
    cl[fl.WindowBg] =            to_vec4(palette.accent1.color_900)
    cl[fl.ChildBg] =             to_vec4(palette.accent1.color_900)
    cl[fl.PopupBg] =             to_vec4(palette.accent1.color_900)
    cl[fl.Border] =              to_vec4(palette.accent1.color_700)
    cl[fl.BorderShadow] =        to_vec4(palette.neutral2.color_900)
    cl[fl.FrameBg] =             to_vec4(palette.accent1.color_800)
    cl[fl.FrameBgHovered] =      to_vec4(palette.accent1.color_700)
    cl[fl.FrameBgActive] =       to_vec4(palette.accent1.color_600)
    cl[fl.TitleBg] =             to_vec4(palette.accent1.color_600)
    cl[fl.TitleBgActive] =       to_vec4(palette.accent1.color_600)
    cl[fl.TitleBgCollapsed] =    to_vec4(palette.accent1.color_600)
    cl[fl.MenuBarBg] =           to_vec4(palette.accent2.color_700)
    cl[fl.ScrollbarBg] =         to_vec4(palette.accent1.color_800)
    cl[fl.ScrollbarGrab] =       to_vec4(palette.accent1.color_600)
    cl[fl.ScrollbarGrabHovered] =to_vec4(palette.accent1.color_500)
    cl[fl.ScrollbarGrabActive] = to_vec4(palette.accent1.color_400)
    cl[fl.CheckMark] =           to_vec4(palette.neutral1.color_50)
    cl[fl.SliderGrab] =          to_vec4(palette.accent1.color_500)
    cl[fl.SliderGrabActive] =    to_vec4(palette.accent1.color_500)
    cl[fl.Button] =              to_vec4(palette.accent1.color_500)
    cl[fl.ButtonHovered] =       to_vec4(palette.accent1.color_400)
    cl[fl.ButtonActive] =        to_vec4(palette.accent1.color_300)
    cl[fl.Header] =              to_vec4(palette.accent1.color_800)
    cl[fl.HeaderHovered] =       to_vec4(palette.accent1.color_700)
    cl[fl.HeaderActive] =        to_vec4(palette.accent1.color_600)
    cl[fl.Separator] =           to_vec4(palette.accent1.color_600)
    cl[fl.SeparatorHovered] =    to_vec4(palette.accent2.color_100)
    cl[fl.SeparatorActive] =     to_vec4(palette.accent2.color_50)
    cl[fl.ResizeGrip] =          to_vec4(palette.accent2.color_900)
    cl[fl.ResizeGripHovered] =   to_vec4(palette.accent2.color_800)
    cl[fl.ResizeGripActive] =    to_vec4(palette.accent2.color_700)
    cl[fl.Tab] =                 to_vec4(palette.accent1.color_700)
    cl[fl.TabHovered] =          to_vec4(palette.accent1.color_600)
    cl[fl.TabActive] =           to_vec4(palette.accent1.color_500)
    -- cl[fl.TabUnfocused] = ImVec4
    -- cl[fl.TabUnfocusedActive] = ImVec4
    cl[fl.PlotLines] =           to_vec4(palette.accent3.color_300)
    cl[fl.PlotLinesHovered] =    to_vec4(palette.accent3.color_50)
    cl[fl.PlotHistogram] =       to_vec4(palette.accent3.color_300)
    cl[fl.PlotHistogramHovered] =to_vec4(palette.accent3.color_50)
    -- cl[fl.TextSelectedBg] = ImVec4
    cl[fl.DragDropTarget] =      to_vec4(palette.accent3.color_700)
    -- cl[fl.NavHighlight] = ImVec4
    -- cl[fl.NavWindowingHighlight] = ImVec4
    -- cl[fl.NavWindowingDimBg] = ImVec4
    -- cl[fl.ModalWindowDimBg] = ImVec4
end

function imgui.HelpGear(text, callback)
    imgui.TextDisabled(faicons('GEAR'))
    if imgui.IsItemClicked() then
        callback()
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(u8(text))
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.Menu()
    for i=1, #menuButtons do
        if imgui.PageButton(menuItem == menuButtons[i].i, menuButtons[i].icon, menuButtons[i].name) then
            menuItem = menuButtons[i].i
        end
    end
end
function imgui.ColoredRadioButtonBool(label, state, color)
    local DL, p, size = imgui.GetWindowDrawList(), imgui.GetCursorScreenPos(), imgui.ImVec2(25, 25)
    local button = imgui.InvisibleButton('##radio_'..label, size)
    DL:AddCircleFilled(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2, imgui.GetColorU32Vec4(imgui.ImVec4(color.x, color.y, color.z, 0.5)), 100)
    DL:AddCircleFilled(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2.7, imgui.GetColorU32Vec4(color), 100)
    if state and ini.style.active then
        DL:AddCircle(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2 + 1, 0xCCffffff, 100, 2)
    end
    return button
end
function imgui.PaletteButton(callback)
    local DL, p, size = imgui.GetWindowDrawList(), imgui.GetCursorScreenPos(), imgui.ImVec2(25, 25)
    local button = imgui.InvisibleButton('##palette_button', size)
    local ts = imgui.CalcTextSize(faicons('PALETTE'))
    local text_pos = imgui.ImVec2(p.x + (size.x / 2) - 8.5, p.y + (size.y / 2) - (ts.y / 2) + 2)
    if not ini.style.active then
        DL:AddCircle(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2 + 1, 0xCCffffff, 100, 2)
    end
    DL:AddText(text_pos, 0xFFFFFFFF, faicons('PALETTE'))
    if imgui.IsItemClicked() then
        callback()
    end
    return button
end
function imgui.RadioButtonBoolH(label, state, color, color_this)
    local DL, p, size, pos = imgui.GetWindowDrawList(), imgui.GetCursorScreenPos(), imgui.ImVec2(25, 25), imgui.GetCursorPos()
    local title = label:gsub('##.*$', '')
    local ts = imgui.CalcTextSize(u8(title))
    local spc = imgui.GetStyle().ItemSpacing
    local button = imgui.InvisibleButton('##radio_'..label, size)
    if state then
        DL:AddCircleFilled(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2, imgui.GetColorU32Vec4(imgui.ImVec4(color_this.x, color_this.y, color_this.z, 0.5)), 100)
        DL:AddCircleFilled(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2.7, imgui.GetColorU32Vec4(color), 100)
        DL:AddCircle(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2 + 1, 0xCCffffff, 100, 2)
    else
        DL:AddCircleFilled(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2, imgui.GetColorU32Vec4(imgui.ImVec4(color.x, color.y, color.z, 0.5)), 100)
        DL:AddCircleFilled(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2.7, imgui.GetColorU32Vec4(color), 100)
    end
    imgui.SetCursorPos(imgui.ImVec2(pos.x + size.x + spc.x, pos.y + ((size.y - ts.y) / 2)))
    imgui.Text(label)
    return button
end
function onSystemMessage(msg, type, Script)
    if Script ~= nil then
        if string.find(msg, "Script died due to error.") and Script.name == 'Hitman Help' and type == 3 then
            message():error('Ошибка LiteTools. Перезагружаюсь!')
            thisScript():reload()
        end
    elseif type == 3 and Script == nil then
        sampAddChatMessage("[ ERROR ]: "..msg, 0xc1c1c1)
        message():error('Критическая ошибка! Перезагрузите скрипт через /aconsole > /reload, или обратитесь к разработчику!')
    end
end
function getAllGangZones()
    local gz_tbl = {}
    local gz_pool = ffi.cast('struct stGangzonePool*', sampGetGangzonePoolPtr())
    for i = 1, 1023 do
        if gz_pool.iIsListed[i] ~= 0 and gz_pool.pGangzone[i] ~= nil then
            gz_tbl[#gz_tbl+1] = {
                id = i,
                pos = {
                    x1 = gz_pool.pGangzone[i].fPosition[0],
                    y1 = gz_pool.pGangzone[i].fPosition[1],
                    x2 = gz_pool.pGangzone[i].fPosition[2],
                    y2 = gz_pool.pGangzone[i].fPosition[3],
                },
                color = gz_pool.pGangzone[i].dwColor,
                altcolor = gz_pool.pGangzone[i].dwAltColor
            }
        end
    end
    return gz_tbl
end
function sampev.onCreateGangZone(zoneId, squareStart, squareEnd, color)
    -- print('onCreateGangZone: [zoneId:'..tostring(zoneId)..'] [squareStart:x_'..tostring(squareStart.x)..':y_'..tostring(squareStart.y)..'] [squareEnd:x_'..tostring(squareEnd.x)..':y_'..tostring(squareEnd.y)..'] [color:'..tostring(color)..']')
    local border = 2
    local squareStart = {
        x = squareStart.x+border,
        y = squareStart.y+border
    }
    local squareEnd = {
        x = squareEnd.x-border,
        y = squareEnd.y-border
    }
    -- local arg = ("%06X"):format(bit.band(color, 0xFFFFFF)) -- -1 -> FF.FF.FF
    -- local B,G,R = arg:match('(..)(..)(..)')
    -- local hexcode = R..G..B
    -- sampAddChatMessage('zoneId: '..zoneId..', hex: '..hexcode, '0xFF'..hexcode)
    return {zoneId, squareStart, squareEnd, color}
end
function imgui.ContureButton(text, size, state)
    local DL = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()
    local button = imgui.Button(faicons('PALETTE'), size or imgui.ImVec2(0,0))
    
    
    if state then
        DL:AddCircle(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2 + 1, 0xCCffffff, 100, 2)
    end
    return button
    
end
function imgui.NeactiveButton(text, size, bool)
    if bool then
        local color = imgui.GetStyle().Colors[imgui.Col.Button]
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(color.x, color.y, color.z, color.w/2) )
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(color.x, color.y, color.z, color.w/2))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(color.x, color.y, color.z, color.w/2))
        imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
            imgui.Button(text,size)
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()

    else
        return imgui.Button(text,size)
    end
    
end
function imgui.IconHelpButton(text, texthint, callback, lvl, ewe_odna_proverka)
    local lvl = lvl or false
    if lvl == true then imgui.SetCursorPosX(imgui.GetCursorPos().x + (imgui.GetColumnWidth() - 7 - imgui.CalcTextSize(text).x) / 2) 
    elseif not lvl and ewe_odna_proverka then imgui.SetCursorPosY(imgui.GetCursorPos().y + 2) end
    local button = imgui.TextDisabled(text)
    
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(u8(texthint))
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
    if imgui.IsItemClicked() then
        callback()
    end
    return button
end
function doroga(id)
    if rInfo.state and rInfo.id ~= -1 then
        local function getNearestRoadCoordinates(radius)
            local A = { getCharCoordinates(PLAYER_PED) }
            local B = { getClosestStraightRoad(A[1], A[2], A[3], 0, radius or 600) }
            if B[1] ~= 0 and B[2] ~= 0 and B[3] ~= 0 then
                return true, B[1], B[2], B[3]
            end
            return false
        end
        local res, x, y, z = getNearestRoadCoordinates(1500)
        if res then
            spectate.command = '/gethere '..id
            spectate.position = {
                x = x,
                y = y,
                z = z+2,
            }
            spectate.process_teleport = true
        else
            message():info('Я не могу найти дорогу поблизости!')
        end
    else
        local function getNearestRoadCoordinates(radius)
            local A = { getCharCoordinates(PLAYER_PED) }
            local B = { getClosestStraightRoad(A[1], A[2], A[3], 0, radius or 600) }
            if B[1] ~= 0 and B[2] ~= 0 and B[3] ~= 0 then
                return true, B[1], B[2], B[3]
            end
            return false
        end
        local res, x, y, z = getNearestRoadCoordinates(1000)
        if res then
            status_doroga = true
            wait(1000)
            sampSendChat('/gethere '..id)
            wait(1000)
            status_doroga = false
        else
            message():info('Я не могу найти дорогу поблизости!')
        end
    end
end 

function getNearestRoadCoordinates(radius)
    local A = { getCharCoordinates(PLAYER_PED) }
    local B = { getClosestStraightRoad(A[1], A[2], A[3], 0, radius or 600) }
    if B[1] ~= 0 and B[2] ~= 0 and B[3] ~= 0 then
        return true, B[1], B[2], B[3]
    end
    return false
end
function sampev.onSendPlayerSync(data)
    if veh.act then
        data.position.x = -357.87448120117
        data.position.y = -2069.8332519531
        data.position.z = 27.827898025513
        
    end
    if status_doroga then
        local res, x, y, z = getNearestRoadCoordinates()
        if res then
            data.position.x = x
            data.position.y = y
            data.position.z = z + 5
        end
    end
    if fastHelp.activeSpawn or fastHelp.activeLock then
        data.position.x = fastHelp.pos.x
        data.position.y = fastHelp.pos.y
        data.position.z = fastHelp.pos.z
    end
    if ainvisible then
        local sync = samp_create_sync_data('spectator')
        sync.position = data.position
        sync.send()
        return false 
    end
end
function sampev.onSendSpectatorSync(data)
    if spectate.process_teleport then
        spectate.count = spectate.count + 1
        if spectate.count <= 8 then
            data.position.x = spectate.position.x
            data.position.y = spectate.position.y-2 -- /gethere -> прибавит координаты Y+2
            data.position.z = spectate.position.z
            if spectate.count == 3 then
                sampSendChat(spectate.command)
            end
        else
            spectate.process_teleport = false
            spectate.count = 0
        end
    end
end
function renderFigure2D(x, y, points, radius, color)
    local step = math.pi * 2 / points
    local render_start, render_end = {}, {}
    for i = 0, math.pi * 2, step do
        render_start[1] = radius * math.cos(i) + x
        render_start[2] = radius * math.sin(i) + y
        render_end[1] = radius * math.cos(i + step) + x
        render_end[2] = radius * math.sin(i + step) + y
        renderDrawLine(render_start[1], render_start[2], render_end[1], render_end[2], 1, color)
    end
end
function getNearCharToCenter(radius)
    local arr = {}
    local sx, sy = getScreenResolution()
    for _, player in ipairs(getAllChars()) do
        if select(1, sampGetPlayerIdByCharHandle(player)) and isCharOnScreen(player) and player ~= playerPed then
            local plX, plY, plZ = getCharCoordinates(player)
            local cX, cY = convert3DCoordsToScreen(plX, plY, plZ)
            local distBetween2d = getDistanceBetweenCoords2d(sx / 2, sy / 2, cX, cY)
            if distBetween2d <= tonumber(radius and radius or sx) then
                table.insert(arr, {distBetween2d, player})
            end
        end
    end
    if #arr > 0 then
        table.sort(arr, function(a, b) return (a[1] < b[1]) end)
        return arr[1][2]
    end
    return nil
end
function renderFontDrawTextAlign(font, text, x, y, color, align)
    if not align or align == 1 then -- слева
        renderFontDrawText(font, text, x, y, color)


    end

    if align == 2 then -- по центру
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text) / 2, y, color)
    end

    if align == 3 then -- справа
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text), y, color)
    end
end
function getNearCarToCenter(radius)
    local arr = {}
    local sx, sy = getScreenResolution()
    for _, car in ipairs(getAllVehicles()) do
        if isCarOnScreen(car) and getDriverOfCar(car) ~= playerPed then
            local carX, carY, carZ = getCarCoordinates(car)
            local cX, cY = convert3DCoordsToScreen(carX, carY, carZ)
            local distBetween2d = getDistanceBetweenCoords2d(sx / 2, sy / 2, cX, cY)
            if distBetween2d <= tonumber(radius and radius or sx) then
                table.insert(arr, {distBetween2d, car})
            end
        end
    end
    if #arr > 0 then
        table.sort(arr, function(a, b) return (a[1] < b[1]) end)
        return arr[1][2]
    end
    return nil
end
function imgui.HeaderButton(bool, str_id)
    local ToU32 = imgui.ColorConvertFloat4ToU32
    local ToVEC = imgui.ColorConvertU32ToFloat4
    local function limit(v, min, max) -- Ограничение динамического значения
        min = min or 0.0
        max = max or 1.0
        return v < min and min or (v > max and max or v)
    end
    local function isPlaceHovered(a, b) -- Проверка находится ли курсор в указанной области
        local m = imgui.GetMousePos()
        if m.x >= a.x and m.y >= a.y then
            if m.x <= b.x and m.y <= b.y then
                return true
            end
        end
        return false
    end
    local function bringVec4To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100),
                from.z + (count * (to.z - from.z) / 100),
                from.w + (count * (to.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end
    local function bringFloatTo(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return from + (count * (to - from) / 100), true
        end
        return (timer > duration) and to or from, false
    end
    local function set_alpha(color, alpha) -- Получение цвета с определённой прозрачностью
        alpha = alpha and limit(alpha, 0.0, 1.0) or 1.0
        return imgui.ImVec4(color.x, color.y, color.z, alpha)
    end
    
    local AI_HEADERBUT = {}
	local DL = imgui.GetWindowDrawList()
	local result = false
	local label = string.gsub(str_id, "##.*$", "")
	local duration = { 0.5, 0.3 }
	local cols = {
        idle = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        hovr = imgui.GetStyle().Colors[imgui.Col.Text],
        slct = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    }

 	if not AI_HEADERBUT[str_id] then
        AI_HEADERBUT[str_id] = {
            color = bool and cols.slct or cols.idle,
            clock = os.clock() + duration[1],
            h = {
                state = bool,
                alpha = bool and 1.00 or 0.00,
                clock = os.clock() + duration[2],
            }
        }
    end
    local pool = AI_HEADERBUT[str_id]

	imgui.BeginGroup()
		local pos = imgui.GetCursorPos()
		local p = imgui.GetCursorScreenPos()
		
		-- Render Text
		imgui.TextColored(pool.color, label)
		local s = imgui.GetItemRectSize()
		local hovered = isPlaceHovered(p, imgui.ImVec2(p.x + s.x, p.y + s.y))
		local clicked = imgui.IsItemClicked()
		
		-- Listeners
		if pool.h.state ~= hovered and not bool then
			pool.h.state = hovered
			pool.h.clock = os.clock()
		end
		
		if clicked then
	    	pool.clock = os.clock()
	    	result = true
	    end

    	if os.clock() - pool.clock <= duration[1] then
			pool.color = bringVec4To(
				imgui.ImVec4(pool.color),
				bool and cols.slct or (hovered and cols.hovr or cols.idle),
				pool.clock,
				duration[1]
			)
		else
			pool.color = bool and cols.slct or (hovered and cols.hovr or cols.idle)
		end

		if pool.h.clock ~= nil then
			if os.clock() - pool.h.clock <= duration[2] then
				pool.h.alpha = bringFloatTo(
					pool.h.alpha,
					pool.h.state and 1.00 or 0.00,
					pool.h.clock,
					duration[2]
				)
			else
				pool.h.alpha = pool.h.state and 1.00 or 0.00
				if not pool.h.state then
					pool.h.clock = nil
				end
			end

			local max = s.x / 2
			local Y = p.y + s.y + 3
			local mid = p.x + max

			DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid + (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
			DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid - (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
		end

	imgui.EndGroup()
	return result
end
function globalCursorHotKeyFunc()
    if is_key_check_available() then
        cursor = not cursor
        showCursor(cursor, false)
    end
end

function set_command_state(state)
    if string.len(str(fulldostup.user)) ~= 0 then
        local command = fulldostup.commands.var[fulldostup.commands.uuid[0] + 1]
        if tonumber(str(fulldostup.user)) ~= nil then
            local id = tonumber(str(fulldostup.user))
            if sampIsPlayerConnected(id) then
                local nick = sampGetPlayerNickname(id)
                sampSendChat(string.format("/setcmd %s %s %s", nick, command, state))
                message():info(string.format("Вы %s %s команду %s", state == 1 and "выдали" or "забрали", sampGetPlayerNickname(id), command))
            else
                message():error("Данный игрок не в сети.")
            end
        else
            local nick = str(fulldostup.user)
            sampSendChat(string.format("/setcmd %s %s %s", nick, command, state))
            message():info(string.format("Вы %s %s команду %s", state == 1 and "выдали" or "забрали", nick, command))
        end
    else
        message():error("Вы ничего не ввели!")
    end
end

function name_hotkey(hotkey)
    local tableh = {}
    for k,v in ipairs(hotkey:GetHotKey()) do
        table.insert(tableh, vkeys.id_to_name(v))
    end
    return table.concat(tableh, ' + ')
end
function find_table_element(table, element)
    for k,v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end

function setFormsWithLvl()
    local lvlcmd = {
        [2] = {'jail', 'unjail', 'ptp', 'spawn', 'mute', 'rmute', 'sp'},
        [3] = {'jail', 'unjail', 'ptp','spawn','mute','rmute','sp'},
        [4] = {'jail','unjail','ptp','spawn','mute','rmute','kick','sp'},
        [5] = {'jail','unjail','ptp','spawn','mute','rmute','kick','sp','unrmute'},
        [6] = {'jail','unjail','ptp','spawn','mute','rmute','kick','sp','ban','warn','unwarn','unrmute'},
        [7] = {'jail','unjail','ptp','spawn','mute','rmute','kick','sp','ban','warn','unwarn','iban','offban','offwarn','skick','sethp','unrmute'},
        [8] = {'jail','unjail','ptp','spawn','mute','rmute','kick','sp','ban','warn','unwarn','iban','offban','offwarn','skick','sethp','unrmute'},
        [9] = {'jail','unjail','ptp','spawn','mute','rmute','kick','sp','ban','warn','unwarn','iban','offban','offwarn','skick','sethp','banip','makehelper','unban','unrmute'},
        [10] = {'jail','unjail','ptp','spawn','mute','rmute','kick','sp','ban','warn','unwarn',
            'iban','offban','offwarn','skick','sethp','agiverank','uval','sban','banip','makehelper','unrmute','unban'},
        [11] = {'jail','unjail','ptp','spawn','mute','rmute','kick','sp','ban','warn','unwarn',
            'iban','offban','offwarn','skick','sethp','agiverank','uval','sban','setskin','money','banip','makehelper','unrmute','unban'},
        [12] = {'jail','unjail','ptp','spawn','mute','rmute','kick','sp','ban','warn','unwarn',
            'iban','offban','offwarn','skick','sethp','agiverank','uval','sban','setskin','money','givedonate','banip','makehelper','unrmute','unban'},
        [13] = {'jail','unjail','ptp','spawn','mute','rmute','kick','sp','ban','warn','unwarn',
            'iban','offban','offwarn','skick','sethp','agiverank','uval','sban','setskin','money','givedonate','banip','makehelper','unrmute','unban'}
    }
    for k,v in pairs(ini.forms) do
        elements.forms[k][0] = false
        ini.forms[k] = false
        save()
    end
    if ini.auth.adminLVL == 1 then
        for k,v in pairs(ini.forms) do
            elements.forms[k][0] = false
            ini.forms[k] = false
            save()
        end
    else
        for k,v in pairs(lvlcmd) do
            if k == ini.auth.adminLVL then
                for _,r in pairs(lvlcmd[k]) do
                    
                    elements.forms[r][0] = true
                    ini.forms[r] = true
                    save()
                end
            end
        end
    end
end

function imgui.CloseButton(str_id, value, size, rounding)
    local ToU32 = imgui.ColorConvertFloat4ToU32
	size = size or 40
	rounding = rounding or 5
	local DL = imgui.GetWindowDrawList()
	local p = imgui.GetCursorScreenPos()
	
	local result = imgui.InvisibleButton(str_id, imgui.ImVec2(size, size))
	if result then
		value[0] = false
	end
	local hovered = imgui.IsItemHovered()

	local col = ToU32(imgui.GetStyle().Colors[imgui.Col.Border])
	local col_bg = hovered and 0x50000000 or 0x30000000
	local offs = (size / 4)

	DL:AddRectFilled(p, imgui.ImVec2(p.x + size, p.y + size), col_bg, rounding, 15)
	DL:AddLine(
		imgui.ImVec2(p.x + offs, p.y + offs), 
		imgui.ImVec2(p.x + size - offs, p.y + size - offs), 
		col,
		size / 10
	)
	DL:AddLine(
		imgui.ImVec2(p.x + size - offs, p.y + offs), 
		imgui.ImVec2(p.x + offs, p.y + size - offs),
		col,
		size / 10
	)
	return result
end
function imgui.CenterText(text)
    
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(tostring(text)).x / 2)
    return imgui.Text(tostring(text))
    
end
function imgui.CenterColoredText(color, text)
    text = u8(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(tostring(text)).x / 2)
    return imgui.TextColored(color, tostring(text))
end
local effect_result = false
function imgui.PageButton(bool, icon, name, but_wide)
    
    local ToU32 = imgui.ColorConvertFloat4ToU32
	but_wide = but_wide or 190
	local duration = 0.25
	local DL = imgui.GetWindowDrawList()
	local p1 = imgui.GetCursorScreenPos()
	local p2 = imgui.GetCursorPos()
	local col = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    local function bringFloatTo(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return from + (count * (to - from) / 100), true
        end
        return (timer > duration) and to or from, false
    end
		
	if not AI_PAGE[name] then
		AI_PAGE[name] = { clock = nil }
	end
	local pool = AI_PAGE[name]

	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    local result = imgui.InvisibleButton(name, imgui.ImVec2(but_wide, 35))
    if result and not bool then 
    	pool.clock = os.clock() 
    end
    local pressed = imgui.IsItemActive()
    imgui.PopStyleColor(3)
	if bool then
		if pool.clock and (os.clock() - pool.clock) < duration then
			local wide = (os.clock() - pool.clock) * (but_wide / duration)
			DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2((p1.x + 190) - wide, p1.y + 35), 0x10FFFFFF, 0, 10)
            DL:AddRectFilled(imgui.ImVec2(p1.x + 185, p1.y), imgui.ImVec2(p1.x + 190, p1.y + 35), ToU32(col))
			DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 35), ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)), 0, 10)
		else
            DL:AddRectFilled(imgui.ImVec2(p1.x + 185, (pressed and p1.y + 3 or p1.y)), imgui.ImVec2(p1.x + 190, (pressed and p1.y + 32 or p1.y + 35)), ToU32(col))
			DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 190, p1.y + 35), ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)), 0, 10)
		end
	else
		if imgui.IsItemHovered() then
			DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 190, p1.y + 35), 0x10FFFFFF, 0, 10)
            effect_result = true
		end
	end
	imgui.SameLine(10); imgui.SetCursorPosY(p2.y + 8)
	if bool then
        imgui.SetCursorPosY(imgui.GetCursorPos().y + 2)
		imgui.Text((' '):rep(3))
		imgui.SameLine(30)
        imgui.SetCursorPosY(imgui.GetCursorPos().y - 2)
		imgui.Text(name)
	else
        imgui.SetCursorPosY(imgui.GetCursorPos().y + 2)
		imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), (' '):rep(3))
		imgui.SameLine(30)
        imgui.SetCursorPosY(imgui.GetCursorPos().y - 2)
		imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), name)
	end
	imgui.SetCursorPosY(p2.y + 40)
	return result
end
function imgui.Link(label, description)

    local size = imgui.CalcTextSize(label)
    local p = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()
    local result = imgui.InvisibleButton(label, size)

    imgui.SetCursorPos(p2)


    if imgui.IsItemHovered() then
        if description then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
            imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
            imgui.EndTooltip()

        end

        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
        imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.CheckMark]))

    else
        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
    end

    return result
end
function imgui.GradientSelectable(text, size, bool)  
    local button = imgui.InvisibleButton('##'..text, size)    
    local dl = imgui.GetWindowDrawList()
    local rectMin = imgui.GetItemRectMin()
    local p = imgui.GetCursorScreenPos()
    local ts = imgui.CalcTextSize(text)
    
    if imgui.IsItemHovered() then
        dl:AddRectFilledMultiColor(imgui.ImVec2(rectMin.x, rectMin.y), imgui.ImVec2(rectMin.x + size.x, rectMin.y + size.y), 
            imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive]), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0,0,0,0)), 
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0,0,0,0)), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive]));
    end
    if bool then  
        dl:AddRectFilledMultiColor(imgui.ImVec2(rectMin.x, rectMin.y), imgui.ImVec2(rectMin.x + size.x, rectMin.y + size.y), 
            imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Separator]), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0,0,0,0)), 
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0,0,0,0)), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Separator]));
    end
    imgui.SameLine(1,1)
    imgui.PushFont(Font[19])
    imgui.Text(text)
    imgui.PopFont()
    
    
    
    return button
end
function renderAdminsTeam()
    if not isGamePaused() and sampGetGamestate() == 3 and elements.toggle.renderAdminsTeam[0] then
        local x,y = ini.main.pos_render_admins_x, ini.main.pos_render_admins_y
        renderFontDrawText(adminMonitor.font, string.format('Администрация online [ %s | AFK: %s | /re: %s ]:', #adminMonitor.admins, adminMonitor.AFK, adminMonitor.RECON), x, y - (elements.int.renderFontSize[0] + 10), -1)
        for k,v in ipairs(adminMonitor.admins) do
            if v.action == 'not' then
                renderFontDrawText(adminMonitor.font, string.format('%s[%s] - {00ff00}%s lvl', v.nick, v.id, v.lvl), x, y, -1)
                
                y = y + (elements.int.renderFontSize[0] + 10)
            elseif v.action == 'AFK' then
                renderFontDrawText(adminMonitor.font, string.format('%s[%s] - {00ff00}%s lvl {ff0000}AFK', v.nick, v.id, v.lvl), x, y, -1)
                
                y = y + (elements.int.renderFontSize[0] + 10)
            elseif v.action == 're' then
                renderFontDrawText(adminMonitor.font, string.format('%s[%s] - {00ff00}%s lvl > /re %s', v.nick, v.id, v.lvl, v.reId), x, y, -1)
                y = y + (elements.int.renderFontSize[0] + 10)
            end
        end
    end
end
function imgui.ToggleButton(str_id, value, hintText, exText)
    local ToU32 = imgui.ColorConvertFloat4ToU32
	local duration = 0.3
	local p = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
	local size = imgui.ImVec2(40, 20)
    local title = str_id:gsub('##.*$', '')
    local ts = imgui.CalcTextSize(title)
    local cols = {
    	enable = imgui.GetStyle().Colors[imgui.Col.ButtonActive],
    	disable = imgui.GetStyle().Colors[imgui.Col.TextDisabled]	
    }
    local radius = 6
    local o = {
    	x = 4,
    	y = p.y + (size.y / 2)
    }
    local A = imgui.ImVec2(p.x + radius + o.x, o.y)
    local B = imgui.ImVec2(p.x + size.x - radius - o.x, o.y)
    local function bringVec4To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100),
                from.z + (count * (to.z - from.z) / 100),
                from.w + (count * (to.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end
    
    local function bringVec2To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec2(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end

    if AI_TOGGLE[str_id] == nil then
        AI_TOGGLE[str_id] = {
        	clock = nil,
        	color = value[0] and cols.enable or cols.disable,
        	pos = value[0] and B or A
        }
    end
    local pool = AI_TOGGLE[str_id]
    
    imgui.BeginGroup()
	    local pos = imgui.GetCursorPos()
	    local result = imgui.InvisibleButton(str_id, imgui.ImVec2(size.x, size.y))
	    if result then
	        value[0] = not value[0]
	        pool.clock = os.clock()
	    end
	    if #title > 0 then
		    local spc = imgui.GetStyle().ItemSpacing
		    imgui.SetCursorPos(imgui.ImVec2(pos.x + size.x + spc.x, pos.y + ((size.y - ts.y) / 2)))
	    	imgui.Text(u8(title))
    	end
    imgui.EndGroup()

 	if pool.clock and os.clock() - pool.clock <= duration then
        pool.color = bringVec4To(
            imgui.ImVec4(pool.color),
            value[0] and cols.enable or cols.disable,
            pool.clock,
            duration
        )

        pool.pos = bringVec2To(
        	imgui.ImVec2(pool.pos),
        	value[0] and B or A,
        	pool.clock,
            duration
        )
    else
        pool.color = value[0] and cols.enable or cols.disable
        pool.pos = value[0] and B or A
    end

	DL:AddRect(p, imgui.ImVec2(p.x + size.x, p.y + size.y), ToU32(pool.color), 10, 15, 1)
	DL:AddCircleFilled(pool.pos, radius, ToU32(pool.color))
    local text = hintText or ''
    if text ~= '' then
        imgui.SameLine()
        imgui.HelpMarker(u8(text))
    end
    local extext = exText or ''
    if extext ~= '' then
        imgui.SameLine()
        imgui.ExMarker(u8(extext))
    end

    return result
end

function imgui.HelpMarker(text)
    imgui.SetCursorPosY(imgui.GetCursorPos().y + 3)
    imgui.TextDisabled(faicons('CIRCLE_QUESTION'))
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end
function imgui.ExMarker(text)
    imgui.TextDisabled(faicons('CIRCLE_EXCLAMATION'))
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function click_warp()
    lua_thread.create(function()
        while true do
            if cursorEnabled and not windows.AdminTools[0] and not windows.reportPanel[0] then
                local mode = sampGetCursorMode()
                if mode == 0 then
                    showCursorForClickWarp(cursorEnabled)
                end
                local sx, sy = getCursorPos()
                local sw, sh = getScreenResolution()
                if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
                    local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
                    local camX, camY, camZ = getActiveCameraCoordinates()
                    local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, 
                    true, true, true, true, false, false, false)
                    if result and colpoint.entity ~= 0 then
                        local normal = colpoint.normal
                        local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
                        local zOffset = 300
                        if normal[3] >= 0.5 then zOffset = 1 end
             
                        local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3,
                        true, true, true, true, false, false, false)
                        if result then
                            pos = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)
                            
                            local curX, curY, curZ  = getCharCoordinates(playerPed)
                            local dist              = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z)
                            local hoffs             = renderGetFontDrawHeight(font)

                            sy = sy - 2
                            sx = sx - 2
                            renderFontDrawText(font, string.format("{FFFFFF}%0.2fm", dist), sx, sy - hoffs, 0xEEEEEEEE)

                            local tpIntoCar = nil
                            local gotp = nil
                            local Handleid = nil
                            local pedx, pedy, pedz = nil, nil, nil
                            if elements.toggle.clickWarpForPeople[0] then
                                if colpoint.entityType == 3 then
                                    local ped = getCharPointerHandle(colpoint.entity)
                                    pedx, pedy, pedz = getCharCoordinates(ped)
                        
                                
                                    if doesCharExist(ped) and not isCharInAnyCar(playerPed) then
                                        local result, id = sampGetPlayerIdByCharHandle(ped)
                                        if id ~= getMyId() then
                                            if result then
                                                renderFontDrawText(font, "{FFFFFF}"..sampGetPlayerNickname(id)..'['..id..']\nPress ЛКМ to TP | ПКМ to Recon', sx, sy - hoffs * 3, -1)
                                                Handleid = id
                                                gotp = true
                                            end
                                        end
                                    end
                                end
                            end
             
                            if colpoint.entityType == 2 then
                                local car = getVehiclePointerHandle(colpoint.entity)
                                if doesVehicleExist(car) and (not isCharInAnyCar(playerPed) or storeCarCharIsInNoSave(playerPed) ~= car) then
                                    displayVehicleName(sx, sy - hoffs * 2, getNameOfVehicleModel(getCarModel(car)))
                                    local color = 0xFFFFFFFF
                                    if isKeyDown(VK_RBUTTON) then
                                        tpIntoCar = car
                                        color = 0xFFFFFFFF
                                    end
                                    renderFontDrawText(font, "{FFFFFF}Hold right mouse button to teleport into the car", sx, sy - hoffs * 3, color)
                                end
                            end
                            createPointMarker(pos.x, pos.y, pos.z)
                            if gotp then
                                if isKeyDown(VK_LBUTTON) then
                                    teleportPlayer(pedx + 5, pedy, pedz)
                                    cursorEnabled = false
                                end
                                
                                if isKeyDown(VK_RBUTTON) then
                                    sampSendChat('/re '..Handleid)
                                    cursorEnabled = false
                                    showCursorForClickWarp(cursorEnabled)
                                end
                            end
                            if isKeyDown(VK_LBUTTON) then
                                if tpIntoCar then
                                    if not jumpIntoCar(tpIntoCar) then
                                        teleportPlayer(pos.x, pos.y, pos.z)
                                        local veh = storeCarCharIsInNoSave(playerPed)
                                        local cordsVeh = {getCarCoordinates(veh)}
                                        setCarCoordinates(veh, cordsVeh[1], cordsVeh[2], cordsVeh[3])
                                        cursorEnabled = false
                                    end
                                else
                                    if isCharInAnyCar(playerPed) then
                                        local norm = Vector3D(colpoint.normal[1], colpoint.normal[2], 0)
                                        local norm2 = Vector3D(colpoint2.normal[1], colpoint2.normal[2], colpoint2.normal[3])
                                        rotateCarAroundUpAxis(storeCarCharIsInNoSave(playerPed), norm2)
                                        pos = pos - norm * 1.8
                                        pos.z = pos.z - 1.1
                                    end
                                    teleportPlayer(pos.x, pos.y, pos.z)
                                    cursorEnabled = false
                                end
                                removePointMarker()
                                while isKeyDown(VK_LBUTTON) do wait(0) end
                                showCursorForClickWarp(cursorEnabled)
                            end
                        end
                    end
                end
            end
            wait(0)
            removePointMarker()
        end
    end)
end

  
  
--- Functions
function rotateCarAroundUpAxis(car, vec)
    local mat = Matrix3X3(getVehicleRotationMatrix(car))
    local rotAxis = Vector3D(mat.up:get())
    vec:normalize()
    rotAxis:normalize()
    local theta = math.acos(rotAxis:dotProduct(vec))
    if theta ~= 0 then
        rotAxis:crossProduct(vec)
        rotAxis:normalize()
        rotAxis:zeroNearZero()
        mat = mat:rotate(rotAxis, -theta)
    end
    setVehicleRotationMatrix(car, mat:get())
end

function readFloatArray(ptr, idx)
    return representIntAsFloat(readMemory(ptr + idx * 4, 4, false))
end

function writeFloatArray(ptr, idx, value)
    writeMemory(ptr + idx * 4, 4, representFloatAsInt(value), false)
end
function wallhack(bool)
    ini.main.enabledWallHack = bool
    if bool then
        nameTagOn()
    else
        nameTagOff()
    end
end
function nameTagOn()
    local pStSet = sampGetServerSettingsPtr();
    NTdist = memory.getfloat(pStSet + 39)
    NTwalls = memory.getint8(pStSet + 47)
    NTshow = memory.getint8(pStSet + 56)
    memory.setfloat(pStSet + 39, 1488.0)
    memory.setint8(pStSet + 47, 0)
    memory.setint8(pStSet + 56, 1)
end

function nameTagOff()
    local pStSet = sampGetServerSettingsPtr();
    memory.setfloat(pStSet + 39, NTdist)
    memory.setint8(pStSet + 47, NTwalls)
    memory.setint8(pStSet + 56, NTshow)
end
function getVehicleRotationMatrix(car)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
        local mat = readMemory(entityPtr + 0x14, 4, false)
        if mat ~= 0 then
        local rx, ry, rz, fx, fy, fz, ux, uy, uz
        rx = readFloatArray(mat, 0)
        ry = readFloatArray(mat, 1)
        rz = readFloatArray(mat, 2)

        fx = readFloatArray(mat, 4)
        fy = readFloatArray(mat, 5)
        fz = readFloatArray(mat, 6)

        ux = readFloatArray(mat, 8)
        uy = readFloatArray(mat, 9)
        uz = readFloatArray(mat, 10)
        return rx, ry, rz, fx, fy, fz, ux, uy, uz
        end
    end
end
function getAmmoRecon()
    local result, recon_handle = sampGetCharHandleBySampPlayerId(rInfo.id)
    if result then
        local weapon = getCurrentCharWeapon(recon_handle)
        local struct = getCharPointer(recon_handle) + 0x5A0 + getWeapontypeSlot(weapon) * 0x1C
        return getStructElement(struct, 0x8, 4)
    end
end
function setVehicleRotationMatrix(car, rx, ry, rz, fx, fy, fz, ux, uy, uz)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
        local mat = readMemory(entityPtr + 0x14, 4, false)
        if mat ~= 0 then
        writeFloatArray(mat, 0, rx)
        writeFloatArray(mat, 1, ry)
        writeFloatArray(mat, 2, rz)

        writeFloatArray(mat, 4, fx)
        writeFloatArray(mat, 5, fy)
        writeFloatArray(mat, 6, fz)

        writeFloatArray(mat, 8, ux)
        writeFloatArray(mat, 9, uy)
        writeFloatArray(mat, 10, uz)
        end
    end
end

function displayVehicleName(x, y, gxt)
    x, y = convertWindowScreenCoordsToGameScreenCoords(x, y)
    useRenderCommands(true)
    setTextWrapx(640.0)
    setTextProportional(true)
    setTextJustify(false)
    setTextScale(0.33, 0.8)
    setTextDropshadow(0, 0, 0, 0, 0)
    setTextColour(255, 255, 255, 230)
    setTextEdge(1, 0, 0, 0, 100)
    setTextFont(1)
    displayText(x, y, gxt)
end

function createPointMarker(x, y, z)
    pointMarker = createUser3dMarker(x, y, z + 0.3, 4)
end

function removePointMarker()
    if pointMarker then
        removeUser3dMarker(pointMarker)
        pointMarker = nil
    end
end

function getCarFreeSeat(car)
    if doesCharExist(getDriverOfCar(car)) then
        local maxPassengers = getMaximumNumberOfPassengers(car)
        for i = 0, maxPassengers do
            if isCarPassengerSeatFree(car, i) then
                return i + 1
            end
        end
        return nil -- no free seats
    else
        return 0 -- driver seat
    end
end

function jumpIntoCar(car)
    local seat = getCarFreeSeat(car)
    if not seat then return false end                         -- no free seats
    if seat == 0 then warpCharIntoCar(playerPed, car)         -- driver seat
    else warpCharIntoCarAsPassenger(playerPed, car, seat - 1) -- passenger seat
    end
    restoreCameraJumpcut()
    return true
end

function teleportPlayer(x, y, z)
    if isCharInAnyCar(playerPed) then
        setCharCoordinates(playerPed, x, y, z)
    end
    setCharCoordinatesDontResetAnim(playerPed, x, y, z)
end

function setCharCoordinatesDontResetAnim(char, x, y, z)
    if doesCharExist(char) then
        local ptr = getCharPointer(char)
        setEntityCoordinates(ptr, x, y, z)
    end
end

function setEntityCoordinates(entityPtr, x, y, z)
    if entityPtr ~= 0 then
        local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
        if matrixPtr ~= 0 then
            local posPtr = matrixPtr + 0x30
            writeMemory(posPtr + 0, 4, representFloatAsInt(x), false) -- X
            writeMemory(posPtr + 4, 4, representFloatAsInt(y), false) -- Y
            writeMemory(posPtr + 8, 4, representFloatAsInt(z), false) -- Z
        end
    end
end

function showCursorForClickWarp(toggle)
    if toggle then
        sampSetCursorMode(CMODE_LOCKCAM)
    else
        sampToggleCursor(false)
    end
end

function imgui.Picture(str_id, image, size, mult, hint)
    local ToU32 = imgui.ColorConvertFloat4ToU32
    local ToVEC = imgui.ColorConvertU32ToFloat4

    local function limit(v, min, max) -- Ограничение динамического значения
        min = min or 0.0
        max = max or 1.0
        return v < min and min or (v > max and max or v)
    end

    local function bringVec4To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100),
                from.z + (count * (to.z - from.z) / 100),
                from.w + (count * (to.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end
	hint = hint or u8'Увеличить изображение'
	mult = mult and limit(mult, 2, 10) or 5
	local duration = { 0.3, 1.0 }
	local p = imgui.GetCursorScreenPos()
	imgui.Image(image, imgui.ImVec2(size.x / mult, size.y / mult))
	local hovered = imgui.IsItemHovered()
	local clicked = imgui.IsItemClicked(0)
	local DL = imgui.GetWindowDrawList()
	local ws, wh = getScreenResolution()
	local s = imgui.GetItemRectSize()
	local ts = imgui.CalcTextSize(hint)
	local cols = {
		bg = {
			hovr = imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg],
			idle = imgui.ImVec4(0.0, 0.0, 0.0, 0.0)
		},
		t = {
			hovr = imgui.GetStyle().Colors[imgui.Col.Text],
			idle = imgui.ImVec4(0.0, 0.0, 0.0, 0.0)
		}
	}

	if AI_PICTURE[str_id] == nil then
		AI_PICTURE[str_id] = {
			o = {
				clock = nil,
				alpha = 0
			},
			h = {
				clock = nil,
				before = false,
				bg_col = hovered and cols.bg.hovr or cols.bg.idle,
				t_col = hovered and cols.t.hovr or cols.t.idle
			}
		}
	end
	local pool = AI_PICTURE[str_id]

	if hovered ~= pool.h.before then
		pool.h.before = hovered
		pool.h.clock = os.clock()
	end

	if clicked then
		pool.o.state = true
		pool.o.clock = os.clock()
	end

	if pool.o.clock ~= nil then
		local bg_col
		if os.clock() - pool.o.clock <= duration[2] then
			local timer = (os.clock() - pool.o.clock)
			local offset = (1.0 - pool.o.alpha)
			pool.o.alpha = pool.o.alpha + ((offset / duration[2]) * timer)
			bg_col = bringVec4To(
				imgui.ImVec4(0, 0, 0, 0),
				cols.bg.hovr,
				pool.o.clock,
				duration[2]
			)
		else
			pool.o.alpha = 1.0	
			bg_col = cols.bg.hovr
		end

		local DL = imgui.GetForegroundDrawList()
		local A = imgui.ImVec2((ws - size.x) / 2, (wh - size.y) / 2)
		local B = imgui.ImVec2(A.x + size.x, A.y + size.y)

		DL:AddRectFilled(imgui.ImVec2(0, 0), imgui.ImVec2(ws, wh), ToU32(bg_col))
		DL:AddImage(image, A, B, _, _, ToU32(imgui.ImVec4(1, 1, 1, pool.o.alpha)))

		if imgui.IsMouseClicked(0) and pool.o.alpha >= 0.1 then
			pool.o.alpha = 0.0
			pool.o.clock = nil
		end	
		goto finish
	end

	if pool.h.clock ~= nil then
		if os.clock() - pool.h.clock <= duration[1] then
			pool.h.bg_col = bringVec4To(
				imgui.ImVec4(pool.h.bg_col),
				hovered and cols.bg.hovr or cols.bg.idle,
				pool.h.clock,
				duration[1]
			)
			pool.h.t_col = bringVec4To(
				imgui.ImVec4(pool.h.t_col),
				hovered and cols.t.hovr or cols.t.idle,
				pool.h.clock,
				duration[1]
			)
		else
			pool.h.bg_col = hovered and cols.bg.hovr or cols.bg.idle
			pool.h.t_col = hovered and cols.t.hovr or cols.t.idle
			if not hovered then
				pool.h.clock = nil
			end
		end
		DL:AddRectFilled(p, imgui.ImVec2(p.x + s.x, p.y + s.y), ToU32(pool.h.bg_col))
		DL:AddText(imgui.ImVec2(p.x + (s.x - ts.x) / 2, p.y + (s.y - ts.y) / 2), ToU32(pool.h.t_col), hint)
	end

	::finish::
	return clicked
end
data_logo = "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x64\x00\x00\x00\x64\x08\x06\x00\x00\x00\x70\xE2\x95\x54\x00\x00\x00\x04\x67\x41\x4D\x41\x00\x00\xB1\x8F\x0B\xFC\x61\x05\x00\x00\x0A\x49\x69\x43\x43\x50\x73\x52\x47\x42\x20\x49\x45\x43\x36\x31\x39\x36\x36\x2D\x32\x2E\x31\x00\x00\x48\x89\x9D\x53\x77\x58\x93\xF7\x16\x3E\xDF\xF7\x65\x0F\x56\x42\xD8\xF0\xB1\x97\x6C\x81\x00\x22\x23\xAC\x08\xC8\x10\x59\xA2\x10\x92\x00\x61\x84\x10\x12\x40\xC5\x85\x88\x0A\x56\x14\x15\x11\x9C\x48\x55\xC4\x82\xD5\x0A\x48\x9D\x88\xE2\xA0\x28\xB8\x67\x41\x8A\x88\x5A\x8B\x55\x5C\x38\xEE\x1F\xDC\xA7\xB5\x7D\x7A\xEF\xED\xED\xFB\xD7\xFB\xBC\xE7\x9C\xE7\xFC\xCE\x79\xCF\x0F\x80\x11\x12\x26\x91\xE6\xA2\x6A\x00\x39\x52\x85\x3C\x3A\xD8\x1F\x8F\x4F\x48\xC4\xC9\xBD\x80\x02\x15\x48\xE0\x04\x20\x10\xE6\xCB\xC2\x67\x05\xC5\x00\x00\xF0\x03\x79\x78\x7E\x74\xB0\x3F\xFC\x01\xAF\x6F\x00\x02\x00\x70\xD5\x2E\x24\x12\xC7\xE1\xFF\x83\xBA\x50\x26\x57\x00\x20\x91\x00\xE0\x22\x12\xE7\x0B\x01\x90\x52\x00\xC8\x2E\x54\xC8\x14\x00\xC8\x18\x00\xB0\x53\xB3\x64\x0A\x00\x94\x00\x00\x6C\x79\x7C\x42\x22\x00\xAA\x0D\x00\xEC\xF4\x49\x3E\x05\x00\xD8\xA9\x93\xDC\x17\x00\xD8\xA2\x1C\xA9\x08\x00\x8D\x01\x00\x99\x28\x47\x24\x02\x40\xBB\x00\x60\x55\x81\x52\x2C\x02\xC0\xC2\x00\xA0\xAC\x40\x22\x2E\x04\xC0\xAE\x01\x80\x59\xB6\x32\x47\x02\x80\xBD\x05\x00\x76\x8E\x58\x90\x0F\x40\x60\x00\x80\x99\x42\x2C\xCC\x00\x20\x38\x02\x00\x43\x1E\x13\xCD\x03\x20\x4C\x03\xA0\x30\xD2\xBF\xE0\xA9\x5F\x70\x85\xB8\x48\x01\x00\xC0\xCB\x95\xCD\x97\x4B\xD2\x33\x14\xB8\x95\xD0\x1A\x77\xF2\xF0\xE0\xE2\x21\xE2\xC2\x6C\xB1\x42\x61\x17\x29\x10\x66\x09\xE4\x22\x9C\x97\x9B\x23\x13\x48\xE7\x03\x4C\xCE\x0C\x00\x00\x1A\xF9\xD1\xC1\xFE\x38\x3F\x90\xE7\xE6\xE4\xE1\xE6\x66\xE7\x6C\xEF\xF4\xC5\xA2\xFE\x6B\xF0\x6F\x22\x3E\x21\xF1\xDF\xFE\xBC\x8C\x02\x04\x00\x10\x4E\xCF\xEF\xDA\x5F\xE5\xE5\xD6\x03\x70\xC7\x01\xB0\x75\xBF\x6B\xA9\x5B\x00\xDA\x56\x00\x68\xDF\xF9\x5D\x33\xDB\x09\xA0\x5A\x0A\xD0\x7A\xF9\x8B\x79\x38\xFC\x40\x1E\x9E\xA1\x50\xC8\x3C\x1D\x1C\x0A\x0B\x0B\xED\x25\x62\xA1\xBD\x30\xE3\x8B\x3E\xFF\x33\xE1\x6F\xE0\x8B\x7E\xF6\xFC\x40\x1E\xFE\xDB\x7A\xF0\x00\x71\x9A\x40\x99\xAD\xC0\xA3\x83\xFD\x71\x61\x6E\x76\xAE\x52\x8E\xE7\xCB\x04\x42\x31\x6E\xF7\xE7\x23\xFE\xC7\x85\x7F\xFD\x8E\x29\xD1\xE2\x34\xB1\x5C\x2C\x15\x8A\xF1\x58\x89\xB8\x50\x22\x4D\xC7\x79\xB9\x52\x91\x44\x21\xC9\x95\xE2\x12\xE9\x7F\x32\xF1\x1F\x96\xFD\x09\x93\x77\x0D\x00\xAC\x86\x4F\xC0\x4E\xB6\x07\xB5\xCB\x6C\xC0\x7E\xEE\x01\x02\x8B\x0E\x58\xD2\x76\x00\x40\x7E\xF3\x2D\x8C\x1A\x0B\x91\x00\x10\x67\x34\x32\x79\xF7\x00\x00\x93\xBF\xF9\x8F\x40\x2B\x01\x00\xCD\x97\xA4\xE3\x00\x00\xBC\xE8\x18\x5C\xA8\x94\x17\x4C\xC6\x08\x00\x00\x44\xA0\x81\x2A\xB0\x41\x07\x0C\xC1\x14\xAC\xC0\x0E\x9C\xC1\x1D\xBC\xC0\x17\x02\x61\x06\x44\x40\x0C\x24\xC0\x3C\x10\x42\x06\xE4\x80\x1C\x0A\xA1\x18\x96\x41\x19\x54\xC0\x3A\xD8\x04\xB5\xB0\x03\x1A\xA0\x11\x9A\xE1\x10\xB4\xC1\x31\x38\x0D\xE7\xE0\x12\x5C\x81\xEB\x70\x17\x06\x60\x18\x9E\xC2\x18\xBC\x86\x09\x04\x41\xC8\x08\x13\x61\x21\x3A\x88\x11\x62\x8E\xD8\x22\xCE\x08\x17\x99\x8E\x04\x22\x61\x48\x34\x92\x80\xA4\x20\xE9\x88\x14\x51\x22\xC5\xC8\x72\xA4\x02\xA9\x42\x6A\x91\x5D\x48\x23\xF2\x2D\x72\x14\x39\x8D\x5C\x40\xFA\x90\xDB\xC8\x20\x32\x8A\xFC\x8A\xBC\x47\x31\x94\x81\xB2\x51\x03\xD4\x02\x75\x40\xB9\xA8\x1F\x1A\x8A\xC6\xA0\x73\xD1\x74\x34\x0F\x5D\x80\x96\xA2\x6B\xD1\x1A\xB4\x1E\x3D\x80\xB6\xA2\xA7\xD1\x4B\xE8\x75\x74\x00\x7D\x8A\x8E\x63\x80\xD1\x31\x0E\x66\x8C\xD9\x61\x5C\x8C\x87\x45\x60\x89\x58\x1A\x26\xC7\x16\x63\xE5\x58\x35\x56\x8F\x35\x63\x1D\x58\x37\x76\x15\x1B\xC0\x9E\x61\xEF\x08\x24\x02\x8B\x80\x13\xEC\x08\x5E\x84\x10\xC2\x6C\x82\x90\x90\x47\x58\x4C\x58\x43\xA8\x25\xEC\x23\xB4\x12\xBA\x08\x57\x09\x83\x84\x31\xC2\x27\x22\x93\xA8\x4F\xB4\x25\x7A\x12\xF9\xC4\x78\x62\x3A\xB1\x90\x58\x46\xAC\x26\xEE\x21\x1E\x21\x9E\x25\x5E\x27\x0E\x13\x5F\x93\x48\x24\x0E\xC9\x92\xE4\x4E\x0A\x21\x25\x90\x32\x49\x0B\x49\x6B\x48\xDB\x48\x2D\xA4\x53\xA4\x3E\xD2\x10\x69\x9C\x4C\x26\xEB\x90\x6D\xC9\xDE\xE4\x08\xB2\x80\xAC\x20\x97\x91\xB7\x90\x0F\x90\x4F\x92\xFB\xC9\xC3\xE4\xB7\x14\x3A\xC5\x88\xE2\x4C\x09\xA2\x24\x52\xA4\x94\x12\x4A\x35\x65\x3F\xE5\x04\xA5\x9F\x32\x42\x99\xA0\xAA\x51\xCD\xA9\x9E\xD4\x08\xAA\x88\x3A\x9F\x5A\x49\x6D\xA0\x76\x50\x2F\x53\x87\xA9\x13\x34\x75\x9A\x25\xCD\x9B\x16\x43\xCB\xA4\x2D\xA3\xD5\xD0\x9A\x69\x67\x69\xF7\x68\x2F\xE9\x74\xBA\x09\xDD\x83\x1E\x45\x97\xD0\x97\xD2\x6B\xE8\x07\xE9\xE7\xE9\x83\xF4\x77\x0C\x0D\x86\x0D\x83\xC7\x48\x62\x28\x19\x6B\x19\x7B\x19\xA7\x18\xB7\x19\x2F\x99\x4C\xA6\x05\xD3\x97\x99\xC8\x54\x30\xD7\x32\x1B\x99\x67\x98\x0F\x98\x6F\x55\x58\x2A\xF6\x2A\x7C\x15\x91\xCA\x12\x95\x3A\x95\x56\x95\x7E\x95\xE7\xAA\x54\x55\x73\x55\x3F\xD5\x79\xAA\x0B\x54\xAB\x55\x0F\xAB\x5E\x56\x7D\xA6\x46\x55\xB3\x50\xE3\xA9\x09\xD4\x16\xAB\xD5\xA9\x1D\x55\xBB\xA9\x36\xAE\xCE\x52\x77\x52\x8F\x50\xCF\x51\x5F\xA3\xBE\x5F\xFD\x82\xFA\x63\x0D\xB2\x86\x85\x46\xA0\x86\x48\xA3\x54\x63\xB7\xC6\x19\x8D\x21\x16\xC6\x32\x65\xF1\x58\x42\xD6\x72\x56\x03\xEB\x2C\x6B\x98\x4D\x62\x5B\xB2\xF9\xEC\x4C\x76\x05\xFB\x1B\x76\x2F\x7B\x4C\x53\x43\x73\xAA\x66\xAC\x66\x91\x66\x9D\xE6\x71\xCD\x01\x0E\xC6\xB1\xE0\xF0\x39\xD9\x9C\x4A\xCE\x21\xCE\x0D\xCE\x7B\x2D\x03\x2D\x3F\x2D\xB1\xD6\x6A\xAD\x66\xAD\x7E\xAD\x37\xDA\x7A\xDA\xBE\xDA\x62\xED\x72\xED\x16\xED\xEB\xDA\xEF\x75\x70\x9D\x40\x9D\x2C\x9D\xF5\x3A\x6D\x3A\xF7\x75\x09\xBA\x36\xBA\x51\xBA\x85\xBA\xDB\x75\xCF\xEA\x3E\xD3\x63\xEB\x79\xE9\x09\xF5\xCA\xF5\x0E\xE9\xDD\xD1\x47\xF5\x6D\xF4\xA3\xF5\x17\xEA\xEF\xD6\xEF\xD1\x1F\x37\x30\x34\x08\x36\x90\x19\x6C\x31\x38\x63\xF0\xCC\x90\x63\xE8\x6B\x98\x69\xB8\xD1\xF0\x84\xE1\xA8\x11\xCB\x68\xBA\x91\xC4\x68\xA3\xD1\x49\xA3\x27\xB8\x26\xEE\x87\x67\xE3\x35\x78\x17\x3E\x66\xAC\x6F\x1C\x62\xAC\x34\xDE\x65\xDC\x6B\x3C\x61\x62\x69\x32\xDB\xA4\xC4\xA4\xC5\xE4\xBE\x29\xCD\x94\x6B\x9A\x66\xBA\xD1\xB4\xD3\x74\xCC\xCC\xC8\x2C\xDC\xAC\xD8\xAC\xC9\xEC\x8E\x39\xD5\x9C\x6B\x9E\x61\xBE\xD9\xBC\xDB\xFC\x8D\x85\xA5\x45\x9C\xC5\x4A\x8B\x36\x8B\xC7\x96\xDA\x96\x7C\xCB\x05\x96\x4D\x96\xF7\xAC\x98\x56\x3E\x56\x79\x56\xF5\x56\xD7\xAC\x49\xD6\x5C\xEB\x2C\xEB\x6D\xD6\x57\x6C\x50\x1B\x57\x9B\x0C\x9B\x3A\x9B\xCB\xB6\xA8\xAD\x9B\xAD\xC4\x76\x9B\x6D\xDF\x14\xE2\x14\x8F\x29\xD2\x29\xF5\x53\x6E\xDA\x31\xEC\xFC\xEC\x0A\xEC\x9A\xEC\x06\xED\x39\xF6\x61\xF6\x25\xF6\x6D\xF6\xCF\x1D\xCC\x1C\x12\x1D\xD6\x3B\x74\x3B\x7C\x72\x74\x75\xCC\x76\x6C\x70\xBC\xEB\xA4\xE1\x34\xC3\xA9\xC4\xA9\xC3\xE9\x57\x67\x1B\x67\xA1\x73\x9D\xF3\x35\x17\xA6\x4B\x90\xCB\x12\x97\x76\x97\x17\x53\x6D\xA7\x8A\xA7\x6E\x9F\x7A\xCB\x95\xE5\x1A\xEE\xBA\xD2\xB5\xD3\xF5\xA3\x9B\xBB\x9B\xDC\xAD\xD9\x6D\xD4\xDD\xCC\x3D\xC5\x7D\xAB\xFB\x4D\x2E\x9B\x1B\xC9\x5D\xC3\x3D\xEF\x41\xF4\xF0\xF7\x58\xE2\x71\xCC\xE3\x9D\xA7\x9B\xA7\xC2\xF3\x90\xE7\x2F\x5E\x76\x5E\x59\x5E\xFB\xBD\x1E\x4F\xB3\x9C\x26\x9E\xD6\x30\x6D\xC8\xDB\xC4\x5B\xE0\xBD\xCB\x7B\x60\x3A\x3E\x3D\x65\xFA\xCE\xE9\x03\x3E\xC6\x3E\x02\x9F\x7A\x9F\x87\xBE\xA6\xBE\x22\xDF\x3D\xBE\x23\x7E\xD6\x7E\x99\x7E\x07\xFC\x9E\xFB\x3B\xFA\xCB\xFD\x8F\xF8\xBF\xE1\x79\xF2\x16\xF1\x4E\x05\x60\x01\xC1\x01\xE5\x01\xBD\x81\x1A\x81\xB3\x03\x6B\x03\x1F\x04\x99\x04\xA5\x07\x35\x05\x8D\x05\xBB\x06\x2F\x0C\x3E\x15\x42\x0C\x09\x0D\x59\x1F\x72\x93\x6F\xC0\x17\xF2\x1B\xF9\x63\x33\xDC\x67\x2C\x9A\xD1\x15\xCA\x08\x9D\x15\x5A\x1B\xFA\x30\xCC\x26\x4C\x1E\xD6\x11\x8E\x86\xCF\x08\xDF\x10\x7E\x6F\xA6\xF9\x4C\xE9\xCC\xB6\x08\x88\xE0\x47\x6C\x88\xB8\x1F\x69\x19\x99\x17\xF9\x7D\x14\x29\x2A\x32\xAA\x2E\xEA\x51\xB4\x53\x74\x71\x74\xF7\x2C\xD6\xAC\xE4\x59\xFB\x67\xBD\x8E\xF1\x8F\xA9\x8C\xB9\x3B\xDB\x6A\xB6\x72\x76\x67\xAC\x6A\x6C\x52\x6C\x63\xEC\x9B\xB8\x80\xB8\xAA\xB8\x81\x78\x87\xF8\x45\xF1\x97\x12\x74\x13\x24\x09\xED\x89\xE4\xC4\xD8\xC4\x3D\x89\xE3\x73\x02\xE7\x6C\x9A\x33\x9C\xE4\x9A\x54\x96\x74\x63\xAE\xE5\xDC\xA2\xB9\x17\xE6\xE9\xCE\xCB\x9E\x77\x3C\x59\x35\x59\x90\x7C\x38\x85\x98\x12\x97\xB2\x3F\xE5\x83\x20\x42\x50\x2F\x18\x4F\xE5\xA7\x6E\x4D\x1D\x13\xF2\x84\x9B\x85\x4F\x45\xBE\xA2\x8D\xA2\x51\xB1\xB7\xB8\x4A\x3C\x92\xE6\x9D\x56\x95\xF6\x38\xDD\x3B\x7D\x43\xFA\x68\x86\x4F\x46\x75\xC6\x33\x09\x4F\x52\x2B\x79\x91\x19\x92\xB9\x23\xF3\x4D\x56\x44\xD6\xDE\xAC\xCF\xD9\x71\xD9\x2D\x39\x94\x9C\x94\x9C\xA3\x52\x0D\x69\x96\xB4\x2B\xD7\x30\xB7\x28\xB7\x4F\x66\x2B\x2B\x93\x0D\xE4\x79\xE6\x6D\xCA\x1B\x93\x87\xCA\xF7\xE4\x23\xF9\x73\xF3\xDB\x15\x6C\x85\x4C\xD1\xA3\xB4\x52\xAE\x50\x0E\x16\x4C\x2F\xA8\x2B\x78\x5B\x18\x5B\x78\xB8\x48\xBD\x48\x5A\xD4\x33\xDF\x66\xFE\xEA\xF9\x23\x0B\x82\x16\x7C\xBD\x90\xB0\x50\xB8\xB0\xB3\xD8\xB8\x78\x59\xF1\xE0\x22\xBF\x45\xBB\x16\x23\x8B\x53\x17\x77\x2E\x31\x5D\x52\xBA\x64\x78\x69\xF0\xD2\x7D\xCB\x68\xCB\xB2\x96\xFD\x50\xE2\x58\x52\x55\xF2\x6A\x79\xDC\xF2\x8E\x52\x83\xD2\xA5\xA5\x43\x2B\x82\x57\x34\x95\xA9\x94\xC9\xCB\x6E\xAE\xF4\x5A\xB9\x63\x15\x61\x95\x64\x55\xEF\x6A\x97\xD5\x5B\x56\x7F\x2A\x17\x95\x5F\xAC\x70\xAC\xA8\xAE\xF8\xB0\x46\xB8\xE6\xE2\x57\x4E\x5F\xD5\x7C\xF5\x79\x6D\xDA\xDA\xDE\x4A\xB7\xCA\xED\xEB\x48\xEB\xA4\xEB\x6E\xAC\xF7\x59\xBF\xAF\x4A\xBD\x6A\x41\xD5\xD0\x86\xF0\x0D\xAD\x1B\xF1\x8D\xE5\x1B\x5F\x6D\x4A\xDE\x74\xA1\x7A\x6A\xF5\x8E\xCD\xB4\xCD\xCA\xCD\x03\x35\x61\x35\xED\x5B\xCC\xB6\xAC\xDB\xF2\xA1\x36\xA3\xF6\x7A\x9D\x7F\x5D\xCB\x56\xFD\xAD\xAB\xB7\xBE\xD9\x26\xDA\xD6\xBF\xDD\x77\x7B\xF3\x0E\x83\x1D\x15\x3B\xDE\xEF\x94\xEC\xBC\xB5\x2B\x78\x57\x6B\xBD\x45\x7D\xF5\x6E\xD2\xEE\x82\xDD\x8F\x1A\x62\x1B\xBA\xBF\xE6\x7E\xDD\xB8\x47\x77\x4F\xC5\x9E\x8F\x7B\xA5\x7B\x07\xF6\x45\xEF\xEB\x6A\x74\x6F\x6C\xDC\xAF\xBF\xBF\xB2\x09\x6D\x52\x36\x8D\x1E\x48\x3A\x70\xE5\x9B\x80\x6F\xDA\x9B\xED\x9A\x77\xB5\x70\x5A\x2A\x0E\xC2\x41\xE5\xC1\x27\xDF\xA6\x7C\x7B\xE3\x50\xE8\xA1\xCE\xC3\xDC\xC3\xCD\xDF\x99\x7F\xB7\xF5\x08\xEB\x48\x79\x2B\xD2\x3A\xBF\x75\xAC\x2D\xA3\x6D\xA0\x3D\xA1\xBD\xEF\xE8\x8C\xA3\x9D\x1D\x5E\x1D\x47\xBE\xB7\xFF\x7E\xEF\x31\xE3\x63\x75\xC7\x35\x8F\x57\x9E\xA0\x9D\x28\x3D\xF1\xF9\xE4\x82\x93\xE3\xA7\x64\xA7\x9E\x9D\x4E\x3F\x3D\xD4\x99\xDC\x79\xF7\x4C\xFC\x99\x6B\x5D\x51\x5D\xBD\x67\x43\xCF\x9E\x3F\x17\x74\xEE\x4C\xB7\x5F\xF7\xC9\xF3\xDE\xE7\x8F\x5D\xF0\xBC\x70\xF4\x22\xF7\x62\xDB\x25\xB7\x4B\xAD\x3D\xAE\x3D\x47\x7E\x70\xFD\xE1\x48\xAF\x5B\x6F\xEB\x65\xF7\xCB\xED\x57\x3C\xAE\x74\xF4\x4D\xEB\x3B\xD1\xEF\xD3\x7F\xFA\x6A\xC0\xD5\x73\xD7\xF8\xD7\x2E\x5D\x9F\x79\xBD\xEF\xC6\xEC\x1B\xB7\x6E\x26\xDD\x1C\xB8\x25\xBA\xF5\xF8\x76\xF6\xED\x17\x77\x0A\xEE\x4C\xDC\x5D\x7A\x8F\x78\xAF\xFC\xBE\xDA\xFD\xEA\x07\xFA\x0F\xEA\x7F\xB4\xFE\xB1\x65\xC0\x6D\xE0\xF8\x60\xC0\x60\xCF\xC3\x59\x0F\xEF\x0E\x09\x87\x9E\xFE\x94\xFF\xD3\x87\xE1\xD2\x47\xCC\x47\xD5\x23\x46\x23\x8D\x8F\x9D\x1F\x1F\x1B\x0D\x1A\xBD\xF2\x64\xCE\x93\xE1\xA7\xB2\xA7\x13\xCF\xCA\x7E\x56\xFF\x79\xEB\x73\xAB\xE7\xDF\xFD\xE2\xFB\x4B\xCF\x58\xFC\xD8\xF0\x0B\xF9\x8B\xCF\xBF\xAE\x79\xA9\xF3\x72\xEF\xAB\xA9\xAF\x3A\xC7\x23\xC7\x1F\xBC\xCE\x79\x3D\xF1\xA6\xFC\xAD\xCE\xDB\x7D\xEF\xB8\xEF\xBA\xDF\xC7\xBD\x1F\x99\x28\xFC\x40\xFE\x50\xF3\xD1\xFA\x63\xC7\xA7\xD0\x4F\xF7\x3E\xE7\x7C\xFE\xFC\x2F\xF7\x84\xF3\xFB\x2D\x47\x38\xCF\x00\x00\x00\x20\x63\x48\x52\x4D\x00\x00\x7A\x26\x00\x00\x80\x84\x00\x00\xFA\x00\x00\x00\x80\xE8\x00\x00\x75\x30\x00\x00\xEA\x60\x00\x00\x3A\x98\x00\x00\x17\x70\x9C\xBA\x51\x3C\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x0B\x13\x00\x00\x0B\x13\x01\x00\x9A\x9C\x18\x00\x00\x04\x16\x49\x44\x41\x54\x78\x9C\xED\x9C\xED\x51\x22\x41\x10\x86\xDF\xBE\xBA\x04\x30\x84\x35\x04\x0D\x41\x43\x90\x10\x30\x04\x0C\x01\x43\x90\x10\x34\x04\x08\x01\x42\x80\x10\x24\x84\xF7\x7E\xEC\xAC\xA0\xC5\xCA\xDE\x4C\x0F\xD3\x0C\xFD\x54\x5D\xD5\x59\x05\xB3\xCB\x3C\xF3\xDD\xBD\x2B\x24\xE1\xD8\xE1\x4F\xE9\x1B\x70\xBE\xE3\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xE1\x42\x8C\xF1\x37\xE5\xCB\x22\x32\xE8\x73\x24\x9F\x00\x34\xE1\xCF\xD9\x2F\x1F\xDD\x02\x98\x87\xFF\xAF\x45\x64\x19\x7F\x77\x65\x48\x4E\x1A\x21\x19\xFD\xEF\x44\xB9\x77\x24\x67\x4C\x67\x46\xF2\x61\xE0\x6F\x79\x53\xB8\x5E\x0A\x0B\x26\xD4\x27\x49\xFD\x21\x8B\x64\x43\xF2\x1D\xC0\x0A\xC0\x54\xA1\xC8\x29\x80\x45\xF8\xB1\x77\x0A\xE5\x99\x46\x55\x08\xDB\x96\xBC\x02\xF0\xA4\x59\x6E\xE0\x01\xC0\x8A\xA4\x86\x64\xB3\xA8\x09\x09\x32\x16\x00\x46\x5A\x65\xF6\x30\x23\xF9\x96\xF9\x1A\xC5\x50\x11\x42\xB2\x01\xF0\xAE\x51\xD6\x40\x26\xB5\xF6\x14\xAD\x1E\xF2\x86\xFC\x3D\xE3\x27\x53\x92\xE7\xBE\x66\x76\x92\x85\x84\xDE\x31\x68\x15\xA4\xCC\x08\x79\xE6\xAA\xA2\x68\xF4\x90\x92\x95\x52\xA2\x21\x64\x45\x43\x48\xC9\xA5\x68\x73\xFA\x23\x97\x85\x86\x90\xD8\x56\xBA\x04\x70\x23\xED\x76\x7F\x1C\x59\x46\x75\xFB\x92\x24\x21\x61\x52\x8D\x9D\x58\xC7\x22\xB2\x03\x00\x11\xF9\x00\xF0\x11\x79\x0F\x55\xF5\x92\xD4\x1E\x12\x2B\x63\xD9\xC9\x38\x60\x9B\x7A\x0F\x22\xF2\x2C\x27\x48\xB8\x0E\x4E\x95\x2D\x22\x8F\xB1\x65\x77\xA4\x0A\x89\x6D\x9D\xC7\x2A\xE5\xA7\xA0\xA1\x54\xB5\xF4\xF5\xE3\x77\x63\x94\x12\x52\x55\xAB\xD6\xA4\x94\x90\xEA\xF6\x0F\x5A\x14\xEB\x21\x1C\x18\xE3\xB8\x36\x84\x69\x11\xAE\x06\xC0\x26\xF2\xBB\x6B\x00\x8F\x47\x56\x5B\x59\x21\xB9\x41\xE4\x62\x44\x06\x84\x48\x13\xEB\x33\xB9\x87\xA4\x54\xE6\x1D\xDA\xC0\x53\x55\xFB\x88\x54\x92\x84\x84\xD6\x1D\xBD\xAE\x47\x2B\x65\xE5\xC3\xD7\x1E\x8D\x39\x64\x9D\xF8\xFD\x11\xDA\x9E\x52\x6D\xD0\xE9\x7F\xD0\x10\x12\x75\xE4\x71\x84\x09\xC9\x0D\xDB\x0C\x95\xAB\x25\x69\x52\xEF\xE6\x38\x92\x9F\xD0\xDD\x5B\xCC\x45\xE4\x59\xB1\xBC\x2F\x6A\x9F\xD4\x3B\x5E\x95\xCA\xE9\xE8\x7A\xCB\xD5\xCD\x2D\x2A\x42\x44\xE4\x15\x69\x93\xFB\x31\x1A\xB4\x73\x4B\x95\xB1\xF3\x3E\x34\x37\x86\xB1\x31\x8D\x53\xCC\x42\x4E\xD6\x55\x1C\xB7\xA8\x09\x11\x91\x35\x80\xE4\xE3\xE7\x1E\xBA\x9C\xAC\xEA\x02\x52\x3F\x51\x3D\x3A\x09\xB9\xB8\x8F\x48\xDB\x30\xF6\xD1\xE0\x0A\xF6\x2C\xEA\x67\x59\x41\xCA\x3D\xDA\x10\x6D\x0E\x16\x35\x4B\xC9\x72\xB8\x28\x22\xDB\x10\x3D\xD3\x5E\x7D\x75\x54\x9B\xE7\x9B\xF5\xB4\x57\x44\x5E\x90\x6F\x08\x7B\xAF\x71\xA2\xCF\x7E\xFC\x1E\x86\xB0\x5B\xE8\x0F\x61\x0D\x7E\x7F\xD6\xE4\x22\x39\x4B\x3C\x44\x44\x76\x61\x08\x7B\x51\x2E\x7A\x52\x5B\x2F\x39\x6B\x80\x2A\x6C\x20\xEF\xA1\xBB\x89\x9C\x28\x96\x55\x9C\xB3\x47\x0C\x45\x64\x2D\x22\xB7\xD0\x3B\x94\xAC\x6A\x72\x2F\x96\x75\x22\x22\x63\xE8\xEC\xEE\xAB\x5A\x02\x17\x4D\x03\x0A\x19\x8B\xA9\x43\xD8\xA8\xA6\xA8\xA3\xC6\xE3\x08\x9B\x98\xA7\x23\xBB\xEF\x1F\x1C\xB9\xA4\x48\x71\x21\x9A\x88\xC8\x16\x69\x9B\x48\x17\xA2\x8D\x88\xCC\xE1\xE9\xA4\x76\x84\x04\xB4\x63\x2A\x17\x87\x35\x21\xA9\x09\x13\x17\x8F\x86\x90\xB3\x26\xBA\xD5\x8E\x0B\x31\x86\x0B\x31\x46\x31\x21\x3D\x87\x82\xD5\xAC\x96\x62\xD1\x10\x12\xBB\x32\xFA\x76\x06\x15\x04\xC5\x26\xC9\x55\xD3\x4B\x4B\x0A\x99\x75\x47\x1E\x0A\xAF\xE6\xA8\x66\x75\x96\x9C\xB9\x18\x5A\xF6\xA7\xDE\x2D\x45\x71\x33\xF4\xB1\x86\xEA\x33\x17\x43\x45\x94\x6C\xA1\xEB\x73\x3F\x63\x92\x13\xAD\x8D\xA1\x56\x6C\xE3\xD2\xAE\xAD\x8E\x96\x90\x39\xCA\x1C\x7B\xEC\xB0\x7F\x47\x63\x15\x68\xE5\xF6\xEE\x90\x2F\x95\xF4\x37\x9E\x6B\x1A\xAE\x00\xFD\x54\xD2\x2C\x8F\x10\xF4\xF0\x12\x02\x5C\x55\xA1\x9D\x4A\x3A\x47\xBE\x3C\xAC\x43\xC6\x21\x61\xA2\x3A\xB2\xA4\x92\x8A\xC8\x0D\xF2\x64\x2D\xCE\x01\xDC\xD6\xD8\x33\xBE\x48\x79\xC7\xEC\x80\xB2\x47\x24\xA7\x24\x3F\x63\xC2\xBC\x07\x4C\xA9\x14\x37\x67\x64\xC8\x99\x43\x7E\x30\xD2\xEA\x93\xA4\xCE\x23\x6D\x03\x6F\xB4\xC1\xFE\x68\x64\x82\xFE\xCD\xD9\x0E\xFB\xDE\xB5\x0C\x73\xD3\xC5\x90\x52\x9F\x40\xFA\x8B\x03\x1C\x65\xAC\x45\x0C\xAF\x1E\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x0C\x17\x62\x8C\x7F\x5E\xEC\x62\x5B\xA2\x56\x4A\xFC\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"
function getFixScreenPos(pos1, pos2, distance) -- незаконченная функа
    distance = math.abs(distance)
    local direct = {x = pos2.x - pos1.x, y = pos2.y - pos1.y, z = pos2.z - pos1.z}
    local length = math.sqrt(direct.x * direct.x + direct.y * direct.y + direct.z * direct.z)

    direct.x = direct.x / length
    direct.y = direct.y / length
    direct.z = direct.z / length

    local newPosition = { x = pos1.x + direct.x * distance, y = pos1.y + direct.y * distance, z = pos1.z + direct.z * distance }
    return newPosition
end
function checkTargetType(target, con_imgui)
    if     target == 0 then return con_imgui.col_vec4.stats
    elseif target == 1 then return con_imgui.col_vec4.ped
    elseif target == 2 then return con_imgui.col_vec4.car
    elseif target == 3 then return con_imgui.col_vec4.dynam
    end
end
function sampev.onSendBulletSync(data)
    -- chat.log('X:%02f Y:%02f Z:%02f - [%d]', data.origin.x, data.origin.y, data.origin.z, data.targetType) -- DEBUG
    if config_imgui.my_bullets.draw[0] and (data.center.x ~= 0 and data.center.y ~= 0 and data.center.z ~= 0) and elements.toggle.bulletTracers[0] then
        local con = config_imgui.my_bullets
        bullets[#bullets+1] = {
            -- id = 65535,
            clock = os.clock(),
            timer = con.timer[0],
            col4 = checkTargetType(data.targetType, con),
            alpha = checkTargetType(data.targetType, con)[3],
            -- targetId = data.targetId,
            -- weaponId = data.weaponId,
            origin = {x = data.origin.x, y = data.origin.y, z = data.origin.z},
            target = {x = data.target.x, y = data.target.y, z = data.target.z},
            transition = con.transition[0],
            thickness = con.thickness[0],
            circle_radius = con.circle_radius[0],
            step_alpha = con.step_alpha[0],
            degree_polygon = con.degree_polygon[0],
            draw_polygon = con.draw_polygon[0],
        }
    end
end

function sampev.onBulletSync(playerid, data)
    -- chat.log('[%d] - X:%02f Y:%02f Z:%02f - [%d]', playerid, data.origin.x, data.origin.y, data.origin.z, data.targetType) -- DEBUG
    if config_imgui.other_bullets.draw[0] and (data.center.x ~= 0 and data.center.y ~= 0 and data.center.z ~= 0) and elements.toggle.bulletTracers[0] then
        local con = config_imgui.other_bullets
        bullets[#bullets+1] = {
            -- id = playerid,
            clock = os.clock(),
            timer = con.timer[0],
            col4 = checkTargetType(data.targetType, con),
            alpha = checkTargetType(data.targetType, con)[3],
            -- targetId = data.targetId,
            -- weaponId = data.weaponId,
            origin = {x = data.origin.x, y = data.origin.y, z = data.origin.z},
            target = {x = data.target.x, y = data.target.y, z = data.target.z},
            transition = con.transition[0],
            thickness = con.thickness[0],
            circle_radius = con.circle_radius[0],
            step_alpha = con.step_alpha[0],
            degree_polygon = con.degree_polygon[0],
            draw_polygon = con.draw_polygon[0],
        }
    end
end
function imgui.BetterInput(name, hint_text, buffer, color, text_color, width)

    ----==| Локальные фунцкии, использованные в этой функции. |==----

    local function bringVec4To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100),
                from.z + (count * (to.z - from.z) / 100),
                from.w + (count * (to.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end

    local function bringFloatTo(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return from + (count * (to - from) / 100), true
        end
        return (timer > duration) and to or from, false
    end


    ----==| Изменение местоположения Imgui курсора, чтобы подсказка при анимации отображалась корректно. |==----

    imgui.SetCursorPosY(imgui.GetCursorPos().y + (imgui.CalcTextSize(hint_text).y * 0.7))


    ----==| Создание шаблона, для корректной работы нескольких таких виджетов. |==----

    if UI_BETTERINPUT == nil then
        UI_BETTERINPUT = {}
    end
    if not UI_BETTERINPUT[name] then
        UI_BETTERINPUT[name] = {buffer = buffer or imgui.ImBuffer(256), width = nil,
        hint = {
            pos = nil,
            old_pos = nil,
            scale = nil
        },
        color = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        old_color = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        active = {false, nil}, inactive = {true, nil}
    }
    end

    local pool = UI_BETTERINPUT[name] -- локальный список переменных для одного виджета


    ----==| Проверка и присваивание значений нужных переменных и аргументов. |==----
    
    if color == nil then
        color = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    end

    if width == nil then
        pool["width"] = imgui.CalcTextSize(hint_text).x + 50
        if pool["width"] < 150 then
            pool["width"] = 150
        end
    else
        pool["width"] = width
    end

    if pool["hint"]["scale"] == nil then
        pool["hint"]["scale"] = 1.0
    end

    if pool["hint"]["pos"] == nil then
        pool["hint"]["pos"] = imgui.ImVec2(imgui.GetCursorPos().x, imgui.GetCursorPos().y)
    end

    if pool["hint"]["old_pos"] == nil then
        pool["hint"]["old_pos"] = imgui.GetCursorPos().y
    end


    ----==| Изменение стилей под параметры виджета. |==----

    imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(1, 1, 1, 0))
    imgui.PushStyleColor(imgui.Col.Text, text_color or imgui.ImVec4(1, 1, 1, 1))
    imgui.PushStyleColor(imgui.Col.TextSelectedBg, color)
    imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(0, imgui.GetStyle().FramePadding.y))
    imgui.PushItemWidth(pool["width"])


    ----==| Получение Imgui Draw List текущего окна. |==----

    local draw_list = imgui.GetWindowDrawList()


    ----==| Добавление декоративной линии под виджет. |==----

    draw_list:AddLine(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x,
    imgui.GetCursorPos().y + imgui.GetWindowPos().y + (2 * imgui.GetStyle().FramePadding.y) + imgui.CalcTextSize(hint_text).y),
    imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + pool["width"],
    imgui.GetCursorPos().y + imgui.GetWindowPos().y + (2 * imgui.GetStyle().FramePadding.y) + imgui.CalcTextSize(hint_text).y),
    imgui.GetColorU32(pool["color"]), 2.0)


    ----==| Само поле ввода. |==----

    imgui.InputText("##" .. name, pool["buffer"])


    ----==| Переключатель состояний виджета. |==----

    if not imgui.IsItemActive() then
        if pool["inactive"][2] == nil then pool["inactive"][2] = os.clock() end
        pool["inactive"][1] = true
        pool["active"][1] = false
        pool["active"][2] = nil

    elseif imgui.IsItemActive() or imgui.IsItemClicked() then
        pool["inactive"][1] = false
        pool["inactive"][2] = nil
        if pool["active"][2] == nil then pool["active"][2] = os.clock() end
        pool["active"][1] = true
    end
    
    ----==| Изменение цвета; размера и позиции подсказки по состоянию. |==----

    if pool["inactive"][1] and #pool["buffer"].v == 0 then
        pool["color"] = bringVec4To(pool["color"], pool["old_color"], pool["inactive"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 1.0, pool["inactive"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"], pool["inactive"][2], 0.25)
        
    elseif pool["inactive"][1] and #pool["buffer"].v > 0 then
        pool["color"] = bringVec4To(pool["color"], pool["old_color"], pool["inactive"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["inactive"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["inactive"][2], 0.25)

    elseif pool["active"][1] and #pool["buffer"].v == 0 then
        pool["color"] = bringVec4To(pool["color"], color, pool["active"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["active"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["active"][2], 0.25)

    elseif pool["active"][1] and #pool["buffer"].v > 0 then
        pool["color"] = bringVec4To(pool["color"], color, pool["active"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["active"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["active"][2], 0.25)
    end   
    imgui.SetWindowFontScale(pool["hint"]["scale"])
    
    
    ----==| Сама подсказка с анимацией. |==----

    draw_list:AddText(imgui.ImVec2(pool["hint"]["pos"].x + imgui.GetWindowPos().x + imgui.GetStyle().FramePadding.x,
    pool["hint"]["pos"].y + imgui.GetWindowPos().y + imgui.GetStyle().FramePadding.y),
    imgui.GetColorU32(pool["color"]),
    hint_text)


    ----==| Возвращение стилей в свой первоначальный вид. |==----

    imgui.SetWindowFontScale(1.0)
    imgui.PopItemWidth()
    imgui.PopStyleColor(3)
    imgui.PopStyleVar()
end
imgui.StateButton = function(bool, ...)
	if bool then
		return imgui.Button(...)
	else
		local but_col = imgui.GetStyle().Colors[imgui.Col.Button]
		imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
		imgui.PushStyleColor(imgui.Col.Button, set_alpha(but_col, 0.2))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, set_alpha(but_col, 0.2))
		imgui.PushStyleColor(imgui.Col.ButtonActive, set_alpha(but_col, 0.2))
		imgui.Button(...)
		imgui.PopStyleColor(4)
	end
end
function imgui.CustomInputTextWithHint(name, bool, hint, size, width, color, password)
    if not size then size = 1.0 end
    if not hint then hint = '' end
    if not width then width = 100 end
    if password then flags = imgui.InputTextFlags.Password else flags = '' end
    local clr = imgui.Col
    local pos = imgui.GetCursorScreenPos()
    local rounding = imgui.GetStyle().WindowRounding -- or ChildRounding
    local drawList = imgui.GetWindowDrawList()
    imgui.BeginChild("##"..name, imgui.ImVec2(width + 10, 25), false) -- 
        imgui.SetCursorPosX(5)
        imgui.SetWindowFontScale(size) -- size
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.15, 0.18, 0.27, 0.00)) -- alpha 0.00 or color == WindowBg & ChildBg
        imgui.PushItemWidth(width) -- width
        if password then
            result = imgui.InputTextWithHint(name, u8(hint), bool, sizeof(bool), flags)
        else
            result = imgui.InputTextWithHint(name, u8(hint), bool, sizeof(bool)) -- imgui.InputTextWithHint
        end
        imgui.PopItemWidth()
        imgui.PopStyleColor(1)
        imgui.SetWindowFontScale(1.0) -- defoult size
        drawList:AddLine(imgui.ImVec2(pos.x, pos.y + (25*size)), imgui.ImVec2(pos.x + width + 15, pos.y + (25*size)), color, 3 * size) -- draw line
    imgui.EndChild()
    return result
end

function KeyCap(keyName, isPressed, size)
    local u32 = imgui.ColorConvertFloat4ToU32
    local function bringVec4To(from, dest, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (dest.x - from.x) / 100),
                from.y + (count * (dest.y - from.y) / 100),
                from.z + (count * (dest.z - from.z) / 100),
                from.w + (count * (dest.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and dest or from, false
    end
    
	local DL = imgui.GetWindowDrawList()
	local p = imgui.GetCursorScreenPos()
	local colors = {
		[true] = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button]),
		[false] = imgui.ImVec4(0.60, 0.60, 1.00, 0.10)
	}

	if KEYCAP == nil then KEYCAP = {} end
	if KEYCAP[keyName] == nil then
		KEYCAP[keyName] = {
			status = isPressed,
			color = colors[isPressed],
			timer = nil
		}
	end

	local K = KEYCAP[keyName]
	if isPressed ~= K.status then
		K.status = isPressed
		K.timer = os.clock()
	end

	local rounding = 3.0
	local A = imgui.ImVec2(p.x, p.y)
	local B = imgui.ImVec2(p.x + size.x, p.y + size.y)
	if K.timer ~= nil then
		K.color = bringVec4To(colors[not isPressed], colors[isPressed], K.timer, 0.1)
	end
	local ts = imgui.CalcTextSize(keyName)
	local text_pos = imgui.ImVec2(p.x + (size.x / 2) - (ts.x / 2), p.y + (size.y / 2) - (ts.y / 2))

	imgui.Dummy(size)
	DL:AddRectFilled(A, B, u32(K.color), rounding)
	DL:AddText(text_pos, 0xFFFFFFFF, keyName)
end
function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'
 
    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function renderDrawButtonA(d3dFont, Title, posX, posY, targetX, targetY, boxColor, targetBoxColor, textColor, targetTextColor, centering)
    if not centering or centering == 1 then
        return renderDrawButton(d3dFont, Title, posX, posY, renderGetFontDrawTextLength(d3dFont, Title), renderGetFontDrawHeight(d3dFont), targetX, targetY, boxColor, targetBoxColor, textColor, targetTextColor) 
    end
    
    if centering == 2 then
        local success, font_length = pcall(renderGetFontDrawTextLength, d3dFont, tostring(Title))
        if success then
            return renderDrawButton(d3dFont, Title, tonumber(posX) - tonumber(font_length) / 2, posY, renderGetFontDrawTextLength(d3dFont, Title), renderGetFontDrawHeight(d3dFont), targetX, targetY, boxColor, targetBoxColor, textColor, targetTextColor) 
        end
    end

    if centering == 3 then
        local success, font_length = pcall(renderGetFontDrawTextLength, d3dFont, tostring(Title))
        if success then
            return renderDrawButton(d3dFont, Title, tonumber(posX) - tonumber(font_length), posY, renderGetFontDrawTextLength(d3dFont, Title), renderGetFontDrawHeight(d3dFont), targetX, targetY, boxColor, targetBoxColor, textColor, targetTextColor) 
        end
    end
end
function renderDrawButton(d3dFont, Title, posX, posY, sizeX, sizeY, targetX, targetY, boxColor, targetBoxColor, textColor, targetTextColor)
    local bool= false
    local currentBoxColor= boxColor
    local currentTextColor= textColor

    if  memory.getint8(getCharPointer(PLAYER_PED) + 0x528, false) ~= 19 and (targetX > posX and targetX < posX + sizeX and targetY > posY and targetY < posY + sizeY) then
        currentBoxColor= targetBoxColor
        currentTextColor= targetTextColor
        if isKeyJustPressed(VK_LBUTTON) then bool = true end
    end

    renderDrawBox(posX, posY, sizeX + 2, sizeY, currentBoxColor)
    renderFontDrawText(d3dFont, Title, posX, posY, currentTextColor)
    return bool
end


function sampev.onSendEnterVehicle(vehId, passenger)
    if ini.main.customfov then
        cameraSetLerpFov(elements.int.customfov_value[0], elements.int.customfov_value[0], 999988888, true)  -- 0922
    end
end

function sampev.onSendExitVehicle(vehId)
    if ini.main.customfov then
        cameraSetLerpFov(elements.int.customfov_value[0], elements.int.customfov_value[0], 999988888, true)  -- 0922
    end
end