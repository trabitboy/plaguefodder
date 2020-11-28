--TODO check if infection from red aura
--buffer last render, and check collision from there
--remove just a little bit , as collision will be continuous
-- or check radius, but then no trail will be taken into account?


dbgmsg='dbg'

--android bug : color analysis doesnt seem to work (wall is ignored, no baddie created ,
--exit doesnt work,nor spawn point
--gameplay variables
initinfectionradius=10
decreaserate=0.2

cvsw=640
cvsh=480

health=100
infectionStep=0.1

mapDetectInhib=64

  --wall
  rw=124
  gw=139
  bw=255


  -- spawn point of player
  rp=243
  gp=0
  bp=0


  --exit
  re=0
  ge=243
  be=0

  --infected person
  ri=243
  gi=243
  bi=0
  

rooms={
  }

loadRooms= function()
  room1={}
  room1.name='welcome'
  room1.imageData=love.image.newImageData('003.png')
  room1.pic=love.graphics.newImage(room1.imageData)
  
  table.insert(rooms,room1)
  room1={}
  room1.name='welcome'
  room1.imageData=love.image.newImageData('004.png')
  room1.pic=love.graphics.newImage(room1.imageData)
  
  table.insert(rooms,room1)
  
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




if love.system.getOS()=='Android' then
   dpiScl=love.window.getDPIScale()

   ww,wh=love.window.getMode()
   ww=ww/dpiScl
   wh=wh/dpiScl
 else
 
	ww=640
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






radColl=function(x1,y1,x2,y2,r)
  sqr=r*r
  sqw=(x1-x2)*(x1-x2)
  sqh=(y1-y2)*(y1-y2)
  if sqr>=(sqw+sqh) then
    return true
  end
  
  return false
end


--we check if there is a go in inhib distance
goInInhib=function(lx,ly)
  for i,go in ipairs(gos)
  do
    if radColl(go.x,go.y,lx,ly,mapDetectInhib) then
      return true
    end
  end
  
  return false
end

--we scan image of current room 
--yellow dot creates an infected go
-- red dot 
-- for dot detection, if other colored dot within inhib radius we dont take it
initRoom=function()
  nbInfected=0
  gos={}
  
  plyPositioned=false
  --go creation
  for i=0,(cvsw-1)
  do
    for j=0,(cvsh-1)
    do
      local r,g,b,a=roomCollisionMap:getPixel(i,j)
      
      --in image data , range is 0 1, our color constants are 0 to 255
      r=math.floor(r*255)
      g=math.floor(g*255)
      b=math.floor(b*255)
      
      
      if r==ri and g==gi and b==bi then
        --we have to check if no go was created for same colored spot
        if goInInhib(i,j)==false then
          --we can create an infected go !!!
          local created={x=i,y=j,dir='g',trail={  }}
          table.insert(gos,created)
          nbInfected=nbInfected+1
        end
      elseif r==rp and g==gp and b==bp and plyPositioned==false then
        px=i
        py=j
        plyPositioned=true
      end
    end
  end
  
  print('nb infected created '..nbInfected)

end


--we see if player position is in infection radius of a go trail
-- if yes we decrease health
checkInfection=function()
  for i,go in ipairs(gos)
  do
    for j,infection in ipairs(go.trail)
    do
--      {x=100,y=100,strength=initinfectionradius} 
      if radColl(px,py,infection.x,infection.y,infection.strength) then
        print('infection !')
        health=health-infectionStep
      end
    end
  end
end


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

--managed by init room ( red detection )
px = 100
py=100

--for stats and debug of load
nbInfected=0

--gos={
--	{x=50,y=100,dir='r',trail={ {x=100,y=100,strength=initinfectionradius} }},
--	{x=200,y=150,dir='g',trail={  }}
--}

initRoom()


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
love.graphics.print('plague '..dbgmsg,0,100)



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


  --in image data , range is 0 1, our color constants are 0 to 255
  r=math.floor(r*255)
  g=math.floor(g*255)
  b=math.floor(b*255)

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
  
  checkInfection()
  
	toapply=moves[1]
	if toapply~=nil then
	  tpx=px+toapply.dx
	  tpy=py+toapply.dy
     
     
    local r,g,b,a=roomCollisionMap:getPixel(tpx,tpy)
    dbgmsg ='tpx '..tpx..' tpy '..tpy..' r '..(r*255)..' g '..(g*255)..' b '..(b*255)
    
    
--    if a~=0 then
    if colorColl(tpx,tpy,rw,gw,bw) then
      --move not possible
      moves={}
            
    elseif colorColl(tpx,tpy,re,ge,be) then
      -- we check next level ( green ) here
      currentRoom=currentRoom+1
      setCurrentRoom(currentRoom)
      initRoom()
    else
      --otherwise we keep on moving
      px=tpx
      py=tpy
      table.remove(moves,1)

    end
     
     
	end

	updategos()
end