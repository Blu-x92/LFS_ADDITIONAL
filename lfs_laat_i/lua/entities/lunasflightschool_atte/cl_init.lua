--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

function ENT:LFSHudPaintInfoText( X, Y, speed, alt, AmmoPrimary, AmmoSecondary, Throttle )

	if self:GetMaxAmmoPrimary() > -1 then
		draw.SimpleText( "PRI", "LFS_FONT", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( AmmoPrimary, "LFS_FONT", 120, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	end

	if self:GetMaxAmmoSecondary() > -1 then
		draw.SimpleText( "SEC", "LFS_FONT", 10, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( AmmoSecondary, "LFS_FONT", 120, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	end
end

function ENT:LFSHudPaintInfoLine( HitPlane, HitPilot, LFS_TIME_NOTIFY, Dir, Len, FREELOOK )
end

function ENT:LFSHudPaintCrosshair( HitEnt, HitPly)
	local startpos = self:GetRotorPos()
	local TracePilot = util.TraceHull( {
		start = startpos,
		endpos = (startpos + LocalPlayer():EyeAngles():Forward() * 50000),
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ),
		filter = {self,self:GetRearEnt()}
	} )
	local HitPilot = TracePilot.HitPos:ToScreen()

	surface.SetDrawColor( 255, 255, 255, 255 )
	simfphys.LFS.DrawCircle( HitPilot.x, HitPilot.y, 34 )
	-- shadow
	surface.SetDrawColor( 0, 0, 0, 80 )
	simfphys.LFS.DrawCircle( HitPilot.x + 1, HitPilot.y + 1, 34 )
end

function ENT:LFSHudPaintRollIndicator( HitPlane, Enabled ) -- roll indicator
end

function ENT:OnRemove()
	self:LegClearAll()
end

function ENT:LegClearAll()
	if istable( self.IK_Joints ) then 
		for _, tab in pairs( self.IK_Joints ) do
			for _,prop in pairs( tab ) do
				if IsValid( prop ) then
					prop:Remove()
				end
			end
		end
		
		self.IK_Joints = nil
	end
end

function ENT:GetLegEnts( index, L1, L2, JOINTANG, STARTPOS, ENDPOS, ATTACHMENTS, PARENT )
	if self.DrawTime then
		if self.DrawTime < (CurTime() - FrameTime() * 2) then
			self:LegClearAll()
			
			return
		end
	end
	
	if not istable( self.IK_Joints ) then self.IK_Joints = {} end
	
	if not self.IK_Joints[ index ] then
		self.IK_Joints[ index ] = {}
		
		local BaseProp = ents.CreateClientProp()
		BaseProp:SetPos( STARTPOS )
		BaseProp:SetAngles( JOINTANG )
		BaseProp:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		BaseProp:SetParent( PARENT )
		BaseProp:Spawn()
		
		local LegRotCalc = ents.CreateClientProp()
		LegRotCalc:SetPos( STARTPOS )
		LegRotCalc:SetAngles( JOINTANG )
		LegRotCalc:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		LegRotCalc:SetParent( PARENT )
		LegRotCalc:Spawn()

		local prop1 = ents.CreateClientProp()
		prop1:SetPos( BaseProp:LocalToWorld( Vector(0,0,L1 * 0.5) ) )
		prop1:SetAngles( JOINTANG )
		prop1:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		prop1:SetParent( PARENT )
		prop1:Spawn()

		local prop2 = ents.CreateClientProp()
		prop2:SetPos( BaseProp:LocalToWorld( Vector(0,0,L1 + L2) ) )
		prop2:SetAngles( JOINTANG )
		prop2:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		prop2:SetParent( PARENT )
		prop2:Spawn()

		local prop3 = ents.CreateClientProp()
		prop3:SetPos( STARTPOS )
		prop3:SetAngles( JOINTANG )
		prop3:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		prop3:SetParent( LegRotCalc )
		prop1:SetParent( prop3 )
		prop3:Spawn()

		local prop4 = ents.CreateClientProp()
		prop4:SetPos( BaseProp:LocalToWorld( Vector(0,0,L1) ) )
		prop4:SetAngles( JOINTANG )
		prop4:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		prop4:SetParent( prop1 )
		prop2:SetParent( prop4 )
		prop4:Spawn()
		
		self.IK_Joints[ index ].LegBaseRot = BaseProp
		self.IK_Joints[ index ].LegRotCalc = LegRotCalc
		self.IK_Joints[ index ].LegEnt1 = prop1
		self.IK_Joints[ index ].LegEnt2 = prop2
		self.IK_Joints[ index ].LegEnt3 = prop3
		self.IK_Joints[ index ].LegEnt4 = prop4
		
		for _, v in pairs( self.IK_Joints[ index ] ) do
			v:SetColor( Color( 0, 0, 0, 0 ) )
			v:SetRenderMode( RENDERMODE_TRANSALPHA )
		end
		
		if ATTACHMENTS then
			if ATTACHMENTS.Leg1 then
				local prop = ents.CreateClientProp()
				prop:SetPos( prop3:LocalToWorld( ATTACHMENTS.Leg1.Pos ) )
				prop:SetAngles( prop3:LocalToWorldAngles( ATTACHMENTS.Leg1.Ang ) )
				prop:SetModel( ATTACHMENTS.Leg1.MDL )
				prop:SetParent( prop3 )
				prop:Spawn()
				self.IK_Joints[ index ].Attachment1 = prop
			end
			if ATTACHMENTS.Leg2 then
				local prop = ents.CreateClientProp()
				prop:SetPos( prop4:LocalToWorld( ATTACHMENTS.Leg2.Pos ) )
				prop:SetAngles( prop4:LocalToWorldAngles( ATTACHMENTS.Leg2.Ang ) )
				prop:SetModel( ATTACHMENTS.Leg2.MDL )
				prop:SetParent( prop4 )
				prop:Spawn()
				self.IK_Joints[ index ].Attachment2 = prop
			end
			if ATTACHMENTS.Foot then
				local prop = ents.CreateClientProp()
				prop:SetModel( ATTACHMENTS.Foot.MDL )
				prop:SetParent( prop2 )
				prop:Spawn()
				self.IK_Joints[ index ].Attachment3 = prop
			end
		end
	end
	
	self.IK_Joints[ index ].LegRotCalc:SetAngles(self.IK_Joints[ index ].LegBaseRot:LocalToWorldAngles( self.IK_Joints[ index ].LegBaseRot:WorldToLocal( ENDPOS ):Angle() ) )

	local Dist = math.min( (self.IK_Joints[ index ].LegRotCalc:GetPos() - ENDPOS ):Length(), L1 + L2)
	local Angle1 = 90 - math.deg( math.acos( (Dist ^ 2 + L1 ^ 2 - L2 ^ 2) / (2 * Dist * L1) ) )
	local Angle2 = math.deg( math.acos( (Dist ^ 2 + L2 ^ 2 - L1 ^ 2) / (2 * Dist * L2) ) ) + 90

	self.IK_Joints[ index ].LegEnt3:SetAngles( self.IK_Joints[ index ].LegRotCalc:LocalToWorldAngles( Angle(Angle1,180,180) ) )
	self.IK_Joints[ index ].LegEnt4:SetAngles( self.IK_Joints[ index ].LegRotCalc:LocalToWorldAngles( Angle(Angle2,180,180) ) )
	
	if self.IK_Joints[ index ].Attachment3 then
		self.IK_Joints[ index ].Attachment3:SetAngles( PARENT:LocalToWorldAngles( ATTACHMENTS.Foot.Ang ) )
		self.IK_Joints[ index ].Attachment3:SetPos(self.IK_Joints[ index ].LegEnt2:GetPos() + PARENT:GetForward() * ATTACHMENTS.Foot.Pos.x  + PARENT:GetRight() * ATTACHMENTS.Foot.Pos.y + PARENT:GetUp() * ATTACHMENTS.Foot.Pos.z )
	end
end

local GroupCollide = {
	[COLLISION_GROUP_DEBRIS] = true,
	[COLLISION_GROUP_DEBRIS_TRIGGER] = true,
	[COLLISION_GROUP_PLAYER] = true,
	[COLLISION_GROUP_WEAPON] = true,
	[COLLISION_GROUP_VEHICLE_CLIP] = true,
	[COLLISION_GROUP_WORLD] = true,
}

function ENT:Think()
	local RearEnt = self:GetRearEnt()
	
	if not IsValid( RearEnt ) then return end
	
	local Up = self:GetUp()
	local Forward = self:GetForward()
	local Vel = self:GetVelocity()
	
	local Stride = 40
	local Lift = 20
	
	local FT = FrameTime()
	local Rate = FT * 20

	if Vel:Length() < 10 then -- sync with server animation when not moving
		self.Move = self:GetMove()
	else
		self.Move = self.Move and self.Move + self:WorldToLocal( self:GetPos() + Vel ).x * FT * 1.8 or 0
	end
	
	local Cycl1 = self.Move
	local Cycl2 = self.Move + 180
	local Cycl3 = self.Move + 90
	local Cycl4 = self.Move + 270
	local Cycl5 = self.Move
	local Cycl6 = self.Move + 180
	
	local IsMoving = self:GetIsMoving()
	
	if self:GetIsCarried() then
		self.TRACEPOS1 = self:LocalToWorld( Vector(200,70,180) )
		self.TRACEPOS2 = self:LocalToWorld( Vector(200,-70,180) )
		self.TRACEPOS3 = RearEnt:LocalToWorld( Vector(-160,-70,180) )
		self.TRACEPOS4 = RearEnt:LocalToWorld( Vector(-160,70,180) )
		self.TRACEPOS5 = RearEnt:LocalToWorld( Vector(0,-140,150) )
		self.TRACEPOS6 = RearEnt:LocalToWorld( Vector(0,140,150) )
		Cycl1 = 0
		Cycl2 = 0
		Cycl3 = 0
		Cycl4 = 0
		Cycl5 = 0
		Cycl6 = 0
		IsMoving = true
	end
	
	-- FRONT LEFT
	local X = 20 + math.cos( math.rad(Cycl1) ) * Stride
	local Z = math.max( math.sin( math.rad(-Cycl1) ), 0) * Lift
	local STARTPOS = self:LocalToWorld( Vector(179.38,49.49,135.76) )
	self.TRACEPOS1 = self.TRACEPOS1 and self.TRACEPOS1 or STARTPOS
	if Z > 0 or not IsMoving then 
		self.TRACEPOS1 = self.TRACEPOS1 + (STARTPOS + Forward * X - self.TRACEPOS1) * Rate
		self.FSOG1 = false
	else
		self.FSOG1 = true
	end
	local ENDPOS = util.TraceLine( { start = self.TRACEPOS1 - Up * 50, endpos = self.TRACEPOS1 - Up * 160, filter = function( ent ) if ent == self or ent == self:GetRearEnt() or GroupCollide[ ent:GetCollisionGroup() ] then return false end return true end,} ).HitPos + Vector(0,0,45+Z)
	if self.FSOG1 ~= self.oldFSOG1 then
		self.oldFSOG1 = self.FSOG1
		if self.FSOG1 then
			sound.Play( Sound( "lfs/laatc_atte/stomp"..math.random(1,4).."_light.ogg" ), ENDPOS, SNDLVL_70dB)
			local effectdata = EffectData()
				effectdata:SetOrigin( ENDPOS - Vector(0,0,45) )
			util.Effect( "laatc_atte_walker_stomp", effectdata )
		else
			sound.Play( Sound( "lfs/laatc_atte/hydraulic"..math.random(1,7)..".ogg" ), ENDPOS, SNDLVL_70dB)
		end
	end
	
	local ATTACHMENTS = {
		Leg1 = {MDL = "models/blu/atte_smallleg_part3.mdl", Ang = Angle(-90,-90,0), Pos = Vector(0,0,0)},
		Leg2 = {MDL = "models/blu/atte_smallleg_part2.mdl", Ang = Angle(-90,-90,0), Pos = Vector(3,4,0)},
		Foot = {MDL = "models/blu/atte_smallleg_part1.mdl", Ang = Angle(0,0,0), Pos = Vector(0,-4,0)}
	}
	self:GetLegEnts( 1, 60, 65, self:LocalToWorldAngles( Angle(90,-10,0) ), STARTPOS, ENDPOS, ATTACHMENTS, self )
	
	
	-- FRONT RIGHT
	local STARTPOS = self:LocalToWorld( Vector(179.38,-49.49,135.76) )
	local X = 20 + math.cos( math.rad(Cycl2) ) * Stride
	local Z = math.max( math.sin( math.rad(-Cycl2) ), 0) * Lift
	self.TRACEPOS2 = self.TRACEPOS2 and self.TRACEPOS2 or STARTPOS
	if Z > 0 or not IsMoving then 
		self.TRACEPOS2 = self.TRACEPOS2 + (STARTPOS + Forward * X - self.TRACEPOS2) * Rate
		self.FSOG2 = false
	else
		self.FSOG2 = true
	end
	local ENDPOS = util.TraceLine( { start = self.TRACEPOS2 - Up * 50, endpos = self.TRACEPOS2 - Up * 160, filter = function( ent ) if ent == self or ent == self:GetRearEnt() or GroupCollide[ ent:GetCollisionGroup() ] then return false end return true end, } ).HitPos + Vector(0,0,45+Z)
	if self.FSOG2 ~= self.oldFSOG2 then
		self.oldFSOG2 = self.FSOG2
		if self.FSOG2 then
			sound.Play( Sound( "lfs/laatc_atte/stomp"..math.random(1,4).."_light.ogg" ), ENDPOS, SNDLVL_70dB)
			local effectdata = EffectData()
				effectdata:SetOrigin( ENDPOS - Vector(0,0,45) )
			util.Effect( "laatc_atte_walker_stomp", effectdata )
		else
			sound.Play( Sound( "lfs/laatc_atte/hydraulic"..math.random(1,7)..".ogg" ), ENDPOS, SNDLVL_70dB)
		end
	end
	
	local ATTACHMENTS = {
		Leg1 = {MDL = "models/blu/atte_smallleg_part3.mdl", Ang = Angle(-90,90,0), Pos = Vector(0,0,0)},
		Leg2 = {MDL = "models/blu/atte_smallleg_part2.mdl", Ang = Angle(-90,90,0), Pos = Vector(-3,-4,0)},
		Foot = {MDL = "models/blu/atte_smallleg_part1.mdl", Ang = Angle(0,180,0), Pos = Vector(0,4,0)}
	}
	
	self:GetLegEnts( 2, 60, 65, self:LocalToWorldAngles( Angle(90,10,0) ), STARTPOS, ENDPOS, ATTACHMENTS, self )
	
	
	
	
	
	local Forward = RearEnt:GetForward()
	local Up = RearEnt:GetUp()
	
	if not self.PixVisATTE then
		self.PixVisATTE = util.GetPixelVisibleHandle()
	end
	
	if util.PixelVisible( RearEnt:LocalToWorld( Vector(-148.37,0,76.6) ), 150, self.PixVisATTE ) >= 0.1 then
		self.DrawTime = CurTime()
	end
	
	-- REAR RIGHT
	local STARTPOS = RearEnt:LocalToWorld( Vector(-144.56,-68.16,126.39) )
	local X = -20 + math.cos( math.rad(Cycl5) ) * Stride
	local Z = math.max( math.sin( math.rad(-Cycl5) ), 0) * Lift
	self.TRACEPOS3 = self.TRACEPOS3 and self.TRACEPOS3 or STARTPOS
	if Z > 0 or not IsMoving then 
		self.TRACEPOS3 = self.TRACEPOS3 + (STARTPOS + Forward * X - self.TRACEPOS3) * Rate
		self.FSOG3 = false
	else
		self.FSOG3 = true
	end
	local ENDPOS = util.TraceLine( { start = self.TRACEPOS3 - Up * 50, endpos = self.TRACEPOS3 - Up * 160, filter = function( ent ) if ent == self or ent == self:GetRearEnt() or GroupCollide[ ent:GetCollisionGroup() ] then return false end return true end, } ).HitPos + Vector(0,0,45+Z)
	if self.FSOG3 ~= self.oldFSOG3 then
		self.oldFSOG3 = self.FSOG3
		if self.FSOG3 then
			sound.Play( Sound( "lfs/laatc_atte/stomp"..math.random(1,4).."_light.ogg" ), ENDPOS, SNDLVL_70dB)
			local effectdata = EffectData()
				effectdata:SetOrigin( ENDPOS - Vector(0,0,45) )
			util.Effect( "laatc_atte_walker_stomp", effectdata )
		else
			sound.Play( Sound( "lfs/laatc_atte/hydraulic"..math.random(1,7)..".ogg" ), ENDPOS, SNDLVL_70dB)
		end
	end
	
	local ATTACHMENTS = {
		Leg1 = {MDL = "models/blu/atte_smallleg_part3.mdl", Ang = Angle(-90,-90,0), Pos = Vector(0,0,0)},
		Leg2 = {MDL = "models/blu/atte_smallleg_part2.mdl", Ang = Angle(-90,-90,0), Pos = Vector(3,4,0)},
		Foot = {MDL = "models/blu/atte_smallleg_part1.mdl", Ang = Angle(0,180,0), Pos = Vector(0,4,0)}
	}
	
	self:GetLegEnts( 3, 60, 65, RearEnt:LocalToWorldAngles( Angle(90,180,0) ), STARTPOS, ENDPOS, ATTACHMENTS, RearEnt )
	
	
	-- REAR LEFT
	local STARTPOS = RearEnt:LocalToWorld( Vector(-144.56,68.16,126.39) )
	local X = -20 + math.cos( math.rad(Cycl6) ) * Stride
	local Z = math.max( math.sin( math.rad(-Cycl6) ), 0) * Lift
	self.TRACEPOS4 = self.TRACEPOS4 and self.TRACEPOS4 or STARTPOS
	if Z > 0 or not IsMoving then 
		self.TRACEPOS4 = self.TRACEPOS4 + (STARTPOS + Forward * X - self.TRACEPOS4) * Rate
		self.FSOG4 = false
	else
		self.FSOG4 = true
	end
	local ENDPOS = util.TraceLine( { start = self.TRACEPOS4 - Up * 50, endpos = self.TRACEPOS4 - Up * 160, filter = function( ent ) if ent == self or ent == self:GetRearEnt() or GroupCollide[ ent:GetCollisionGroup() ] then return false end return true end, } ).HitPos + Vector(0,0,45+Z)
	if self.FSOG4 ~= self.oldFSOG4 then
		self.oldFSOG4 = self.FSOG4
		if self.FSOG4 then
			sound.Play( Sound( "lfs/laatc_atte/stomp"..math.random(1,4).."_light.ogg" ), ENDPOS, SNDLVL_70dB)
			local effectdata = EffectData()
				effectdata:SetOrigin( ENDPOS - Vector(0,0,45) )
			util.Effect( "laatc_atte_walker_stomp", effectdata )
		else
			sound.Play( Sound( "lfs/laatc_atte/hydraulic"..math.random(1,7)..".ogg" ), ENDPOS, SNDLVL_70dB)
		end
	end
	
	local ATTACHMENTS = {
		Leg1 = {MDL = "models/blu/atte_smallleg_part3.mdl", Ang = Angle(-90,90,0), Pos = Vector(0,0,0)},
		Leg2 = {MDL = "models/blu/atte_smallleg_part2.mdl", Ang = Angle(-90,90,0), Pos = Vector(-3,-4,0)},
		Foot = {MDL = "models/blu/atte_smallleg_part1.mdl", Ang = Angle(0,0,0), Pos = Vector(0,-4,0)}
	}
	
	self:GetLegEnts( 4, 60, 65, RearEnt:LocalToWorldAngles( Angle(90,180,0) ), STARTPOS, ENDPOS, ATTACHMENTS, RearEnt )


	local Right = RearEnt:GetRight()

	-- MID RIGHT
	local STARTPOS = RearEnt:LocalToWorld( Vector(-11.37,-45,139.61) )
	local X = 30 + math.cos( math.rad(Cycl3) ) * Stride
	local Z = math.max( math.sin( math.rad(-Cycl3) ), 0) * Lift
	self.TRACEPOS5 = self.TRACEPOS5 and self.TRACEPOS5 or STARTPOS
	if Z > 0 or not IsMoving then 
		self.TRACEPOS5 = self.TRACEPOS5 + (STARTPOS + Forward * X + Right * 90 - self.TRACEPOS5) * Rate
		self.FSOG5 = false
	else
		self.FSOG5 = true
	end
	local ENDPOS = util.TraceLine( { start = self.TRACEPOS5 - Up * 50, endpos = self.TRACEPOS5 - Up * 160, filter = function( ent ) if ent == self or ent == self:GetRearEnt() or GroupCollide[ ent:GetCollisionGroup() ] then return false end return true end, } ).HitPos + Vector(0,0,65+Z)
	if self.FSOG5 ~= self.oldFSOG5 then
		self.oldFSOG5 = self.FSOG5
		if self.FSOG5 then
			sound.Play( Sound( "lfs/laatc_atte/stomp"..math.random(1,4)..".ogg" ), ENDPOS, SNDLVL_100dB )
			local effectdata = EffectData()
				effectdata:SetOrigin( ENDPOS - Vector(0,0,65) )
			util.Effect( "laatc_atte_walker_stomp", effectdata )
		else
			sound.Play( Sound( "lfs/laatc_atte/lift"..math.random(1,4)..".ogg" ), ENDPOS, SNDLVL_100dB )
		end
	end
	
	local ATTACHMENTS = {
		Leg2 = {MDL = "models/blu/atte_bigleg.mdl", Ang = Angle(-90,180,0), Pos = Vector(0,0,0)},
		Foot = {MDL = "models/blu/atte_bigfoot.mdl", Ang = Angle(0,180,0), Pos = Vector(-16,3,0)}
	}
	
	self:GetLegEnts( 5, 60, 94, RearEnt:LocalToWorldAngles( Angle(135,100,0) ), STARTPOS, ENDPOS, ATTACHMENTS, RearEnt )
	
	
	
	-- MID LEFT
	local STARTPOS = RearEnt:LocalToWorld( Vector(-11.37,45,139.61) )
	local X = 30 + math.cos( math.rad(Cycl4) ) * Stride
	local Z = math.max( math.sin( math.rad(-Cycl4) ), 0) * Lift
	self.TRACEPOS6 = self.TRACEPOS6 and self.TRACEPOS6 or STARTPOS
	if Z > 0 or not IsMoving then 
		self.TRACEPOS6 = self.TRACEPOS6 + (STARTPOS + Forward * X - Right * 90 - self.TRACEPOS6) * Rate
		self.FSOG6 = false
	else
		self.FSOG6 = true
	end
	local ENDPOS = util.TraceLine( { start = self.TRACEPOS6 - Up * 50, endpos = self.TRACEPOS6 - Up * 160, filter = function( ent ) if ent == self or ent == self:GetRearEnt() or GroupCollide[ ent:GetCollisionGroup() ] then return false end return true end } ).HitPos + Vector(0,0,65+Z)
	if self.FSOG6 ~= self.oldFSOG6 then
		self.oldFSOG6 = self.FSOG6
		if self.FSOG6 then
			sound.Play( Sound( "lfs/laatc_atte/stomp"..math.random(1,4)..".ogg" ), ENDPOS, SNDLVL_100dB )
			local effectdata = EffectData()
				effectdata:SetOrigin( ENDPOS - Vector(0,0,65) )
			util.Effect( "laatc_atte_walker_stomp", effectdata )
		else
			sound.Play( Sound( "lfs/laatc_atte/lift"..math.random(1,4)..".ogg" ), ENDPOS, SNDLVL_100dB )
		end
	end
	
	local ATTACHMENTS = {
		Leg2 = {MDL = "models/blu/atte_bigleg.mdl", Ang = Angle(-90,180,0), Pos = Vector(0,0,0)},
		Foot = {MDL = "models/blu/atte_bigfoot.mdl", Ang = Angle(0,0,0), Pos = Vector(16,-3,0)}
	}
	
	self:GetLegEnts( 6, 60, 94, RearEnt:LocalToWorldAngles( Angle(135,-100,0) ), STARTPOS, ENDPOS, ATTACHMENTS, RearEnt )
end

function ENT:Draw()
	self:DrawModel()
	self.DrawTime = CurTime()
end