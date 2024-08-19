DROP DATABASE IF EXISTS `macroyourself`;
CREATE DATABASE IF NOT EXISTS `macroyourself`;
USE `macroyourself`;

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
    PRIMARY KEY (couId, ingId)
    );

create table course(
	couId int NOT NULL AUTO_INCREMENT,
    couName char(255) NOT NULL,
    madeOn date DEFAULT (CURRENT_DATE),
    PRIMARY KEY (couId)
    );

-- VIEWS AND SOME SUCH
drop view if exists listRecIng;
drop view if exists listAllRecIng;

create view listRecIng as 
	select recipe.recId, recipe.recFamily, recipe.recVariation, ingredient.ingName, recing.amountused, ingredient.servingmeasurement 
	from recipe, ingredient, recing 
	where recipe.recid = recing.recid and ingredient.ingid = recing.ingid;

create view listAllRecIng as	
	select recipe.recId, recipe.recFamily, recipe.recVariation, recipe.recVersion, ingredient.ingName, recing.amountused, ingredient.servingmeasurement 
	from recipe, ingredient, recing 
	where recipe.recid = recing.recid and ingredient.ingid = recing.ingid;
    
-- PROCEDURES

delimiter //

create procedure ma_InsertRecipe (in inFamily varchar(255), in inVariation varchar(255), in inVersion int)
begin
	insert into recipe (recFamily, recVariation, recVersion)
    values (inFamily, inVariation, inVersion)
    on duplicate key update recVersion = inVersion + 1;
end // 

delimiter //

create procedure ma_addIngredientToRecipe (in inRecId int, in inIngId int, in inPortion float)
begin
	insert into recIng (recId, ingId, amountUsed)
    value (inRecId, inIngId, inPortion)
    on duplicate key update amountUsed = inPortion;
end //

delimiter ;

-- INSERT THE DEFAULT STUFF INTO THE DATABASE --    
insert into recipe (createdDate, recFamily, recvariation) values (curdate(), 'Omelette', 'Original');
insert into recipe (createdDate, recFamily, recvariation) values (curdate(), 'Egg Sandwich', 'Original');
insert into recipe (createdDate, recFamily, recvariation) values (curdate(), 'Egg Sandwich', 'Cheese');

insert into ingredient (ingName, servingSize, servingMeasurement) values ('Egg', 1, 'count');
insert into ingredient (ingName, servingSize, servingMeasurement) values ('Bread', 1, 'count');
insert into ingredient (ingName, servingSize, servingMeasurement) values ('Mayo', 100, 'grams');
insert into ingredient (ingName, servingSize, servingMeasurement) values ('Cheese', 1, 'count');

insert into nutrient (nutName) value ('Calories');
insert into nutrient (nutName) value ('Protein');
insert into nutrient (nutName) value ('Sugar');
insert into nutrient (nutName) value ('Fat');

set @recName := (select recId from recipe where recFamily = 'Egg Sandwich' AND recvariation = 'Original');

set @ingName := (select ingId from ingredient where ingName = 'Egg');
insert into recing values (@recName, @ingName, 1);
set @ingName := (select ingId from ingredient where ingName = 'Bread');
insert into recing values (@recName, @ingName, 2);
set @ingName := (select ingId from ingredient where ingName = "Mayo");
insert into recing values (@recName, @ingName, 200);

set @recName := (select recId from recipe where recFamily = 'Egg Sandwich' AND recvariation = 'Cheese');

set @ingName := (select ingId from ingredient where ingName = 'Egg');
insert into recing values (@recName, @ingName, 1);
set @ingName := (select ingId from ingredient where ingName = 'Bread');
insert into recing values (@recName, @ingName, 2);
set @ingName := (select ingId from ingredient where ingName = "Mayo");
insert into recing values (@recName, @ingName, 200);
set @ingName := (select ingId from ingredient where ingName = 'Cheese');
insert into recing values (@recName, @ingName, 1);

set @recName := (select recId from recipe where recFamily = 'Omelette' AND recvariation = 'Original');

set @ingName := (select ingId from ingredient where ingName = 'Egg');
insert into recing values (@recName, @ingName, 8);
set @ingName := (select ingId from ingredient where ingName = 'Cheese');
insert into recing values (@recName, @ingName, 2);

select * from listAllRecIng;
