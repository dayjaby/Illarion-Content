-- Noobia triggerfields: teleport char to Cadomyr, Runewick or Galmair
-- by Merung

-- INSERT INTO triggerfields VALUES (56,96,100,'triggerfield.noobiafactionwarp');
-- INSERT INTO triggerfields VALUES (20,99,100,'triggerfield.noobiafactionwarp');
-- INSERT INTO triggerfields VALUES (40,111,100,'triggerfield.noobiafactionwarp');

require("base.common")

module("triggerfield.noobiafactionwarp", package.seeall)

function MoveToField(Character)

    -- Cadomyr: 127 647 0
    -- Runewick: 788 826 0
    -- Galmair: 424 245 0

    -- we define our destination
    if Character.pos == position(56,96,100) then --Cadomyr
	   destination = position(127,647,0);
	elseif Character.pos == position(20,99,100) then --Runewick
	   destination = position(788,826,0);
    elseif Character.pos == position(40,111,100) then --Galmair
	   destination = position(424,245,0);
	end

    world:gfx(41,Character.pos)	
	Character:warp(destination)
    world:makeSound(4,destination)
    world:gfx(41,Character.pos)	
	
	FactionCheck = base.factions.get_Faction(Character)
	if not Character:isAdmin() and not (FactionCheck.tid~=0) then -- admins and chars who are already members of a faction are unaffected and just warped 
	
		-- we delete some items, if the char has more than one of them
		local DeleteList = {23,391,2763} --hammer, torch, pick-axe
		for i=1,#DeleteList do
			itemAmount = Character:count(DeleteList[i])
			Character:eraseItem( ItemListe[i], (itemAmount -1))
		end	
		
		-- we remove the newbie lte
		find, myEffect = Character.effects:find(13)
		if find then
			removedEffect = Character.effects:removeEffect(13)
			if not removedEffect then -- security check
				Character:inform("[Error] Please contact a developer. Error: Triggerfields to factions.")
			end
		end
		
		Character:setAttrib("hitpoints",10000)
		Character:setAttrib("mana",10000)
		Character:setAttrib("foodlevel",30000)
		
		local callbackNewbie = function(dialogNewbie) end; --empty callback
			
	        if Character:getPlayerLanguage() == 0 then
		        dialogNewbie = MessageDialog("Überschrift","deutscher Text", callbackNewbie)
	        else	
		        dialogNewbie = MessageDialog("Tutorial", "Congratulations, you finished the tutorial. ", callbackNewbie)
	        end	
	        Character:requestMessageDialog(dialogNewbie)
	end	
end	