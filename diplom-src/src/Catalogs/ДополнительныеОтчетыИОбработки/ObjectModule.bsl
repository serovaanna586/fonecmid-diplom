///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

Перем ЭтоГлобальнаяОбработка;

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;

	ПроверкаЭлемента = Истина;
	Если ДополнительныеСвойства.Свойство("ПроверкаСписка") Тогда
		ПроверкаЭлемента = Ложь;
	КонецЕсли;

	Если Не ДополнительныеОтчетыИОбработки.ПроверитьГлобальнаяОбработка(Вид) Тогда
		Если Не ИспользоватьДляФормыОбъекта И Не ИспользоватьДляФормыСписка И Публикация
			<> Перечисления.ВариантыПубликацииДополнительныхОтчетовИОбработок.Отключена Тогда
			ОбщегоНазначения.СообщитьПользователю(
				НСтр("ru = 'Отключите публикацию или выберите для использования как минимум одну из форм'"), , ,
				"Объект.ИспользоватьДляФормыОбъекта", Отказ);
		КонецЕсли;
	КонецЕсли;
	
	// Если отчет публикуется, то необходим контроль уникальности имени объекта, 
	//     под которым дополнительный отчет регистрируется в системе.
	Если Публикация = Перечисления.ВариантыПубликацииДополнительныхОтчетовИОбработок.Используется Тогда
		
		// Проверка имени
		ТекстЗапроса =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	1
		|ИЗ
		|	Справочник.ДополнительныеОтчетыИОбработки КАК ДопОтчеты
		|ГДЕ
		|	ДопОтчеты.ИмяОбъекта = &ИмяОбъекта
		|	И &УсловиеДопОтчет
		|	И ДопОтчеты.Публикация = ЗНАЧЕНИЕ(Перечисление.ВариантыПубликацииДополнительныхОтчетовИОбработок.Используется)
		|	И ДопОтчеты.ПометкаУдаления = ЛОЖЬ
		|	И ДопОтчеты.Ссылка <> &Ссылка";

		ВидыДопОтчетов = Новый Массив;
		ВидыДопОтчетов.Добавить(Перечисления.ВидыДополнительныхОтчетовИОбработок.ДополнительныйОтчет);
		ВидыДопОтчетов.Добавить(Перечисления.ВидыДополнительныхОтчетовИОбработок.Отчет);

		Если ВидыДопОтчетов.Найти(Вид) <> Неопределено Тогда
			ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&УсловиеДопОтчет", "ДопОтчеты.Вид В (&ВидыДопОтчетов)");
		Иначе
			ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&УсловиеДопОтчет", "НЕ ДопОтчеты.Вид В (&ВидыДопОтчетов)");
		КонецЕсли;

		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("ИмяОбъекта", ИмяОбъекта);
		Запрос.УстановитьПараметр("ВидыДопОтчетов", ВидыДопОтчетов);
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.Текст = ТекстЗапроса;

		УстановитьПривилегированныйРежим(Истина);
		Конфликтующие = Запрос.Выполнить().Выгрузить();
		УстановитьПривилегированныйРежим(Ложь);

		Если Конфликтующие.Количество() > 0 Тогда
			Отказ = Истина;
			Если ПроверкаЭлемента Тогда
				ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Имя ""%1"", используемое данным отчетом (обработкой), уже занято другим опубликованным дополнительным отчетом (обработкой). 
						 |
						 |Для продолжения измените вид Публикации с ""%2"" на ""%3"" или ""%4"".'"), ИмяОбъекта, Строка(
					Перечисления.ВариантыПубликацииДополнительныхОтчетовИОбработок.Используется), Строка(
					Перечисления.ВариантыПубликацииДополнительныхОтчетовИОбработок.РежимОтладки), Строка(
					Перечисления.ВариантыПубликацииДополнительныхОтчетовИОбработок.Отключена));
			Иначе
				ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр(
					"ru = 'Имя ""%1"", используемое отчетом (обработкой) ""%2"", уже занято другим опубликованным дополнительным отчетом (обработкой).'"),
					ИмяОбъекта, Строка(Ссылка));
			КонецЕсли;
			ОбщегоНазначения.СообщитьПользователю(ТекстОшибки, , "Объект.Публикация");
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ)

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;

	ИнтеграцияПодсистемБСП.ПередЗаписьюДополнительнойОбработки(ЭтотОбъект, Отказ);

	Если ЭтоНовый() И Не ДополнительныеОтчетыИОбработки.ПравоДобавления(ЭтотОбъект) Тогда
		ВызватьИсключение НСтр("ru = 'Недостаточно прав для добавления дополнительных отчетов или обработок.'");
	КонецЕсли;
	
	// Предварительные проверки
	Если Не ЭтоНовый() И Вид <> ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "Вид") Тогда
		ОбщегоНазначения.СообщитьПользователю(
			НСтр("ru = 'Невозможно сменить вид существующего дополнительного отчета или обработки.'"), , , , Отказ);
		Возврат;
	КонецЕсли;
	
	// Связь реквизитов с пометкой удаления.
	Если ПометкаУдаления Тогда
		Публикация = Перечисления.ВариантыПубликацииДополнительныхОтчетовИОбработок.Отключена;
	КонецЕсли;
	
	// Кэш стандартных проверок
	ДополнительныеСвойства.Вставить("ПубликацияИспользуется", Публикация
		= Перечисления.ВариантыПубликацииДополнительныхОтчетовИОбработок.Используется);

	Если ЭтоГлобальнаяОбработка() Тогда
		Если ПравоНастройкиРасписания() Тогда
			ПередЗаписьюГлобальнойОбработки(Отказ);
		КонецЕсли;
		Назначение.Очистить();
	Иначе
		ПередЗаписьюНазначаемойОбработки(Отказ);
		Разделы.Очистить();
	КонецЕсли;

КонецПроцедуры

Процедура ПриЗаписи(Отказ)

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;

	БыстрыйДоступ = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ДополнительныеСвойства, "БыстрыйДоступ");
	Если ТипЗнч(БыстрыйДоступ) = Тип("ТаблицаЗначений") Тогда
		ЗначенияИзмерений = Новый Структура("ДополнительныйОтчетИлиОбработка", Ссылка);
		ЗначенияРесурсов = Новый Структура("Доступно", Истина);
		РегистрыСведений.ПользовательскиеНастройкиДоступаКОбработкам.ЗаписатьПакетНастроек(БыстрыйДоступ,
			ЗначенияИзмерений, ЗначенияРесурсов, Истина);
	КонецЕсли;

	Если ЭтоГлобальнаяОбработка() Тогда
		Если ПравоНастройкиРасписания() Тогда
			ПриЗаписиГлобальнойОбработки(Отказ);
		КонецЕсли;
	Иначе
		ПриЗаписиНазначаемойОбработки(Отказ);
	КонецЕсли;

	Если Вид = Перечисления.ВидыДополнительныхОтчетовИОбработок.ДополнительныйОтчет Или Вид
		= Перечисления.ВидыДополнительныхОтчетовИОбработок.Отчет Тогда
		ПриЗаписиОтчета(Отказ);
	КонецЕсли;

КонецПроцедуры

Процедура ПередУдалением(Отказ)

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;

	ИнтеграцияПодсистемБСП.ПередУдалениемДополнительнойОбработки(ЭтотОбъект, Отказ);

	Если ДополнительныеОтчетыИОбработки.ПроверитьГлобальнаяОбработка(Вид) Тогда

		УстановитьПривилегированныйРежим(Истина);
		// Удаление всех заданий.
		Для Каждого Команда Из Команды Цикл
			Если ЗначениеЗаполнено(Команда.РегламентноеЗаданиеGUID) Тогда
				РегламентныеЗаданияСервер.УдалитьЗадание(Команда.РегламентноеЗаданиеGUID);
			КонецЕсли;
		КонецЦикла;
		УстановитьПривилегированныйРежим(Ложь);

	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ЭтоГлобальнаяОбработка()

	Если ЭтоГлобальнаяОбработка = Неопределено Тогда
		ЭтоГлобальнаяОбработка = ДополнительныеОтчетыИОбработки.ПроверитьГлобальнаяОбработка(Вид);
	КонецЕсли;

	Возврат ЭтоГлобальнаяОбработка;

КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Глобальные обработки

Процедура ПередЗаписьюГлобальнойОбработки(Отказ)
	Если Отказ Или Не ДополнительныеСвойства.Свойство("АктуальныеКоманды") Тогда
		Возврат;
	КонецЕсли;

	ТаблицаКоманд = ДополнительныеСвойства.АктуальныеКоманды;// СправочникТабличнаяЧасть.ДополнительныеОтчетыИОбработки.Команды

	ЗаданияДляОбновления = Новый Соответствие;

	ПубликацияВключена = (Публикация <> Перечисления.ВариантыПубликацииДополнительныхОтчетовИОбработок.Отключена);
	
	// Регламентные задания необходимо изменять в привилегированном режиме.
	УстановитьПривилегированныйРежим(Истина);
	
	// Очистка заданий по командам, которые были удалены из таблицы.
	Если Не ЭтоНовый() Тогда
		Для Каждого СтараяКоманда Из Ссылка.Команды Цикл
			Если ЗначениеЗаполнено(СтараяКоманда.РегламентноеЗаданиеGUID) И ТаблицаКоманд.Найти(
				СтараяКоманда.РегламентноеЗаданиеGUID, "РегламентноеЗаданиеGUID") = Неопределено Тогда
				РегламентныеЗаданияСервер.УдалитьЗадание(СтараяКоманда.РегламентноеЗаданиеGUID);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	// Актуализация набора регламентных заданий для записи их идентификаторов в табличную часть.
	Для Каждого АктуальнаяКоманда Из ТаблицаКоманд Цикл
		Команда = Команды.Найти(АктуальнаяКоманда.Идентификатор, "Идентификатор");

		Если ПубликацияВключена И АктуальнаяКоманда.РегламентноеЗаданиеРасписание.Количество() > 0 Тогда
			Расписание    = АктуальнаяКоманда.РегламентноеЗаданиеРасписание[0].Значение;
			Использование = АктуальнаяКоманда.РегламентноеЗаданиеИспользование
				И ДополнительныеОтчетыИОбработкиКлиентСервер.РасписаниеЗадано(Расписание);
		Иначе
			Расписание = Неопределено;
			Использование = Ложь;
		КонецЕсли;

		Задание = РегламентныеЗаданияСервер.Задание(АктуальнаяКоманда.РегламентноеЗаданиеGUID);
		Если Задание = Неопределено Тогда // Не найдено
			Если Использование Тогда
				// Создать и зарегистрировать.
				ПараметрыЗадания = Новый Структура;
				ПараметрыЗадания.Вставить("Метаданные", Метаданные.РегламентныеЗадания.ЗапускДополнительныхОбработок);
				ПараметрыЗадания.Вставить("Использование", Ложь);
				Задание = РегламентныеЗаданияСервер.ДобавитьЗадание(ПараметрыЗадания);
				ЗаданияДляОбновления.Вставить(АктуальнаяКоманда, Задание);
				Команда.РегламентноеЗаданиеGUID = РегламентныеЗаданияСервер.УникальныйИдентификатор(Задание);
			Иначе
				// Действие не требуется
			КонецЕсли;
		Иначе // Найдено
			Если Использование Тогда
				// Зарегистрировать.
				ЗаданияДляОбновления.Вставить(АктуальнаяКоманда, Задание);
			Иначе
				// Удалить.
				РегламентныеЗаданияСервер.УдалитьЗадание(АктуальнаяКоманда.РегламентноеЗаданиеGUID);
				Команда.РегламентноеЗаданиеGUID = ОбщегоНазначенияКлиентСервер.ПустойУникальныйИдентификатор();
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	ДополнительныеСвойства.Вставить("ЗаданияДляОбновления", ЗаданияДляОбновления);

КонецПроцедуры

Процедура ПриЗаписиГлобальнойОбработки(Отказ)
	Если Отказ Или Не ДополнительныеСвойства.Свойство("АктуальныеКоманды") Тогда
		Возврат;
	КонецЕсли;

	ПубликацияВключена = (Публикация <> Перечисления.ВариантыПубликацииДополнительныхОтчетовИОбработок.Отключена);
	
	// Регламентные задания необходимо изменять в привилегированном режиме.
	УстановитьПривилегированныйРежим(Истина);

	Для Каждого КлючИЗначение Из ДополнительныеСвойства.ЗаданияДляОбновления Цикл
		Команда = КлючИЗначение.Ключ;// СправочникТабличнаяЧастьСтрока.ДополнительныеОтчетыИОбработки.Команды
		Задание = КлючИЗначение.Значение;

		Изменения = Новый Структура;
		Изменения.Вставить("Использование", Ложь);
		Изменения.Вставить("Расписание", Неопределено);
		Изменения.Вставить("Наименование", Лев(ПредставлениеЗадания(Команда), 120));

		Если ПубликацияВключена И Команда.РегламентноеЗаданиеРасписание.Количество() > 0 Тогда
			Изменения.Расписание    = Команда.РегламентноеЗаданиеРасписание[0].Значение;
			Изменения.Использование = Команда.РегламентноеЗаданиеИспользование
				И ДополнительныеОтчетыИОбработкиКлиентСервер.РасписаниеЗадано(Изменения.Расписание);
		КонецЕсли;

		ПараметрыПроцедуры = Новый Массив;
		ПараметрыПроцедуры.Добавить(Ссылка);
		ПараметрыПроцедуры.Добавить(Команда.Идентификатор);

		Изменения.Вставить("Параметры", ПараметрыПроцедуры);

		ИнтеграцияПодсистемБСП.ПередОбновлениемЗадания(ЭтотОбъект, Команда, Задание, Изменения);
		Если Изменения <> Неопределено Тогда
			РегламентныеЗаданияСервер.ИзменитьЗадание(Задание, Изменения);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Работа с регламентными заданиями.

Функция ПравоНастройкиРасписания()
	// Проверяет наличие права настройки расписания дополнительных отчетов и обработок.
	Возврат ПравоДоступа("Изменение", Метаданные.Справочники.ДополнительныеОтчетыИОбработки);
КонецФункции

Функция ПредставлениеЗадания(Команда)
	// '[ВидОбъекта]: [НаименованиеОбъекта] / Команда: [ПредставлениеКоманды]'
	Возврат (СокрЛП(Вид) + ": " + СокрЛП(Наименование) + " / " + НСтр("ru = 'Команда'") + ": " + СокрЛП(
		Команда.Представление));
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Назначаемые обработки

Процедура ПередЗаписьюНазначаемойОбработки(Отказ)
	ТаблицаНазначение = Назначение.Выгрузить();
	ТаблицаНазначение.Свернуть("ОбъектНазначения");
	Назначение.Загрузить(ТаблицаНазначение);

	СсылкиОбъектовМетаданных = ТаблицаНазначение.ВыгрузитьКолонку("ОбъектНазначения");

	Если Не ЭтоНовый() Тогда
		Для Каждого СтрокаТаблицы Из Ссылка.Назначение Цикл
			Если СсылкиОбъектовМетаданных.Найти(СтрокаТаблицы.ОбъектНазначения) = Неопределено Тогда
				СсылкиОбъектовМетаданных.Добавить(СтрокаТаблицы.ОбъектНазначения);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	ДополнительныеСвойства.Вставить("СсылкиОбъектовМетаданных", СсылкиОбъектовМетаданных);
КонецПроцедуры

Процедура ПриЗаписиНазначаемойОбработки(Отказ)
	Если Отказ Или Не ДополнительныеСвойства.Свойство("СсылкиОбъектовМетаданных") Тогда
		Возврат;
	КонецЕсли;

	РегистрыСведений.НазначениеДополнительныхОбработок.ОбновитьДанныеПоСсылкамОбъектовМетаданных(
		ДополнительныеСвойства.СсылкиОбъектовМетаданных);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Глобальные отчеты

Процедура ПриЗаписиОтчета(Отказ)

	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ВариантыОтчетов") Тогда

		Попытка
			Если ЭтоНовый() Тогда
				ВнешнийОбъект = ВнешниеОтчеты.Создать(ИмяОбъекта);
			Иначе
				ВнешнийОбъект = ДополнительныеОтчетыИОбработки.ОбъектВнешнейОбработки(Ссылка);
			КонецЕсли;
		Исключение
			ТекстОшибки = НСтр("ru = 'Ошибка подключения:'") + Символы.ПС + ПодробноеПредставлениеОшибки(
				ИнформацияОбОшибке());
			ДополнительныеОтчетыИОбработки.ЗаписатьОшибку(Ссылка, ТекстОшибки);
			ДополнительныеСвойства.Вставить("ОшибкаПодключения", ТекстОшибки);
			ВнешнийОбъект = Неопределено;
		КонецПопытки;

		ДополнительныеСвойства.Вставить("Глобальный", ЭтоГлобальнаяОбработка());

		МодульВариантыОтчетов = ОбщегоНазначения.ОбщийМодуль("ВариантыОтчетов");
		МодульВариантыОтчетов.ПриЗаписиДополнительногоОтчета(ЭтотОбъект, Отказ, ВнешнийОбъект);

	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Иначе
	ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли