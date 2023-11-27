#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

Функция ДобавитьКомандуСоздатьНаОсновании(КомандыСозданияНаОсновании) Экспорт

	Если ПравоДоступа("Добавление", Метаданные.Документы.ОплатаОтПокупателя) Тогда

		КомандаСоздатьНаОсновании = КомандыСозданияНаОсновании.Добавить();
		КомандаСоздатьНаОсновании.Менеджер = Метаданные.Документы.ОплатаОтПокупателя.ПолноеИмя();
		КомандаСоздатьНаОсновании.Представление = ОбщегоНазначения.ПредставлениеОбъекта(
			Метаданные.Документы.ОплатаОтПокупателя);
		КомандаСоздатьНаОсновании.РежимЗаписи = "Проводить";

		Возврат КомандаСоздатьНаОсновании;

	КонецЕсли;

	Возврат Неопределено;

КонецФункции

#КонецОбласти

#КонецЕсли