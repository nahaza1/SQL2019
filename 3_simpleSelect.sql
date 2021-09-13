-- 1. Напишите один запрос с использованием псевдонимов для таблиц и их полей, 
--    выбирающий все возможные комбинации городов (CITY) из таблиц 
--    STUDENTS, LECTURERS и UNIVERSITIES


-- 2. Напишите запрос для вывода полей в следущем порядке: семестр, в котором он
--    читается, идентификатора (номера ID) предмета обучения, его наименования и 
--    количества отводимых на этот предмет часов для всех строк таблицы SUBJECTS

SELECT
		ID
		, name
		, hours
FROM SUBJECTS;

-- 3. Выведите все строки таблицы EXAM_MARKS, в которых предмет обучения SUBJ_ID равен 4

SELECT *
FROM EXAM_MARKS
WHERE SUBJ_ID=4;


-- 4. Необходимо выбирать все данные, в следующем порядке 
--    Стипендия, Курс, Фамилия, Имя  из таблицы STUDENTS, причем интересуют
--    студенты, родившиеся после '1993-07-21'

SELECT 
		stipend
		,course
		,surname
		,name
FROM students
WHERE BIRTHDAY>1993-07-21;

SELECT 
	STIPEND
	,COURSE
	,SURNAME
	,NAME
	,BIRTHDAY
FROM STUDENTS 
	WHERE BIRTHDAY > '1993-07-21'   --Опасно!
	WHERE BIRTHDAY > 1993-07-21		--Число!
	WHERE BIRTHDAY > '19930721'		--Правильно!

--!! Дата всегда записывается ввиде строкового литерала: '1993-07-21' а не просто 1993-07-21, эту запись сервер воспримет как арифметическое выражение.

-- 5. Вывести на экран все предметы: их наименования и кол-во часов для каждого из них
--    в 1-м семестре и при этом кол-во часов не должно превышать 40

SELECT
		name
		,hours
FROM subjects
WHERE semester=1 and hours<=40;


-- 6. Напишите запрос, позволяющий получить из таблицы EXAM_MARKS уникальные 
--    значения экзаменационных оценок всех студентов, которые сдавали
--    экзамены '2012-06-11'

SELECT distinct mark
FROM exam_marks 
WHERE CONVERT(nvarchar, exam_date,23) like '2012-06-11';

-- вариант, зная что время у всех 00:00:00.000
SELECT distinct mark
FROM exam_marks
WHERE EXAM_Date = '2012-06-11 00:00:00.000';

--!! Правильно, но можно проще: exam_date = '20120611'

-- 7. Выведите список фамилий студентов, обучающихся на третьем и последующих 
--    курсах, а также проживающих не в Киеве, не Харькове и не Львове.

SELECT surname,city
FROM students
WHERE COURSE>=3 
		and city  <> 'Киев'
		and city  <> 'Харьков'
		and city  <> 'Львов';
		
SELECT 
	SURNAME
	,CITY
	,COURSE
FROM STUDENTS
WHERE COURSE >= 3 AND CITY NOT IN ('КИЕВ', 'ХАРЬКОВ', 'ЛЬВОВ')


-- 8. Покажите данные о фамилии, имени и номере курса для студентов, 
--    получающих стипендию в диапазоне от 400 до 650, не включая 
--    эти граничные суммы. Приведите несколько вариантов решения этой задачи.

SELECT
		surname
		,name
		,course
FROM students
WHERE stipend between 400.01 and 649.99;
--!! А что будет, стипендия у студента  400.001?

SELECT
		surname
		,name
		,course
FROM students
WHERE stipend > 400 and stipend < 650;

SELECT
		surname
		,name
		,course
FROM students
WHERE stipend between 400 and 650 
		and stipend not in (400, 650);


-- 9. Напишите запрос, выполняющий выборку из таблицы LECTURERS всех фамилий
--    преподавателей, проживающих во Львове, либо же преподающих в университете
--    с идентификатором 14

SELECT surname
FROM lecturers
WHERE city='Львов'
	or univ_ID=14;


-- 10. Выясните в каких городах расположены университеты, рейтинг которых 
--     состовляет 500 +/- 50 баллов.

SELECT city, rating
FROM universities
WHERE rating between 500-50 and 500+50;


-- 11. Отобрать список фамилий киевских студентов, их имен и дат рождений 
--     для всех нечетных курсов.

SELECT 
		surname
		,name
		,birthday
FROM students
WHERE not course % 2=0 and city='Киев';

SELECT 
		surname
		,name
		,birthday
FROM students
WHERE course % 2=1 and city='Киев';

-- 12. Дайте логическую формулировку запроса? 
-- SELECT * FROM STUDENTS WHERE (STIPEND < 500 OR NOT (BIRTHDAY >= '1993-01-01' AND ID > 9))
Выбрать с таблицы Студенты все данные по студентам, у которых стипендия менше 500, 
либо которые родились не позже 31 декабря 1992 г. и ID  меньше 9 


-- 12. Дайте логическую формулировку запроса? 
-- SELECT * FROM STUDENTS WHERE (STIPEND < 500 OR NOT (BIRTHDAY >= '1993-01-01' AND ID > 9))

SELECT * FROM STUDENTS 
WHERE (STIPEND < 500 OR (NOT(BIRTHDAY >= '1993-01-01') OR NOT(ID > 9)))
	
SELECT * FROM STUDENTS 
WHERE (STIPEND < 500 OR ((BIRTHDAY < '1993-01-01') OR (ID <= 9)))

SELECT * FROM STUDENTS 
WHERE STIPEND < 500 OR BIRTHDAY < '1993-01-01' OR ID <= 9


--!! Есть неточности, нужно было упростить условие фильтрации. Разберем эту задачу в сб.

-- 13. Дайте логическую формулировку запроса? 
-- SELECT * FROM STUDENTS WHERE NOT ((BIRTHDAY = '1993-06-07' OR STIPEND > 500) AND ID >= 9)
Выбрать с таблицы Студенты все данные по всем студентам, 
которые родились не 07.06.1993 или стипендия ниже 500, 
и ID которых не превышает 8 (--зная, что шаг у ID=1)

--!! Есть неточности, нужно было упростить условие фильтрации. Разберем эту задачу в сб.

SELECT * FROM STUDENTS 
WHERE NOT ((BIRTHDAY = '1993-06-07' OR STIPEND > 500) AND ID >= 9)

SELECT * FROM STUDENTS 
WHERE (NOT(BIRTHDAY = '1993-06-07' OR STIPEND > 500) OR NOT (ID >= 9))

SELECT * FROM STUDENTS 
WHERE ((NOT(BIRTHDAY = '1993-06-07') AND NOT(STIPEND > 500)) OR (ID < 9))

SELECT * FROM STUDENTS 
WHERE (((BIRTHDAY <> '1993-06-07') AND (STIPEND <= 500)) OR (ID < 9))

SELECT * FROM STUDENTS 
WHERE BIRTHDAY <> '1993-06-07' AND STIPEND <= 500 OR ID < 9
