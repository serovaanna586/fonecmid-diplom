///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Область ПрограммныйИнтерфейс

// Обновляет список команд в зависимости от текущего контекста.
//
// Параметры:
//   Форма - ФормаКлиентскогоПриложения - форма, для которой требуется обновление команд.
//   Источник - ДанныеФормыСтруктура
//            - ТаблицаФормы - контекст для проверки условий (Форма.Объект или Форма.Элементы.Список).
//
Процедура ОбновитьКоманды(Форма, Источник) Экспорт

	ПараметрыКлиента = ПараметрыПодключаемыхКоманд(Форма);
	Если ТипЗнч(ПараметрыКлиента) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;

	Если ПараметрыКлиента.ВводНаОснованииЧерезПодключаемыеКоманды Тогда
		ПодменюСоздатьНаОсновании = Форма.Элементы.Найти("ФормаСоздатьНаОсновании");
		Если ПодменюСоздатьНаОсновании <> Неопределено И ПодменюСоздатьНаОсновании.Видимость Тогда
			ПодменюСоздатьНаОсновании.Видимость = Ложь;
		КонецЕсли;
	КонецЕсли;

	Если ТипЗнч(Источник) = Тип("ТаблицаФормы") Тогда
		ДоступностьКоманд = (Источник.ТекущаяСтрока <> Неопределено);
	Иначе
		ДоступностьКоманд = Истина;
	КонецЕсли;
	Если ДоступностьКоманд <> ПараметрыКлиента.ДоступностьКоманд Тогда
		ПараметрыКлиента.ДоступностьКоманд = ДоступностьКоманд;
		Для Каждого ИмяКнопкиИлиПодменю Из ПараметрыКлиента.КорневыеПодменюИКоманды Цикл
			КнопкаИлиПодменю = Форма.Элементы[ИмяКнопкиИлиПодменю];
			КнопкаИлиПодменю.Доступность = ДоступностьКоманд;
			Если ТипЗнч(КнопкаИлиПодменю) = Тип("ГруппаФормы") И КнопкаИлиПодменю.Вид = ВидГруппыФормы.Подменю Тогда
				СкрытьПоказатьВсеПодчиненныеКнопки(КнопкаИлиПодменю, ДоступностьКоманд);
				КомандаЗаглушка = Форма.Элементы.Найти(ИмяКнопкиИлиПодменю + "Заглушка");
				Если КомандаЗаглушка <> Неопределено Тогда
					КомандаЗаглушка.Видимость = Не ДоступностьКоманд;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	Для Каждого ОписаниеКоманды Из ПараметрыКлиента.КомандыСПометкой Цикл
		Если ЗначениеЗаполнено(ОписаниеКоманды.ЗначениеПометки) Тогда
			Если ТипЗнч(Источник) = Тип("ТаблицаФормы") Тогда
				ВыражениеВычисленияЗначениеПометки = СтрЗаменить(ОписаниеКоманды.ЗначениеПометки, "%ИСТОЧНИК%",
					Источник.Имя);
			Иначе
				ВыражениеВычисленияЗначениеПометки = ОписаниеКоманды.ЗначениеПометки;
			КонецЕсли;

			Форма.Элементы[ОписаниеКоманды.ИмяВФорме].Пометка = Вычислить(ВыражениеВычисленияЗначениеПометки); // АПК:488 Исполняемый код безопасен.
		КонецЕсли;
	КонецЦикла;

	Если Не ДоступностьКоманд Или Не ПараметрыКлиента.ЕстьУсловияВидимости Тогда
		Возврат;
	КонецЕсли;

	ПроверятьОписаниеТипов = ТипЗнч(Источник) = Тип("ТаблицаФормы");
	ВыбранныеОбъекты = ВыбранныеОбъекты(Источник);

	Для Каждого КраткиеСведенияОПодменю Из ПараметрыКлиента.ПодменюСУсловиямиВидимости Цикл
		ЕстьВидимыеКоманды = Ложь;
		Подменю = Форма.Элементы.Найти(КраткиеСведенияОПодменю.Имя);
		ИзменятьВидимость = (ТипЗнч(Подменю) = Тип("ГруппаФормы") И Подменю.Вид = ВидГруппыФормы.Подменю);
		СкрыватьКомандуРазблокировкиОбъекта = СкрыватьКомандуРазблокировкиОбъекта(Форма);

		Для Каждого Команда Из КраткиеСведенияОПодменю.КомандыСУсловиямиВидимости Цикл
			КомандаЭлемент = Форма.Элементы[Команда.ИмяВФорме];
			Видимость = ВыбранныеОбъекты.Количество() > 0;
			Для Каждого Объект Из ВыбранныеОбъекты Цикл
				Если ПроверятьОписаниеТипов И ТипЗнч(Команда.ТипПараметра) = Тип("ОписаниеТипов")
					И Не Команда.ТипПараметра.СодержитТип(ТипЗнч(Объект.Ссылка)) Тогда
					Видимость = Ложь;
					Прервать;
				КонецЕсли;

				Если ЗначениеЗаполнено(Команда.УсловияВидимостиПоТипамОбъектов) Тогда
					УсловияВидимости = Команда.УсловияВидимостиПоТипамОбъектов[ТипЗнч(Объект.Ссылка)];
				Иначе
					УсловияВидимости = Команда.УсловияВидимости;
				КонецЕсли;

				Если ЗначениеЗаполнено(УсловияВидимости) И Не УсловияВыполняются(УсловияВидимости, Объект) Тогда
					Видимость = Ложь;
					Прервать;
				КонецЕсли;
			КонецЦикла;

			Если СкрыватьКомандуРазблокировкиОбъекта И ЭтоКомандаРазблокировкиОбъекта(Команда.УсловияВидимости) Тогда
				КомандаЭлемент.Видимость = Ложь;
			ИначеЕсли ИзменятьВидимость Тогда
				КомандаЭлемент.Видимость = Видимость;
			Иначе
				КомандаЭлемент.Доступность = Видимость;
			КонецЕсли;
			ЕстьВидимыеКоманды = ЕстьВидимыеКоманды Или Видимость;
		КонецЦикла;

		Если Не КраткиеСведенияОПодменю.ЕстьКомандыБезУсловийВидимости Тогда
			КомандаЗаглушка = Форма.Элементы.Найти(КраткиеСведенияОПодменю.Имя + "Заглушка");
			Если КомандаЗаглушка <> Неопределено Тогда
				КомандаЗаглушка.Видимость = Не ЕстьВидимыеКоманды;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Свойства второго параметра обработчика подключаемой команды, общие для клиентских и серверных обработчиков.
//
// Возвращаемое значение:
//  Структура:
//   * ОписаниеКоманды - Структура - состав свойств совпадает с колонками таблицы значений параметра Команды
///                                  процедуры ПодключаемыеКомандыПереопределяемый.ПриОпределенииКомандПодключенныхКОбъекту.
//                                   Ключевые свойства:
//      ** Идентификатор - Строка - идентификатор команды.
//      ** Представление - Строка - представление команды в форме.
//      ** Имя - Строка - имя команды в форме.
//   * Форма - ФормаКлиентскогоПриложения - форма, из которой вызвана команда.
//   * ЭтоФормаОбъекта - Булево - Истина, если команда вызвана из формы объекта.
//   * Источник - ТаблицаФормы
//              - ДанныеФормыСтруктура - объект или список формы с полем "Ссылка".
//
Функция ПараметрыВыполненияКоманды() Экспорт
	Результат = Новый Структура;
	Результат.Вставить("ОписаниеКоманды", Неопределено);
	Результат.Вставить("Форма", Неопределено);
	Результат.Вставить("Источник", Неопределено);
	Результат.Вставить("ЭтоФормаОбъекта", Ложь);
	Возврат Результат;
КонецФункции

Функция УсловияВыполняются(Условия, ЗначенияРеквизитов)
	Для Каждого Условие Из Условия Цикл
		ИмяРеквизита = Условие.Реквизит;
		Если Не ЗначенияРеквизитов.Свойство(ИмяРеквизита) Тогда
			Продолжить;
		КонецЕсли;
		УсловиеВыполняется = Истина;
		Если Условие.ВидСравнения = ВидСравнения.Равно Или Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] = Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.Больше Или Условие.ВидСравнения
			= ВидСравненияКомпоновкиДанных.Больше Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] > Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.БольшеИлиРавно Или Условие.ВидСравнения
			= ВидСравненияКомпоновкиДанных.БольшеИлиРавно Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] >= Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.Меньше Или Условие.ВидСравнения
			= ВидСравненияКомпоновкиДанных.Меньше Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] < Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.МеньшеИлиРавно Или Условие.ВидСравнения
			= ВидСравненияКомпоновкиДанных.МеньшеИлиРавно Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] <= Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.НеРавно Или Условие.ВидСравнения
			= ВидСравненияКомпоновкиДанных.НеРавно Тогда
			УсловиеВыполняется = ЗначенияРеквизитов[ИмяРеквизита] <> Условие.Значение;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.ВСписке Или Условие.ВидСравнения
			= ВидСравненияКомпоновкиДанных.ВСписке Тогда
			Если ТипЗнч(Условие.Значение) = Тип("СписокЗначений") Тогда
				УсловиеВыполняется = Условие.Значение.НайтиПоЗначению(ЗначенияРеквизитов[ИмяРеквизита]) <> Неопределено;
			Иначе // Массив
				УсловиеВыполняется = Условие.Значение.Найти(ЗначенияРеквизитов[ИмяРеквизита]) <> Неопределено;
			КонецЕсли;
		ИначеЕсли Условие.ВидСравнения = ВидСравнения.НеВСписке Или Условие.ВидСравнения
			= ВидСравненияКомпоновкиДанных.НеВСписке Тогда
			Если ТипЗнч(Условие.Значение) = Тип("СписокЗначений") Тогда
				УсловиеВыполняется = Условие.Значение.НайтиПоЗначению(ЗначенияРеквизитов[ИмяРеквизита]) = Неопределено;
			Иначе // Массив
				УсловиеВыполняется = Условие.Значение.Найти(ЗначенияРеквизитов[ИмяРеквизита]) = Неопределено;
			КонецЕсли;
		ИначеЕсли Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.Заполнено Тогда
			УсловиеВыполняется = ЗначениеЗаполнено(ЗначенияРеквизитов[ИмяРеквизита]);
		ИначеЕсли Условие.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено Тогда
			УсловиеВыполняется = Не ЗначениеЗаполнено(ЗначенияРеквизитов[ИмяРеквизита]);
		КонецЕсли;
		Если Не УсловиеВыполняется Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	Возврат Истина;
КонецФункции

Процедура СкрытьПоказатьВсеПодчиненныеКнопки(ГруппаФормы, Видимость)
	Для Каждого ПодчиненныйЭлемент Из ГруппаФормы.ПодчиненныеЭлементы Цикл
		Если ТипЗнч(ПодчиненныйЭлемент) = Тип("ГруппаФормы") Тогда
			СкрытьПоказатьВсеПодчиненныеКнопки(ПодчиненныйЭлемент, Видимость);
		ИначеЕсли ТипЗнч(ПодчиненныйЭлемент) = Тип("КнопкаФормы") Тогда
			ПодчиненныйЭлемент.Видимость = Видимость;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

// Возвращаемое значение:
//  Структура:
//   * ЕстьУсловияВидимости - Булево
//   * ПодменюСУсловиямиВидимости - Массив из Структура:
//    ** Имя - Строка
//    ** КомандыСУсловиямиВидимости - Массив
//    ** ЕстьКомандыБезУсловийВидимости - Булево
//   * КомандыСПометкой - Массив
//   * КорневыеПодменюИКоманды - Массив
//   * ДоступностьКоманд - Булево
//   * АдресТаблицыКоманд - Строка
//   * ВводНаОснованииЧерезПодключаемыеКоманды - Булево
//
Функция ПараметрыПодключаемыхКоманд(Форма)

	Структура = Новый Структура("ПараметрыПодключаемыхКоманд", Null);
	ЗаполнитьЗначенияСвойств(Структура, Форма);
	Возврат Структура.ПараметрыПодключаемыхКоманд;

КонецФункции

// Возвращаемое значение:
//  Массив из ДанныеФормыСтруктура, ДанныеФормыЭлементКоллекции:
//   * Ссылка - ЛюбаяСсылка
// 
Функция ВыбранныеОбъекты(Источник)

	ВыбранныеОбъекты = Новый Массив; // Массив из ДанныеФормыСтруктура, ДанныеФормыЭлементКоллекции

	Если ТипЗнч(Источник) = Тип("ТаблицаФормы") Тогда
		ВыделенныеСтроки = Источник.ВыделенныеСтроки;
		Для Каждого ВыделеннаяСтрока Из ВыделенныеСтроки Цикл
			Если ТипЗнч(ВыделеннаяСтрока) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
				Продолжить;
			КонецЕсли;
			ТекущаяСтрока = Источник.ДанныеСтроки(ВыделеннаяСтрока);
			Если ТекущаяСтрока <> Неопределено Тогда
				ВыбранныеОбъекты.Добавить(ТекущаяСтрока);
			КонецЕсли;
		КонецЦикла;
	Иначе
		ВыбранныеОбъекты.Добавить(Источник);
	КонецЕсли;

	Возврат ВыбранныеОбъекты;

КонецФункции
Функция ЭтоКомандаРазблокировкиОбъекта(Условия)
	Для Каждого Условие Из Условия Цикл
		ИмяРеквизита = Условие.Реквизит;
		Если ИмяРеквизита = "ОбновлениеВерсииИБ_ОбъектЗаблокирован" Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;

	Возврат Ложь;
КонецФункции

Функция СкрыватьКомандуРазблокировкиОбъекта(Форма)
	ПризнакБлокировки = Форма.Команды.Найти("ОбновлениеВерсииИБ_ОбъектЗаблокирован");
	Если ПризнакБлокировки = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;

	Возврат Ложь;
КонецФункции

#КонецОбласти