-------------------------------------------------------------------------------------------------------------------------------------------------
-- S C R E E N   I N I T
-------------------------------------------------------------------------------------------------------------------------------------------------
SW=love.graphics:getWidth() ; SH=love.graphics:getHeight()
love.graphics.setBackgroundColor(255,255,255)
-------------------------------------------------------------------------------------------------------------------------------------------------
-- L O A D    T I L E S E T
-------------------------------------------------------------------------------------------------------------------------------------------------
tiles = love.graphics.newImage("terrain.png")
tilesetW=tiles:getWidth();tilesetH=tiles:getHeight()
tilew=64 ;tileh=32 -- largeur / hauteur tile
htilew=tilew/2;htileh=tileh/2 -- idem half tile
tiler=tileh/tilew; -- ratio tilesize  
mapw=math.floor( (SW-tilesetW)/tilew )  -- largeur de la zone affichable, en nbr de cells
SP = love.graphics.newSpriteBatch( tiles, 1200, "static" )

TILE={}
for i=0,tilesetW/tilew,1 do
	TILE[i]={}
	for j=0,tilesetH/tileh,1 do
		TILE[i][j]=love.graphics.newQuad( i*tilew,j*tileh, tilew, tileh, tilesetW,tilesetH)
	end
end	

DrawQ={}
DQi=0

Qstamp=TILE[0][0]
-------------------------------------------------------------------------------------------------------------------------------------------------
-- C A L C U L S  Mouse -> cell -> screen
-- on decoupe le plan losanges : ce sont les "cells".  les diagonales ont pour mesure tilew/tileh
-- chaque losange s'inscrit dans un rectangle englobant qu'on decoupe en 4 recangles de mesure htilew/htileh (h pour half)
-------------------------------------------------------------------------------------------------------------------------------------------------
-- table utilisee pour calculer les coordonnees de la cellule en fonction des coordonees du rectangle "quart de cellule"
xy2cell_tbl={       -- mpente,decal,addabow,cxshift pour les 4 combinaisons pair/impair de qx/qy
			{   {-1,1,0,0}  , {1,0,0,0} },   --qx pair {  qy pair, qy inpair }
			{   {1,0,-1,-1} , {-1,1,1,0} }     --qx inpair {  qy pair, qy inpair }
 		}
-------------------------------------------------------------------------------------------------------------------------------------------------		
-- trouve la cellule qui contiens le point x,y
function getcell(x,y)  --------------------------------------------------------------------------------------------------------------------
	rx=x%htilew;ry=y%htileh; 		-- position relative de la souris dans le quart de rectangle englobant
	qx=(x-rx)/htilew;qy=(y-ry)/htileh; 	-- qx,qy = coordonees du quart de rectangle englobant de cell (unit=quart de rectangle)
	mpente,decal,addabow,cxshift=unpack(xy2cell_tbl[qx%2+1][qy%2+1]) -- charge coefs
	if ry > ((rx*mpente*tiler)+(htileh*decal))  then abow=1 else abow=0;end -- souris above/below diagonale
	return math.floor(qx/2)+addabow*(abow+cxshift),qy+abow
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-- renvoie les coordonees du coin superieur gauche du rectangle englobant la cell dont on passe les coordonees en parametre
function cell_coord(cx,cy) -------------------------------------------------------------------------------------------------------------
	return (cx*2+(cy%2)-1)*htilew,(cy-1)*htileh
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-- P A I N T   C E L L
-------------------------------------------------------------------------------------------------------------------------------------------------
--~ function put(q,cx,cy)
--~ 		SP:addq(q,cell_coord(cx,cy))
--~ end
-------------------------------------------------------------------------------------------------------------------------------------------------
-- D R A W   T I L E    L I S T
-------------------------------------------------------------------------------------------------------------------------------------------------
function draw_tile_list()
-- catalogue des tiles sur la gauche
	love.graphics.setColor(255,200,255,255)
	love.graphics.setColorMode( "replace" )
	love.graphics.rectangle("fill",mapw*tilew,0,tilesetW,tilesetH)
	SP:add(mapw*tilew,0)
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-- M O U S E
-------------------------------------------------------------------------------------------------------------------------------------------------
-- PRESSED
function love.mousepressed( x, y, button )
	cx,cy = getcell(x,y)
	if cx>=mapw then do
					Qstamp=TILE[cx-mapw][(cy-1)/2]
				end
			else 	do
					DrawQ[DQi]={}
					DrawQ[DQi][0],DrawQ[DQi][1]=cell_coord(cx,cy)
					DrawQ[DQi][2]=Qstamp
					DQi=DQi+1
				end
	end
end	

--RELEASED
-------------------------------------------------------------------------------------------------------------------------------------------------
-- K E Y B O A R D
-------------------------------------------------------------------------------------------------------------------------------------------------
function love.keypressed(key)   -- we do not need the unicode, so we can leave it out
   if key == "escape" then
      love.event.push("quit")   -- actually causes the app to quit
   end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-- U P D A T E
-------------------------------------------------------------------------------------------------------------------------------------------------
function love.update(dt)
	SP = love.graphics.newSpriteBatch( tiles, 1200, "dynamic" )
	cx,cy=getcell( love.mouse.getPosition( ))
	if cx>=mapw and cy%2==0 then cy=pcy;end
	pcy=cy
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-- D R A W
-------------------------------------------------------------------------------------------------------------------------------------------------
function love.draw()
	for i=0,DQi-1,1 do
		SP:addq(DrawQ[i][2],DrawQ[i][0],DrawQ[i][1])
	end
	draw_tile_list()
	zx,zy=cell_coord( cx,cy   )
	
	SP:addq(Qstamp,zx,zy)
 	love.graphics.draw(SP)
	
	
	love.graphics.setColor(255,0,0,255)
	love.graphics.rectangle("line",zx,zy,tilew,tileh)
	love.graphics.polygon('line',zx+htilew,zy,zx+tilew,zy+htileh,zx+htilew,zy+tileh,zx,zy+htileh)
end