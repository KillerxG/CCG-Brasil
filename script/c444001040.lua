-- The Clock Tower Guardian of Vampire Castle - Death

local s, id = GetID()

function s.initial_effect(c)
    -- Regras de Synchro
    c:EnableReviveLimit()
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99, nil, nil, function(g) return g:IsExists(Card.IsSetCard, 1, nil, 0x208e) end)

    -- 1. Efeito Armades (Sem interações até o fim do Dano)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,1)
    e1:SetValue(1)
    e1:SetCondition(s.armcon)
    c:RegisterEffect(e1)

    -- 2. Regra Illusion (Ninguém morre na batalha)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetTarget(s.indtg)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- 3. Recrutar / Contágio (Death atacando)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_CONTROL)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_DAMAGE_STEP_END)
    e4:SetCondition(s.ctcon_death)
    e4:SetTarget(s.cttg)
    e4:SetOperation(s.ctop)
    c:RegisterEffect(e4)
end

function s.armcon(e)
    local c=e:GetHandler()
    return Duel.GetAttacker()==c or Duel.GetAttackTarget()==c
end
function s.indtg(e,c)
    local tc=e:GetHandler():GetBattleTarget()
    return tc and c==tc
end
function s.ctcon_death(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():GetBattleTarget()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    local bc=e:GetHandler():GetBattleTarget()
    if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsControler(1-tp) and bc:IsControlerCanBeChanged() end
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,bc,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() and not bc:IsControler(tp) then
        if Duel.GetControl(bc,tp) then
            s.apply_infection(bc, tp, e:GetHandler())
        end
    end
end

-- ==================================
-- A Função de Infecção (Aplicada aos recrutados)
-- ==================================
function s.apply_infection(bc, tp, source_card)
    -- ID da carta escondida no CDB que contém os efeitos do vírus
    local VIRUS_ID = 444001999 
    
    -- O EDOPro vai automaticamente desligar os efeitos originais 
    -- e injetar tudo o que estiver no script c444001999.lua!
    bc:ReplaceEffect(VIRUS_ID, RESET_EVENT+RESETS_STANDARD)
end