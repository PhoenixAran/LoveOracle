---@param spriteBank SpriteBank
return function(spriteBank)
  local spriteBuilder = spriteBank.createSpriteBuilder()
  spriteBuilder:setSpriteSheet('inventory_panel')

  -- construct the ninePatchTextures
  local greenNinePatch = spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 1, 1, 'green_ui_9_patch')
  local yellowNinePatch = spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 4, 1, 'yellow_ui_9_patch')
  local redNinePatch = spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 7, 1, 'red_ui_9_patch')

  -- construct sprites
  spriteBuilder:buildNinePatchSprite(greenNinePatch, 32, 32, 1)
  -- TODO rest of them

end