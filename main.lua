--TODO check if infection from red aura
--buffer last render, and check collision from there
--remove just a little bit , as collision will be continuous
-- or check radius, but then no trail will be taken into account?


cvsw=640
cvsh=480

health=100


  rw=124/255
  gw=139/255
  bw=255/255

  re=0/255
  ge=243/255
  be=0/255


rooms={
  }

loadRooms= function()
  
  room1={}
  room1.name='welcome'
  room1.imageData=love.image.newImageData('001.png')
  room1.pic=love.graphics.newImage(room1.imageData)
  
  table.insert(rooms,room1)

  room2={}
  room2.name='continued'
  room2.imageData=love.image.newImageData('002.png')
  room2.pic=love.graphics.newImage(room2.imageData)
  
  table.insert(rooms,room2)


end

loadRooms()

--roomCollisionMap=love.image.newImageData(
----  'testroom.png'
--'001.png'
--  )
--roomPic=love.graphics.newImage(roomCollisionMap)

currentRoom=1

setCurrentRoom=function(num)
  roomCollisionMap=rooms[num].imageData
  roomPic=rooms[num].pic
end

setCurrentRoom(currentRoom)



--gameplay variables
initinfectionradius=10
decreaserate=0.2

if love.system.getOS()=='Android' then
   ww,wh=love.window.getMode()
   ww=ww/dpiScl
   wh=wh/dpiScl
 else
 
	ww=854
	 wh=480
 	 love.window.setMode(ww,wh,{resizable=true})
 end




 function determineHDUicanvasZoom(nww,nwh)
	local pscrsx=nww/cvsw
	local pscrsy=nwh/cvsh
	if pscrsx>pscrsy then
		scrsy=pscrsy
		scrsx=pscrsy
	else
		scrsy=pscrsx
		scrsx=pscrsx
	
	end
--	addMsg('zoom ' .. scrsx)
 
 end

	determineHDUicanvasZoom(ww,wh)

	cvs=love.graphics.newCanvas(cvsw,cvsh)

moves={}
--sqspeed=64
sqspeed=256

function calculatetraj(tx,ty,ix,iy)
	moves={}
	squaredist=(tx-ix)*(tx-ix)+(ty-iy)*(ty-iy)
	nbsteps=squaredist/sqspeed
	xstep=(tx-ix)/nbsteps
	ystep=(ty-iy)/nbsteps
	for i=1,nbsteps
	do
		table.insert(moves,{dx=xstep,dy=ystep})
	end
end


function love.resize( nw, nh )
	local npw,nph=love.window.toPixels( nw, nh )
	ww=npw
	wh=nph

	determineHDUicanvasZoom(ww,wh) 


	-- local pscrsx=ww/conf.cvsw
	-- local pscrsy=wh/conf.cvsh
	-- if pscrsx>pscrsy then
		-- scrsy=pscrsy
		-- scrsx=pscrsy
	-- else
		-- scrsy=pscrsx
		-- scrsx=pscrsx
	
	-- end
end


px = 100
py=100


gos={
	{x=50,y=100,dir='r',trail={ {x=100,y=100,strength=initinfectionradius} }},
	{x=200,y=150,dir='g',trail={  }}
}

updateinfectiontrail = function(go)
  for j,inf in ipairs(go.trail) 
  do
    inf.strength=inf.strength-decreaserate
    if inf.strength<=0
    then
      table.remove(go.trail,j)
      
    end
  end
  
  table.insert(go.trail,{x=go.x,y=go.y,strength=initinfectionradius})
  
  
end




updatego=function(go)
  
    potx=go.x
    poty=go.y
    
		if go.dir=='r' then potx=go.x+1 
		elseif go.dir=='g' then potx=go.x-1 end


		if go.dir=='r' and potx>=cvsw  
    then 
      go.dir='g' 
      return
    elseif go.dir=='g' and potx<=0  
    then 
      go.dir='r'
      return
    end

    if colorColl(potx,poty,rw,gw,bw) then
      if go.dir=='r' then go.dir='g' 
      elseif go.dir=='g' then go.dir='r' end
      
    else
      go.x=potx
      go.y=poty
    end

    
    updateinfectiontrail(go)
  
end


updategos= function()
    
  
	for i,go in ipairs(gos)
	do
      updatego(go)
  end
end


love.draw=function()
 
 love.graphics.setCanvas(cvs)
 love.graphics.clear()
 love.graphics.draw(roomPic)
 love.graphics.setColor(1.0,0.0,0.0,0.5)
 for i,go in ipairs(gos)
 do
   for j,inf in ipairs(go.trail)
    do
     love.graphics.circle('fill',inf.x,inf.y,inf.strength ) 
    end
  end
 
love.graphics.setColor(0.0,1.0,0.0,1.0)

for i,go in ipairs(gos)
do
     love.graphics.circle('fill',go.x,go.y,4 ) 

--	love.graphics.print('o',go.x,go.y)
  
end

love.graphics.setColor(1.0,1.0,1.0,1.0)
love.graphics.print('plague')



   love.graphics.circle('fill',px,py,4 )
   
   
   --displaying health level
   love.graphics.rectangle('fill',0,0,health/100*cvsw,32)
   
   
-- love.graphics.print('x',px,py)
 love.graphics.setCanvas()

 love.graphics.draw(cvs,0,0,0,scrsx,scrsy)

end


love.mousepressed=function(x,y)
	calculatetraj(math.floor(x/scrsx),math.floor(y/scrsy),px,py)

end


colorColl=function(tx,ty,rc,gc,bc)
  
  local r,g,b,a=roomCollisionMap:getPixel(tx,ty)

--  rw=124/255
--  gw=139/255
--  bw=255/255
  if r==rc and g==gc and b==bc then
    return true
  end
--  if a~=0 then return true end
  
  return false
end


love.update=function()
  
  
  
	toapply=moves[1]
	if toapply~=nil then
	  tpx=px+toapply.dx
	  tpy=py+toapply.dy
     
     
--    local r,g,b,a=roomCollisionMap:getPixel(tpx,tpy)
     
--    if a~=0 then
    if colorColl(tpx,tpy,rw,gw,bw) then
      --move not possible
      moves={}
            
    elseif colorColl(tpx,tpy,re,ge,be) then
      -- we check next level ( green ) here
      currentRoom=currentRoom+1
      setCurrentRoom(currentRoom)
    
    else
      --otherwise we keep on moving
      px=tpx
      py=tpy
      table.remove(moves,1)

    end
     
     
	end

	updategos()
end