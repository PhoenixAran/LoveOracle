local console = require('lib.console')

local questionHandler = {text = ""}

function questionHandler.enter()
    questionHandler.question = "Is this real?"
    console.print(questionHandler.question)
    questionHandler.chosen = "yes"
    questionHandler.setText()
end

function questionHandler.setText()
    questionHandler.text = "\n             " .. questionHandler.question .. "\n\n"
    questionHandler.text = questionHandler.text .. console.buttonText({
        {text = "yes", selected = questionHandler.chosen == "yes"},
        {text = "no", selected = questionHandler.chosen == "no"},
    })
end

function questionHandler.keypressed(key)
    if key == "left" or key == "right" then
        questionHandler.chosen = questionHandler.chosen == "yes" and "no" or "yes"
        questionHandler.setText()
    end

    if key == "return" then
        console.takeOver()
        console.print(questionHandler.chosen)
    end
end

function console.commands.question(str)
    console.takeOver(questionHandler)
end

function console.commands.ezquestion(str)
    console.chooseOption("Why?", {"Pressure", "Conviction"}, function(i, option)
        console.print(i .. " " .. option)
    end)
end

console.help.recipe = {section = "Awesome",
    "Find recipes with a given ingredient",
    "Will ask for an ingredient once invoked."}
function console.commands.recipe(str)
    console.prompt("What kind ingredients would you like to use?", function(str)
        console.print("I don't know any recipes that use " .. str)
    end)
end

function console.commands.quit()
    love.event.quit()
end