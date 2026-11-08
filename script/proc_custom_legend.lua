--Custom Legend Cards
--Scripted by Codex
if CustomLegend then return end
CustomLegend={}

--Each entry stores the card's Legend category.
CustomLegend.Cards={
	[776000200]=TYPE_MONSTER, --The Winged Dragon of Ra
	[776000210]=TYPE_MONSTER, --Slifer the Sky Dragon
	[776000220]=TYPE_MONSTER, --Obelisk the Tormentor
	[776000230]=TYPE_MONSTER, --Uria, Lord of Searing Flames
	[776000240]=TYPE_MONSTER, --Raviel, Lord of Phantasms
	[776000250]=TYPE_MONSTER, --Hamon, Lord of Striking Thunder
	[776000260]=TYPE_MONSTER, --Odin, Father of the Aesir
	[776000270]=TYPE_MONSTER, --Thor, Lord of the Aesir
	[776000280]=TYPE_MONSTER  --Loki, Lord of the Aesir
}

function CustomLegend.IsLegend(c)
	return c and CustomLegend.Cards[c:GetOriginalCode()]~=nil
end

function CustomLegend.GetType(c)
	return c and CustomLegend.Cards[c:GetOriginalCode()] or nil
end

function CustomLegend.IsType(c,card_type)
	return CustomLegend.GetType(c)==card_type
end

--Extend the native Rush Duel check without replacing its original list.
local original_is_legend=Card.IsLegend
function Card.IsLegend(c)
	return CustomLegend.IsLegend(c)
		or (original_is_legend and original_is_legend(c))
		or false
end

function Card.GetLegendType(c)
	if CustomLegend.IsLegend(c) then
		return CustomLegend.GetType(c)
	end
	if original_is_legend and original_is_legend(c) then
		if c:IsMonster() then return TYPE_MONSTER end
		if c:IsSpell() then return TYPE_SPELL end
		if c:IsTrap() then return TYPE_TRAP end
	end
	return nil
end
