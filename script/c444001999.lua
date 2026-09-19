local s, id = GetID()
-- ATENÇÃO: Este é o script do monstro escondido (c444001999) 
-- usado exclusivamente para repassar os efeitos da Morte aos recrutados.

function s.initial_effect(c)
    -- Transforma em DARK
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e1:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e1)
    
    -- Transforma em Illusion
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_RACE)
    e2:SetValue(RACE_ILLUSION)
    c:RegisterEffect(e2)
    
    -- Também é tratado como Zombie (Soma as Raças)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_ADD_RACE)
    e3:SetValue(RACE_ZOMBIE)
    c:RegisterEffect(e3)

    -- Regra Illusion (Ele não morre em batalha)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    
    -- Regra Illusion (O inimigo que ele bater também não morre)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e5:SetTarget(function(e,tc) return tc==e:GetHandler():GetBattleTarget() end)
    e5:SetValue(1)
    c:RegisterEffect(e5)

    -- Rastreador Invisível de Dano (Verifica se este monstro causou dano)
    local e_dam=Effect.CreateEffect(c)
    e_dam:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e_dam:SetCode(EVENT_BATTLE_DAMAGE)
    e_dam:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        if ep~=tp then
            e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
        end
    end)
    c:RegisterEffect(e_dam)

    -- Espalhar o contágio (Recrutar a próxima vítima)
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,1)) -- "Recrutar monstro infectado"
    e8:SetCategory(CATEGORY_CONTROL)
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e8:SetCode(EVENT_DAMAGE_STEP_END)
    e8:SetCondition(s.infcon)
    e8:SetTarget(s.cttg)
    e8:SetOperation(s.ctop) 
    c:RegisterEffect(e8)

    -- A SENTENÇA DE MORTE (Destrói na End Phase e ganha 500 LP)
    local edes=Effect.CreateEffect(c)
    edes:SetDescription(aux.Stringid(id,2)) -- "Destruir esta carta e ganhar 500 LP"
    edes:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
    edes:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    edes:SetCode(EVENT_PHASE+PHASE_END)
    edes:SetRange(LOCATION_MZONE)
    edes:SetCountLimit(1)
    edes:SetTarget(s.destg)
    edes:SetOperation(s.desop)
    c:RegisterEffect(edes)
end

-- ==================================
-- Funções do Vírus
-- ==================================
function s.infcon(e,tp,eg,ep,ev,re,r,rp)
    -- Ativa apenas se causou dano (marcado pela flag) e batalhou um monstro
    return e:GetHandler():GetFlagEffect(id)>0 and e:GetHandler():GetBattleTarget()
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
            -- O novo monstro também sofre o ReplaceEffect chamando este MESMO arquivo!
            bc:ReplaceEffect(id, RESET_EVENT+RESETS_STANDARD)
        end
    end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Usa GetHandlerPlayer para curar quem está controlando o monstro no momento em que ele explode
    local p = e:GetHandlerPlayer() 
    if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
        Duel.Recover(p,500,REASON_EFFECT)
    end
end