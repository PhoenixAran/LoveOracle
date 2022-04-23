return makeModuleFunction(function(loadFontFunc)
  -- font for debug console
  loadFontFunc('data/assets/fonts/express.ttf', 'debugConsole', 18)
  -- font for base screen on screen print
  loadFontFunc('data/assets/fonts/express.ttf', 'baseScreenDebug', 9)
  loadFontFunc('data/assets/fonts/classified.ttf', 'dialog', 16)
end)