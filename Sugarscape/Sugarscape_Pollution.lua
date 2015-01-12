--Sugarscape-Pollution rule by Friedrich Müller


-- from year 0-10 there is no pollution
-- from 10-30 the pollution should be the pollution value (=sugar value) of a cell + the metabolition value if there is an agent.7
-- from year 30 there should be a diffusion of pollution. 

-- Error in pollution distribution rule <-- has to be fixed
-- Agent act not as they should. Actually they should go to the sugar hot spots then after 10 years go to the outer regions and after the vision move again more in 
-- the inner region.

-------------------------------------------------------------------------------------------------------------creating sugarscape
-- random dependent on os time
math.randomseed(os.time())



--------------------------------------------------------------------------------- CellularSpace
cs = CellularSpace {
	xdim = 50,
	ydim = 50
}

--------------------------------------------------------------------------------- Neighborhood
cs:createNeighborhood{strategy = "vonneumann"}



--------------------------------------------------------------------------------- Spatial sugar distribution
forEachCell(cs, function(cell)

	cell.maxSugar = 0
	cell.sugar = 0
	cell.pollution=0
	cell.state=0
	cell.p_ratio=0
end)
cell = Cell{
	wealth = 0,
	age = 0,
	pollution = 0,
	state=0,
	sugar=0
}

cs:getCell(Coord{x = 11, y = 35}).maxSugar = 4
cs:getCell(Coord{x = 11, y = 35}).state = 4
cs:getCell(Coord{x = 36, y = 10}).maxSugar = 4
cs:getCell(Coord{x = 36, y = 10}).state = 4

for i = 1, 5 do
	cs:synchronize()
	forEachCell(cs, function(cell)
		forEachNeighbor(cell, function(cell, neighbor)
			if neighbor.past.maxSugar == 4 then
				cell.maxSugar = 4
				cell.state=4
			end
		end)
	end)
end

for i = 1, 6 do
	cs:synchronize()
	forEachCell(cs, function(cell)
		forEachNeighbor(cell, function(cell, neighbor)
			if neighbor.past.maxSugar >= 3 and cell.maxSugar == 0 then
				cell.maxSugar = 3
				cell.state=3
			end
		end)
	end)
end

for i = 1, 7 do
	cs:synchronize()
	forEachCell(cs, function(cell)
		forEachNeighbor(cell, function(cell, neighbor)
			if neighbor.past.maxSugar >= 2 and cell.maxSugar == 0 then
				cell.maxSugar = 2
				cell.state=2
			end
		end)
	end)
end

for i = 1, 10 do
	cs:synchronize()
	forEachCell(cs, function(cell)
		forEachNeighbor(cell, function(cell, neighbor)
			if neighbor.past.maxSugar >= 1 and cell.maxSugar == 0 then
				cell.maxSugar = 1
				cell.state=1
			end
		end)
	end)
end
-------------------------------------------------------------------------------------------------------------




--------------------------------------------------------------------------------- Legend
leg = Legend {
	grouping = "uniquevalue",
	colorBar = {
		{value = 0, color = "white"},
		{value = 4, color = "red"},
	}
}




--------------------------------------------------------------------------------- Observer
Observer {
	subject = cs,
	attributes = {"sugar"},
	legends = {leg},

}

--------------------------------------------------------------------------------- Sugar-Pollution ratio
-- define sugar/pollution ratio
forEachCell(cs,function(cell)
cell.p_ratio=cell.sugar/(1+cell.pollution)
end)


------------------------------------------------------------------------------------------------------------- Agent Bird
birds = Agent{

	age = 0,
	init = function(self)
		self.wealth = math.random(5, 25)
		self.metabolism = math.random(1, 2)
		self.maxAge = math.random(60, 100)
		self.pollution=0
	end,
	execute = function(self)

self:getCell().state=BIRD
bestOptions = {self:getCell()}



	bestOptions2 = {self:getCell()}	

-- if one neighbor has more sugar then bestOptions is the neigbor cell.
		
		
--vision
	vision=2
-- only the cells in east, west direction are considered within the vision area	
	forEachCell(cs, function(cell)
--exclude the current position cell
	if cell.x ~= self:getCell().x then
		if cell.x< self:getCell().x+vision and cell.x> self:getCell().x-vision then
	
			if cell.y==self:getCell().y then
		
-- defines the neighbor cell with the highest sugar value in bestOptions 	
				if cell.p_ratio > bestOptions[1].p_ratio then
				
					bestOptions = {cell}
				
-- if neighbor has equal sugar then the neigbor is saved in the array and get a own index number		
				elseif cell.p_ratio == bestOptions[1].p_ratio then
				
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
	
				if cell.p_ratio > bestOptions2[1].p_ratio  then
				
					bestOptions2 = {cell}--overwrites the old location with the neigbor cell
				
-- if neighbor has equal sugar then the neigbor is saved in the array and get an own index number		
				elseif cell.p_ratio == bestOptions2[1].p_ratio then
					bestOptions2[table.getn(bestOptions2)+1] = cell --getn, which returns the size of an array
			
				end
			
		
	
			end
		end
		end		
	end)
	
-- this choose a neighbor cell  randomly.
	bestOption2 = bestOptions2[math.random(table.getn(bestOptions2))]
	if season_time>1 then
		if bestOption1.p_ratio>bestOption2.p_ratio then
			self:move(bestOption1)-- the agent moves to the neigbor with the highest sugar, if there are more equal high sugar value cells the movement is randomly.
		else
			self:move(bestOption2)
		end
		
		if bestOption1.p_ratio==bestOption2.p_ratio then

		
			bestOptionChoice = {bestOption1, bestOption2}
			bestOption3 = bestOptionChoice[math.random(table.getn(bestOptionChoice))]
			self:move(bestOption3)
		end
	end
		
		self.age = self.age + 1 --agent age increase
		self.wealth = self.wealth - self.metabolism + self:getCell().sugar
		self.pollution=self.metabolism/8
-- the pollution of a cell is the sum of the produced agent pollution
	    if season_time>=10 and season_time<30 then
		self:getCell().pollution= self:getCell().pollution+ self.pollution
		self:getCell().p_ratio= self:getCell().sugar/(1+self:getCell().pollution)
		end
		
		self:getCell().sugar = 0

	if self.age > self.maxAge or self.wealth <= 0 then

	self:die()
		end
		
	end
}


-------------------------------------------------------------------------------------------------------------		AGENT BEAR
bears  = Agent{
	age = 0,
	init = function(self)
		self.wealth = math.random(5, 25)
		self.metabolism = math.random(1, 4)
		self.maxAge = math.random(60, 100)
		self.pollution=0
	
	end,
 execute = function(self)

	self:getCell().state= BEAR
	bestOptions_b = {self:getCell()}
	bestOptions2 = {self:getCell()}	

-- if one neighbor has more sugar then bestOptions is the neigbor cell.
		
		
--vision
	vision=2
-- only the cells in east, west direction are considered within the vision area	
	forEachCell(cs, function(cell)
--exclude the current position cell
	if cell.x ~= self:getCell().x then
		if cell.x< self:getCell().x+vision and cell.x> self:getCell().x-vision then
	
			if cell.y==self:getCell().y then
		
-- defines the neighbor cell with the highest sugar value in bestOptions 	
				if cell.p_ratio > bestOptions[1].p_ratio then
				
					bestOptions = {cell}
				
-- if neighbor has equal sugar then the neigbor is saved in the array and get a own index number		
				elseif cell.p_ratio == bestOptions[1].p_ratio then
				
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
	
				if cell.p_ratio > bestOptions2[1].p_ratio  then
				
					bestOptions2 = {cell}--overwrites the old location with the neigbor cell
				
-- if neighbor has equal sugar then the neigbor is saved in the array and get an own index number		
				elseif cell.p_ratio == bestOptions2[1].p_ratio then
					bestOptions2[table.getn(bestOptions2)+1] = cell --getn, which returns the size of an array
			
				end
			
		
	
			end
		end
		end		
	end)
	
-- this choose a neighbor cell  randomly.
	bestOption2 = bestOptions2[math.random(table.getn(bestOptions2))]
	if season_time>1 then
		if bestOption1.p_ratio>bestOption2.p_ratio then
			self:move(bestOption1)-- the agent moves to the neigbor with the highest sugar, if there are more equal high sugar value cells the movement is randomly.
		else
			self:move(bestOption2)
		end
		
		if bestOption1.p_ratio==bestOption2.p_ratio then

		
			bestOptionChoice = {bestOption1, bestOption2}
			bestOption3 = bestOptionChoice[math.random(table.getn(bestOptionChoice))]
			self:move(bestOption3)
		end
	end
		
		self.age = self.age + 1 --agent age increase
		self.wealth = self.wealth - self.metabolism + self:getCell().sugar
		self.pollution=self.metabolism/8
		if season_time>=10 and season_time<30 then
		self:getCell().pollution= self:getCell().pollution+ self.pollution
		self:getCell().p_ratio= self:getCell().sugar/(1+self:getCell().pollution)
		end
		
		
		
		
		
		
		self:getCell().sugar = 0

	if self.age > self.maxAge or self.wealth <= 0 then

	self:die()
		end
		
	end
}


--------------------------------------------------------------------------------- Society
n_birds=20
soc_birds = Society{
	instance = birds,
	quantity =n_birds
}

n_bears=20
soc_bears = Society{
	instance = bears,
	quantity =n_bears
}



--------------------------------------------------------------------------------- Environment

e = Environment{cs, soc_birds,soc_bears}


e:createPlacement{
strategy = "random"}










	
	
    
-- diffusion pollution rule for time=30
-- The new pollution value of a cell is calculated by the average pollution of the neighbors.
-- calculating average values
updateCell = function()
	cell.wealth = 0
	cell.age = 0
	
	
	if season_time==30 then

		forEachCell(cs, function(cell)
			sumPollution=0

				forEachNeighbor(cell, function(cell,neighbor)

					sumPollution= sumPollution+neighbor.pollution

				end)


				averagePollution=sumPollution/4

				cell.pollution=averagePollution
				cell.p_ratio=cell.sugar/(1+cell.pollution)

		end)

	end	
	

	
	forEachAgent(soc_birds, function(agent)
		cell.age = cell.age + agent.age
		cell.wealth = cell.wealth + agent.wealth
	
	    cell.state=BIRD

		cell.age = cell.age / soc_birds:size()
		cell.wealth = cell.wealth / soc_birds:size()
	end)
	forEachAgent(soc_bears, function(agent)
		cell.age = cell.age + agent.age
		cell.wealth = cell.wealth + agent.wealth
	    cell.state=BEAR
		cell.age = cell.age / soc_bears:size()
		cell.wealth = cell.wealth / soc_bears:size()

	end)

	
end



--------------------------------------------------------------------------------- Observer

Observer{
	subject = cell,
	type = "chart",
	attributes = {"age", "wealth","pollution"},
	curveLabels = {"age", "wealth"}
}


---sugar growback rule
growSugar = function()
	forEachCell(cs, function(cell)
			if cell.sugar < cell.maxSugar then
				cell.sugar = cell.sugar+1
			end
	end)
end





--------------------------------------------------------------------------------- Timer
season_time=0
t = Timer{

	Event{action = function()
	growSugar()
	season_time=season_time+1
	--print(season_time)
	end},
	Event{action = soc_birds},
	Event{action = soc_bears},
	Event{action = updateCell},
	Event{action = pollutionSeason},
	Event{action = cs},
	Event{action = cell}
	
}

t:execute(150 )

