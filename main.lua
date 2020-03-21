cvsw=320
cvsh=200

--gameplay variables
initinfectionradius=10


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
sqspeed=64

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
	{x=100,y=100,dir='r',trail={ {x=100,y=100,strength=initinfectionradius} }},
	{x=150,y=150,dir='g',trail={  }}
}

updateinfectiontrail = function(go)
  for j,inf in ipairs(go.trail) 
  do
    inf.strength=inf.strength-1
    if inf.strength==0
    then
      table.remove(go.trail,j)
      
    end
  end
  
  table.insert(go.trail,{x=go.x,y=go.y,strength=initinfectionradius})
  
  
end

updategos= function()
    
  
	for i,go in ipairs(gos)
	do
		if go.dir=='r' then go.x=go.x+1 end
		if go.dir=='g' then go.x=go.x-1 end

		if go.dir=='r' and go.x>cvsw  then go.dir='g' end
		if go.dir=='g' and go.x<0  then go.dir='r' end
    
    updateinfectiontrail(go)
    
	  end
end


love.draw=function()
 
 love.graphics.setCanvas(cvs)
 love.graphics.clear()
 
 love.graphics.setColor(1.0,0.0,0.0,0.5)
 for i,go in ipairs(gos)
 do
   for j,inf in ipairs(go.trail)
    do
     love.graphics.circle('fill',inf.x,inf.y,inf.strength ) 
    end
  end
 
love.graphics.setColor(1.0,0.0,0.0,1.0)

for i,go in ipairs(gos)
do

	love.graphics.print('o',go.x,go.y)
  
end

love.graphics.setColor(1.0,1.0,1.0,1.0)
love.graphics.print('plague')



 love.graphics.print('x',px,py)
 love.graphics.setCanvas()

 love.graphics.draw(cvs,0,0,0,scrsx,scrsy)

end


love.mousepressed=function(x,y)
	calculatetraj(math.floor(x/scrsx),math.floor(y/scrsy),px,py)

end

love.update=function()
  
  
  
	toapply=moves[1]
	if toapply~=nil then
	   px=px+toapply.dx
	   py=py+toapply.dy
	   table.remove(moves,1)
	end

	updategos()
end