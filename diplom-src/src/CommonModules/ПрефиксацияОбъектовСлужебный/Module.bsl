///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Область СлужебныйПрограммныйИнтерфейс

// Выполняет действия по изменению префикса информационной базы
// Дополнительно позволяет выполнить обработку данных для продолжения нумерации.
//
// Параметры:
//  Параметры - Структура - параметры выполнения процедуры:
//   * НовыйПрефиксИБ - Строка - новый префикс информационной базы.
//   * ПродолжитьНумерацию - Булево - признак необходимости продолжения нумерации.
//  АдресРезультата - Строка - адрес временного хранилища, в которое нужно
//                                поместить результат работы процедуры.
//
Процедура ИзменитьПрефиксИБ(Параметры, АдресРезультата = "") Экспорт
	
	// Константа, хранящая префикс, поставляется с подсистемой "Обмен данными".
	// Без нее выполнение процедуры не имеет смысла.
	Если Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными") Тогда
		Возврат;
	КонецЕсли;

	НовыйПрефиксИБ = Параметры.НовыйПрефиксИБ;
	ПродолжитьНумерацию = Параметры.ПродолжитьНумерацию;

	НачатьТранзакцию();

	Попытка

		Если ПродолжитьНумерацию Тогда
			ОбработатьДанныеДляПродолженияНумерации(НовыйПрефиксИБ);
		КонецЕсли;
		
		// Константу устанавливаем в последнюю очередь, чтобы иметь доступ к предыдущему ее значению.
		ПрефиксИмяКонстанты = "ПрефиксУзлаРаспределеннойИнформационнойБазы";
		Константы[ПрефиксИмяКонстанты].Установить(НовыйПрефиксИБ);

		ЗафиксироватьТранзакцию();

	Исключение

		ОтменитьТранзакцию();

		ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрацииПерепрефиксацияОбъектов(), УровеньЖурналаРегистрации.Ошибка, ,
			, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));

		ВызватьИсключение НСтр("ru = 'Не удалось изменить префикс.'");

	КонецПопытки;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Экспортные служебные процедуры и функции.

// Возвращает признак изменения организации или даты объекта.
//
// Параметры:
//  Ссылка - ссылка на объект ИБ.
//  ДатаПослеИзменения - дата объекта после изменения.
//  ОрганизацияПослеИзменения - организация объекта после изменения.
//
//  Возвращаемое значение:
//    Булево - Истина - организация объекта была изменена или новая дата объекта
//            задана в другом интервале периодичности по сравнению с предыдущим значением даты.
//   Ложь - организация и дата документа не были изменены.
//
Функция ДатаИлиОрганизацияОбъектаИзменена(Ссылка, Знач ДатаПослеИзменения, Знач ОрганизацияПослеИзменения) Экспорт

	ПолноеИмяТаблицы = Ссылка.Метаданные().ПолноеИмя();
	ТекстЗапроса = "
				   |ВЫБРАТЬ
				   |	ШапкаОбъекта.Дата КАК Дата,
				   |	ЕСТЬNULL(ШапкаОбъекта.ИмяРеквизитаОрганизация.Префикс, """") КАК ПрефиксОрганизацииДоИзменения
				   |ИЗ
				   |	&ИмяТаблицы КАК ШапкаОбъекта
				   |ГДЕ
				   |	ШапкаОбъекта.Ссылка = &Ссылка
				   |";

	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ИмяТаблицы", ПолноеИмяТаблицы);
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "ИмяРеквизитаОрганизация",
		ПрефиксацияОбъектовСобытия.ИмяРеквизитаОрганизация(ПолноеИмяТаблицы));

	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);

	УстановитьПривилегированныйРежим(Истина);

	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();

	ПрефиксОрганизацииПослеИзменения = Неопределено;
	ПрефиксацияОбъектовСобытия.ПриОпределенииПрефиксаОрганизации(ОрганизацияПослеИзменения,
		ПрефиксОрганизацииПослеИзменения);
	
	// Если задана пустая ссылка на организацию.
	ПрефиксОрганизацииПослеИзменения = ?(ПрефиксОрганизацииПослеИзменения = Ложь, "", ПрефиксОрганизацииПослеИзменения);

	Возврат Выборка.ПрефиксОрганизацииДоИзменения <> ПрефиксОрганизацииПослеИзменения Или Не ДатыОбъектаОдногоПериода(
		Выборка.Дата, ДатаПослеИзменения, Ссылка);
	//
КонецФункции

// Возвращает признак изменения организации объекта.
//
// Параметры:
//  Ссылка - ссылка на объект ИБ.
//  ОрганизацияПослеИзменения - организация объекта после изменения.
//
//  Возвращаемое значение:
//    Булево - Истина - организация объекта была изменена. Ложь - организация не была изменена.
//
Функция ОрганизацияОбъектаИзменена(Ссылка, Знач ОрганизацияПослеИзменения) Экспорт

	ПолноеИмяТаблицы = Ссылка.Метаданные().ПолноеИмя();
	ТекстЗапроса = "
				   |ВЫБРАТЬ
				   |	ЕСТЬNULL(ШапкаОбъекта.ИмяРеквизитаОрганизация.Префикс, """") КАК ПрефиксОрганизацииДоИзменения
				   |ИЗ
				   |	&ИмяТаблицы КАК ШапкаОбъекта
				   |ГДЕ
				   |	ШапкаОбъекта.Ссылка = &Ссылка
				   |";

	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ИмяТаблицы", ПолноеИмяТаблицы);
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "ИмяРеквизитаОрганизация",
		ПрефиксацияОбъектовСобытия.ИмяРеквизитаОрганизация(ПолноеИмяТаблицы));

	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);

	УстановитьПривилегированныйРежим(Истина);

	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();

	ПрефиксОрганизацииПослеИзменения = Неопределено;
	ПрефиксацияОбъектовСобытия.ПриОпределенииПрефиксаОрганизации(ОрганизацияПослеИзменения,
		ПрефиксОрганизацииПослеИзменения);
	
	// Если задана пустая ссылка на организацию.
	ПрефиксОрганизацииПослеИзменения = ?(ПрефиксОрганизацииПослеИзменения = Ложь, "", ПрефиксОрганизацииПослеИзменения);

	Возврат Выборка.ПрефиксОрганизацииДоИзменения <> ПрефиксОрганизацииПослеИзменения;

КонецФункции

// Определяет признак равенства двух дат для объекта метаданных.
// Даты считаются равными, если они принадлежат одному периоду времени: Год, Месяц, День и пр.
//
// Параметры:
//   Дата1 - первая дата для сравнения;
//   Дата2 - вторая дата для сравнения;
//   МетаданныеОбъекта - метаданные объекта, для которого необходимо получить значение функции.
//
//  Возвращаемое значение:
//    Булево - Истина - даты объекта одного периода; Ложь - даты объекта разных периодов.
//
Функция ДатыОбъектаОдногоПериода(Знач Дата1, Знач Дата2, Ссылка) Экспорт

	МетаданныеОбъекта = Ссылка.Метаданные();

	Если ПериодичностьНомераДокументаГод(МетаданныеОбъекта) Тогда

		РазностьДат = НачалоГода(Дата1) - НачалоГода(Дата2);

	ИначеЕсли ПериодичностьНомераДокументаКвартал(МетаданныеОбъекта) Тогда

		РазностьДат = НачалоКвартала(Дата1) - НачалоКвартала(Дата2);

	ИначеЕсли ПериодичностьНомераДокументаМесяц(МетаданныеОбъекта) Тогда

		РазностьДат = НачалоМесяца(Дата1) - НачалоМесяца(Дата2);

	ИначеЕсли ПериодичностьНомераДокументаДень(МетаданныеОбъекта) Тогда

		РазностьДат = НачалоДня(Дата1) - НачалоДня(Дата2);

	Иначе // ПериодичностьНомераДокументаНеопределено

		РазностьДат = 0;

	КонецЕсли;

	Возврат РазностьДат = 0;

КонецФункции

Функция ОписаниеМетаданныхИспользующихПрефиксы(РежимДиагностики = Ложь) Экспорт

	Результат = НовоеОписаниеМетаданныхИспользующихПрефиксы();

	МодульРаботаВМоделиСервиса = Неопределено;
	ЕстьПодсистемаРаботаВМоделиСервиса = ОбщегоНазначения.ПодсистемаСуществует(
		"ТехнологияСервиса.БазоваяФункциональность");
	Если ЕстьПодсистемаРаботаВМоделиСервиса Тогда
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
	КонецЕсли;

	// Наполнение таблицы метаданных.
	РазделениеВключено = ОбщегоНазначения.РазделениеВключено();
	Для Каждого Подписка Из Метаданные.ПодпискиНаСобытия Цикл

		ИспользуетсяПрефиксИБ = Ложь;
		ИспользуетсяПрефиксОрганизации = Ложь;
		Если ВРег(Подписка.Обработчик) = ВРег(
			"ПрефиксацияОбъектовСобытия.УстановитьПрефиксИнформационнойБазыИОрганизации") Тогда
			ИспользуетсяПрефиксИБ = Истина;
			ИспользуетсяПрефиксОрганизации = Истина;
		ИначеЕсли ВРег(Подписка.Обработчик) = ВРег("ПрефиксацияОбъектовСобытия.УстановитьПрефиксИнформационнойБазы") Тогда
			ИспользуетсяПрефиксИБ = Истина;
		ИначеЕсли ВРег(Подписка.Обработчик) = ВРег("ПрефиксацияОбъектовСобытия.УстановитьПрефиксОрганизации") Тогда
			ИспользуетсяПрефиксОрганизации = Истина;
		Иначе
			// Пропускаем подписки, не связанные с установкой префикса.
			Продолжить;
		КонецЕсли;

		Для Каждого ТипИсточника Из Подписка.Источник.Типы() Цикл

			МетаданныеИсточника = Метаданные.НайтиПоТипу(ТипИсточника);
			ПолноеИмяОбъекта = МетаданныеИсточника.ПолноеИмя();

			ЭтоРазделенныйОбъектМетаданных = Ложь;
			Если ЕстьПодсистемаРаботаВМоделиСервиса Тогда
				ЭтоРазделенныйОбъектМетаданных = МодульРаботаВМоделиСервиса.ЭтоРазделенныйОбъектМетаданных(
					ПолноеИмяОбъекта);
			КонецЕсли;
			
			// Пропускаем уже добавленные объекты (в случае ошибочного назначения нескольких подписок),
			// а также объекты, соответствующие неразделенным данным, если это разделенный режим.
			Если Не РежимДиагностики Тогда

				Если Результат.Найти(ПолноеИмяОбъекта, "ПолноеИмя") <> Неопределено Тогда
					Продолжить;
				ИначеЕсли РазделениеВключено Тогда

					Если Не ЭтоРазделенныйОбъектМетаданных Тогда
						Продолжить;
					КонецЕсли;

				КонецЕсли;

			КонецЕсли;

			ОписаниеОбъекта = Результат.Добавить();
			ОписаниеОбъекта.Имя = МетаданныеИсточника.Имя;
			ОписаниеОбъекта.ПолноеИмя = ПолноеИмяОбъекта;
			ОписаниеОбъекта.ИспользуетсяПрефиксИБ = ИспользуетсяПрефиксИБ;
			ОписаниеОбъекта.ИспользуетсяПрефиксОрганизации = ИспользуетсяПрефиксОрганизации;
		
			// Возможные виды данных с кодом или номером.
			ОписаниеОбъекта.ЭтоСправочник             = ОбщегоНазначения.ЭтоСправочник(МетаданныеИсточника);
			ОписаниеОбъекта.ЭтоПланВидовХарактеристик = ОбщегоНазначения.ЭтоПланВидовХарактеристик(МетаданныеИсточника);
			ОписаниеОбъекта.ЭтоДокумент               = ОбщегоНазначения.ЭтоДокумент(МетаданныеИсточника);
			ОписаниеОбъекта.ЭтоБизнесПроцесс          = ОбщегоНазначения.ЭтоБизнесПроцесс(МетаданныеИсточника);
			ОписаниеОбъекта.ЭтоЗадача                 = ОбщегоНазначения.ЭтоЗадача(МетаданныеИсточника);

			ОписаниеОбъекта.ИмяПодписки = Подписка.Имя;

			ОписаниеОбъекта.ЭтоРазделенныйОбъектМетаданных = ЭтоРазделенныйОбъектМетаданных;

			Характеристики = Новый Структура("ДлинаКода, ДлинаНомера", 0, 0);
			ЗаполнитьЗначенияСвойств(Характеристики, МетаданныеИсточника);

			Если Характеристики.ДлинаКода = 0 И Характеристики.ДлинаНомера = 0 Тогда

				Если Не РежимДиагностики Тогда

					ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Ошибка внедрения подсистемы ""%1"" для объекта метаданных ""%2"".'"),
						Метаданные.Подсистемы.СтандартныеПодсистемы.Подсистемы.ПрефиксацияОбъектов, ПолноеИмяОбъекта);

				КонецЕсли;

			Иначе

				Если ОписаниеОбъекта.ЭтоСправочник Или ОписаниеОбъекта.ЭтоПланВидовХарактеристик Тогда
					ОписаниеОбъекта.ЕстьКод = Истина;
				Иначе
					ОписаниеОбъекта.ЕстьНомер = Истина;
				КонецЕсли;

			КонецЕсли;
			
			// Определение периодичности номера для документа и бизнес-процесса.
			ПериодичностьНомера = Метаданные.СвойстваОбъектов.ПериодичностьНомераДокумента.Непериодический;
			Если ОписаниеОбъекта.ЭтоДокумент Тогда
				ПериодичностьНомера = МетаданныеИсточника.ПериодичностьНомера;
			ИначеЕсли ОписаниеОбъекта.ЭтоБизнесПроцесс Тогда
				Если МетаданныеИсточника.ПериодичностьНомера
					= Метаданные.СвойстваОбъектов.ПериодичностьНомераБизнесПроцесса.Год Тогда
					ПериодичностьНомера = Метаданные.СвойстваОбъектов.ПериодичностьНомераДокумента.Год;
				ИначеЕсли МетаданныеИсточника.ПериодичностьНомера
					= Метаданные.СвойстваОбъектов.ПериодичностьНомераБизнесПроцесса.День Тогда
					ПериодичностьНомера = Метаданные.СвойстваОбъектов.ПериодичностьНомераДокумента.День;
				ИначеЕсли МетаданныеИсточника.ПериодичностьНомера
					= Метаданные.СвойстваОбъектов.ПериодичностьНомераБизнесПроцесса.Квартал Тогда
					ПериодичностьНомера = Метаданные.СвойстваОбъектов.ПериодичностьНомераДокумента.Квартал;
				ИначеЕсли МетаданныеИсточника.ПериодичностьНомера
					= Метаданные.СвойстваОбъектов.ПериодичностьНомераБизнесПроцесса.Месяц Тогда
					ПериодичностьНомера = Метаданные.СвойстваОбъектов.ПериодичностьНомераДокумента.Месяц;
				ИначеЕсли МетаданныеИсточника.ПериодичностьНомера
					= Метаданные.СвойстваОбъектов.ПериодичностьНомераБизнесПроцесса.Непериодический Тогда
					ПериодичностьНомера = Метаданные.СвойстваОбъектов.ПериодичностьНомераДокумента.Непериодический;
				КонецЕсли;
			КонецЕсли;
			ОписаниеОбъекта.ПериодичностьНомера = ПериодичностьНомера;

		КонецЦикла;
	КонецЦикла;

	Возврат Результат;

КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Локальные служебные процедуры и функции.

// Определяет необходимость выполнения обработчика события "ПослеЗагрузкиДанных" при обмене в РИБ.
//
// Параметры:
//  НовыйПрефиксИБ - Строка - необходим для вычисления новых кодов (номеров) элементов после изменения префикса.
//  РежимАнализаДанных - Булево - если Истина, изменения данных не происходит, функция только просчитывает,
//                                какие данные будут изменены и как они будут изменены. Если Ложь - изменения объекта,
//                                записываются в информационную базу.
//
// Возвращаемое значение:
//   см. ПрефиксацияОбъектовСлужебный.ОписаниеМетаданныхИспользующихПрефиксы
//
Функция ОбработатьДанныеДляПродолженияНумерации(Знач НовыйПрефиксИБ = "", РежимАнализаДанных = Ложь)

	ОписаниеМетаданныхИспользующихПрефиксы = ОписаниеМетаданныхИспользующихПрефиксы();

	ДополнитьСтрокуНулямиСлева(НовыйПрефиксИБ, 2);

	Результат = НовоеОписаниеМетаданныхИспользующихПрефиксы();
	Результат.Колонки.Добавить("Ссылка");
	Результат.Колонки.Добавить("Номер");
	Результат.Колонки.Добавить("НовыйНомер");

	ТекущийПрефиксИБ = "";
	ПрефиксацияОбъектовСобытия.ПриОпределенииПрефиксаИнформационнойБазы(ТекущийПрефиксИБ);
	ДополнитьСтрокуНулямиСлева(ТекущийПрефиксИБ, 2);

	Для Каждого ОписаниеОбъекта Из ОписаниеМетаданныхИспользующихПрефиксы Цикл

		Если Не РежимАнализаДанных Тогда
			// Устанавливаем исключительную блокировку на читаемые и впоследствии изменяемые виды данных.
			БлокировкаДанных = Новый БлокировкаДанных;
			ЭлементБлокировкиДанных = БлокировкаДанных.Добавить(ОписаниеОбъекта.ПолноеИмя);
			БлокировкаДанных.Заблокировать();
		КонецЕсли;

		ДанныеОбъектовДляПеренумерацииПоследнегоЭлемента = ДанныеОбъектовОдногоВидаДляПеренумерацииПоследнихЭлементов(
			ОписаниеОбъекта, ТекущийПрефиксИБ);

		Если ДанныеОбъектовДляПеренумерацииПоследнегоЭлемента.Пустой() Тогда
			Продолжить;
		КонецЕсли;

		ВыборкаОбъектов = ДанныеОбъектовДляПеренумерацииПоследнегоЭлемента.Выбрать();
		Пока ВыборкаОбъектов.Следующий() Цикл

			НоваяСтрокаРезультата = Результат.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрокаРезультата, ОписаниеОбъекта);
			ЗаполнитьЗначенияСвойств(НоваяСтрокаРезультата, ВыборкаОбъектов);
			НоваяСтрокаРезультата.НовыйНомер = СтрЗаменить(НоваяСтрокаРезультата.Номер, ТекущийПрефиксИБ + "-",
				НовыйПрефиксИБ + "-");

			Если Не РежимАнализаДанных Тогда
				ОбъектПеренумерации = НоваяСтрокаРезультата.Ссылка.ПолучитьОбъект();
				ОбъектПеренумерации[?(НоваяСтрокаРезультата.ЕстьНомер, "Номер",
					"Код")] = НоваяСтрокаРезультата.НовыйНомер;
				ОбновлениеИнформационнойБазы.ЗаписатьДанные(ОбъектПеренумерации, Истина, Ложь);
			КонецЕсли;

		КонецЦикла;

	КонецЦикла;

	Возврат Результат;

КонецФункции

Функция ПериодичностьНомераДокументаГод(МетаданныеОбъекта)

	Возврат МетаданныеОбъекта.ПериодичностьНомера = Метаданные.СвойстваОбъектов.ПериодичностьНомераДокумента.Год;

КонецФункции

Функция ПериодичностьНомераДокументаКвартал(МетаданныеОбъекта)

	Возврат МетаданныеОбъекта.ПериодичностьНомера = Метаданные.СвойстваОбъектов.ПериодичностьНомераДокумента.Квартал;

КонецФункции

Функция ПериодичностьНомераДокументаМесяц(МетаданныеОбъекта)

	Возврат МетаданныеОбъекта.ПериодичностьНомера = Метаданные.СвойстваОбъектов.ПериодичностьНомераДокумента.Месяц;

КонецФункции

Функция ПериодичностьНомераДокументаДень(МетаданныеОбъекта)

	Возврат МетаданныеОбъекта.ПериодичностьНомера = Метаданные.СвойстваОбъектов.ПериодичностьНомераДокумента.День;

КонецФункции

Функция ДанныеОбъектовОдногоВидаДляПеренумерацииПоследнихЭлементов(Знач ОписаниеОбъекта, Знач ПредыдущийПрефикс = "")

	ПолноеИмяОбъекта = ОписаниеОбъекта.ПолноеИмя;
	ЕстьНомер = ОписаниеОбъекта.ЕстьНомер;
	ИспользуетсяПрефиксОрганизации = ОписаниеОбъекта.ИспользуетсяПрефиксОрганизации;

	Запрос = Новый Запрос;

	ТекстыЗапросовПакета = Новый Массив;
	Разделитель =
	"
	|;
	|/////////////////////////////////////////////////////////////
	|";

	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ВыборкаПоДатеНомеру.Ссылка КАК Ссылка,
	|	&ИмяПоляОрганизация КАК Организация,
	|	&ИмяПоляКодНомер КАК Номер
	|ПОМЕСТИТЬ ВыборкаПоДатеНомеру
	|ИЗ
	|	&ИмяТаблицы КАК ВыборкаПоДатеНомеру
	|ГДЕ
	|	&УсловиеПоДате И &ИмяПоляКодНомер ПОДОБНО &Префикс
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номер,
	|	Организация";

	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&УсловиеПоДате", ?(ЕстьНомер, "ВыборкаПоДатеНомеру.Дата >= &Дата",
		"ИСТИНА"));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ИмяПоляКодНомер", "ВыборкаПоДатеНомеру." + ?(ЕстьНомер, "Номер", "Код"));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ИмяТаблицы", ПолноеИмяОбъекта);

	ИмяПоляОрганизация = ?(ИспользуетсяПрефиксОрганизации, "ВыборкаПоДатеНомеру."
		+ ПрефиксацияОбъектовСобытия.ИмяРеквизитаОрганизация(ПолноеИмяОбъекта), "Неопределено");
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ИмяПоляОрганизация", ИмяПоляОрганизация);

	ТекстыЗапросовПакета.Добавить(ТекстЗапроса);

	ТекстЗапроса =
	"ВЫБРАТЬ
	|	МаксимальныеКоды.Организация КАК Организация,
	|	МАКСИМУМ(МаксимальныеКоды.Номер) КАК Номер
	|ПОМЕСТИТЬ МаксимальныеКоды
	|ИЗ
	|	ВыборкаПоДатеНомеру КАК МаксимальныеКоды
	|
	|СГРУППИРОВАТЬ ПО
	|	МаксимальныеКоды.Организация
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номер,
	|	Организация";
	ТекстыЗапросовПакета.Добавить(ТекстЗапроса);

	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ВыборкаПоДатеНомеру.Организация КАК Организация,
	|	ВыборкаПоДатеНомеру.Номер КАК Номер,
	|	МАКСИМУМ(ВыборкаПоДатеНомеру.Ссылка) КАК Ссылка
	|ИЗ
	|	ВыборкаПоДатеНомеру КАК ВыборкаПоДатеНомеру
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ МаксимальныеКоды КАК МаксимальныеКоды
	|		ПО (МаксимальныеКоды.Номер = ВыборкаПоДатеНомеру.Номер
	|				И МаксимальныеКоды.Организация = ВыборкаПоДатеНомеру.Организация)
	|
	|СГРУППИРОВАТЬ ПО
	|	ВыборкаПоДатеНомеру.Организация,
	|	ВыборкаПоДатеНомеру.Номер";
	ТекстыЗапросовПакета.Добавить(ТекстЗапроса);

	Запрос.Текст = СтрСоединить(ТекстыЗапросовПакета, Разделитель);

	Если ЕстьНомер Тогда
		// Выбираем данные с начала текущего года.
		СДаты = НачалоДня(НачалоГода(ТекущаяДатаСеанса()));
		Запрос.УстановитьПараметр("Дата", НачалоДня(СДаты));
	КонецЕсли;
	
	// Обрабатываем объекты, созданные только в текущей информационной базе.
	Префикс = "%[Префикс]-%";
	Префикс = СтрЗаменить(Префикс, "[Префикс]", ПредыдущийПрефикс);
	Запрос.УстановитьПараметр("Префикс", Префикс);

	Возврат Запрос.Выполнить();

КонецФункции

Функция НовоеОписаниеМетаданныхИспользующихПрефиксы()

	ОписаниеТиповСтрока = Новый ОписаниеТипов("Строка");
	ОписаниеТиповБулево = Новый ОписаниеТипов("Булево");

	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("Имя", ОписаниеТиповСтрока);
	Результат.Колонки.Добавить("ПолноеИмя", ОписаниеТиповСтрока);

	Результат.Колонки.Добавить("ЕстьКод", ОписаниеТиповБулево);
	Результат.Колонки.Добавить("ЕстьНомер", ОписаниеТиповБулево);
	Результат.Колонки.Добавить("ЭтоСправочник", ОписаниеТиповБулево);
	Результат.Колонки.Добавить("ЭтоПланВидовХарактеристик", ОписаниеТиповБулево);
	Результат.Колонки.Добавить("ЭтоДокумент", ОписаниеТиповБулево);
	Результат.Колонки.Добавить("ЭтоБизнесПроцесс", ОписаниеТиповБулево);
	Результат.Колонки.Добавить("ЭтоЗадача", ОписаниеТиповБулево);
	Результат.Колонки.Добавить("ИспользуетсяПрефиксИБ", ОписаниеТиповБулево);
	Результат.Колонки.Добавить("ИспользуетсяПрефиксОрганизации", ОписаниеТиповБулево);

	Результат.Колонки.Добавить("ПериодичностьНомера");

	Результат.Колонки.Добавить("ИмяПодписки", ОписаниеТиповСтрока);

	Результат.Колонки.Добавить("ЭтоРазделенныйОбъектМетаданных", ОписаниеТиповБулево);

	Возврат Результат;

КонецФункции

Процедура ДополнитьСтрокуНулямиСлева(Строка, ДлинаСтроки)

	Строка = СтроковыеФункцииКлиентСервер.ДополнитьСтроку(Строка, ДлинаСтроки, "0", "Слева");

КонецПроцедуры

Функция СобытиеЖурналаРегистрацииПерепрефиксацияОбъектов()

	Возврат НСтр("ru = 'Префиксация объектов.Изменение префикса информационной базы'",
		ОбщегоНазначения.КодОсновногоЯзыка());

КонецФункции

#КонецОбласти