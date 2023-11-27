///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ВариантыОтчетов

// Задать настройки формы отчета.
//
// Параметры:
//   Форма - ФормаКлиентскогоПриложения
//         - Неопределено
//   КлючВарианта - Строка
//                - Неопределено
//   Настройки - см. ОтчетыКлиентСервер.НастройкиОтчетаПоУмолчанию
//
Процедура ОпределитьНастройкиФормы(Форма, КлючВарианта, Настройки) Экспорт
	Настройки.ФормироватьСразу = Истина;
КонецПроцедуры

// Конец СтандартныеПодсистемы.ВариантыОтчетов

#КонецОбласти

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	// Переформируем заголовок по набору ссылок.
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	НаборСсылок = Настройки.ПараметрыДанных.НайтиЗначениеПараметра( Новый ПараметрКомпоновкиДанных("НаборСсылок"));
	Если НаборСсылок <> Неопределено Тогда
		НаборСсылок = НаборСсылок.Значение;
	КонецЕсли;
	Заголовок = ЗаголовокПоНаборуСсылок(НаборСсылок);
	КомпоновщикНастроек.ФиксированныеНастройки.ПараметрыВывода.УстановитьЗначениеПараметра("Заголовок", Заголовок);

	ПроцессорКомпоновки = ПроцессорКомпоновки(ДанныеРасшифровки);

	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);

	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПроцессорКомпоновки(ДанныеРасшифровки = Неопределено, ТипГенератора = "ГенераторМакетаКомпоновкиДанных")

	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	
	// Список ссылок из параметров.
	ЗначениеПараметра = Настройки.ПараметрыДанных.НайтиЗначениеПараметра(
		Новый ПараметрКомпоновкиДанных("НаборСсылок")).Значение;
	ТипЗначения = ТипЗнч(ЗначениеПараметра);
	Если ТипЗначения = Тип("СписокЗначений") Тогда
		МассивСсылок = ЗначениеПараметра.ВыгрузитьЗначения();
	ИначеЕсли ТипЗначения = Тип("Массив") Тогда
		МассивСсылок = ЗначениеПараметра;
	Иначе
		МассивСсылок = Новый Массив;
		Если ЗначениеПараметра <> Неопределено Тогда
			МассивСсылок.Добавить(ЗначениеПараметра);
		КонецЕсли;
	КонецЕсли;
	
	// Параметры вывода из фиксированных параметров.
	Для Каждого ПараметрВывода Из КомпоновщикНастроек.ФиксированныеНастройки.ПараметрыВывода.Элементы Цикл
		Если ПараметрВывода.Использование Тогда
			Элемент = Настройки.ПараметрыВывода.НайтиЗначениеПараметра(ПараметрВывода.Параметр);
			Если Элемент <> Неопределено Тогда
				Элемент.Использование = Истина;
				Элемент.Значение      = ПараметрВывода.Значение;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	// Таблицы источников данных
	МестаИспользования = ОбщегоНазначения.МестаИспользования(МассивСсылок);
	
	// Проверяем чтобы у нас были все ссылки.
	Для Каждого Ссылка Из МассивСсылок Цикл
		Если МестаИспользования.Найти(Ссылка, "Ссылка") = Неопределено Тогда
			Дополнительно = МестаИспользования.Добавить();
			Дополнительно.Ссылка = Ссылка;
			Дополнительно.ВспомогательныеДанные = Истина;
		КонецЕсли;
	КонецЦикла;

	ВнешниеДанные = Новый Структура;
	ВнешниеДанные.Вставить("МестаИспользования", МестаИспользования);
	
	// Выполнение
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	Макет = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, Настройки, ДанныеРасшифровки, , Тип(ТипГенератора));

	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(Макет, ВнешниеДанные, ДанныеРасшифровки);

	Возврат ПроцессорКомпоновки;
КонецФункции

Функция ЗаголовокПоНаборуСсылок(Знач НаборСсылок)

	Если ТипЗнч(НаборСсылок) = Тип("СписокЗначений") Тогда
		ВсегоСсылок = НаборСсылок.Количество();
		Если ВсегоСсылок = 1 Тогда
			Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Места использования %1'"), ОбщегоНазначения.ПредметСтрокой(НаборСсылок[0].Значение));
		ИначеЕсли ВсегоСсылок > 1 Тогда

			ОдинаковыйТип = Истина;
			ТипПервойСсылки = ТипЗнч(НаборСсылок[0].Значение);
			Для Позиция = 0 По ВсегоСсылок - 1 Цикл
				Если ТипЗнч(НаборСсылок[Позиция].Значение) <> ТипПервойСсылки Тогда
					ОдинаковыйТип = Ложь;
					Прервать;
				КонецЕсли;
			КонецЦикла;

			Если ОдинаковыйТип Тогда
				Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Места использования элементов ""%1"" (%2)'"),
					НаборСсылок[0].Значение.Метаданные().Представление(), ВсегоСсылок);
			Иначе
				Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Места использования элементов (%1)'"), ВсегоСсылок);
			КонецЕсли;
		КонецЕсли;

	КонецЕсли;

	Возврат НСтр("ru = 'Места использования элементов'");

КонецФункции

#КонецОбласти

#Иначе
	ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли