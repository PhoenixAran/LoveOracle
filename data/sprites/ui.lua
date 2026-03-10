---@param spriteBank SpriteBank
return function(spriteBank)
  local spriteBuilder = spriteBank.createSpriteBuilder()
  spriteBuilder:setSpriteSheet('inventory_panel')

  -- construct the ninePatchTextures
  local greenNinePatch = spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 1, 1, 'green_ui_9_patch')
  local yellowNinePatch = spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 4, 1, 'yellow_ui_9_patch')
  local redNinePatch = spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 7, 1, 'red_ui_9_patch')

  -- construct sprites
  spriteBank.registerSprite('item_panel_9', spriteBuilder:buildNinePatchSprite(greenNinePatch, 160, 192, 1))
  spriteBank.registerSprite('item_details_panel_9', spriteBuilder:buildNinePatchSprite(yellowNinePatch, 96, 96, 1))
  
  -- TODO rest of them

end