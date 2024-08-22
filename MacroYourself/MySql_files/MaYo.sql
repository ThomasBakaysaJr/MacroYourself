DROP DATABASE IF EXISTS `macroyourself`;
CREATE DATABASE IF NOT EXISTS `macroyourself`;
USE `macroyourself`;

# Last edit 8/22/2024
# Developed by: Thomas T Bakaysa Jr

create table recipe(
    createdDate date NOT NULL default(curdate()),
	recId int NOT NULL AUTO_INCREMENT,
    recFamily varchar(255) NOT NULL,
    recVariation varchar(255) NOT NULL,
    recVersion int NOT NULL default(1),
    constraint full_name unique(recFamily, recVariation, recVersion),
    PRIMARY	KEY (recId)
    );

create table ingredient(
	ingId int NOT NULL AUTO_INCREMENT,
    ingName varchar(255) NOT NULL,
    servingSize int NOT NULL,
    servingMeasurement ENUM('grams', 'count', 'mil Liters') NOT NULL default('grams'),
    PRIMARY KEY (ingId)
    );

create table nutrient(
	nutId int NOT NULL AUTO_INCREMENT,
    nutName varchar(255) NOT NULL,
    PRIMARY KEY (nutId)
    );
    
    
create table course(
	couId int NOT NULL AUTO_INCREMENT,
    couFamily char(255) NOT NULL,
    couVariation char(255) DEFAULT ("Original"),
    madeOn date DEFAULT (CURRENT_DATE),
    PRIMARY KEY (couId)
    );

#						#
-- ASSOCIATIVE TABLES -- 
#						#
 
create table recIng(
	recId int NOT NULL,
    ingId int NOT NULL,
    amountUsed float NOT NULL,
    constraint PK_recIng PRIMARY KEY (recId, ingId),
    FOREIGN KEY(recId)
		references recipe(recId)
        on delete cascade,
	FOREIGN KEY(ingId)
		references ingredient(ingId)
		on delete cascade
    );
    
create table ingNut(
	ingId int NOT NULL,
    nutId int NOT NULL,
    amountPresent float NOT NULL,
    constraint PK_ingNut PRIMARY KEY (ingId, nutId),
    FOREIGN KEY(ingId)
		references ingredient(ingId)
		on delete cascade,
	FOREIGN KEY(nutId)
		references nutrient(nutId)
        on delete cascade
    );    

create table couIng(
	couId int,
    ingId int,
    amountPresent float NOT NULL,
    PRIMARY KEY (couId, ingId),
    FOREIGN KEY (couId)
		references course(couId)
        on delete cascade,
	FOREIGN KEY (ingId)
		references ingredient(ingId)
        on delete cascade
    );
