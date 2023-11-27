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

	ОбъектЗначение = Параметры.Ключ.ПолучитьОбъект();
	ОбъектЗначение.Заполнить(Неопределено);

	НастроитьОбъектФормы(ОбъектЗначение);

	Если ТипЗнч(ЭтотОбъект.Объект.Владелец) = Тип("СправочникСсылка.Файлы") Тогда
		Элементы.Наименование0.ТолькоПросмотр = Истина;
	КонецЕсли;

	Если Пользователи.ЭтоПолноправныйПользователь() Тогда
		Элементы.Автор0.ТолькоПросмотр = Ложь;
		Элементы.ДатаСоздания0.ТолькоПросмотр = Ложь;
	Иначе
		Элементы.ГруппаХранение.Видимость = Ложь;
	КонецЕсли;

	ТомПолныйПуть = РаботаСФайламиВТомахСлужебный.ПолныйПутьТома(ЭтотОбъект.Объект.Том);

	ОбщиеНастройки = РаботаСФайламиСлужебныйПовтИсп.НастройкиРаботыСФайлами().ОбщиеНастройки;

	РасширениеФайлаВСписке = РаботаСФайламиСлужебныйКлиентСервер.РасширениеФайлаВСписке(
		ОбщиеНастройки.СписокРасширенийТекстовыхФайлов, ЭтотОбъект.Объект.Расширение);

	Если РасширениеФайлаВСписке Тогда
		Если ЗначениеЗаполнено(ЭтотОбъект.Объект.Ссылка) Тогда

			КодировкаЗначение = РегистрыСведений.КодировкиФайлов.КодировкаВерсииФайла(ЭтотОбъект.Объект.Ссылка);

			СписокКодировок = РаботаСФайламиСлужебный.Кодировки();
			ЭлементСписка = СписокКодировок.НайтиПоЗначению(КодировкаЗначение);
			Если ЭлементСписка = Неопределено Тогда
				Кодировка = КодировкаЗначение;
			Иначе
				Кодировка = ЭлементСписка.Представление;
			КонецЕсли;

		КонецЕсли;

		Если Не ЗначениеЗаполнено(Кодировка) Тогда
			Кодировка = НСтр("ru = 'По умолчанию'");
		КонецЕсли;
	Иначе
		Элементы.Кодировка.Видимость = Ложь;
	КонецЕсли;

	Элементы.ФормаУдалить.Видимость = ЭтотОбъект.Объект.Автор = Пользователи.АвторизованныйПользователь();

	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда

		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "СтандартнаяЗаписатьИЗакрыть",
			"Отображение", ОтображениеКнопки.Картинка);

		Если Элементы.Найти("Комментарий") <> Неопределено Тогда

			ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Комментарий", "МаксимальнаяВысота",
				2);
			ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Комментарий",
				"АвтоМаксимальнаяВысота", Ложь);
			ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Комментарий",
				"РастягиватьПоВертикали", Ложь);

		КонецЕсли;

		Если Элементы.Найти("Комментарий0") <> Неопределено Тогда

			ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Комментарий0",
				"МаксимальнаяВысота", 2);
			ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Комментарий0",
				"АвтоМаксимальнаяВысота", Ложь);
			ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Комментарий0",
				"РастягиватьПоВертикали", Ложь);

		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОткрытьВыполнить()

	ВерсияСсылка = ЭтотОбъект.Объект.Ссылка;
	ДанныеФайла = РаботаСФайламиСлужебныйВызовСервера.ДанныеФайлаДляОткрытия(ЭтотОбъект.Объект.Владелец, ВерсияСсылка,
		УникальныйИдентификатор);
	РаботаСФайламиСлужебныйКлиент.ОткрытьВерсиюФайла(Неопределено, ДанныеФайла, УникальныйИдентификатор);

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СохранитьКак(Команда)

	ВерсияСсылка = ЭтотОбъект.Объект.Ссылка;
	ДанныеФайла = РаботаСФайламиСлужебныйВызовСервера.ДанныеФайлаДляСохранения(ЭтотОбъект.Объект.Владелец,
		ВерсияСсылка, УникальныйИдентификатор);
	РаботаСФайламиСлужебныйКлиент.СохранитьКак(Неопределено, ДанныеФайла, УникальныйИдентификатор);

КонецПроцедуры

&НаКлиенте
Процедура СтандартнаяЗаписать(Команда)
	ОбработатьКомандуЗаписиВерсииФайла();
КонецПроцедуры

&НаКлиенте
Процедура СтандартнаяЗаписатьИЗакрыть(Команда)

	Если ОбработатьКомандуЗаписиВерсииФайла() Тогда
		Закрыть();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СтандартнаяПеречитать(Команда)

	Если ЭтоНовый() Тогда
		Возврат;
	КонецЕсли;

	Если Не Модифицированность Тогда
		ПеречитатьДанныеССервера();
		Возврат;
	КонецЕсли;

	ТекстВопроса = НСтр("ru = 'Данные изменены. Перечитать данные?'");

	ОписаниеОповещения = Новый ОписаниеОповещения("СтандартнаяПеречитатьОтветПолучен", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да);

КонецПроцедуры

&НаКлиенте
Процедура Удалить(Команда)

	РаботаСФайламиСлужебныйКлиент.УдалитьДанные(
		Новый ОписаниеОповещения("ПослеУдаленияДанных", ЭтотОбъект), ТекущийОбъектФормы().Ссылка,
		УникальныйИдентификатор);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПослеУдаленияДанных(Результат, ДополнительныеПараметры) Экспорт

	Закрыть();

КонецПроцедуры

&НаСервере
Процедура НастроитьОбъектФормы(Знач НовыйОбъект)

	ТипНовогоОбъекта = Новый Массив;
	ТипНовогоОбъекта.Добавить(ТипЗнч(НовыйОбъект));
	НовыйРеквизит = Новый РеквизитФормы("Объект", Новый ОписаниеТипов(ТипНовогоОбъекта));
	НовыйРеквизит.СохраняемыеДанные = Истина;

	ДобавляемыеРеквизиты = Новый Массив;
	ДобавляемыеРеквизиты.Добавить(НовыйРеквизит);

	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	ЗначениеВРеквизитФормы(НовыйОбъект, "Объект");
	Для Каждого Элемент Из Элементы Цикл

		Если ТипЗнч(Элемент) = Тип("ПолеФормы") И СтрНачинаетсяС(Элемент.ПутьКДанным, "ОбъектПрототип[0].")
			И СтрЗаканчиваетсяНа(Элемент.Имя, "0") Тогда

			ИмяЭлемента = Лев(Элемент.Имя, СтрДлина(Элемент.Имя) - 1);
			Если Элементы.Найти(ИмяЭлемента) <> Неопределено Тогда
				Продолжить;
			КонецЕсли;

			НовыйЭлемент = Элементы.Вставить(ИмяЭлемента, ТипЗнч(Элемент), Элемент.Родитель, Элемент);
			НовыйЭлемент.ПутьКДанным = "Объект." + Сред(Элемент.ПутьКДанным, СтрДлина("ОбъектПрототип[0].") + 1);
			Если Элемент.Вид = ВидПоляФормы.ПолеФлажка Или Элемент.Вид = ВидПоляФормы.ПолеКартинки Тогда
				ИсключаемыеСвойства = "Имя, ПутьКДанным";
			Иначе
				ИсключаемыеСвойства = "Имя, ПутьКДанным, ВыделенныйТекст, СвязьПоТипу";
			КонецЕсли;

			ЗаполнитьЗначенияСвойств(НовыйЭлемент, Элемент, , ИсключаемыеСвойства);
			Элемент.Видимость = Ложь;

		КонецЕсли;

	КонецЦикла;

	Если Не НовыйОбъект.ЭтоНовый() Тогда
		ЭтотОбъект.НавигационнаяСсылка = ПолучитьНавигационнуюСсылку(НовыйОбъект);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Функция ОбработатьКомандуЗаписиВерсииФайла()

	Если ПустаяСтрока(ЭтотОбъект.Объект.Наименование) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Для продолжения укажите имя версии файла.'"), , "Наименование", "Объект");
		Возврат Ложь;
	КонецЕсли;

	Попытка
		РаботаСФайламиСлужебныйКлиент.КорректноеИмяФайла(ЭтотОбъект.Объект.Наименование);
	Исключение
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			КраткоеПредставлениеОшибки(ИнформацияОбОшибке()), , "Наименование", "Объект");
		Возврат Ложь;
	КонецПопытки;

	Если Не ЗаписатьВерсиюФайла() Тогда
		Возврат Ложь;
	КонецЕсли;

	Модифицированность = Ложь;
	ОтобразитьИзменениеДанных(ЭтотОбъект.Объект.Ссылка, ВидИзмененияДанных.Изменение);
	ОповеститьОбИзменении(ЭтотОбъект.Объект.Ссылка);
	Оповестить("Запись_Файл", Новый Структура("Событие", "ВерсияСохранена"), ЭтотОбъект.Объект.Владелец);
	Оповестить("Запись_ВерсияФайла", Новый Структура("ЭтоНовый", Ложь), ЭтотОбъект.Объект.Ссылка);

	Возврат Истина;

КонецФункции

&НаСервере
Функция ЗаписатьВерсиюФайла(Знач ПараметрОбъект = Неопределено)

	Если ПараметрОбъект = Неопределено Тогда
		ЗаписываемыйОбъект = РеквизитФормыВЗначение("Объект"); // СправочникОбъект
	Иначе
		ЗаписываемыйОбъект = ПараметрОбъект;
	КонецЕсли;

	НачатьТранзакцию();
	Попытка
		ЗаписываемыйОбъект.Записать();
		ЗафиксироватьТранзакцию();
	Исключение

		ОтменитьТранзакцию();
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Файлы.Ошибка записи версии присоединенного файла'",
			ОбщегоНазначения.КодОсновногоЯзыка()), УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(
			ИнформацияОбОшибке()));

		ВызватьИсключение;

	КонецПопытки;

	Если ПараметрОбъект = Неопределено Тогда
		ЗначениеВРеквизитФормы(ЗаписываемыйОбъект, "Объект");
	КонецЕсли;

	Возврат Истина;

КонецФункции

&НаСервере
Процедура ПеречитатьДанныеССервера()

	ФайлОбъект = ТекущийОбъектФормыСервер().Ссылка.ПолучитьОбъект();
	ЗначениеВРеквизитФормы(ФайлОбъект, "Объект");

КонецПроцедуры

&НаКлиенте
Процедура СтандартнаяПеречитатьОтветПолучен(РезультатВопроса, ДополнительныеПараметры) Экспорт

	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		ПеречитатьДанныеССервера();
		Модифицированность = Ложь;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Функция ЭтоНовый()

	Возврат ТекущийОбъектФормы().Ссылка.Пустая();

КонецФункции

// Возвращаемое значение:
//   СправочникОбъект
//
&НаКлиенте
Функция ТекущийОбъектФормы()

	Возврат ЭтотОбъект.Объект;

КонецФункции

// Возвращаемое значение:
//   СправочникОбъект
//
&НаСервере
Функция ТекущийОбъектФормыСервер()

	Возврат ЭтотОбъект.Объект;

КонецФункции

#КонецОбласти