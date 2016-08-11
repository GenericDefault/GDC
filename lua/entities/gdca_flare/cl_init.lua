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
		for i=1, 1 do
			local particle = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos)
			if (particle) then
				particle:SetVelocity(self:GetUp() )
				particle:SetDieTime( math.Rand( 3, 7 ) )
				particle:SetStartAlpha( math.Rand( 40, 50 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 50 )
				particle:SetEndSize( math.Rand( 300, 350 ) )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( 230 , 230 , 230 ) 
 				particle:SetAirResistance( 100 ) 
 				particle:SetGravity( VectorRand():GetNormalized()*math.Rand(50, 200) ) 	
			end

			for i=1, 2 do
				local particle = self.emitter:Add( "effects/fire_cloud1", pos )
				particle:SetVelocity(self:GetUp() )
				particle:SetDieTime( 0.15 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 50 )
				particle:SetEndSize( math.Rand( 55, 65 ) )
				particle:SetRoll( math.Rand( -5, 5 ) )
				particle:SetRollDelta( 0 )
				particle:SetAirResistance(10)
				particle:SetColor( 255,255,255 )

		end
		
	end

end