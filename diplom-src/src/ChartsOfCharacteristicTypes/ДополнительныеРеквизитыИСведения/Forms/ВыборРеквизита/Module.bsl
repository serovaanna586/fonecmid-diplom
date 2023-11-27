///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	ТаблицаРеквизитов = ПолучитьИзВременногоХранилища(Параметры.РеквизитыОбъекта);
	ЗначениеВРеквизитФормы(ТаблицаРеквизитов, "РеквизитыОбъекта");
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаВыбрать(Команда)
	ВыбратьЭлементИЗакрыть();
КонецПроцедуры

&НаКлиенте
Процедура КомандаОтмена(Команда)
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура РеквизитыОбъектаВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ВыбратьЭлементИЗакрыть();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыбратьЭлементИЗакрыть()
	ВыбраннаяСтрока = Элементы.РеквизитыОбъекта.ТекущиеДанные;
	ПараметрыВыбора = Новый Структура;
	ПараметрыВыбора.Вставить("Реквизит", ВыбраннаяСтрока.Реквизит);
	ПараметрыВыбора.Вставить("Представление", ВыбраннаяСтрока.Представление);
	ПараметрыВыбора.Вставить("ТипЗначения", ВыбраннаяСтрока.ТипЗначения);
	ПараметрыВыбора.Вставить("РежимВыбора", ВыбраннаяСтрока.РежимВыбора);

	Оповестить("Свойства_ВыборРеквизитаОбъекта", ПараметрыВыбора);

	Закрыть();
КонецПроцедуры

#КонецОбласти