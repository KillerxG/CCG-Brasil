local s, id = GetID()

local ID_PRINCESS = 444001020
local ID_EMPRESS = 444001010

function s.initial_effect(c)
    -- Deve ser Invocada por Invocação-Especial primeiro
    c:EnableReviveLimit()
    
    -- Registro visual dos materiais
    Fusion.AddProcMix(c, true, true, ID_PRINCESS, ID_EMPRESS)
    
    -- 0. Procedimento Customizado de Invocação-Especial (Contact Fusion)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.sprcon)
    e0:SetTarget(s.sprtg)
    e0:SetOperation(s.sprop)
    c:RegisterEffect(e0)

    -- 1. Não pode ser destruído em batalha
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    
    -- 2. Sem dano de batalha
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- 3. Taunt: Oponente é obrigado a atacar esta carta
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_MUST_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    c:RegisterEffect(e3)
    local e3b=Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_FIELD)
    e3b:SetCode(EFFECT_MUST_ATTACK_MONSTER)
    e3b:SetRange(LOCATION_MZONE)
    e3b:SetTargetRange(0,LOCATION_MZONE)
    e3b:SetValue(s.atklimit)
    c:RegisterEffect(e3b)

    -- 4. Refletir o dano (Antes do cálculo)
    local e3=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetCondition(s.damcon)
    e4:SetOperation(s.damop)
    c:RegisterEffect(e4)

    -- 5. Ignition Effect (Main Phase): Banir GY -> Buscar -> Normal Summon
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, id) -- Hard Once per Turn
    e5:SetCost(s.thcost)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)

    -- 5. End Phase: Tributar ou Tomar Dano e Curar
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
    e6:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e6:SetCode(EVENT_PHASE+PHASE_END)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1, id+1)
    e6:SetCondition(s.epcon)
    e6:SetTarget(s.eptg)
    e6:SetOperation(s.epop)
    c:RegisterEffect(e6)
end

-- ==========================================
-- TAUNT (OBRIGAR ATAQUE)
-- ==========================================
function s.atklimit(e,c)
    return c==e:GetHandler()
end

-- ==========================================
-- PROCEDIMENTO DE INVOCACÃO CUSTOMIZADO
-- ==========================================
function s.matfilter(c)
    -- Checa se a carta é a Princess ou a Empress
    if not (c:IsCode(ID_PRINCESS) or c:IsCode(ID_EMPRESS)) then return false end
    -- Checa se estão no campo ou cemitério, e se podem voltar ao deck
    return (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToDeckAsCost()
end

function s.rescon(sg, e, tp, mg)
    -- Fixado: Exatamente 2 materiais
    if #sg ~= 2 then return false end
    
    -- Verifica se tem 1 Princess e 1 Empress
    local has_princess = sg:IsExists(Card.IsCode, 1, nil, ID_PRINCESS)
    local has_empress = sg:IsExists(Card.IsCode, 1, nil, ID_EMPRESS)
    
    if not (has_princess and has_empress) then return false end

    return Duel.GetLocationCountFromEx(tp, tp, sg, e:GetHandler()) > 0
end

function s.sprcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    return aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon,0)
end

function s.sprtg(e,tp,eg,ep,ev,re,r,rp,c)
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    local g=aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TODECK)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
    c:SetMaterial(g)
    g:DeleteGroup()
end

-- ==========================================
-- REFLEXÃO DE DANO E EFEITOS DE BATALHA
-- ==========================================
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    return bc and bc:GetControler()~=tp
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() then
        local dam=bc:GetAttack()
        if dam>0 then
            Duel.Damage(1-tp, dam, REASON_EFFECT)
        end
    end
end

-- ==========================================
-- IGNITION EFFECT: BANIR, BUSCAR E INVOCAR
-- ==========================================
function s.cfilter(c)
    return c:IsSetCard(0x8e) and c:IsAbleToRemoveAsCost()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.thfilter(c)
    return c:IsSetCard(0x8e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.sumfilter(c)
    return c:IsSummonable(true, nil) and (c:IsSetCard(0x8e) or (c:GetAttack()==0 and c:GetDefense()==0))
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
        local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND,0,nil)
        if #sg>0 and Duel.SelectYesNo(tp, aux.Stringid(id,3)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
            local sc=sg:Select(tp,1,1,nil):GetFirst()
            if sc then
                Duel.Summon(tp,sc,true,nil)
            end
        end
    end
end

-- ==========================================
-- END PHASE: TRIBUTAR OU TOMAR DANO/CURAR
-- ==========================================
function s.epcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==1-tp
end

function s.eptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.lvlval(c)
    return c:HasLevel() and c:GetLevel() or 1
end

function s.epop(e,tp,eg,ep,ev,re,r,rp)
    local vg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x8e),tp,LOCATION_MZONE,0,nil)
    local req_lvl=0
    for vc in aux.Next(vg) do
        req_lvl = req_lvl + s.lvlval(vc)
    end
    if req_lvl == 0 then return end
    
    local tributed_lvl = 0
    local sg = Group.CreateGroup()
    
    while tributed_lvl < req_lvl do
        local cg = Duel.GetMatchingGroup(Card.IsReleasable,1-tp,LOCATION_ONFIELD,0,sg)
        if #cg == 0 then break end
        
        Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RELEASE)
        local tc = cg:Select(1-tp, 0, 1, nil):GetFirst()
        if not tc then break end 
        
        sg:AddCard(tc)
        tributed_lvl = tributed_lvl + s.lvlval(tc)
    end
    
    if #sg > 0 then
        Duel.Release(sg, REASON_RULE)
    end
    
    if tributed_lvl < req_lvl then
        local missing = req_lvl - tributed_lvl
        local dmg = missing * 500
        -- Causa o dano e se for bem sucedido, você ganha a mesma quantia
        if Duel.Damage(1-tp, dmg, REASON_EFFECT) > 0 then
            Duel.Recover(tp, dmg, REASON_EFFECT)
        end
    end
end