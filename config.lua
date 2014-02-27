
local isTall = ( "iPhone" == system.getInfo( "model" ))and ( display.pixelHeight > 960 )
--or ("iPod touch" == system.getInfo( "model") 

if(isTall)then
application = {
	content = {
		width = 320,
		height = 568, 
		scale = "letterBox",--letterBox zoomEven
		fps = 30,
		
		imageSuffix = {
		    ["@2x"] = 2,
		}
		
	},

    --[[
    -- Push notifications

    notification =
    {
        iphone =
        {
            types =
            {
                "badge", "sound", "alert", "newsstand"
            }
        }
    }
    --]]
}
else
application = {
	content = {
		width = 320,
		height = 480, 
		scale = "letterBox",
		fps = 30,
		
        imageSuffix = {
		    ["@2x"] = 2,
		}
		
	},

    --[[
    -- Push notifications

    notification =
    {
        iphone =
        {
            types =
            {
                "badge", "sound", "alert", "newsstand"
            }
        }
    }
    --]]
}
end
