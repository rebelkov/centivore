local Sheetchenille = {}

Sheetchenille.sheet =
{
    frames = {
    
        {
            -- chenille1
            x=1,
            y=1,
            width=20,
            height=20,

        },
        {
            -- chenille2
            x=23,
            y=1,
            width=20,
            height=20,

        },
        {
            -- chenille3
            x=45,
            y=1,
            width=20,
            height=20,

        },
        {
            -- chenille4
            x=67,
            y=1,
            width=20,
            height=20,

        },
    },
    
    sheetContentWidth = 88,
    sheetContentHeight = 22
}

Sheetchenille.frameIndex =
{

    ["chenille1"] = 1,
    ["chenille2"] = 2,
    ["chenille3"] = 3,
    ["chenille4"] = 4,
}

function Sheetchenille:getSheet()
    return self.sheet;
end

function Sheetchenille:getFrameIndex(name)
    return self.frameIndex[name];
end

return Sheetchenille
