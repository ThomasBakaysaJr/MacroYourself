use macroyourself;

drop view if exists listRecIng;
drop view if exists listAllRecIng;
drop view if exists listAllIng;
drop view if exists listAllRec;

create view listRecIng as 
	select recipe.recId, recipe.recFamily, recipe.recVariation, ingredient.ingName, recing.amountused, ingredient.servingmeasurement 
	from recipe, ingredient, recing 
	where recipe.recid = recing.recid and ingredient.ingid = recing.ingid;

create view listAllRecIng as	
	select recipe.recId, recipe.recFamily, recipe.recVariation, recipe.recVersion, ingredient.ingName, recing.amountused, ingredient.servingmeasurement 
	from recipe, ingredient, recing 
	where recipe.recid = recing.recid and ingredient.ingid = recing.ingid;

create view listAllIng as
	select ingredient.ingId, ingredient.ingName, ingredient.servingMeasurement
    from ingredient;
    
create view listAllRec as
	select recipe.recId, recipe.recFamily, recipe.recVariation, recipe.createdDate
    from recipe;
    