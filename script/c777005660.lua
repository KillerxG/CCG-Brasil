--Dark Magician Girl of Silent
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,false,false,CARD_DARK_MAGICIAN_GIRL,aux.FilterBoolFunctionEx(Card.IsSetCard,0xe8))
	--(1)Immune to Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--(2)Negate opponent's Spell effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--(3)Special Summon 1 Dark Magician Girl or 1 Silent Magician monster from your GY and place the other on the bottom of the Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e4:SetCost(Cost.SelfBanish)
	e4:SetTarget(s.sptdtg)
	e4:SetOperation(s.sptdop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_DARK_MAGICIAN_GIRL}
--(1)Immune to Spell
function s.efilter(e,te)
	return te:IsSpellEffect() and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--(2)Negate opponent's Spell effects
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsSpellEffect() and Duel.IsChainNegatable(ev)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():HasLevel() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and c:IsRelateToEffect(e) and c:IsFaceup() then
		--Increase its ATK by 500
		c:UpdateAttack(500)
	end
end
--(3)Special Summon 1 Dark Magician Girl or 1 Silent Magician monster from your GY and place the other on the bottom of the Deck
function s.sptdfilter(c,e,tp)
	return (c:IsCode(CARD_DARK_MAGICIAN_GIRL) or c:IsSetCard(0xe8)) and (c:IsCanBeSpecialSummoned(e,0,tp,true,true) or c:IsAbleToDeck())
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsCode,1,nil,CARD_DARK_MAGICIAN_GIRL) and sg:IsExists(Card.IsSetCard,1,nil,0xe8)
		and sg:IsExists(s.spchk,1,nil,e,tp,sg)
end
function s.spchk(c,e,tp,sg)
	return c:IsCanBeSpecialSummoned(e,0,tp,true,true) and (#sg==1 or sg:IsExists(Card.IsAbleToDeck,1,c))
end
function s.sptdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.sptdfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,tp,0)
end
function s.sptdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if (#tg==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=tg:FilterSelect(tp,s.spchk,1,1,nil,e,tp,tg)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,true,true,POS_FACEUP)>0 and #tg==2 then
		local dg=tg-sg
		Duel.HintSelection(dg)
		Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end