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

local zzz_tangyiming = General(extension, "zzz_tangyiming", "zzz", 4, 4, General.Male)
local zzz_huawen_skills = {"zzz_huawen", "zzz_huawen_all", "zzz_huawen_finish", "zzz_huawen_all_finish"}
local zzz_huawen_all_vs = fk.CreateViewAsSkill{
  name = "zzz_huawen_all_vs",
  interaction = function()
    local names, all_names = {} , {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card:isCommonTrick() and not card.is_derived then
        table.insertIfNeed(all_names, card.name)
        if Self:canUse(card) and not Self:prohibitUse(card) then
          table.insertIfNeed(names, card.name)
        end
      end
    end
    return UI.ComboBox {choices = names, all_choices = all_names}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
}
local zzz_huawen_vs = fk.CreateViewAsSkill{
  name = "zzz_huawen_vs",
  interaction = function()
    local names, all_names = {} , {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.trueName == "savage_assault" or card.trueName == "archery_attack") and not card.is_derived then
        table.insertIfNeed(all_names, card.name)
        table.insertIfNeed(names, card.name)
      end
    end
    return UI.ComboBox {choices = names, all_choices = all_names}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
}
local zzz_huawen = fk.CreateTriggerSkill{
	name = "zzz_huawen",
	events = {fk.EventPhaseStart},
	can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
      and player.phase == Player.Start and
      table.every(zzz_huawen_skills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
	end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local _, dat = room:askForUseActiveSkill(player, "zzz_huawen_vs", "#zzz_huawen-invoke", true)
    if not dat then return false end
    local card = Fk:cloneCard(dat.interaction)
    card.skillName = self.name
    local tos = dat.targets
    room:useCard{
      from = player.id,
      tos = table.map(dat.targets, function(id) return {id} end),
      card = card,
    }
  end,
}
local zzz_huawen_all = fk.CreateTriggerSkill{
	name = "zzz_huawen_all",
	events = {fk.EventPhaseStart},
	can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
      and player.phase == Player.Start and
      table.every(zzz_huawen_skills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
	end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local _, dat = room:askForUseActiveSkill(player, "zzz_huawen_all_vs", "#zzz_huawen_all-invoke", true)
    if not dat then return false end
    local card = Fk:cloneCard(dat.interaction)
    card.skillName = self.name
    local tos = dat.targets
    room:useCard{
      from = player.id,
      tos = table.map(dat.targets, function(id) return {id} end),
      card = card,
    }
  end,
}
local zzz_huawen_finish = fk.CreateTriggerSkill{
	name = "zzz_huawen_finish",
	events = {fk.EventPhaseStart},
	can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
      and (player.phase == Player.Start or player.phase == Player.Finish) and
      table.every(zzz_huawen_skills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
	end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local _, dat = room:askForUseActiveSkill(player, "zzz_huawen_vs", "#zzz_huawen-invoke", true)
    if not dat then return false end
    local card = Fk:cloneCard(dat.interaction)
    card.skillName = self.name
    local tos = dat.targets
    room:useCard{
      from = player.id,
      tos = table.map(dat.targets, function(id) return {id} end),
      card = card,
    }
  end,
}
local zzz_huawen_all_finish = fk.CreateTriggerSkill{
	name = "zzz_huawen_all_finish",
	events = {fk.EventPhaseStart},
	can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
      and (player.phase == Player.Start or player.phase == Player.Finish) and
      table.every(zzz_huawen_skills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
	end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local _, dat = room:askForUseActiveSkill(player, "zzz_huawen_all_vs", "#zzz_huawen_all-invoke", true)
    if not dat then return false end
    local card = Fk:cloneCard(dat.interaction)
    card.skillName = self.name
    local tos = dat.targets
    room:useCard{
      from = player.id,
      tos = table.map(dat.targets, function(id) return {id} end),
      card = card,
    }
  end,
}
local zzz_woxin = fk.CreateTriggerSkill{
	name = "zzz_woxin",
	frequency = Skill.Wake,
	events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getMark("zzz_huawen_status")
    if not n then n = 0 end
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, zzz_huawen_skills[(n | 1) + 1].."|-"..zzz_huawen_skills[n + 1], nil, false, true)
    room:setPlayerMark(player, "zzz_huawen_status", n | 1)
  end,
}
local zzz_changdan = fk.CreateTriggerSkill{
	name = "zzz_changdan",
	frequency = Skill.Wake,
	events = {fk.HpRecover},
	can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getMark("zzz_huawen_status")
    if not n then n = 0 end
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, zzz_huawen_skills[(n | 2) + 1].."|-"..zzz_huawen_skills[n + 1], nil, false, true)
    room:setPlayerMark(player, "zzz_huawen_status", n | 2)
  end,
}
Fk:addSkill(zzz_huawen_vs)
Fk:addSkill(zzz_huawen_all_vs)
Fk:addSkill(zzz_huawen_all)
Fk:addSkill(zzz_huawen_finish)
Fk:addSkill(zzz_huawen_all_finish)
zzz_tangyiming:addSkill(zzz_huawen)
zzz_tangyiming:addSkill(zzz_woxin)
zzz_tangyiming:addSkill(zzz_changdan)
Fk:loadTranslationTable{
  ["zzz_tangyiming"] = "汤一鸣",
  ["#zzz_tangyiming"] = "文漾潇湘",
  ["designer:zzz_tangyiming"] = "zlc",
  ["illustrator:zzz_tangyiming"] = "tym",
	["zzz_huawen"] = "华文",
	[":zzz_huawen"] = "准备阶段，你可以视为使用一张【南蛮入侵】或【万箭齐发】。",
  ["#zzz_huawen-invoke"] = "华文：视为使用一张【南蛮入侵】或【万箭齐发】",
	["zzz_huawen_all"] = "华文",
	[":zzz_huawen_all"] = "准备阶段，你可以视为使用一张普通锦囊牌。",
  ["#zzz_huawen_all-invoke"] = "华文：视为使用一张普通锦囊牌",
	["zzz_huawen_finish"] = "华文",
	[":zzz_huawen_finish"] = "准备阶段或结束阶段，你可以视为使用一张【南蛮入侵】或【万箭齐发】。",
	["zzz_huawen_all_finish"] = "华文",
	[":zzz_huawen_all_finish"] = "准备阶段或结束阶段，你可以视为使用一张普通锦囊牌。",
	["zzz_huawen_vs"] = "华文",
	["zzz_huawen_all_vs"] = "华文",
	["zzz_woxin"] = "卧薪",
	[":zzz_woxin"] = "觉醒技，你受到伤害后，你减1点体力上限，将“华文”中“【南蛮入侵】或【万箭齐发】”修改为“普通锦囊牌”。",
  ["zzz_changdan"] = "尝胆",
	[":zzz_changdan"] = "觉醒技，你回复体力时，你减1点体力上限，将“华文”中“准备阶段”修改为“准备阶段或结束阶段”。",
}

local zzz_chenqishen = General(extension, "zzz_chenqishen", "zzz", 4, 4, General.Male)
local zzz_bawang = fk.CreateTriggerSkill{
	name = "zzz_bawang",
  anim_type = "drawcard",
	events = {fk.DrawNCards},
	can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isNude()
  end,
	on_use = function(self, event, target, player, data)
    data.n = 0
    local choices = {}
    local n_bawang = player:getHandcardNum()
    if not player:isKongcheng() then table.insert(choices, "throw_handcard") end
    if #player.player_cards[Player.Equip] > 0 then table.insert(choices, "throw_all") end
    local choice = player.room:askForChoice(player, choices, self.name, nil, false)
    if choice == "throw_handcard" then
      player:throwAllCards("h")
    else
      n_bawang = n_bawang + #player.player_cards[Player.Equip]
      player:throwAllCards("he")
    end
    player:drawCards(n_bawang + n_bawang, self.name)
	end
}
local zzz_daimao = fk.CreateTriggerSkill{
	name = "zzz_daimao",
	frequency = Skill.Compulsory,
  anim_type = "negative",
  refresh_events = {fk.PreCardUse, fk.EventAcquireSkill, fk.EventLoseSkill},
  can_refresh = function(self, event, target, player, data)
    if player ~= target or player.dead or player.phase ~= Player.Play 
    or player:usedSkillTimes("zzz_bawang", Player.HistoryTurn) == 0 then return false end
    if event == fk.PreCardUse then
      return player:hasSkill(self, true)
    elseif event == fk.EventAcquireSkill then
      return data == self and player.room:getTag("RoundCount")
    elseif event == fk.EventLoseSkill then
      return data == self
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.PreCardUse then
      local x = player:getMark("zzz_daimao-phase") + 1
      room:setPlayerMark(player, "zzz_daimao-phase", x)
      x = 3 - x
      room:setPlayerMark(player, "@zzz_daimao-phase", x > 0 and {"zzz_daimao_remains", x} or {"zzz_daimao_prohibit"})
    elseif event == fk.EventAcquireSkill then
      local phase_event = room.logic:getCurrentEvent():findParent(GameEvent.Phase, true)
      if phase_event == nil then return false end
      local end_id = phase_event.id
      local x = 0
      U.getEventsByRule(room, GameEvent.UseCard, 1, function (e)
        local use = e.data[1]
        if use.from == player.id then
          x = x + 1
        end
        return false
      end, end_id)
      room:setPlayerMark(player, "zzz_daimao-phase", x)
      x = 3 - x
      room:setPlayerMark(player, "@zzz_daimao-phase", x > 0 and {"zzz_daimao_remains", x} or {"zzz_daimao_prohibit"})
    elseif event == fk.EventLoseSkill then
      room:setPlayerMark(player, "@zzz_daimao-phase", 0)
    end
  end,
}
local zzz_daimao_maxcards = fk.CreateMaxCardsSkill{
  name = "#zzz_daimao_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(zzz_daimao) and player:usedSkillTimes("zzz_bawang", Player.HistoryTurn) > 0 then
      return 1
    end
  end,
}
local zzz_daimao_prohibit = fk.CreateProhibitSkill{
  name = '#zzz_daimao_prohibit',
  prohibit_use = function(self, player)
    return player:hasSkill(zzz_daimao) and player.phase == Player.Play and
    (player:getMark("zzz_daimao-phase") >= 3)
  end,
}
zzz_daimao:addRelatedSkill(zzz_daimao_prohibit)
zzz_daimao:addRelatedSkill(zzz_daimao_maxcards)
zzz_chenqishen:addSkill(zzz_bawang)
zzz_chenqishen:addSkill(zzz_daimao)
Fk:loadTranslationTable{
  ["zzz_chenqishen"] = "陈祺珅",
  ["#zzz_chenqishen"] = "我是呆霸王",
  ["designer:zzz_chenqishen"] = "yzy",
	["illustrator:zzz_chenqishen"] = "syh",
	["zzz_bawang"] = "霸王",
	[":zzz_bawang"] = "摸牌阶段，你可以改为弃置所有牌或所有手牌，摸两倍数量的牌。",
  ["throw_handcard"] = "弃置所有手牌",
  ["throw_all"] = "弃置所有牌",
  ["zzz_daimao"] = "呆毛",
	[":zzz_daimao"] = "锁定技，若你于摸牌阶段发动过“霸王”，你本回合出牌阶段至多使用三张牌，且本回合内手牌上限+1。",
  ['@zzz_daimao-phase'] = '呆毛',
  ["zzz_daimao_remains"] = "剩余",
  ["zzz_daimao_prohibit"] = "不能出牌",
}

local zzz_zhouyicheng = General(extension, "zzz_zhouyicheng", "zzz", 3, 3, General.Male)
local zzz_chazui = fk.CreateTriggerSkill{
  name = "zzz_chazui",
  events = {fk.TurnEnd},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and
      player:getMark("zzz_chazui-turn") > 0 and player:getMark("zzz_chazui-turn") >= player.hp
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play, true)
  end,
  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    local x = 0
    for _, move in ipairs(data) do
      if move.from and move.from == player.id then
        x = x + #table.filter(move.moveInfo, function(info)
          return info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip end)
      end
    end
    if x > 0 then
      self.cost_data = x
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "zzz_chazui-turn", self.cost_data)
    if player:hasSkill(self, true) and player ~= player.room.current then
      player.room:setPlayerMark(player, "@zzz_chazui-turn", player:getMark("zzz_chazui-turn"))
    end
  end,
}
local zzz_judai = fk.CreateTriggerSkill{
  name = "zzz_judai",
  events = {fk.TurnEnd},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local players = player.room:getAlivePlayers()
      local to = {}
      for _, p in ipairs(players) do
        if p:getMark("zzz_judai-turn") > player:getHandcardNum() then
          table.insert(to, p)
        end
      end
      self.cost_data = to
      return #to > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
    if player.dead or player:isKongcheng() then return end
    U.askForDistribution(player, player:getCardIds("he"), self.cost_data, self.name, 1, 1, "#zzz_judai-distribution")
  end,
  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    local x = 0
    for _, move in ipairs(data) do
      if move.from and move.from == player.id then
        x = x + #table.filter(move.moveInfo, function(info)
          return info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip end)
      end
    end
    if x > 0 then
      self.cost_data = x
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "zzz_judai-turn", self.cost_data)
    player.room:setPlayerMark(player, "@zzz_judai-turn", player:getMark("zzz_judai-turn"))
  end,
}
zzz_zhouyicheng:addSkill(zzz_chazui)
zzz_zhouyicheng:addSkill(zzz_judai)
Fk:loadTranslationTable{
  ["zzz_zhouyicheng"] = "周弈成",
  ["#zzz_zhouyicheng"] = "绝尘不呆",
  ["designer:zzz_zhouyicheng"] = "zyc&yzy",
	["illustrator:zzz_zhouyicheng"] = "lff",
	["zzz_chazui"] = "插嘴",
	[":zzz_chazui"] = "一名其他角色的回合结束时，若你本回合失去的牌数不少于你的体力值，你可以执行一个出牌阶段。",
  ["@zzz_chazui-turn"] = "插嘴",
  ["zzz_judai"] = "聚呆",
	[":zzz_judai"] = "一名角色的回合结束时，若有角色本回合失去的牌数大于你的手牌数，你可以摸两张牌并交给其中一名角色一张牌。",
  ["@zzz_judai-turn"] = "聚呆",
  ["#zzz_judai-distribution"] = "聚呆：请交给其中一名角色一张牌",
}

local zzz_zhoulangcheng = General(extension, "zzz_zhoulangcheng", "zzz", 4, 4, General.Male)
local zzz_xunyin = fk.CreateActiveSkill{
  name = "zzz_xunyin",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = "#zzz_xunyin",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 5 and player:getMark("@zzz_xunyin-phase") ~= "success"
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:addMark("@zzz_xunyin-phase", 1)
    local x = player:getMark("@zzz_xunyin-phase")
    local card_ids = room:getNCards(x)
    U.viewCards(player, card_ids, self.name)
    local target = room:getPlayerById(room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper),
      1, 1, "#zzz_xunyin_choose_target", self.name, false)[1])
    room:fillAG(player, card_ids)
    local card_id = room:askForAG(player, card_ids, false, "#zzz_xunyin_choose")
    local card_to_guess = Fk:getCardById(card_id)
    room:closeAG(player)
    local choices = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if not card.is_derived then
        table.insertIfNeed(choices, card.trueName)
      end
    end
    local choice = room:askForChoice(target, choices, self.name, "#zzz_xunyin_guess:::"..card_to_guess:getSuitCompletedString(true))
    local card_player_ids = {}
    local card_to_ids = {}
    for _, id in ipairs(card_ids) do
      if Fk:getCardById(id).trueName == choice then
        table.insertIfNeed(card_to_ids, id)
      else
        table.insertIfNeed(card_player_ids, id)
      end
    end
    if #card_to_ids > 0 then
      room:obtainCard(target, card_to_ids, true, fk.ReasonPrey)
      U.askForDistribution(player, card_player_ids, room.alive_players, self.name, #card_player_ids, #card_player_ids, nil, card_player_ids)
      room:setPlayerMark(player, "@zzz_xunyin-phase", "success")
    else
      room:askForDiscard(target, 1, 1, true, self.name, false)
      room:obtainCard(player, card_ids, true, fk.ReasonPrey)
      room:askForDiscard(player, x, x, true, self.name, false)
    end
  end
}
zzz_zhoulangcheng:addSkill(zzz_xunyin)
Fk:loadTranslationTable{
  ["zzz_zhoulangcheng"] = "周朗诚",
  ["#zzz_zhoulangcheng"] = "好姻缘",
  ["designer:zzz_zhoulangcheng"] = "zlc",
	["illustrator:zzz_zhoulangcheng"] = "syh",
  ["zzz_xunyin"] = "巡音",
	[":zzz_xunyin"] = "出牌阶段限五次，你可以观看牌堆顶X张牌（X为1），指定一名其他角色并声明你观看的牌中的一张牌的花色与点数，"
    .."其声明一个牌名。若你观看的牌中有与之相同牌名的牌，你令其获得之并任意分配其余你观看的牌，此阶段不能再发动此技能；"
    .."否则其弃置一张牌，你获得你观看的牌并弃置等量的牌，令此阶段内X+1。",
  ["@zzz_xunyin-phase"] = "巡音",
  ["#zzz_xunyin"] = "巡音：观看牌堆顶X张牌",
  ["#zzz_xunyin_choose_target"] = "巡音：请选择一名其他角色",
  ["#zzz_xunyin_choose"] = "巡音：请选择其中一张牌声明花色点数",
  ["#zzz_xunyin_guess"] = "巡音：请猜测牌名（已知牌中有%arg）",
  ["success"] = "成功",
}

local zzz_zhengyuxiang = General(extension, "zzz_zhengyuxiang", "zzz", 4, 4, General.Male)
local zzz_daimeng = fk.CreateTriggerSkill{
	name = "zzz_daimeng",
	frequency = Skill.Compulsory,
  anim_type = "drawcard",
	events = {fk.CardUsing},
	can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 3, function(e)
        local use = e.data[1]
        return use.from == player.id
      end, Player.HistoryPhase)
      return (#events == 2 and events[2].data[1] == data) or (#events == 1 and events[1].data[1] == data)
    end
  end,
	on_use = function(self, event, target, player, data)
		local mark = player:getMark("@zzz_daimeng-turn")
    if mark == 0 then
      player:addMark("@zzz_daimeng-turn", 1)
			player:drawCards(2, self.name)
		else
      player:addMark("@zzz_daimeng-turn", 1)
		  player.room:askForDiscard(player, 3, 3, true, self.name, false)
		end
	end
}
local zzz_qiangzhuang = fk.CreateTriggerSkill{
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

local zzz_liangyubin = General(extension, "zzz_liangyubin", "zzz", 4, 4, General.Male)
local zzz_qiuge = fk.CreateTriggerSkill{
  name = "zzz_qiuge",
	events = {fk.CardUsing, fk.CardResponding},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if target == player and #player:getPile("zzz_qiu") > 0 and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      return data.card.suit == Fk:getCardById(player:getPile("zzz_qiu")[1]).suit
        or data.card.number == Fk:getCardById(player:getPile("zzz_qiu")[1]).number
    end
  end,
	on_use = function(self, event, target, player, data)
		local room = player.room
    player:showCards(player:getPile("zzz_qiu"))
    player:drawCards(player.maxHp - player:getHandcardNum(), self.name)
    local cids = room:askForCard(player, 1, 1, false, self.name, false, nil, "#zzz_qiuge-put")
    room:moveCardTo(player:getPile("zzz_qiu")[1], Card.DiscardPile, nil, fk.ReasonJustMove, self.name)
    player:addToPile("zzz_qiu", cids[1], false, self.name)
	end,
  refresh_events = {fk.GameStart},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_refresh = function(self, event, target, player, data)
		local room = player.room
    player:drawCards(1, self.name)
    if not player:isKongcheng() then
      local cids = room:askForCard(player, 1, 1, true, self.name, false, nil, "#zzz_qiuge-put")
      if #cids > 0 then
        player:addToPile("zzz_qiu", cids[1], false, self.name)
      end
    end
	end,
}
zzz_liangyubin:addSkill(zzz_qiuge)
Fk:loadTranslationTable{
  ["zzz_liangyubin"] = "梁誉缤",
  ["#zzz_liangyubin"] = "球王",
  ["designer:zzz_liangyubin"] = "yzy",
	["illustrator:zzz_liangyubin"] = "lyb",
	["zzz_qiuge"] = "球哥",
	[":zzz_qiuge"] = "游戏开始时，你可以摸一张牌，并将一张牌扣置于武将牌上，称为“球”。你使用或打出与“球”相同花色或点数的牌时，你可以展示“球”并将手牌摸至体力上限，然后用一张手牌代替“球”。每回合限一次。",
  ["#zzz_qiuge-put"] = "球哥：将一张牌扣置于武将牌上，称为“球”",
  ["zzz_qiu"] = "球",
}


local zzz_zhaiyihong = General(extension, "zzz_zhaiyihong", "zzz", 4, 4, General.Male)
local zzz_pengzhang = fk.CreateActiveSkill{
  name = "zzz_pengzhang",
  prompt = "#zzz_pengzhang-active",
  anim_type = "support",
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and (Fk:currentRoom():getCardArea(to_select) == Player.Hand or Fk:currentRoom():getCardArea(to_select) == Player.Equip) 
      and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  card_num = 1,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    local choices = {"growmaxhp"}
    if from:isWounded() then table.insert(choices, "recover") end
    local choice = room:askForChoice(from, choices, self.name, nil, false)
    if choice == "growmaxhp" then
      room:changeMaxHp(from, 1)
    else
      room:recover({
        who = from,
        num = 1,
        recoverBy = from,
        skillName = self.name
      })
    end
  end
}
local zzz_baozha = fk.CreateTriggerSkill{
  name = "zzz_baozha",
  anim_type = "offensive",
  events = {fk.TurnStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.maxHp > 5
  end,
  on_use = function(self, event, target, player, data)
    local x = player.hp - 5
    if x > 0 then player.room:loseHp(player, x, self.name) end
    while x > 0 do
      local tos = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), Util.IdMapper), 1, 1, "#zzz_baozha-choose", self.name, true)
      if #tos == 0 then return end
      player.room:damage{
        from = player,
        to = player.room:getPlayerById(tos[1]),
        damage = 1,
        skillName = self.name,
      }
      x = x - 1
    end
    x = player.maxHp - 5
    player:drawCards(x, self.name)
    player.room:changeMaxHp(player, -x)
  end,
}
zzz_zhaiyihong:addSkill(zzz_pengzhang)
zzz_zhaiyihong:addSkill(zzz_baozha)
Fk:loadTranslationTable{
  ["zzz_zhaiyihong"] = "翟一泓",
  ["#zzz_zhaiyihong"] = "我太强了",
  ["designer:zzz_zhaiyihong"] = "yzy&zlc",
	["zzz_pengzhang"] = "膨胀",
	[":zzz_pengzhang"] = "出牌阶段，你可以弃置一张牌，选择一项：1. 增加1点体力上限；2.回复1点体力。",
  ["#zzz_pengzhang-active"] = "膨胀：你可以弃置一张牌，令你增加1点体力上限或回复1点体力",
  ["growmaxhp"] = "增加1点体力上限",
  ["zzz_baozha"] = "爆炸",
	[":zzz_baozha"] = "锁定技，回合开始时，若你的体力上限多于5点，你失去体力至5点并分配等同于你以此法失去体力值数量的伤害，减少体力上限至5点并摸等同于你以此法减少的体力上限张数的牌。",
  ["#zzz_baozha-choose"] = "爆炸：对一名角色造成1点伤害",
}

local zzz_tengdanliang = General(extension, "zzz_tengdanliang", "zzz", 3, 3, General.Male)
local zzz_guaicai = fk.CreateTriggerSkill{
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

local zhixi = fk.CreateTriggerSkill{
  name = 'ol__zhixi',
  frequency = Skill.Compulsory,

  refresh_events = { fk.PreCardUse, fk.HpChanged, fk.MaxHpChanged, fk.EventAcquireSkill, fk.EventLoseSkill},
  can_refresh = function(self, event, target, player, data)
    if player ~= target or player.dead or player.phase ~= Player.Play then return false end
    if event == fk.PreCardUse then
      return player:hasSkill(self, true) and player:getMark("ol__zhixi_prohibit-phase") == 0
    elseif event == fk.HpChanged or event == fk.MaxHpChanged then
      return player:hasSkill(self, true) and player:getMark("ol__zhixi_prohibit-phase") == 0
    elseif event == fk.EventPhaseStart then
      return player:hasSkill(self, true)
    elseif event == fk.EventAcquireSkill then
      return data == self and player.room:getTag("RoundCount")
    elseif event == fk.EventLoseSkill then
      return data == self
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.PreCardUse then
      if data.card.type == Card.TypeTrick then
        room:setPlayerMark(player, "ol__zhixi_prohibit-phase", 1)
        room:setPlayerMark(player, "@ol__zhixi-phase", {"ol__zhixi_prohibit"})
      else
        local x = player:getMark("ol__zhixi-phase") + 1
        room:setPlayerMark(player, "ol__zhixi-phase", x)
        x = player.hp - x
        room:setPlayerMark(player, "@ol__zhixi-phase", x > 0 and {"ol__zhixi_remains", x} or {"ol__zhixi_prohibit"})
      end
    elseif event == fk.HpChanged or event == fk.MaxHpChanged then
      local x = player.hp - player:getMark("ol__zhixi-phase")
      room:setPlayerMark(player, "@ol__zhixi-phase", x > 0 and {"ol__zhixi_remains", x} or {"ol__zhixi_prohibit"})
    elseif event == fk.EventPhaseStart then
      room:setPlayerMark(player, "@ol__zhixi-phase", player.hp > 0 and {"ol__zhixi_remains", player.hp} or {"ol__zhixi_prohibit"})
    elseif event == fk.EventAcquireSkill then
      local phase_event = room.logic:getCurrentEvent():findParent(GameEvent.Phase, true)
      if phase_event == nil then return false end
      local end_id = phase_event.id
      local x = 0
      local use_trick = false
      U.getEventsByRule(room, GameEvent.UseCard, 1, function (e)
        local use = e.data[1]
        if use.from == player.id then
          if use.card.type == Card.TypeTrick then
            use_trick = true
            return true
          end
          x = x + 1
        end
        return false
      end, end_id)
      if use_trick then
        room:setPlayerMark(player, "ol__zhixi_prohibit-phase", 1)
        room:setPlayerMark(player, "@ol__zhixi-phase", {"ol__zhixi_prohibit"})
      else
        room:setPlayerMark(player, "ol__zhixi-phase", x)
        x = player.hp - x
        room:setPlayerMark(player, "@ol__zhixi-phase", x > 0 and {"ol__zhixi_remains", x} or {"ol__zhixi_prohibit"})
      end
    elseif event == fk.EventLoseSkill then
      room:setPlayerMark(player, "@ol__zhixi-phase", 0)
    end
  end,
}
local zhixip = fk.CreateProhibitSkill{
  name = '#ol__zhixi_prohibit',
  prohibit_use = function(self, player)
    return player:hasSkill(zhixi) and player.phase == Player.Play and
    (player:getMark("ol__zhixi_prohibit-phase") > 0 or player:getMark("ol__zhixi-phase") >= player.hp)
  end,
}
local ol__jingce = fk.CreateTriggerSkill{
  name = "ol__jingce",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Play then
      local types = {}
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
        local use = e.data[1]
        if use.from == player.id then
          table.insertIfNeed(types, use.card.type)
        end
      end, Player.HistoryTurn)
      if #types > 0 then
        self.cost_data = #types
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(self.cost_data, self.name)
  end,

  refresh_events = {fk.CardUsing, fk.EventAcquireSkill},
  can_refresh = function (self, event, target, player, data)
    if player ~= player.room.current then return false end
    if event == fk.CardUsing then
      return player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
      and not table.contains(U.getMark(player, "@ol__jingce-turn"), data.card:getSuitString(true))
    else
      return data == self and target == player and player.room:getTag("RoundCount")
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      local mark = U.getMark(player, "@ol__jingce-turn")
      table.insert(mark, data.card:getSuitString(true))
      room:setPlayerMark(player, "@ol__jingce-turn", mark)
    else
      local mark = {}
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
        local use = e.data[1]
        if use.from == player.id and use.card.suit ~= Card.NoSuit then
          table.insertIfNeed(mark, use.card:getSuitString(true))
        end
      end, Player.HistoryTurn)
      room:setPlayerMark(player, "@ol__jingce-turn", #mark > 0 and mark or 0)
    end
    room:broadcastProperty(player, "MaxCards")
  end,
}
local ol__jingce_maxcards = fk.CreateMaxCardsSkill{
  name = "#ol__jingce_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(ol__jingce) then
      return #U.getMark(player, "@ol__jingce-turn")
    end
  end,
}

local shangjian = fk.CreateTriggerSkill{
  name = "shangjian",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Finish and
      player:getMark("shangjian-turn") > 0 and player:getMark("shangjian-turn") <= player.hp
  end,
  on_use = function(self, event, target, player, data)
    player.room:drawCards(player, player:getMark("shangjian-turn"), self.name)
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    local fuckYoka = {}
    local parentUseData = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if parentUseData then
      local use = parentUseData.data[1]
      if use.card.type == Card.TypeEquip and use.from == player.id then
        fuckYoka = use.card:isVirtual() and use.card.subcards or {use.card.id}
      end
    end
    local x = 0
    for _, move in ipairs(data) do
      if move.from and move.from == player.id then
        x = x + #table.filter(move.moveInfo, function(info)
          return (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and not table.contains(fuckYoka, info.cardId) end)
      end
      if move.to ~= player.id or move.toArea ~= Card.PlayerEquip then
        x = x + #table.filter(move.moveInfo, function(info)
          return (info.fromArea == Card.Processing) and table.contains(fuckYoka, info.cardId) end)
      end
    end
    if x > 0 then
      self.cost_data = x
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "shangjian-turn", self.cost_data)
    if player:hasSkill(self, true) then
      player.room:setPlayerMark(player, "@shangjian-turn", player:getMark("shangjian-turn"))
    end
  end,
}
local os__mingren = fk.CreateTriggerSkill{
  name = "os__mingren",
  events = {fk.GameStart, fk.EventPhaseStart, fk.EventPhaseEnd},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    return (event == fk.GameStart or (target == player and player.phase == Player.Play and not player:isKongcheng() and #player:getPile("os__duty") > 0))
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.GameStart then
      return true
    else
      local cids = player.room:askForCard(player, 1, 1, false, self.name, true, nil, "#os__mingren-exchange")
      if #cids > 0 then
        self.cost_data = cids[1]
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      player:drawCards(1, self.name)
      if not player:isKongcheng() then
        local cids = room:askForCard(player, 1, 1, false, self.name, true, nil, "#os__mingren-put")
        if #cids > 0 then
          player:addToPile("os__duty", cids[1], true, self.name)
        end
      end
    else
      player:addToPile("os__duty", self.cost_data, true, self.name)
      room:moveCardTo(player:getPile("os__duty")[1], Player.Hand, player, fk.ReasonJustMove, self.name, "os__duty")
    end
  end,
}
local ty_ex__qianxin = fk.CreateTriggerSkill{
  name = "ty_ex__qianxin",
  events = {fk.Damage},
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player.hp < player.maxHp
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, "ty_ex__jianyan")
  end,
}
local qice = fk.CreateViewAsSkill{
  name = "qice",
  interaction = function()
    local names, all_names = {} , {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card:isCommonTrick() and not card.is_derived then
        table.insertIfNeed(all_names, card.name)
        if Self:canUse(card) and not Self:prohibitUse(card) then
          table.insertIfNeed(names, card.name)
        end
      end
    end
    return UI.ComboBox {choices = names, all_choices = all_names}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(Self:getCardIds(Player.Hand))
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
}
local pangdegong = General(extension, "ty__pangdegong", "qun", 3)
local heqia = fk.CreateTriggerSkill{
  name = "heqia",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and (not player:isNude() or
      table.find(player.room:getOtherPlayers(player), function(p) return not p:isNude() end))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askForUseActiveSkill(player, "heqia_active", "#heqia-invoke", true, nil, false)
    if success and dat then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to
    local to_get
    if #self.cost_data.cards > 0 then
      to = room:getPlayerById(self.cost_data.targets[1])
      to_get = self.cost_data.cards
    else
      to = player
      local src = room:getPlayerById(self.cost_data.targets[1])
      to_get = room:askForCard(src, 1, 999, true, self.name, false, ".", "#heqia-give:"..player.id)
    end
    room:moveCardTo(to_get, Card.PlayerHand, to, fk.ReasonGive, self.name, nil, false, player.id)
    if to.dead or to:isKongcheng() then return end
    room:setPlayerMark(to, "heqia-tmp", #to_get)
    local success, dat = room:askForUseActiveSkill(to, "heqia_viewas", "#heqia-use:::"..#to_get, true)
    if success and dat then
      local card = Fk:cloneCard(dat.interaction)
      card:addSubcards(dat.cards)
      room:useCard{
        from = to.id,
        tos = table.map(dat.targets, function(id) return {id} end),
        card = card,
        extraUse = true,
      }
    end
  end,
}
local heqia_active = fk.CreateActiveSkill{
  name = "heqia_active",
  min_card_num = 0,
  target_num = 1,
  interaction = function()
    local choices = {}
    if not Self:isNude() then table.insert(choices, "heqia_give") end
    if table.find(Fk:currentRoom().alive_players, function(p) return Self ~= p and not p:isNude() end) then
      table.insert(choices, "heqia_prey")
    end
    return UI.ComboBox {choices = choices}
  end,
  card_filter = function(self, to_select, selected)
    if not self.interaction.data or self.interaction.data == "heqia_prey" then return false end
    return true
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if not self.interaction.data or #selected > 0 or to_select == Self.id then return false end
    if self.interaction.data == "heqia_give" then
      return #selected_cards > 0
    else
      return not Fk:currentRoom():getPlayerById(to_select):isNude()
    end
  end,
}
local heqia_viewas = fk.CreateActiveSkill{
  name = "heqia_viewas",
  interaction = function()
    local all_names = U.getAllCardNames("b")
    local names = U.getViewAsCardNames(Self, "heqia", all_names)
    if #names == 0 then return false end
    return UI.ComboBox { choices = names, all_choices = all_names }
  end,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if not self.interaction.data or #selected_cards ~= 1 then return false end
    if #selected >= Self:getMark("heqia-tmp") then return false end
    local to_use = Fk:cloneCard(self.interaction.data)
    to_use.skillName = "heqia"
    if Self:isProhibited(Fk:currentRoom():getPlayerById(to_select), to_use) then return false end
    return to_use.skill:modTargetFilter(to_select, selected, Self.id, to_use, false)
  end,
  feasible = function(self, selected, selected_cards)
    if not self.interaction.data or #selected_cards ~= 1 then return false end
    local to_use = Fk:cloneCard(self.interaction.data)
    to_use.skillName = "heqia"
    if to_use.skill:getMinTargetNum() == 0 then
      return (#selected == 0 or table.contains(selected, Self.id)) and to_use.skill:feasible(selected, selected_cards, Self, to_use)
    else
      return #selected > 0
    end
  end,
}
]]
