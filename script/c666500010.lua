--Priestess.lua
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Link Summon Procedure
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	--Link Up
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_LINK)
	e0:SetRange(LOCATION_EMZONE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LINK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return (e:GetHandler():GetSequence()==1 or e:GetHandler():GetSequence()==3) end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Bottom Link Marker
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_LINKMARKER)
	e2:SetRange(LOCATION_EMZONE)
	e2:SetValue(LINK_MARKER_BOTTOM)
	c:RegisterEffect(e2)
	--Top Link Marker
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ADD_LINKMARKER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return (e:GetHandler():GetSequence()==1 or e:GetHandler():GetSequence()==3) end)
	e3:SetValue(LINK_MARKER_TOP)
	c:RegisterEffect(e3)
    --Gain ATK
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.atktg)
	e4:SetValue(1000)
	c:RegisterEffect(e4)
	--Search/Send to GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCountLimit(1,{id,1})
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.thtgtg)
	e5:SetOperation(s.thtgop)
	c:RegisterEffect(e5)
end
--Link Summon Procedure
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x660,lc,sumtype,tp)
end
--Gain ATK
function s.atktg(e,c)
	return c:IsLinked() and c:IsSetCard(0x660)
end
--Search/Send to GY
function s.thtgfilter(c)
	return c:IsSetCard(0x660) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.thtgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thtgfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.thtgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thtgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	aux.ToHandOrElse(tc,tp)
end