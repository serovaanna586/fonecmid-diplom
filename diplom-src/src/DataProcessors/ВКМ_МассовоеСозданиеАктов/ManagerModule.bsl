Функция СозданныеАкты(Параметры) Экспорт 
	 
Запрос = Новый Запрос;
Запрос.Текст = "ВЫБРАТЬ
               |	РеализацияТоваровУслуг.Договор КАК Договор,
               |	РеализацияТоваровУслуг.Контрагент КАК Контрагент,
               |	РеализацияТоваровУслуг.Организация КАК Организация
               |ПОМЕСТИТЬ ВТ_СозданныеДокументы
               |ИЗ
               |	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
               |		ПО РеализацияТоваровУслуг.Договор = ДоговорыКонтрагентов.Ссылка
               |			И РеализацияТоваровУслуг.Контрагент = ДоговорыКонтрагентов.Владелец
               |ГДЕ
               |	РеализацияТоваровУслуг.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
               |	И ДоговорыКонтрагентов.ВидДоговора = &ВидДоговора
               |;
               |
               |////////////////////////////////////////////////////////////////////////////////
               |ВЫБРАТЬ
               |	ДоговорыКонтрагентов.Организация КАК Организация,
               |	ДоговорыКонтрагентов.Владелец КАК Контрагент,
               |	ДоговорыКонтрагентов.Ссылка КАК Договор
               |ИЗ
               |	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
               |		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_СозданныеДокументы КАК ВТ_СозданныеДокументы
               |		ПО ДоговорыКонтрагентов.Ссылка = ВТ_СозданныеДокументы.Договор
               |ГДЕ
               |	ДоговорыКонтрагентов.ВидДоговора = &ВидДоговора
               |	И ДоговорыКонтрагентов.ВКМ_ПериодС <= &ДатаОкончания
               |	И ДоговорыКонтрагентов.ВКМ_По >= &ДатаОкончания
               |	И НЕ ДоговорыКонтрагентов.Ссылка В
               |				(ВЫБРАТЬ
               |					ВТ_СозданныеДокументы.Договор КАК Договор
               |				ИЗ
               |					ВТ_СозданныеДокументы КАК ВТ_СозданныеДокументы)";

Запрос.УстановитьПараметр("ВидДоговора",Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбоненскоеОбслуживание);
Запрос.УстановитьПараметр("ДатаНачала",НачалоДня(Параметры.Период.ДатаНачала));
Запрос.УстановитьПараметр("ДатаОкончания",НачалоДня(Параметры.Период.ДатаОкончания));
Результат = Новый Массив;

Выборка = Запрос.Выполнить().Выбрать();
	
Пока Выборка.Следующий() Цикл

НовыйДокумент = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
НовыйДокумент.Дата = КонецДня(Параметры.Период.ДатаОкончания);
НовыйДокумент.Договор = Выборка.Договор;
НовыйДокумент.Организация = Выборка.Организация;
НовыйДокумент.Контрагент = Выборка.Контрагент;
НовыйДокумент.Записать();

НовыйДокумент.ВыполнитьАвтозаполнение();	
НовыйДокумент.Услуги.Загрузить(НовыйДокумент.ВыполнитьАвтозаполнение());
НовыйДокумент.ПроверитьЗаполнение();
НовыйДокумент.Записать();

Запись = Новый Структура;
Запись.Вставить("Договор", НовыйДокумент.Договор);
Запись.Вставить("Ссылка", НовыйДокумент.Ссылка);
Результат.Добавить(Запись);

Если НовыйДокумент.ПроверитьЗаполнение() = Истина Тогда
НовыйДокумент.Записать(РежимЗаписиДокумента.Проведение);
КонецЕсли;

КонецЦикла; 

Возврат Результат;

КонецФункции
