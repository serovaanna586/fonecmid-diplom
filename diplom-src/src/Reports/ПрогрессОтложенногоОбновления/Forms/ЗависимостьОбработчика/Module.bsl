///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Область ОписаниеПеременных

&НаСервере
Перем ТаблицаПриоритетов, ОчередиОбработчиков, ПрогрессОбработки;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	ИмяОбработчика = Параметры.Значение;
	КешПриоритетов = Параметры.КешПриоритетов;

	ИсходныйОбработчик = ИмяОбработчика;

	Заголовок = НСтр("ru = 'Зависимости обработчика %1'");
	Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Заголовок, ИмяОбработчика);

	ПрогрессОбработки = ПолучитьИзВременногоХранилища(Параметры.Кеш).Скопировать(); // ТаблицаЗначений
	ПрогрессОбработки.Колонки.КоличествоОбъектов.Имя = "ОсталосьОбработать";
	ДанныеОбработчика = ПрогрессОбработки.Найти(ИмяОбработчика, "ОбработчикОбновления");

	ТаблицаПриоритетов = Неопределено;
	Если ЗначениеЗаполнено(КешПриоритетов) Тогда
		ТаблицаПриоритетов = ПолучитьИзВременногоХранилища(КешПриоритетов);
	КонецЕсли;
	Если ТаблицаПриоритетов = Неопределено Тогда
		ОписаниеОбработчиков = Обработки.ОписаниеОбработчиковОбновления.Создать();
		ОписаниеОбработчиков.ЗагрузитьОбработчики();

		ТаблицаПриоритетов = ОписаниеОбработчиков.ПриоритетыВыполнения.Выгрузить( , "Процедура1,Процедура2,Порядок");
		ПоместитьВоВременноеХранилище(ТаблицаПриоритетов, КешПриоритетов);
	КонецЕсли;

	Зависимости = РеквизитФормыВЗначение("ДеревоЗависимостей");

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ОчередьОтложеннойОбработки", ДанныеОбработчика.Очередь);
	Запрос.УстановитьПараметр("РежимВыполненияОтложенногоОбработчика",
		Перечисления.РежимыВыполненияОтложенныхОбработчиков.Параллельно);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОбработчикиОбновления.ИмяОбработчика КАК ИмяОбработчика,
	|	ОбработчикиОбновления.ОчередьОтложеннойОбработки КАК Очередь,
	|	ОбработчикиОбновления.Статус КАК Статус
	|ИЗ
	|	РегистрСведений.ОбработчикиОбновления КАК ОбработчикиОбновления
	|ГДЕ
	|	ОбработчикиОбновления.ОчередьОтложеннойОбработки < &ОчередьОтложеннойОбработки
	|	И ОбработчикиОбновления.РежимВыполненияОтложенногоОбработчика = &РежимВыполненияОтложенногоОбработчика";
	ОчередиОбработчиков = Запрос.Выполнить().Выгрузить();
	ОчередиОбработчиков.Индексы.Добавить("ИмяОбработчика");

	КонфликтыОбработчика = КонфликтыОбработчика(ИмяОбработчика);

	ОсновнойОбработчик = Зависимости.Строки.Добавить();
	ЗаполнитьЗначенияСвойств(ОсновнойОбработчик, ПараметрыОбработчика(ИмяОбработчика));
	ОсновнойОбработчик.ОбщийПрогресс = ПрогрессОбработки(ОсновнойОбработчик);

	УстановитьСтатусОбработчика(ОсновнойОбработчик, ДанныеОбработчика.Статус);

	ОчередьОбработчика = ДанныеОбработчика.Очередь;

	ДобавитьДочерниеОбработчики(ОсновнойОбработчик.Строки, ИмяОбработчика, КонфликтыОбработчика, ОчередьОбработчика);

	ЗначениеВРеквизитФормы(Зависимости, "ДеревоЗависимостей");

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПодключитьОбработчикОжидания("Подключаемый_РазвернутьСтроки", 0.1, Истина);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗарегистрированныеДанные(Команда)
	ТекущиеДанные = Элементы.ДеревоЗависимостей.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ПередаваемыеПараметры = Новый Структура;
	ПередаваемыеПараметры.Вставить("ИмяОбработчика", ТекущиеДанные.ОбработчикОбновления);
	ПередаваемыеПараметры.Вставить("ВсегоОбъектов", ТекущиеДанные.ВсегоОбъектов);
	ПередаваемыеПараметры.Вставить("ОсталосьОбработать", ТекущиеДанные.ОсталосьОбработать);
	ПередаваемыеПараметры.Вставить("Прогресс", ТекущиеДанные.ОбщийПрогресс);
	ПередаваемыеПараметры.Вставить("ОбработаноЗаПериод", ТекущиеДанные.ОбработаноЗаИнтервал);
	ОткрытьФорму("Отчет.ПрогрессОтложенногоОбновления.Форма.ЗарегистрированныеДанные", ПередаваемыеПараметры, ,
		ТекущиеДанные.ОбработчикОбновления);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ДобавитьДочерниеОбработчики(СтрокаДерева, ИмяОбработчика, КонфликтыОбработчика, ОчередьОбработчика)

	Для Каждого СтрокаКонфликт Из КонфликтыОбработчика Цикл
		Если СтрокаКонфликт.Порядок = "До" Тогда
			Продолжить;
		КонецЕсли;

		ВторойОбработчик = СтрокаКонфликт.Процедура2;
		ОчередьИСтатус = ОчередьИСтатусОбработчика(ВторойОбработчик);
		Если ОчередьИСтатус = Неопределено Или ОчередьИСтатус.Очередь >= ОчередьОбработчика Тогда
			// У данного обработчика очередь выше, он не держит выполнение.
			Продолжить;
		КонецЕсли;
		ПараметрыОбработчика = ПараметрыОбработчика(ВторойОбработчик);
		Если ПараметрыОбработчика = Неопределено Тогда
			// Обработчик не регистрировал ничего к обработке, выполнение не держит.
			Продолжить;
		КонецЕсли;
		СтрокаЗависимости = СтрокаДерева.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаЗависимости, ПараметрыОбработчика);
		СтрокаЗависимости.ОбщийПрогресс = ПрогрессОбработки(ПараметрыОбработчика);
		УстановитьСтатусОбработчика(СтрокаЗависимости, ОчередьИСтатус.Статус);

		КонфликтыВторогоОбработчика = КонфликтыОбработчика(ВторойОбработчик);

		ДобавитьДочерниеОбработчики(СтрокаЗависимости.Строки, ВторойОбработчик, КонфликтыВторогоОбработчика,
			ОчередьИСтатус.Очередь);
	КонецЦикла
	;

КонецПроцедуры

&НаСервере
Функция ПрогрессОбработки(ПараметрыОбработчика)

	Возврат Цел(((ПараметрыОбработчика.ВсегоОбъектов - ПараметрыОбработчика.ОсталосьОбработать)
		/ ПараметрыОбработчика.ВсегоОбъектов * 100) * 100) / 100;

КонецФункции

&НаСервере
Функция ПараметрыОбработчика(ИмяОбработчика)
	ДанныеОбработчика = ПрогрессОбработки.Найти(ИмяОбработчика, "ОбработчикОбновления");
	Возврат ДанныеОбработчика;
КонецФункции

&НаСервере
Функция КонфликтыОбработчика(ИмяОбработчика)

	ОтборСтрок = Новый Структура;
	ОтборСтрок.Вставить("Процедура1", ИмяОбработчика);
	КонфликтыОбработчика = ТаблицаПриоритетов.НайтиСтроки(ОтборСтрок);

	Возврат КонфликтыОбработчика;

КонецФункции

&НаСервере
Функция ОчередьИСтатусОбработчика(ИмяОбработчика)

	Результат = ОчередиОбработчиков.Найти(ИмяОбработчика, "ИмяОбработчика");
	Возврат Результат;

КонецФункции

&НаСервере
Процедура УстановитьСтатусОбработчика(Строка, Статус)

	Если Статус = Перечисления.СтатусыОбработчиковОбновления.Выполнен Тогда
		Строка.Картинка = БиблиотекаКартинок.ОформлениеКругЗеленый;
	ИначеЕсли Статус = Перечисления.СтатусыОбработчиковОбновления.Ошибка Тогда
		Строка.Картинка = БиблиотекаКартинок.ОформлениеКругКрасный;
	Иначе
		Строка.Картинка = БиблиотекаКартинок.ОформлениеКругПустой;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_РазвернутьСтроки()

	ВеткаОсновногоОбработчика = ДеревоЗависимостей.ПолучитьЭлементы()[0];
	Идентификатор = ВеткаОсновногоОбработчика.ПолучитьИдентификатор();
	Элементы.ДеревоЗависимостей.Развернуть(Идентификатор, Ложь);

КонецПроцедуры

#КонецОбласти