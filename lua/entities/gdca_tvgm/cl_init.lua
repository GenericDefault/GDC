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
	pos = self:GetPos()
	self.emitter = ParticleEmitter( pos )
 end
 
 function ENT:Think()
	
	pos = self:GetPos()
		for i=0, (5) do
			local particle = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + (self:GetUp() * -80 * i))
			if (particle) then
				particle:SetVelocity((self:GetUp() * -2000) )
				particle:SetDieTime( math.Rand( 5, 9 ) )
				particle:SetStartAlpha( math.Rand( 20, 30 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 60 )
				particle:SetEndSize( math.Rand( 240, 290 ) )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( 200 , 200 , 200 ) 
 				particle:SetAirResistance( 100 ) 
 				particle:SetGravity( VectorRand():GetNormalized()*math.Rand(50, 100) ) 
			end
		end
end
	