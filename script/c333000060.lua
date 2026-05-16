--Festos Tools - Comunication Pet
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x311))
    --(1)Place Machine Part Counters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--(2)Draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
--(1)Place Machine Part Counters
function s.ctcon(e)
    return e:GetHandler():GetEquipTarget():IsType(TYPE_NORMAL)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if not eg then return false end
    local tc=eg:GetFirst()
	    if chkc then return chkc==tc end
    if chk==0 then return ep==tp and tc:IsFaceup() and tc:IsSetCard(0x311) and tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
    Duel.SetTargetCard(eg)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local amt=tc:GetLevel()
	local amx=tc:GetRank()
	if not tc:IsType(TYPE_XYZ) then
		e:GetHandler():GetEquipTarget():AddCounter(0x311,amt)
			elseif tc:IsType(TYPE_XYZ) then
				e:GetHandler():GetEquipTarget():AddCounter(0x311,amx)
	end
end
--(2)Draw
function s.drcon(e)
    return e:GetHandler():GetEquipTarget():IsType(TYPE_EFFECT)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(1)
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  if Duel.Draw(p,d,REASON_EFFECT)~=0 then
	local tc=Duel.GetOperatedGroup():GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.BreakEffect()
	if tc:IsType(TYPE_GEMINI) then
	  if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	  and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	  end
	end
	Duel.ShuffleHand(tp)
  end
end