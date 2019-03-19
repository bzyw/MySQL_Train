
-- 创建函数：计算某一个系的教师人数
DELIMITER $$
CREATE FUNCTION dept_count(dept_name VARCHAR(20)) 
RETURNS VARCHAR(20) 
READS SQL DATA -- 子程序需要被声明为确定性的或者不更改数据，否则：ERROR 1418 (HY000)
BEGIN
	DECLARE d_count int;
	SELECT COUNT(id) into d_count FROM instructor where instructor.dept_name=dept_name;
	return d_count;
END$$
DELIMITER ;

-- 创建表函数（此特性最早出现在SQL 2003） 不支持
/*
DELIMITER $$
create FUNCTION instructor_of(dept_name VARCHAR(20))
returns TABLE( ID VARCHAR(5),
							 name varchar(20),
							 dept_name VARCHAR(20),
							 salary NUMERIC(8,2))
READS SQL DATA
begin 
	return table(select ID,name,dept_name,salary from instructor where instructor.dept_name=dept_name);
end $$;
DELIMITER ;
*/


-- 创建存储过程：计算某一个系的教师人数
delimiter $$
create PROCEDURE dept_count_pro(in dept_name varchar(20),out d_count INT)
begin 
		select count(*) into d_count from instructor where instructor.dept_name=dept_name;
end $$
delimiter ;

 
call dept_count_pro('Physics',@d_count);
select @d_count as d_count;

select dept_count('Physics') as dept_count;

-- if_else
delimiter $$
create PROCEDURE get_stu_level_if(in stu_ID varchar(5),out cred_level varchar(5))
begin 
	declare cred decimal(5,0);
	select tot_cred into cred from student where ID=stu_ID;
	if cred >=100 THEN 
			set cred_level='非常好';
	elseif cred>=80 THEN
			set cred_level='好';
	elseif cred>=50 THEN 
			set cred_level='良';
	else 
			set cred_level='差';
	end IF;
end $$
delimiter ;

call get_stu_level_if('19991',@cred_level);
select @cred_level as cred_level;


-- case
delimiter $$
create PROCEDURE get_stu_level_case(in stu_ID varchar(5),out cred_level varchar(5))
begin 
	declare cred decimal(5,0);
	select tot_cred into cred from student where ID=stu_ID;
	case 
		when cred>=100 then 
			SET cred_level='非常好';
		when cred>=80 then
			SET cred_level='好';
		when cred>=50 then
			SET cred_level='良';
		ELSE
			SET cred_level='差';
	END CASE;
end $$
delimiter ;

call get_stu_level_case('19991',@cred_level_1);
select @cred_level_1 as cred_level_1;


-- LEAVE can be used within BEGIN ... END or loop constructs (LOOP, REPEAT, WHILE).
-- ITERATE can appear only within LOOP, REPEAT, and WHILE statements. ITERATE means “start the loop again.”
-- WHILE
delimiter $$
create function sum_while(buttom INT,top INT)
returns INT NO SQL
BEGIN
	declare temp int;-- 变量必须在最前面声明
	declare sum int default 0;
	declare i int;
	IF buttom>top THEN
		set temp=buttom;
		set buttom=top;
		set top=temp;
	END IF;
	set i=buttom;
	WHILE i<=top DO
		set sum=sum+i;
		set i=i+1;
	END WHILE;
	return sum;
END $$
delimiter ;

select sum_while(1,100);
select sum_while(101,100);

-- LOOP
delimiter $$
create function sum_loop(buttom int,top INT)
returns INT 
LANGUAGE SQL DETERMINISTIC NO SQL SQL SECURITY INVOKER
BEGIN
	declare temp INT;
	declare sum int default 0;
	declare i int;
	IF buttom>top THEN
		set temp=buttom;
		set buttom=top;
		set top=temp;
	END IF;
	set i=buttom;
	sum_label:LOOP
		IF i>top THEN 
			LEAVE sum_label; 
		END IF;
		set sum=sum+i;
		set i=i+1;
	END LOOP sum_label;
	return sum;
END $$
delimiter ;

select sum_loop(1,100);
select sum_loop(101,100);

-- REPEAT
delimiter $$
create function sum_repeat(buttom int,top INT)
returns INT
LANGUAGE SQL DETERMINISTIC NO SQL SQL SECURITY INVOKER
BEGIN
	declare temp INT;
	declare i INT;
	declare sum int DEFAULT 0;
	IF buttom>top THEN
		set temp=top;
		set top=buttom;
		set buttom=temp;
	END IF;
	set i=buttom;
	sum_label:REPEAT
		set sum=sum+i;
		set i=i+1;
	UNTIL i>top
	END REPEAT sum_label;
	return sum;
END $$
delimiter ;

select sum_repeat(1,100);
select sum_repeat(101,100);


-- 查看函数（存储过程）状态和定义
show function status like 'sum_while';
show create function sum_while;
show procedure status LIKE 'dept_count_pro';
show create procedure dept_count_pro;

select * from information_schema.Routines;

-- 修改函数和存储过程
-- 语法: ALTER {PROCEDURE|FUNCTION} sp_name [characteristic...]
-- 注意：函数和存储过程的代码在定义之后不能修改（只能先删除再新建）
-- 注意：不能修改[NOT] DETERMINISTIC特性，因为函数或存储过程内容不能修改，而内容决定了是否是确定的
alter function sum_while LANGUAGE SQL NO SQL SQL SECURITY INVOKER;

-- 删除函数和存储过程
drop function if exists sum_while;



-- 游标的使用
delimiter $$
create procedure cursor_test(in top_budget DECIMAL(12),out count INT)
begin 
	declare temp_budget DECIMAL;
	declare no_more_record int default 0;
	declare dept_cursor CURSOR for select budget from department;
	DECLARE CONTINUE HANDLER for NOT FOUND SET no_more_record=1;
	
	set count=0;
	open dept_cursor;
	count_loop:LOOP
			--取多个字段  FETCH  NEXT from cur_account INTO phone1,password1,name1; 
			FETCH dept_cursor INTO temp_budget;	
			IF no_more_record=1 THEN
				LEAVE count_loop;
			ELSEIF temp_budget<=top_budget THEN
				set count=count+1;
			END IF;
	END LOOP count_loop;
	close dept_cursor;
END $$
delimiter ;

CALL cursor_test(90000,@d_count);
select @d_count;