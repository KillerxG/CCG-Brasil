--Royal Angel's Glory
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Reveal
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.revtg)
	e1:SetOperation(s.revop)
	c:RegisterEffect(e1)
	--(2)Foolish to gain Race,Type and ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_LVCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_names={777003740,id}
--(1)Reveal
function s.revfilter(c,e,tp,rc)
  return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAttack(1400)
			and (c:IsAbleToHand() or (Duel.GetMZoneCount(tp,rc)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_DECK,0,nil)
	if #g>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1):GetFirst()
			if Duel.SendtoHand(tg,nil,REASON_EFFECT) then
				if tg:IsLevelAbove(5) and tg:IsCanBeSpecialSummoned(e,0,tp,false,false) and  Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
	end
end
--(2)Foolish to gain Race,Type and ATK
function s.tgfilter(c)
	return c:IsMonster() and c:IsRitualMonster() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.cfilter(c,lv,rac,atk)
	return c:IsFaceup() and c:HasLevel() and c:IsPosition(POS_FACEUP_DEFENSE) and (not c:IsRace(rac) or not c:IsLevel(lv) or not c:IsAttack(atk))
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) then
		local lv=sc:GetLevel()
		local rac=sc:GetRace()
		local atk=sc:GetBaseAttack()
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,lv,rac,atk)
		if #g>=1 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
			local sg=g:FilterSelect(tp,s.cfilter,1,2,nil,lv,rac,atk)
			Duel.HintSelection(sg,true)
			Duel.BreakEffect()
			local c=e:GetHandler()
			for tc in sg:Iter() do
				--Level becomes the sent monster's level
				if not tc:IsLevel(lv) then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CHANGE_LEVEL)
					e1:SetValue(lv)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e1)
				end
				--Type becomes the sent monster's type
				if not tc:IsRace(rac) then
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_CHANGE_RACE)
					e2:SetValue(rac)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e2)
				end
				if not tc:IsAttack(atk) then
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_SET_ATTACK_FINAL)
					e2:SetValue(atk)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e2)
				end
			end
		end
	end
end