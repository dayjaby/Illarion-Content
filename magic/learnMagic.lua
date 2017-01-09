--[[
Illarion Server

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

local common = require("base.common")

-- IMPORTANT: Add new books to the END of the list. The list must not contain more than 30 elements.
local magicBooks = {337, 351, 379, 382, 398, 401, 404}

local amountNeeded = 3

function M.readMagicBooks(user, bookId)

    -- Alchemists cannot become mages.
    if user:getMagicType() == 3 then 
        return
    end
    
    -- Attribute requirements
    if user:increaseAttrib("willpower", 0) + user:increaseAttrib("essence", 0) + user:increaseAttrib("intelligence") < 30 then
        return
    end
    
    -- Already is a mage
    if user:getMagicType() == 0 and (user:getQuestProgress(37) ~= 0 or user:getMagicFlags(0) > 0)
        return
    end
    
    local questProgress = user:getQuestProgress(38)
    
    -- Already did all the reading
    if bit32.extract(questProgress, 30) == 1 then
        return
    end
    
    -- Register new book if it is a magical one
    local foundNewBook = false
    for i = 1, #magicBooks do
        if magicBooks[i] == bookId then
            local bitToChange = i - 1
            questProgress = bit32.replace(questProgress, 1, bitToChange)
            foundNewBook = true
        end
    end
    
    if foundNewBook then
        
        -- Count how many magic books have been read
        local readBooks = 0
        for i = 0, #magicBooks-1 do
            if bit32.extract(questProgress, i) == 1 then
                readBooks = readBooks + 1
            end
        end
        
        if readBooks < 3 then
            user:inform("Das Lesen dieses Buches hat dein Verst�ndnis der Magie vertieft. Wenn du weitere B�cher �ber Magie findest, kannst du ja vielleicht selbst bald ein Magier werden.", "This book forwards your understanding of magic. If you want more books about magic, you might be able to become a magician yourself as well.", Character.highPriority)
        
        elseif bit32.extract(questProgress, 30) == 0 then    
            
            local callback = function(dialog)end;
            
            if user:getPlayerLanguage() == Player.german then
                dialog = MessageDialog("Magische Lekt�re", "Durch das Lesen der verschiedenen B�cher �ber Magie hast du ein tiefes Verst�ndnis f�r die arkanen K�nste erlangt. Um den Pfad der Magie zu betreten, ergreife einen Zauberstab und konzentriere dich auf deine innere St�rke.", callback)
            else
                dialog = MessageDialog("Magical reading", "Reading the various books about magic gave you a vast understanding of the arcane arts. To follow the path of magic, you should acquire a magical wand, hold it firmly and concentrate on your inner strength.", callback)
            end
            questProgress = bit32.replace(questProgress, 1, 30)
        end
    end
    
    user:setQuestProgress(38, questProgress)
end

function M.useMagicWand(user, sourceItem)
    
    -- Alchemists cannot become mages.
    if user:getMagicType() == 3 then 
        return
    end
    
    -- Attribute requirements
    if user:increaseAttrib("willpower", 0) + user:increaseAttrib("essence", 0) + user:increaseAttrib("intelligence") < 30 then
        return
    end
    
    -- Already is a mage
    if user:getMagicType() == 0 and (user:getQuestProgress(37) ~= 0 or user:getMagicFlags(0) > 0)
        return
    end

    local questProgress = user:getQuestProgress(38)

    -- Has not read enough books
    if bit32.extract(questProgress, 30) == 0 then
        return
    end
    
    local callback = function(dialog)
        local success = dialog:getSuccess()
        if success then
            if dialog:getSelectedIndex() == 0 then
                local messageCallback = function(dialog)
                    user:setMagicType(3)
                    world:makeSound(13,user.pos)
                    world:gfx(31,user.pos)
                    world:gfx(52,user.pos)
                    world:gfx(31,user.pos)
                    user:setQuestProgress(37, 1)
                end
                
                if user:getPlayerLanguage() == Player.german then
                    dialog = MessageDialog("Ein neuer Magier", "Du gibst dich der im Stab verborgenen arkanen Kraft hin und l�sst sie durch deinen K�rper flie�en. Ja! Du kannst diese Macht beherrschen. Von nun an bist du in der Lage Magie zu werden. Der Stab wird dir gehorchen.", callback)
                else
                    dialog = MessageDialog("A new mage", "You induldge in the hidden arcane powers which you found in the wand. You let it run through your body. Yes! You are now able to control this force. From this day on, you are able to use magic. The wand will obey your commands.", callback)
                end
                
            else
                user:inform("Du hast dich dagegen entschieden Magier zu werden. Die M�glichkeit bleibt dir aber offen.", "You decided against becoming a mage. The option, however, will remain available to you.", Character.highPriority)
            end
        else
            user:inform("Du hast dich dagegen entschieden Magier zu werden. Die M�glichkeit bleibt dir aber offen.", "You decided against becoming a mage. The option, however, will remain available to you.", Character.highPriority)
        end
    end
    local dialog = SelectionDialog(common.GetNLS(user, "Der Weg der Magie", "The path of magic"), common.GetNLS(user, "Als du den Stab ber�hrst, kannst du seine magische Macht sp�ren. Dir scheint, dass es dir gelingen k�nnte, sie dir nutzbar zu machen. Willst du das tun und somit zu einem Magier werden? Bedenke, dass eine weitere hohe Kunst - die Alchemie - dir so dann verschlossen sein wird.", "As you touch the wand, you can feel its magical power. It seems to you that you should be able to use this power. Do you want to do so and, therefore, become a mage? Mind that an other high art - alchemy - will not be accessable for you once you became a mage."), callback)
    dialog:addOption(0, common.GetNLS(user, "Werde Magier", "Become a mage"))
    dialog:addOption(0, common.GetNLS(user, "Nein. Vielleicht sp�ter.", "No. Maybe later."))
    User:requestSelectionDialog(dialog)
    
end