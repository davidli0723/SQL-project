-- COMP9311 23T2 Project Check
--
-- MyMyUNSW Check

SET client_min_messages TO WARNING;

create or replace function
	proj1_table_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='r';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_view_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='v';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_function_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_proc
	where proname=tname;
	return (_check > 0);
end;
$$ language plpgsql;

-- proj1_check_result:
-- * determines appropriate message, based on count of
--   excess and missing tuples in user output vs expected output

create or replace function
	proj1_check_result(nexcess integer, nmissing integer) returns text
as $$
begin
	if (nexcess = 0 and nmissing = 0) then
		return 'correct';
	elsif (nexcess > 0 and nmissing = 0) then
		return 'too many result tuples';
	elsif (nexcess = 0 and nmissing > 0) then
		return 'missing result tuples';
	elsif (nexcess > 0 and nmissing > 0) then
		return 'incorrect result tuples';
	end if;
end;
$$ language plpgsql;

-- proj1_check:
-- * compares output of user view/function against expected output
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_check(_type text, _name text, _res text, _query text) returns text
as $$
declare
	nexcess integer;
	nmissing integer;
	excessQ text;
	missingQ text;
begin
	if (_type = 'view' and not proj1_view_exists(_name)) then
		return 'No '||_name||' view; did it load correctly?';
	elsif (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (not proj1_table_exists(_res)) then
		return _res||': No expected results!';
	else
		excessQ := 'select count(*) '||
				 'from (('||_query||') except '||
				 '(select * from '||_res||')) as X';
		-- raise notice 'Q: %',excessQ;
		execute excessQ into nexcess;
		missingQ := 'select count(*) '||
					'from ((select * from '||_res||') '||
					'except ('||_query||')) as X';
		-- raise notice 'Q: %',missingQ;
		execute missingQ into nmissing;
		return proj1_check_result(nexcess,nmissing);
	end if;
	return '???';
end;
$$ language plpgsql;

-- proj1_rescheck:
-- * compares output of user function against expected result
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_rescheck(_type text, _name text, _res text, _query text) returns text
as $$
declare
	_sql text;
	_chk boolean;
begin
	if (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (_res is null) then
		_sql := 'select ('||_query||') is null';
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	else
		_sql := 'select ('||_query||') = '||quote_literal(_res);
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	end if;
	if (_chk) then
		return 'correct';
	else
		return 'incorrect result';
	end if;
end;
$$ language plpgsql;

-- check_all:
-- * run all of the checks and return a table of results

drop type if exists TestingResult cascade;
create type TestingResult as (test text, result text);

create or replace function
	check_all() returns setof TestingResult
as $$
declare
	i int;
	testQ text;
	result text;
	out TestingResult;
	tests text[] := array['q1', 'q2', 'q3', 'q4', 'q5','q6','q7','q8','q9','q10',
	'q11a','q11b','q11c','q11d','q11e',
	'q12a','q12b','q12c','q12d','q12e'];
begin
	for i in array_lower(tests,1) .. array_upper(tests,1)
	loop
		testQ := 'select check_'||tests[i]||'()';
		execute testQ into result;
		out := (tests[i],result);
		return next out;
	end loop;
	return;
end;
$$ language plpgsql;


--
-- Check functions for specific test-cases in Project 1
--

create or replace function check_q1() returns text
as $chk$
select proj1_check('view','q1','q1_expected',
									 $$select * from q1$$)
$chk$ language sql;

create or replace function check_q2() returns text
as $chk$
select proj1_check('view','q2','q2_expected',
									 $$select * from q2$$)
$chk$ language sql;

create or replace function check_q3() returns text
as $chk$
select proj1_check('view','q3','q3_expected',
									 $$select * from q3$$)
$chk$ language sql;

create or replace function check_q4() returns text
as $chk$
select proj1_check('view','q4','q4_expected',
									 $$select * from q4$$)
$chk$ language sql;

create or replace function check_q5() returns text
as $chk$
select proj1_check('view','q5','q5_expected',
									 $$select * from q5$$)
$chk$ language sql;

create or replace function check_q6() returns text
as $chk$
select proj1_check('view','q6','q6_expected',
									 $$select * from q6$$)
$chk$ language sql;

create or replace function check_q7() returns text
as $chk$
select proj1_check('view','q7','q7_expected',
									 $$select * from q7$$)
$chk$ language sql;

create or replace function check_q8() returns text
as $chk$
select proj1_check('view','q8','q8_expected',
									 $$select * from q8$$)
$chk$ language sql;

create or replace function check_q9() returns text
as $chk$
select proj1_check('view','q9','q9_expected',
									 $$select * from q9$$)
$chk$ language sql;

-- Q10
create or replace function check_q10() returns text
as $chk$
select proj1_check('view','q10','q10_expected',
									 $$select * from q10$$)
$chk$ language sql;

-- Q11
create or replace function check_q11a() returns text
as $chk$
select proj1_check('function','q11','q11a_expected',
									 $$select q11(2008, 'S2', 97)$$)
$chk$ language sql;

create or replace function check_q11b() returns text
as $chk$
select proj1_check('function','q11','q11b_expected',
									 $$select q11(2009, 'S1', 1350)$$)
$chk$ language sql;

create or replace function check_q11c() returns text
as $chk$
select proj1_check('function','q11','q11c_expected',
									 $$select q11(2010, 'S2', 180)$$)
$chk$ language sql;

create or replace function check_q11d() returns text
as $chk$
select proj1_check('function','q11','q11d_expected',
									 $$select q11(2007, 'S2', 1455)$$)
$chk$ language sql;

create or replace function check_q11e() returns text
as $chk$
select proj1_check('function','q11','q11e_expected',
									 $$select q11(2010, 'X1', 31)$$)
$chk$ language sql;

-- Q12
create or replace function check_q12a() returns text
as $chk$
select proj1_check('function','q12','q12a_expected',
									 $$select q12('ACCT')$$)
$chk$ language sql;

create or replace function check_q12b() returns text
as $chk$
select proj1_check('function','q12','q12b_expected',
									 $$select q12('ARTS')$$)
$chk$ language sql;

create or replace function check_q12c() returns text
as $chk$
select proj1_check('function','q12','q12c_expected',
									 $$select q12('ECON')$$)
$chk$ language sql;

create or replace function check_q12d() returns text
as $chk$
select proj1_check('function','q12','q12d_expected',
									 $$select q12('PSYC')$$)
$chk$ language sql;

create or replace function check_q12e() returns text
as $chk$
select proj1_check('function','q12','q12e_expected',
									 $$select q12('PHYS')$$)
$chk$ language sql;

--
-- Tables of expected results for test cases
--

drop table if exists q1_expected;
create table q1_expected (
	subject_code character(8)
);

drop table if exists q2_expected;
create table q2_expected (
	course_id integer
);

drop table if exists q3_expected;
create table q3_expected (
	unsw_id integer
);

drop table if exists q4_expected;
create table q4_expected (
	course_id integer, avg_mark numeric
);

drop table if exists q5_expected;
create table q5_expected (
	faculty_id integer, room_id integer
);

drop table if exists q6_expected;
create table q6_expected (
	program_id integer, stream_id integer
);

drop table if exists q7_expected;
create table q7_expected (
	subject_id integer, staff_name longname
);

drop table if exists q8_expected;
create table q8_expected (
	unsw_id integer, name longname
);

drop table if exists q9_expected;
create table q9_expected (
	prof_id integer, fail_rate numeric
);

drop table if exists q10_expected;
create table q10_expected (
	student_id integer, program_id integer, remain_uoc integer
);

drop table if exists q11a_expected;
create table q11a_expected (
	q11 text
);

drop table if exists q11b_expected;
create table q11b_expected (
	q11 text
);

drop table if exists q11c_expected;
create table q11c_expected (
	q11 text
);

drop table if exists q11d_expected;
create table q11d_expected (
	q11 text
);

drop table if exists q11e_expected;
create table q11e_expected (
	q11 text
);

drop table if exists q12a_expected;
create table q12a_expected (
	q12 text
);

drop table if exists q12b_expected;
create table q12b_expected (
	q12 text
);

drop table if exists q12c_expected;
create table q12c_expected (
	q12 text
);

drop table if exists q12d_expected;
create table q12d_expected (
	q12 text
);

drop table if exists q12e_expected;
create table q12e_expected (
	q12 text
);
-- ( )+\|+( )+

COPY q1_expected (subject_code) FROM stdin;
INTD4908
CLIM3001
ARTS5042
INTD4900
INTD4901
INTD4902
INTD8301
INTD8302
INTD9000
INTD9050
SPRC9000
SPRC9050
REGZ9070
REGZ9072
MSCI5007
REGZ0001
REGZ9075
REGZ9076
REGZ9077
REGZ9078
MSCI4003
GENB5001
GENY0002
MSCI5002
MSCI5006
MSCI5001
MSCI6300
MSCI4009
ARTS5013
INTD7012
INTD7016
MDCN9011
ARTS5040
MSCI5003
MSCI6200
INTD7008
INTD9500
ARTS5041
\.

COPY q2_expected (course_id) FROM stdin;
74188
34040
16499
72141
22787
34460
27555
70908
35989
37033
34041
67325
36995
70902
70950
\.

COPY q3_expected (unsw_id) FROM stdin;
2189863
3299663
3294792
3248587
3262592
3268160
3242406
3222157
3265264
3237075
3208690
\.

COPY q4_expected (course_id, avg_mark) FROM stdin;
51037	90.5000
51064	90.5000
\.

COPY q5_expected (faculty_id, room_id) FROM stdin;
31	610
31	614
82	1159
164	1109
\.

COPY q6_expected (program_id, stream_id) FROM stdin;
514	934
517	723
521	5141
521	5206
524	1375
537	1768
539	255
539	421
539	647
539	723
556	723
567	1303
608	1325
611	1077
614	1325
620	1677
630	1318
684	424
737	326
745	936
758	1677
804	135
838	1314
995	1331
1049	531
1058	768
1059	691
1062	727
1064	1137
1066	1140
1067	1208
1123	1328
1157	727
1158	424
1160	1075
1275	1382
1306	539
5077	576
6015	531
6015	1318
\.

COPY q7_expected (subject_id, staff_name) FROM stdin;
1361	Gordon Mackenzie
2326	Michael Peters
2327	Michael Peters
2371	David Hughes
2375	John Squires
2376	John Squires
2381	David Vaile
2784	David Hughes
2801	Keven Booker
2801	Sean Brennan
2917	Janet Austin
2918	Francesco Zumbo
2919	Jennifer Buchan
2919	Kerry Gottlieb
2919	Mary Ip
2920	Francesco Zumbo
2922	Anil Hargovan
2922	Janet Austin
2929	Christopher Taylor
4620	Gordon Mackenzie
4645	Gordon Mackenzie
5602	Bruce Gordon
5603	Cyril Butcher
5608	Anil Hargovan
5618	Christopher Taylor
8508	Cyril Butcher
20551	Rosemary Howell
20553	Robert Shelly
20612	Jenifer Engel
20612	Joanna Krygier
20800	Joanna Krygier
20836	Edward Santow
20836	Simon Blount
20847	Arthur Glass
21116	Alexandra George
21116	Michael Handler
21148	Owen Jessep
21629	Audrey Blunden
22398	Alana Maurushat
22398	David Vaile
22489	Deborah Healey
23081	Denis Harley
24509	Thomas Hickie
24599	Paul Gwynne
27124	Sarrah Huang
27311	Denis Harley
27312	Denis Harley
\.

COPY q8_expected (unsw_id, name) FROM stdin;
3197832	Qianlan Chen Qi
3169783	Praewphan Vatanakun
3130577	Ji Ohm
3119561	Kerrie Jolin-Thomas
3267831	Nga Shen
3207217	Bo Ning
3207454	Tommy Amornpantang
3299764	Nigel Tahtouh
3244097	Graham Pile
3256841	Shihab Rangoonwala
3031314	Diana Bagot
3249241	Edwina Agapiou
3221757	Sue Yeo
3274638	Hock Chian
3251898	Tieh-Shang Dou
3215932	Donna Bourke
3225241	Joung Carol
3253228	Leonidas Karamaneas
3304906	Nicola Garth
3351569	Danny Jo
3358563	Nicholas Pselletes
3324798	Diana Issa
3324781	Paul Farrelly
3309272	Abhishek Bajaj
3350216	Daniel Killen
3367828	Scott Rikard-Bell
3389810	Sanaa Stocks
3381162	Simon Newell
3337535	Minh Thieu
3399154	Zhi You
3329525	Pan-Seog Kwang
3357175	Huan Cao Xuedong
3349381	Joelene Watts
3313386	Emmanuel Fanker
3338727	Rohan Paoloni
3392914	Jaspreet Harvison
3370953	Lisnawati Novilia
3350789	Robert Duryea
3339042	Jelena Wilden
3321186	Thi Brown
3496932	Xiaozhu Huo
3499191	Kel Stavrinos
3491017	Mark Spackman
3487680	Christen Cranney
\.

COPY q9_expected (prof_id, fail_rate) FROM stdin;
6712455	0.1111
7268403	0.0526
7324520	0.0877
8022985	0.0536
8284662	0.0565
8548365	0.0049
9108191	0.0920
9155962	0.0581
9187449	0.0000
9147803	0.0587
9118081	0.0000
9752203	0.0404
9501528	0.1389
3055459	0.1343
3128625	0.1151
3165109	0.0556
9798375	0.2335
3082621	0.0833
8814478	0.1405
8840653	0.1852
\.



COPY q10_expected (student_id, program_id, remain_uoc) FROM stdin;
3196536	1157	76
9114429	961	30
\.


COPY q11a_expected (q11) FROM stdin;
HD 0.0189
DN 0.2767
CR 0.4465
PS 0.2390
FL 0.0189
\.

COPY q11b_expected (q11) FROM stdin;
HD 0.0841
DN 0.2995
CR 0.3923
PS 0.2189
FL 0.0053
\.

COPY q11c_expected (q11) FROM stdin;
HD 0.0491
DN 0.1739
CR 0.3478
PS 0.3289
FL 0.1002
\.

COPY q11d_expected (q11) FROM stdin;
HD 0.0949
DN 0.2263
CR 0.4453
PS 0.2190
FL 0.0146
\.

COPY q11e_expected (q11) FROM stdin;
HD 0.0730
DN 0.2920
CR 0.3285
PS 0.2701
FL 0.0365
\.

COPY q12a_expected (q12) FROM stdin;
18605 1278/1313/1576/1626
22134 1278/1313/1576/1626
26058 1278/1313/1576/1626
26072 1278/1313/1576/1626
50392 38/1600/1618/1619
54140 4/1278/1342/1578
57287 38/1600/1618/1619
64253 38/1600/1618/1619
\.

COPY q12b_expected (q12) FROM stdin;
7574 183/1570/1571/1596
40206 240/1450/1451/1452
43525 240/1450/1451/1452
47218 724/1450/1451/1452
47232 240/1450/1451/1452
47289 31/240/1411/1450/1596/1601/1602/1617/1635
47293 240/1450/1451/1452
50490 31/113/164/1141/1387
50494 31/238/1450/1451/1452/1596/1602
50495 31/724/1450/1451/1452/1596/1602
50568 240/1450/1451/1452
50600 240/1450/1451/1452
53772 197/412/1607/1608/1609
54258 31/1450/1451/1452
54266 31/1450/1451/1452/1596/1602
54308 31/240/1411/1450/1596/1601/1602/1617/1635
54314 240/1450/1451/1452
54329 238/240/1450/1451/1452
57399 113/177/1148/1451
57423 240/412/1251/1450
57476 240/1450/1451/1452
57483 31/240/1450/1451/1452
57542 240/1450/1451/1452
57549 31/240/1450/1451/1452
60659 197/412/1607/1608/1609
61140 238/1450/1451/1452
61217 240/1450/1451/1452
61236 238/240/1450/1451/1452
61237 240/1450/1451/1452
61277 183/238/1570/1571/1596
64439 31/240/1450/1451/1452
64443 197/1450/1451/1452
64489 240/1450/1451/1452
64494 31/240/1450/1451/1452
67626 197/412/1607/1608/1609
68117 238/1450/1451/1452
68133 240/1450/1451/1452
68134 31/197/238/1451
68193 240/1450/1451/1452
68245 31/240/1450/1451/1452
68252 183/1570/1571/1596
68253 238/1450/1451/1498
68261 31/240/1450/1451/1452
71280 31/238/1450/1451/1452/1596/1602
71302 31/89/238/412
71328 28/31/229/1574/1596/1602
71358 31/240/1450/1451/1452
71413 240/1450/1451/1452
71418 240/1450/1451/1452
71422 31/240/1450/1451/1452
71434 31/240/1450/1451/1452
\.

COPY q12c_expected (q12) FROM stdin;
23034 1576/1577/1578/1596
26856 1576/1577/1578/1596
30024 1576/1577/1578/1596
30046 1576/1577/1578/1596
37157 53/106/1278/1541
40867 1576/1577/1578/1596
47933 1576/1577/1578/1596
54961 1576/1577/1578/1596
61890 1576/1577/1578/1596
68847 1576/1577/1578/1596
\.

COPY q12d_expected (q12) FROM stdin;
2695 52/229/1568/1569
2699 52/229/1568/1569
9212 52/229/1568/1569
9224 52/229/1568/1569
9225 52/229/1568/1569
25001 52/229/1568/1569
28563 52/229/1568/1569/1602
28565 52/229/1568/1569
31671 229/1569/1602/1632
31677 52/229/1568/1569
31694 52/229/1568/1569
35386 52/229/1568/1569/1602
35388 52/229/1568/1569/1632
42397 52/229/1568/1569/1602
42399 52/229/1568/1569
42410 52/229/1568/1569
45761 52/229/1568/1569
45777 52/229/1568/1569
49475 52/229/1568/1569/1602
49477 52/229/1568/1569
49488 52/229/1568/1569
52842 52/229/1568/1569
56393 52/229/1568/1569
56404 52/229/1568/1569
59695 52/229/1568/1569
59708 52/229/1568/1569
63349 52/229/1568/1569
63361 52/229/1568/1569
66722 52/229/1568/1569
70263 52/229/1568/1569
70274 52/229/1568/1569
73582 52/229/1568/1569
\.

COPY q12e_expected (q12) FROM stdin;
4713 52/217/1568/1569
4714 52/217/1568/1569
6906 52/217/1568/1569
6907 52/217/1568/1569
9131 52/217/1568/1569
9132 52/217/1568/1569
21288 52/217/1568/1569
21289 52/217/1568/1569
21290 52/217/1568/1569
21291 52/217/1568/1569
21294 52/217/1568/1569
21295 52/217/1568/1569
25970 52/217/1568/1569
25971 52/217/1568/1569
31598 52/217/1568/1569
31615 52/217/1568/1569
35309 52/217/1568/1569
35318 52/217/1568/1569
35323 52/217/1568/1569
42319 52/217/1568/1569
42338 52/217/1568/1569
59613 52/217/1568/1569/1594
66624 52/217/1568/1569/1594
73488 52/217/1568/1569/1594
\.
