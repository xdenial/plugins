-- translitwdx.lua
-- Аналог wdx_Translit
-- 2017.09.22
-- Сохранить в UTF-8 без BOM

--[[--
  2016.05.12:
    - публичный релиз, хе-хе.
  2016.05.13:
    - убираем расширение файла;
    - как следствие первого - исправлена работа с файлами, которые начинаются с точки :));
    - из обработки убрано "..".
  2016.05.14:
    - исправлена ошибка в таблице в lat_rus_rint ("Lat2Rus (РИНТ)");
    - исправлена таблица в lat_rus_kolxo3()
        "Lat2Rus (Колхоз)": ".." - срабатывало как два любых символа;
    - из обработки убраны каталоги, как в wdx_Translit.
        Требуется ревизия 6828 и выше! Пока (на эту дату) только в alpha-версии!
  2017.09.21:
    - исправлена ошибка с получением значения в поле "Rus2Lat (MP3 Навигатор 2)",
      "Rus2Lat (РИНТ)", "Lat2Rus (РИНТ)";
    - вернул обработку имён папок;
    - теперь не убирается расширение (точнее, текст после последней точки);
    - разное.
  2017.09.22:
    - в диалог свойств файла/каталога добавлена вкладка "Плагины":
        Начиная с ревизии 7802 при запросе данных из диалога свойств параметр Flags функции
        ContentGetValue установлен в CONTENT_DELAYIFSLOW. Таким образом в плагине, для
        медленно вычисляемых полей, необходимо проверять этот флаг и если он установлен
        возвращать nil.
      проверка Flags добавлена в начале функции ContentGetValue, чтобы исключить любой вывод.

--]]--

--[[--
  url_decode()
      http://lua-users.org/wiki/StringRecipes
  rus_lat_calc_ru(), lat_rus_calc_ru()
      Латинско-русский транслит https://www.calc.ru/ Без "Ъ" и "Ь"!
  rus_lat_gost2000(), lat_rus_gost2000()
      Транслитерация ГОСТ 7.79-2000 http://transliteration.ru/gost-7-79-2000/
  rus_lat_zagranpasport(), lat_rus_zagranpasport()
      Транслитерация имен для загранпаспорта РФ. http://transliteration.ru/mvd_1047/
  rus_lat_mp3navig(), lat_rus_mp3navig()
      Основа взята из программы MP3 Навигатор 2 by Иван Никитин
      Корректировка таблицы: Павел Дубровский aka D1P
  lat_rus_kolxo3(), rus_lat_kolxo3()
      Латинско-русский транслит для названий книг из библиотеки Колхоза.
      Автор - Сивцов Иван aka Melirius
      Версия 1.0
  rus_lat_sms(), lat_rus_sms()
      Русско-латинская транслитная перекодировка для SMS-сообщений
      Автор: Le
  rus_lat_rint(), lat_rus_rint()
      Транслитерация по системе РИНТ (Русский ИНТернет).
      Система РИНТ (Русский + ИНТернет) представляет собой письменность русского языка на графической
        основе латинского алфавита. Она предназначена для интернет-пользователей и способствует
        распространению текстов на русском языке при отсутствии возможности использования русского
        алфавита (кириллицы).
      Автор: Павел Дубровский aka D1P
  win1251_utf8()
      WIN1251-UTF8 - таблица перекодировки для плагина wdx_Translit.
      Vitaly Valitsky, 06.01.2005 v-tal@e-mail.ru
  utf8_win1251()
      UTF8-WIN1251 - таблица перекодировки для плагина wdx_Translit.
      Vitaly Valitsky, 06.01.2005 v-tal@e-mail.ru
  koi8r_win1251()
      Перекодировщик из КОИ8 в WIN1251
      Автор: Evil Angel ~ /random/+ [vinnica]
  dos866_win1251()
      Таблица перекодировки DOS866 в WIN1251.
      Автор: Павел Дубровский aka D1P
--]]--

function ContentGetSupportedField(Index)
  if (Index == 0) then
    return 'Rus2Lat (ГОСТ 7_79-2000)','', 8; -- FieldName,Units,ft_string
  elseif (Index == 1) then
    return 'Rus2Lat (Загранпаспорт РФ)','', 8;
  elseif (Index == 2) then
    return 'Rus2Lat (MP3 Навигатор 2)','', 8;
  elseif (Index == 3) then
    return 'Rus2Lat (Колхоз)','', 8;
  elseif (Index == 4) then
    return 'Rus2Lat (calc.ru, без ЪЬ)','', 8;
  elseif (Index == 5) then
    return 'Rus2Lat (SMS)','', 8;
  elseif (Index == 6) then
    return 'Rus2Lat (РИНТ)','', 8;
  elseif (Index == 7) then
    return 'Lat2Rus (ГОСТ 7_79-2000)','', 8;
  elseif (Index == 8) then
    return 'Lat2Rus (Загранпаспорт РФ)','', 8;
  elseif (Index == 9) then
    return 'Lat2Rus (MP3 Навигатор 2)','', 8;
  elseif (Index == 10) then
    return 'Lat2Rus (Колхоз)','', 8;
  elseif (Index == 11) then
    return 'Lat2Rus (calc.ru, без ЪЬ)','', 8;
  elseif (Index == 12) then
    return 'Lat2Rus (SMS)','', 8;
  elseif (Index == 13) then
    return 'Lat2Rus (РИНТ)','', 8;
  elseif (Index == 14) then
    return 'URL to Text','', 8;
  elseif (Index == 15) then
    return 'Win1251 to UTF8','', 8;
  elseif (Index == 16) then
    return 'UTF-8 to Win1251','', 8;
  elseif (Index == 17) then
    return 'KOI8R to Win1251','', 8;
  elseif (Index == 18) then
    return 'OEM866 to Win1251','', 8;
  end
  return '','', 0; -- ft_nomorefields
end

function ContentGetDetectString()
  return 'EXT="*"'; -- return detect string
end

function ContentGetValue(FileName, FieldIndex, UnitIndex, flags)
  local n, s
  -- Исключаем вывод для диалога свойств (CONTENT_DELAYIFSLOW)
  if (flags == 1) then
    return nil;
  end
  -- Разделитель каталогов
  if (string.find(FileName, "/", 1, true) == nil) then
    s = "\\"; -- Win
  else
    s = "/"; -- Linux
  end
  if (string.sub(FileName, -3) == s .. "..") or (string.sub(FileName, -2) == s .. ".") then
    return nil;
  end
  n = string.match(FileName, s .. "([^" .. s .. "]+)$");
  if (FieldIndex == 0) then
    return rus_lat_gost2000(n);
  elseif (FieldIndex == 1) then
    return rus_lat_zagranpasport(n);
  elseif (FieldIndex == 2) then
    return rus_lat_mp3navig(n);
  elseif (FieldIndex == 3) then
    return rus_lat_kolxo3(n);
  elseif (FieldIndex == 4) then
    return rus_lat_calc_ru(n);
  elseif (FieldIndex == 5) then
    return rus_lat_sms(n);
  elseif (FieldIndex == 6) then
    return rus_lat_rint(n);
  elseif (FieldIndex == 7) then
    return lat_rus_gost2000(n);
  elseif (FieldIndex == 8) then
    return lat_rus_zagranpasport(n);
  elseif (FieldIndex == 9) then
    return lat_rus_mp3navig(n);
  elseif (FieldIndex == 10) then
    return lat_rus_kolxo3(n);
  elseif (FieldIndex == 11) then
    return lat_rus_calc_ru(n);
  elseif (FieldIndex == 12) then
    return lat_rus_sms(n);
  elseif (FieldIndex == 13) then
    return lat_rus_rint(n);
  elseif (FieldIndex == 14) then
    return url_decode(n);
  elseif (FieldIndex == 15) then
    return win1251_utf8(n);
  elseif (FieldIndex == 16) then
    return utf8_win1251(n);
  elseif (FieldIndex == 17) then
    return koi8r_win1251(n);
  elseif (FieldIndex == 18) then
    return dos866_win1251(n);
  end
  return nil;
end

function url_decode(str)
  str = string.gsub(str, "+", " ");
  str = string.gsub(str, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  return str;
end

function rus_lat_gost2000(str)
  local t = {["А"]="A", ["Б"]="B", ["В"]="V", ["Г"]="G", ["Д"]="D", ["Е"]="E", ["Ё"]="YO", ["Ж"]="ZH", ["З"]="Z", ["И"]="I", ["Й"]="J", ["К"]="K", ["Л"]="L", ["М"]="M", ["Н"]="N", ["О"]="O", ["П"]="P", ["Р"]="R", ["С"]="S", ["Т"]="T", ["У"]="U", ["Ф"]="F", ["Х"]="X", ["Ц"]="C", ["Ч"]="CH", ["Ш"]="SH", ["Щ"]="SHH", ["Ъ"]="''", ["Ы"]="Y", ["Ь"]="'", ["Э"]="E", ["Ю"]="YU", ["Я"]="YA", ["а"]="a", ["б"]="b", ["в"]="v", ["г"]="g", ["д"]="d", ["е"]="e", ["ё"]="yo", ["ж"]="zh", ["з"]="z", ["и"]="i", ["й"]="j", ["к"]="k", ["л"]="l", ["м"]="m", ["н"]="n", ["о"]="o", ["п"]="p", ["р"]="r", ["с"]="s", ["т"]="t", ["у"]="u", ["ф"]="f", ["х"]="x", ["ц"]="c", ["ч"]="ch", ["ш"]="sh", ["щ"]="shh", ["ъ"]="''", ["ы"]="y", ["ь"]="'", ["э"]="e", ["ю"]="yu", ["я"]="ya"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function lat_rus_gost2000(str)
  local t = {["SHH"]="Щ", ["shh"]="щ", ["CH"]="Ч", ["ch"]="ч", ["SH"]="Ш", ["sh"]="ш", ["YO"]="Ё", ["yo"]="ё", ["YU"]="Ю", ["yu"]="ю", ["YA"]="Я", ["ya"]="я", ["ZH"]="Ж", ["zh"]="ж", ["A"]="А", ["B"]="Б", ["V"]="В", ["G"]="Г", ["D"]="Д", ["E"]="Е", ["Z"]="З", ["I"]="И", ["J"]="Й", ["K"]="К", ["L"]="Л", ["M"]="М", ["N"]="Н", ["O"]="О", ["P"]="П", ["R"]="Р", ["S"]="С", ["T"]="Т", ["U"]="У", ["F"]="Ф", ["X"]="Х", ["C"]="Ц", ["''"]="Ъ", ["Y"]="Ы", ["'"]="Ь", ["E"]="Э", ["a"]="а", ["b"]="б", ["v"]="в", ["g"]="г", ["d"]="д", ["e"]="е", ["z"]="з", ["i"]="и", ["j"]="й", ["k"]="к", ["l"]="л", ["m"]="м", ["n"]="н", ["o"]="о", ["p"]="п", ["r"]="р", ["s"]="с", ["t"]="т", ["u"]="у", ["f"]="ф", ["x"]="х", ["c"]="ц", ["''"]="ъ", ["y"]="ы", ["'"]="ь", ["e"]="э"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function rus_lat_zagranpasport(str)
  local t = {["ай"]="ay", ["ей"]="ey", ["ий"]="iy", ["ой"]="oy", ["уй"]="uy", ["ый"]="yy", ["эй"]="ey", ["юй"]="yuy", ["ей"]="yay", ["А"]="A", ["Б"]="B", ["В"]="V", ["Г"]="G", ["Д"]="D", ["Е"]="E", ["Ё"]="YE", ["Ж"]="ZH", ["З"]="Z", ["И"]="I", ["Й"]="Y", ["К"]="K", ["Л"]="L", ["М"]="M", ["Н"]="N", ["О"]="O", ["П"]="P", ["Р"]="R", ["С"]="S", ["Т"]="T", ["У"]="U", ["Ф"]="F", ["Х"]="KH", ["Ц"]="TS", ["Ч"]="CH", ["Ш"]="SH", ["Щ"]="SHCH", ["Ъ"]="''", ["Ы"]="Y", ["Ь"]="'", ["Э"]="E", ["Ю"]="YU", ["Я"]="YA", ["а"]="a", ["б"]="b", ["в"]="v", ["г"]="g", ["д"]="d", ["е"]="e", ["ё"]="ye", ["ж"]="zh", ["з"]="z", ["и"]="i", ["й"]="y", ["к"]="k", ["л"]="l", ["м"]="m", ["н"]="n", ["о"]="o", ["п"]="p", ["р"]="r", ["с"]="s", ["т"]="t", ["у"]="u", ["ф"]="f", ["х"]="kh", ["ц"]="ts", ["ч"]="ch", ["ш"]="sh", ["щ"]="shch", ["ъ"]="''", ["ы"]="y", ["ь"]="'", ["э"]="e", ["ю"]="yu", ["я"]="ya"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function lat_rus_zagranpasport(str)
  local t = {["yuy"]="юй", ["yay"]="ей", ["ay"]="ай", ["ey"]="ей", ["iy"]="ий", ["oy"]="ой", ["uy"]="уй", ["yy"]="ый", ["ey"]="эй", ["SHCH"]="Щ", ["shch"]="щ", ["CH"]="Ч", ["ch"]="ч", ["SH"]="Ш", ["sh"]="ш", ["KH"]="Х", ["kh"]="х", ["TS"]="Ц", ["ts"]="ц", ["YA"]="Я", ["ya"]="я", ["YE"]="Ё", ["ye"]="ё", ["YU"]="Ю", ["yu"]="ю", ["ZH"]="Ж", ["zh"]="ж", ["A"]="А", ["B"]="Б", ["V"]="В", ["G"]="Г", ["D"]="Д", ["E"]="Е", ["Z"]="З", ["I"]="И", ["Y"]="Й", ["K"]="К", ["L"]="Л", ["M"]="М", ["N"]="Н", ["O"]="О", ["P"]="П", ["R"]="Р", ["S"]="С", ["T"]="Т", ["U"]="У", ["F"]="Ф", ["''"]="Ъ", ["Y"]="Ы", ["'"]="Ь", ["E"]="Э", ["a"]="а", ["b"]="б", ["v"]="в", ["g"]="г", ["d"]="д", ["e"]="е", ["z"]="з", ["i"]="и", ["y"]="й", ["k"]="к", ["l"]="л", ["m"]="м", ["n"]="н", ["o"]="о", ["p"]="п", ["r"]="р", ["s"]="с", ["t"]="т", ["u"]="у", ["f"]="ф", ["''"]="ъ", ["y"]="ы", ["'"]="ь", ["e"]="э"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function rus_lat_mp3navig(str)
  local t = {["А"]="A", ["Б"]="B", ["В"]="V", ["Г"]="G", ["Д"]="D", ["Е"]="E", ["Ё"]="Е", ["Ж"]="ZH", ["З"]="Z", ["И"]="I", ["Й"]="J", ["К"]="K", ["Л"]="L", ["М"]="M", ["Н"]="N", ["О"]="O", ["П"]="P", ["Р"]="R", ["С"]="S", ["Т"]="T", ["У"]="U", ["Ф"]="F", ["Х"]="H", ["Ц"]="C", ["Ч"]="CH", ["Ш"]="SH", ["Щ"]="SHCH", ["Ъ"]="''", ["Ы"]="Y", ["Ь"]="'", ["Э"]="E", ["Ю"]="IU", ["Я"]="IA", ["а"]="a", ["б"]="b", ["в"]="v", ["г"]="g", ["д"]="d", ["е"]="e", ["ё"]="e", ["ж"]="zh", ["з"]="z", ["и"]="i", ["й"]="j", ["к"]="k", ["л"]="l", ["м"]="m", ["н"]="n", ["о"]="o", ["п"]="p", ["р"]="r", ["с"]="s", ["т"]="t", ["у"]="u", ["ф"]="f", ["х"]="h", ["ц"]="c", ["ч"]="ch", ["ш"]="sh", ["щ"]="shch", ["ъ"]="''", ["ы"]="y", ["ь"]="'", ["э"]="e", ["ю"]="iu", ["я"]="ia"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function lat_rus_mp3navig(str)
  local t = {["SHCH"]="Щ", ["shch"]="щ", ["CH"]="Ч", ["ch"]="ч", ["SH"]="Ш", ["sh"]="ш", ["IA"]="Я", ["ia"]="я", ["IU"]="Ю", ["iu"]="ю", ["ZH"]="Ж", ["zh"]="ж", ["A"]="А", ["B"]="Б", ["V"]="В", ["G"]="Г", ["D"]="Д", ["E"]="Е", ["Z"]="З", ["I"]="И", ["J"]="Й", ["K"]="К", ["L"]="Л", ["M"]="М", ["N"]="Н", ["O"]="О", ["P"]="П", ["R"]="Р", ["S"]="С", ["T"]="Т", ["U"]="У", ["F"]="Ф", ["H"]="Х", ["C"]="Ц", ["''"]="Ъ", ["Y"]="Ы", ["'"]="Ь", ["E"]="Э", ["a"]="а", ["b"]="б", ["v"]="в", ["g"]="г", ["d"]="д", ["e"]="е", ["e"]="ё", ["z"]="з", ["i"]="и", ["j"]="й", ["k"]="к", ["l"]="л", ["m"]="м", ["n"]="н", ["o"]="о", ["p"]="п", ["r"]="р", ["s"]="с", ["t"]="т", ["u"]="у", ["f"]="ф", ["h"]="х", ["c"]="ц", ["''"]="ъ", ["y"]="ы", ["'"]="ь", ["e"]="э"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function lat_rus_kolxo3(str)
  local t = {["ShCh"]="Щ", ["Shch"]="Щ", ["SHCH"]="Щ", ["shch"]="щ", ["Ch"]="Ч", ["CH"]="Ч", ["ch"]="ч", ["Sh"]="Ш", ["SH"]="Ш", ["sh"]="ш", ["JA"]="Я", ["Ja"]="Я", ["ja"]="я", ["jo"]="ё", ["JO"]="Ё", ["Jo"]="Ё", ["Ju"]="Ю", ["JU"]="Ю", ["ju"]="ю", ["Ya"]="Я", ["YA"]="Я", ["ya"]="я", ["Yo"]="Ё", ["YO"]="Ё", ["yo"]="ё", ["YU"]="Ю", ["Yu"]="Ю", ["yu"]="ю", ["Zh"]="Ж", ["ZH"]="Ж", ["zh"]="ж", ["E'"]="Э", ["e'"]="э", ["%.%."]=":", ["A"]="А", ["B"]="Б", ["V"]="В", ["G"]="Г", ["D"]="Д", ["E"]="Е", ["Z"]="З", ["I"]="И", ["J"]="Й", ["K"]="К", ["L"]="Л", ["M"]="М", ["N"]="Н", ["O"]="О", ["P"]="П", ["R"]="Р", ["S"]="С", ["T"]="Т", ["U"]="У", ["F"]="Ф", ["X"]="Х", ["H"]="Х", ["C"]="Ц", ["~"]="Ъ", ["Y"]="Ы", ["a"]="а", ["b"]="б", ["v"]="в", ["g"]="г", ["d"]="д", ["e"]="е", ["z"]="з", ["i"]="и", ["j"]="й", ["k"]="к", ["l"]="л", ["m"]="м", ["n"]="н", ["o"]="о", ["p"]="п", ["r"]="р", ["s"]="с", ["t"]="т", ["u"]="у", ["f"]="ф", ["x"]="х", ["h"]="х", ["c"]="ц", ["~"]="ъ", ["y"]="ы", ["'"]="ь", ["#"]="ь", ["'"]="Ь", ["#"]="Ь"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function rus_lat_kolxo3(str)
  local t = {["А"]="A", ["Б"]="B", ["В"]="V", ["Г"]="G", ["Д"]="D", ["Е"]="E", ["Ё"]="YO", ["Ж"]="ZH", ["З"]="Z", ["И"]="I", ["Й"]="J", ["К"]="K", ["Л"]="L", ["М"]="M", ["Н"]="N", ["О"]="O", ["П"]="P", ["Р"]="R", ["С"]="S", ["Т"]="T", ["У"]="U", ["Ф"]="F", ["Х"]="H", ["Ц"]="C", ["Ч"]="CH", ["Ш"]="SH", ["Щ"]="SHCH", ["Ъ"]="~", ["Ы"]="Y", ["Ь"]="'", ["Э"]="E'", ["Ю"]="YU", ["Я"]="YA", ["а"]="a", ["б"]="b", ["в"]="v", ["г"]="g", ["д"]="d", ["е"]="e", ["ё"]="yo", ["ж"]="zh", ["з"]="z", ["и"]="i", ["й"]="j", ["к"]="k", ["л"]="l", ["м"]="m", ["н"]="n", ["о"]="o", ["п"]="p", ["р"]="r", ["с"]="s", ["т"]="t", ["у"]="u", ["ф"]="f", ["х"]="h", ["ц"]="c", ["ч"]="ch", ["ш"]="sh", ["щ"]="shch", ["ъ"]="~", ["ы"]="y", ["ь"]="'", ["э"]="e'", ["ю"]="yu", ["я"]="ya"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function rus_lat_calc_ru(str)
  local t = {["А"]="A", ["Б"]="B", ["В"]="V", ["Г"]="G", ["Д"]="D", ["Е"]="E", ["Ё"]="E", ["Ж"]="Zh", ["З"]="Z", ["И"]="I", ["Й"]="Y", ["К"]="K", ["Л"]="L", ["М"]="M", ["Н"]="N", ["О"]="O", ["П"]="P", ["Р"]="R", ["С"]="S", ["Т"]="T", ["У"]="U", ["Ф"]="F", ["Х"]="Kh", ["Ц"]="Ts", ["Ч"]="Ch", ["Ш"]="Sh", ["Щ"]="Shch", ["Ъ"]="_", ["Ы"]="Y", ["Ь"]="_", ["Э"]="E", ["Ю"]="Yu", ["Я"]="Ya", ["а"]="a", ["б"]="b", ["в"]="v", ["г"]="g", ["д"]="d", ["е"]="e", ["ё"]="e", ["ж"]="zh", ["з"]="z", ["и"]="i", ["й"]="y", ["к"]="k", ["л"]="l", ["м"]="m", ["н"]="n", ["о"]="o", ["п"]="p", ["р"]="r", ["с"]="s", ["т"]="t", ["у"]="u", ["ф"]="f", ["х"]="kh", ["ц"]="ts", ["ч"]="ch", ["ш"]="sh", ["щ"]="shch", ["ъ"]="_", ["ы"]="y", ["ь"]="_", ["э"]="e", ["ю"]="yu", ["я"]="ya"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function lat_rus_calc_ru(str)
  local t = {["Shch"]="Щ", ["shch"]="щ", ["Ch"]="Ч", ["ch"]="ч", ["Kh"]="Х", ["kh"]="х", ["Sh"]="Ш", ["sh"]="ш", ["Ts"]="Ц", ["ts"]="ц", ["Ya"]="Я", ["ya"]="я", ["Yu"]="Ю", ["yu"]="ю", ["Zh"]="Ж", ["zh"]="ж", ["A"]="А", ["B"]="Б", ["V"]="В", ["G"]="Г", ["D"]="Д", ["E"]="Е", ["E"]="Ё", ["Z"]="З", ["I"]="И", ["Y"]="Й", ["K"]="К", ["L"]="Л", ["M"]="М", ["N"]="Н", ["O"]="О", ["P"]="П", ["R"]="Р", ["S"]="С", ["T"]="Т", ["U"]="У", ["F"]="Ф", ["Y"]="Ы", ["E"]="Э", ["a"]="а", ["b"]="б", ["v"]="в", ["g"]="г", ["d"]="д", ["e"]="е", ["e"]="ё", ["z"]="з", ["i"]="и", ["y"]="й", ["k"]="к", ["l"]="л", ["m"]="м", ["n"]="н", ["o"]="о", ["p"]="п", ["r"]="р", ["s"]="с", ["t"]="т", ["u"]="у", ["f"]="ф", ["y"]="ы", ["e"]="э"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function rus_lat_sms(str)
  local t = {["А"]="A", ["Б"]="B", ["В"]="V", ["Г"]="G", ["Д"]="D", ["Е"]="E", ["Ё"]="E", ["Ж"]="ZH", ["З"]="Z", ["И"]="I", ["Й"]="J", ["К"]="K", ["Л"]="L", ["М"]="M", ["Н"]="N", ["О"]="O", ["П"]="P", ["Р"]="R", ["С"]="S", ["Т"]="T", ["У"]="U", ["Ф"]="F", ["Х"]="H", ["Ц"]="TS", ["Ч"]="CH", ["Ш"]="SH", ["Щ"]="SCH", ["Ъ"]="''", ["Ы"]="YI", ["Ь"]="'", ["Э"]="YE", ["Ю"]="YU", ["Я"]="YA", ["а"]="a", ["б"]="b", ["в"]="v", ["г"]="g", ["д"]="d", ["е"]="e", ["ё"]="e", ["ж"]="zh", ["з"]="z", ["и"]="i", ["й"]="j", ["к"]="k", ["л"]="l", ["м"]="m", ["н"]="n", ["о"]="o", ["п"]="p", ["р"]="r", ["с"]="s", ["т"]="t", ["у"]="u", ["ф"]="f", ["х"]="h", ["ц"]="ts", ["ч"]="ch", ["ш"]="sh", ["щ"]="sch", ["ъ"]="''", ["ы"]="yi", ["ь"]="'", ["э"]="ye", ["ю"]="yu", ["я"]="ya"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function lat_rus_sms(str)
  local t = {["SCH"]="Щ", ["sch"]="щ", ["CH"]="Ч", ["ch"]="ч", ["SH"]="Ш", ["sh"]="ш", ["TS"]="Ц", ["ts"]="ц", ["YA"]="Я", ["ya"]="я", ["YE"]="Э", ["ye"]="э", ["YI"]="Ы", ["yi"]="ы", ["YU"]="Ю", ["yu"]="ю", ["ZH"]="Ж", ["zh"]="ж", ["A"]="А", ["B"]="Б", ["V"]="В", ["G"]="Г", ["D"]="Д", ["E"]="Е", ["Z"]="З", ["I"]="И", ["J"]="Й", ["K"]="К", ["L"]="Л", ["M"]="М", ["N"]="Н", ["O"]="О", ["P"]="П", ["R"]="Р", ["S"]="С", ["T"]="Т", ["U"]="У", ["F"]="Ф", ["H"]="Х", ["''"]="Ъ", ["'"]="Ь", ["a"]="а", ["b"]="б", ["v"]="в", ["g"]="г", ["d"]="д", ["e"]="е", ["e"]="ё", ["z"]="з", ["i"]="и", ["j"]="й", ["k"]="к", ["l"]="л", ["m"]="м", ["n"]="н", ["o"]="о", ["p"]="п", ["r"]="р", ["s"]="с", ["t"]="т", ["u"]="у", ["f"]="ф", ["h"]="х", ["''"]="ъ", ["'"]="ь"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function rus_lat_rint(str)
  local t = {["Аё"]="A'yo", ["аё"]="a'yo", ["Юё"]="Yuyo", ["юё"]="yuyo", ["Яё"]="Yayo", ["яё"]="yayo", ["Юя"]="Yuya", ["юя"]="yuya", ["Яя"]="Yaya", ["яя"]="yaya", ["Щя"]="Xq'a", ["щя"]="xq'a", ["Ея"]="Yeya", ["ея"]="yeya", ["Ёя"]="Yoya", ["ёя"]="yoya", ["Юю"]="Yuyu", ["юю"]="yuyu", ["Яю"]="Yayu", ["яю"]="yayu", ["Ёе"]="Yoye", ["ёе"]="yoye", ["Юе"]="Yuye", ["юе"]="Yuye", ["Яе"]="Yaye", ["яе"]="yaye", ["Её"]="Yeyo", ["её"]="yeyo", ["Ёё"]="Yoyo", ["ёё"]="yoyo", ["Щё"]="Xq’o", ["щё"]="xq’o", ["Ею"]="Yeyu", ["Ёю"]="Yoyu", ["ёю"]="yoyu", ["Щю"]="Xq'u", ["щю"]="xq'u", ["Ае"]="Aye", ["ае"]="aye", ["Ее"]="Eye", ["ее"]="eye", ["Ие"]="Iye", ["ие"]="iye", ["Ое"]="Oye", ["ое"]="oye", ["Уе"]="Uye", ["уе"]="uye", ["Ще"]="Xqe", ["ще"]="xqe", ["ье"]="'ye", ["Бё"]="B’o", ["бё"]="b’o", ["Вё"]="V’o", ["вё"]="v’o", ["Гё"]="G’o", ["гё"]="g’o", ["Дё"]="D’o", ["дё"]="d’o", ["Иё"]="Iyo", ["иё"]="iyo", ["Йё"]="Yyo", ["йё"]="yyo", ["Кё"]="K’o", ["кё"]="k’o", ["Лё"]="L’o", ["лё"]="l’o", ["Мё"]="M’o", ["мё"]="m’o", ["Нё"]="N’o", ["нё"]="n’o", ["Оё"]="Oyo", ["оё"]="oyo", ["Пё"]="P’o", ["пё"]="p’o", ["Рё"]="R’o", ["рё"]="r’o", ["Сё"]="S’o", ["сё"]="c’o", ["Тё"]="T’o", ["тё"]="t’o", ["Уё"]="Uyo", ["уё"]="uyo", ["Фё"]="F’o", ["фё"]="f’o", ["Хё"]="H’o", ["хё"]="h’o", ["Цё"]="C’o", ["цё"]="c’o", ["Чё"]="Q’o", ["чё"]="q’o", ["Шё"]="X’o", ["шё"]="x’o", ["Ыю"]="Wyu", ["ыю"]="wyu", ["ью"]="'yu", ["Эю"]="Eyu", ["эю"]="eyu", ["Ая"]="Aya", ["ая"]="aya", ["Бя"]="B'a", ["бя"]="b'a", ["Вя"]="V'a", ["вя"]="v'a", ["Гя"]="G'a", ["гя"]="g'a", ["Дя"]="D'a", ["дя"]="d'a", ["Ия"]="Iya", ["ия"]="iya", ["Йя"]="Yya", ["йя"]="yya", ["Кя"]="K'a", ["кя"]="k'a", ["Ля"]="L'a", ["ля"]="l'a", ["Мя"]="M'a", ["мя"]="m'a", ["Ня"]="N'a", ["ня"]="n'a", ["Оя"]="Oya", ["оя"]="oya", ["Пя"]="P'a", ["пя"]="p'a", ["Ря"]="R'a", ["ря"]="r'a", ["Ся"]="S'a", ["ся"]="s'a", ["Тя"]="T'a", ["тя"]="t'a", ["Уя"]="Uya", ["уя"]="uya", ["Фя"]="F'a", ["фя"]="f'a", ["Хя"]="H'a", ["хя"]="h'a", ["Ця"]="C'a", ["ця"]="c'a", ["Чя"]="Q'a", ["чя"]="q'a", ["Шя"]="X'a", ["шя"]="x'a", ["Ыя"]="Wya", ["ыя"]="wya", ["ья"]="'ya", ["Эя"]="Eya", ["эя"]="eya", ["ьи"]="'yi", ["ьо"]="'yo", ["Ыё"]="Wyo", ["ыё"]="wyo", ["ьё"]="'yo", ["Эё"]="Eyo", ["эё"]="eyo", ["Аю"]="Ayu", ["аю"]="ayu", ["Бю"]="B'u", ["бю"]="b'u", ["Вю"]="V'u", ["вю"]="v'u", ["Гю"]="G'u", ["гю"]="g'u", ["Дю"]="D'u", ["дю"]="d'u", ["ею"]="eyu", ["Ию"]="Iyu", ["ию"]="iyu", ["Йю"]="Yyu", ["йю"]="yyu", ["Кю"]="K'u", ["кю"]="k'u", ["Лю"]="L'u", ["лю"]="l'u", ["Мю"]="M'u", ["мю"]="m'u", ["Ню"]="N'u", ["ню"]="n'u", ["Ою"]="Oyu", ["ою"]="oyu", ["Пю"]="P'u", ["пю"]="p'u", ["Рю"]="R'u", ["рю"]="r'u", ["Сю"]="S'u", ["сю"]="s'u", ["Тю"]="T'u", ["тю"]="t'u", ["Ую"]="Uyu", ["ую"]="uyu", ["Фю"]="F'u", ["фю"]="f'u", ["Хю"]="H'u", ["хю"]="h'u", ["Цю"]="C'u", ["цю"]="c'u", ["Чю"]="Q'u", ["чю"]="Q'u", ["Шю"]="X'u", ["шю"]="x'u", ["Бе"]="Be", ["бе"]="be", ["Ве"]="Ve", ["ве"]="ve", ["Ге"]="Ge", ["ге"]="ge", ["Де"]="De", ["де"]="de", ["Йе"]="Ye", ["йе"]="ye", ["Ке"]="Ke", ["ке"]="ke", ["Ле"]="Le", ["ле"]="le", ["Ме"]="Me", ["ме"]="me", ["Не"]="Ne", ["не"]="ne", ["Пе"]="Pe", ["пе"]="pe", ["Ре"]="Re", ["ре"]="re", ["Се"]="Se", ["се"]="se", ["Те"]="Te", ["те"]="te", ["Фе"]="Fe", ["фе"]="fe", ["Хе"]="He", ["хе"]="he", ["Це"]="Ce", ["це"]="ce", ["Че"]="Qe", ["че"]="qe", ["Ше"]="Xe", ["ше"]="xe", ["ъе"]="ye", ["Ые"]="We", ["ые"]="we", ["Эе"]="Ee", ["эе"]="ee", ["ъё"]="yo", ["ъю"]="yu", ["ъя"]="ya", ["Щ"]="Xq", ["щ"]="xq", ["Ю"]="Yu", ["ю"]="yu", ["Я"]="Ya", ["я"]="ya", ["Е"]="Ye", ["е"]="ye", ["Ё"]="Yo", ["ё"]="yo", ["А"]="A", ["а"]="a", ["Б"]="B", ["б"]="b", ["В"]="V", ["в"]="v", ["Г"]="G", ["г"]="g", ["Д"]="D", ["д"]="d", ["Ж"]="J", ["ж"]="j", ["З"]="Z", ["з"]="z", ["И"]="I", ["и"]="i", ["Й"]="Y", ["й"]="y", ["К"]="K", ["к"]="k", ["Л"]="L", ["л"]="l", ["М"]="M", ["м"]="m", ["Н"]="N", ["н"]="n", ["О"]="O", ["о"]="o", ["П"]="P", ["п"]="p", ["Р"]="R", ["р"]="r", ["С"]="S", ["с"]="s", ["Т"]="T", ["т"]="t", ["У"]="U", ["у"]="u", ["Ф"]="F", ["ф"]="f", ["Х"]="H", ["х"]="h", ["Ц"]="C", ["ц"]="c", ["Ч"]="Q", ["ч"]="q", ["Ш"]="X", ["ш"]="x", ["Ы"]="W", ["ы"]="w", ["ь"]="'", ["Э"]="E", ["э"]="e", ["ъ"]=""}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function lat_rus_rint(str)
  local t = {["A'yo"]="Аё", ["a'yo"]="аё", ["Yuyo"]="Юё", ["yuyo"]="юё", ["Yayo"]="Яё", ["yayo"]="яё", ["Yuya"]="Юя", ["yuya"]="юя", ["Yaya"]="Яя", ["yaya"]="яя", ["Xq'a"]="Щя", ["xq'a"]="щя", ["Yeya"]="Ея", ["yeya"]="ея", ["Yoya"]="Ёя", ["yoya"]="ёя", ["Yuyu"]="Юю", ["yuyu"]="юю", ["Yayu"]="Яю", ["yayu"]="яю", ["Yoye"]="Ёе", ["yoye"]="ёе", ["Yuye"]="Юе", ["Yuye"]="юе", ["Yaye"]="Яе", ["yaye"]="яе", ["Yeyo"]="Её", ["yeyo"]="её", ["Yoyo"]="Ёё", ["yoyo"]="ёё", ["Xq’o"]="Щё", ["xq’o"]="щё", ["Yeyu"]="Ею", ["Yoyu"]="Ёю", ["yoyu"]="ёю", ["Xq'u"]="Щю", ["xq'u"]="щю", ["Aye"]="Ае", ["aye"]="ае", ["Eye"]="Ее", ["eye"]="ее", ["Iye"]="Ие", ["iye"]="ие", ["Oye"]="Ое", ["oye"]="ое", ["Uye"]="Уе", ["uye"]="уе", ["Xqe"]="Ще", ["xqe"]="ще", ["'ye"]="ье", ["B’o"]="Бё", ["b’o"]="бё", ["V’o"]="Вё", ["v’o"]="вё", ["G’o"]="Гё", ["g’o"]="гё", ["D’o"]="Дё", ["d’o"]="дё", ["Iyo"]="Иё", ["iyo"]="иё", ["Yyo"]="Йё", ["yyo"]="йё", ["K’o"]="Кё", ["k’o"]="кё", ["L’o"]="Лё", ["l’o"]="лё", ["M’o"]="Мё", ["m’o"]="мё", ["N’o"]="Нё", ["n’o"]="нё", ["Oyo"]="Оё", ["oyo"]="оё", ["P’o"]="Пё", ["p’o"]="пё", ["R’o"]="Рё", ["r’o"]="рё", ["S’o"]="Сё", ["c’o"]="сё", ["T’o"]="Тё", ["t’o"]="тё", ["Uyo"]="Уё", ["uyo"]="уё", ["F’o"]="Фё", ["f’o"]="фё", ["H’o"]="Хё", ["h’o"]="хё", ["C’o"]="Цё", ["c’o"]="цё", ["Q’o"]="Чё", ["q’o"]="чё", ["X’o"]="Шё", ["x’o"]="шё", ["Wyu"]="Ыю", ["wyu"]="ыю", ["'yu"]="ью", ["Eyu"]="Эю", ["eyu"]="эю", ["Aya"]="Ая", ["aya"]="ая", ["B'a"]="Бя", ["b'a"]="бя", ["V'a"]="Вя", ["v'a"]="вя", ["G'a"]="Гя", ["g'a"]="гя", ["D'a"]="Дя", ["d'a"]="дя", ["Iya"]="Ия", ["iya"]="ия", ["Yya"]="Йя", ["yya"]="йя", ["K'a"]="Кя", ["k'a"]="кя", ["L'a"]="Ля", ["l'a"]="ля", ["M'a"]="Мя", ["m'a"]="мя", ["N'a"]="Ня", ["n'a"]="ня", ["Oya"]="Оя", ["oya"]="оя", ["P'a"]="Пя", ["p'a"]="пя", ["R'a"]="Ря", ["r'a"]="ря", ["S'a"]="Ся", ["s'a"]="ся", ["T'a"]="Тя", ["t'a"]="тя", ["Uya"]="Уя", ["uya"]="уя", ["F'a"]="Фя", ["f'a"]="фя", ["H'a"]="Хя", ["h'a"]="хя", ["C'a"]="Ця", ["c'a"]="ця", ["Q'a"]="Чя", ["q'a"]="чя", ["X'a"]="Шя", ["x'a"]="шя", ["Wya"]="Ыя", ["wya"]="ыя", ["'ya"]="ья", ["Eya"]="Эя", ["eya"]="эя", ["'yi"]="ьи", ["'yo"]="ьо", ["Wyo"]="Ыё", ["wyo"]="ыё", ["'yo"]="ьё", ["Eyo"]="Эё", ["eyo"]="эё", ["Ayu"]="Аю", ["ayu"]="аю", ["B'u"]="Бю", ["b'u"]="бю", ["V'u"]="Вю", ["v'u"]="вю", ["G'u"]="Гю", ["g'u"]="гю", ["D'u"]="Дю", ["d'u"]="дю", ["eyu"]="ею", ["Iyu"]="Ию", ["iyu"]="ию", ["Yyu"]="Йю", ["yyu"]="йю", ["K'u"]="Кю", ["k'u"]="кю", ["L'u"]="Лю", ["l'u"]="лю", ["M'u"]="Мю", ["m'u"]="мю", ["N'u"]="Ню", ["n'u"]="ню", ["Oyu"]="Ою", ["oyu"]="ою", ["P'u"]="Пю", ["p'u"]="пю", ["R'u"]="Рю", ["r'u"]="рю", ["S'u"]="Сю", ["s'u"]="сю", ["T'u"]="Тю", ["t'u"]="тю", ["Uyu"]="Ую", ["uyu"]="ую", ["F'u"]="Фю", ["f'u"]="фю", ["H'u"]="Хю", ["h'u"]="хю", ["C'u"]="Цю", ["c'u"]="цю", ["Q'u"]="Чю", ["Q'u"]="чю", ["X'u"]="Шю", ["x'u"]="шю", ["Be"]="Бе", ["be"]="бе", ["Ve"]="Ве", ["ve"]="ве", ["Ge"]="Ге", ["ge"]="ге", ["De"]="Де", ["de"]="де", ["Ye"]="Йе", ["ye"]="йе", ["Ke"]="Ке", ["ke"]="ке", ["Le"]="Ле", ["le"]="ле", ["Me"]="Ме", ["me"]="ме", ["Ne"]="Не", ["ne"]="не", ["Pe"]="Пе", ["pe"]="пе", ["Re"]="Ре", ["re"]="ре", ["Se"]="Се", ["se"]="се", ["Te"]="Те", ["te"]="те", ["Fe"]="Фе", ["fe"]="фе", ["He"]="Хе", ["he"]="хе", ["Ce"]="Це", ["ce"]="це", ["Qe"]="Че", ["qe"]="че", ["Xe"]="Ше", ["xe"]="ше", ["ye"]="ъе", ["We"]="Ые", ["we"]="ые", ["Ee"]="Эе", ["ee"]="эе", ["yo"]="ъё", ["yu"]="ъю", ["ya"]="ъя", ["Xq"]="Щ", ["xq"]="щ", ["Yu"]="Ю", ["yu"]="ю", ["Ya"]="Я", ["ya"]="я", ["Ye"]="Е", ["ye"]="е", ["Yo"]="Ё", ["yo"]="ё", ["A"]="А", ["a"]="а", ["B"]="Б", ["b"]="б", ["V"]="В", ["v"]="в", ["G"]="Г", ["g"]="г", ["D"]="Д", ["d"]="д", ["J"]="Ж", ["j"]="ж", ["Z"]="З", ["z"]="з", ["I"]="И", ["i"]="и", ["Y"]="Й", ["y"]="й", ["K"]="К", ["k"]="к", ["L"]="Л", ["l"]="л", ["M"]="М", ["m"]="м", ["N"]="Н", ["n"]="н", ["O"]="О", ["o"]="о", ["P"]="П", ["p"]="п", ["R"]="Р", ["r"]="р", ["S"]="С", ["s"]="с", ["T"]="Т", ["t"]="т", ["U"]="У", ["u"]="у", ["F"]="Ф", ["f"]="ф", ["H"]="Х", ["h"]="х", ["C"]="Ц", ["c"]="ц", ["Q"]="Ч", ["q"]="ч", ["X"]="Ш", ["x"]="ш", ["W"]="Ы", ["w"]="ы", ["'"]="ь", ["E"]="Э", ["e"]="э"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function win1251_utf8(str)
  local t = {["А"]="Рђ", ["Б"]="Р‘", ["В"]="Р’", ["Г"]="Р“", ["Д"]="Р”", ["Е"]="Р•", ["Ё"]="РЃ", ["Ж"]="Р–", ["З"]="Р—", ["И"]="Р", ["Й"]="Р™", ["К"]="Рљ", ["Л"]="Р›", ["М"]="Рњ", ["Н"]="Рќ", ["О"]="Рћ", ["П"]="Рџ", ["Р"]="Р ", ["С"]="РЎ", ["Т"]="Рў", ["У"]="РЈ", ["Ф"]="Р¤", ["Х"]="РҐ", ["Ц"]="Р¦", ["Ч"]="Р§", ["Ш"]="РЁ", ["Щ"]="Р©", ["Ъ"]="РЄ", ["Ы"]="Р«", ["Ь"]="Р¬", ["Э"]="Р­", ["Ю"]="Р®", ["Я"]="РЇ", ["а"]="Р°", ["б"]="Р±", ["в"]="РІ", ["г"]="Рі", ["д"]="Рґ", ["е"]="Рµ", ["ё"]="С‘", ["ж"]="Р¶", ["з"]="Р·", ["и"]="Рё", ["й"]="Р№", ["к"]="Рє", ["л"]="Р»", ["м"]="Рј", ["н"]="РЅ", ["о"]="Рѕ", ["п"]="Рї", ["р"]="СЂ", ["с"]="СЃ", ["т"]="С‚", ["у"]="Сѓ", ["ф"]="С„", ["х"]="С…", ["ц"]="С†", ["ч"]="С‡", ["ш"]="С€", ["щ"]="С‰", ["ъ"]="СЉ", ["ы"]="С‹", ["ь"]="СЊ", ["э"]="СЌ", ["ю"]="СЋ", ["я"]="СЏ"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function utf8_win1251(str)
  local t = {["Рђ"]="А", ["Р‘"]="Б", ["Р’"]="В", ["Р“"]="Г", ["Р”"]="Д", ["Р•"]="Е", ["РЃ"]="Ё", ["Р–"]="Ж", ["Р—"]="З", ["Р"]="И", ["Р™"]="Й", ["Рљ"]="К", ["Р›"]="Л", ["Рњ"]="М", ["Рќ"]="Н", ["Рћ"]="О", ["Рџ"]="П", ["Р "]="Р", ["РЎ"]="С", ["Рў"]="Т", ["РЈ"]="У", ["Р¤"]="Ф", ["РҐ"]="Х", ["Р¦"]="Ц", ["Р§"]="Ч", ["РЁ"]="Ш", ["Р©"]="Щ", ["РЄ"]="Ъ", ["Р«"]="Ы", ["Р¬"]="Ь", ["Р­"]="Э", ["Р®"]="Ю", ["РЇ"]="Я", ["Р°"]="а", ["Р±"]="б", ["РІ"]="в", ["Рі"]="г", ["Рґ"]="д", ["Рµ"]="е", ["С‘"]="ё", ["Р¶"]="ж", ["Р·"]="з", ["Рё"]="и", ["Р№"]="й", ["Рє"]="к", ["Р»"]="л", ["Рј"]="м", ["РЅ"]="н", ["Рѕ"]="о", ["Рї"]="п", ["СЂ"]="р", ["СЃ"]="с", ["С‚"]="т", ["Сѓ"]="у", ["С„"]="ф", ["С…"]="х", ["С†"]="ц", ["С‡"]="ч", ["С€"]="ш", ["С‰"]="щ", ["СЉ"]="ъ", ["С‹"]="ы", ["СЊ"]="ь", ["СЌ"]="э", ["СЋ"]="ю", ["СЏ"]="я"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function koi8r_win1251(str)
  local t = {["К"]="й", ["Г"]="ц", ["Х"]="у", ["Л"]="к", ["Е"]="е", ["О"]="н", ["З"]="г", ["Ы"]="ш", ["Э"]="щ", ["Ъ"]="з", ["И"]="х", ["Я"]="ъ", ["Ж"]="ф", ["Щ"]="ы", ["Ч"]="в", ["Б"]="а", ["Р"]="п", ["Т"]="р", ["П"]="о", ["М"]="л", ["Д"]="д", ["Ц"]="ж", ["Ь"]="э", ["C"]="я", ["Ю"]="ч", ["У"]="с", ["Н"]="м", ["Й"]="и", ["Ф"]="т", ["Ш"]="ь", ["В"]="б", ["А"]="ю", ["к"]="Й", ["г"]="Ц", ["х"]="У", ["л"]="К", ["е"]="Е", ["о"]="Н", ["з"]="Г", ["ы"]="Ш", ["э"]="Щ", ["ъ"]="З", ["и"]="Х", ["y"]="Ъ", ["ж"]="Ф", ["щ"]="Ы", ["ч"]="В", ["б"]="А", ["р"]="П", ["т"]="Р", ["п"]="О", ["м"]="Л", ["д"]="Д", ["ц"]="Ж", ["ь"]="Э", ["с"]="Я", ["ю"]="Ч", ["у"]="С", ["н"]="М", ["й"]="И", ["ф"]="Т", ["ш"]="Ь", ["в"]="Б", ["а"]="Ю", ["Ь"]="э", ["ь"]="Э", ["y"]="Ъ", ["Я"]="ъ", ["C"]="я", ["С"]="я", ["Я"]="я", ["я"]="Я", ["ъ"]="Я", ["Ъ"]="я"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end

function dos866_win1251(str)
  local t = {["‰"]="Й", ["–"]="Ц", ["“"]="У", ["Љ"]="К", ["…"]="Е", ["Ќ"]="Н", ["ѓ"]="Г", [""]="Ш", ["™"]="Щ", ["‡"]="З", ["•"]="Х", ["љ"]="Ъ", ["”"]="Ф", ["›"]="Ы", ["‚"]="В", ["Ђ"]="А", ["Џ"]="П", ["ђ"]="Р", ["Ћ"]="О", ["‹"]="Л", ["„"]="Д", ["†"]="Ж", ["ќ"]="Э", ["џ"]="Я", ["—"]="Ч", ["‘"]="С", ["Њ"]="М", ["€"]="И", ["’"]="Т", ["њ"]="Ь", ["Ѓ"]="Б", ["ћ"]="Ю", ["©"]="й", ["ж"]="ц", ["г"]="у", ["Є"]="к", ["Ґ"]="е", ["­"]="н", ["Ј"]="г", ["и"]="ш", ["й"]="щ", ["§"]="з", ["е"]="х", ["к"]="ъ", ["д"]="ф", ["л"]="ы", ["ў"]="в", [" "]="а", ["Ї"]="п", ["а"]="р", ["®"]="о", ["«"]="л", ["¤"]="д", ["¦"]="ж", ["н"]="э", ["п"]="я", ["з"]="ч", ["б"]="с", ["¬"]="м", ["Ё"]="и", ["в"]="т", ["м"]="ь", ["Ў"]="б", ["о"]="ю"}
  for key, val in pairs(t) do
    str = string.gsub(str, key, val);
  end
  return str;
end
