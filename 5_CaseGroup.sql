-- 1. Проведена реформа образования: стипендия студентам 1, 2 курса увеличена на 20%, 
--    4 и 5 курсов - уменьшена на 10%, 3-курсников оставлена без изменений. 
--    Cоставьте запрос к таблице STUDENTS, выводящиий номера студента, фамилию и 
--    величину “новой” стипендии. Выходные данные упорядочить по убыванию в 
--    алфавитном порядке фамилий студентов, затем по убыванию значения новой 
--    вычисленной стипендии.

select
	id
	,surname
	,case 
		when course in(1,2) then stipend*1.2
		when course in(4,5) then stipend*0.9
		else stipend
	 end as stipend_new
from students
order by surname  desc, stipend desc  --!! stipend - это старое значение стипендии. новое храниться в поле stipend_new

select
	id
	,surname
	,case 
		when course in(1,2) then stipend*1.2
		when course in(4,5) then stipend*0.9
		else stipend
	 end as stipend_new
from students
order by surname  desc, stipend_new desc  --!! stipend - это старое значение стипендии. новое храниться в поле stipend_new

-- 2. Напишите запрос, который по таблице EXAM_MARKS позволяет найти для каждого 
--    студента период времени, который он провел на сессии (в днях), кол-во сданных экзаменов, 
--    а также их максимальные и минимальные оценки. 
--    В выборке дожлен присутствовать идентификатор студента.

select
	student_id
	,datediff(dd, min(EXAM_DATE),max(EXAM_DATE)) as time_length   --!! Почти. Сколько дней студент провел на сессии, если min(EXAM_DATE) и max(EXAM_DATE) совпадают?
	,count(subj_id) as exam_quantity --!! Экзамен сдан, если получена оценка 3 или выше
	,max(mark)as max_mark
	,min(mark) as min_mark
from exam_marks as m
group by student_id

select
	student_id
	,datediff(dd, min(EXAM_DATE),max(EXAM_DATE))+1 as time_length   --!! Почти. Сколько дней студент провел на сессии, если min(EXAM_DATE) и max(EXAM_DATE) совпадают?
	,count(
			case 
				when mark>2 then 1
				else null
			end) as exam_quantity --!! Экзамен сдан, если получена оценка 3 или выше
	,max(mark)as max_mark
	,min(mark) as min_mark
from exam_marks as m
group by student_id



select 
	em.STUDENT_ID
	,max(em.EXAM_DATE) as first_day
	,min(em.EXAM_DATE) as last_day
	,max(em.EXAM_DATE) - min(em.EXAM_DATE) as [last_day - first_day]
	,day(max(em.EXAM_DATE) - min(em.EXAM_DATE))  as [провел на сессии (в днях)]
	,DATEDIFF(dd, min(em.EXAM_DATE), max(em.EXAM_DATE)) + 1  as [провел на сессии (в днях)]
	,DATEDIFF(day, min(em.EXAM_DATE), max(em.EXAM_DATE)) + 1  as [провел на сессии (в днях)]
	,COUNT(*) as [кол-во экзаменов]
	,COUNT( 
		case
			when em.MARK > 2 then 1
			else null
		end
	) as [кол-во сданных экзаменов]
	,max(em.MARK) as [max(em.MARK)]
	,min(em.MARK) as [min(em.MARK)]
from EXAM_MARKS as em
group by em.STUDENT_ID

-- 3. Напишите запрос для таблицы EXAM_MARKS, выдающий даты, для которых средний балл 
--    находиться в диапазоне от 4.22 до 4.77. Формат даты для вывода на экран: 
--    день месяць, например, 05 Jun.

select convert(varchar(6), ed.exam_date, 106) as date_mark 
from 
		(select 
				avg(mark) as avg_m
				,exam_date
		 from exam_marks
		 group by exam_date) as ed
where ed.avg_m between 4.22 and 4.77


select 
	convert(varchar(6), exam_date, 106) as date_mark
from exam_marks
group by exam_date
having avg(mark) between 4.22 and 4.77


select 
	format(exam_date, 'dd MMM', 'en-US') as date_mark
from exam_marks
group by exam_date
having avg(mark) between 4.22 and 4.77


-- 4. Напишите запрос, отображающий список предметов обучения, вычитываемых за самый короткий 
--    промежуток времени, отсортированный в порядке убывания семестров. Поле семестра в 
--    выходных данных должно быть первым, за ним должны следовать наименование и 
--    идентификатор предмета обучения.

select
	semester
	,name
	,id
from subjects
where hours=(select min(hours)
			from subjects)
order by semester desc



-- 5. Напишите запрос с подзапросом для получения данных обо всех положительных оценках(4, 5) Марины 
--    Шуст (предположим, что ее персональный номер неизвестен), идентификаторов предметов и дат 
--    их сдачи. Всегда ли такой запрос будет корректным?

select 
	mark
	,subj_id
	,exam_date
from exam_marks
where 
	student_id=(select id
				from students
				where surname='Шуст' and name='Марина')
	and mark in(4,5)

	-- запрос будет некорректным в случае наличия людей с одинковым именем и фамилией

-- 6. Покажите сумму и среднее значение баллов, также максимальный и минимальный балл всех 
--    студентов для каждой даты сдачи экзаменов, для студентов 5 курса. Результат выведите 
--    в порядке убывания сумм баллов, а дату в формате dd/mm/yyyy.


select
		convert(varchar(10),exam_date,103) as exam_date
		,sum(mark) as 'sum mark'
		,avg(mark) as 'avg mark'
		,max(mark) as 'max mark'
		,min(mark) as 'min mark'
from exam_marks
where student_id in (select id
					from students
					where course=5)
group by exam_date
order by sum(mark) desc
		

select 
	sum (MARK)  as Sum
	, avg (MARK) as Average
	, max (MARK) as Max
	, min (MARK) as Min
	, convert (nvarchar, EXAM_DATE, 103) as Date_Exam
from EXAM_MARKS 
where STUDENT_ID in (
		select ID
		from STUDENTS 
		where COURSE = 5)
group by EXAM_DATE
order by sum (MARK) desc


select 
	sum(em.MARK)
	,avg(em.MARK)
	,min(em.MARK)
	,max(em.MARK)
	,convert (nvarchar, EXAM_DATE, 103) as Date_Exam
from EXAM_MARKS em
where (select course 
		from STUDENTS s
		where s.ID = em.STUDENT_ID) = 5
group by EXAM_DATE
order by sum (MARK) desc


-- 7. Покажите имена всех студентов, имеющих средний балл, по предметам с идентификаторами 
--    1 и 2, который превышает средний общий балл по всем остальным оценкам. 
--    Используйте вложенный подзапрос.


select 
	id
	,surname
	,name
from students as Na		--!! Для алиасов принято выбирать сокращенное название таблицы: s, st, std ...
where Na.id in (select id
				from students as st
				where st.id in (select student_id
								from (select 
											student_id
											,avg(case 
														when subj_id in(1,2) then mark
												 end) as av12
											,avg(case 
														when subj_id>2 then mark
												 end) as av45
									 from exam_marks
									 group by student_id
									 having avg(case 
														when subj_id in(1,2) then mark
												end)
											>avg(case 
														when subj_id>2 then mark
												 end)
											or avg(case 
														when subj_id>2 then mark
												   end) is null
										)  as v
								)
					group by id
					having id in (select student_id 
									from(select student_id
										  from exam_marks
										  where subj_id in (1,2)
										  group by student_id
										   having count (subj_id)=2) as dfg))

--мои шаги

--id студентов, сдававшие 1 и 2 предметы
select student_id
from exam_marks
where subj_id in (1,2)
group by student_id
having count (subj_id)=2

--сводная таблица

select 
		student_id
		,avg(case 
					when subj_id in(1,2) then mark
			end) as av12
		,avg(case 
					when subj_id>2 then mark
			end) as av45
from exam_marks
group by student_id
having 
		avg(case 
				when subj_id in(1,2) then mark
			end)
		>avg(case 
				when subj_id>2 then mark
			 end) 
		or avg(case 
					when subj_id>2 then mark
			   end) is null


--!! Логика правильная, но выборку можно упростить:




--студенты, сдававшие 1 или 2 предметы, ср.бал по которым>ср.бала по другим предметам
select 
	id
	,surname
	,name
from students as st
where st.id in (select student_id	--!! Этот запрос не обязательный, если во вложенном убрать лишние выражения.
				from (select 
							student_id
							,avg(case	--!! Это условие фильтра, по этому эти выражения можно вообще убрать.
									 when subj_id in(1,2) then mark
								 end) as av12
							,avg(case 
									 when subj_id>2 then mark
								 end) as av45
						from exam_marks
						group by student_id
						having avg(case 
										when subj_id in(1,2) then mark
									end)
							   >avg(case 
										when subj_id>2 then mark
									end)
							  or avg(case 
										when subj_id>2 then mark
									 end) is null
						)  as v
					)



--правильный ответ

select s.NAME
from STUDENTS AS s
where (
	select isnull(avg(MARK),0)
	from EXAM_MARKS em
	where em.SUBJ_ID in (1,2) 
	  AND em.STUDENT_ID = S.ID) > 
								( select isnull(avg(MARK), 0)
									from EXAM_MARKS em
									where not(em.SUBJ_ID in (1,2)) 
									AND em.STUDENT_ID = S.ID)





-- 8. Напишите запрос, выполняющий вывод общего суммарного балла, для каждого экзаменованого 
--    студента 1го курса, при условии, что он сдал 2 и больше предметов.

select
student_id
,sum(mark) as sum_mark
from exam_marks
where student_id in (select id
						from students
						where course=1) and mark>2
group by student_id
having count(subj_id)>=2

--если оценка>2, то студент сдал предмет
--неправильный ответ преподавателя
select STUDENT_ID, sum(MARK)
from EXAM_MARKS em
where (select course 
	   from STUDENTS s
	   where s.ID = em.STUDENT_ID) = 1
group by STUDENT_ID
having count(case
				when mark > 2 then 1
				else null
			   end) > 2


-- 9. Напишите запрос к таблице SUBJECTS, выдающий названия всех предметов, средний балл
--    которых превышает средний балл по всем предметам университетов г.Днепропетровска. 
--    Используйте вложенный подзапрос.

select name
from subjects as sj
where sj.id in(
				select subj_id 
				from		(select
							subj_id
							,avg(mark) as avg_mark
							from exam_marks as av_m
							group by subj_id
							having avg(mark)>(select avg(mark) as Davg
											  from exam_marks as e
											  where e.student_id in (select id
																	 from students as s
																	 where s.univ_id in(select id
																						from universities as u
																						where city like 'Днепр'
																						)
																	)
												)
							) 
				 as chupakabra)

--мои шаги

--имена предметов
select name
from subjects

--средний бал по предметам
select
subj_id
,avg(mark) as avg_mark
from exam_marks
group by subj_id

--id предметов, ср.бал>ср.бала по Днепру
select
subj_id
,avg(mark) as avg_mark
from exam_marks as av_m
group by subj_id
having avg(mark)>(select avg(mark) as Davg
				  from exam_marks as e
				  where e.student_id in (select id
										 from students as s
										 where s.univ_id in(select id
															from universities as u
															where city like 'Днепр'
															)
										)
					)

--средний бал по Днепропетровску
select avg(mark) as Davg
from exam_marks as e
where e.student_id in (select id
				from students as s
				where s.univ_id in(select id
									from universities as u
									where city like 'Днепр'))

--студенты, которые учатся в г.Днепр
select id
from students
where univ_id in(select id
				from universities
				where city like 'Днепр')


--еще один правильный вариант

select * 
from SUBJECTS as sub
where (
	select avg(em.MARK)
	from EXAM_MARKS em
	where em.SUBJ_ID = sub.id) > (select avg(MARK)
								  from EXAM_MARKS em
								  where em.STUDENT_ID in (
														select s.ID
														from students s
														where s.UNIV_ID in (
																			select id
																			from UNIVERSITIES
																			where CITY = 'Днепр')))

select avg(MARK)
from EXAM_MARKS em
where em.STUDENT_ID in (
	select s.ID
	from students s
	where s.UNIV_ID in (
		select id
		from UNIVERSITIES
		where CITY = 'Днепр'))