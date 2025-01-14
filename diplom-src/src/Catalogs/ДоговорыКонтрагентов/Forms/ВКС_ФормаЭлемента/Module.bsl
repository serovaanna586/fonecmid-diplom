
#Область ОбработчикиСобытийФормы
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Элементы.Найти("АбоненскаяПлата") = Неопределено Тогда
		НовыйЭлемент = Элементы.Добавить("АбоненскаяПлата", Тип("ПолеФормы"));		
		НовыйЭлемент.ПутьКДанным = "Объект.ВКМ_АбоненскаяПлата";
		НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
		НовыйЭлемент.Заголовок = "Абоненская плата";
	КонецЕсли;
		
	Если Элементы.Найти("СтоимостьЧасаРаботы") = Неопределено Тогда
		НовыйЭлемент = Элементы.Добавить("СтоимостьЧасаРаботы", Тип("ПолеФормы"));		
		НовыйЭлемент.ПутьКДанным = "Объект.ВКМ_СтоимостьЧасаРаботы";
		НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
		НовыйЭлемент.Заголовок = "Стоимость часа работы";
	КонецЕсли;
	
	ГруппаПериод = Элементы.Добавить("ГруппаПериод", Тип("ГруппаФормы"),ЭтотОбъект);
	ГруппаПериод.Вид = ВидГруппыФормы.ОбычнаяГруппа;
	ГруппаПериод.Группировка = ГруппировкаПодчиненныхЭлементовФормы.ГоризонтальнаяВсегда;
	ГруппаПериод.ОтображатьЗаголовок = Ложь;
	ГруппаПериод.Отображение = ОтображениеОбычнойГруппы.Нет;

		
	Если Элементы.Найти("ПериодС") = Неопределено Тогда
		НовыйЭлемент = Элементы.Добавить("ПериодС", Тип("ПолеФормы"), ГруппаПериод);		
		НовыйЭлемент.ПутьКДанным = "Объект.ВКМ_ПериодС";
		НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
		НовыйЭлемент.Заголовок = "Период с";
	КонецЕсли;
		
	Если Элементы.Найти("По") = Неопределено Тогда
		НовыйЭлемент = Элементы.Добавить("По", Тип("ПолеФормы"), ГруппаПериод);		
		НовыйЭлемент.ПутьКДанным = "Объект.ВКМ_По";
		НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
		НовыйЭлемент.Заголовок = "По";
	КонецЕсли;
	
	Элементы.ВидДоговора.УстановитьДействие("ПриИзменении", "ВидДоговораПриИзменении");
	
	ВывестиЭлементыНаФорму(ЭтотОбъект);
	
КонецПроцедуры
#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВидДоговораПриИзменении(Элемент)
	
	ВывестиЭлементыНаФорму(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ВывестиЭлементыНаФорму(Форма)

 Если Форма.Объект.ВидДоговора = ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.ВКМ_АбоненскоеОбслуживание") Тогда
	
	   Форма.Элементы.СтоимостьЧасаРаботы.Видимость = Истина;
	   Форма.Элементы.АбоненскаяПлата.Видимость = Истина;
	   Форма.Элементы.ПериодС.Видимость = Истина;
	   Форма.Элементы.По.Видимость = Истина;
	   
 Иначе
 	
 	 Форма.Элементы.СтоимостьЧасаРаботы.Видимость = Ложь;
	 Форма.Элементы.АбоненскаяПлата.Видимость = Ложь;
	 Форма.Элементы.ПериодС.Видимость = Ложь;
	 Форма.Элементы.По.Видимость = Ложь;
	 
 КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

