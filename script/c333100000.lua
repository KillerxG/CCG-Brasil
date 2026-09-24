-- Operator of Warforged - Festos
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- You can only Special Summon this card once per turn
    c:SetSPSummonOnce(id)
    
    -- Cannot be Normal Summoned/Set
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.FALSE)
    c:RegisterEffect(e1)
    
    -- Special Summon from hand
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(s.spcon)
    c:RegisterEffect(e2)
    
    -- Trigger: Special Summon Normal FIRE Machines and Search Equip
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    
    -- Gemini monsters become Effect monsters
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_GEMINI_STATUS)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.geminitg)
    c:RegisterEffect(e4)
    
    -- "Warforged" Immune to non-targeting activated effects
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_IMMUNE_EFFECT)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetTarget(s.imtg)
    e5:SetValue(s.imval)
    c:RegisterEffect(e5)
    
    -- Quick Effect: Equip
    local e6=Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_EQUIP)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_MZONE)
    e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e6:SetCountLimit(1)
    e6:SetTarget(s.eqtg)
    e6:SetOperation(s.eqop)
    c:RegisterEffect(e6)
end

-- Arquétipo Set Code (Substitua 0xfff pelo Set Code real do seu arquétipo)
local SETCODE_WARFORGED = 0x311

-- Funções para o Efeito de Invocação da Mão (e2)
function s.spfilter(c)
    return c:IsSetCard(SETCODE_WARFORGED) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetClassCount(Card.GetCode)>=3
end

-- Funções para o Trigger (e3)
function s.tgfilter(c,e,tp)
    return c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Restrição de Extra Deck
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    
    -- Seleciona os monstros para invocar
    local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
    if #tg==0 then return end
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
    
    -- Calcula o máximo possível de invocações
    local count=math.min(#tg,ft)
    if count<=0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    -- Força a seleção exata do limite máximo ("as many as possible")
    local sg=tg:Select(tp,count,count,nil)
    local sp_ct=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    
    -- Lógica para adicionar Equip Spells à mão
    if sp_ct>0 then
        local thg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
        if #thg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local search_sg=thg:Select(tp,1,sp_ct,nil)
            if #search_sg>0 then
                Duel.SendtoHand(search_sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,search_sg)
            end
        end
    end
end
function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
end

-- Função que aplica o Status Gemini (e4)
function s.geminitg(e,c)
    return c:IsType(TYPE_GEMINI)
end

-- Funções de Imunidade (e5)
function s.imtg(e,c)
    return c:IsSetCard(SETCODE_WARFORGED)
end
function s.imval(e,te,c)
    if te:GetOwnerPlayer()==e:GetHandlerPlayer() or not te:IsActivated() then return false end
    if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    return not (g and g:IsContains(c))
end

-- Funções do Quick Effect: Equip (e6)
function s.eqtgfilter(c)
    return c:IsFaceup() and c:IsSetCard(SETCODE_WARFORGED)
end
function s.eqfilter(c,tc,tp)
    return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqtgfilter(chkc) end
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    local eq_ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,TYPE_EQUIP)
    local max_targets=math.min(ft,eq_ct)
    
    if chk==0 then return max_targets>0
        and Duel.IsExistingTarget(s.eqtgfilter,tp,LOCATION_MZONE,0,1,nil) end
        
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.eqtgfilter,tp,LOCATION_MZONE,0,1,max_targets,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,#g,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    if #tg==0 then return end
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if ft<=0 then return end
    for tc in aux.Next(tg) do
        if ft>0 then
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
            -- Verifica no filtro se a magia selecionada pode ser equipada naquele monstro específico
            local eqg=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tc,tp)
            local eq=eqg:GetFirst()
            if eq then
                Duel.Equip(tp,eq,tc)
                ft=ft-1
            end
        end
    end
end