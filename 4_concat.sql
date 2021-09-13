-- Внимание! Во всех результирующих выборках не должно быть NULL записей
-- Для этого используйте либо CASE, либо функцию ISNULL(<выражение>, <значение по умолчанию>)
-- Соблюдать это условие достаточно для двух полей BIRTHDAY и UNIV_ID.

-- 1. Составьте запрос для таблицы STUDENT таким образом, чтобы выходная таблица 
--    содержала один столбец типа varchar, содержащий последовательность разделенных 
--    символом ';' (точка с запятой) значений всех столбцов этой таблицы, и при этом 
--    текстовые значения должны отображаться прописными символами (верхний регистр), 
--    то есть быть представленными в следующем виде: 
--    1;КАБАНОВ;ВИТАЛИЙ;4;ХАРЬКОВ;1/12/1990;2.
--    примечание: в выборку должны попасть студенты из любого города, 
--    состоящего из 5 символов

select
	cast(cast(id as varchar) + ';'
	+ upper(surname) + ';'
	+ upper(name) + ';'
	+ cast(course as char (1)) + ';'
	+ upper(city) + ';'
	+ isnull (convert(varchar (12), birthday, 103), 'who knows') + ';'
	+ isnull (convert(varchar(9), univ_id), 'who knows')
	+ '.'as varchar (max))
	as full_info
from students
where city like '_____'

--!! Как будет выглядить условие, если имя города будет состоять из 30 символов? Лучше испольовать LEN()

select
	cast(cast(id as varchar) + ';'
	+ upper(surname) + ';'
	+ upper(name) + ';'
	+ cast(course as char (1)) + ';'
	+ upper(city) + ';'
	+ isnull (convert(varchar (12), birthday, 103), 'who knows') + ';'
	+ isnull (convert(varchar(9), univ_id), 'who knows')
	+ '.'as varchar (max))
	as full_info
from students
where len(city)=5

SELECT CONCAT(
		ID, ';', 
		UPPER(SURNAME), ';', 
		UPPER(NAME), ';', 
		GENDER, ';', 
		STIPEND, ';', 
		COURSE, ';', 
		UPPER(CITY), ';',
		ISNULL(CONVERT(VARCHAR(12),BIRTHDAY,101), 'НЕТ ДАННЫХ'), ';',
		ISNULL(CAST(UNIV_ID AS VARCHAR),'НЕТ ДАННЫХ')) AS FUL_INFO,
		CAST(ISNULL(UNIV_ID, 'НЕТ ДАННЫХ') AS VARCHAR)        -- Ошибка, столбец должен содержать данные одного типа!
FROM STUDENTS	
WHERE LEN(CITY)=5
WHERE CITY like '_____'   -- Не универсально!

SELECT UPPER(CONCAT(
			ID, ';', 
			SURNAME, ';', 
			NAME, ';', 
			GENDER, ';', 
			STIPEND, ';', 
			COURSE, ';', 
			CITY, ';',
			ISNULL(CONVERT(VARCHAR(12), BIRTHDAY, 101), 'НЕТ ДАННЫХ'), ';',
			ISNULL(CAST(UNIV_ID AS VARCHAR), 'НЕТ ДАННЫХ')
		)) AS FUL_INFO
FROM STUDENTS	
WHERE LEN(CITY)=5


-- 2. Составьте запрос для таблицы STUDENT таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде: 
--    В.КАБАНОВ;местожительства-ХАРЬКОВ;родился-01.12.90
--    примечание: в выборку должны попасть студенты, фамилия которых содержит вторую
--    букву 'а'

select 
	left(upper(s.name),1) + '.'
	+ upper(s.surname) + ';'
	+ 'местожительства-' + upper(s.city)+ ';'
	+ case s.gender
			when 'm' then 'родился-'
			when 'f' then 'родилась-'
		end
	+ isnull (convert(varchar (12), s.birthday, 104), 'who knows')
as birth_info
from (select *  --!! Зачем здесь подзапрос? 
		from students
		where surname like '_а%') as s
 
--!! from students as s
--!! where surname like '_а%'

select 
	left(upper(s.name),1) + '.'
	+ upper(s.surname) + ';'
	+ 'местожительства-' + upper(s.city)+ ';'
	+ case s.gender
			when 'm' then 'родился-'
			when 'f' then 'родилась-'
		end
	+ isnull (convert(varchar (12), s.birthday, 104), 'who knows')
as birth_info
from students as s
where surname like '_а%'


select
	concat(left(upper(s.name),1) , '.'
	, upper(s.surname) , ';'
	, 'местожительства-' , upper(s.city) , ';'
	, case s.gender
			when 'm' then 'родился-'
			when 'f' then 'родилась-'
		end
	, isnull (convert(varchar (12), s.birthday, 104), 'who knows')
	) as birth_info
from (select *
		from students
		where surname like '_а%') as s

SELECT LEFT(NAME, 1) 
		+ '.' 
		+ UPPER(SURNAME) 
		+ ';местожительства-' 
		+ UPPER(CITY) 
		+ ';родился-'
		+ ISNULL(CONVERT(VARCHAR(8),BIRTHDAY,04),'НЕТ ДАННЫХ') AS INFO
FROM STUDENTS 
WHERE SURNAME LIKE '_а%'

		
-- 3. Составьте запрос для таблицы STUDENT таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде:
--    в.кабанов;местожительства-харьков;учиться на IV курсе
--    примечание: курс указать римскими цифрами


select 
concat(
	left(lower(name),1), '.'
	, lower(surname), ';'
	, 'местожительства-', lower(city), ';'
	, 'учится на '
	, case course
			when '1' then 'I'
			when '2' then 'II'
			when '3' then 'III'
			when '4' then 'IV'
			else 'V'
			end   --!! end сдвинуть под case
	, ' курсе'
	) as study_info
from students

-- 4. Составьте запрос для таблицы STUDENT таким образом, чтобы выборка 
--    содержала столбец в следующего вида:
--    Виталий Кабанов из г.Харьков родился в 1990 году
--    ... и т.д.

select
	concat (
	name, ' '
	, surname, ' '
	, 'из г.'
	, city, ' '
	,case gender
			when 'm' then 'родился в '
			when 'f' then 'родилась в '
		end
	, isnull(convert (varchar (4), birthday, 126), '????')
	,' году') as birth_info
from students


select
	concat (
	name, ' '
	, surname, ' '
	, 'из г.'
	, city, ' '
	, case gender
			when 'm' then 'родился в '
			when 'f' then 'родилась в '
		end
	, coalesce (convert (varchar (4), birthday, 126), 'who knows')
	,' году') as birth_info
from students

-- 5. Вывести фамилии, имена студентов и величину получаемых ими стипендий, 
--    при этом значения стипендий первокурсников должны быть увеличены на 30%.


select
	surname
	,name
	, case 
			when course like '1' then stipend*1.3
			else stipend
			end as new_stipend
from students

-- 6. Вывести наименования всех учебных заведений и их расстояния 
--    (придумать/нагуглить/взять на глаз) до Киева.

select
	name
	,case 
		when city like 'Белая Церковь' then '87' --!! Можно просто = 
		when city like 'Днепр' then '480'
		when city like 'Донецк' then '738'
		when city like 'Запорожье' then '560'
		when city like 'Киев' then '0'
		when city like 'Львов' then '540'
		when city like 'Одесса' then '475'
		when city like 'Тернополь' then '420'
		when city like 'Харьков' then '480'
		when city like 'Херсон' then '550'
	end as Расстояние_до_Киева   --!! Если нужно использовать пробелы берем выражение в скобки или кавычки
from universities

-- 7. Вывести все учебные заведения и их две последние цифры рейтинга.

select
	id
	, name
	, city
	, right (rating, 2) as cut_rating
from universities


-- 8. Составьте запрос для таблицы UNIVERSITY таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде:
--    Код-1;КПИ-г.Киев;Рейтинг относительно ДНТУ(501) +276
--    примечание: рейтинг вычислить относительно ДНТУшного, а также должен 
--    присутствовать знак (+/-)

select
	concat (
	'Код-'
	, id, ';'
	, name
	,'-г.'
	, city, ';'
	, 'Рейтнг относительно ДНТУ(501) '
	, case --!! Для этого оператора возвращаемые значения должны быть одоного типа:
		when rating>501 then concat('+', rating-501) --!! Это строка, ф-я конкат возвращает строку 
		when rating<501 then concat('-', 501-rating) --!! Это строка, ф-я конкат возвращает строку
		else 0  --!! Это число!!!! Должно быть '0'
		end
	) as ДНТУ_rating
from universities

--исправила
select
	concat (
	'Код-'
	, id, ';'
	, name
	,'-г.'
	, city, ';'
	, 'Рейтнг относительно ДНТУ(501) '
	,  case --!! Для этого оператора возвращаемые значения должны быть одоного типа:
		when rating>501 then concat('+', rating-501) --!! Это строка, ф-я конкат возвращает строку 
		when rating<501 then concat('-', 501-rating) --!! Это строка, ф-я конкат возвращает строку
		else '0'  --!! Это число!!!! Должно быть '0'
		end
	) as ДНТУ_rating
from universities


SELECT CONCAT(
			'Код-'
			,ID
			,';'
			,NAME
			,'-г.'
			,CITY
			,';'
			,'Рейтин относительно ДНТУ(501)  '
			,CASE 
				WHEN RATING - 501 > 0 THEN '+'		
				ELSE  ''
			END,
			RATING - 501
		) AS NEW
FROM UNIVERSITIES

-- 9. Составьте запрос для таблицы UNIVERSITY таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде:
--    Код-1;КНУ-г.Киев;Рейтинг состоит из 6 сотен
--    примечание: в рейтинге необходимо указать кол-во сотен

select
	concat (
	'Код-'
	, id, ';'
	, name
	,'-г.'
	, city, ';'
	, 'Рейтинг состоит из '
	, left (rating, 1)  --!! Какой будет рейтинг в сотнях для рейтинга 1200? Должен быть 12 сотен. 
	, case 
		when left(rating, 1)=1 then ' сотни'
		else ' сотен'
	  end
	) as cut_rating
from universities

--!! Здесь нужно делить на 100. rating / 100 = количество сотен, так как rating целое число. 


select
	concat (
	'Код-'
	, id, ';'
	, name
	,'-г.'
	, city, ';'
	, 'Рейтинг состоит из '
	, rating/100  --!! Какой будет рейтинг в сотнях для рейтинга 1200? Должен быть 12 сотен. 
	, case 
		when right(rating, 1)=1 then ' сотни'
		else ' сотен'
		end
	) as cut_rating
from universities