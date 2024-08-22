use macroyourself;

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
