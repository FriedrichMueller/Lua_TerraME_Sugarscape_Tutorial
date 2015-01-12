--Sugarscape-Culture rule  by Friedrich Müller
-- Cultural behaviour each agent has a string with 1s and 0s. 
-- Everytime a bird agent meets a bear agent  a bird change a random character of the string if it is different to the bear string is changed into the bear string character at the selected place


-- random dependent on os time
math.randomseed(os.time())


-- variables for color distribution
BLUE=5
GREEN=6
RED=7



--------------------------------------------------------------------------------- Cellularspace
-- defining the Cellularspace
cs = CellularSpace {
	xdim = 50,
	ydim = 50
}

--------------------------------------------------------------------------------- Neighborhood
-- defining von Neumann neighborhood
cs:createNeighborhood{strategy = "vonneumann"}





--------------------------------------------------------------------------------- Creating spatial distribution


-- defining attributes
forEachCell(cs, function(cell)
	cell.maxSugar = 0
	cell.sugar = 0
	cell.pollution=0
	cell.state=0
	cell.name="EMPTY"
	cell.p_ratio=0
	cell.name="EMPTY"
	cell.age=0
	cell.wealthStart=0
end)



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






--------------------------------------------------------------------------------- Legend
leg = Legend {
	grouping = "uniquevalue",
	colorBar = {
		{value = 0, color = "white"},
		{value = 1, color = "yellow"},
		{value = 2, color = "white"},
		{value = 3, color = "yellow"},
		{value = 4, color = "white"},	
		{value = 5, color = "blue"},
		{value = 6, color = "green"},
		{value = 7, color = "red"}
		
	}
}

--------------------------------------------------------------------------------- Observer
Observer {
	subject = cs,
	attributes = {"state"},
	legends = {leg}
}






--------------------------------------------------------------------------------------------------------------------- Agent

-- Agent bird high vision, low metabolism

--help variables
countID=0
countID2=0
childCount=0
ID1=0
ID2=0



birds = Agent{

	age = 0,
	init = function(self)
		self.wealth = math.random(5, 25)
		self.metabolism = math.random(1, 2)
		self.maxAge = math.random(60, 100)
		self.name="bird"
		self.culture= "11111110100"
		--self.culture= "10000100100"
		self.state=5
	end,
	execute = function(self)
	
	self:getCell().name="BIRD"
	self:getCell().age=self.age
	self:getCell().state=self.state
--bestOptions is cell where the agent is located
	bestOptions = {self:getCell()}
	bestOptions2 = {self:getCell()}	

-- if one neighbor has more sugar then bestOptions is the neigbor cell.
		
		
--vision
	vision=3
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
	
				self:getCell().name="EMPTY"
				self:getCell().state=self:getCell().maxSugar
				self:move(bestOption1)-- the agent moves to the neigbor with the highest sugar, if there are more equal high sugar value cells the movement is randomly.		
			    self:getCell().state=self.state
				self:getCell().name="BIRD"
			else
	
				self:getCell().name="EMPTY"
				self:getCell().state=self:getCell().maxSugar
				self:move(bestOption2)
				self:getCell().state=self.state
				self:getCell().name="BIRD"
			
			end
			
			if bestOption1.sugar==bestOption2.sugar then
				bestOptionChoice = {bestOption1, bestOption2}
				bestOption3 = bestOptionChoice[math.random(table.getn(bestOptionChoice))]
		
				self:getCell().name="EMPTY"
				self:getCell().state=self:getCell().maxSugar		
				self:move(bestOption3)
				self:getCell().state=self.state
				self:getCell().name="BIRD"
			end
		end
		
		self.age = self.age + 1 --agent age increase
		self.wealth = self.wealth - self.metabolism + self:getCell().sugar
		self:getCell().sugar = 0


		
	end
}


------------------------------------------------------------------------------------------------------------------------- Bear
bears  = Agent{
	age = 0,
	init = function(self)
		self.wealth = math.random(5, 25)
		self.metabolism = math.random(1, 4)
		self.maxAge = math.random(60, 100)
		self.name="bear"
	    self.culture= "10011010011"
	    self.state=6
	end,
	execute = function(self)
	self:getCell().name="BEAR"	
	self:getCell().wealthStart=self.wealthStart
	
	bestOptions = {self:getCell()}
	self:getCell().state=self.state
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
		
			


------------------------------------------------------------------------------------------------------------------------------------------ CULTURE Transmission rule


-- function that counts the appearance of a character within a string
------------------- 
	function char_count(str, char) 
	    if not str then
	        return 0
	    end
	
	    local count = 0 
	    local byte_char = string.byte(char)
	    for i = 1, #str do
	        if string.byte(str, i) == byte_char then
	            count = count + 1 
	        end 
	    end 
	    return count
	end
---------- Source: http://amix.dk/blog/post/19462

-- function that replace a character with a predefined value within a string at a certain place 
	function replaceChar(str,idx,rep)
	    local pat
	    if idx==1 then
	        pat="^.(.*)$"
	        return string.gsub(str,pat,rep.."%1") 
	    else
	        pat="^(" .. ("."):rep(idx-1) .. ").(.*)$"
	        return string.gsub(str,pat,"%1"..rep.."%2")
	    end
	end
---------- Source: http://forum.luahub.com/index.php?topic=2646.0






-- culture time is  the time a agent stays at his current culture and don't change to another
	culturetime=0
	
	forEachNeighbor(self:getCell(), function(cell, neigh)
		place= math.random(1,string.len(self.culture))
		string_bear=string.sub(self.culture, place,place)
		if neigh.name=="BIRD" then
			forEachAgent(neigh,function(agent)
				if agent.name=="bird" then
					test=agent.culture
					string_bird=string.sub(test, place,place)
	
	
						if string_bird ~=string_bear and season_time>culturetime then
							print(string_bird)
							print(string_bear)
							x=tostring(string_bear)
							check=replaceChar(test,place,x)
							culturetime=season_time+1
							print("Change CULTURE")
							print(test,check)
							agent.culture=check
						end
	
				colorcheck= char_count(check, 0)
					if colorcheck<=3 then
						agent.state=BLUE
						agent:getCell().state=BLUE
	
					elseif colorcheck >=4 and colorcheck<=7 then
						agent.state=GREEN
						agent:getCell().state=GREEN
					else
						agent.state=RED
						agent:getCell().state=RED
					end
				colorcheck=0
				end
			end)
		end
	end)	
 end
}


--------------------------------------------------------------------------------- Society



-- creating a society of birds 
n_birds=3
soc_birds = Society{
	instance = birds,
	quantity =n_birds
}
-- creating a society of bears
n_bears=1
soc_bears = Society{
	instance = bears,
	quantity =n_bears
}



z=0
x1=0
y1=49
--------------------------------------------------------------------------------- Environment
-- creating an environment composed by cellularspace and societies
e = Environment{cs, soc_birds,soc_bears}



-- create placement strategy
e:createPlacement{strategy = "void"}


forEachAgent(soc_birds, function(agent)
	if x1==0 then
		x1=0
		y1=y1-1
	end
	c = Coord{x = x1, y = y1}
	f = {cs:getCell(c)}
	agent:enter(f[table.getn(f)])
	agent:getCell()
	x1=x1+1
end)

x1=15
y1=46
forEachAgent(soc_bears, function(agent)
	if x1==10 then
		x1=0
		y1=y1-1
	end
	c = Coord{x = x1, y = y1}
	f = {cs:getCell(c)}
	agent:enter(f[table.getn(f)])
	agent:getCell()
	x1=x1+1
end)


	
-- sugar regrow rule of the cells
growSugar = function()
	forEachCell(cs, function(cell)
		if cell.sugar < cell.maxSugar then
			cell.sugar = cell.sugar + 1
			cell.state=cell.maxSugar 
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
	Event{action = soc_bears},
	Event{action = updateCell},
	Event{action = cs},
	Event{action = cell}
	
}

t:execute(100)

