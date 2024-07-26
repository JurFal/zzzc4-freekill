local extension = Package("zzzc4")
--[[local zzzc4_pao = require "packages/zzzc4/zzzc4_pao"
local zzzc4_xue = require "packages/zzzc4/zzzc4_xue"]]
local U = require "packages/utility/utility"


Fk:loadTranslationTable{
    ["zzzc4"] = "班杀",
    ["zzz"] = "紫",
  }



local zzz_youya = General(extension, "zzz_youya", "zzz", 3, 3, General.Female)
local zzz_yyouya = fk.CreateTriggerSkill{
    name = "zzz_yyouya",
    anim_type = "drawcard",
    events = {fk.TurnEnd},
    can_trigger = function(self, event, target, player, data)
      return player:hasSkill(self) and player:getHandcardNum() ~= player.hp
    end,
    on_use = function(self, event, target, player, data)
      local room = player.room
      if not player:hasSkill(self) then return end
      if player:getHandcardNum() < player.hp then
        player:drawCards(1, self.name)
      elseif player:getHandcardNum() > player.hp and player:isWounded() then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name
        }
      end
    end
}
zzz_youya:addSkill(zzz_yyouya)
zzz_youya:addSkill("songci")
Fk:loadTranslationTable{
  ["zzz_youya"] = "尤雅",
  ["#zzz_youya"] = "诗画怡红",
  ["designer:zzz_youya"] = "zlc",
	["illustrator:zzz_youya"] = "msh",
	["zzz_yyouya"] = "优雅",
	[":zzz_yyouya"] = "一名角色的回合结束时，若你的手牌数小于体力值，你可以摸一张牌；若你的手牌数大于体力值，你可以回复1点体力。",
}


--[[zzz_tangyiming = General(extension, "zzz_tangyiming", "zzz", 4, 4, General.Male)


zzz_huawen = sgs.CreateTriggerSkill{
	name = "zzz_huawen",
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, target, player, data)
    if player:getPhase() ~= sgs.Player_Start and (player:getPhase() ~= sgs.Player_Finish or player:getMark("zzzPaikao_end") == 0) then return false end
	end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local x = 0
    local all = table.filter(U.getUniversalCards(room, "t"), function(id)
      local trick = Fk:getCardById(id)
      return not trick.multiple_targets and trick.skill:getMinTargetNum() > 0
    end)
    for i = 1, 3 do
      local names = table.filter(all, function (id)
        local card = Fk:cloneCard(Fk:getCardById(id).name)
        card.skillName = self.name
        return player:canUseTo(card, to, {bypass_distances = true})
      end)
      if #names == 0 then break end
      local _, dat = room:askForUseActiveSkill(player, "ty__juanxia_active", "#ty__juanxia-invoke::" .. to.id..":"..i, true,
      {ty__juanxia_names = names, ty__juanxia_target = to.id})
      if not dat then break end
      table.removeOne(all, dat.cards[1])
      local card = Fk:cloneCard(Fk:getCardById(dat.cards[1]).name)
      x = x + 1
      card.skillName = self.name
      local tos = dat.targets
      if #tos == 0 then table.insert(tos, to.id) end
      room:useCard{
        from = player.id,
        tos = table.map(dat.targets, function(id) return {id} end),
        card = card,
      }
      if player.dead or to.dead then return end
    end
    if x == 0 then return end
    room:setPlayerMark(to, "@ty__juanxia", x)
    room:setPlayerMark(to, "ty__juanxia_src", player.id)
  end,
}

zzz_woxin = sgs.CreateTriggerSkill{
	name = "zzz_woxin",
	frequency = Skill.Wake,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data, room)
		if player:getMark(self:objectName()) > 0 then return false end
		room:setPlayerMark(player, self:objectName(), 1)
		room:changeMaxHpForAwakenSkill(player, -1)
		room:addPlayerMark(player, "zzzPaikao_start")
		if player:getMark("zzzPaikao_end") > 0 then 
			room:changeTranslation(player, "zzz_huawen", sgs.Sanguosha:translate("zzz_huawen_complete"))
		else
			room:changeTranslation(player, "zzz_huawen", sgs.Sanguosha:translate("zzz_huawen_start"))
		end
	end
}

zzz_changdan = fk.CreateTriggerSkill{
	name = "zzz_changdan",
	frequency = Skill.Wake,
	events = {sgs.HpRecover},
	on_trigger = function(self, event, player, data, room)
		if player:getMark(self:objectName()) > 0 then return false end
		room:setPlayerMark(player, self:objectName(), 1)
		room:changeMaxHpForAwakenSkill(player, -1)
		room:addPlayerMark(player, "zzzPaikao_end")
		if player:getMark("zzzPaikao_start") > 0 then 
			room:changeTranslation(player, "zzz_huawen", sgs.Sanguosha:translate("zzz_huawen_complete"))
		else
			room:changeTranslation(player, "zzz_huawen", sgs.Sanguosha:translate("zzz_huawen_end"))
		end
	end
}

zzz_tangyiming:addSkill(zzz_huawen)
zzz_tangyiming:addSkill(zzz_woxin)
zzz_tangyiming:addSkill(zzz_changdan)
]]





zzz_zhengyuxiang = General(extension, "zzz_zhengyuxiang", "zzz", 4, 4, General.Male)
zzz_daimeng = fk.CreateTriggerSkill{
	name = "zzz_daimeng",
	frequency = Skill.Compulsory,
	events = {fk.CardUsing},
	can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function(e)
        local use = e.data[1]
        return use.from == player.id
      end, Player.HistoryPhase)
      return (#events == 2 and events[2].data[1] == data) or (#events == 1 and events[1].data[1] == data)
    end
  end,
	on_use = function(self, event, player, data, room)
		if player:hasSkill(self) then
      local mark = player:getMark("@zzz_daimeng-turn")
      if mark == 0 then
        player:addMark("@zzz_daimeng-turn", 1)
				player:drawCards(2, self.name)
			else
        player:addMark("@zzz_daimeng-turn", 1)
				player.room:askForDiscard(player, 3, 3, true, self.name, false)
			end
		end
		return false
	end
}
zzz_qiangzhuang = fk.CreateTriggerSkill{
	name = "zzz_qiangzhuang",
  anim_type = "offensive",
	events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local types = {}
      local room = player.room
      for _, move in ipairs(data) do
        if move.moveReason == fk.ReasonDiscard and move.from and move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            table.insertIfNeed(types, Fk:getCardById(info.cardId).type)
          end
        end
      end
      if #types == 3 then
        return true
      end
    end
  end,
	on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room:askForChoosePlayers(player, table.map(room:getAlivePlayers(), Util.IdMapper),
      1, 1, "#zzz_qiangzhuang-choose", self.name, true)
    if #targets > 0 then
      room:sortPlayersByAction(targets)
      self.cost_data = targets
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, pid in ipairs(self.cost_data) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = self.name,
        }
      end
    end
	end,
}
zzz_zhengyuxiang:addSkill(zzz_daimeng)
zzz_zhengyuxiang:addSkill(zzz_qiangzhuang)
Fk:loadTranslationTable{
  ["zzz_zhengyuxiang"] = "郑宇翔",
  ["#zzz_zhengyuxiang"] = "菜的一匹",
  ["designer:zzz_zhengyuxiang"] = "yzy",
	["zzz_daimeng"] = "呆萌",
	[":zzz_daimeng"] = "锁定技，你于一名角色的回合内使用第一张牌时摸两张牌，使用本回合内第二张牌时弃置三张牌。",
  ["zzz_qiangzhuang"] = "强壮",
	[":zzz_qiangzhuang"] = "你因弃置失去牌时，若其中包含所有类别的牌，你可以对一名角色造成1点伤害。",
  ["#zzz_qiangzhuang-choose"] = "强壮：请对一名角色造成1点伤害",
}

zzz_tengdanliang = General(extension, "zzz_tengdanliang", "zzz", 3, 3, General.Male)
zzz_guaicai = fk.CreateTriggerSkill{
	name = "zzz_guaicai",
	events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local ids = {}
      local room = player.room
      for _, move in ipairs(data) do
        if (move.moveReason == fk.ReasonUse or move.moveReason == fk.ReasonResonpse or
        move.moveReason == fk.ReasonDiscard)
        and move.from and move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids > 0 then
        local max_num = 0
        for _, id in ipairs(ids) do
          max_num = math.max(Fk:getCardById(id).number, max_num)
        end
        for _, id in ipairs(player:getCardIds(Player.Hand)) do
          if Fk:getCardById(id).number > max_num then return false end
        end
        self.cost_data = max_num
        if max_num == 13 then self.cost_data = "K" end
        if max_num == 12 then self.cost_data = "Q" end
        if max_num == 11 then self.cost_data = "J" end
        if max_num == 1 then self.cost_data = "A" end
        return true
      end
    end
  end,
	on_use = function(self, event, target, player, data)
    local maxhp = player.maxHp
		local room = player.room
    local cards = room:getNCards(maxhp)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
      skillName = self.name,
      proposer = player.id
    })
    local get = {}
    for _, id in ipairs(cards) do
      table.insert(get, id)
    end
    get = room:askForArrangeCards(player, self.name, cards, "#zzz_guaicai-choose", false, 0, {maxhp, maxhp}, {0, 0}, ".|"..self.cost_data.."~K", nil, nil)[2]
    if #get > 0 then
      room:obtainCard(player, get, true, fk.ReasonPrey)
    end
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonJustMove, self.name)
    end
    return true
	end
}
zzz_tengdanliang:addSkill(zzz_guaicai)
Fk:loadTranslationTable{
  ["zzz_tengdanliang"] = "滕丹亮",
  ["#zzz_tengdanliang"] = "陈祺珅是呆子",
  ["designer:zzz_tengdanliang"] = "zlc",
	["zzz_guaicai"] = "怪才",
	[":zzz_guaicai"] = "当你因使用、打出或弃置而失去手牌中点数最大的牌时，你可以展示牌堆顶X张牌（X为你的体力上限）并获得其中任意张点数不小于此牌的牌，将其余的牌置入弃牌堆。",
  ["#zzz_guaicai-choose"] = "怪才：选择其中任意张点数不小于此牌的牌获得",
}


return {
    extension,
    --[[zzzc4_pao,
    zzzc4_xue,]]
}

--[[
local biyue = fk.CreateTriggerSkill{
  name = "biyue",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
      and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
local bingzheng = fk.CreateTriggerSkill{
  name = "bingzheng",
  anim_type = "control",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
      not table.every(player.room:getAlivePlayers(), function(p) return p:getHandcardNum() == p.hp end)
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(table.filter(player.room:getAlivePlayers(), function(p)
      return p:getHandcardNum() ~= p.hp end), Util.IdMapper), 1, 1, "#bingzheng-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local choices = {"bingzheng_draw"}
    if not to:isKongcheng() then
      table.insert(choices, 1, "bingzheng_discard")
    end
    local choice = room:askForChoice(player, choices, self.name, "#bingzheng-choice::"..to.id)
    if choice == "bingzheng_draw" then
      to:drawCards(1, self.name)
    else
      room:askForDiscard(to, 1, 1, false, self.name, false)
    end
    if #to.player_cards[Player.Hand] == to.hp then
      player:drawCards(1, self.name)
      if to ~= player then
        local card = room:askForCard(player, 1, 1, true, self.name, true, ".", "#bingzheng-card::"..to.id)
        if #card > 0 then
          room:obtainCard(to, card[1], false, fk.ReasonGive)
        end
      end
    end
  end,
}
local ty__langmie = fk.CreateTriggerSkill{
  name = "ty__langmie",
  mute = true,
  events = {fk.EventPhaseEnd, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player then
      if event == fk.EventPhaseEnd and target.phase == Player.Play then
        local count = {0, 0, 0}
        player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
          local use = e.data[1]
          if use.from == target.id then
            if use.card.type == Card.TypeBasic then
              count[1] = count[1] + 1
            elseif use.card.type == Card.TypeTrick then
              count[2] = count[2] + 1
            elseif use.card.type == Card.TypeEquip then
              count[3] = count[3] + 1
            end
          end
        end, Player.HistoryPhase)
        return table.find(count, function(i) return i > 1 end)
      elseif event == fk.EventPhaseStart and target.phase == Player.Finish and not player:isNude() then
        local n = 0
        player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 999, function(e)
          local damage = e.data[5]
          if damage and target == damage.from then
            n = n + damage.damage
          end
        end, Player.HistoryTurn)
        return n > 1
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.EventPhaseEnd then
      return player.room:askForSkillInvoke(player, self.name, nil, "#ty__langmie-draw")
    elseif event == fk.EventPhaseStart then
      local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#ty__langmie-damage::"..target.id, true)
      if #card > 0 then
        self.cost_data = card
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.EventPhaseEnd then
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:drawCards(1, self.name)
    elseif event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, "offensive")
      room:doIndicate(player.id, {target.id})
      room:throwCard(self.cost_data, self.name, player, player)
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
local fenyin = fk.CreateTriggerSkill{
  name = "fenyin",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase < Player.NotActive and self.can_fenyin
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,

  refresh_events = {fk.CardUsing, fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    if event == fk.EventPhaseStart then
      return player.phase == Player.NotActive
    else
      return player.phase < Player.NotActive -- FIXME: this is a bug of FK 0.0.2!!
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      room:setPlayerMark(player, self.name, 0)
      room:setPlayerMark(player, "@" .. self.name, 0)
    else
      self.can_fenyin = data.card.color ~= player:getMark(self.name) and player:getMark(self.name) ~= 0
      room:setPlayerMark(player, self.name, data.card.color)
      room:setPlayerMark(player, "@" .. self.name, data.card:getColorString())
    end
  end,
}
local shijian = fk.CreateTriggerSkill{
  name = "shijian",
  anim_type = "support",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if target ~= player and player:hasSkill(self) and target.phase == Player.Play and not player:isNude() and not target:hasSkill("yuxu",true) then
      local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function(e)
        local use = e.data[1]
        return use.from == target.id
      end, Player.HistoryPhase)
      return #events == 2 and events[2].data[1] == data
    end
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#shijian-invoke::"..target.id, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    room:handleAddLoseSkills(target, "yuxu")
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
      room:handleAddLoseSkills(target, "-yuxu")
    end)
  end,
}
local liuzan = General(extension, "ty__liuzan", "wu", 4)
local ty__fenyin = fk.CreateTriggerSkill{
  name = "ty__fenyin",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase ~= Player.NotActive then
      local mark = U.getMark(player, "@fenyin_suits-turn")
      if #mark > 3 then return false end
      local suits = {}
      local suit = ""
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            suit = Fk:getCardById(info.cardId):getSuitString(true)
            if suit ~= "log_nosuit" and not table.contains(mark, suit) then
              table.insertIfNeed(suits, suit)
            end
          end
        end
      end
      if #suits > 0 then
        self.cost_data = suits
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local mark = U.getMark(player, "@fenyin_suits-turn")
    table.insertTable(mark, self.cost_data)
    player.room:setPlayerMark(player, "@fenyin_suits-turn", mark)
    player:drawCards(#self.cost_data, self.name)
  end,
}
local liji = fk.CreateActiveSkill{
  name = "liji",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    local mark = U.getMark(player, "@liji-turn")
    return #mark > 0 and mark[1] > 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local mark = U.getMark(player, "@liji-turn")
    mark[1] = mark[1] - 1
    room:setPlayerMark(player, "@liji-turn", mark)
    room:throwCard(effect.cards, self.name, player, player)
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
  end,
}

local liji_record = fk.CreateTriggerSkill{
  name = "#liji_record",

  refresh_events = {fk.TurnStart, fk.EventPhaseStart, fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if event == fk.TurnStart then
      return player == target
    else
      return player.room.current == player and not player.dead and #U.getMark(player, "@liji-turn") == 5
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.TurnStart then
      if player:hasSkill(self, true) then
        player.room:setPlayerMark(player, "@liji-turn", {0, "-", 0, "/", #player.room.alive_players < 5 and 4 or 8})
      end
    elseif event == fk.EventPhaseStart then
      local mark = U.getMark(player, "@liji-turn")
      mark[1] = player:getMark("liji_times-turn")
      player.room:setPlayerMark(player, "@liji-turn", mark)
    else
      local mark = U.getMark(player, "@liji-turn")
      local x = mark[3]
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          x = x + #move.moveInfo
        end
      end
      mark[1] = mark[1] + x // mark[5]
      player.room:addPlayerMark(player, "liji_times-turn", x // mark[5])
      mark[3] = x % mark[5]
      player.room:setPlayerMark(player, "@liji-turn", mark)
    end
  end,
local pingkou = fk.CreateTriggerSkill{
  name = "pingkou",
  mute = true,
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and type(player.skipped_phases) == "table"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    for _, phase in ipairs({Player.Start, Player.Judge, Player.Draw, Player.Play, Player.Discard, Player.Finish}) do
      if player.skipped_phases[phase] then
        n = n + 1
      end
    end
    local targets = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper),
      1, n, "#pingkou-choose:::"..n, self.name, true)
    if #targets > 0 then
      room:sortPlayersByAction(targets)
      self.cost_data = targets
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, pid in ipairs(self.cost_data) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
local luoying = fk.CreateTriggerSkill{
  name = "luoying",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local ids = {}
      local room = player.room
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.moveReason == fk.ReasonDiscard and move.from and move.from ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              Fk:getCardById(info.cardId).suit == Card.Club and
              room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          elseif move.moveReason == fk.ReasonJudge then
            local judge_event = room.logic:getCurrentEvent():findParent(GameEvent.Judge)
            if judge_event and judge_event.data[1].who ~= player then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.Processing and Fk:getCardById(info.cardId).suit == Card.Club and
                room:getCardArea(info.cardId) == Card.DiscardPile then
                  table.insertIfNeed(ids, info.cardId)
                end
              end
            end
          end
        end
      end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids > 0 then
        self.cost_data = ids
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = table.simpleClone(self.cost_data)
    if #ids > 1 then
      local cards, _ = U.askforChooseCardsAndChoice(player, ids, {"OK"}, self.name,
      "#luoying-choose", {"get_all"}, 1, #ids)
      if #cards > 0 then
        ids = cards
      end
    end
    room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonPrey, self.name)
  end,
}
local yangyi = General(extension, "ty__yangyi", "shu", 3)
local ty__juanxia_active = fk.CreateActiveSkill{
  name = "ty__juanxia_active",
  expand_pile = function(self)
    return self.ty__juanxia_names or {}
  end,
  card_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(self.ty__juanxia_names or {}, to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected_cards == 0 then return false end
    local to = self.ty__juanxia_target
    if #selected == 0 then
      return to_select == to
    elseif #selected == 1 then
      local card = Fk:cloneCard(Fk:getCardById(selected_cards[1]).name)
      card.skillName = "ty__juanxia"
      if card.skill:getMinTargetNum() == 2 and selected[1] == to then
        return card.skill:targetFilter(to_select, selected, {}, card)
      end
    end
  end,
  feasible = function(self, selected, selected_cards)
    if #selected_cards == 0 then return false end
    local to_use = Fk:cloneCard(Fk:getCardById(selected_cards[1]).name)
    to_use.skillName = "ty__juanxia"
    local selected_copy = table.simpleClone(selected)
    if #selected_copy == 0 then
      table.insert(selected_copy, self.ty__juanxia_target)
    end
    return to_use.skill:feasible(selected_copy, {}, Self, to_use)
  end,
}
local ty__juanxia = fk.CreateTriggerSkill{
  name = "ty__juanxia",
  anim_type = "offensive",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1, "#ty__juanxia-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = tos[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local x = 0
    local all = table.filter(U.getUniversalCards(room, "t"), function(id)
      local trick = Fk:getCardById(id)
      return not trick.multiple_targets and trick.skill:getMinTargetNum() > 0
    end)
    for i = 1, 3 do
      local names = table.filter(all, function (id)
        local card = Fk:cloneCard(Fk:getCardById(id).name)
        card.skillName = self.name
        return player:canUseTo(card, to, {bypass_distances = true})
      end)
      if #names == 0 then break end
      local _, dat = room:askForUseActiveSkill(player, "ty__juanxia_active", "#ty__juanxia-invoke::" .. to.id..":"..i, true,
      {ty__juanxia_names = names, ty__juanxia_target = to.id})
      if not dat then break end
      table.removeOne(all, dat.cards[1])
      local card = Fk:cloneCard(Fk:getCardById(dat.cards[1]).name)
      x = x + 1
      card.skillName = self.name
      local tos = dat.targets
      if #tos == 0 then table.insert(tos, to.id) end
      room:useCard{
        from = player.id,
        tos = table.map(dat.targets, function(id) return {id} end),
        card = card,
      }
      if player.dead or to.dead then return end
    end
    if x == 0 then return end
    room:setPlayerMark(to, "@ty__juanxia", x)
    room:setPlayerMark(to, "ty__juanxia_src", player.id)
  end,

  refresh_events = {fk.AfterTurnEnd},
  can_refresh = function(self, event, target, player, data)
    return player == target and (player:getMark("@ty__juanxia") > 0 or player:getMark("ty__juanxia_src") > 0)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@ty__juanxia", 0)
    room:setPlayerMark(player, "ty__juanxia_src", 0)
  end,
}
local ty__juanxia_delay = fk.CreateTriggerSkill{
  name = "#ty__juanxia_delay",
  events = {fk.TurnEnd},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and not target.dead and target:getMark("@ty__juanxia") > 0 and
    target:getMark("ty__juanxia_src") == player.id
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = target:getMark("@ty__juanxia")
    for i = 1, n, 1 do
      local slash = Fk:cloneCard("slash")
      slash.skillName = "ty__juanxia"
      if U.canUseCardTo(room, target, player, slash, false, false) and
      room:askForSkillInvoke(target, self.name, nil, "#ty__juanxia-slash:"..player.id.."::"..n..":"..i) then
        room:useCard{
          from = target.id,
          tos = {{player.id}},
          card = slash,
          extraUse = true,
        }
      else
        break
      end
      if player.dead or target.dead then break end
    end
  end
}
local guohuanghou = General(extension, "guohuanghou", "wei", 3, 3, General.Female)
local jiaozhaoSkills = {"jiaozhao", "jiaozhaoEx1", "jiaozhaoEx2"}
local jiaozhao = fk.CreateActiveSkill{
  name = "jiaozhao",
  anim_type = "special",
  card_num = 1,
  target_num = 1,
  prompt = "#jiaozhao",
  can_use = function(self, player)
    return not player:isKongcheng() and
      table.every(jiaozhaoSkills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 then
      local n = 999
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= Self and Self:distanceTo(p) < n then
          n = Self:distanceTo(p)
        end
      end
      return Self:distanceTo(Fk:currentRoom():getPlayerById(to_select)) == n
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:showCards(effect.cards)
    if player.dead then return end
    local c = Fk:getCardById(effect.cards[1])
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic and not card.is_derived then
        table.insertIfNeed(names, card.name)
      end
    end
    local choice = room:askForChoice(target, names, self.name, "#jiaozhao-choice:"..player.id.."::"..c:toLogString())
    room:doBroadcastNotify("ShowToast", Fk:translate("jiaozhao_choice")..Fk:translate(choice))
    if room:getCardOwner(c) == player and room:getCardArea(c) == Card.PlayerHand then
      room:setCardMark(c, "jiaozhao-inhand", choice)
      room:setCardMark(c, "@jiaozhao-inhand", Fk:translate(choice))
      room:handleAddLoseSkills(player, "-jiaozhao|jiaozhaoVS", nil, false, true)
    end
  end,
}
local jiaozhaoVS = fk.CreateViewAsSkill{
  name = "jiaozhaoVS",
  pattern = ".",
  mute = true,
  prompt = "#jiaozhaoVS",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select):getMark("jiaozhao-inhand") ~= 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(Fk:getCardById(cards[1]):getMark("jiaozhao-inhand"))
    card.skillName = "jiaozhao"
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    player:broadcastSkillInvoke("jiaozhao")
    room:notifySkillInvoked(player, "jiaozhao", "special")
    room:handleAddLoseSkills(player, jiaozhaoSkills[player:getMark("jiaozhao_status")].."|-jiaozhaoVS", nil, false, true)
  end,
  enabled_at_play = function(self, player)
    return table.find(player:getCardIds("h"), function(id) return Fk:getCardById(id):getMark("jiaozhao-inhand") ~= 0 end)
  end,
  enabled_at_response = function(self, player, response)
    return not response and player.phase ~= Player.NotActive and
      table.find(player:getCardIds("h"), function(id) return Fk:getCardById(id):getMark("jiaozhao-inhand") ~= 0 end)
  end,
}
local jiaozhao_prohibit = fk.CreateProhibitSkill{
  name = "#jiaozhao_prohibit",
  is_prohibited = function(self, from, to, card)
    return card and from == to and table.contains(card.skillNames, "jiaozhao")
  end,
}
local jiaozhao_change = fk.CreateTriggerSkill{
  name = "#jiaozhao_change",

  refresh_events = {fk.GameStart, fk.EventAcquireSkill, fk.TurnStart, fk.TurnEnd},
  can_refresh = function(self, event, target, player, data)
    if event == fk.GameStart then
      return player:hasSkill("jiaozhao")
    elseif target == player then
      if event == fk.EventAcquireSkill then
        return data.name == "jiaozhao"
      elseif event == fk.TurnStart or event == fk.TurnEnd then
        return player:hasSkill("jiaozhaoVS", true)
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      room:setPlayerMark(player, "jiaozhao_status", 1)
    else
      if player:getMark("jiaozhao_status") == 0 then
        room:setPlayerMark(player, "jiaozhao_status", 1)
      end
      if event == fk.TurnStart or event == fk.TurnEnd then
        for _, id in ipairs(player:getCardIds("h")) do
          room:setCardMark(Fk:getCardById(id), "jiaozhao-inhand", 0)
          room:setCardMark(Fk:getCardById(id), "@jiaozhao-inhand", 0)
        end
      end
      room:handleAddLoseSkills(player, jiaozhaoSkills[player:getMark("jiaozhao_status")].."|-jiaozhaoVS", nil, false, true)
    end
  end,
}
local jiaozhaoEx1 = fk.CreateActiveSkill{
  name = "jiaozhaoEx1",
  mute = true,
  card_num = 1,
  target_num = 1,
  prompt = "#jiaozhaoEx1",
  can_use = function(self, player)
    return not player:isKongcheng() and
      table.every(jiaozhaoSkills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 then
      local n = 999
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= Self and Self:distanceTo(p) < n then
          n = Self:distanceTo(p)
        end
      end
      return Self:distanceTo(Fk:currentRoom():getPlayerById(to_select)) == n
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:broadcastSkillInvoke("jiaozhao")
    room:notifySkillInvoked(player, "jiaozhao", "special")
    player:showCards(effect.cards)
    if player.dead then return end
    local c = Fk:getCardById(effect.cards[1])
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_derived then
        table.insertIfNeed(names, card.name)
      end
    end
    local choice = room:askForChoice(target, names, "jiaozhao", "#jiaozhao-choice:"..player.id.."::"..c:toLogString())
    room:doBroadcastNotify("ShowToast", Fk:translate("jiaozhao_choice")..Fk:translate(choice))
    if room:getCardOwner(c) == player and room:getCardArea(c) == Card.PlayerHand then
      room:setCardMark(c, "jiaozhao-inhand", choice)
      room:setCardMark(c, "@jiaozhao-inhand", Fk:translate(choice))
      room:handleAddLoseSkills(player, "-jiaozhaoEx1|jiaozhaoVS", nil, false, true)
    end
  end,
}
local jiaozhaoEx2 = fk.CreateActiveSkill{
  name = "jiaozhaoEx2",
  mute = true,
  card_num = 1,
  target_num = 0,
  prompt = "#jiaozhaoEx2",
  can_use = function(self, player)
    return not player:isKongcheng() and
      table.every(jiaozhaoSkills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke("jiaozhao")
    room:notifySkillInvoked(player, "jiaozhao", "special")
    player:showCards(effect.cards)
    if player.dead then return end
    local c = Fk:getCardById(effect.cards[1])
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_derived then
        table.insertIfNeed(names, card.name)
      end
    end
    local choice = room:askForChoice(player, names, "jiaozhao", "#jiaozhao-choice:"..player.id.."::"..c:toLogString())
    room:doBroadcastNotify("ShowToast", Fk:translate("jiaozhao_choice")..Fk:translate(choice))
    if room:getCardOwner(c) == player and room:getCardArea(c) == Card.PlayerHand then
      room:setCardMark(c, "jiaozhao-inhand", choice)
      room:setCardMark(c, "@jiaozhao-inhand", Fk:translate(choice))
      room:handleAddLoseSkills(player, "-jiaozhaoEx2|jiaozhaoVS", nil, false, true)
    end
  end,
}
local danxin = fk.CreateTriggerSkill{
  name = "danxin",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_cost = function(self, event, target, player, data)
    local choices = {"Cancel", "draw1"}
    if player:getMark("jiaozhao_status") > 0 and player:getMark("jiaozhao_status") < 3 then
      table.insert(choices, "updateJiaozhao")
    end
    local choice = player.room:askForChoice(player, choices, self.name)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if self.cost_data == "draw1" then
      player:drawCards(1, self.name)
    else
      local room = player.room
      local n = player:getMark("jiaozhao_status")
      room:addPlayerMark(player, "jiaozhao_status", 1)
      if not player:hasSkill("jiaozhaoVS", true) then
        room:handleAddLoseSkills(player, jiaozhaoSkills[n + 1].."|-"..jiaozhaoSkills[n], nil, false, true)
      end
    end
  end,
}
jiaozhaoVS:addRelatedSkill(jiaozhao_prohibit)
Fk:addSkill(jiaozhaoVS)
Fk:addSkill(jiaozhaoEx1)
Fk:addSkill(jiaozhaoEx2)
jiaozhao:addRelatedSkill(jiaozhao_change)
guohuanghou:addSkill(danxin)
guohuanghou:addSkill(jiaozhao)
]]
