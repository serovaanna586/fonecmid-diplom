///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

// Вызывается в обработчике одноименного события формы отчета после выполнения кода формы.
//
// Параметры:
//   Форма - ФормаКлиентскогоПриложения - форма отчета.
//   Отказ - Булево - передается из параметров стандартного обработчика ПриСозданииНаСервере "как есть".
//   СтандартнаяОбработка - Булево - передается из параметров стандартного обработчика ПриСозданииНаСервере "как есть".
//
Процедура ПриСозданииНаСервере(Форма, Отказ, СтандартнаяОбработка) Экспорт
	// Добавление команд на командную панель.
	Если Пользователи.ЭтоПолноправныйПользователь() Тогда

		МодульОтчетыСервер = ОбщегоНазначения.ОбщийМодуль("ОтчетыСервер");

		Команда = Форма.Команды.Добавить("ПрогрессОтложенногоОбновленияЗависимости");
		Команда.Действие  = "Подключаемый_Команда";
		Команда.Заголовок = НСтр("ru = 'Зависимости обработчика'");
		Команда.Подсказка = НСтр("ru = 'Посмотреть зависимости выбранного обработчика'");
		Команда.Картинка  = БиблиотекаКартинок.ЗатенитьФлажки;
		МодульОтчетыСервер.ВывестиКоманду(Форма, Команда, "Настройки");

		Команда = Форма.Команды.Добавить("ПрогрессОтложенногоОбновленияОшибки");
		Команда.Действие  = "Подключаемый_Команда";
		Команда.Заголовок = НСтр("ru = 'Посмотреть ошибки'");
		Команда.Подсказка = НСтр("ru = 'Посмотреть ошибки в журнале регистрации'");
		Команда.Картинка  = БиблиотекаКартинок.ЖурналРегистрации;
		МодульОтчетыСервер.ВывестиКоманду(Форма, Команда, "Настройки");
	КонецЕсли;

КонецПроцедуры

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	НастройкиКД = КомпоновщикНастроек.ПолучитьНастройки();

	ПрогрессОбработки = НастройкиКД.ПараметрыДанных.Элементы.Найти("ПрогрессОбработки");
	Период = Неопределено;
	Если ПрогрессОбработки.Использование Тогда
		Период = ПрогрессОбработки.Значение;
	КонецЕсли;
	Кеш = НастройкиКД.ПараметрыДанных.Элементы.Найти("Кеш");

	ТекущееЗначениеКеша = НастройкиКД.ПараметрыДанных.Элементы.Найти("Кеш").Значение;
	ТаблицаРезультата = Неопределено;
	Если ЗначениеЗаполнено(ТекущееЗначениеКеша) Тогда
		ТаблицаРезультата = ПолучитьИзВременногоХранилища(ТекущееЗначениеКеша);
	КонецЕсли;
	КешироватьРезультат = НастройкиКД.ПараметрыДанных.Элементы.Найти("КешироватьРезультат").Значение
		И НастройкиКД.ПараметрыДанных.Элементы.Найти("КешироватьРезультат").Использование;

	Если Не КешироватьРезультат Или ТаблицаРезультата = Неопределено Тогда
		ТаблицаРезультата = ЗарегистрированныеОбъекты(Период);
	КонецЕсли;

	ПоместитьВоВременноеХранилище(ТаблицаРезультата, Кеш.Значение);

	ВнешниеНаборыДанных = Новый Структура("ТаблицаРезультата", ТаблицаРезультата);

	КомпоновщикМакетаКД = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКД = КомпоновщикМакетаКД.Выполнить(СхемаКомпоновкиДанных, НастройкиКД, ДанныеРасшифровки);

	ПроцессорКД = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКД.Инициализировать(МакетКД, ВнешниеНаборыДанных, ДанныеРасшифровки, Истина);

	ПроцессорВыводаРезультатаКД = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВыводаРезультатаКД.УстановитьДокумент(ДокументРезультат);
	ПроцессорВыводаРезультатаКД.Вывести(ПроцессорКД);

	ДокументРезультат.ПоказатьУровеньГруппировокСтрок(2);

	КомпоновщикНастроек.ПользовательскиеНастройки.ДополнительныеСвойства.Вставить("ОтчетПустой",
		ТаблицаРезультата.Количество() = 0);

КонецПроцедуры

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

	Настройки.СкрытьКомандыРассылки                              = Истина;
	Настройки.ФормироватьСразу                                   = Ложь;

	Настройки.События.ПриСозданииНаСервере = Истина;
	Настройки.События.ПриЗагрузкеВариантаНаСервере = Истина;
	Настройки.События.ПриЗагрузкеПользовательскихНастроекНаСервере = Истина;
	Настройки.События.ПриОпределенииПараметровВыбора = Истина;

КонецПроцедуры

Процедура ПриЗагрузкеВариантаНаСервере(Форма, НовыеНастройкиКД) Экспорт
	ПараметрКД = Форма.Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("Кеш");
	ПараметрКД.Значение = ПоместитьВоВременноеХранилище(Неопределено, Форма.УникальныйИдентификатор);

	ПараметрКД = Форма.Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("КешПриоритетов");
	ПараметрКД.Значение = ПоместитьВоВременноеХранилище(Неопределено, Форма.УникальныйИдентификатор);
КонецПроцедуры

Процедура ПриЗагрузкеПользовательскихНастроекНаСервере(Форма, НовыеПользовательскиеНастройкиКД) Экспорт

	Если Форма.Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.ДополнительныеСвойства.Свойство(
		"КэшЗначенийОтборов") Тогда
		Форма.Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.ДополнительныеСвойства.КэшЗначенийОтборов.Очистить();
	КонецЕсли;

КонецПроцедуры

// Вызывается в форме отчета перед выводом настройки.
//   Подробнее - см. ОтчетыПереопределяемый.ПриОпределенииПараметровВыбора.
//
Процедура ПриОпределенииПараметровВыбора(Форма, СвойстваНастройки) Экспорт

	Если СвойстваНастройки.ПолеКД = Новый ПолеКомпоновкиДанных("ПараметрыДанных.ПрогрессОбработки") Тогда
		СвойстваНастройки.ЗначенияДляВыбора.Добавить(Строка(НачалоДня(ТекущаяДатаСеанса())), НСтр(
			"ru = 'За весь период'"));
		ДоступныеПериоды(СвойстваНастройки.ЗначенияДляВыбора);
	ИначеЕсли СвойстваНастройки.ПолеКД = Новый ПолеКомпоновкиДанных("ПараметрыДанных.КешироватьРезультат") Тогда
		СвойстваНастройки.ВыводитьТолькоФлажок = Истина;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ДоступныеПериоды(ДоступныеПериоды)

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПрогрессОбновления.ИнтервалЧас КАК ИнтервалЧас
	|ИЗ
	|	РегистрСведений.ПрогрессОбновления КАК ПрогрессОбновления";
	Результат = Запрос.Выполнить().Выгрузить();

	Для Каждого Строка Из Результат Цикл
		Если День(Строка.ИнтервалЧас) = День(ТекущаяДатаСеанса()) Тогда
			ФорматнаяСтрока = "ДЛФ=T";
		Иначе
			ФорматнаяСтрока = "ДЛФ=DT";
		КонецЕсли;

		ПредставлениеИнтервала = "с %1";
		ПредставлениеИнтервала = СтрШаблон(ПредставлениеИнтервала, Формат(Строка.ИнтервалЧас, ФорматнаяСтрока));

		ДоступныеПериоды.Добавить(Строка(Строка.ИнтервалЧас), ПредставлениеИнтервала);
	КонецЦикла;

	Возврат ДоступныеПериоды;

КонецФункции

Функция ЗарегистрированныеОбъекты(ВыбранныеИнтервалы)

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОбновлениеИнформационнойБазы.Ссылка КАК Ссылка
	|ИЗ
	|	ПланОбмена.ОбновлениеИнформационнойБазы КАК ОбновлениеИнформационнойБазы
	|ГДЕ
	|	ОбновлениеИнформационнойБазы.Временная = ЛОЖЬ";
	Результат = Запрос.Выполнить().Выгрузить();
	МассивУзлов = Результат.ВыгрузитьКолонку("Ссылка");
	СписокУзлов = Новый СписокЗначений;
	СписокУзлов.ЗагрузитьЗначения(МассивУзлов);

	ТаблицаРезультата = Новый ТаблицаЗначений;
	ТаблицаРезультата.Колонки.Добавить("СинонимКонфигурации");
	ТаблицаРезультата.Колонки.Добавить("ПолноеИмя");
	ТаблицаРезультата.Колонки.Добавить("ТипОбъекта");
	ТаблицаРезультата.Колонки.Добавить("Представление");
	ТаблицаРезультата.Колонки.Добавить("ТипМетаданных");
	ТаблицаРезультата.Колонки.Добавить("КоличествоОбъектов");
	ТаблицаРезультата.Колонки.Добавить("Очередь");
	ТаблицаРезультата.Колонки.Добавить("ОбработчикОбновления");
	ТаблицаРезультата.Колонки.Добавить("Статус");
	ТаблицаРезультата.Колонки.Добавить("ОбработаноЗаИнтервал", Новый ОписаниеТипов("Число"));
	ТаблицаРезультата.Колонки.Добавить("ВсегоОбъектов", Новый ОписаниеТипов("Число"));
	ТаблицаРезультата.Колонки.Добавить("ЕстьОшибки", Новый ОписаниеТипов("Булево"));
	ТаблицаРезультата.Колонки.Добавить("ПроблемаВДанных", Новый ОписаниеТипов("Булево"));

	СоставПланаОбмена = Метаданные.ПланыОбмена.ОбновлениеИнформационнойБазы.Состав;
	СоответствиеПредставлений = Новый Соответствие;

	СинонимКонфигурации = Метаданные.Синоним;
	ТекстЗапроса = "";
	Запрос       = Новый Запрос;
	Запрос.УстановитьПараметр("СписокУзлов", СписокУзлов);
	Ограничение  = 0;
	Для Каждого ЭлементПланаОбмена Из СоставПланаОбмена Цикл
		ОбъектМетаданных = ЭлементПланаОбмена.Метаданные;
		Если Не ПравоДоступа("Чтение", ОбъектМетаданных) Тогда
			Продолжить;
		КонецЕсли;
		Представление    = ОбъектМетаданных.Представление();
		ПолноеИмя        = ОбъектМетаданных.ПолноеИмя();
		ПолноеИмяЧастями = СтрРазделить(ПолноеИмя, ".");
		
		// Преобразование из "РегистрРасчета._ДемоОсновныеНачисления.Перерасчет.ПерерасчетОсновныхНачислений.Изменения"
		// в "РегистрРасчета._ДемоОсновныеНачисления.ПерерасчетОсновныхНачислений.Изменения".
		Если ПолноеИмяЧастями[0] = "РегистрРасчета" И ПолноеИмяЧастями.Количество() = 4 И ПолноеИмяЧастями[2]
			= "Перерасчет" Тогда
			ПолноеИмяЧастями.Удалить(2); // удалить лишний "Перерасчет"
			ПолноеИмя = СтрСоединить(ПолноеИмяЧастями, ".");
		КонецЕсли;
		// Контекстный перевод
		ТекстЗапроса = ТекстЗапроса + ?(ТекстЗапроса = "", "", "ОБЪЕДИНИТЬ ВСЕ") + "
																				   |ВЫБРАТЬ
																				   |	""&ПредставлениеТипаМетаданных"" КАК ТипМетаданных,
																				   |	""&ТипОбъекта"" КАК ТипОбъекта,
																				   |	""&ПолноеИмя"" КАК ПолноеИмя,
																				   |	Узел.Очередь КАК Очередь,
																				   |	КОЛИЧЕСТВО(*) КАК КоличествоОбъектов
																				   |ИЗ
																				   |	&ТаблицаИзменений
																				   |ГДЕ
																				   |	Узел В (&СписокУзлов)
																				   |СГРУППИРОВАТЬ ПО
																				   |	Узел
																				   |";
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ПредставлениеТипаМетаданных", ПредставлениеТипаМетаданных(
			ПолноеИмяЧастями[0]));
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ТипОбъекта", ПолноеИмяЧастями[1]);
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ПолноеИмя", ПолноеИмя);
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ТаблицаИзменений", ПолноеИмя + ".Изменения");

		Ограничение = Ограничение + 1;
		СоответствиеПредставлений.Вставить(ПолноеИмяЧастями[1], Представление);
		Если Ограничение = 200 Тогда
			Запрос.Текст = ТекстЗапроса;
			Выборка = Запрос.Выполнить().Выбрать();
			Пока Выборка.Следующий() Цикл
				Строка = ТаблицаРезультата.Добавить();
				ЗаполнитьЗначенияСвойств(Строка, Выборка);
				Строка.СинонимКонфигурации = СинонимКонфигурации;
				Строка.Представление = СоответствиеПредставлений[Строка.ТипОбъекта];
			КонецЦикла;
			Ограничение  = 0;
			ТекстЗапроса = "";
			СоответствиеПредставлений = Новый Соответствие;
		КонецЕсли;

	КонецЦикла;

	Если ТекстЗапроса <> "" Тогда
		Запрос.Текст = ТекстЗапроса;
		Выборка = Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			Строка = ТаблицаРезультата.Добавить();
			ЗаполнитьЗначенияСвойств(Строка, Выборка);
			Строка.СинонимКонфигурации = СинонимКонфигурации;
			Строка.Представление = СоответствиеПредставлений[Строка.ТипОбъекта];
		КонецЦикла;
	КонецЕсли;

	ПрогрессОбработкиДанных         = ПрогрессОбработкиДанных(ВыбранныеИнтервалы);
	ОшибкиПриВыполненииОбработчиков = ОшибкиПриВыполненииОбработчиков();
	ПроблемыСДаннымиВОбработчиках   = ПроблемыСДаннымиВОбработчиках();

	Обработчики = ОбновлениеИнформационнойБазыСлужебный.ОбработчикиДляОтложеннойРегистрацииДанных();
	Для Каждого Обработчик Из Обработчики Цикл
		ДанныеПоОбработчику = Обработчик.ОбрабатываемыеДанные.Получить();
		ИмяОбработчика = Обработчик.ИмяОбработчика;
		СтатусОбработчика = Обработчик.Статус;

		Если ПрогрессОбработкиДанных = Неопределено Тогда
			ОбъектовОбработано = 0;
		Иначе
			ПараметрыОтбора = Новый Структура;
			ПараметрыОтбора.Вставить("ИмяОбработчика", ИмяОбработчика);
			Строки = ПрогрессОбработкиДанных.НайтиСтроки(ПараметрыОтбора);
			ОбъектовОбработано = 0;
			Для Каждого Строка Из Строки Цикл
				ОбъектовОбработано = ОбъектовОбработано + Строка.ОбъектовОбработано;
			КонецЦикла;
		КонецЕсли;

		Для Каждого ДанныеПоОбъекту Из ДанныеПоОбработчику.ДанныеОбработчика Цикл
			ПолноеИмяОбъекта = ДанныеПоОбъекту.Ключ;
			Очередь    = ДанныеПоОбъекту.Значение.Очередь;
			Количество = ДанныеПоОбъекту.Значение.Количество;

			ПараметрыОтбора = Новый Структура;
			ПараметрыОтбора.Вставить("ПолноеИмя", ПолноеИмяОбъекта);
			ПараметрыОтбора.Вставить("Очередь", Очередь);
			Строки = ТаблицаРезультата.НайтиСтроки(ПараметрыОтбора);
			Для Каждого Строка Из Строки Цикл
				Если Не ЗначениеЗаполнено(Строка.ОбработчикОбновления) Тогда
					Строка.ОбработчикОбновления = ИмяОбработчика;
				Иначе
					Строка.ОбработчикОбновления = Строка.ОбработчикОбновления + "," + Символы.ПС + ИмяОбработчика;
				КонецЕсли;
				Строка.ВсегоОбъектов = Строка.ВсегоОбъектов + Количество;
				Если ОбъектовОбработано > Строка.ВсегоОбъектов Тогда
					ОбъектовОбработано = Строка.ВсегоОбъектов;
				КонецЕсли;
				Строка.ОбработаноЗаИнтервал = ОбъектовОбработано;
				Строка.Статус = СтатусОбработчика;
				Если ОшибкиПриВыполненииОбработчиков[ИмяОбработчика] = Истина Тогда
					Строка.ЕстьОшибки = Истина;
				КонецЕсли;
				Если ПроблемыСДаннымиВОбработчиках[ИмяОбработчика] = Истина Тогда
					Строка.ПроблемаВДанных = Истина;
				КонецЕсли;
			КонецЦикла;
			
			// Объект полностью обработан.
			Если Строки.Количество() = 0 Тогда
				Строка = ТаблицаРезультата.Добавить();
				ПолноеИмяЧастями = СтрРазделить(ПолноеИмяОбъекта, ".");

				Строка.СинонимКонфигурации = СинонимКонфигурации;
				Строка.ПолноеИмя     = ПолноеИмяОбъекта;
				Строка.ТипОбъекта    = ПолноеИмяЧастями[1];
				Строка.Представление = Метаданные.НайтиПоПолномуИмени(ПолноеИмяОбъекта).Представление();
				Строка.ТипМетаданных = ПредставлениеТипаМетаданных(ПолноеИмяЧастями[0]);
				Строка.Очередь       = Очередь;
				Строка.ОбработчикОбновления = ИмяОбработчика;
				Строка.ВсегоОбъектов = Строка.ВсегоОбъектов + Количество;
				Строка.КоличествоОбъектов = 0;
				Если ОбъектовОбработано > Строка.ВсегоОбъектов Тогда
					ОбъектовОбработано = Строка.ВсегоОбъектов;
				КонецЕсли;
				Строка.ОбработаноЗаИнтервал = ОбъектовОбработано;
				Строка.Статус = СтатусОбработчика;
				Если ОшибкиПриВыполненииОбработчиков[ИмяОбработчика] = Истина Тогда
					Строка.ЕстьОшибки = Истина;
				КонецЕсли;
				Если ПроблемыСДаннымиВОбработчиках[ИмяОбработчика] = Истина Тогда
					Строка.ПроблемаВДанных = Истина;
				КонецЕсли;
			КонецЕсли;

		КонецЦикла;
	КонецЦикла;

	Отбор = Новый Структура;
	Отбор.Вставить("ОбработчикОбновления", Неопределено);
	РезультатПоиска = ТаблицаРезультата.НайтиСтроки(Отбор);

	Для Каждого Строка Из РезультатПоиска Цикл
		ТаблицаРезультата.Удалить(Строка);
	КонецЦикла;

	Возврат ТаблицаРезультата;

КонецФункции

Функция ПрогрессОбработкиДанных(ВыбранныйИнтервал)

	Если ВыбранныйИнтервал = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	ОписаниеДаты = Новый ОписаниеТипов("Дата");
	ПриведенноеЗначениеДаты = ОписаниеДаты.ПривестиЗначение(ВыбранныйИнтервал);
	Если Не ЗначениеЗаполнено(ПриведенноеЗначениеДаты) Тогда
		Возврат Неопределено;
	КонецЕсли;

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИнтервалЧас", ПриведенноеЗначениеДаты);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ПрогрессОбновления.ИмяОбработчика КАК ИмяОбработчика,
	|	СУММА(ПрогрессОбновления.ОбъектовОбработано) КАК ОбъектовОбработано
	|ИЗ
	|	РегистрСведений.ПрогрессОбновления КАК ПрогрессОбновления
	|ГДЕ
	|	ПрогрессОбновления.ИнтервалЧас >= &ИнтервалЧас
	|
	|СГРУППИРОВАТЬ ПО
	|	ПрогрессОбновления.ИмяОбработчика";

	Результат = Запрос.Выполнить().Выгрузить();

	Возврат Результат;

КонецФункции

Функция ОшибкиПриВыполненииОбработчиков()
	ОбработчикиСПроблемами = Новый Соответствие;

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("РежимВыполненияОтложенногоОбработчика",
		Перечисления.РежимыВыполненияОтложенныхОбработчиков.Параллельно);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОбработчикиОбновления.ИмяОбработчика КАК ИмяОбработчика,
	|	ОбработчикиОбновления.СтатистикаВыполнения КАК СтатистикаВыполнения
	|ИЗ
	|	РегистрСведений.ОбработчикиОбновления КАК ОбработчикиОбновления
	|ГДЕ
	|	ОбработчикиОбновления.РежимВыполненияОтложенногоОбработчика = &РежимВыполненияОтложенногоОбработчика";
	Результат = Запрос.Выполнить().Выгрузить();
	Для Каждого СтрокаОбработчик Из Результат Цикл
		СтатистикаВыполнения = СтрокаОбработчик.СтатистикаВыполнения.Получить();
		Если СтатистикаВыполнения = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		Если СтатистикаВыполнения["ЕстьОшибки"] <> Неопределено И СтатистикаВыполнения["ЕстьОшибки"] Тогда
			ОбработчикиСПроблемами.Вставить(СтрокаОбработчик.ИмяОбработчика, Истина);
		КонецЕсли;
	КонецЦикла;

	Возврат ОбработчикиСПроблемами;
КонецФункции

Функция ПроблемыСДаннымиВОбработчиках()

	ПроблемыПоОбработчику = Новый Соответствие;
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.КонтрольВеденияУчета") Тогда
		МодульКонтрольВеденияУчета = ОбщегоНазначения.ОбщийМодуль("КонтрольВеденияУчета");
		ОшибкиПоВидамПроверок = МодульКонтрольВеденияУчета.ПодробнаяИнформацияПоВидамПроверок("ОбновлениеВерсииИБ",
			Ложь);
		Для Каждого Ошибка Из ОшибкиПоВидамПроверок Цикл
			ВидПроверки = Ошибка.ВидПроверки;
			ИмяОбработчика = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ВидПроверки, "Свойство2");
			ПроблемыПоОбработчику.Вставить(ИмяОбработчика, Истина);
		КонецЦикла;
	КонецЕсли;

	Возврат ПроблемыПоОбработчику;

КонецФункции

Функция ПредставлениеТипаМетаданных(ТипМетаданных)

	Соответствие = Новый Соответствие;
	Соответствие.Вставить("Константа", НСтр("ru = 'Константы'"));
	Соответствие.Вставить("Справочник", НСтр("ru = 'Справочники'"));
	Соответствие.Вставить("Документ", НСтр("ru = 'Документы'"));
	Соответствие.Вставить("ПланВидовХарактеристик", НСтр("ru = 'Планы видов характеристик'"));
	Соответствие.Вставить("ПланСчетов", НСтр("ru = 'Планы счетов'"));
	Соответствие.Вставить("ПланВидовРасчета", НСтр("ru = 'Планы видов расчета'"));
	Соответствие.Вставить("РегистрСведений", НСтр("ru = 'Регистры сведений'"));
	Соответствие.Вставить("РегистрНакопления", НСтр("ru = 'Регистры накопления'"));
	Соответствие.Вставить("РегистрБухгалтерии", НСтр("ru = 'Регистры бухгалтерии'"));
	Соответствие.Вставить("РегистрРасчета", НСтр("ru = 'Регистры расчета'"));
	Соответствие.Вставить("БизнесПроцесс", НСтр("ru = 'Бизнес процессы'"));
	Соответствие.Вставить("Задача", НСтр("ru = 'Задачи'"));

	Возврат Соответствие[ТипМетаданных];

КонецФункции

#КонецОбласти

#Иначе
	ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли