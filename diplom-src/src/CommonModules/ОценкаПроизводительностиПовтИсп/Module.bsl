///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Область СлужебныеПроцедурыИФункции

// Функция возвращает ссылку на ключевую операцию по имени.
// Если ключевая операция с таким названием отсутствует в справочнике, 
// то создает новый элемент.
//
// Параметры:
//  ИмяКлючевойОперации - Строка - название ключевой операции.
//  ВыполненаСОшибкой - Булево - признак ключевой операции.
//
// Возвращаемое значение:
//  СправочникСсылка.КлючевыеОперации
//
Функция ПолучитьКлючевуюОперациюПоИмени(ИмяКлючевойОперации, Длительная = Ложь) Экспорт

	УстановитьПривилегированныйРежим(Истина);

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
				   |	КлючевыеОперации.Ссылка КАК Ссылка
				   |ИЗ
				   |	Справочник.КлючевыеОперации КАК КлючевыеОперации
				   |ГДЕ
				   |	КлючевыеОперации.ИмяХеш = &ИмяХеш
				   |
				   |УПОРЯДОЧИТЬ ПО
				   |	Ссылка";

	ХешMD5 = Новый ХешированиеДанных(ХешФункция.MD5);
	ХешMD5.Добавить(ИмяКлючевойОперации);
	ИмяХеш = ХешMD5.ХешСумма;
	ИмяХеш = СтрЗаменить(Строка(ИмяХеш), " ", "");

	Запрос.УстановитьПараметр("ИмяХеш", ИмяХеш);
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		КлючеваяОперацияСсылка = ОценкаПроизводительности.СоздатьКлючевуюОперацию(ИмяКлючевойОперации, 1, Длительная);
	Иначе
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		КлючеваяОперацияСсылка = Выборка.Ссылка;
	КонецЕсли;

	Возврат КлючеваяОперацияСсылка;

КонецФункции

#Область СтандартныеПодсистемыПовтИспКопия

// Возвращает соответствие имен "функциональных" подсистем и значения Истина.
// У "функциональной" подсистемы снят флажок "Включать в командный интерфейс".
//
Функция ИменаПодсистем() Экспорт

	ОтключенныеПодсистемы = ОценкаПроизводительностиСлужебный.ОбщиеПараметрыБазовойФункциональности().ОтключенныеПодсистемы;

	Имена = Новый Соответствие;
	ВставитьИменаПодчиненныхПодсистем(Имена, Метаданные, ОтключенныеПодсистемы);

	Возврат Новый ФиксированноеСоответствие(Имена);

КонецФункции

Процедура ВставитьИменаПодчиненныхПодсистем(Имена, РодительскаяПодсистема, ОтключенныеПодсистемы,
	ИмяРодительскойПодсистемы = "")

	Для Каждого ТекущаяПодсистема Из РодительскаяПодсистема.Подсистемы Цикл

		Если ТекущаяПодсистема.ВключатьВКомандныйИнтерфейс Тогда
			Продолжить;
		КонецЕсли;

		ИмяТекущейПодсистемы = ИмяРодительскойПодсистемы + ТекущаяПодсистема.Имя;
		Если ОтключенныеПодсистемы.Получить(ИмяТекущейПодсистемы) = Истина Тогда
			Продолжить;
		Иначе
			Имена.Вставить(ИмяТекущейПодсистемы, Истина);
		КонецЕсли;

		Если ТекущаяПодсистема.Подсистемы.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;

		ВставитьИменаПодчиненныхПодсистем(Имена, ТекущаяПодсистема, ОтключенныеПодсистемы, ИмяТекущейПодсистемы + ".");
	КонецЦикла;

КонецПроцедуры

#КонецОбласти

#Область ОбщегоНазначенияПовтИспКопия

// Возвращает массив существующих в конфигурации разделителей.
//
// Возвращаемое значение:
//   ФиксированныйМассив из Строка - массив имен общих реквизитов, которые
//  являются разделителями.
//
Функция РазделителиКонфигурации() Экспорт

	МассивРазделителей = Новый Массив;

	Для Каждого ОбщийРеквизит Из Метаданные.ОбщиеРеквизиты Цикл
		Если ОбщийРеквизит.РазделениеДанных = Метаданные.СвойстваОбъектов.РазделениеДанныхОбщегоРеквизита.Разделять Тогда
			МассивРазделителей.Добавить(ОбщийРеквизит.Имя);
		КонецЕсли;
	КонецЦикла;

	Возврат Новый ФиксированныйМассив(МассивРазделителей);

КонецФункции

#КонецОбласти

#КонецОбласти