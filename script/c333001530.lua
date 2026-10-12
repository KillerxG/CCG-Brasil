--Spectral Ascension
--Scripted by Codex
local s,id=GetID()
function s.initial_effect(c)
	--Set up to 2 "Spectral Hunter" monsters with different names from the Deck as Traps
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--Special Summon 1 "Spectral Hunter" Xyz Monster and attach the targeted monsters to it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.xyzcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end
s.listed_series={0x250}

function s.setfilter(c)
	return c:IsSetCard(0x250) and c:IsMonster() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return ft>0 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,math.min(2,ft,g:GetClassCount(Card.GetCode)),tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	local mg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	local maxct=math.min(2,ft,mg:GetClassCount(Card.GetCode))
	if maxct==0 then return end
	local g=aux.SelectUnselectGroup(mg,e,tp,1,maxct,aux.dncheck,1,tp,HINTMSG_SET)
	if #g==0 or Duel.SSet(tp,g)==0 then return end
	for tc in g:Iter() do
		if tc:IsControler(tp) and tc:IsLocation(LOCATION_SZONE) then
			--Treat the Set monster as a Trap
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_TRAP)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			--It can be activated this turn
			local e2=Effect.CreateEffect(tc)
			e2:SetDescription(aux.Stringid(id,2))
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT)
			e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end

function s.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.oppfilter(c,e)
	return c:IsCanBeEffectTarget(e)
end
function s.ownfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x250) and c:IsCanBeEffectTarget(e)
end
function s.xyzfilter(c,e,tp)
	return c:IsSetCard(0x250) and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
			and ((chkc:IsControler(tp) and s.ownfilter(chkc,e))
				or (chkc:IsControler(1-tp) and s.oppfilter(chkc,e)))
	end
	if chk==0 then return Duel.IsExistingTarget(s.oppfilter,tp,0,LOCATION_MZONE,1,nil,e)
		and Duel.IsExistingTarget(s.ownfilter,tp,LOCATION_MZONE,0,1,nil,e)
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.oppfilter,tp,0,LOCATION_MZONE,1,1,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.ownfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not sc or Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)==0 then return end
	sc:CompleteProcedure()
	local g=Duel.GetTargetCards(e):Filter(function(c,e)
		return c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
	end,nil,e)
	if #g>0 then
		Duel.Overlay(sc,g,true)
	end
end
