

local addonName, arg1 = ...

-- SavedVariables
-- locals
local _G = _G
local GetSpellCooldown = GetSpellCooldown
local GetSpellCharges  = GetSpellCharges
local IsSpellInRange   = IsSpellInRange

-- lua api
local select   = _G.select
local strmatch = _G.string.match
local tonumber = _G.tonumber
local floor    = _G.math.floor
local sub      = _G.string.sub
local format   = _G.format
local ceil     = _G.math.ceil

EXALIB = {}

EXALIB.ShortenNumber = function(number,digits)
	digits = tonumber(digits) or 0 -- error
	number = tonumber(number) or 0 -- error
    local affix = {'','k','m','b','t','p'}
    local pastPoint = number
    local i = 1
    while number>1000 do
        number = number/1000
        i = i+1
    end
	pastPoint = sub(pastPoint,strlen(floor(number))+1,strlen(floor(number))+digits)
	pastPoint = pastPoint ~= "" and tonumber(pastPoint) or 0
	if digits > 0 and pastPoint > 0 then
    return format("%i",number).. "." .. pastPoint .. affix[i]
	else
	return format("%i",number) .. affix[i]
	end
end

EXALIB.ClassColour = function(class)
	if class == "Paladin" then
        return  0.96,0.55,0.73,1
    elseif class == "Mage" then
        return 0.41,0.8,0.94,1
    elseif class == "Druid" then
        return 1,0.49,0.04,1
    elseif class == "Death Knight" then
        return 0.77,0.12,0.23,1
    elseif class == "Hunter" then
        return 0.67,0.83,0.45,1
    elseif class == "Monk" then
        return 0.33,0.74,0.52,1
    elseif class == "Priest" then
        return 1,1,1,1
    elseif class == "Rogue" then
        return 1,0.96,0.41,1
    elseif class == "Shaman" then
        return 0,0.44,0.87,1
    elseif class == "Warlock" then
        return 0.58,0.51,0.79,1
    elseif class == "Warrior" then
        return 0.78,0.61,0.43,1
    elseif class == "Demon Hunter" then
        return 0.64,0.19,0.79,1
    end
    return 0.2,0.72,0.06,1
end

EXALIB.UnitColor = function(unit)
	if UnitIsTapDenied(unit) then
		return 0.36,0.36,0.36,1 --unit is tagged
	elseif  UnitIsPlayer(unit) then -- if unit is player
		local class = UnitClass(unit)
		if UnitIsFriend then
			return EXALIB.ClassColour(class) -- friendly (player)
		else
			return 0.83,0.11,0.12,1 -- enemy (player)
		end
	else -- unit is npc
		local reaction = UnitReaction('player',unit) or 0
		if reaction == 4 then
			if UnitAffectingCombat(unit) then
				return 0.83,0.11,0.12,1
			else
				return 1,0.8,0.21,1 -- neutral (npc)
			end
		elseif reaction > 4 then
			 return 0.2,0.72,0.06,1 -- friendly (npc)
		else
			 return 0.83,0.11,0.12,1 -- hated (npc)
		end
	end
	return 1,1,1,1 -- should never happen
end

EXALIB.TimeShort = function(time)
    if time <= 5 then -- under 5s
        return format('%.1f',time) .. '|cFFAAAAAAs'
    elseif time<60 then
        return format('%i',time) .. '|cFFAAAAAAs'
    else
        local min = (time/60 - floor(time/60)) > 0.5 and ceil(time/60) or floor(time/60)
        return min .. '|cFFAAAAAAm|r'
    end
end

EXALIB.StringShort = function(String,maxLen)
    if strlen(String) > maxLen then
        local wordcnt = 1;
        local wordfl = {1};

        -- how many words
        for i=2,strlen(String),1 do
            if sub(String,i,i) == " " then
                wordcnt = wordcnt + 1; -- add word
                wordfl[wordcnt] = i+1; -- where new word starts
            end
        end
        -- format if more than 1 word
        if wordcnt>1 then
            local longname = "";
            local s = 1;
            for j=wordcnt,1,-1 do
                if (j==1 and maxLen < 2*(wordcnt-1)+(strlen(String)-wordfl[s]+1)) then
                    local trmStr = (2*(wordcnt-1)+(strlen(String)-wordfl[s]+1))-maxLen+3;
                    longname = longname .. sub(String,wordfl[s],strlen(String)-trmStr) .. "...";
                elseif (j==1) then
                    longname = longname  .. sub(String,wordfl[s],strlen(String));
                else
                    longname = longname .. sub(String,wordfl[s],wordfl[s]) .. ".";
                end
                s=s+1
            end
            return format(longname)
        else
            return sub(String,1,maxLen-3) .. "..."
        end
    else
        return format(String)
    end
end

EXALIB.GetSpellInfo = function(id,item)
	if not item then
		-- spell
		local charges,maxCharges,start,duration
		if GetSpellCharges(id) then
			charges,maxCharges,start,duration = GetSpellCharges(id)
			return charges,maxCharges,start,duration
		else
			start,duration = GetSpellCooldown(id)
			charges = 0
			maxCharges = 0
			return charges,maxCharges,start,duration
		end
	else
		-- item
		-- return itemcount,itemcount,start,duration
		local start,duration,enable = GetItemCooldown(id) -- enable => Should Cooldown go on
		local itemCount = GetItemCount(id)
		return itemCount,itemCount,start,duration,enable
	end
end

EXALIB.SpellOnCD = function(id,item)
	if not item then
		-- spell
		local _,gcd = GetSpellCooldown(61304)
		if GetSpellCharges(id) then
			local c,cm,s,d = GetSpellCharges(id)
			return d > gcd and c < cm
		else
			return select(2,GetSpellCooldown(id)) > gcd
		end
	else
		-- item
		local start,duration,enable = GetItemCooldown(id)
		return duration > 0
	end
end

EXALIB.SpellOnCDCharges = function(id,item)
	if not item then
		-- spell
		if GetSpellCharges(id)then
			local charges,maxCharges = GetSpellCharges(id)
			return charges > 0
		end
		return false
	else
		-- item
		return false
	end
end
