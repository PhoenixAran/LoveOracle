return makeModuleFunction(function(loadFontFunc)
  -- font for base screen on screen print
  loadFontFunc('data/assets/fonts/express.ttf', 'baseScreenDebug', 9)
  -- font for text boxes
  loadFontFunc('data/assets/fonts/classified.ttf', 'dialog', 16)
end)