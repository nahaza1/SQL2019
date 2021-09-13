-- /* Везде, где необходимо данные придумать самостоятельно. */


-- 1. Необходимо добавить двух новых студентов для нового учебного 
--    заведения "Винницкий Медицинский Университет".

begin tran;

insert into universities (id, name, rating, city)
	 values (16, N'ВМУ', 757, N'Винница');

insert into students (id, surname, name, gender, stipend, course, city, birthday, univ_id)
	 values (46, N'Родригес', N'Хавьер', 'm', 800, 4, N'Буэнос-Айрес',  convert(datetime, N'1978-05-15', 101), 16), -- Айдишку можно получить динамически (select ID from universities where name = 'ВМУ')
			(47, N'Кастеллано', N'Мойра', 'f', 800, 4, N'Буэнос-Айрес',  convert(datetime, N'1979-02-23', 101), 16);

--select * from universities; 

--select * from students;

rollback;

begin tran;

insert into universities (id, name, rating, city)
	 values (16, N'ВМУ', 757, N'Винница');

insert into students (id, surname, name, gender, stipend, course, city, birthday, univ_id)
	 values (46, N'Родригес', N'Хавьер', 'm', 800, 4, N'Буэнос-Айрес',  convert(datetime, N'1978-05-15', 101),   --ДАТА!
						(select ID from universities where name = 'ВМУ')),
			(47, N'Кастеллано', N'Мойра', 'f', 800, 4, N'Буэнос-Айрес',  '19790223', 
						(select ID from universities where name = 'ВМУ'));

select * from universities; 
select * from students;

rollback;

-- 2. Добавить еще один институт для города Ивано-Франковск, 
--    1-2 преподавателей, преподающих в нем, 1-2 студента,
--    а так же внести новые данные в экзаменационную таблицу.
begin tran;

insert into universities (id, name, rating, city)
	 values (17, N'ИФПИ', 715, N'Ивано-Франковск');

insert into lecturers (id, surname, name, city, univ_id)
	 values (26, N'Арреги', N'Лучиана', N'Ивано-Франковск', 17),
			(27, N'Морэно', N'Андрес', N'Ивано-Франковск', 17);

insert into students (id, surname, name, gender, stipend, course, city, birthday, univ_id)
	 values (48, N'Эспиноза', N'Карлитос', 'm', 850, 3, N'Ивано-Франковск',  convert(datetime, N'1988-05-15', 101), 17),   -- Дату можно явно не преобразовывать, просто '19880515'
			(49, N'Хуртадо', N'Ноэлия', 'f', 850, 2, N'Ивано-Франковск',  convert(datetime, N'1988-02-23', 101), 17);

insert into exam_marks (student_id, subj_id, mark, exam_date)
	 values (48, 1, 4, convert(datetime, N'2012-06-17', 101)),
			(48, 3, 5, convert(datetime, N'2012-06-22', 101)),
			(48, 5, 5, convert(datetime, N'2012-06-24', 101)),
			(49, 2, 4, convert(datetime, N'2012-06-05', 101)),
			(49, 5, 5, convert(datetime, N'2012-06-12', 101));

--select * from universities;
--select * from students;
--select * from exam_marks;

rollback;

-- 3. Известно, что студенты Павленко и Пименчук перевелись в КПИ. 
--    Модифицируйте соответствующие таблицы и поля.

begin tran

select * into students_arch				-- Архивная таблица называеться STUDENTS_ARCHIVE. И нужно еще разобраться с оценками.
from students 
where surname in ('Павленко', 'Пименчук');


update students set 
		univ_id=(select id from universities where name='КПИ') 
where surname in ('Павленко', 'Пименчук');

--select * from students where surname in ('Павленко', 'Пименчук');
--select * from students_arch;

rollback;

-- 4. В учебных заведениях Украины проведена реформа и все студенты, 
--    у которых средний бал не превышает 3.5 балов - отчислены из институтов. 
--    Сделайте все необходимые удаления из БД.
--    Примечание: предварительно "отчисляемых" сохранить в архивационной таблице
begin tran

--select student_id
--from exam_marks
--group by student_id
--having avg(mark)<=3.5;

--select *
--from exam_marks 
--where student_id in(select student_id
--					from exam_marks
--					group by student_id
--					having avg(mark)<=3.5);

select * into exam_marks_arch						-- оценки сохранять не нужно
from exam_marks 
where student_id in(select student_id
					from exam_marks
					group by student_id
					having avg(mark)<=3.5);

select * into students_arch						-- Архивная таблица называеться STUDENTS_ARCHIVE.
from students 
where id in(select student_id
			from exam_marks
			group by student_id
			having avg(mark)<=3.5);



													insert into students_archive			-- Архивная таблица называеться STUDENTS_ARCHIVE.				
													select *
													from students 
													where id in(select student_id
																from exam_marks
																group by student_id
																having avg(mark)<=3.5);

select * into students_temp_remove 
from students 
where id in(select student_id
			from exam_marks
			group by student_id
			having avg(mark)<=3.5);

delete from exam_marks 
where student_id=any(select student_id
					from exam_marks
					group by student_id
					having avg(mark)<=3.5);

delete from students 
where id=any(select id
			from students_temp_remove);

delete from students						-- так тоже можно, без вспомогательной таблицы
where id=any(select student_id
					from exam_marks
					group by student_id
					having avg(mark)<=3.5);

--select * from students;

--select student_id
--from exam_marks
--group by student_id
--having avg(mark)<=3.5;

--select * from students_arch;

--select * from exam_marks_arch;

--select * from students_temp_remove;

rollback;


begin tran
insert into STUDENTS_ARCHIVE 
select ID
		, SURNAME 
		, NAME
		, GENDER
		, STIPEND
		, COURSE
		, CITY
		, BIRTHDAY
		, UNIV_ID
from STUDENTS 
where ID in (select STUDENT_ID
			 from EXAM_MARKS
			 group by STUDENT_ID
			 having avg(MARK)<=3.5)

select * from STUDENTS_ARCHIVE;


delete from EXAM_MARKS where STUDENT_ID in (select STUDENT_ID 
											from EXAM_MARKS
											group by STUDENT_ID
											having avg(MARK)<=3.5)
select * from EXAM_MARKS;
			
/*delete*/select * from STUDENTS s where ID not in (select STUDENT_ID				
									    from EXAM_MARKS
									    group by STUDENT_ID
									    having avg(MARK)>3.5)
							and  exists(select STUDENT_ID				-- У 3х студентов нет оценок. Без этого условия в выборке 23 студента
									    from EXAM_MARKS em
										where em.STUDENT_ID = s.ID)	
										  

				  
delete from STUDENTS where ID in (select ID from STUDENTS_ARCHIVE)					  	
																	

select * from STUDENTS
rollback




-- 5. Студентам со средним балом 4.75 начислить 12.5% к стипендии,
--    со средним балом 5 добавить 200 грн.
--    Выполните соответствующие изменения в БД.

begin tran

--select * from students

--select * from students 
--where id in(select student_id
--			from exam_marks
--			group by student_id
--			having avg(mark)=4.75

--			union

--			select student_id
--			from exam_marks
--			group by student_id
--			having avg(mark)=5.0);

 
select * into students_arch 
from students 
where id in(select student_id
			from exam_marks
			group by student_id
			having avg(mark)=4.75

			union

			select student_id
			from exam_marks
			group by student_id
			having avg(mark)=5.0);

update students set 
		stipend= case
					when id in (select student_id
								from exam_marks
								group by student_id
								having avg(mark)=4.75)
														then stipend*1.125
					when id in (select student_id
								from exam_marks
								group by student_id
								having avg(mark)=5)
														then stipend+200
					else stipend
				end;

select * from students 

--select * from students_arch;

--select * from students 
--where id in(select student_id
--			from exam_marks
--			group by student_id
--			having avg(mark)=4.75

--			union

--			select student_id
--			from exam_marks
--			group by student_id
--			having avg(mark)=5.0);

rollback;

--2 вариант 
begin tran

select * into students_arch 
from students 
where id in(select student_id
			from exam_marks
			group by student_id
			having avg(mark)=4.75

			union

			select student_id
			from exam_marks
			group by student_id
			having avg(mark)=5.0);


update students set 
		stipend=stipend*1.125
where id in (select student_id
			 from exam_marks
			 group by student_id
			 having avg(mark)=4.75);
		
		
update students set 
		stipend=stipend+200
where id in (select student_id
			 from exam_marks
			 group by student_id
			 having avg(mark)=5);
											
rollback;



-- вариант преподавателя

select * from STUDENTS
begin tran

update STUDENTS set STIPEND = STIPEND*1.125				-- Ок, а если с помощью 1го апдейта?
				where ID in (select STUDENT_ID 
								from EXAM_MARKS
								group by STUDENT_ID
								having AVG(MARK) = 4.75)  
update STUDENTS set STIPEND = STIPEND + 200
				where ID in (select STUDENT_ID 
								from EXAM_MARKS
								group by STUDENT_ID
								having AVG(MARK) = 5)  

select * from STUDENTS
rollback

-- ИЛИ

begin tran
update STUDENTS set STIPEND= 
				case
				when ID in (select STUDENT_ID 
								from EXAM_MARKS
								group by STUDENT_ID
								having AVG(MARK) = 4.75) 
				then  STIPEND*1.125	
				when ID in (select STUDENT_ID 
							from EXAM_MARKS
							group by STUDENT_ID
							having AVG(MARK) = 5)  
				then STIPEND + 200
				else STIPEND
				end 

select * from STUDENTS
rollback




-- 6. Необходимо удалить все предметы, по котором не было получено ни одной оценки.
--    Если таковые отсутствуют, попробуйте смоделировать данную ситуацию.

begin tran;

--select *
--from subjects
--where id not in(select subj_id from exam_marks);

insert into subjects (id, name, hours, semester)
	 values (8, N'Логика', 60, 3);

insert into subj_lect (lecturer_id, subj_id)
	 values (7, 8);

select * into subj_lect_arch 
from subj_lect
where subj_id not in(select subj_id from exam_marks);

select * into subjects_arch 
from subjects
where id not in(select subj_id from exam_marks);   -- лучше exists

delete from subj_lect
where subj_id not in(select subj_id from exam_marks);  -- лучше exists

delete from subjects
where id not in(select subj_id from exam_marks);

--select * from subjects where id not in(select subj_id from exam_marks);
--select * from subj_lect where subj_id not in(select subj_id from exam_marks);

rollback;


-- 7. Лектор 3 ушел на пенсию, необходимо корректно удалить о нем данные.

begin tran;

--select * from lecturers where id=3;
--select * from subj_lect where lecturer_id=3;

select * into subj_lect_arch 
from subj_lect
where lecturer_id=3;

select * into lecturers_arch 
from lecturers
where id=3;

delete from subj_lect
where lecturer_id=3;

delete from lecturers
where id=3;

--select * from lecturers where id=3;
--select * from subj_lect where lecturer_id=3;
--select * from lecturers_arch;
--select * from subj_lect_arch;

rollback;