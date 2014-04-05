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
------------------------------------------
------------------------------------------
--背景
local back = display.newRect(_W/2, _H/2, _W, _H)
back:setFillColor(0.5, 0.7, 1)
--地面
local base = display.newRect(_W/2, _H -25, _W*3, 50)
base:setFillColor(0.5, 0.3, 0.1)
--地面のふちの線に色を付ける
base:setStrokeColor( 0.5, 0.5, 0.5 )
--地面のふちの線の幅を設定
base.strokeWidth = 3
--地面に物理属性を追加
physics.addBody(base, "static", {density = 10, friction = 0.2, bounce = 0.1})
------------------------------------------
--タイマーの数字に代入する変数
local t = 10
------------------------------------------
--ボール
local ball = display.newCircle(_W/2, _H -70, 20)
--ボールのふちの線に色を付ける
ball:setStrokeColor( 0.5, 0.5, 0.5 )
--ボールのふちの線の幅を設定
ball.strokeWidth = 3
--ボールに物理属性を追加
physics.addBody( ball, "static", {density = 2, friction = 0.2, bounce = 0.5, radius = 20})
------------------------------------------
--ゲームオーバー表示
local text = display.newText("Game Over", _W/2, _H/3, "HelveticaNeue-UltraLight", 48)
--ゲームオーバーを非表示に設定
text.isVisible = false
------------------------------------------
--ゲームクリア表示
local clearText = display.newText("Clear", _W/2, _H/3, "HelveticaNeue-UltraLight", 48)
--ゲームクリアを非表示に設定
clearText.isVisible = false
------------------------------------------
--リセットボタン
local button = display.newImage("Button.png", _W/2, _H *2/3)
--リセットボタンを非表示に設定
button.isVisible = false
------------------------------------------
--「タイマー」の文字
local TitleTimer = display.newText("Time", _W -120, 20, "HelveticaNeue-Light", 30)
--タイマーの本体
local timeText = display.newText( t, _W -30, 20, "HelveticaNeue-Light", 28 )
------------------------------------------
--石を格納しておくテーブル
local rocks = {}
--テーブルの番号に利用する変数
local numB = 0	
--衝突判定のフラグ
local cFlag = 0
------------------------------------------
------------------------------------------
--[[
--画像を変数に代入
local image_name = "rock.png"
--画像の変数を指定し、外形線を取得する
local image_outline = graphics.newOutline( 2, image_name )
--画像サイズを指定してオブジェクトを表示
local image_Heart = display.newImageRect( image_name,150,150 )
--オブジェクトの座標を設定
image_Heart.x = _W/2; image_Heart.y = _H*2/3
--外形線を利用して物理的な実体を作成
physics.addBody( image_Heart, "dynamic", { density = 3.0,friction = 0.6,bounce = 0.4,outline = image_outline } )
--]]
------------------------------------------
--[[
--画像に対する実体の比率を指定
local scaleFactor = 0.5
--rock.luaのfunctionを利用して、物理的な実体を作成する際の外形の座標位置を取得
local rockData = (require ("rock").Data(scaleFactor))
---画像サイズを指定してオブジェクトを表示
local rock = display.newImageRect("rock.png", 150, 150)
--オブジェクトの座標を設定
rock.x = _W/2; rock.y = _H*2/3
--物理的な実体を作成
physics.addBody( rock, rockData:get("rock.png") )
--]]
------------------------------------------
--dropRockというfunctionを作成
local function dropRock(event)
	--タッチイベントが開始されたら
	if("began" == event.phase)then
		--numBの現在の値に1足す
		numB = numB + 1
		--画像に対する実体の比率を指定
		local scaleFactor = 0.5
		--変数
		local rockData
		--1から指定した数字までの間でランダムに数字が決まる
		local n = math.random(2)
		
		--物理的な実体を作成する際の外形の座標位置を取得
		rockData = (require ("rock" .. n).Data(scaleFactor))
		--画像サイズを指定してオブジェクトを表示し、テーブルに格納する
		rocks[numB] = display.newImageRect("rock" .. n .. ".png", 150, 150)
		--オブジェクトの座標を設定
		rocks[numB].x = event.x; rocks[numB].y = event.y
		--物理的な実体を作成
		physics.addBody( rocks[numB], rockData:get("rock" .. n .. ".png") )
	end
end

--画面をタッチイベントのリスナーに設定
Runtime:addEventListener("touch", dropRock)
------------------------------------------
--リセットボタンを押下した時のfunction
local function gameReset(event)
	if("ended" == event.phase)then
		--iがテーブルの最大数から-1していき、1になるまで処理を繰り返す
		for i = table.maxn(rocks), 1, -1 do
			--テーブルの中に格納されているオブジェクトを破棄
			rocks[i]:removeSelf( )
			--テーブルの中身を確実に初期化
			rocks[i] = nil
		end
		
		--変数を初期化
		numB = 0
		
		--ゲームオーバーを非表示に設定
		text.isVisible = false
		
		--ゲームクリアを非表示に設定
		clearText.isVisible = false
		
		--リセットボタンをタッチイベントのリスナーを解除
		button:removeEventListener("touch", gameReset)
		--リセットボタンを表示
		button.isVisible = false
		
		t = 11
		--GameTimerを呼び出す
		timer.resume(GameTimer)
		
		--フラグを初期化
		cFlag = 0
		
		--停止していた物理演算を再開
		physics.start()
		--地面を衝突イベントのリスナーに再度設定
		base:addEventListener("collision", onCollision)
		Runtime:addEventListener("touch", dropRock)
	end
end
------------------------------------------
------------------------------------------
--地面との衝突時のfunction
function onCollision(event)
	if(event.phase == "began")then
		cFlag = 1
		
		--タイマーを一時停止
		timer.pause(GameTimer)
		
		--地面を衝突イベントのリスナーから解除
		base:removeEventListener("collision", onCollision)
		--画面をタッチイベントのリスナーから解除
		Runtime:removeEventListener("touch", dropRock)
		
		--物理演算を一時停止
		physics.pause()
		
		--ゲームオーバーを表示
		text.isVisible = true
		--ゲームオーバーを前面に表示
		text:toFront()
		
		--リセットボタンを表示
		button.isVisible = true
		--リセットボタンを前面に表示
		button:toFront()
		--リセットボタンをタッチイベントのリスナーに設定
		button:addEventListener("touch", gameReset)
	end
end

--地面を衝突イベントのリスナーに設定
base:addEventListener("collision", onCollision)
------------------------------------------
--timeCheckというfunctionを作成
local function timeCheck( )
	t = t-1
	if(t >= 10)then
		timeText.text = t
	elseif(t > 0)then
		timeText.text = "0" .. t
	elseif(t == 0)then
		timeText.text = "0" .. t
		
		if(cFlag == 0)then
			--タイマーを一時停止
			timer.pause(GameTimer)
			
			Runtime:removeEventListener("touch", dropRock)
			--物理演算を一時停止
			physics.pause()
			
			button.isVisible = true
			--リセットボタンを前面に表示
			button:toFront()
			button:addEventListener("touch", gameReset)
		end
		
		--１つでも石が作成されいる場合
		if(table.maxn(rocks) >= 1)then
			clearText.isVisible = true
			clearText:toFront()
		
		--それ以外の場合
		else
			text.isVisible = true
			text:toFront()
		end
	
	--elseif(t < 0)then
	--	timeText.text = t	
	end
end

--１秒ごとにtimeCheckを呼び出すタイマーを作成
GameTimer = timer.performWithDelay(1000, timeCheck, 0)
------------------------------------------
------------------------------------------
