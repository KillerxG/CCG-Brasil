--Draw Challenge
--Scripted by Slayerzs
local s,id=GetID()
function s.initial_effect(c)
	--(1)Draw
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--(1)Draw
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) and Duel.IsPlayerCanDraw(1-tp,3) end
	end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
local fx=Duel.SelectOption(tp,1371,1372,1370)
local gx=fx+1
local   g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	local d1=Duel.Draw(tp,1,REASON_EFFECT)
	local tc=Duel.GetOperatedGroup():GetFirst()
  Duel.ConfirmCards(1-tp,tc)
	local d2=Duel.Draw(1-tp,1,REASON_EFFECT)
	local tc2=Duel.GetOperatedGroup():GetFirst()
  Duel.ConfirmCards(tp,tc2)
  if gx==1 then
	local challenge=tc:GetAttack()
	local challenge2=tc2:GetAttack()
	if challenge>challenge2 then
			d1=Duel.Draw(tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp)  
	elseif challenge<challenge2 then
			d2=Duel.Draw(1-tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
  elseif challenge==challenge2 and tc:IsType(TYPE_MONSTER) and tc2:IsType(TYPE_MONSTER) then
  d1=Duel.Draw(tp,1,REASON_EFFECT)
  d2=Duel.Draw(1-tp,1,REASON_EFFECT)
    Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
  elseif (tc:IsType(TYPE_SPELL) or tc:IsType(TYPE_TRAP)) and (tc2:IsType(TYPE_SPELL) or tc2:IsType(TYPE_TRAP)) then 
	Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
	Duel.SendtoGrave(tc2,REASON_EFFECT+REASON_DISCARD)
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
  elseif challenge==challenge2 and tc:IsType(TYPE_MONSTER) and (tc2:IsType(TYPE_SPELL) or tc2:IsType(TYPE_TRAP)) then
  d1=Duel.Draw(tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp)
  else 
  			d2=Duel.Draw(1-tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
end
	elseif gx==2 then 
	local challenge=tc:GetDefense()
	local challenge2=tc2:GetDefense()
	if challenge>challenge2 then
			d1=Duel.Draw(tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp)  
	elseif challenge<challenge2 then
			d2=Duel.Draw(1-tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
  elseif challenge==challenge2 and tc:IsType(TYPE_MONSTER) and tc2:IsType(TYPE_MONSTER) then
  d1=Duel.Draw(tp,1,REASON_EFFECT)
  d2=Duel.Draw(1-tp,1,REASON_EFFECT)
    Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
  elseif (tc:IsType(TYPE_SPELL) or tc:IsType(TYPE_TRAP)) and (tc2:IsType(TYPE_SPELL) or tc2:IsType(TYPE_TRAP)) then 
	Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
	Duel.SendtoGrave(tc2,REASON_EFFECT+REASON_DISCARD)
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
  elseif challenge==challenge2 and tc:IsType(TYPE_MONSTER) and (tc2:IsType(TYPE_SPELL) or tc2:IsType(TYPE_TRAP)) then
  d1=Duel.Draw(tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp)
  else 
  			d2=Duel.Draw(1-tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
end
else
	local challenge=tc:GetLevel()
	local challenge2=tc2:GetLevel()
	if challenge>challenge2 then
			d1=Duel.Draw(tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp)  
	elseif challenge<challenge2 then
			d2=Duel.Draw(1-tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
  elseif challenge==challenge2 and tc:IsType(TYPE_MONSTER) and tc2:IsType(TYPE_MONSTER) then
  d1=Duel.Draw(tp,1,REASON_EFFECT)
  d2=Duel.Draw(1-tp,1,REASON_EFFECT)
    Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
  elseif (tc:IsType(TYPE_SPELL) or tc:IsType(TYPE_TRAP)) and (tc2:IsType(TYPE_SPELL) or tc2:IsType(TYPE_TRAP)) then 
	Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
	Duel.SendtoGrave(tc2,REASON_EFFECT+REASON_DISCARD)
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
  elseif challenge==challenge2 and tc:IsType(TYPE_MONSTER) and (tc2:IsType(TYPE_SPELL) or tc2:IsType(TYPE_TRAP)) then
  d1=Duel.Draw(tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp)
  else 
  			d2=Duel.Draw(1-tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp)
end
end
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
local   g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	local d1=Duel.Draw(tp,1,REASON_EFFECT)
	local tc=Duel.GetOperatedGroup():GetFirst()
  Duel.ConfirmCards(1-tp,tc)
	local d2=Duel.Draw(1-tp,1,REASON_EFFECT)
	local tc2=Duel.GetOperatedGroup():GetFirst()
  Duel.ConfirmCards(tp,tc2)
	local challenge=tc:GetDefense()
	local challenge2=tc2:GetDefense()
	if challenge>challenge2 then
			d1=Duel.Draw(tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp)  
	elseif challenge<challenge2 then
			d2=Duel.Draw(1-tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
  elseif challenge==challenge2 and tc:IsType(TYPE_MONSTER) and tc2:IsType(TYPE_MONSTER) then
  d1=Duel.Draw(tp,1,REASON_EFFECT)
  d2=Duel.Draw(1-tp,1,REASON_EFFECT)
    Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
  elseif (tc:IsType(TYPE_SPELL) or tc:IsType(TYPE_TRAP)) and (tc2:IsType(TYPE_SPELL) or tc2:IsType(TYPE_TRAP)) then 
	Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
	Duel.SendtoGrave(tc2,REASON_EFFECT+REASON_DISCARD)
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
  elseif challenge==challenge2 and tc:IsType(TYPE_MONSTER) and (tc2:IsType(TYPE_SPELL) or tc2:IsType(TYPE_TRAP)) then
  d1=Duel.Draw(tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp)
  else 
  			d2=Duel.Draw(1-tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
end
end
function s.activate3(e,tp,eg,ep,ev,re,r,rp)
local   g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	local d1=Duel.Draw(tp,1,REASON_EFFECT)
	local tc=Duel.GetOperatedGroup():GetFirst()
  Duel.ConfirmCards(1-tp,tc)
	local d2=Duel.Draw(1-tp,1,REASON_EFFECT)
	local tc2=Duel.GetOperatedGroup():GetFirst()
  Duel.ConfirmCards(tp,tc2)
	local challenge=tc:GetLevel()
	local challenge2=tc2:GetLevel()
	if challenge>challenge2 then
			d1=Duel.Draw(tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp)  
	elseif challenge<challenge2 then
			d2=Duel.Draw(1-tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
  elseif challenge==challenge2 and tc:IsType(TYPE_MONSTER) and tc2:IsType(TYPE_MONSTER) then
  d1=Duel.Draw(tp,1,REASON_EFFECT)
  d2=Duel.Draw(1-tp,1,REASON_EFFECT)
    Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
  elseif (tc:IsType(TYPE_SPELL) or tc:IsType(TYPE_TRAP)) and (tc2:IsType(TYPE_SPELL) or tc2:IsType(TYPE_TRAP)) then 
	Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
	Duel.SendtoGrave(tc2,REASON_EFFECT+REASON_DISCARD)
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
  elseif challenge==challenge2 and tc:IsType(TYPE_MONSTER) and (tc2:IsType(TYPE_SPELL) or tc2:IsType(TYPE_TRAP)) then
  d1=Duel.Draw(tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp)
  else 
  			d2=Duel.Draw(1-tp,2,REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.ShuffleHand(1-tp) 
end
end
