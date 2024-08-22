use macroyourself;

drop procedure if exists ma_InsertRecipe;
drop procedure if exists ma_addIngredientToRecipe;
drop procedure if exists ma_InsertCourse;

delimiter //

create procedure ma_InsertRecipe (in inFamily varchar(255), in inVariation varchar(255))
begin
	insert into recipe (recFamily, recVariation, recVersion)
    values (inFamily, inVariation, 1)
    on duplicate key update recVersion = recVersion + 1;
end // 

delimiter ;

delimiter //

create procedure ma_InsertCourse (in inRecId int)
begin
	DECLARE newFamily, newVariation varchar(255);
    DECLARE tempId int;
    
    select recFamily 
    into newFamily 
    from recipe
    where recipe.recId = inRecId;
    
    select recVariation
    into newVariation
    from recipe
    where recipe.recId = inRecId;
    
    insert into course(couFamily, couVariation)
    values (newFamily, newVariation);
    
    set tempId = last_insert_id();
    
    insert into couIng (couId, ingId)
		select tempId, recIng.ingId from recIng where recIng.recId = inRecId;
    
end //

delimiter ;

delimiter //

create procedure ma_addIngredientToRecipe (in inRecId int, in inIngId int, in inPortion float)
begin
	insert into recIng (recId, ingId, amountUsed)
    value (inRecId, inIngId, inPortion)
    on duplicate key update amountUsed = inPortion;
end //

delimiter ;
