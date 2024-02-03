local extension = Package("zzzc4")
local zzzc4_pao = require "packages/zzzc4/zzzc4_pao"
local zzzc4_xue = require "packages/zzzc4/zzzc4_xue"


Fk:loadTranslationTable{
    ["zzzc4"] = "班杀",
  }

return {
    extension,
    zzzc4_pao,
    zzzc4_xue,
}

