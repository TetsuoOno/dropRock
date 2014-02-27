--ステータスバーを非表示に設定
display.setStatusBar( display.HiddenStatusBar )

--物理演算の呼出し
local physics = require( "physics" )
--描画モード
--physics.setDrawMode("hybrid")
--物理演算の開始
physics.start()

local _W = display.contentWidth
local _H = display.contentHeight

--石のテーブル
local rocks = {}
--
local numB = 0
--タイマーの数字に代入する変数
local t = 10
------------------------------------------
------------------------------------------
--背景
local back = display.newRect(_W/2, _H/2, _W, _H)
back:setFillColor(0.5, 0.7, 1)
--地面
local base = display.newRect(_W/2, _H -25, _W*3, 50)
base:setFillColor(0.5, 0.3, 0.1)
base:setStrokeColor( 0.5, 0.5, 0.5 )
base.strokeWidth = 3
physics.addBody(base,"static",{density = 10, friction = 0.2, bounce = 0.1})
------------------------------------------
--ボール
local ball = display.newCircle(_W/2, _H -70, 20)
ball:setStrokeColor( 0.5, 0.5, 0.5 )
ball.strokeWidth = 3
physics.addBody( ball, "static", {density = 2, friction = 0.2, bounce = 0.5, radius = 20})
------------------------------------------
--ゲームオーバー
local text = display.newText("Game Over", _W/2, _H/3, "HelveticaNeue-UltraLight", 48)
text.isVisible = false
------------------------------------------
--ゲームクリア
local clearText = display.newText("Clear", _W/2, _H/3, "HelveticaNeue-UltraLight", 48)
clearText.isVisible = false
------------------------------------------
--リセットボタン
local button = display.newImage("Button.png", _W/2, _H *2/3)
button.isVisible = false
------------------------------------------
--タイマータイトル
local TitleTimer = display.newText("Time", _W -120, 20, "HelveticaNeue-Light", 30)
--タイマーの数字
local timeText = display.newText( t, _W -30, 20, "HelveticaNeue-Light", 28 )
------------------------------------------
------------------------------------------
--
local function dropRock(event)
	if("began" == event.phase)then
		numB = numB + 1
		
		local scaleFactor = 0.5
		local rockData
		local n = math.random(3)
		--if(numB <= 3)then
			
			--
			rockData = (require ("rock" .. n).Data(scaleFactor))
			--
			rocks[numB] = display.newImageRect("rock" .. n .. ".png", 150, 150)
			--
			rocks[numB].x = event.x; rocks[numB].y = event.y
			--
			physics.addBody( rocks[numB], rockData:get("rock" .. n .. ".png") )
			print(n)
			print(rocks[numB])
		
		--elseif(numB > 3)then
		--	numB = 0
		--	Runtime:removeEventListener("touch", dropRock)
		--end
	end
end

Runtime:addEventListener("touch", dropRock)
------------------------------------------
local function gameReset(event)
	if("ended" == event.phase)then
		for i = table.maxn(rocks), 1, -1 do
			print(i)
			rocks[i]:removeSelf( )
			rocks[i] = nil
			print(rocks[i])
		end
		
		numB = 0
		
		text.isVisible = false
		clearText.isVisible = false
		
		button:removeEventListener("touch", gameReset)
		button.isVisible = false
		
		t = 11
		--即座にGameTimerを呼び出す
		timer.resume(GameTimer)
		
		physics.start()
		Runtime:addEventListener("touch", dropRock)
	end
end
------------------------------------------

------------------------------------------
local function onCollision(event)
	if(event.phase == "began")then
		timer.pause(GameTimer)
		Runtime:removeEventListener("touch", dropRock)
		physics.pause()
		
		text.isVisible = true
		text:toFront()
		button.isVisible = true
		button:toFront()
		button:addEventListener("touch", gameReset)
	end
end

base:addEventListener("collision", onCollision)
------------------------------------------
local function timeOver()
	text.isVisible = true
	text:toFront()
end
------------------------------------------
local function clear()
	clearText.isVisible = true
	clearText:toFront()
end
------------------------------------------

local function timeCheck( event )
	t = t-1
	if(t >= 10)then
		timeText.text = t
	elseif(t > 0)then
		timeText.text = "0" .. t
	elseif(t == 0)then
		timeText.text = "0" .. t
		
		timer.pause(GameTimer)
		
		Runtime:removeEventListener("touch", dropRock)
		physics.pause()
		
		button.isVisible = true
		button:toFront()
		button:addEventListener("touch", gameReset)
	
		if(table.maxn(rocks) >= 1)then
			clear()
		else
			timeOver()
		end
	end
end

--１秒ごとにtimeCheckを呼び出す
GameTimer = timer.performWithDelay(1000, timeCheck, 0)
------------------------------------------
------------------------------------------
