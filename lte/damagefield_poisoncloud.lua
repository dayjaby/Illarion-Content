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
require("base.common")
require("monster.base.monstermagic")

-- Long time effect (112)
module("lte.damagefield_poisoncloud", package.seeall)

local function causeDamage(User, quality)

    local resist = monster.base.monstermagic.SpellResistence(User) * 10
    if resist < quality then
        local damageLow = 3 * math.floor((math.max(10, quality - resist)))
        local damageHigh = 5 * math.floor(quality - resist)
        local damageDealt = math.random(math.min(damageLow, damageHigh), math.max(damageLow, damageHigh))
        User:increaseAttrib("hitpoints", -damageDealt);
    end
end

function addEffect(theEffect, User)

    User:inform("Du f�hlst wie dein K�rper schw�cher wird.",
                "You feel your body becoming weaker.")
    local _, quality = theEffect:findValue("quality")
    causeDamage(User, quality)
end

function callEffect(theEffect, User)

    -- check if still on a damaging field
    local Items = base.common.GetItemsOnField(User.pos)
    local FieldItem

    for _, item in pairs(Items) do
        if(item.id == 372) then
            FieldItem = item
            break
        end
    end

    -- not on damaging field enymore
    if FieldItem == nil then
        return false
    end

    causeDamage(User, FieldItem.quality)
    -- repeat in 5sec
    theEffect.nextCalled = 50
    return true
end

function loadEffect(theEffect, User)
    -- we dont care
end

function removeEffect (theEffect, User)

    User:inform("Du f�hlst wie das Gift in deinem K�rper nachl�sst.",
                "You feel the poison fade.")
end