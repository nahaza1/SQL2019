-- 1. Напишите запрос, выдающий список фамилий преподавателей 
--    с названиями университетов, в которых они преподают.
--    Отсортируйте запрос по городу, где расположен университ, а
--    затем по его названию.


select l.surname, u.name
from lecturers as l
cross join universities as u   -- лучше inner join
where l.univ_id=u.id
order by u.city, u.name


-- вариант препода

select l.surname, u.name
from lecturers as l
inner join universities as u on u.ID = l.UNIV_ID
order by u.city, u.name


-- 2. Напишите запрос, который выполняет вывод данных о фамилиях, сдававших экзамены 
--    студентов, вместе с наименованием каждого сданного ими предмета, оценкой и датой сдачи.

select s.surname, su.name, e.mark, e.exam_date
from students s
cross join subjects su
cross join exam_marks e
where s.id=e.student_id and e.subj_id=su.id


--или
select s.surname, su.name, e.mark, e.exam_date
from students s
inner join exam_marks e on s.id=e.student_id
inner join subjects su on e.subj_id=su.id


-- 3. Используя опратор JOIN, выведите объединенный список городов с указанием количества 
--    учащихся в них студентов и преподающих там же преподавателей.


select u.city, s.numberStudents, l.numberLecturers
from universities u
inner join (select univ_id, count(id) as numberStudents			--!! А что будет если написать left join? Есть ли города в которых никто не преподает ИЛИ никто не учиться
			from students
			group by univ_id) s on s.univ_id=u.id
inner join (select univ_id, count(id) as numberLecturers
			from lecturers
			group by univ_id) l on l.univ_id=u.id

select u.city, s.numberStudents, l.numberLecturers
from universities u
left join (select univ_id, count(id) as numberStudents			--!! А что будет если написать left join? Есть ли города в которых никто не преподает ИЛИ никто не учиться
			from students
			group by univ_id) s on s.univ_id=u.id
left join (select univ_id, count(id) as numberLecturers
			from lecturers
			group by univ_id) l on l.univ_id=u.id

-- вариант препода

select un.city, count (distinct (st.ID)), count(distinct(lec.ID))
from universities as un
left join students as st on st.UNIV_ID = un.ID
left join lecturers as lec on lec.UNIV_ID = un.ID
group by un.CITY

-- 4. Напишите запрос который выдает фамилии всех преподавателей и наименование предметов,
--    которые они читают в КПИ


select l.surname, u.name as univ_name, su.name as subj_name
from lecturers l
inner join universities u on l.univ_id=u.id and u.name='КПИ'
inner join subj_lect sl on l.id=sl.lecturer_id
inner join subjects su on su.id=sl.subj_id

-- вариант препода

select lec.surname, su.name
from lecturers as lec
inner join universities as un on lec.univ_id=un.id
inner join subj_lect as sl on lec.id=sl.lecturer_id
inner join subjects as su on su.id=sl.subj_id
where un.name='КПИ'


-- 5. Покажите всех студентов-двоешников, кто получил только неудовлетворительные оценки (2) 
--    и по каким предметам, а также тех кто не сдал ни одного экзамена. 
--    В выходных данных должны быть приведены фамилии студентов, названия предметов и 
--    оценка, если оценки нет, заменить ее на прочерк.

select s.id, s.surname, isnull(su.name, '---') as subj_name, isnull (cast(em.mark as varchar),'---') as mark
from students s
left outer join exam_marks em on s.id=em.student_id 
left outer join subjects su on su.id=em.subj_id
where s.id not in (select student_id								-- этот подзапрос можно заменить более простым условием
				   from exam_marks) 
	  or em.mark=2 and s.id not in (select student_id 
									from exam_marks 
									where mark>2)


select s.id, s.surname, isnull(su.name, '---') as subj_name, isnull (cast(em.mark as varchar),'---') as mark
from students s
left outer join exam_marks em on s.id=em.student_id 
left outer join subjects su on su.id=em.subj_id
where mark is null													-- этот подзапрос можно заменить более простым условием
	  or em.mark=2 and s.id not in (select student_id 
									from exam_marks 
									where mark>2)


-- вариант препода

select st.ID
from STUDENTS as st
left join EXAM_MARKS as em on em.STUDENT_ID = st.ID
left join SUBJECTS as sb on sb.ID = em.SUBJ_ID
group by st.ID
having max(mark) = 2 
    or count(mark) = 0


select *
from STUDENTS as st
left join EXAM_MARKS as em on em.STUDENT_ID = st.ID
left join SUBJECTS as sb on sb.ID = em.SUBJ_ID
where em.ID is null 
   or exists (select 1
			  from EXAM_MARKS as em
			  where em.STUDENT_ID = st.ID
			  having max(em.MARK) = 2)

-- 6. Напишите запрос, который выполняет вывод списка университетов с рейтингом, 
--    превышающим 490, вместе со значением максимального размера стипендии, 
--    получаемой студентами в этих университетах.

select u.*, s.max_stipend
from universities u
cross join (select max(stipend) as max_stipend, univ_id   -- Лучше inner join
			from students
			group by univ_id) s
where u.id=s.univ_id and u.rating>490


-- вариант препода

select un.ID, un.NAME, un.RATING, isnull(max(st.STIPEND), 0)
from universities as un
left join STUDENTS as st on st.UNIV_ID = un.ID
where un.rating > 490
group by un.ID, un.NAME, un.RATING

-- 7. Расчитать средний бал по оценкам студентов для каждого университета, 
--    умноженный на 100, округленный до целого, и вычислить разницу с текущим значением
--    рейтинга университета.


select u.*, t1.mark100-rating as markVSrate
from universities u
left outer join (select s.univ_id, cast(round(avg(em.mark)*100, -1) as int) as mark100
				 from students s
				 cross join exam_marks em 
				 where em.student_id=s.id
				 group by s.univ_id) t1 on u.id=t1.univ_id


--или

select u.*, isnull(t1.mark100-rating, 999999) as markVSrate
from universities u
left outer join (select s.univ_id, cast(round(avg(em.mark)*100, -1) as int) as mark100
				 from students s
				 cross join exam_marks em 
				 where em.student_id=s.id
				 group by s.univ_id) t1 on u.id=t1.univ_id

--или

select u.*, isnull(cast(t1.mark100-rating as varchar), '---') as markVSrate
from universities u
left outer join (select s.univ_id, cast(round(avg(em.mark)*100, -1) as int) as mark100
				 from students s
				 cross join exam_marks em 
				 where em.student_id=s.id
				 group by s.univ_id) t1 on u.id=t1.univ_id

-- вариант препода

select un.ID, avg(em.MARK) * 100, isnull(round(avg(em.MARK) * 100, 0), 0) - un.RATING
from universities as un
left join STUDENTS as st on st.UNIV_ID = un.ID
left join EXAM_MARKS as em on em.STUDENT_ID = st.ID
group by un.ID, un.RATING

-- 8. Написать запрос, выдающий список всех фамилий лекторов из Киева попарно. 
--    При этом не включать в список комбинации фамилий самих с собой,
--    то есть комбинацию типа "Иванов-Иванов", а также комбинации фамилий, 
--    отличающиеся порядком следования, т.е. включать лишь одну из двух 
--    комбинаций типа "Иванов-Петров" или "Петров-Иванов".


select l1.surname as first, l2.surname as second
from lecturers l1
cross join (select id, surname
			from lecturers) l2
where l1.surname<>l2.surname and l1.id>l2.id   -- "...лекторов из Киева попарно.", нужно добавить еще одно условие.


select l1.surname as first, l2.surname as second
from lecturers l1
cross join (select id, surname, city
			from lecturers
			where city='Киев') l2
where l1.surname<>l2.surname and l1.id>l2.id  and l1.city='Киев' -- "...лекторов из Киева попарно.", нужно добавить еще одно условие.

--или

select concat(l1.surname, '-', l2.surname) as couple
from lecturers l1
cross join (select id, surname
			from lecturers) l2
where l1.surname<>l2.surname and l1.id>l2.id
order by 1


-- вариант препода

select *
from lecturers as lec1
cross join lecturers as lec2
where lec1.CITY = 'Киев'

select *
from lecturers as lec1
cross join lecturers as lec2
where lec1.CITY = 'Киев'			
  and lec1.CITY = lec2.CITY
  and lec1.ID > lec2.ID

--или

select *
from lecturers as lec1
join lecturers as lec2 on lec1.CITY = 'Киев' 
                      and lec1.CITY = lec2.CITY 
					  and lec1.ID > lec2.ID

  
DECLARE @city varchar(100) = 'Киев';
select *
from lecturers as lec1
join lecturers as lec2 on lec1.CITY = @city
                      and lec1.CITY = lec2.CITY 
					  and lec1.ID > lec2.ID

-- 9. Выдать информацию о всех университетах, всех предметах и фамилиях преподавателей, 
--    если в университете для конкретного предмета преподаватель отсутствует, то его фамилию
--    вывести на экран как прочерк '-' (воспользуйтесь ф-ей isnull)


select u.*, su.name as Subject, isnull(t1.surname, '---') as Lecturer
from universities u
cross join subjects su
left outer join (select l.surname, u.name as uname, su.name as suname, l.univ_id, sl.*
				from subj_lect sl
				right outer join lecturers l on sl.lecturer_id=l.id 
				cross join universities u
				cross join subjects su
				where l.univ_id=u.id and sl.subj_id=su.id   -- там где есть явная связь, лучше использовать inner join
				) as t1 on u.id=t1.univ_id and su.id=t1.subj_id
order by u.id, su.id

-- вариант препода

select *
from UNIVERSITIES as un 
cross join SUBJECTS as sb
order by un.NAME


select un.NAME, sb.NAME, isnull(LEC_SUB.SURNAME, '-')
from UNIVERSITIES as un 
cross join SUBJECTS as sb
left join (select lec.ID as LEC_ID, sb.SUBJ_ID, lec.UNIV_ID, lec.SURNAME
	       from LECTURERS as lec
	       join SUBJ_LECT sb on sb.LECTURER_ID = lec.ID) as LEC_SUB on LEC_SUB.UNIV_ID = un.ID 
		                                                           and sb.ID = LEC_SUB.SUBJ_ID 
order by un.NAME, sb.NAME


select u.NAME, sb.NAME, isnull(lec.SURNAME, '-')
from UNIVERSITIES as u 
cross join SUBJECTS as sb
left join LECTURERS as lec 
join SUBJ_LECT as sbl on lec.ID=sbl.LECTURER_ID   -- FIRST LECTURERS AND SUBJ_LECT

on u.ID=lec.UNIV_ID and sbl.SUBJ_ID = sb.ID       -- THEN LEFT JOIN
order by u.NAME, sb.NAME	

-- 10. Кто из преподавателей и сколько поставил пятерок за свой предмет?

--первый вариант

select l.id, l.surname, su.name, count(em.student_id) as st_quant
from lecturers l
inner join subj_lect sl on l.id=sl.lecturer_id
inner join subjects su on sl.subj_id=su.id
inner join students st on st.univ_id=l.univ_id
inner join exam_marks em on em.subj_id=su.id and st.id=em.student_id
where em.mark=5
group by l.id, l.surname, su.name


 --когда не поверила с первого раза, что результат 9 пятерок (хотя всего поставлено 23 пятерки, просто остальные 14 поставлены неизвестными преподавателями)

select t1.lec_id, t1.lecturer, t1.subject, t1.university, count(em.student_id) as number_of_students
from students st
inner join exam_marks em on st.id=em.student_id and mark=5
inner join (select l.id as lec_id, l.surname as lecturer, u.name as university, su.name as subject, l.univ_id, sl.*
			from subj_lect sl
			right outer join lecturers l on sl.lecturer_id=l.id 
			cross join universities u
			cross join subjects su
			where l.univ_id=u.id and sl.subj_id=su.id) t1 on st.univ_id=t1.univ_id and em.subj_id=t1.subj_id
group by t1. lec_id, t1.lecturer, t1.lecturer, t1.subject, t1.university


-- вариант препода

select l.SURNAME, su.NAME, count(*)
from lecturers l
inner join subj_lect sl on l.id = sl.lecturer_id
inner join subjects su on sl.subj_id = su.id
inner join students st on st.univ_id = l.univ_id			             -- у нас нет ссылки на преподавателя, по этому ищем по связи преподаватель-университет-студент. 
inner join exam_marks em on em.subj_id = su.id and st.id = em.student_id 
where em.MARK = 5
group by l.SURNAME, su.NAME

select * from EXAM_MARKS 
where MARK = 5 and STUDENT_ID = 34          -- Получил 5 но не попал в выборку

select * from STUDENTS where ID = 34         --UNIV_ID = 11
select * from LECTURERS where UNIV_ID = 11   -- EMPTY