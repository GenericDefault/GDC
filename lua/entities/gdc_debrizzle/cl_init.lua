 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]]  
 function ENT:Draw()      
 // self.BaseClass.Draw(self)  
 -- We want to override rendering, so don't call baseclass.                                   
 // Use this when you need to add to the rendering.        
 self.Entity:DrawModel()       // Draw the model.   
 end  


  function ENT:Initialize()
	Position = self:GetPos()
	self.emitter = ParticleEmitter( Position )
	Size = math.Clamp(self.Entity:BoundingRadius()/70,0.4,1.7) or 1
 end
 
 function ENT:Think()
	if (CurTime() >= (self.NextRBUpdate or 0)) then
	self.NextRBUpdate = CurTime()+2
	Wire_UpdateRenderBounds(self.Entity)
	end

		Position = self:GetPos()

 			for i=1, 1 do 
			local particle1 = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), Position ) 
 			if (particle1) then 
 			particle1:SetVelocity( VectorRand() * math.Rand(200, 300) ) 
 			particle1:SetLifeTime( 0 ) 
 			particle1:SetDieTime( math.Rand(1, 7) ) 
 			particle1:SetStartAlpha( 140 ) 
 			particle1:SetEndAlpha( 0 ) 
 			particle1:SetStartSize( 70*Size ) 
 			particle1:SetEndSize( 250*Size ) 
			Smoka = math.random(60,65)			
 			particle1:SetColor( Smoka,Smoka,Smoka ) 			
 			particle1:SetRoll( math.Rand(0, 360) ) 
 			particle1:SetRollDelta( math.Rand(-1.5, 1.5) ) 
 			particle1:SetAirResistance( 200 ) 
 			particle1:SetGravity( Vector( math.Rand(0, 200), 0, 0 ) ) 
 			end  
 			end 

end
