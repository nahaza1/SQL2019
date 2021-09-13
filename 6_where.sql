-- 1. Напишите запрос с EXISTS, позволяющий вывести данные обо всех студентах, 
--    обучающихся в вузах с рейтингом не попадающим в диапазон от 488 до 571

select *
from students as st
where not exists (select id
							from universities as un
							where rating between 488 and 571
							and st.univ_id=un.id) and (st.univ_id is not null)


-- вариант препода

select *
from STUDENTS as s
where exists (select *
			  from UNIVERSITIES
			  where (RATING  < 488 or RATING > 571) 
                and ID = s.UNIV_ID)
				
select *,
	(select RATING FROM UNIVERSITIES where ID = s.UNIV_ID)
from STUDENTS as s
where not exists (select *
				  from UNIVERSITIES
				  where RATING between 488 and 571 
				    and ID = s.UNIV_ID) 
  and UNIV_ID is not null
				

-- 2. Напишите запрос с EXISTS, выбирающий всех студентов, для которых в том же городе, 
--    где живет студент, существуют университеты, в которых он не учится.


select *
from students as st
where exists (select un.id
				from universities as un
				where st.city=un.city and st.univ_id<>un.id)


--вариант препода
select  *
		,(select STRING_AGG(CITY, ', ') from UNIVERSITIES where s.CITY = CITY  and (ID <> s.UNIV_ID or s.UNIV_ID is null))
		,(select CITY from UNIVERSITIES where ID = s.UNIV_ID)
from STUDENTS as s
where exists ( select 1																		   --!! У нас есть студент, который не учиться ни в одном университете и при этом он из Ровно
			   from UNIVERSITIES as un															--!! Если бы у нас в базе были универы в Ровно, то этот студент дожен был бы попасть в выборку
			   where s.CITY = un.CITY  and (un.ID <> s.UNIV_ID or s.UNIV_ID is null))				

select * from UNIVERSITIES

-- 3. Напишите запрос, выбирающий из таблицы SUBJECTS данные о названиях предметов обучения, 
--    экзамены по которым сданы более чем 20 студентами. Используйте EXISTS.

select name
from subjects as su
where exists (select subj_id				--!! Вместо списка полей можно просто написать 1 или поле по которому группируем.
			  ,count(case 
						 when mark>2 then 1 
						 else 0
					 end) as 'к-во студентов'
				from exam_marks as em
				where su.id=em.subj_id
				group by subj_id
				having count(case when mark>2 then 1 else 0 end)>20    --!! А почему 0? Разве count считает по разному 0 и 1? 
			  )


select name
from subjects as su
where exists (select subj_id, count(student_id)				
			  from exam_marks as em
			  where su.id=em.subj_id and mark>2
			  group by subj_id
			  having count(student_id)>20)

-- вариант препода				
select name
from SUBJECTS as sb
where exists (  select 1
				from EXAM_MARKS
				where MARK > 2 and SUBJ_ID = sb.ID 
				having count(MARK) > 20 )
		

-- 4. Напишите запрос EXISTS, выбирающий фамилии всех лекторов, преподающих в университетах
--    с рейтингом, превосходящим рейтинг любого харьковского универа.

select *
from lecturers as le
where exists (select *
				from universities as un
				where le.univ_id=un.id and rating>any(select rating
														from universities
														where city='Харьков'))


-- 5. Напишите 2 запроса, использующий ANY и ALL, выполняющий выборку данных о студентах, 
--    у которых в городе их постоянного местожительства нет университета.


select *
from students as st
where st.city=any(select st.city from students as st 
					except 
				  select city from universities)


select *
from students as st
where st.city<>all(select st.city from students as st 
					intersect 
				  select city from universities)


--вариант препода

select *
from STUDENTS as s
where s.CITY <> ALL (select CITY from UNIVERSITIES u )


select *
from STUDENTS as s
where not(s.CITY = ANY (select CITY from UNIVERSITIES u ))

select *
from STUDENTS as s
where 2 = ALL (select 1 from UNIVERSITIES u where u.CITY = s.CITY)   -- на пустой выборке ALL всегда True select * from STUDENTS as s where 1 =all (select 1  where 1=0)


select *
from STUDENTS as s
where CITY = ANY (
				select city
				from STUDENTS 
				where  not exists ( select 1
									from UNIVERSITIES
									where city = s.city) 
									)

select *
from STUDENTS as s
where CITY <> ALL (
					select city
					from STUDENTS 
					where  exists (select 1
									from UNIVERSITIES
									where city = s.city) 
									)


-- 6. Напишите запрос выдающий имена и фамилии студентов, которые получили
--    максимальные оценки в первый и последний день сессии.
--    Подсказка: выборка должна содержать по крайне мере 2х студентов.

select id, name, surname
from students
where id in (select sma1.student_id 
			from (select student_id, max (mark) as max_mark
			      from exam_marks m1							
			      group by student_id							
			      having max (mark) in (select mark				-- Этот запрос с подзапросами вернет все оценки за первый и последний день сессии.
									   from exam_marks m2       -- having max() in () проверит максимальная оценка студента поподает ли в этом списке, это не то что нужно. См. ниже.
									   where exam_date in (select min(exam_date) from exam_marks 
														   union
														   select max(exam_date) from exam_marks
														   ) 
													 and m1.student_id=m2.student_id
									   )
				 ) sma1
			 )



-- Для начала лучше решить задачу только для первого дня сессии.
-- И нужно наоборот, найти максимальную оценку за первый день сессии и посмотреть кто из студентов ее получил и получил в этот же день сессии!

select id, name, surname
from students
where id in (select student_id
			from exam_marks em
			where mark=(select max(mark)
						from exam_marks
						where exam_date in (select min(exam_date)
											from exam_marks)) and exam_date in (select min(exam_date) as min_date
											from exam_marks)

			union

			select student_id
			from exam_marks em
			where mark=(select max(mark)
						from exam_marks
						where exam_date in (select max(exam_date)
											from exam_marks)) and exam_date in (select max(exam_date) as min_date
											from exam_marks))


--вариант препода

select NAME
	   ,Surname
from STUDENTS as s 
where ID in (select STUDENT_ID
 			 from EXAM_MARKS em
 			 where EXAM_DATE >= ALL (select EXAM_DATE from EXAM_MARKS) and MARK >= ALL (select MARK from EXAM_MARKS eem where eem.EXAM_DATE = em.EXAM_DATE)
     			or EXAM_DATE <= ALL (select EXAM_DATE from EXAM_MARKS) and MARK >= ALL (select MARK from EXAM_MARKS eem where eem.EXAM_DATE = em.EXAM_DATE)	)

select NAME
	   , Surname
from STUDENTS as s
where   (select MARK 
         from EXAM_MARKS 
		   where s.id=STUDENT_ID and 
		       EXAM_DATE = ( select min(EXAM_DATE) 
			                  from EXAM_MARKS)) = (select max( MARK) 
												   from EXAM_MARKS
 												   where EXAM_DATE = ( select min(EXAM_DATE) 
												                        from EXAM_MARKS))
				or
		 (select MARK 
          from EXAM_MARKS 
		  where s.id=STUDENT_ID and 
		        EXAM_DATE = (select max(EXAM_DATE) 
				              from EXAM_MARKS)) = (select max( MARK) 
												   from EXAM_MARKS
 												   where EXAM_DATE = (select max(EXAM_DATE) 
												                       from EXAM_MARKS))
		

SELECT st.ID
    , st.SURNAME
    , st.NAME 
FROM STUDENTS st
WHERE EXISTS(SELECT * 
             FROM EXAM_MARKS em 
             WHERE (MARK = (SELECT MAX(MARK) 
                            FROM EXAM_MARKS
                            WHERE EXAM_DATE = (SELECT
                                               MAX(EXAM_DATE)
                                               FROM EXAM_MARKS))
               AND EXAM_DATE = (SELECT MAX(EXAM_DATE)
                                FROM EXAM_MARKS))
			   AND st.ID=em.STUDENT_ID)

UNION ALL

SELECT 
    st.ID
    , st.SURNAME
    , st.NAME 
FROM STUDENTS st
WHERE EXISTS(SELECT * 
             FROM EXAM_MARKS em 
             WHERE MARK = (SELECT
                           MAX(MARK) 
                           FROM EXAM_MARKS
						   WHERE EXAM_DATE = (SELECT
                                              MIN(EXAM_DATE)
                                              FROM EXAM_MARKS)) 
             AND EXAM_DATE = (SELECT 
                              MIN(EXAM_DATE) 
                              FROM EXAM_MARKS) 
             AND st.ID=em.STUDENT_ID);

-- 7. Напишите запрос EXISTS, который выполняет вывод данных об кол-ве успешно 
--    сдававших экзамены (без двоек) студентов для каждого курса.

select   course
		,count(id) [количество студентов] 
from STUDENTS s 
where not exists (select student_id    
					from EXAM_MARKS    
					where s.id = student_id and mark = 2) and exists (select student_id    
					from EXAM_MARKS    
					where s.id = student_id and mark >2) 
group by course;


-- вариант препода
select COURSE 
	   , COUNT (ID) as 'Кол-во студентов'
	   , STRING_AGG(cast(ID as varchar), ' ,')
from STUDENTS as s
where exists(select * from EXAM_MARKS em where s.ID = em.STUDENT_ID having min(MARK) <> 2)
group by COURSE


select COURSE 
	   , COUNT (ID) as 'Кол-во студентов' 
from STUDENTS as s
where exists  (select 1
			     from EXAM_MARKS as em
			     where s.id = STUDENT_ID and not exists(select 1 from EXAM_MARKS where mark =2 and s.id = STUDENT_ID))
group by COURSE

					 					 									  
select COURSE 
	   , COUNT (ID) as 'Кол-во студентов' , STRING_AGG(ID, ', ')
from STUDENTS as s
where exists  (select 1
			     from EXAM_MARKS as em
			     where s.id = STUDENT_ID and STUDENT_ID not in (select STUDENT_ID 
			 												    from EXAM_MARKS 
															    where mark = 2))
group by COURSE


select COURSE 
	   , COUNT (ID) as 'Кол-во студентов' 
	   , STRING_AGG(ID, ', ')
from STUDENTS as s
where not exists ( select 1
			       from EXAM_MARKS as em
			       where s.id = STUDENT_ID and mark = 2 )
  and exists(select 1
			 from EXAM_MARKS as em
			 where s.id = STUDENT_ID)
group by COURSE
			  

-- 8. Напишите запрос EXISTS на выдачу названий предметов обучения, 
--    по которым было получено максимальное кол-во оценок.


select name
from subjects s
where exists (select subj_id 
			  from (select top 1 count(mark) as mquant, subj_id			--!! Правильный вариант. Но нужно было использовать >ALL(...) . В этот раз повезло, что максимальное количество получено по одному предмету.
                    from exam_marks
                    group by subj_id
                    order by mquant desc) m1
			  where s.id=m1.subj_id)

---без exists и top 3
select name
from subjects
where id in (select subj_id 
			 from (select top 3 count(mark) as mquant, subj_id
				  from exam_marks
				  group by SUBJ_ID
				  order by mquant desc) m1)

-- вариант препода

select NAME
from SUBJECTS as sb
where exists( select * 
              from EXAM_MARKS em
			  where sb.ID = em.SUBJ_ID
			  having count(*) >= ALL (select count(MARK) c 
									  from EXAM_MARKS
									  group by SUBJ_ID))


select 
	NAME
from SUBJECTS as S
where exists (  select 1
				from EXAM_MARKS as em 
				where S.ID = em.SUBJ_ID 
				having count(*) = ( select top 1 count(*) as CNT
									from EXAM_MARKS 
									group by SUBJ_ID
									order by CNT desc))
	

select NAME
from SUBJECTS as sb
where exists(
	 select * from EXAM_MARKS em
	 where sb.ID = em.SUBJ_ID
	having count(*) >=  (select max(c) --!! Без ALL
						 from ( select count(MARK) as c 
								from EXAM_MARKS
								group by SUBJ_ID) as t1)
	)


-- 9. Напишите команду, которая выдает список фамилий студентов по алфавиту, 
--     с колонкой комментарием: 'успевает' у студентов , имеющих все положительные оценки, 
--     'не успевает' для сдававших экзамены, но имеющих хотя бы одну 
--     неудовлетворительную оценку, и комментарием 'не сдавал' – для всех остальных.

--!! Еще можно с помощью case exists(...) then

select surname, 'не успевает' as 'comment'
from students s
where exists (select student_id
			 from exam_marks m
             where mark=2 and s.id=m.student_id)


union

select surname, 'успевает' as 'comment'
from students s
where exists (select student_id
			 from exam_marks m
             where mark>2 and s.id=m.student_id) 
	 and not exists (select student_id
			        from exam_marks m
                    where mark=2 and s.id=m.student_id)

union

select surname, 'не сдавал' as 'comment'
from students s
where s.id not in (select student_id from exam_marks)
order by surname


--!! Еще можно с помощью case exists(...) then 

select surname, case 
					when exists (select student_id
								 from exam_marks m
								 where mark=2 and s.id=m.student_id) then 'не успевает' 
					when exists (select student_id
								 from exam_marks m
								 where mark>2 and s.id=m.student_id) 
						 and not exists (select student_id
										from exam_marks m
										where mark=2 and s.id=m.student_id)	then 'успевает'
					when exists (select student_id
								 from exam_marks m
								 where mark=2 and s.id=m.student_id) then 'не сдавал'
				end as 'comment'
from students s


-- вариант препода
select  SURNAME
		, case
			when not exists(select * from EXAM_MARKS em where s.ID = em.STUDENT_ID) then 'не сдавал'
			when not exists(select * from EXAM_MARKS em where em.MARK = 2 and s.ID = em.STUDENT_ID) then 'успевает'
			when exists(select * from EXAM_MARKS em where em.MARK = 2 and s.ID = em.STUDENT_ID) then 'не успевает'			
		  end
from STUDENTS as s
order by SURNAME




select  SURNAME
		, 'успевает' as COMMENT
from STUDENTS as s
where id not in (select STUDENT_ID
			 	 from EXAM_MARKS
				 where MARK = 2) and exists (select 1
											 from EXAM_MARKS
											 where STUDENT_ID = s.ID)

union

select SURNAME
	   ,' не успевает' as COMMENT
from STUDENTS
where id in (select STUDENT_ID
  		     from EXAM_MARKS
			 where MARK = 2)

union
										
select SURNAME
	   , 'не сдавал' as COMMENT
from STUDENTS as s
where not exists (  select 1
					from EXAM_MARKS
					where STUDENT_ID = s.ID)

order by SURNAME

-- 10. Создайте объединение двух запросов, которые выдают значения полей 
--     NAME, CITY, RATING для всех университетов. Те из них, у которых рейтинг 
--     равен или выше 500, должны иметь комментарий 'Высокий', все остальные – 'Низкий'.

select 
		name
		, city
		, rating
		, 'высокий' as 'comment'
from universities
where rating>=500

union

select 
		name
		, city
		, rating
		, 'низкий' as 'comment'
from universities
where rating<500

--или 

select 
		name
		, city
		, rating
		, 'высокий' as 'comment'
from universities
where rating>=500

union

select 
		name
		, city
		, rating
		, 'низкий' as 'comment'
from universities
where rating<500 or rating is null


--вариант препода

select NAME
	   , CITY
	   , RATING
	   ,'Высокий' as 'Рейтинг'
from UNIVERSITIES
where RATING >= 500

union

select NAME
	   , CITY
	   , RATING
	   ,'Низкий' as 'Рейтинг'
from UNIVERSITIES
where RATING < 500

-- 11. Напишите UNION запрос на выдачу списка фамилий студентов 4-5 курсов в виде 3х полей выборки:
--     SURNAME, 'студент <значение поля COURSE> курса', STIPEND
--     включив в список преподавателей в виде
--     SURNAME, 'преподаватель из <значение поля CITY>', <значение зарплаты в зависимости от города (придумать самим)>
--     отсортировать по фамилии
--     Примечание: достаточно учесть 4-5 городов.


select surname
       , concat('студент ', isnull(cast(course as varchar), 'no info'), ' курса') as information
	   , stipend as income 
from students

union

select surname
       , concat('преподаватель из г.', isnull(city, 'no info')) as information
	   , case when city in ('Киев', 'Харьков', 'Днепр', 'Львов') then 35000
			  when city in ('Херсон', 'Полтава', 'Чернигов') then 28000
			  else 25000 
		  end as 'income'
from lecturers

--вариант препода
select SURNAME
		, ' студент '+ CAST(COURSE AS VARCHAR)+' курса' as INFO
		, STIPEND
from STUDENTS
where course in (4,5)

union

select SURNAME
	   , ' преподаватель из города '+ CAST(CITY AS VARCHAR)
	   , case CITY
			when 'Львов' then 30000
			when 'Киев' then 50000
			when 'Харьков' then 34000
			when 'Винница' then 20000
			when 'Днепр' then 27000
			else 100500
		 end 
from LECTURERS
order by SURNAME


