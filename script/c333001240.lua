--Freealow Plumatriarch
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WIND),6,2)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(function(e,c) return c:IsSetCard(0x759) end)
	e0:SetValue(function(e,_,rc) return rc==e:GetHandler() and 6 or 0 end)
	c:RegisterEffect(e0)
	-- E1: Special Summon WIND + destroy/overlay
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.ssptg)
    e1:SetOperation(s.sspop)
    c:RegisterEffect(e1)
	-- E2: Quick Effect – ataque direto + invoca Freealow
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+2)
    e2:SetCost(s.cost)
    e2:SetTarget(s.dirtg)
    e2:SetOperation(s.dirop)
    c:RegisterEffect(e2)
    -- E3: Revive with level/rank/link of the monster that destroyed it
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_BATTLE_DESTROYED)
    e3:SetCountLimit(1,id+1)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.bspop)
    c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.spcon)
    e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
--sp summoned
function s.getvalue(c)
    if c:IsType(TYPE_LINK) then return c:GetLink()
    elseif c:IsType(TYPE_XYZ) then return c:GetRank()
    else return c:GetLevel() end
end

function s.sspfilter(c,e,tp,val)
    return c:IsAttribute(ATTRIBUTE_WIND) and s.getvalue(c)>0 and s.getvalue(c)<=val
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.xyzfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_XYZ)
end

function s.ssptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local val=e:GetHandler():GetRank()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.sspfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,val)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.sspop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local val=c:GetRank()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.sspfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,val)
    local sc=g:GetFirst()
    if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Cria um efeito para resolver na End Phase
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,0))
        e1:SetCategory(CATEGORY_DESTROY)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
		e1:SetCountLimit(1,id+3)
        e1:SetRange(LOCATION_MZONE)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetCondition(function() return sc:IsOnField() end)
        e1:SetOperation(function()
            local b1=sc:IsDestructable()
            local b2=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,sc)
            if not (b1 or b2) then return end
            local opt=0
            if b1 and b2 then
                opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
            elseif b1 then opt=0 else opt=1 end
            if opt==0 then
                Duel.Destroy(sc,REASON_EFFECT)
            else
            local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,sc):GetFirst()
            if xyz then Duel.Overlay(xyz,Group.FromCards(sc)) 
                end
            end
        end)
        Duel.RegisterEffect(e1,tp)
    end
end
-- e2
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.dirfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end

function s.dirtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingTarget(s.dirfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.dirfilter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.dirop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    -- Pode atacar diretamente
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DIRECT_ATTACK)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)

    -- Trigger: se causar dano, invoca 1 Freealow
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetDescription(aux.Stringid(id,5))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+4)
    e2:SetCondition(function(_,_,_,_,_,rp) return rp~=tp end)
    e2:SetTarget(s.damsp_tg)
    e2:SetOperation(s.damsp_op)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)
end

function s.freespfilter(c,e,tp)
    return c:IsSetCard(0x759) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.damsp_tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.freespfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.damsp_op(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.freespfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
-- E3: condição – destruído por batalha ou por efeito de monstro
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsReason(REASON_DESTROY) then return false end
    if c:IsReason(REASON_EFFECT) and re and re:GetHandler():IsMonster() then
        -- armazena o destruidor no efeito usando uma flag
        e:SetLabelObject(re:GetHandler())
        return true
    end
    return false
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    local rc=e:GetLabelObject()
    if not rc or not rc:IsType(TYPE_MONSTER) then return end

    local newlv=0
    if rc:IsType(TYPE_LINK) then
        newlv=rc:GetLink()
    elseif rc:IsType(TYPE_XYZ) then
        newlv=rc:GetRank()
    else
        newlv=rc:GetLevel()
    end

    if newlv>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_RANK)
        e1:SetValue(newlv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end

function s.bspop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if c==tc then tc=Duel.GetAttackTarget() end
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    local rc=tc
    if not rc or not rc:IsType(TYPE_MONSTER) then return end

    local newlv=0
    if rc:IsType(TYPE_LINK) then
        newlv=rc:GetLink()
    elseif rc:IsType(TYPE_XYZ) then
        newlv=rc:GetRank()
    else
        newlv=rc:GetLevel()
    end

    if newlv>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_RANK)
        e1:SetValue(newlv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end