--Necromorph Swarmer
local s,id=GetID()
function s.initial_effect(c)
	--c:SetUniqueOnField(1,0,id)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
  e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

function s.eqcon(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
--draw cards
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
--equip to enemy monster
function s.eqlimit(e,c)
	return e:GetOwner()==c
end

function s.filter(c)
	return c:IsFaceup()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
  --Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
  if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
  local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsMonster() and tc:IsControler(1-tp) then
		Duel.Equip(tp,c,tc,true)
		--Add Equip limit
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		c:RegisterEffect(e1)
    --atk
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_ATTACK)
		e2:SetValue(0)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
    --def
    local e3=e2:Clone()
		e3:SetCode(EFFECT_SET_DEFENSE)
		c:RegisterEffect(e3)
	end
end