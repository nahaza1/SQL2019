-- 1. Создайте представление для получения сведений обо всех студентах, 
--    круглых отличниках. Напишите запрос "расжалующий" их в троешников, 
--    в каком случае сработает такой скрипт.

select



create view excel_stud as
select s.*, em.subj_id, em.mark
from students s
inner join exam_marks em on em.student_id=s.id
where s.id not in (select student_id from exam_marks where mark<5)


begin tran

select * from excel_stud

update excel_stud set mark=3.00

select * from excel_stud

rollback

-- сработает без  with check option

-- 2. Создайте представление для получения сведений о количестве студентов 
--    в каждом городе.

create view st_number as
select u.city, count(s.id) as stud_quant
from universities u
left join students s on u.id=s.univ_id
group by u.city


-- 3. Создайте представление для получения сведений по каждому студенту: 
--    его ID, фамилию, имя, средний и общий баллы.

create view st_info as
select s.id, s.surname, s.name, avg(em.mark) as avg_mark, sum(em.mark) as overall_mark
from students s
left join exam_marks em on em.student_id=s.id
group by s.id, s.surname, s.name



-- 4. Создайте представление для получения сведений о студенте фамилия, 
--    имя, а также количестве экзаменов, которые он сдавал.

create view st_exam as
select s.id, s.surname, s.name, count(em.subj_id) as exam_quant
from students s
left join exam_marks em on em.student_id=s.id
group by s.id, s.surname, s.name


--если брать уникальные экзамены
create view st_exam_1 as
select s.id, s.surname, s.name, count(distinct em.subj_id) as exam_quant
from students s
left join exam_marks em on em.student_id=s.id
group by s.id, s.surname, s.name


-- 5. Какие из представленных ниже представлений являются обновляемыми?


-- A. CREATE VIEW DAILYEXAM AS
--    SELECT DISTINCT STUDENT_ID, SUBJ_ID, MARK, EXAM_DATE            -- есть distinct
--    FROM EXAM_MARKS


-- B. CREATE VIEW CUSTALS AS
--    SELECT SUBJECTS.ID, SUM (MARK) AS MARK1                          -- есть group by
--    FROM SUBJECTS, EXAM_MARKS
--    WHERE SUBJECTS.ID = EXAM_MARKS.SUBJ_ID
--    GROUP BY SUBJECT.ID


-- C. CREATE VIEW THIRDEXAM
--    AS SELECT *
--    FROM DAILYEXAM                                                   -- ссылка на немодифицируемое представление (да и формат даты)
--    WHERE EXAM_DATE = ‘2012/06/03’


 D. CREATE VIEW NULLCITIES
    AS SELECT ID, SURNAME, CITY              -- обновляемое, но фамилии с первой буквой Д не включаются в выборку, 
    FROM STUDENTS							 -- поскольку 'любая фамилияя на Д'>'Д'
    WHERE CITY IS NULL
    OR SURNAME BETWEEN 'А' AND 'Д'
    WITH CHECK OPTION


-- 6. Создайте представление таблицы STUDENTS с именем STIP, включающее поля 
--    STIPEND и ID и позволяющее вводить или изменять значение поля 
--    стипендия, но только в пределах от 100 д о 500.

create view stip as
select id, stipend
from students
where stipend between 100 and 500
with check option




