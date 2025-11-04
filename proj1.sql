-- comp9311 23T2 Project 1

-- Q1:
create or replace view Q1(subject_code)
as
select code
from subjects 
where offeredby in
(select a.id from orgunits a, orgunit_types b where a.utype = b.id and b.name like '%Centre%') ;

-- Q2:
Create or replace view q2_course_ctype(course, num_of_ctype)
as
select course, count(distinct ctype) 
from classes 
group by course 
having count(distinct ctype) >= 4;

create or replace view Q2(course_id)
as
select distinct course 
from classes
where ctype in (select id from class_types where name like '%Seminar%')
and course in (select course from q2_course_ctype);

-- Q3:
create or replace view q3_temp1(student, course) 
as 
select student, course 
from course_enrolments 
where course in (select id from courses where semester in (select id from semesters where year = 2010));

create or replace view q3_temp2(id, _equivalent) 
as 
select a.id, b._equivalent 
from courses a, subjects b 
where a.subject = b.id and b._equivalent LIKE '%JURD%' and b._equivalent LIKE '%LAWS%';

create or replace view q3_temp3(student, course, _equivalent, unswid) 
as 
select a.*, b._equivalent, c.unswid 
from q3_temp1 a, q3_temp2 b, people c 
where a.course = b.id and a.student = c.id;

create or replace view Q3(unsw_id)
as
select distinct unswid from q3_temp3 group by unswid having count(course)>=2;

-- Q4:
create or replace view q4_temp1(course, avg_mark)
as 
select distinct course , round(avg(mark), 4) as avg_mark
from course_enrolments 
where course in (select id from courses where semester in (select id from semesters where year = 2010)) 
and mark is not null group by course;

create or replace view q4_temp2(id, avg_mark) 
as 
select a.id, c.avg_mark 
from courses a, subjects b, q4_temp1 c 
where a.subject = b.id 
and b.code LIKE 'COMP%' 
and a.id = c.course;

create or replace view Q4(course_id, avg_mark)
as
select id, avg_mark 
from q4_temp2 
where avg_mark = (select max(avg_mark) from q4_temp2);

-- Q5:
create or replace view q5_temp1(faculty_id, subject_id, courses_id)
as
select a.id as faculty_id, b.id as subject_id, c.id as courses_id 
from orgunits a, subjects b, courses c 
where a.id = b.offeredby 
and b.id = c.subject 
and c.semester in (select id from semesters where year = 2005) and a.utype in (select id from orgunit_types where name like '%Faculty%');

create or replace view q5_temp2(faculty_id, subject_id, courses_id, room, ctype, startdate, enddate) 
as 
select a.*, b.room, b.ctype, b.startdate, b.enddate from q5_temp1 a, classes b 
where a.courses_id = b.course 
and b.ctype in (select id from class_types where name = 'Tutorial');

create or replace view q5_temp3 (faculty_id, room, num) 
as 
select faculty_id, room, count(room) 
from q5_temp2 
group by faculty_id, room;

create or replace view Q5(faculty_id, room_id)
as
select faculty_id, room 
from q5_temp3 
where (faculty_id, num) in 
(select faculty_id, max(num) from q5_temp3 group by faculty_id);

-- Q6:
create or replace view q6_temp1(id, student, semester, program, stream) 
as
select a.id, a.student, a.semester, a.program, b.stream 
from program_enrolments a, stream_enrolments b 
where semester in (select id from semesters where year = 2005 and term = 'S1') 
and a.id = b.partof 
and program in (select id from programs where offeredby in (select id from orgunits where name = 'Faculty of Arts and Social Sciences'));

create or replace view q6_temp2(program, stream, num) 
as 
select program, stream, count(student) 
from q6_temp1 
group by program, stream 
order by program;

create or replace view Q6(program_id, stream_id)
as
select program, stream from q6_temp2 
where (program, num) in (select program, max(num) from q6_temp2 group by program);

-- Q7:
create or replace view q7_temp1(id, subject_id) 
as 
select id, subject 
from courses 
where semester in (select id from semesters where year = 2008) 
and subject in (select id from subjects where offeredby in (select id from orgunits where lower(name) like '%law%'));

create or replace view q7_temp2(course_id, subject_id, staff_id, staff_name) 
as 
select a.*, b.staff, c.name 
from q7_temp1 a 
left join course_staff b 
on a.id = b.course 
left join people c 
on b.staff = c.id;

create or replace view q7_temp3(subject_id, no_of_course) 
as 
select subject_id, count(distinct course_id) as no_of_course 
from q7_temp2 
where subject_id not in (select subject_id from q7_temp2 where staff_id is NULL) 
group by subject_id 
having count(distinct course_id)>=2;

create or replace view q7_temp4(subject_id, staff_name, no_of_course_teach) 
as 
select subject_id, staff_name, count(distinct course_id) as no_of_course_teach 
from q7_temp2 
where subject_id not in (select subject_id from q7_temp2 where staff_id is NULL) 
group by subject_id, staff_name 
having count(distinct course_id)>=2;

create or replace view Q7(subject_id, staff_name)
as
select subject_id, staff_name 
from q7_temp4 
where (subject_id, no_of_course_teach) in (select * from q7_temp3);

-- Q8:
create or replace view q8_temp1 (people_id, unswid, name, semester_id, program_id, offeredby) 
as 
select distinct a.student as people_id, c.unswid, c.name, a.semester as semester_id, a.program as program_id, b.offeredby 
from program_enrolments a, programs b, people c 
where a.program = b.id 
and b.offeredby in (select id from orgunits where name = 'Faculty of Science') 
and a.student = c.id;

create or replace view q8_temp2(people_id, course_id, mark, subject_id, semester, subject_code, subject_name) 
as 
select a.student, a.course, a.mark, b.subject, b.semester, c.code, c.name 
from course_enrolments a, courses b, subjects c 
where a.course = b.id and b.subject = c.id;

create or replace view q8_temp3 (people_id, course_id, mark, subject_id, semester, subject_code, subject_name) 
as 
select * from q8_temp2 
where (subject_code, semester) in (select subject_code, semester from q8_temp2 group by subject_code, semester having count(distinct people_id) > 100);

create or replace view q8_temp4 (people_id, course_id, mark, subject_id, semester, subject_code, subject_name, rank) 
as 
select *, RANK () OVER (PARTITION BY course_id order by mark desc) 
from q8_temp3 where mark is not null;

create or replace view q8_temp5(unswid, name, subject_code, rank) 
as 
select a.unswid, a.name, b. subject_code, b.rank 
from q8_temp1 a, q8_temp4 b 
where a.people_id = b.people_id and a.semester_id = b.semester;

create or replace view q8_temp6 (unswid, name, subject_code, rank) 
as 
select * from q8_temp5 where rank between 1 and 10;

create or replace view Q8(unsw_id, name)
as
select distinct unswid, name 
from q8_temp6 where unswid not in (select distinct unswid from q8_temp6 where subject_code not like 'MATH%');

-- Q9:
create or replace view q9_temp1(course_id, mark, subject_id, people_id, role) 
as 
select a.course, a.mark, b.subject, c.staff, c.role 
from course_enrolments a, courses b, course_staff c 
where a.course = b.id 
and a.course = c.course 
and role = (select id from staff_roles where name = 'Course Convenor');

create or replace view q9_temp2 (course_id, mark, subject_id, people_id, role, pf, career) 
as 
select a.*, case when mark < 50 then 'F' else 'P' end as PF, b.career 
from q9_temp1 a, subjects b 
where a.subject_id = b.id 
and b.career = 'UG' 
and mark is not null;

create or replace view q9_temp3 (people_id, unswid) 
as 
select distinct staff, b.unswid from affiliations a, people b 
where orgunit in (select id from orgunits where longname = 'School of Mechanical and Manufacturing Engineering') 
and role in (select id from staff_roles where name like '%Professor%') 
and a.staff = b.id;

create or replace view q9_temp4 (course_id, mark, subject_id, people_id, role, pf, career, unswid) 
as 
select a.*, b.unswid 
from q9_temp2 a, q9_temp3 b 
where a.people_id = b.people_id;

create or replace view q9_temp5(unswid, count_all, f_count) 
as 
select distinct unswid, cast(count(*) as numeric), sum(case when pf = 'F' then 1 else 0 end) as f_count 
from q9_temp4 group by unswid;

create or replace view Q9(prof_id,fail_rate)
as
select unswid, round(f_count/count_all, 4) as fail_rate 
from q9_temp5;

-- Q10:
create or replace view q10_temp1(people_id, semester_id, program, startdate, enddate) 
as 
select a.student, a.semester, a.program, b.starting, b.ending 
from program_enrolments a, semesters b 
where program in (select id from programs where id in (select program from program_degrees where abbrev = 'MA')) 
and a.semester = b.id;

create or replace view q10_temp2_1(people_id, semester_id, program, startdate) 
as 
select people_id, semester_id, program, startdate from q10_temp1 
where (people_id, semester_id, program) in (select people_id, min(semester_id), program from q10_temp1 group by people_id, program);

create or replace view q10_temp2_2(people_id, semester_id, program, enddate) 
as 
select people_id, semester_id, program, enddate from q10_temp1 
where (people_id, semester_id, program) in (select people_id, max(semester_id), program from q10_temp1 group by people_id, program);

create or replace view q10_temp3 (people_id, program, startdate, enddate) 
as 
select a.people_id, a.program, a.startdate, b.enddate 
from q10_temp2_1 a join q10_temp2_2 b 
on a.people_id = b.people_id 
and a.program = b.program;

create or replace view q10_temp4(people_id, program, startdate, enddate, days) 
as 
select *, (enddate::date - startdate::date) AS days 
from q10_temp3 
where (enddate::date - startdate::date) > 2000;

create or replace view q10_temp5(people_id, course_id, mark, subject_id, semester, subject_code, subject_name, uoc) 
as 
select a.student, a.course, a.mark, b.subject, b.semester, c.code, c.name, c.uoc 
from course_enrolments a, courses b, subjects c 
where a.course = b.id 
and b.subject = c.id;

create or replace view q10_temp6 (people_id, earned_uoc) 
as 
select people_id, sum(uoc) 
from q10_temp5 
where mark is not null 
group by people_id;

create or replace view q10_temp7 (people_id, program, uoc, expected_uoc, earned_uoc) 
as 
select a.people_id, a.program, b.uoc, b.uoc/2 as expected_uoc, c.earned_uoc 
from q10_temp4 a, programs b, q10_temp6 c 
where a.program = b.id 
and a.people_id = c.people_id;

create or replace view Q10(student_id, program_id, remain_uoc)
as
select b.unswid, a.program, a.uoc-a.earned_uoc as remain_uoc 
from q10_temp7 a, people b 
where a.people_id = b.id 
and a.expected_uoc > a.earned_uoc;

-- Q11
create or replace function
	Q11_student_with_grade(year courseyeartype, term character(2), orgunit_id integer) returns table(
	student int, avg_mark numeric, grade text)
as $$
begin
	return query select a.student, avg(a.mark) as avg_mark, 
	case when avg(a.mark) >= 85 then 'HD' 
	when avg(a.mark) >= 75 then 'DN' 
	when avg(a.mark) >= 65 then 'CR' 
	when avg(a.mark) >= 50 then 'PS' 
	else 'FL' end as grade 
	from course_enrolments a 
	where a.student in 
	(select b.student from program_enrolments b where b.program in (select id from programs where programs.offeredby = Q11_student_with_grade.orgunit_id) 
	and b.semester in (select id from semesters where semesters.year = Q11_student_with_grade.year and semesters.term = Q11_student_with_grade.term)) 
	and a.course in (select id from courses where courses.semester in (select id from semesters where semesters.year = Q11_student_with_grade.year and semesters.term = Q11_student_with_grade.term)) 
	and a.mark is not null 
	group by a.student;
	
end;$$ language plpgsql;

create or replace function
	Q11_count_grade(year courseyeartype, term character(2), orgunit_id integer) returns table (grade text, count numeric)
as $$
begin
	return query select a.grade, cast(count(a.student) as numeric) as num 
	from Q11_student_with_grade(year, term, orgunit_id) a 
	group by a.grade;
	
end;$$ language plpgsql;

create or replace function
	Q11_count_total(year courseyeartype, term character(2), orgunit_id integer) returns table (total numeric)
as $$
begin
	return query select cast(sum(a.count) as numeric) as total 
	from Q11_count_grade(year, term, orgunit_id) a;
	
end;$$ language plpgsql;


create or replace function
	Q11(year courseyeartype, term character(2), orgunit_id integer) returns setof text
as $$
declare
	r record;
	out text := '';
begin
	for r in select a.grade, cast(round(a.count/b.total, 4) as numeric) as perc 
	from Q11_count_grade(year, term, orgunit_id) a, Q11_count_total(year, term, orgunit_id) b

	loop
		out := out || r.grade ||' '|| r.perc;
		return next out;
		out := '';
	end loop;
	
end;$$ language plpgsql;


-- Q12
create or replace function staff_in_prefix(subject_prefix character(4)) returns table (course integer, staff integer, subject integer)

as $$
begin
	return query select a.course, a.staff, b.subject 
	from course_staff a, courses b 
	where a.course = b.id 
	and b.subject in (select id from subjects where substr(subjects.code, 1,4) = staff_in_prefix.subject_prefix);

end; $$ language plpgsql;

create or replace function course_with_orgunit(subject_prefix character(4)) returns table (course_id integer, people_id integer, orgunit integer)

as $$
begin
	return query select a.course, a.staff, b.orgunit 
	from staff_in_prefix(subject_prefix) a, affiliations b 
	where a.staff = b.staff;

end; $$ language plpgsql;

create or replace function q12_result(subject_prefix character(4)) returns table (course_id integer, orgunit integer)

as $$
begin
	return query select distinct a.course_id, a.orgunit 
	from course_with_orgunit(subject_prefix) a
	where a.course_id in (select b.course_id from course_with_orgunit(subject_prefix) b group by b.course_id having count(distinct b.orgunit)>=4) 
	order by a.course_id, a.orgunit;

end; $$ language plpgsql;


create or replace function q12_result1(subject_prefix character(4)) returns table (course_id integer, orgunit text)

as $$
begin
	return query select a.course_id, cast(a.orgunit as text) from q12_result(subject_prefix) a;

end; $$ language plpgsql;



create or replace function 
	Q12(subject_prefix character(4)) returns setof text
as $$
declare
	r record;
	out text := '';
begin
	for r in select a.course_id, string_agg(a.orgunit, '/') as orgunit_list from q12_result1(subject_prefix) a group by a.course_id

	loop
		out := out || r.course_id ||' '|| r.orgunit_list;
		return next out;
		out := '';
	end loop;
end;
$$ language plpgsql;

