-- Mr. Basalt Sky Crusher - 333001680
local s,id=GetID()
local ORIGINAL=333001580
local ATTR=ATTRIBUTE_EARTH
local RACE=RACE_ROCK
local SET_MR=0x215b

function s.xyzfilter(c,xyz,sumtype,tp)
 return c:IsLevel(5) and c:IsAttribute(ATTR) and c:IsRace(RACE)
  and (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI))
end
function s.has_original(e)
 return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,ORIGINAL)
end
function s.attribute_target(e,c)
 return c:IsMonster() and (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI))
end
function s.initial_effect(c)
 Xyz.AddProcedure(c,s.xyzfilter,5,2)
 c:EnableReviveLimit()
 -- Name becomes Mr. Basalt on field/in GY.
 local e1=Effect.CreateEffect(c)
 e1:SetType(EFFECT_TYPE_SINGLE)
 e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
 e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
 e1:SetCode(EFFECT_CHANGE_CODE)
 e1:SetValue(ORIGINAL)
 c:RegisterEffect(e1)
 -- Normal Monster in GY.
 local e2=Effect.CreateEffect(c)
 e2:SetType(EFFECT_TYPE_SINGLE)
 e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
 e2:SetRange(LOCATION_GRAVE)
 e2:SetCode(EFFECT_ADD_TYPE)
 e2:SetValue(TYPE_NORMAL)
 c:RegisterEffect(e2)
 -- Attribute aura while Mr. Basalt is attached.
 local e3=Effect.CreateEffect(c)
 e3:SetType(EFFECT_TYPE_FIELD)
 e3:SetCode(EFFECT_ADD_ATTRIBUTE)
 e3:SetRange(LOCATION_MZONE)
 e3:SetTargetRange(LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE)
 e3:SetCondition(s.has_original)
 e3:SetTarget(s.attribute_target)
 e3:SetValue(ATTR)
 c:RegisterEffect(e3)
 -- EARTH monsters on field cannot be destroyed by battle.
 local e4=Effect.CreateEffect(c)
 e4:SetType(EFFECT_TYPE_FIELD)
 e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
 e4:SetRange(LOCATION_MZONE)
 e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
 e4:SetTarget(function(e,tc) return tc:IsAttribute(ATTR) end)
 e4:SetValue(1)
 c:RegisterEffect(e4)
 -- Battle damage in a monster-vs-monster battle: select and modify ATK.
 local e5=Effect.CreateEffect(c)
 e5:SetDescription(aux.Stringid(id,0))
 e5:SetCategory(CATEGORY_ATKCHANGE)
 e5:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
 e5:SetCode(EVENT_BATTLE_DAMAGE)
 e5:SetRange(LOCATION_MZONE)
 e5:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
 e5:SetCountLimit(1,{id,0})
 e5:SetCondition(s.dmgcon)
 e5:SetTarget(s.dmgtg)
 e5:SetOperation(s.dmgop)
 c:RegisterEffect(e5)
 -- On an EARTH monster battle: detach, change position, grant piercing.
 local e6=Effect.CreateEffect(c)
 e6:SetDescription(aux.Stringid(id,1))
 e6:SetCategory(CATEGORY_POSITION)
 e6:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
 e6:SetCode(EVENT_ATTACK_ANNOUNCE)
 e6:SetRange(LOCATION_MZONE)
 e6:SetCountLimit(1,{id,1})
 e6:SetCondition(s.piercecon)
 e6:SetCost(s.piercecost)
 e6:SetTarget(s.piercetg)
 e6:SetOperation(s.pierceop)
 c:RegisterEffect(e6)
 -- GY Ignition; no destruction condition.
 local e7=Effect.CreateEffect(c)
 e7:SetDescription(aux.Stringid(id,2))
 e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
 e7:SetType(EFFECT_TYPE_IGNITION)
 e7:SetRange(LOCATION_GRAVE)
 e7:SetCountLimit(1,{id,2})
 e7:SetCost(s.rev_cost)
 e7:SetTarget(s.rev_tg)
 e7:SetOperation(s.rev_op)
 c:RegisterEffect(e7)
end

function s.mrfilter(c)
 return c:IsMonster() and c:IsSetCard(SET_MR)
end
function s.attcount(tp)
 local g=Duel.GetMatchingGroup(s.mrfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
 local mask=0
 for tc in aux.Next(g) do mask=mask|tc:GetAttribute() end
 local ct=0
 for _,attr in ipairs({ATTRIBUTE_EARTH,ATTRIBUTE_WATER,ATTRIBUTE_FIRE,ATTRIBUTE_WIND,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK,ATTRIBUTE_DIVINE}) do
  if (mask&attr)~=0 then ct=ct+1 end
 end
 return ct
end
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
 local a=Duel.GetAttacker()
 local d=Duel.GetAttackTarget()
 return ev>0 and a~=nil and d~=nil and a:IsMonster() and d:IsMonster()
end
function s.atkfilter(c)
 return c:IsFaceup() and c:IsMonster()
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
 local ct=s.attcount(tp)
 if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
 local max=math.min(ct,Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil))
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
 local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,max,nil)
 e:SetLabel(ev)
 Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0)
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
 local dmg=e:GetLabel()
 if dmg<=0 then return end
 local g=Duel.GetTargetCards(e)
 for tc in aux.Next(g) do
  if tc:IsFaceup() and tc:IsMonster() then
   local val=tc:IsControler(tp) and dmg or -dmg
   local ec=Effect.CreateEffect(e:GetHandler())
   ec:SetType(EFFECT_TYPE_SINGLE)
   ec:SetCode(EFFECT_UPDATE_ATTACK)
   ec:SetValue(val)
   ec:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
   tc:RegisterEffect(ec)
  end
 end
end

function s.piercecon(e,tp,eg,ep,ev,re,r,rp)
 local a=Duel.GetAttacker()
 local d=Duel.GetAttackTarget()
 return (a and a:IsAttribute(ATTR)) or (d and d:IsAttribute(ATTR))
end
function s.piercecost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
 e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.piercefilter(c)
 return c:IsFaceup() and c:IsAttribute(ATTR) and c:IsType(TYPE_NORMAL)
end
function s.piercetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsOnField() and s.piercefilter(chkc) end
 if chk==0 then return Duel.IsExistingMatchingCard(s.piercefilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
 local g=Duel.SelectTarget(tp,s.piercefilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
 -- First selected card changes battle position; second gains piercing.
 local first=g:Select(tp,1,1,nil):GetFirst()
 e:SetLabelObject(first)
 Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.pierceop(e,tp,eg,ep,ev,re,r,rp)
 local g=Duel.GetTargetCards(e)
 local first=e:GetLabelObject()
 if not first or not g:IsContains(first) then return end
 local other=g:Filter(function(c) return c~=first end,nil):GetFirst()
 if first:IsFaceup() then
  if first:IsAttackPos() then Duel.ChangePosition(first,POS_FACEUP_DEFENSE)
  else Duel.ChangePosition(first,POS_FACEUP_ATTACK) end
 end
 if other and other:IsFaceup() then
  local pe=Effect.CreateEffect(e:GetHandler())
  pe:SetType(EFFECT_TYPE_SINGLE)
  pe:SetCode(EFFECT_PIERCE)
  pe:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
  other:RegisterEffect(pe)
 end
end

function s.originalfilter(c,e,tp)
 return c:IsCode(ORIGINAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rev_cost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
 Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.rev_tg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.originalfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.rev_op(e,tp,eg,ep,ev,re,r,rp)
 if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 local g=Duel.SelectMatchingCard(tp,s.originalfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
 local tc=g:GetFirst()
 if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
 local eff=Effect.CreateEffect(tc)
 eff:SetType(EFFECT_TYPE_SINGLE)
 eff:SetCode(EFFECT_ADD_TYPE)
 eff:SetValue(TYPE_EFFECT)
 eff:SetReset(RESET_EVENT|RESETS_STANDARD)
 tc:RegisterEffect(eff)
 local ne=Effect.CreateEffect(tc)
 ne:SetDescription(aux.Stringid(id,3))
 ne:SetCategory(CATEGORY_SPECIAL_SUMMON)
 ne:SetType(EFFECT_TYPE_IGNITION)
 ne:SetRange(LOCATION_MZONE)
 ne:SetCountLimit(1,ORIGINAL+80000000)
 ne:SetTarget(s.ban_tg)
 ne:SetOperation(s.ban_op)
 ne:SetReset(RESET_EVENT|RESETS_STANDARD)
 tc:RegisterEffect(ne)
end
function s.banfilter(c,e,tp)
 return c:IsFaceup() and c:IsSetCard(SET_MR) and c:IsType(TYPE_XYZ)
  and not c:IsAttribute(ATTR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ban_tg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.ban_op(e,tp,eg,ep,ev,re,r,rp)
 local c=e:GetHandler()
 if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
 local xyz=g:GetFirst()
 if xyz and Duel.SpecialSummon(xyz,0,tp,tp,false,false,POS_FACEUP)>0
  and xyz:IsFaceup() and xyz:IsType(TYPE_XYZ) and c:IsRelateToEffect(e) then
  Duel.Overlay(xyz,Group.FromCards(c))
 end
end
