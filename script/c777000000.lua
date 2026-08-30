-- Idrakian Force
-- Scripted by Gemini
Duel.EnableUnofficialProc(PROC_EVENT_LP0)
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
    -- [ESCUDO ABSOLUTO: INAFETADA POR TUDO]
    if not s.global_check then
        s.global_check = true
        local ge1 = Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD)
        ge1:SetCode(EFFECT_IMMUNE_EFFECT)
        ge1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        ge1:SetTargetRange(LOCATION_ONFIELD, LOCATION_ONFIELD)
        ge1:SetTarget(function(e,tc) return tc:GetOriginalCode()==id end)
        ge1:SetValue(function(e,te) return te:GetOwner():GetOriginalCode()~=id end)
        Duel.RegisterEffect(ge1, 0)
    end
	--Divine Hierarchy Rank 2
	DivineHierarchyMod.Register(c,2)
    -- [ATIVAÇÃO RÁPIDA] Pode ser ativada no mesmo turno em que foi Baixada (Set)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    c:RegisterEffect(e0)

    -- Survive
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_LP0)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    aux.LP0ActivationValidity(e1)
	--Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
end

function s.filter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_CHAIN)
    e1:SetCode(EFFECT_CANNOT_LOSE_LP)
    Duel.RegisterEffect(e1,tp)
    
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
    
    -- [INRESPONDÍVEL] Restrição: Nenhum jogador pode responder à ativação desta carta!
    Duel.SetChainLimit(aux.FALSE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tp=e:GetHandlerPlayer()
    
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    
    -- Monta o Menu de Opções de texto (Puxa as descrições/strings de 1 a 12 cadastradas na carta)
    local ops = {}
    for i = 1, 12 do
        table.insert(ops, aux.Stringid(id, i))
    end
    
    -- Abre a janela de SelectOption
    local sel = Duel.SelectOption(tp, table.unpack(ops))
    
    -- 'sel' retorna o índice escolhido (começando do 0 até 11)
    -- Calculamos o ID correspondente à escolha
    local t_id = 776999880 + (sel * 10)
    local tc = Duel.CreateToken(tp, t_id)
    
    if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
        
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_LOSE_DECK)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetLabel(1)
        e1:SetLabelObject(tc)
        e1:SetCondition(s.con)
        Duel.RegisterEffect(e1,tp)
        
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CANNOT_LOSE_LP)
        Duel.RegisterEffect(e2,tp)
        
        local e3=e1:Clone()
        e3:SetCode(EFFECT_CANNOT_LOSE_EFFECT)
        tc:RegisterEffect(e3)
        Duel.RegisterEffect(e3,tp)
        
        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e4:SetCode(EVENT_LEAVE_FIELD)
        e4:SetLabel(1-tp)
        e4:SetCondition(s.losecon)
        e4:SetOperation(s.loseop)
        e4:SetReset(RESET_EVENT|RESET_TURN_SET|RESET_OVERLAY|RESET_MSCHANGE)
        tc:RegisterEffect(e4,true)
        
        Duel.SpecialSummonComplete()
    end
end

function s.losecon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_DESTROY)
end

function s.loseop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Win(e:GetLabel(),WIN_REASON_RELAY_SOUL)
end

function s.con(e)
    if e:GetLabelObject() and not e:GetLabelObject():IsReason(REASON_DESTROY) then
        return true
    end
    if e:GetLabel()==0 then
        e:SetLabelObject(nil)
        return false
    else
        e:SetLabel(0)
    end
    return false
end