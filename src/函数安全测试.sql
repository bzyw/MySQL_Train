
delimiter $$
CREATE FUNCTION my_sum (num1 INT,num2 INT,newDate datetime) 
RETURNS VARCHAR (64) 
DETERMINISTIC SQL SECURITY INVOKER
BEGIN
		DECLARE num1Str varchar(32);
		DECLARE num2Str varchar(32);
		DECLARE dateStr varchar(32);
		select CONCAT(num1,'') INTO num1Str;
		select CONCAT(num2,'') INTO num2Str;
		select DATE_FORMAT(newDate,'%Y-%m-%d %H:%i:%s') into dateStr;
		RETURN (SELECT CONCAT(dateStr,'_',num1Str,'_',num2Str)) ; 
END$$
delimiter ;

show create function my_sum;

delimiter $$
create PROCEDURE add_credit(in userId long,in credit SMALLINT,in newDate date,OUT result VARCHAR(16))
BEGIN
	declare u_count INT default 0;
	INSERT INTO t_takes(t_credit,t_date,user_id) VALUES(credit,newDate,userId);
	select ROW_COUNT() into u_count;
	IF u_count=1 THEN
		SET result='success';
	ELSE
		SET result='failed';
	END IF;
END $$
delimiter ;

call add_credit(1,2,NOW(),@result);
select @result;