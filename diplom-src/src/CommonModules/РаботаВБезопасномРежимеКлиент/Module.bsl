///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Область ПрограммныйИнтерфейс

// Применяет ранее сохраненные в информационной базе запросы на использование внешних ресурсов.
//
// Параметры:
//  Идентификаторы - Массив - идентификаторы запросов, которые требуется применить,
//  ФормаВладелец - ФормаКлиентскогоПриложения - форма, которая должна блокироваться до окончания применения разрешений,
//  ОповещениеОЗакрытии - ОписаниеОповещения - которое будет вызвано при успешном предоставлении разрешений.
//
Процедура ПрименитьЗапросыНаИспользованиеВнешнихРесурсов(Знач Идентификаторы, ФормаВладелец, ОповещениеОЗакрытии) Экспорт

	СтандартнаяОбработка = Истина;
	ИнтеграцияПодсистемБСПКлиент.ПриПодтвержденииЗапросовНаИспользованиеВнешнихРесурсов(Идентификаторы, ФормаВладелец,
		ОповещениеОЗакрытии, СтандартнаяОбработка);
	Если Не СтандартнаяОбработка Тогда
		Возврат;
	КонецЕсли;

	РаботаВБезопасномРежимеКлиентПереопределяемый.ПриПодтвержденииЗапросовНаИспользованиеВнешнихРесурсов(
		Идентификаторы, ФормаВладелец, ОповещениеОЗакрытии, СтандартнаяОбработка);
	НастройкаРазрешенийНаИспользованиеВнешнихРесурсовКлиент.НачатьИнициализациюЗапросаРазрешенийНаИспользованиеВнешнихРесурсов(
		Идентификаторы, ФормаВладелец, ОповещениеОЗакрытии);

КонецПроцедуры

// Открывает диалог настройки режима использования профилей безопасности для
// текущей информационной базы.
//
Процедура ОткрытьДиалогНастройкиИспользованияПрофилейБезопасности() Экспорт

	ОткрытьФорму(
		"Обработка.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.Форма.НастройкиИспользованияПрофилейБезопасности", , ,
		"Обработка.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.Форма.НастройкиИспользованияПрофилейБезопасности", , , ,
		РежимОткрытияОкнаФормы.Независимый);

КонецПроцедуры

// Позволяет администратору открыть внешнюю обработку или отчет с выбором безопасного режима.
//
// Параметры:
//   Владелец - ФормаКлиентскогоПриложения - форма-владелец формы внешней обработки или отчета. 
//
Процедура ОткрытьВнешнююОбработкуИлиОтчет(Владелец) Экспорт

	ОткрытьФорму(
		"Обработка.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.Форма.ОткрытиеВнешнейОбработкиИлиОтчетаСВыборомБезопасногоРежима", ,
		Владелец);

КонецПроцедуры

#КонецОбласти