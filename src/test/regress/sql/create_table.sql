--
-- CREATE_TABLE
--

--
-- CLASS DEFINITIONS
--
CREATE TABLE hobbies_r (
	name		text, 
	person 		text
);

CREATE TABLE equipment_r (
	name 		text,
	hobby		text
);

CREATE TABLE onek (
	unique1		int4,
	unique2		int4,
	two			int4,
	four		int4,
	ten			int4,
	twenty		int4,
	hundred		int4,
	thousand	int4,
	twothousand	int4,
	fivethous	int4,
	tenthous	int4,
	odd			int4,
	even		int4,
	stringu1	name,
	stringu2	name,
	string4		name
);

CREATE TABLE tenk1 (
	unique1		int4,
	unique2		int4,
	two			int4,
	four		int4,
	ten			int4,
	twenty		int4,
	hundred		int4,
	thousand	int4,
	twothousand	int4,
	fivethous	int4,
	tenthous	int4,
	odd			int4,
	even		int4,
	stringu1	name,
	stringu2	name,
	string4		name
) WITH OIDS;

CREATE TABLE tenk2 (
	unique1 	int4,
	unique2 	int4,
	two 	 	int4,
	four 		int4,
	ten			int4,
	twenty 		int4,
	hundred 	int4,
	thousand 	int4,
	twothousand int4,
	fivethous 	int4,
	tenthous	int4,
	odd			int4,
	even		int4,
	stringu1	name,
	stringu2	name,
	string4		name
);


CREATE TABLE person (
	name 		text,
	age			int4,
	location 	point
);


CREATE TABLE emp (
	salary 		int4,
	manager 	name
) INHERITS (person) WITH OIDS;


CREATE TABLE student (
	gpa 		float8
) INHERITS (person);


CREATE TABLE stud_emp (
	percent 	int4
) INHERITS (emp, student);


CREATE TABLE city (
	name		name,
	location 	box,
	budget 		city_budget
);

CREATE TABLE dept (
	dname		name,
	mgrname 	text
);

CREATE TABLE slow_emp4000 (
	home_base	 box
);

CREATE TABLE fast_emp4000 (
	home_base	 box
);

CREATE TABLE road (
	name		text,
	thepath 	path
);

CREATE TABLE ihighway () INHERITS (road);

CREATE TABLE shighway (
	surface		text
) INHERITS (road);

CREATE TABLE real_city (
	pop			int4,
	cname		text,
	outline 	path
);

--
-- test the "star" operators a bit more thoroughly -- this time,
-- throw in lots of NULL fields...
--
-- a is the type root
-- b and c inherit from a (one-level single inheritance)
-- d inherits from b and c (two-level multiple inheritance)
-- e inherits from c (two-level single inheritance)
-- f inherits from e (three-level single inheritance)
--
CREATE TABLE a_star (
	class		char, 
	a 			int4
);

CREATE TABLE b_star (
	b 			text
) INHERITS (a_star);

CREATE TABLE c_star (
	c 			name
) INHERITS (a_star);

CREATE TABLE d_star (
	d 			float8
) INHERITS (b_star, c_star);

CREATE TABLE e_star (
	e 			int2
) INHERITS (c_star);

CREATE TABLE f_star (
	f 			polygon
) INHERITS (e_star);

CREATE TABLE aggtest (
	a 			int2,
	b			float4
);

CREATE TABLE hash_i4_heap (
	seqno 		int4,
	random 		int4
) distributed by (seqno);

CREATE TABLE hash_name_heap (
	seqno 		int4,
	random 		name
) distributed by (seqno);

CREATE TABLE hash_txt_heap (
	seqno 		int4,
	random 		text
) distributed by (seqno);

CREATE TABLE hash_f8_heap (
	seqno		int4,
	random 		float8
) distributed by (seqno);

-- don't include the hash_ovfl_heap stuff in the distribution
-- the data set is too large for what it's worth
-- 
-- CREATE TABLE hash_ovfl_heap (
--	x			int4,
--	y			int4
-- );

CREATE TABLE bt_i4_heap (
	seqno 		int4,
	random 		int4
);

CREATE TABLE bt_name_heap (
	seqno 		name,
	random 		int4
);

CREATE TABLE bt_txt_heap (
	seqno 		text,
	random 		int4
);

CREATE TABLE bt_f8_heap (
	seqno 		float8, 
	random 		int4
);

CREATE TABLE array_op_test (
	seqno		int4,
	i			int4[],
	t			text[]
);

CREATE TABLE array_index_op_test (
	seqno		int4,
	i			int4[],
	t			text[]
);

--MPP-22020: Dis-allow duplicate constraint names for the same table.
create table dupconstr (
						i int,
						j int constraint test CHECK (j > 10),
						CONSTRAINT test UNIQUE (i,j))
						distributed by (i);

-- MPP-2764: distributed randomly is not compatible with primary key or unique
-- constraints
create table distrand(i int, j int, primary key (i)) distributed randomly;
create table distrand(i int, j int, unique (i)) distributed randomly;
create table distrand(i int, j int, primary key (i, j)) distributed randomly;
create table distrand(i int, j int, unique (i, j)) distributed randomly;
create table distrand(i int, j int, constraint "test" primary key (i)) 
   distributed randomly;
create table distrand(i int, j int, constraint "test" unique (i)) 
   distributed randomly;
-- this should work though
create table distrand(i int, j int, constraint "test" unique (i, j)) 
   distributed by(i, j);
drop table distrand;
create table distrand(i int, j int) distributed randomly;
create unique index distrand_idx on distrand(i);
drop table distrand; 

-- Make sure distribution policy determined from CTAS actually works, MPP-101
create table distpol as select random(), 1 as a, 2 as b distributed by (random);
select attrnums from gp_distribution_policy where 
  localoid = 'distpol'::regclass;
drop table distpol;
create table distpol as select random(), 2 as foo distributed by (foo);
select attrnums from gp_distribution_policy where 
  localoid = 'distpol'::regclass;
drop table distpol;
-- now test that MPP-101 /actually/ works
create table distpol (i int, j int, k int) distributed by (i);
alter table distpol add primary key (j);
select attrnums from gp_distribution_policy where 
  localoid = 'distpol'::regclass;
-- make sure we can't overwrite it
create unique index distpol_uidx on distpol(k);
-- should be able to now
alter table distpol drop constraint distpol_pkey;
create unique index distpol_uidx on distpol(k);
select attrnums from gp_distribution_policy where 
  localoid = 'distpol'::regclass;
drop index distpol_uidx;
-- expressions shouldn't be able to update the distribution key
create unique index distpol_uidx on distpol(ln(k));
drop index distpol_uidx;
-- lets make sure we don't change the policy when the table is full
insert into distpol values(1, 2, 3);
create unique index distpol_uidx on distpol(i);
alter table distpol add primary key (i);
drop table distpol;

-- MPP-2872: set ops with distributed by should work as advertised
create table distpol1 (i int, j int);
create table distpol2 (i int, j int);
create table distpol3 as select i, j from distpol1 union 
  select i, j from distpol2 distributed by (j);
select attrnums from gp_distribution_policy where
  localoid = 'distpol3'::regclass;
drop table distpol3;
create table distpol3 as (select i, j from distpol1 union
  select i, j from distpol2) distributed by (j);
select attrnums from gp_distribution_policy where
  localoid = 'distpol3'::regclass;


-- MPP-7268: CTAS produces incorrect distribution.
drop table if exists foo;
drop table if exists bar;
create table foo (a varchar(15), b int) distributed by (b);
create table bar as select * from foo distributed by (b);
select attrnums from gp_distribution_policy where localoid='bar'::regclass;

drop table if exists foo;
drop table if exists bar;
create table foo (a int, b varchar(15)) distributed by (b);
create table bar as select * from foo distributed by (b);
select attrnums from gp_distribution_policy where localoid='bar'::regclass;

drop table if exists foo;
drop table if exists bar;

CREATE TABLE foo (
col_with_default numeric DEFAULT 0,
col_with_default_drop_default character varying(30) DEFAULT 'test1',
col_with_constraint numeric UNIQUE
) DISTRIBUTED BY (col_with_constraint);

CREATE TABLE bar AS SELECT * FROM foo distributed by (col_with_constraint);
select attrnums from gp_distribution_policy where localoid='bar'::regclass;

drop table if exists foo;
drop table if exists bar;

-- MPP-14770: check for duplicate columns in DISTRIBUTED BY clause
create table foo (a int, b text) distributed by (b,B);
create table foo (a int, b int) distributed by (a,aA,A);
create table foo (a int, b int) distributed by (b,a,aabb);
create table foo (a int, b int) distributed by (c,C);
create table foo ("I" int, i int) distributed by ("I",I);
select attrnums from gp_distribution_policy where localoid='foo'::regclass;
drop table if exists foo;

-- check if number of DISTRIBUTED BY clause exceed the limitation (1600)
create table foo (
c1 int,c2 int,c3 int,c4 int,c5 int,c6 int,c7 int,c8 int,c9 int,c10 int,c11 int,c12 int,c13 int,c14 int,c15 int,c16 int,c17 int,c18 int,c19 int,c20 int,c21 int,c22 int,c23 int,c24 int,c25 int,c26 int,c27 int,c28 int,c29 int,c30 int,c31 int,c32 int,c33 int,c34 int,c35 int,c36 int,c37 int,c38 int,c39 int,c40 int,c41 int,c42 int,c43 int,c44 int,c45 int,c46 int,c47 int,c48 int,c49 int,c50 int,c51 int,c52 int,c53 int,c54 int,c55 int,c56 int,c57 int,c58 int,c59 int,c60 int,c61 int,c62 int,c63 int,c64 int,c65 int,c66 int,c67 int,c68 int,c69 int,c70 int,c71 int,c72 int,c73 int,c74 int,c75 int,c76 int,c77 int,c78 int,c79 int,c80 int,c81 int,c82 int,c83 int,c84 int,c85 int,c86 int,c87 int,c88 int,c89 int,c90 int,c91 int,c92 int,c93 int,c94 int,c95 int,c96 int,c97 int,c98 int,c99 int,c100 int,c101 int,c102 int,c103 int,c104 int,c105 int,c106 int,c107 int,c108 int,c109 int,c110 int,c111 int,c112 int,c113 int,c114 int,c115 int,c116 int,c117 int,c118 int,c119 int,c120 int,c121 int,c122 int,c123 int,c124 int,c125 int,c126 int,c127 int,c128 int,c129 int,c130 int,c131 int,c132 int,c133 int,c134 int,c135 int,c136 int,c137 int,c138 int,c139 int,c140 int,c141 int,c142 int,c143 int,c144 int,c145 int,c146 int,c147 int,c148 int,c149 int,c150 int,c151 int,c152 int,c153 int,c154 int,c155 int,c156 int,c157 int,c158 int,c159 int,c160 int,c161 int,c162 int,c163 int,c164 int,c165 int,c166 int,c167 int,c168 int,c169 int,c170 int,c171 int,c172 int,c173 int,c174 int,c175 int,c176 int,c177 int,c178 int,c179 int,c180 int,c181 int,c182 int,c183 int,c184 int,c185 int,c186 int,c187 int,c188 int,c189 int,c190 int,c191 int,c192 int,c193 int,c194 int,c195 int,c196 int,c197 int,c198 int,c199 int,c200 int,c201 int,c202 int,c203 int,c204 int,c205 int,c206 int,c207 int,c208 int,c209 int,c210 int,c211 int,c212 int,c213 int,c214 int,c215 int,c216 int,c217 int,c218 int,c219 int,c220 int,c221 int,c222 int,c223 int,c224 int,c225 int,c226 int,c227 int,c228 int,c229 int,c230 int,c231 int,c232 int,c233 int,c234 int,c235 int,c236 int,c237 int,c238 int,c239 int,c240 int,c241 int,c242 int,c243 int,c244 int,c245 int,c246 int,c247 int,c248 int,c249 int,c250 int,c251 int,c252 int,c253 int,c254 int,c255 int,c256 int,c257 int,c258 int,c259 int,c260 int,c261 int,c262 int,c263 int,c264 int,c265 int,c266 int,c267 int,c268 int,c269 int,c270 int,c271 int,c272 int,c273 int,c274 int,c275 int,c276 int,c277 int,c278 int,c279 int,c280 int,c281 int,c282 int,c283 int,c284 int,c285 int,c286 int,c287 int,c288 int,c289 int,c290 int,c291 int,c292 int,c293 int,c294 int,c295 int,c296 int,c297 int,c298 int,c299 int,c300 int,c301 int,c302 int,c303 int,c304 int,c305 int,c306 int,c307 int,c308 int,c309 int,c310 int,c311 int,c312 int,c313 int,c314 int,c315 int,c316 int,c317 int,c318 int,c319 int,c320 int,c321 int,c322 int,c323 int,c324 int,c325 int,c326 int,c327 int,c328 int,c329 int,c330 int,c331 int,c332 int,c333 int,c334 int,c335 int,c336 int,c337 int,c338 int,c339 int,c340 int,c341 int,c342 int,c343 int,c344 int,c345 int,c346 int,c347 int,c348 int,c349 int,c350 int,c351 int,c352 int,c353 int,c354 int,c355 int,c356 int,c357 int,c358 int,c359 int,c360 int,c361 int,c362 int,c363 int,c364 int,c365 int,c366 int,c367 int,c368 int,c369 int,c370 int,c371 int,c372 int,c373 int,c374 int,c375 int,c376 int,c377 int,c378 int,c379 int,c380 int,c381 int,c382 int,c383 int,c384 int,c385 int,c386 int,c387 int,c388 int,c389 int,c390 int,c391 int,c392 int,c393 int,c394 int,c395 int,c396 int,c397 int,c398 int,c399 int,c400 int,c401 int,c402 int,c403 int,c404 int,c405 int,c406 int,c407 int,c408 int,c409 int,c410 int,c411 int,c412 int,c413 int,c414 int,c415 int,c416 int,c417 int,c418 int,c419 int,c420 int,c421 int,c422 int,c423 int,c424 int,c425 int,c426 int,c427 int,c428 int,c429 int,c430 int,c431 int,c432 int,c433 int,c434 int,c435 int,c436 int,c437 int,c438 int,c439 int,c440 int,c441 int,c442 int,c443 int,c444 int,c445 int,c446 int,c447 int,c448 int,c449 int,c450 int,c451 int,c452 int,c453 int,c454 int,c455 int,c456 int,c457 int,c458 int,c459 int,c460 int,c461 int,c462 int,c463 int,c464 int,c465 int,c466 int,c467 int,c468 int,c469 int,c470 int,c471 int,c472 int,c473 int,c474 int,c475 int,c476 int,c477 int,c478 int,c479 int,c480 int,c481 int,c482 int,c483 int,c484 int,c485 int,c486 int,c487 int,c488 int,c489 int,c490 int,c491 int,c492 int,c493 int,c494 int,c495 int,c496 int,c497 int,c498 int,c499 int,c500 int,c501 int,c502 int,c503 int,c504 int,c505 int,c506 int,c507 int,c508 int,c509 int,c510 int,c511 int,c512 int,c513 int,c514 int,c515 int,c516 int,c517 int,c518 int,c519 int,c520 int,c521 int,c522 int,c523 int,c524 int,c525 int,c526 int,c527 int,c528 int,c529 int,c530 int,c531 int,c532 int,c533 int,c534 int,c535 int,c536 int,c537 int,c538 int,c539 int,c540 int,c541 int,c542 int,c543 int,c544 int,c545 int,c546 int,c547 int,c548 int,c549 int,c550 int,c551 int,c552 int,c553 int,c554 int,c555 int,c556 int,c557 int,c558 int,c559 int,c560 int,c561 int,c562 int,c563 int,c564 int,c565 int,c566 int,c567 int,c568 int,c569 int,c570 int,c571 int,c572 int,c573 int,c574 int,c575 int,c576 int,c577 int,c578 int,c579 int,c580 int,c581 int,c582 int,c583 int,c584 int,c585 int,c586 int,c587 int,c588 int,c589 int,c590 int,c591 int,c592 int,c593 int,c594 int,c595 int,c596 int,c597 int,c598 int,c599 int,c600 int,c601 int,c602 int,c603 int,c604 int,c605 int,c606 int,c607 int,c608 int,c609 int,c610 int,c611 int,c612 int,c613 int,c614 int,c615 int,c616 int,c617 int,c618 int,c619 int,c620 int,c621 int,c622 int,c623 int,c624 int,c625 int,c626 int,c627 int,c628 int,c629 int,c630 int,c631 int,c632 int,c633 int,c634 int,c635 int,c636 int,c637 int,c638 int,c639 int,c640 int,c641 int,c642 int,c643 int,c644 int,c645 int,c646 int,c647 int,c648 int,c649 int,c650 int,c651 int,c652 int,c653 int,c654 int,c655 int,c656 int,c657 int,c658 int,c659 int,c660 int,c661 int,c662 int,c663 int,c664 int,c665 int,c666 int,c667 int,c668 int,c669 int,c670 int,c671 int,c672 int,c673 int,c674 int,c675 int,c676 int,c677 int,c678 int,c679 int,c680 int,c681 int,c682 int,c683 int,c684 int,c685 int,c686 int,c687 int,c688 int,c689 int,c690 int,c691 int,c692 int,c693 int,c694 int,c695 int,c696 int,c697 int,c698 int,c699 int,c700 int,c701 int,c702 int,c703 int,c704 int,c705 int,c706 int,c707 int,c708 int,c709 int,c710 int,c711 int,c712 int,c713 int,c714 int,c715 int,c716 int,c717 int,c718 int,c719 int,c720 int,c721 int,c722 int,c723 int,c724 int,c725 int,c726 int,c727 int,c728 int,c729 int,c730 int,c731 int,c732 int,c733 int,c734 int,c735 int,c736 int,c737 int,c738 int,c739 int,c740 int,c741 int,c742 int,c743 int,c744 int,c745 int,c746 int,c747 int,c748 int,c749 int,c750 int,c751 int,c752 int,c753 int,c754 int,c755 int,c756 int,c757 int,c758 int,c759 int,c760 int,c761 int,c762 int,c763 int,c764 int,c765 int,c766 int,c767 int,c768 int,c769 int,c770 int,c771 int,c772 int,c773 int,c774 int,c775 int,c776 int,c777 int,c778 int,c779 int,c780 int,c781 int,c782 int,c783 int,c784 int,c785 int,c786 int,c787 int,c788 int,c789 int,c790 int,c791 int,c792 int,c793 int,c794 int,c795 int,c796 int,c797 int,c798 int,c799 int,c800 int,c801 int,c802 int,c803 int,c804 int,c805 int,c806 int,c807 int,c808 int,c809 int,c810 int,c811 int,c812 int,c813 int,c814 int,c815 int,c816 int,c817 int,c818 int,c819 int,c820 int,c821 int,c822 int,c823 int,c824 int,c825 int,c826 int,c827 int,c828 int,c829 int,c830 int,c831 int,c832 int,c833 int,c834 int,c835 int,c836 int,c837 int,c838 int,c839 int,c840 int,c841 int,c842 int,c843 int,c844 int,c845 int,c846 int,c847 int,c848 int,c849 int,c850 int,c851 int,c852 int,c853 int,c854 int,c855 int,c856 int,c857 int,c858 int,c859 int,c860 int,c861 int,c862 int,c863 int,c864 int,c865 int,c866 int,c867 int,c868 int,c869 int,c870 int,c871 int,c872 int,c873 int,c874 int,c875 int,c876 int,c877 int,c878 int,c879 int,c880 int,c881 int,c882 int,c883 int,c884 int,c885 int,c886 int,c887 int,c888 int,c889 int,c890 int,c891 int,c892 int,c893 int,c894 int,c895 int,c896 int,c897 int,c898 int,c899 int,c900 int,c901 int,c902 int,c903 int,c904 int,c905 int,c906 int,c907 int,c908 int,c909 int,c910 int,c911 int,c912 int,c913 int,c914 int,c915 int,c916 int,c917 int,c918 int,c919 int,c920 int,c921 int,c922 int,c923 int,c924 int,c925 int,c926 int,c927 int,c928 int,c929 int,c930 int,c931 int,c932 int,c933 int,c934 int,c935 int,c936 int,c937 int,c938 int,c939 int,c940 int,c941 int,c942 int,c943 int,c944 int,c945 int,c946 int,c947 int,c948 int,c949 int,c950 int,c951 int,c952 int,c953 int,c954 int,c955 int,c956 int,c957 int,c958 int,c959 int,c960 int,c961 int,c962 int,c963 int,c964 int,c965 int,c966 int,c967 int,c968 int,c969 int,c970 int,c971 int,c972 int,c973 int,c974 int,c975 int,c976 int,c977 int,c978 int,c979 int,c980 int,c981 int,c982 int,c983 int,c984 int,c985 int,c986 int,c987 int,c988 int,c989 int,c990 int,c991 int,c992 int,c993 int,c994 int,c995 int,c996 int,c997 int,c998 int,c999 int,c1000 int,c1001 int,c1002 int,c1003 int,c1004 int,c1005 int,c1006 int,c1007 int,c1008 int,c1009 int,c1010 int,c1011 int,c1012 int,c1013 int,c1014 int,c1015 int,c1016 int,c1017 int,c1018 int,c1019 int,c1020 int,c1021 int,c1022 int,c1023 int,c1024 int,c1025 int,c1026 int,c1027 int,c1028 int,c1029 int,c1030 int,c1031 int,c1032 int,c1033 int,c1034 int,c1035 int,c1036 int,c1037 int,c1038 int,c1039 int,c1040 int,c1041 int,c1042 int,c1043 int,c1044 int,c1045 int,c1046 int,c1047 int,c1048 int,c1049 int,c1050 int,c1051 int,c1052 int,c1053 int,c1054 int,c1055 int,c1056 int,c1057 int,c1058 int,c1059 int,c1060 int,c1061 int,c1062 int,c1063 int,c1064 int,c1065 int,c1066 int,c1067 int,c1068 int,c1069 int,c1070 int,c1071 int,c1072 int,c1073 int,c1074 int,c1075 int,c1076 int,c1077 int,c1078 int,c1079 int,c1080 int,c1081 int,c1082 int,c1083 int,c1084 int,c1085 int,c1086 int,c1087 int,c1088 int,c1089 int,c1090 int,c1091 int,c1092 int,c1093 int,c1094 int,c1095 int,c1096 int,c1097 int,c1098 int,c1099 int,c1100 int,c1101 int,c1102 int,c1103 int,c1104 int,c1105 int,c1106 int,c1107 int,c1108 int,c1109 int,c1110 int,c1111 int,c1112 int,c1113 int,c1114 int,c1115 int,c1116 int,c1117 int,c1118 int,c1119 int,c1120 int,c1121 int,c1122 int,c1123 int,c1124 int,c1125 int,c1126 int,c1127 int,c1128 int,c1129 int,c1130 int,c1131 int,c1132 int,c1133 int,c1134 int,c1135 int,c1136 int,c1137 int,c1138 int,c1139 int,c1140 int,c1141 int,c1142 int,c1143 int,c1144 int,c1145 int,c1146 int,c1147 int,c1148 int,c1149 int,c1150 int,c1151 int,c1152 int,c1153 int,c1154 int,c1155 int,c1156 int,c1157 int,c1158 int,c1159 int,c1160 int,c1161 int,c1162 int,c1163 int,c1164 int,c1165 int,c1166 int,c1167 int,c1168 int,c1169 int,c1170 int,c1171 int,c1172 int,c1173 int,c1174 int,c1175 int,c1176 int,c1177 int,c1178 int,c1179 int,c1180 int,c1181 int,c1182 int,c1183 int,c1184 int,c1185 int,c1186 int,c1187 int,c1188 int,c1189 int,c1190 int,c1191 int,c1192 int,c1193 int,c1194 int,c1195 int,c1196 int,c1197 int,c1198 int,c1199 int,c1200 int,c1201 int,c1202 int,c1203 int,c1204 int,c1205 int,c1206 int,c1207 int,c1208 int,c1209 int,c1210 int,c1211 int,c1212 int,c1213 int,c1214 int,c1215 int,c1216 int,c1217 int,c1218 int,c1219 int,c1220 int,c1221 int,c1222 int,c1223 int,c1224 int,c1225 int,c1226 int,c1227 int,c1228 int,c1229 int,c1230 int,c1231 int,c1232 int,c1233 int,c1234 int,c1235 int,c1236 int,c1237 int,c1238 int,c1239 int,c1240 int,c1241 int,c1242 int,c1243 int,c1244 int,c1245 int,c1246 int,c1247 int,c1248 int,c1249 int,c1250 int,c1251 int,c1252 int,c1253 int,c1254 int,c1255 int,c1256 int,c1257 int,c1258 int,c1259 int,c1260 int,c1261 int,c1262 int,c1263 int,c1264 int,c1265 int,c1266 int,c1267 int,c1268 int,c1269 int,c1270 int,c1271 int,c1272 int,c1273 int,c1274 int,c1275 int,c1276 int,c1277 int,c1278 int,c1279 int,c1280 int,c1281 int,c1282 int,c1283 int,c1284 int,c1285 int,c1286 int,c1287 int,c1288 int,c1289 int,c1290 int,c1291 int,c1292 int,c1293 int,c1294 int,c1295 int,c1296 int,c1297 int,c1298 int,c1299 int,c1300 int,c1301 int,c1302 int,c1303 int,c1304 int,c1305 int,c1306 int,c1307 int,c1308 int,c1309 int,c1310 int,c1311 int,c1312 int,c1313 int,c1314 int,c1315 int,c1316 int,c1317 int,c1318 int,c1319 int,c1320 int,c1321 int,c1322 int,c1323 int,c1324 int,c1325 int,c1326 int,c1327 int,c1328 int,c1329 int,c1330 int,c1331 int,c1332 int,c1333 int,c1334 int,c1335 int,c1336 int,c1337 int,c1338 int,c1339 int,c1340 int,c1341 int,c1342 int,c1343 int,c1344 int,c1345 int,c1346 int,c1347 int,c1348 int,c1349 int,c1350 int,c1351 int,c1352 int,c1353 int,c1354 int,c1355 int,c1356 int,c1357 int,c1358 int,c1359 int,c1360 int,c1361 int,c1362 int,c1363 int,c1364 int,c1365 int,c1366 int,c1367 int,c1368 int,c1369 int,c1370 int,c1371 int,c1372 int,c1373 int,c1374 int,c1375 int,c1376 int,c1377 int,c1378 int,c1379 int,c1380 int,c1381 int,c1382 int,c1383 int,c1384 int,c1385 int,c1386 int,c1387 int,c1388 int,c1389 int,c1390 int,c1391 int,c1392 int,c1393 int,c1394 int,c1395 int,c1396 int,c1397 int,c1398 int,c1399 int,c1400 int,c1401 int,c1402 int,c1403 int,c1404 int,c1405 int,c1406 int,c1407 int,c1408 int,c1409 int,c1410 int,c1411 int,c1412 int,c1413 int,c1414 int,c1415 int,c1416 int,c1417 int,c1418 int,c1419 int,c1420 int,c1421 int,c1422 int,c1423 int,c1424 int,c1425 int,c1426 int,c1427 int,c1428 int,c1429 int,c1430 int,c1431 int,c1432 int,c1433 int,c1434 int,c1435 int,c1436 int,c1437 int,c1438 int,c1439 int,c1440 int,c1441 int,c1442 int,c1443 int,c1444 int,c1445 int,c1446 int,c1447 int,c1448 int,c1449 int,c1450 int,c1451 int,c1452 int,c1453 int,c1454 int,c1455 int,c1456 int,c1457 int,c1458 int,c1459 int,c1460 int,c1461 int,c1462 int,c1463 int,c1464 int,c1465 int,c1466 int,c1467 int,c1468 int,c1469 int,c1470 int,c1471 int,c1472 int,c1473 int,c1474 int,c1475 int,c1476 int,c1477 int,c1478 int,c1479 int,c1480 int,c1481 int,c1482 int,c1483 int,c1484 int,c1485 int,c1486 int,c1487 int,c1488 int,c1489 int,c1490 int,c1491 int,c1492 int,c1493 int,c1494 int,c1495 int,c1496 int,c1497 int,c1498 int,c1499 int,c1500 int,c1501 int,c1502 int,c1503 int,c1504 int,c1505 int,c1506 int,c1507 int,c1508 int,c1509 int,c1510 int,c1511 int,c1512 int,c1513 int,c1514 int,c1515 int,c1516 int,c1517 int,c1518 int,c1519 int,c1520 int,c1521 int,c1522 int,c1523 int,c1524 int,c1525 int,c1526 int,c1527 int,c1528 int,c1529 int,c1530 int,c1531 int,c1532 int,c1533 int,c1534 int,c1535 int,c1536 int,c1537 int,c1538 int,c1539 int,c1540 int,c1541 int,c1542 int,c1543 int,c1544 int,c1545 int,c1546 int,c1547 int,c1548 int,c1549 int,c1550 int,c1551 int,c1552 int,c1553 int,c1554 int,c1555 int,c1556 int,c1557 int,c1558 int,c1559 int,c1560 int,c1561 int,c1562 int,c1563 int,c1564 int,c1565 int,c1566 int,c1567 int,c1568 int,c1569 int,c1570 int,c1571 int,c1572 int,c1573 int,c1574 int,c1575 int,c1576 int,c1577 int,c1578 int,c1579 int,c1580 int,c1581 int,c1582 int,c1583 int,c1584 int,c1585 int,c1586 int,c1587 int,c1588 int,c1589 int,c1590 int,c1591 int,c1592 int,c1593 int,c1594 int,c1595 int,c1596 int,c1597 int,c1598 int,c1599 int,c1600 int
) distributed by
(
c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c35,c36,c37,c38,c39,c40,c41,c42,c43,c44,c45,c46,c47,c48,c49,c50,c51,c52,c53,c54,c55,c56,c57,c58,c59,c60,c61,c62,c63,c64,c65,c66,c67,c68,c69,c70,c71,c72,c73,c74,c75,c76,c77,c78,c79,c80,c81,c82,c83,c84,c85,c86,c87,c88,c89,c90,c91,c92,c93,c94,c95,c96,c97,c98,c99,c100,c101,c102,c103,c104,c105,c106,c107,c108,c109,c110,c111,c112,c113,c114,c115,c116,c117,c118,c119,c120,c121,c122,c123,c124,c125,c126,c127,c128,c129,c130,c131,c132,c133,c134,c135,c136,c137,c138,c139,c140,c141,c142,c143,c144,c145,c146,c147,c148,c149,c150,c151,c152,c153,c154,c155,c156,c157,c158,c159,c160,c161,c162,c163,c164,c165,c166,c167,c168,c169,c170,c171,c172,c173,c174,c175,c176,c177,c178,c179,c180,c181,c182,c183,c184,c185,c186,c187,c188,c189,c190,c191,c192,c193,c194,c195,c196,c197,c198,c199,c200,c201,c202,c203,c204,c205,c206,c207,c208,c209,c210,c211,c212,c213,c214,c215,c216,c217,c218,c219,c220,c221,c222,c223,c224,c225,c226,c227,c228,c229,c230,c231,c232,c233,c234,c235,c236,c237,c238,c239,c240,c241,c242,c243,c244,c245,c246,c247,c248,c249,c250,c251,c252,c253,c254,c255,c256,c257,c258,c259,c260,c261,c262,c263,c264,c265,c266,c267,c268,c269,c270,c271,c272,c273,c274,c275,c276,c277,c278,c279,c280,c281,c282,c283,c284,c285,c286,c287,c288,c289,c290,c291,c292,c293,c294,c295,c296,c297,c298,c299,c300,c301,c302,c303,c304,c305,c306,c307,c308,c309,c310,c311,c312,c313,c314,c315,c316,c317,c318,c319,c320,c321,c322,c323,c324,c325,c326,c327,c328,c329,c330,c331,c332,c333,c334,c335,c336,c337,c338,c339,c340,c341,c342,c343,c344,c345,c346,c347,c348,c349,c350,c351,c352,c353,c354,c355,c356,c357,c358,c359,c360,c361,c362,c363,c364,c365,c366,c367,c368,c369,c370,c371,c372,c373,c374,c375,c376,c377,c378,c379,c380,c381,c382,c383,c384,c385,c386,c387,c388,c389,c390,c391,c392,c393,c394,c395,c396,c397,c398,c399,c400,c401,c402,c403,c404,c405,c406,c407,c408,c409,c410,c411,c412,c413,c414,c415,c416,c417,c418,c419,c420,c421,c422,c423,c424,c425,c426,c427,c428,c429,c430,c431,c432,c433,c434,c435,c436,c437,c438,c439,c440,c441,c442,c443,c444,c445,c446,c447,c448,c449,c450,c451,c452,c453,c454,c455,c456,c457,c458,c459,c460,c461,c462,c463,c464,c465,c466,c467,c468,c469,c470,c471,c472,c473,c474,c475,c476,c477,c478,c479,c480,c481,c482,c483,c484,c485,c486,c487,c488,c489,c490,c491,c492,c493,c494,c495,c496,c497,c498,c499,c500,c501,c502,c503,c504,c505,c506,c507,c508,c509,c510,c511,c512,c513,c514,c515,c516,c517,c518,c519,c520,c521,c522,c523,c524,c525,c526,c527,c528,c529,c530,c531,c532,c533,c534,c535,c536,c537,c538,c539,c540,c541,c542,c543,c544,c545,c546,c547,c548,c549,c550,c551,c552,c553,c554,c555,c556,c557,c558,c559,c560,c561,c562,c563,c564,c565,c566,c567,c568,c569,c570,c571,c572,c573,c574,c575,c576,c577,c578,c579,c580,c581,c582,c583,c584,c585,c586,c587,c588,c589,c590,c591,c592,c593,c594,c595,c596,c597,c598,c599,c600,c601,c602,c603,c604,c605,c606,c607,c608,c609,c610,c611,c612,c613,c614,c615,c616,c617,c618,c619,c620,c621,c622,c623,c624,c625,c626,c627,c628,c629,c630,c631,c632,c633,c634,c635,c636,c637,c638,c639,c640,c641,c642,c643,c644,c645,c646,c647,c648,c649,c650,c651,c652,c653,c654,c655,c656,c657,c658,c659,c660,c661,c662,c663,c664,c665,c666,c667,c668,c669,c670,c671,c672,c673,c674,c675,c676,c677,c678,c679,c680,c681,c682,c683,c684,c685,c686,c687,c688,c689,c690,c691,c692,c693,c694,c695,c696,c697,c698,c699,c700,c701,c702,c703,c704,c705,c706,c707,c708,c709,c710,c711,c712,c713,c714,c715,c716,c717,c718,c719,c720,c721,c722,c723,c724,c725,c726,c727,c728,c729,c730,c731,c732,c733,c734,c735,c736,c737,c738,c739,c740,c741,c742,c743,c744,c745,c746,c747,c748,c749,c750,c751,c752,c753,c754,c755,c756,c757,c758,c759,c760,c761,c762,c763,c764,c765,c766,c767,c768,c769,c770,c771,c772,c773,c774,c775,c776,c777,c778,c779,c780,c781,c782,c783,c784,c785,c786,c787,c788,c789,c790,c791,c792,c793,c794,c795,c796,c797,c798,c799,c800,c801,c802,c803,c804,c805,c806,c807,c808,c809,c810,c811,c812,c813,c814,c815,c816,c817,c818,c819,c820,c821,c822,c823,c824,c825,c826,c827,c828,c829,c830,c831,c832,c833,c834,c835,c836,c837,c838,c839,c840,c841,c842,c843,c844,c845,c846,c847,c848,c849,c850,c851,c852,c853,c854,c855,c856,c857,c858,c859,c860,c861,c862,c863,c864,c865,c866,c867,c868,c869,c870,c871,c872,c873,c874,c875,c876,c877,c878,c879,c880,c881,c882,c883,c884,c885,c886,c887,c888,c889,c890,c891,c892,c893,c894,c895,c896,c897,c898,c899,c900,c901,c902,c903,c904,c905,c906,c907,c908,c909,c910,c911,c912,c913,c914,c915,c916,c917,c918,c919,c920,c921,c922,c923,c924,c925,c926,c927,c928,c929,c930,c931,c932,c933,c934,c935,c936,c937,c938,c939,c940,c941,c942,c943,c944,c945,c946,c947,c948,c949,c950,c951,c952,c953,c954,c955,c956,c957,c958,c959,c960,c961,c962,c963,c964,c965,c966,c967,c968,c969,c970,c971,c972,c973,c974,c975,c976,c977,c978,c979,c980,c981,c982,c983,c984,c985,c986,c987,c988,c989,c990,c991,c992,c993,c994,c995,c996,c997,c998,c999,c1000,c1001,c1002,c1003,c1004,c1005,c1006,c1007,c1008,c1009,c1010,c1011,c1012,c1013,c1014,c1015,c1016,c1017,c1018,c1019,c1020,c1021,c1022,c1023,c1024,c1025,c1026,c1027,c1028,c1029,c1030,c1031,c1032,c1033,c1034,c1035,c1036,c1037,c1038,c1039,c1040,c1041,c1042,c1043,c1044,c1045,c1046,c1047,c1048,c1049,c1050,c1051,c1052,c1053,c1054,c1055,c1056,c1057,c1058,c1059,c1060,c1061,c1062,c1063,c1064,c1065,c1066,c1067,c1068,c1069,c1070,c1071,c1072,c1073,c1074,c1075,c1076,c1077,c1078,c1079,c1080,c1081,c1082,c1083,c1084,c1085,c1086,c1087,c1088,c1089,c1090,c1091,c1092,c1093,c1094,c1095,c1096,c1097,c1098,c1099,c1100,c1101,c1102,c1103,c1104,c1105,c1106,c1107,c1108,c1109,c1110,c1111,c1112,c1113,c1114,c1115,c1116,c1117,c1118,c1119,c1120,c1121,c1122,c1123,c1124,c1125,c1126,c1127,c1128,c1129,c1130,c1131,c1132,c1133,c1134,c1135,c1136,c1137,c1138,c1139,c1140,c1141,c1142,c1143,c1144,c1145,c1146,c1147,c1148,c1149,c1150,c1151,c1152,c1153,c1154,c1155,c1156,c1157,c1158,c1159,c1160,c1161,c1162,c1163,c1164,c1165,c1166,c1167,c1168,c1169,c1170,c1171,c1172,c1173,c1174,c1175,c1176,c1177,c1178,c1179,c1180,c1181,c1182,c1183,c1184,c1185,c1186,c1187,c1188,c1189,c1190,c1191,c1192,c1193,c1194,c1195,c1196,c1197,c1198,c1199,c1200,c1201,c1202,c1203,c1204,c1205,c1206,c1207,c1208,c1209,c1210,c1211,c1212,c1213,c1214,c1215,c1216,c1217,c1218,c1219,c1220,c1221,c1222,c1223,c1224,c1225,c1226,c1227,c1228,c1229,c1230,c1231,c1232,c1233,c1234,c1235,c1236,c1237,c1238,c1239,c1240,c1241,c1242,c1243,c1244,c1245,c1246,c1247,c1248,c1249,c1250,c1251,c1252,c1253,c1254,c1255,c1256,c1257,c1258,c1259,c1260,c1261,c1262,c1263,c1264,c1265,c1266,c1267,c1268,c1269,c1270,c1271,c1272,c1273,c1274,c1275,c1276,c1277,c1278,c1279,c1280,c1281,c1282,c1283,c1284,c1285,c1286,c1287,c1288,c1289,c1290,c1291,c1292,c1293,c1294,c1295,c1296,c1297,c1298,c1299,c1300,c1301,c1302,c1303,c1304,c1305,c1306,c1307,c1308,c1309,c1310,c1311,c1312,c1313,c1314,c1315,c1316,c1317,c1318,c1319,c1320,c1321,c1322,c1323,c1324,c1325,c1326,c1327,c1328,c1329,c1330,c1331,c1332,c1333,c1334,c1335,c1336,c1337,c1338,c1339,c1340,c1341,c1342,c1343,c1344,c1345,c1346,c1347,c1348,c1349,c1350,c1351,c1352,c1353,c1354,c1355,c1356,c1357,c1358,c1359,c1360,c1361,c1362,c1363,c1364,c1365,c1366,c1367,c1368,c1369,c1370,c1371,c1372,c1373,c1374,c1375,c1376,c1377,c1378,c1379,c1380,c1381,c1382,c1383,c1384,c1385,c1386,c1387,c1388,c1389,c1390,c1391,c1392,c1393,c1394,c1395,c1396,c1397,c1398,c1399,c1400,c1401,c1402,c1403,c1404,c1405,c1406,c1407,c1408,c1409,c1410,c1411,c1412,c1413,c1414,c1415,c1416,c1417,c1418,c1419,c1420,c1421,c1422,c1423,c1424,c1425,c1426,c1427,c1428,c1429,c1430,c1431,c1432,c1433,c1434,c1435,c1436,c1437,c1438,c1439,c1440,c1441,c1442,c1443,c1444,c1445,c1446,c1447,c1448,c1449,c1450,c1451,c1452,c1453,c1454,c1455,c1456,c1457,c1458,c1459,c1460,c1461,c1462,c1463,c1464,c1465,c1466,c1467,c1468,c1469,c1470,c1471,c1472,c1473,c1474,c1475,c1476,c1477,c1478,c1479,c1480,c1481,c1482,c1483,c1484,c1485,c1486,c1487,c1488,c1489,c1490,c1491,c1492,c1493,c1494,c1495,c1496,c1497,c1498,c1499,c1500,c1501,c1502,c1503,c1504,c1505,c1506,c1507,c1508,c1509,c1510,c1511,c1512,c1513,c1514,c1515,c1516,c1517,c1518,c1519,c1520,c1521,c1522,c1523,c1524,c1525,c1526,c1527,c1528,c1529,c1530,c1531,c1532,c1533,c1534,c1535,c1536,c1537,c1538,c1539,c1540,c1541,c1542,c1543,c1544,c1545,c1546,c1547,c1548,c1549,c1550,c1551,c1552,c1553,c1554,c1555,c1556,c1557,c1558,c1559,c1560,c1561,c1562,c1563,c1564,c1565,c1566,c1567,c1568,c1569,c1570,c1571,c1572,c1573,c1574,c1575,c1576,c1577,c1578,c1579,c1580,c1581,c1582,c1583,c1584,c1585,c1586,c1587,c1588,c1589,c1590,c1591,c1592,c1593,c1594,c1595,c1596,c1597,c1598,c1599,c1600
);

create table bar as select * from foo;

drop table if exists foo;
drop table if exists bar;

create table foo (
c1 int,c2 int,c3 int,c4 int,c5 int,c6 int,c7 int,c8 int,c9 int,c10 int,c11 int,c12 int,c13 int,c14 int,c15 int,c16 int,c17 int,c18 int,c19 int,c20 int,c21 int,c22 int,c23 int,c24 int,c25 int,c26 int,c27 int,c28 int,c29 int,c30 int,c31 int,c32 int,c33 int,c34 int,c35 int,c36 int,c37 int,c38 int,c39 int,c40 int,c41 int,c42 int,c43 int,c44 int,c45 int,c46 int,c47 int,c48 int,c49 int,c50 int,c51 int,c52 int,c53 int,c54 int,c55 int,c56 int,c57 int,c58 int,c59 int,c60 int,c61 int,c62 int,c63 int,c64 int,c65 int,c66 int,c67 int,c68 int,c69 int,c70 int,c71 int,c72 int,c73 int,c74 int,c75 int,c76 int,c77 int,c78 int,c79 int,c80 int,c81 int,c82 int,c83 int,c84 int,c85 int,c86 int,c87 int,c88 int,c89 int,c90 int,c91 int,c92 int,c93 int,c94 int,c95 int,c96 int,c97 int,c98 int,c99 int,c100 int,c101 int,c102 int,c103 int,c104 int,c105 int,c106 int,c107 int,c108 int,c109 int,c110 int,c111 int,c112 int,c113 int,c114 int,c115 int,c116 int,c117 int,c118 int,c119 int,c120 int,c121 int,c122 int,c123 int,c124 int,c125 int,c126 int,c127 int,c128 int,c129 int,c130 int,c131 int,c132 int,c133 int,c134 int,c135 int,c136 int,c137 int,c138 int,c139 int,c140 int,c141 int,c142 int,c143 int,c144 int,c145 int,c146 int,c147 int,c148 int,c149 int,c150 int,c151 int,c152 int,c153 int,c154 int,c155 int,c156 int,c157 int,c158 int,c159 int,c160 int,c161 int,c162 int,c163 int,c164 int,c165 int,c166 int,c167 int,c168 int,c169 int,c170 int,c171 int,c172 int,c173 int,c174 int,c175 int,c176 int,c177 int,c178 int,c179 int,c180 int,c181 int,c182 int,c183 int,c184 int,c185 int,c186 int,c187 int,c188 int,c189 int,c190 int,c191 int,c192 int,c193 int,c194 int,c195 int,c196 int,c197 int,c198 int,c199 int,c200 int,c201 int,c202 int,c203 int,c204 int,c205 int,c206 int,c207 int,c208 int,c209 int,c210 int,c211 int,c212 int,c213 int,c214 int,c215 int,c216 int,c217 int,c218 int,c219 int,c220 int,c221 int,c222 int,c223 int,c224 int,c225 int,c226 int,c227 int,c228 int,c229 int,c230 int,c231 int,c232 int,c233 int,c234 int,c235 int,c236 int,c237 int,c238 int,c239 int,c240 int,c241 int,c242 int,c243 int,c244 int,c245 int,c246 int,c247 int,c248 int,c249 int,c250 int,c251 int,c252 int,c253 int,c254 int,c255 int,c256 int,c257 int,c258 int,c259 int,c260 int,c261 int,c262 int,c263 int,c264 int,c265 int,c266 int,c267 int,c268 int,c269 int,c270 int,c271 int,c272 int,c273 int,c274 int,c275 int,c276 int,c277 int,c278 int,c279 int,c280 int,c281 int,c282 int,c283 int,c284 int,c285 int,c286 int,c287 int,c288 int,c289 int,c290 int,c291 int,c292 int,c293 int,c294 int,c295 int,c296 int,c297 int,c298 int,c299 int,c300 int,c301 int,c302 int,c303 int,c304 int,c305 int,c306 int,c307 int,c308 int,c309 int,c310 int,c311 int,c312 int,c313 int,c314 int,c315 int,c316 int,c317 int,c318 int,c319 int,c320 int,c321 int,c322 int,c323 int,c324 int,c325 int,c326 int,c327 int,c328 int,c329 int,c330 int,c331 int,c332 int,c333 int,c334 int,c335 int,c336 int,c337 int,c338 int,c339 int,c340 int,c341 int,c342 int,c343 int,c344 int,c345 int,c346 int,c347 int,c348 int,c349 int,c350 int,c351 int,c352 int,c353 int,c354 int,c355 int,c356 int,c357 int,c358 int,c359 int,c360 int,c361 int,c362 int,c363 int,c364 int,c365 int,c366 int,c367 int,c368 int,c369 int,c370 int,c371 int,c372 int,c373 int,c374 int,c375 int,c376 int,c377 int,c378 int,c379 int,c380 int,c381 int,c382 int,c383 int,c384 int,c385 int,c386 int,c387 int,c388 int,c389 int,c390 int,c391 int,c392 int,c393 int,c394 int,c395 int,c396 int,c397 int,c398 int,c399 int,c400 int,c401 int,c402 int,c403 int,c404 int,c405 int,c406 int,c407 int,c408 int,c409 int,c410 int,c411 int,c412 int,c413 int,c414 int,c415 int,c416 int,c417 int,c418 int,c419 int,c420 int,c421 int,c422 int,c423 int,c424 int,c425 int,c426 int,c427 int,c428 int,c429 int,c430 int,c431 int,c432 int,c433 int,c434 int,c435 int,c436 int,c437 int,c438 int,c439 int,c440 int,c441 int,c442 int,c443 int,c444 int,c445 int,c446 int,c447 int,c448 int,c449 int,c450 int,c451 int,c452 int,c453 int,c454 int,c455 int,c456 int,c457 int,c458 int,c459 int,c460 int,c461 int,c462 int,c463 int,c464 int,c465 int,c466 int,c467 int,c468 int,c469 int,c470 int,c471 int,c472 int,c473 int,c474 int,c475 int,c476 int,c477 int,c478 int,c479 int,c480 int,c481 int,c482 int,c483 int,c484 int,c485 int,c486 int,c487 int,c488 int,c489 int,c490 int,c491 int,c492 int,c493 int,c494 int,c495 int,c496 int,c497 int,c498 int,c499 int,c500 int,c501 int,c502 int,c503 int,c504 int,c505 int,c506 int,c507 int,c508 int,c509 int,c510 int,c511 int,c512 int,c513 int,c514 int,c515 int,c516 int,c517 int,c518 int,c519 int,c520 int,c521 int,c522 int,c523 int,c524 int,c525 int,c526 int,c527 int,c528 int,c529 int,c530 int,c531 int,c532 int,c533 int,c534 int,c535 int,c536 int,c537 int,c538 int,c539 int,c540 int,c541 int,c542 int,c543 int,c544 int,c545 int,c546 int,c547 int,c548 int,c549 int,c550 int,c551 int,c552 int,c553 int,c554 int,c555 int,c556 int,c557 int,c558 int,c559 int,c560 int,c561 int,c562 int,c563 int,c564 int,c565 int,c566 int,c567 int,c568 int,c569 int,c570 int,c571 int,c572 int,c573 int,c574 int,c575 int,c576 int,c577 int,c578 int,c579 int,c580 int,c581 int,c582 int,c583 int,c584 int,c585 int,c586 int,c587 int,c588 int,c589 int,c590 int,c591 int,c592 int,c593 int,c594 int,c595 int,c596 int,c597 int,c598 int,c599 int,c600 int,c601 int,c602 int,c603 int,c604 int,c605 int,c606 int,c607 int,c608 int,c609 int,c610 int,c611 int,c612 int,c613 int,c614 int,c615 int,c616 int,c617 int,c618 int,c619 int,c620 int,c621 int,c622 int,c623 int,c624 int,c625 int,c626 int,c627 int,c628 int,c629 int,c630 int,c631 int,c632 int,c633 int,c634 int,c635 int,c636 int,c637 int,c638 int,c639 int,c640 int,c641 int,c642 int,c643 int,c644 int,c645 int,c646 int,c647 int,c648 int,c649 int,c650 int,c651 int,c652 int,c653 int,c654 int,c655 int,c656 int,c657 int,c658 int,c659 int,c660 int,c661 int,c662 int,c663 int,c664 int,c665 int,c666 int,c667 int,c668 int,c669 int,c670 int,c671 int,c672 int,c673 int,c674 int,c675 int,c676 int,c677 int,c678 int,c679 int,c680 int,c681 int,c682 int,c683 int,c684 int,c685 int,c686 int,c687 int,c688 int,c689 int,c690 int,c691 int,c692 int,c693 int,c694 int,c695 int,c696 int,c697 int,c698 int,c699 int,c700 int,c701 int,c702 int,c703 int,c704 int,c705 int,c706 int,c707 int,c708 int,c709 int,c710 int,c711 int,c712 int,c713 int,c714 int,c715 int,c716 int,c717 int,c718 int,c719 int,c720 int,c721 int,c722 int,c723 int,c724 int,c725 int,c726 int,c727 int,c728 int,c729 int,c730 int,c731 int,c732 int,c733 int,c734 int,c735 int,c736 int,c737 int,c738 int,c739 int,c740 int,c741 int,c742 int,c743 int,c744 int,c745 int,c746 int,c747 int,c748 int,c749 int,c750 int,c751 int,c752 int,c753 int,c754 int,c755 int,c756 int,c757 int,c758 int,c759 int,c760 int,c761 int,c762 int,c763 int,c764 int,c765 int,c766 int,c767 int,c768 int,c769 int,c770 int,c771 int,c772 int,c773 int,c774 int,c775 int,c776 int,c777 int,c778 int,c779 int,c780 int,c781 int,c782 int,c783 int,c784 int,c785 int,c786 int,c787 int,c788 int,c789 int,c790 int,c791 int,c792 int,c793 int,c794 int,c795 int,c796 int,c797 int,c798 int,c799 int,c800 int,c801 int,c802 int,c803 int,c804 int,c805 int,c806 int,c807 int,c808 int,c809 int,c810 int,c811 int,c812 int,c813 int,c814 int,c815 int,c816 int,c817 int,c818 int,c819 int,c820 int,c821 int,c822 int,c823 int,c824 int,c825 int,c826 int,c827 int,c828 int,c829 int,c830 int,c831 int,c832 int,c833 int,c834 int,c835 int,c836 int,c837 int,c838 int,c839 int,c840 int,c841 int,c842 int,c843 int,c844 int,c845 int,c846 int,c847 int,c848 int,c849 int,c850 int,c851 int,c852 int,c853 int,c854 int,c855 int,c856 int,c857 int,c858 int,c859 int,c860 int,c861 int,c862 int,c863 int,c864 int,c865 int,c866 int,c867 int,c868 int,c869 int,c870 int,c871 int,c872 int,c873 int,c874 int,c875 int,c876 int,c877 int,c878 int,c879 int,c880 int,c881 int,c882 int,c883 int,c884 int,c885 int,c886 int,c887 int,c888 int,c889 int,c890 int,c891 int,c892 int,c893 int,c894 int,c895 int,c896 int,c897 int,c898 int,c899 int,c900 int,c901 int,c902 int,c903 int,c904 int,c905 int,c906 int,c907 int,c908 int,c909 int,c910 int,c911 int,c912 int,c913 int,c914 int,c915 int,c916 int,c917 int,c918 int,c919 int,c920 int,c921 int,c922 int,c923 int,c924 int,c925 int,c926 int,c927 int,c928 int,c929 int,c930 int,c931 int,c932 int,c933 int,c934 int,c935 int,c936 int,c937 int,c938 int,c939 int,c940 int,c941 int,c942 int,c943 int,c944 int,c945 int,c946 int,c947 int,c948 int,c949 int,c950 int,c951 int,c952 int,c953 int,c954 int,c955 int,c956 int,c957 int,c958 int,c959 int,c960 int,c961 int,c962 int,c963 int,c964 int,c965 int,c966 int,c967 int,c968 int,c969 int,c970 int,c971 int,c972 int,c973 int,c974 int,c975 int,c976 int,c977 int,c978 int,c979 int,c980 int,c981 int,c982 int,c983 int,c984 int,c985 int,c986 int,c987 int,c988 int,c989 int,c990 int,c991 int,c992 int,c993 int,c994 int,c995 int,c996 int,c997 int,c998 int,c999 int,c1000 int,c1001 int,c1002 int,c1003 int,c1004 int,c1005 int,c1006 int,c1007 int,c1008 int,c1009 int,c1010 int,c1011 int,c1012 int,c1013 int,c1014 int,c1015 int,c1016 int,c1017 int,c1018 int,c1019 int,c1020 int,c1021 int,c1022 int,c1023 int,c1024 int,c1025 int,c1026 int,c1027 int,c1028 int,c1029 int,c1030 int,c1031 int,c1032 int,c1033 int,c1034 int,c1035 int,c1036 int,c1037 int,c1038 int,c1039 int,c1040 int,c1041 int,c1042 int,c1043 int,c1044 int,c1045 int,c1046 int,c1047 int,c1048 int,c1049 int,c1050 int,c1051 int,c1052 int,c1053 int,c1054 int,c1055 int,c1056 int,c1057 int,c1058 int,c1059 int,c1060 int,c1061 int,c1062 int,c1063 int,c1064 int,c1065 int,c1066 int,c1067 int,c1068 int,c1069 int,c1070 int,c1071 int,c1072 int,c1073 int,c1074 int,c1075 int,c1076 int,c1077 int,c1078 int,c1079 int,c1080 int,c1081 int,c1082 int,c1083 int,c1084 int,c1085 int,c1086 int,c1087 int,c1088 int,c1089 int,c1090 int,c1091 int,c1092 int,c1093 int,c1094 int,c1095 int,c1096 int,c1097 int,c1098 int,c1099 int,c1100 int,c1101 int,c1102 int,c1103 int,c1104 int,c1105 int,c1106 int,c1107 int,c1108 int,c1109 int,c1110 int,c1111 int,c1112 int,c1113 int,c1114 int,c1115 int,c1116 int,c1117 int,c1118 int,c1119 int,c1120 int,c1121 int,c1122 int,c1123 int,c1124 int,c1125 int,c1126 int,c1127 int,c1128 int,c1129 int,c1130 int,c1131 int,c1132 int,c1133 int,c1134 int,c1135 int,c1136 int,c1137 int,c1138 int,c1139 int,c1140 int,c1141 int,c1142 int,c1143 int,c1144 int,c1145 int,c1146 int,c1147 int,c1148 int,c1149 int,c1150 int,c1151 int,c1152 int,c1153 int,c1154 int,c1155 int,c1156 int,c1157 int,c1158 int,c1159 int,c1160 int,c1161 int,c1162 int,c1163 int,c1164 int,c1165 int,c1166 int,c1167 int,c1168 int,c1169 int,c1170 int,c1171 int,c1172 int,c1173 int,c1174 int,c1175 int,c1176 int,c1177 int,c1178 int,c1179 int,c1180 int,c1181 int,c1182 int,c1183 int,c1184 int,c1185 int,c1186 int,c1187 int,c1188 int,c1189 int,c1190 int,c1191 int,c1192 int,c1193 int,c1194 int,c1195 int,c1196 int,c1197 int,c1198 int,c1199 int,c1200 int,c1201 int,c1202 int,c1203 int,c1204 int,c1205 int,c1206 int,c1207 int,c1208 int,c1209 int,c1210 int,c1211 int,c1212 int,c1213 int,c1214 int,c1215 int,c1216 int,c1217 int,c1218 int,c1219 int,c1220 int,c1221 int,c1222 int,c1223 int,c1224 int,c1225 int,c1226 int,c1227 int,c1228 int,c1229 int,c1230 int,c1231 int,c1232 int,c1233 int,c1234 int,c1235 int,c1236 int,c1237 int,c1238 int,c1239 int,c1240 int,c1241 int,c1242 int,c1243 int,c1244 int,c1245 int,c1246 int,c1247 int,c1248 int,c1249 int,c1250 int,c1251 int,c1252 int,c1253 int,c1254 int,c1255 int,c1256 int,c1257 int,c1258 int,c1259 int,c1260 int,c1261 int,c1262 int,c1263 int,c1264 int,c1265 int,c1266 int,c1267 int,c1268 int,c1269 int,c1270 int,c1271 int,c1272 int,c1273 int,c1274 int,c1275 int,c1276 int,c1277 int,c1278 int,c1279 int,c1280 int,c1281 int,c1282 int,c1283 int,c1284 int,c1285 int,c1286 int,c1287 int,c1288 int,c1289 int,c1290 int,c1291 int,c1292 int,c1293 int,c1294 int,c1295 int,c1296 int,c1297 int,c1298 int,c1299 int,c1300 int,c1301 int,c1302 int,c1303 int,c1304 int,c1305 int,c1306 int,c1307 int,c1308 int,c1309 int,c1310 int,c1311 int,c1312 int,c1313 int,c1314 int,c1315 int,c1316 int,c1317 int,c1318 int,c1319 int,c1320 int,c1321 int,c1322 int,c1323 int,c1324 int,c1325 int,c1326 int,c1327 int,c1328 int,c1329 int,c1330 int,c1331 int,c1332 int,c1333 int,c1334 int,c1335 int,c1336 int,c1337 int,c1338 int,c1339 int,c1340 int,c1341 int,c1342 int,c1343 int,c1344 int,c1345 int,c1346 int,c1347 int,c1348 int,c1349 int,c1350 int,c1351 int,c1352 int,c1353 int,c1354 int,c1355 int,c1356 int,c1357 int,c1358 int,c1359 int,c1360 int,c1361 int,c1362 int,c1363 int,c1364 int,c1365 int,c1366 int,c1367 int,c1368 int,c1369 int,c1370 int,c1371 int,c1372 int,c1373 int,c1374 int,c1375 int,c1376 int,c1377 int,c1378 int,c1379 int,c1380 int,c1381 int,c1382 int,c1383 int,c1384 int,c1385 int,c1386 int,c1387 int,c1388 int,c1389 int,c1390 int,c1391 int,c1392 int,c1393 int,c1394 int,c1395 int,c1396 int,c1397 int,c1398 int,c1399 int,c1400 int,c1401 int,c1402 int,c1403 int,c1404 int,c1405 int,c1406 int,c1407 int,c1408 int,c1409 int,c1410 int,c1411 int,c1412 int,c1413 int,c1414 int,c1415 int,c1416 int,c1417 int,c1418 int,c1419 int,c1420 int,c1421 int,c1422 int,c1423 int,c1424 int,c1425 int,c1426 int,c1427 int,c1428 int,c1429 int,c1430 int,c1431 int,c1432 int,c1433 int,c1434 int,c1435 int,c1436 int,c1437 int,c1438 int,c1439 int,c1440 int,c1441 int,c1442 int,c1443 int,c1444 int,c1445 int,c1446 int,c1447 int,c1448 int,c1449 int,c1450 int,c1451 int,c1452 int,c1453 int,c1454 int,c1455 int,c1456 int,c1457 int,c1458 int,c1459 int,c1460 int,c1461 int,c1462 int,c1463 int,c1464 int,c1465 int,c1466 int,c1467 int,c1468 int,c1469 int,c1470 int,c1471 int,c1472 int,c1473 int,c1474 int,c1475 int,c1476 int,c1477 int,c1478 int,c1479 int,c1480 int,c1481 int,c1482 int,c1483 int,c1484 int,c1485 int,c1486 int,c1487 int,c1488 int,c1489 int,c1490 int,c1491 int,c1492 int,c1493 int,c1494 int,c1495 int,c1496 int,c1497 int,c1498 int,c1499 int,c1500 int,c1501 int,c1502 int,c1503 int,c1504 int,c1505 int,c1506 int,c1507 int,c1508 int,c1509 int,c1510 int,c1511 int,c1512 int,c1513 int,c1514 int,c1515 int,c1516 int,c1517 int,c1518 int,c1519 int,c1520 int,c1521 int,c1522 int,c1523 int,c1524 int,c1525 int,c1526 int,c1527 int,c1528 int,c1529 int,c1530 int,c1531 int,c1532 int,c1533 int,c1534 int,c1535 int,c1536 int,c1537 int,c1538 int,c1539 int,c1540 int,c1541 int,c1542 int,c1543 int,c1544 int,c1545 int,c1546 int,c1547 int,c1548 int,c1549 int,c1550 int,c1551 int,c1552 int,c1553 int,c1554 int,c1555 int,c1556 int,c1557 int,c1558 int,c1559 int,c1560 int,c1561 int,c1562 int,c1563 int,c1564 int,c1565 int,c1566 int,c1567 int,c1568 int,c1569 int,c1570 int,c1571 int,c1572 int,c1573 int,c1574 int,c1575 int,c1576 int,c1577 int,c1578 int,c1579 int,c1580 int,c1581 int,c1582 int,c1583 int,c1584 int,c1585 int,c1586 int,c1587 int,c1588 int,c1589 int,c1590 int,c1591 int,c1592 int,c1593 int,c1594 int,c1595 int,c1596 int,c1597 int,c1598 int,c1599 int,c1600 int, c1601 int
) distributed by
(
c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c35,c36,c37,c38,c39,c40,c41,c42,c43,c44,c45,c46,c47,c48,c49,c50,c51,c52,c53,c54,c55,c56,c57,c58,c59,c60,c61,c62,c63,c64,c65,c66,c67,c68,c69,c70,c71,c72,c73,c74,c75,c76,c77,c78,c79,c80,c81,c82,c83,c84,c85,c86,c87,c88,c89,c90,c91,c92,c93,c94,c95,c96,c97,c98,c99,c100,c101,c102,c103,c104,c105,c106,c107,c108,c109,c110,c111,c112,c113,c114,c115,c116,c117,c118,c119,c120,c121,c122,c123,c124,c125,c126,c127,c128,c129,c130,c131,c132,c133,c134,c135,c136,c137,c138,c139,c140,c141,c142,c143,c144,c145,c146,c147,c148,c149,c150,c151,c152,c153,c154,c155,c156,c157,c158,c159,c160,c161,c162,c163,c164,c165,c166,c167,c168,c169,c170,c171,c172,c173,c174,c175,c176,c177,c178,c179,c180,c181,c182,c183,c184,c185,c186,c187,c188,c189,c190,c191,c192,c193,c194,c195,c196,c197,c198,c199,c200,c201,c202,c203,c204,c205,c206,c207,c208,c209,c210,c211,c212,c213,c214,c215,c216,c217,c218,c219,c220,c221,c222,c223,c224,c225,c226,c227,c228,c229,c230,c231,c232,c233,c234,c235,c236,c237,c238,c239,c240,c241,c242,c243,c244,c245,c246,c247,c248,c249,c250,c251,c252,c253,c254,c255,c256,c257,c258,c259,c260,c261,c262,c263,c264,c265,c266,c267,c268,c269,c270,c271,c272,c273,c274,c275,c276,c277,c278,c279,c280,c281,c282,c283,c284,c285,c286,c287,c288,c289,c290,c291,c292,c293,c294,c295,c296,c297,c298,c299,c300,c301,c302,c303,c304,c305,c306,c307,c308,c309,c310,c311,c312,c313,c314,c315,c316,c317,c318,c319,c320,c321,c322,c323,c324,c325,c326,c327,c328,c329,c330,c331,c332,c333,c334,c335,c336,c337,c338,c339,c340,c341,c342,c343,c344,c345,c346,c347,c348,c349,c350,c351,c352,c353,c354,c355,c356,c357,c358,c359,c360,c361,c362,c363,c364,c365,c366,c367,c368,c369,c370,c371,c372,c373,c374,c375,c376,c377,c378,c379,c380,c381,c382,c383,c384,c385,c386,c387,c388,c389,c390,c391,c392,c393,c394,c395,c396,c397,c398,c399,c400,c401,c402,c403,c404,c405,c406,c407,c408,c409,c410,c411,c412,c413,c414,c415,c416,c417,c418,c419,c420,c421,c422,c423,c424,c425,c426,c427,c428,c429,c430,c431,c432,c433,c434,c435,c436,c437,c438,c439,c440,c441,c442,c443,c444,c445,c446,c447,c448,c449,c450,c451,c452,c453,c454,c455,c456,c457,c458,c459,c460,c461,c462,c463,c464,c465,c466,c467,c468,c469,c470,c471,c472,c473,c474,c475,c476,c477,c478,c479,c480,c481,c482,c483,c484,c485,c486,c487,c488,c489,c490,c491,c492,c493,c494,c495,c496,c497,c498,c499,c500,c501,c502,c503,c504,c505,c506,c507,c508,c509,c510,c511,c512,c513,c514,c515,c516,c517,c518,c519,c520,c521,c522,c523,c524,c525,c526,c527,c528,c529,c530,c531,c532,c533,c534,c535,c536,c537,c538,c539,c540,c541,c542,c543,c544,c545,c546,c547,c548,c549,c550,c551,c552,c553,c554,c555,c556,c557,c558,c559,c560,c561,c562,c563,c564,c565,c566,c567,c568,c569,c570,c571,c572,c573,c574,c575,c576,c577,c578,c579,c580,c581,c582,c583,c584,c585,c586,c587,c588,c589,c590,c591,c592,c593,c594,c595,c596,c597,c598,c599,c600,c601,c602,c603,c604,c605,c606,c607,c608,c609,c610,c611,c612,c613,c614,c615,c616,c617,c618,c619,c620,c621,c622,c623,c624,c625,c626,c627,c628,c629,c630,c631,c632,c633,c634,c635,c636,c637,c638,c639,c640,c641,c642,c643,c644,c645,c646,c647,c648,c649,c650,c651,c652,c653,c654,c655,c656,c657,c658,c659,c660,c661,c662,c663,c664,c665,c666,c667,c668,c669,c670,c671,c672,c673,c674,c675,c676,c677,c678,c679,c680,c681,c682,c683,c684,c685,c686,c687,c688,c689,c690,c691,c692,c693,c694,c695,c696,c697,c698,c699,c700,c701,c702,c703,c704,c705,c706,c707,c708,c709,c710,c711,c712,c713,c714,c715,c716,c717,c718,c719,c720,c721,c722,c723,c724,c725,c726,c727,c728,c729,c730,c731,c732,c733,c734,c735,c736,c737,c738,c739,c740,c741,c742,c743,c744,c745,c746,c747,c748,c749,c750,c751,c752,c753,c754,c755,c756,c757,c758,c759,c760,c761,c762,c763,c764,c765,c766,c767,c768,c769,c770,c771,c772,c773,c774,c775,c776,c777,c778,c779,c780,c781,c782,c783,c784,c785,c786,c787,c788,c789,c790,c791,c792,c793,c794,c795,c796,c797,c798,c799,c800,c801,c802,c803,c804,c805,c806,c807,c808,c809,c810,c811,c812,c813,c814,c815,c816,c817,c818,c819,c820,c821,c822,c823,c824,c825,c826,c827,c828,c829,c830,c831,c832,c833,c834,c835,c836,c837,c838,c839,c840,c841,c842,c843,c844,c845,c846,c847,c848,c849,c850,c851,c852,c853,c854,c855,c856,c857,c858,c859,c860,c861,c862,c863,c864,c865,c866,c867,c868,c869,c870,c871,c872,c873,c874,c875,c876,c877,c878,c879,c880,c881,c882,c883,c884,c885,c886,c887,c888,c889,c890,c891,c892,c893,c894,c895,c896,c897,c898,c899,c900,c901,c902,c903,c904,c905,c906,c907,c908,c909,c910,c911,c912,c913,c914,c915,c916,c917,c918,c919,c920,c921,c922,c923,c924,c925,c926,c927,c928,c929,c930,c931,c932,c933,c934,c935,c936,c937,c938,c939,c940,c941,c942,c943,c944,c945,c946,c947,c948,c949,c950,c951,c952,c953,c954,c955,c956,c957,c958,c959,c960,c961,c962,c963,c964,c965,c966,c967,c968,c969,c970,c971,c972,c973,c974,c975,c976,c977,c978,c979,c980,c981,c982,c983,c984,c985,c986,c987,c988,c989,c990,c991,c992,c993,c994,c995,c996,c997,c998,c999,c1000,c1001,c1002,c1003,c1004,c1005,c1006,c1007,c1008,c1009,c1010,c1011,c1012,c1013,c1014,c1015,c1016,c1017,c1018,c1019,c1020,c1021,c1022,c1023,c1024,c1025,c1026,c1027,c1028,c1029,c1030,c1031,c1032,c1033,c1034,c1035,c1036,c1037,c1038,c1039,c1040,c1041,c1042,c1043,c1044,c1045,c1046,c1047,c1048,c1049,c1050,c1051,c1052,c1053,c1054,c1055,c1056,c1057,c1058,c1059,c1060,c1061,c1062,c1063,c1064,c1065,c1066,c1067,c1068,c1069,c1070,c1071,c1072,c1073,c1074,c1075,c1076,c1077,c1078,c1079,c1080,c1081,c1082,c1083,c1084,c1085,c1086,c1087,c1088,c1089,c1090,c1091,c1092,c1093,c1094,c1095,c1096,c1097,c1098,c1099,c1100,c1101,c1102,c1103,c1104,c1105,c1106,c1107,c1108,c1109,c1110,c1111,c1112,c1113,c1114,c1115,c1116,c1117,c1118,c1119,c1120,c1121,c1122,c1123,c1124,c1125,c1126,c1127,c1128,c1129,c1130,c1131,c1132,c1133,c1134,c1135,c1136,c1137,c1138,c1139,c1140,c1141,c1142,c1143,c1144,c1145,c1146,c1147,c1148,c1149,c1150,c1151,c1152,c1153,c1154,c1155,c1156,c1157,c1158,c1159,c1160,c1161,c1162,c1163,c1164,c1165,c1166,c1167,c1168,c1169,c1170,c1171,c1172,c1173,c1174,c1175,c1176,c1177,c1178,c1179,c1180,c1181,c1182,c1183,c1184,c1185,c1186,c1187,c1188,c1189,c1190,c1191,c1192,c1193,c1194,c1195,c1196,c1197,c1198,c1199,c1200,c1201,c1202,c1203,c1204,c1205,c1206,c1207,c1208,c1209,c1210,c1211,c1212,c1213,c1214,c1215,c1216,c1217,c1218,c1219,c1220,c1221,c1222,c1223,c1224,c1225,c1226,c1227,c1228,c1229,c1230,c1231,c1232,c1233,c1234,c1235,c1236,c1237,c1238,c1239,c1240,c1241,c1242,c1243,c1244,c1245,c1246,c1247,c1248,c1249,c1250,c1251,c1252,c1253,c1254,c1255,c1256,c1257,c1258,c1259,c1260,c1261,c1262,c1263,c1264,c1265,c1266,c1267,c1268,c1269,c1270,c1271,c1272,c1273,c1274,c1275,c1276,c1277,c1278,c1279,c1280,c1281,c1282,c1283,c1284,c1285,c1286,c1287,c1288,c1289,c1290,c1291,c1292,c1293,c1294,c1295,c1296,c1297,c1298,c1299,c1300,c1301,c1302,c1303,c1304,c1305,c1306,c1307,c1308,c1309,c1310,c1311,c1312,c1313,c1314,c1315,c1316,c1317,c1318,c1319,c1320,c1321,c1322,c1323,c1324,c1325,c1326,c1327,c1328,c1329,c1330,c1331,c1332,c1333,c1334,c1335,c1336,c1337,c1338,c1339,c1340,c1341,c1342,c1343,c1344,c1345,c1346,c1347,c1348,c1349,c1350,c1351,c1352,c1353,c1354,c1355,c1356,c1357,c1358,c1359,c1360,c1361,c1362,c1363,c1364,c1365,c1366,c1367,c1368,c1369,c1370,c1371,c1372,c1373,c1374,c1375,c1376,c1377,c1378,c1379,c1380,c1381,c1382,c1383,c1384,c1385,c1386,c1387,c1388,c1389,c1390,c1391,c1392,c1393,c1394,c1395,c1396,c1397,c1398,c1399,c1400,c1401,c1402,c1403,c1404,c1405,c1406,c1407,c1408,c1409,c1410,c1411,c1412,c1413,c1414,c1415,c1416,c1417,c1418,c1419,c1420,c1421,c1422,c1423,c1424,c1425,c1426,c1427,c1428,c1429,c1430,c1431,c1432,c1433,c1434,c1435,c1436,c1437,c1438,c1439,c1440,c1441,c1442,c1443,c1444,c1445,c1446,c1447,c1448,c1449,c1450,c1451,c1452,c1453,c1454,c1455,c1456,c1457,c1458,c1459,c1460,c1461,c1462,c1463,c1464,c1465,c1466,c1467,c1468,c1469,c1470,c1471,c1472,c1473,c1474,c1475,c1476,c1477,c1478,c1479,c1480,c1481,c1482,c1483,c1484,c1485,c1486,c1487,c1488,c1489,c1490,c1491,c1492,c1493,c1494,c1495,c1496,c1497,c1498,c1499,c1500,c1501,c1502,c1503,c1504,c1505,c1506,c1507,c1508,c1509,c1510,c1511,c1512,c1513,c1514,c1515,c1516,c1517,c1518,c1519,c1520,c1521,c1522,c1523,c1524,c1525,c1526,c1527,c1528,c1529,c1530,c1531,c1532,c1533,c1534,c1535,c1536,c1537,c1538,c1539,c1540,c1541,c1542,c1543,c1544,c1545,c1546,c1547,c1548,c1549,c1550,c1551,c1552,c1553,c1554,c1555,c1556,c1557,c1558,c1559,c1560,c1561,c1562,c1563,c1564,c1565,c1566,c1567,c1568,c1569,c1570,c1571,c1572,c1573,c1574,c1575,c1576,c1577,c1578,c1579,c1580,c1581,c1582,c1583,c1584,c1585,c1586,c1587,c1588,c1589,c1590,c1591,c1592,c1593,c1594,c1595,c1596,c1597,c1598,c1599,c1600,c1601
);

drop table if exists foo;
