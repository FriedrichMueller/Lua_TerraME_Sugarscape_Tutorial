--Sugarscape-Reproduction rule  by Friedrich Müller
---different agent types man/female
---start at certain region
---reproduction of agents
		--random gender
		--the agent is placed to a free neighbor cell of a female or a man.
--- inheritance of agents.
    -- if an agent dies then
    -- the wealth of an child increase half of the parents wealth (at moment of the creation) if one of the parents die.

-- random dependent on os time
math.randomseed(os.time())






--------------------------------------------------------------------------------- Cell
cell = Cell{
	wealth = 0,
	age = 0
}



--------------------------------------------------------------------------------- Cellularspace
cs = CellularSpace {
	xdim = 50,
	ydim = 50
}
--------------------------------------------------------------------------------- Neighborhood
cs:createNeighborhood{strategy = "vonneumann"}



forEachCell(cs, function(cell)
	cell.maxSugar = 0
	cell.sugar = 0
	cell.state=0
	cell.name="EMPTY"
end)
--------------------------------------------------------------------------------- Creating spatial distribution

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





--------------------------------------------------------------------------------- LEGEND

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






--------------------------------------------------------------------------------------------------------------------- Agent

-- Agent female high vision, low metabolism

countID=0
countID2=0
childCount=0
ID1=0
ID2=0
INHERITANCE=0


females = Agent{

	age = 0,
	init = function(self)
		self.wealth = math.random(5, 25)
		self.wealthStart=self.wealth
		self.metabolism = math.random(1, 2)
		self.maxAge = math.random(60, 100)
		self.sugar=4
		self.name="female"
		self.inheritance=0
		self.id= 0
		self.childs=0
	end,
	execute = function(self)
		self:getCell().name="female"
		self:getCell().age=self.age


--bestOptions is cell where the agent is located
		bestOptions = {self:getCell()}
	
		-- vision in N,S,E,W direction
		-- 
		--condition for the east , west direction vision cells
		vision=5
		forEachCell(cs, function(cell)
			if cell.x< self:getCell().x+vision and cell.x> self:getCell().x-vision then
		  		 if cell.y==self:getCell().y then
		
-- defines the neighbor cell with the highest sugar value in bestOptions 	
					if cell.sugar > bestOptions[1].sugar then
				
						bestOptions = {cell}--overwrites the old location with the neigbor cell
				
-- if neighbor has equal sugar then the neigbor it is saved in the array and get an own index number		
					elseif cell.sugar == bestOptions[1].sugar then
						bestOptions[table.getn(bestOptions)+1] = cell --getn, which returns the size of an array
				
					end
			
				end	
			end	
		end)
-- this choose a neighbor cell  randomly.
		bestOption1 = bestOptions[math.random(table.getn(bestOptions))]
	
		
	
--condition for the north , south direction vision cells
	forEachCell(cs, function(cell)
		if cell.y< self:getCell().y+vision and cell.y> self:getCell().y-vision then
		   if cell.x==self:getCell().x then
		
-- defines the neighbor cell with the highest sugar value in bestOptions 
			
				if cell.sugar > bestOptions[1].sugar  then
					
					bestOptions = {cell}--overwrites the old location with the neigbor cell
					
-- if neighbor has equal sugar then the neigbor is saved in the array and get a own index number		
				elseif cell.sugar == bestOptions[1].sugar then
					bestOptions[table.getn(bestOptions)+1] = cell --getn, which returns the size of an array
					
				end
			
			end
		end		
	end)
	
	
        -- this choose a neighbor cell  randomly.
		bestOption2 = bestOptions[math.random(table.getn(bestOptions))]
			if season_time>1 then
				if bestOption1.sugar>bestOption2.sugar then
	
					self:getCell().name="EMPTY"
					self:move(bestOption1)-- the agent moves to the neigbor with the highest sugar, if there are more equal high sugar value cells the movement is randomly.		
					self:getCell().name="female"
				else
	
					self:getCell().name="EMPTY"
					self:move(bestOption2)
					self:getCell().name="female"
	
				end
			if bestOption1==bestOption2 then
				bestOptionChoice = {bestOption1, bestOption2}
				bestOption3 = bestOptionChoice[math.random(table.getn(bestOptionChoice))]
	
				self:getCell().name="EMPTY"
				self:move(bestOption3)	
				self:getCell().name="female"
			end
			end
		
		self.age = self.age + 1 --agent age increase
		self.wealth = self.wealth - self.metabolism + self:getCell().sugar
		self:getCell().sugar = 0
		
	end
}


-------------------------------------------------------------------------------------------------------------------------
men  = Agent{
	age = 0,
	init = function(self)
		self.wealth = math.random(5, 25)
		self.metabolism = math.random(1, 4)
		self.maxAge = math.random(60, 100)
		self.name="man"
	    self.inheritance=0
	    self.id=0
	    self.dad=0
	    self.mum=0
	    self.childs=0
	end,
	execute = function(self)
	
	
		self:getCell().name="man"	
		bestOptions = {self:getCell()}

		-- vision in N,S,E,W direction
		-- 
		--condition for the east , west direction vision cells
		vision_man=2
			forEachCell(cs, function(cell)
				if cell.x< self:getCell().x+vision_man and cell.x> self:getCell().x-vision_man then
		  	   		 if cell.y==self:getCell().y then
		
		-- defines the neighbor cell with the highest sugar value in bestOptions 	
						if cell.sugar > bestOptions[1].sugar then
				
							bestOptions = {cell}--overwrites the old location with the neigbor cell
				
		-- if neighbor has equal sugar then the neigbor is saved in the array and get a own index number		
						elseif cell.sugar == bestOptions[1].sugar then
							bestOptions[table.getn(bestOptions)+1] = cell --getn, which returns the size of an array
			
						end
	
					end	
				end	--print(neighbor.sugar)
			end)
        -- this choose a neighbor cell  randomly.
		bestOption1 = bestOptions[math.random(table.getn(bestOptions))]
	
		
	
	--condition for the north , south direction vision cells
		forEachCell(cs, function(cell)
				if cell.y< self:getCell().y+vision_man and cell.y> self:getCell().y-vision_man then
		  			 if cell.x==self:getCell().x then
		
		-- defines the neighbor cell with the highest sugar value in bestOptions 
			
					if cell.sugar > bestOptions[1].sugar  then
				
						bestOptions = {cell}--overwrites the old location with the neigbor cell
				
		-- if neighbor has equal sugar then the neigbor is saved in the array and get a own index number		
					elseif cell.sugar == bestOptions[1].sugar then
						bestOptions[table.getn(bestOptions)+1] = cell --getn, which returns the size of an array
				
					end
			
					end
				end		
		end)
        -- this choose a neighbor cell  randomly.
		bestOption2 = bestOptions[math.random(table.getn(bestOptions))]
		if season_time>1 then
			if bestOption1.sugar>bestOption2.sugar then
	
				self:getCell().name="EMPTY"
				self:move(bestOption1)-- the agent moves to the neigbor with the highest sugar, if there are more equal high sugar value cells the movement is randomly.		
				self:getCell().name="man"
			else
	
				self:getCell().name="EMPTY"
				self:move(bestOption2)
				self:getCell().name="man"
	
			end
			if bestOption1==bestOption2 then
				bestOptionChoice = {bestOption1, bestOption2}
				bestOption3 = bestOptionChoice[math.random(table.getn(bestOptionChoice))]
				self:getCell().name="EMPTY"
				self:move(bestOption3)
				self:getCell().name="man"
			end
		end
		
		
		self.age = self.age + 1 --agent age increase
		self.wealth = self.wealth - self.metabolism + self:getCell().sugar
		self:getCell().sugar = 0
------------------------------------------------------------------------------------------------------------------------------------- Reproduction	

   count=0
   neighborchoice={}

INHERITANCE1=0 
INHERITANCE2=0 


forEachNeighbor(self:getCell(), function(cell, neigh)
	if neigh.name=="female" and self:getCell().name=="man" then 
  
    forEachAgent(self:getCell(), function(self)
    	INHERITANCE1=self.wealth
  
	    if self.id==0 and self.name=="man" then
	    	self.id=countID
	    	countID=countID+1
	    	ID1=self.id
	  
	    end
end)
    
--female agent id and inheritance   
   forEachAgent(neigh, function(agent)
    
   	if agent.id==0 then
    	agent.id=countID2
    	countID2=countID2+1

   	end
    ID2=agent.id
    INHERITANCE2=agent.wealth 
    end)
    
   
    INHERITANCE= (INHERITANCE1+INHERITANCE2)/2

	
	reproductionProbability=math.random(0,1)
	
	if reproductionProbability == 0 then
		forEachAgent(neigh, function(agent)
    		if agent.name == "female" then
    
   
   
				son= agent:reproduce{age=0,dad=ID1,mum=ID2,inheritance=INHERITANCE}
				son.inheritance=INHERITANCE

    		end
    	end)
    
    else
    
    
    son = self:reproduce{age=0,inheritance=INHERITANCE,dad=ID1,mum=ID2}
    


	end

	count=count+1
	
	-- if all neigbors of the cell are occupied
	if count==4 then
		forEachNeighbor(neigh, function(cell, neighbor)
    		if neighbor.name=="EMPTY"  then
	
				neighborchoice[table.getn(neighborchoice)+1]=neigh
   
				son:enter(neighborchoice[math.random(table.getn(neighborchoice))])
			end
		end)
	end
	
	
	
	
	
	
	
	
	
	if neigh.name=="EMPTY" and count>0 then

		neighborchoice[table.getn(neighborchoice)+1]=neigh
   
		son:enter(neighborchoice[math.random(table.getn(neighborchoice))])
	
	end

end

end)











------------------------------------------------------------------------------------------------------------------------------------------------  Inheritance

	
IDinheritance=0		

if self.age > self.maxAge or self.wealth <= 0 then
	
	IDinheritance=self.id                             --Death cell ID

	self:die()										  -- Agent dies
	
	childcount=0
	forEachCell(cs, function(cell)
		forEachAgent(cell,function(agent)
			if agent.mum== IDinheritance then
				childcount=childcount+1				  -- counting of child where the id was father or mother
			end
			if agent.dad== IDinheritance then
				childcount=childcount+1
			end
		end)
	end)
	
	forEachCell(cs, function(cell)	
		forEachAgent(cell,function(agent)
			if agent.mum ~=0 and agent.dad~=0 then
				if agent.mum== IDinheritance then
					print("Number of childs"..childcount)
					print("Inheritance value"..agent.inheritance)
					print("Wealth of child"..agent.wealth)
					agent.wealth= agent.wealth+agent.inheritance/childcount			-- looking for childs and adding the inheritance
					print("Added inheritance"..agent.wealth)
				end
				if agent.dad== IDinheritance then
					agent.wealth= agent.wealth+agent.inheritance/childcount
				end
	
			end
		end)
	end)
end
	
	
	
end
		
------------------------------------------------------------------------------------------------------------------------------------------------  SOCIETY	
}

n_females=5
soc_females = Society{
	instance = females,
	quantity =n_females
}

n_men=5
soc_men = Society{
	instance = men,
	quantity =n_men
}


------------------------------------------------------------------------------------------------------------------------------------------------  Environment

x1=0
y1=49
e = Environment{cs, soc_females,soc_men}

e:createPlacement{strategy = "void"}




forEachAgent(soc_females, function(agent)

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

x1=15
y1=46
forEachAgent(soc_men, function(agent)
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


	
	
-- calculating average values
updateCell = function()
	cell.wealth = 0
	cell.age = 0
	forEachAgent(soc_females, function(agent)
		cell.age = cell.age + agent.age
		cell.wealth = cell.wealth + agent.wealth
	
	cell.age = cell.age / soc_females:size()
	cell.wealth = cell.wealth / soc_females:size()
	end)
	forEachAgent(soc_men, function(agent)
		cell.age = cell.age + agent.age
		cell.wealth = cell.wealth + agent.wealth
	
	cell.age = cell.age / soc_men:size()
	cell.wealth = cell.wealth / soc_men:size()
	end)

	
end


------------------------------------------------------------------------------------------------------------------------------------------------  Observer
Observer{
	subject = cell,
	type = "chart",
	attributes = {"age", "wealth"},
	curveLabels = {"age", "wealth"}
}



growSugar = function()
	forEachCell(cs, function(cell)
		if cell.sugar < cell.maxSugar then
			cell.sugar = cell.sugar + 1
		end
	end)
end	
	


--giving out number of men and female agents
femalecount=0
mancount=0
summary=function()

if  season_time/2==1 then
forEachCell(cs, function(cell)
forEachAgent(cell,function(agent)
if agent.name=="man" then
mancount=mancount+1

elseif agent.name=="female" then
femalecount=femalecount+1

end
end)
end)
print("men:"..mancount)
print("females"..femalecount)
end

if season_time==20 then
season_time=0
end	

end


------------------------------------------------------------------------------------------------------------------------------------------------  Timer	
season_time=0
t = Timer{

	Event{action = function()
	growSugar()
	season_time=season_time+1
	end},
	Event{action = soc_females},
	Event{action = summary},
	Event{action = soc_men},
	Event{action = updateCell},
	Event{action = cs},
	Event{action = cell}
	
}

t:execute(100)

