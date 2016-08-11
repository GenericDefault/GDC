include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]]  
 
 local matFire			= Material( "effects/fire_cloud1" ) 
 local matHeatWave		= Material( "sprites/heatwave" )
 
 function ENT:Draw()      
 // self.BaseClass.Draw(self)  
 -- We want to override rendering, so don't call baseclass.                                   
 // Use this when you need to add to the rendering. 
 
 self.Entity:DrawModel()       // Draw the model.  
Wire_Render(self.Entity) 
if !self:GetNetworkedBool("fire") then return end
	self:EffectDraw_fire()
 end 
 
 function ENT:DrawTranslucent()
	
 end
 
 function ENT:EffectDraw_fire() --adapted from the garry thruster. Helps blend the fire effect near the barrel.
	
	
	
 	local vOffset = self:GetPos() + self:GetUp()* 30 
 	local vNormal = self:GetUp()
   
 	local scroll =  (CurTime() * -10) 
 	 
 	local Scale = 2
 		 
 	render.SetMaterial( matFire ) 
 	 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 60 * Scale, 32 * Scale, scroll + 1, Color( 255, 255, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 148 * Scale, 32 * Scale, scroll + 3, Color( 255, 255, 255, 0) ) 
 	render.EndBeam() 
 	 
 	scroll = scroll * 0.5 
 	 
 	render.UpdateRefractTexture() 
 	render.SetMaterial( matHeatWave ) 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 32 * Scale, 32 * Scale, scroll + 2, Color( 255, 255, 255, 255) ) 
 		render.AddBeam( vOffset + vNormal * 128 * Scale, 48 * Scale, scroll + 5, Color( 0, 0, 0, 0) ) 
 	render.EndBeam() 
 	 
 	 
 	scroll = scroll * 1.3 
 	render.SetMaterial( matFire ) 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 60 * Scale, 16 * Scale, scroll + 1, Color( 255, 255, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 148 * Scale, 16 * Scale, scroll + 3, Color( 255, 255, 255, 0) ) 
 	render.EndBeam() 
 	 
 end 
 
  function ENT:Initialize()
	pos = self:GetPos()
	self.emitter = ParticleEmitter( pos )
 end
 
 function ENT:Think()
	if (CurTime() >= (self.NextRBUpdate or 0)) then
	self.NextRBUpdate = CurTime()+2
	Wire_UpdateRenderBounds(self.Entity)
	end


	if self:GetNetworkedBool("fire") then
		pos = self:GetPos()

	if self:GetNetworkedBool("hp") then

		for i=1, (8) do
		local particle = self.emitter:Add( "particles/flamelet"..math.random(1,5), pos +(i*70*self:GetUp()))
			if (particle) then
			particle:SetVelocity(self:GetUp() * 12000 + VectorRand():GetNormalized()*80 )
			particle:SetDieTime( math.Rand( 0.2, 0.3 ) )
			particle:SetStartAlpha( 230 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 30 )
			particle:SetEndSize( 250 )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-5, 5) )
			particle:SetColor( 255 , 255 , 255 )
			particle:SetAirResistance( 150 )
 			particle:SetGravity( Vector(0,0,10)*math.Rand(350, 500) ) 
			particle:SetCollide( true ) 
 			//particle:SetBounce( 0.01 ) 
			end
		end


		for i=1, (8) do
		local particle = self.emitter:Add( "particles/flamelet"..math.random(1,5), pos +((i-1)*80*self:GetUp()))
			if (particle) then
			particle:SetVelocity(self:GetUp() * math.Rand(500, 1000) * i )
			particle:SetDieTime( math.Rand( 0.3, 0.5 ) )
			particle:SetStartAlpha( 200 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 10 + (i*10) )
			particle:SetEndSize( 50 + (i*20) )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-5, 5) )
			particle:SetColor( 255 , 255 , 255 )
			particle:SetAirResistance( 200 )
 			particle:SetGravity( Vector(0,0,5)*math.Rand(200, 400) ) 
			particle:SetCollide( true ) 
 			//particle:SetBounce( 0.01 ) 
			end
		end

			else // This switches the high pressure check


		for i=1, (8) do
		local particle = self.emitter:Add( "particles/flamelet"..math.random(1,5), pos +(i*100*self:GetUp()))
			if (particle) then
			particle:SetVelocity(self:GetUp() * 5000 + VectorRand():GetNormalized()*100 )
			particle:SetDieTime( math.Rand( 0.2, 0.3 ) )
			particle:SetStartAlpha( 230 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 20 )
			particle:SetEndSize( 160 )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-5, 5) )
			particle:SetColor( 255 , 255 , 255 )
			particle:SetAirResistance( 150 )
 			particle:SetGravity( Vector(0,0,10)*math.Rand(350, 500) ) 
			particle:SetCollide( true ) 
 			//particle:SetBounce( 0.01 ) 
			end
		end


		for i=1, (6) do
		local particle = self.emitter:Add( "particles/flamelet"..math.random(1,5), pos +((i-1)*80*self:GetUp()))
			if (particle) then
			particle:SetVelocity(self:GetUp() * math.Rand(500, 1000) * i )
			particle:SetDieTime( math.Rand( 0.3, 0.5 ) )
			particle:SetStartAlpha( 200 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 5 + (i*10) )
			particle:SetEndSize( 30 + (i*15) )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-5, 5) )
			particle:SetColor( 255 , 255 , 255 )
			particle:SetAirResistance( 200 )
 			particle:SetGravity( Vector(0,0,5)*math.Rand(200, 400) ) 
			particle:SetCollide( true ) 
 			//particle:SetBounce( 0.01 ) 
			end
		end


		end 	// Ends the high pressure check
	end		// Ends the Fire check


end
