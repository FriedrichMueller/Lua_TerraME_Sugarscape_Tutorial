--Sugarscape-Migration rule 3 by Friedrich Müller
--Example of random distributed agents within a seasonal sugar regrowth environment


-- random dependent on os time
math.randomseed(os.time())






--------------------------------------------------------------------------------- CellularSpace
-- database connection
cs = CellularSpace {
	database = "c:\\sugarscape.mdb",
	theme = "sugarscape",
	select = {"maxSugar", "sugar"}
	
}



--------------------------------------------------------------------------------- Neighborhood
cs:createNeighborhood{strategy = "vonneumann"}





--------------------------------------------------------------------------------- Legend
leg = Legend {
	slices = 5,
	colorBar = {
		{value = 0, color = "white"},
		{value = 4, color = "red"}
	}
}
--------------------------------------------------------------------------------- Observer
Observer {
	subject = cs,
	attributes = {"sugar"},
	legends = {leg}
}


--------------------------------------------------------------------------------- Agent
birds = Agent{

	age = 0,
	init = function(self)
		self.wealth = math.random(5, 25)
		self.metabolism =3
		self.maxAge = math.random(200)
	end,
	execute = function(self)
	bestOptions = {self:getCell()}
	bestOptions2 = {self:getCell()}	

-- if one neighbor has more sugar then bestOptions is the neigbor cell.
		
		
--vision
	vision=20
-- only the cells in east, west direction are considered within the vision area	
	forEachCell(cs, function(cell)
--exclude the current position cell
	if cell.x ~= self:getCell().x then
		if cell.x< self:getCell().x+vision and cell.x> self:getCell().x-vision then
	
			if cell.y==self:getCell().y then
		
-- defines the neighbor cell with the highest sugar value in bestOptions 	
				if cell.sugar > bestOptions[1].sugar then
				
					bestOptions = {cell}--overwrites the old location with the neigbor cell
				
-- if neighbor has equal sugar then the neigbor is saved in the array and get a own index number		
				elseif cell.sugar == bestOptions[1].sugar then
				
					bestOptions[table.getn(bestOptions)+1] = cell --getn, which returns the size of an array
			
				end
			end	
		end	
		end
	end)
-- this choose a neighbor cell  randomly.
	bestOption1 = bestOptions[math.random(table.getn(bestOptions))]
	

		
-- N,S vision cell area	
	
	forEachCell(cs, function(cell)
--exclude the current position cell
	        if cell.y ~= self:getCell().y then
		if cell.y< self:getCell().y+vision and cell.y> self:getCell().y-vision then
		    
			if cell.x==self:getCell().x then
		
-- defines the neighbor cell with the highest sugar value in bestOptions 
	
				if cell.sugar > bestOptions2[1].sugar  then
				
					bestOptions2 = {cell}--overwrites the old location with the neigbor cell
				
-- if neighbor has equal sugar then the neigbor is saved in the array and get an own index number		
				elseif cell.sugar == bestOptions2[1].sugar then
					bestOptions2[table.getn(bestOptions2)+1] = cell --getn, which returns the size of an array
			
				end
			
		
	
			end
		end
		end		
	end)
	
-- this choose a neighbor cell  randomly.
	bestOption2 = bestOptions2[math.random(table.getn(bestOptions2))]
	if season_time>1 then
		if bestOption1.sugar>bestOption2.sugar then
			self:move(bestOption1)-- the agent moves to the neigbor with the highest sugar, if there are more equal high sugar value cells the movement is randomly.
		else
			self:move(bestOption2)
		end
		
		if bestOption1.sugar==bestOption2.sugar then

		
			bestOptionChoice = {bestOption1, bestOption2}
			bestOption3 = bestOptionChoice[math.random(table.getn(bestOptionChoice))]
			self:move(bestOption3)
		end
	end

	
	
			
	self.age = self.age + 1 --agent age increase
	self.wealth = self.wealth - self.metabolism + self:getCell().sugar
	self:getCell().sugar = 0

		
	--------------------------------------------------------------------------------------------------------  Birth and Death		
		
	if self.age > self.maxAge or self.wealth <= 0 then
	--		son = self:reproduce()		
	--		son:enter(cs:sample())
		self:die()
    end
-----------------------------------------------------------------------------------
					
  end
}





--------------------------------------------------------------------------------- Society
n_birds=100
soc_birds = Society{
	instance = birds,
	quantity =n_birds
}





--------------------------------------------------------------------------------- Environment
x1=0
y1=49
e = Environment{cs, soc_birds}

e:createPlacement{strategy = "random"}
	
    
cell = Cell{
	wealth = 0,
	age = 0
}
-- calcuating average values
updateCell = function()
	cell.wealth = 0
	cell.age = 0
	forEachAgent(soc_birds, function(agent)
		cell.age = cell.age + agent.age
		cell.wealth = cell.wealth + agent.wealth
	
	cell.age = cell.age / soc_birds:size()
	cell.wealth = cell.wealth / soc_birds:size()
	end)
	
end


--------------------------------------------------------------------------------- Observer
Observer{
	subject = cell,
	type = "chart",
	attributes = {"age", "wealth"},
	curveLabels = {"age", "wealth"}
}

--------------------------------------------------------------------------------- 
--seasonal sugar regrowth.
--equator liney=25
-- First season is summer in the north and winter in the south.
-- season region flip every 50 years
growSugar = function()
 
	forEachCell(cs, function(cell)
			
		if season_time<50 then
			if cell.y>= 25 then
		    	if cell.sugar < cell.maxSugar then
			  		cell.sugar = cell.sugar + 1/8
			 	 end
			 elseif cell.y< 25 then
				if cell.sugar < cell.maxSugar then
					cell.sugar = cell.sugar + 1
				end
		 	end
	   end
		
		if season_time>=50 then
			if cell.y>= 25 then
		    	if cell.sugar < cell.maxSugar then
					cell.sugar = cell.sugar + 1
		        end
		   elseif cell.y< 25 then
			    if cell.sugar < cell.maxSugar then
					cell.sugar = cell.sugar + 1/8
			    end
		   end
		end
				
		if season_time ==100 then
			season_time=0
		end
	    if cell.sugar > cell.maxSugar then
	 		cell.sugar=cell.maxSugar
	    end
	end)
end







--------------------------------------------------------------------------------- Timer
season_time=0
t = Timer{

	Event{action = function()
	growSugar()
	season_time=season_time+1
	end},
	Event{action = soc_birds},
	Event{action = updateCell},
	Event{action = cs},
	Event{action = cell}
	
}

t:execute(100)

