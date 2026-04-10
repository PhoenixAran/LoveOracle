---@param spriteBank SpriteBank
return function(spriteBank)
  -- inventory panels
  local spriteBuilder = spriteBank.createSpriteBuilder()
  spriteBuilder:setSpriteSheet('inventory_panel')

  -- construct nine patch textures
  spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 1, 1, 'green_ui_9_patch')
  spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 4, 1, 'yellow_ui_9_patch')
  spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 7, 1, 'red_ui_9_patch')

  -- spriteBank.registerSprite('item_panel_9', spriteBuilder:buildNinePatchSprite(greenNinePatch, 160, 192, 1))
  -- spriteBank.registerSprite('item_details_panel_9', spriteBuilder:buildNinePatchSprite(yellowNinePatch, 96, 96, 1))

  -- status bars
  spriteBuilder:setSpriteSheet('ui_bars_border_9')

  -- register bar nine patch texture
  spriteBank.createThreePatchTextureAsNine(spriteBuilder:getSpriteSheet(), 1, 1, true, 'ui_bar_border')

  -- bar fills
  spriteBuilder:setSpriteSheet('ui_bars_fill')
  
  spriteBank.registerSprite('black_bar_fill', spriteBuilder:buildSprite(1, 4))
  spriteBank.registerSprite('health_bar_fill', spriteBuilder:buildSprite(1, 1))
  spriteBank.registerSprite('madness_bar_fill', spriteBuilder:buildSprite(1, 2))
  spriteBank.registerSprite('stamina_bar_fill', spriteBuilder:buildSprite(1, 3))

  -- construct nine patch textures
  -- local healthBarFill = spriteBank.createThreePatchAsNine(spriteBuilder:getSpriteSheet(), 1, 1, 'health_bar_fill_9')
  -- local staminaBarFill = spriteBank.createThreePatchAsNine(spriteBuilder:getSpriteSheet(), 1, 2, 'stamina_bar_fill_9')
  -- local madnessBarFill = spriteBank.createThreePatchAsNine(spriteBuilder:getSpriteSheet(), 1, 3, 'madness_bar_fill_9')
end