---@param spriteBank SpriteBank
return function(spriteBank)

  -- 9 patch inventory panels
  local spriteBuilder = spriteBank.createSpriteBuilder()
  spriteBuilder:setSpriteSheet('inventory_panel')

  -- construct sprites
  local greenNinePatch = spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 1, 1, 'green_ui_9_patch')
  local yellowNinePatch = spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 4, 1, 'yellow_ui_9_patch')
  local redNinePatch = spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 7, 1, 'red_ui_9_patch')

  -- register 9 patch sprites
  spriteBank.registerSprite('item_panel_9', spriteBuilder:buildNinePatchSprite(greenNinePatch, 160, 192, 1))
  spriteBank.registerSprite('item_details_panel_9', spriteBuilder:buildNinePatchSprite(yellowNinePatch, 96, 96, 1))

  -- status bars
  spriteBuilder:setSpriteSheet('ui_bars_small')

  -- construct sprites
  local healthBarBorder = spriteBuilder:buildSprite(1, 1)
  local healthBarFill = spriteBuilder:buildSprite(2, 1)
  
  local madnessBarBorder = spriteBuilder:buildSprite(2, 1)
  local madnessBarFill = spriteBuilder:buildSprite(2, 2)

  local staminaBarBorder = spriteBuilder:buildSprite(3, 1)
  local staminaBarFill = spriteBuilder:buildSprite(3, 2)


  -- register sprites
  spriteBank.registerSprite('health_bar_border', healthBarBorder)
  spriteBank.registerSprite('health_bar_fill', healthBarFill)
  spriteBank.registerSprite('madness_bar_border', madnessBarBorder)
  spriteBank.registerSprite('madness_bar_fill', madnessBarFill)
  spriteBank.registerSprite('stamina_bar_border', staminaBarBorder)
  spriteBank.registerSprite('stamina_bar_fill', staminaBarFill)
end