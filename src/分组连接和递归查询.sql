select user_id,GROUP_CONCAT(t_credit ORDER BY t_credit ASC SEPARATOR ',') from t_takes group by user_id;

select FIND_IN_SET('c','a,b,c,d');


delimiter $$
create function getSubArea(areaId INT)
returns varchar(10240)
READS SQL DATA
begin 
	declare subAreaList varchar(10240);
	declare subAreaTemp varchar(1024);
	set subAreaList='$';
	set subAreaTemp=CONVERT(areaId,char);
	my_label:REPEAT
			set subAreaList = CONCAT(subAreaList,',',subAreaTemp);
			select GROUP_CONCAT(id) into subAreaTemp from t_areainfo where FIND_IN_SET(parentId,subAreaTemp)>0;
	UNTIL subAreaTemp is null
	END REPEAT my_label;
	return subAreaList;
end $$
delimiter ;

delimiter $$
create function getSuperArea(areaId INT)
returns varchar(10240)
READS SQL DATA
BEGIN
	declare superAreaList varchar(10240);
	declare temp varchar(1024);
	set temp=CONVERT(areaId,char);
	set superAreaList='$';
	REPEAT
			set superAreaList=CONCAT(superAreaList,',',temp);
			select parentId into temp from t_areainfo where id=temp;
	UNTIL temp=0
	end REPEAT;
	return superAreaList;
END $$
delimiter ;

select getSubArea(4);
select getSuperArea(4);


DROP TABLE IF EXISTS `t_areainfo`;
CREATE TABLE `t_areainfo` (
 `id` int(11) NOT null AUTO_INCREMENT,
 `level` int(11) DEFAULT 0,
 `name` varchar(255) DEFAULT '0',
 `parentId` int(11) DEFAULT 0,
 `status` int(11) DEFAULT 0,
 PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8;

INSERT INTO `t_areainfo` VALUES (1, 0, '中国', 0, 0);
INSERT INTO `t_areainfo` VALUES (2, 0, '华北区', 1, 0);
INSERT INTO `t_areainfo` VALUES (3, 0, '华南区', 1, 0);
INSERT INTO `t_areainfo` VALUES (4, 0, '北京', 2, 0);
INSERT INTO `t_areainfo` VALUES (5, 0, '海淀区', 4, 0);
INSERT INTO `t_areainfo` VALUES (6, 0, '丰台区', 4, 0);
INSERT INTO `t_areainfo` VALUES (7, 0, '朝阳区', 4, 0);
INSERT INTO `t_areainfo` VALUES (27, 0, '北京XX区1', 4, 0);
INSERT INTO `t_areainfo` VALUES (28, 0, '北京XX区2', 4, 0);
INSERT INTO `t_areainfo` VALUES (29, 0, '北京XX区3', 4, 0);
INSERT INTO `t_areainfo` VALUES (30, 0, '北京XX区4', 4, 0);
INSERT INTO `t_areainfo` VALUES (31, 0, '北京XX区5', 4, 0);
INSERT INTO `t_areainfo` VALUES (32, 0, '北京XX区6', 4, 0);
INSERT INTO `t_areainfo` VALUES (33, 0, '北京XX区7', 4, 0);
INSERT INTO `t_areainfo` VALUES (34, 0, '北京XX区8', 4, 0);
INSERT INTO `t_areainfo` VALUES (35, 0, '北京XX区9', 4, 0);
INSERT INTO `t_areainfo` VALUES (36, 0, '北京XX区10', 4, 0);