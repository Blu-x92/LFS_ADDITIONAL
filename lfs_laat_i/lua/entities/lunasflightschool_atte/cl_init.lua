--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE


include("shared.lua")
include("cl_ikfunctions.lua")

function ENT:DamageFX()
	local HP = self:GetHP()
	if HP > self:GetMaxHP() * 0.5 then return end
	
	self.nextDFX = self.nextDFX or 0
	
	if self.nextDFX < CurTime() then
		self.nextDFX = CurTime() + 0.05
		
		local effectdata = EffectData()
			effectdata:SetOrigin( self:LocalToWorld( Vector(0,0,160) ) )
		util.Effect( "lfs_blacksmoke", effectdata )

		if HP <= 500 then
			if math.random(0,45) < 3 then
				if math.random(1,2) == 1 then
					local Pos = self:LocalToWorld( Vector(0,0,70) + VectorRand() * 80 )
					local effectdata = EffectData()
						effectdata:SetOrigin( Pos )
					util.Effect( "cball_explode", effectdata, true, true )
					
					sound.Play( "lfs/laatc_atte/spark"..math.random(1,4)..".ogg", Pos, 75 )
				end
			end
		end
	end
end

function ENT:OnRemoveAdd() -- since ENT:OnRemove() is used by the IK script we need to do our stuff here
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:LFSCalcViewFirstPerson( view, ply )
	return self:LFSCalcViewThirdPerson( view, ply, true )
end

function ENT:LFSCalcViewThirdPerson( view, ply, FirstPerson )
	local Pod = ply:GetVehicle()

	if ply == self:GetDriver() then
		return view
	end

	if ply == self:GetGunner() then
		local BaseEnt = self:GetRearEnt()
		
		if IsValid( BaseEnt ) then
			local radius = 800
			radius = radius + radius * Pod:GetCameraDistance()
			
			local StartPos = BaseEnt:LocalToWorld( Vector(-200,0,180) ) + view.angles:Up() * 100
			local EndPos = StartPos - view.angles:Forward() * radius
			
			local WallOffset = 4

			local tr = util.TraceHull( {
				start = StartPos,
				endpos = EndPos,
				filter = function( e )
					local c = e:GetClass()
					local collide = not c:StartWith( "prop_physics" ) and not c:StartWith( "prop_dynamic" ) and not c:StartWith( "prop_ragdoll" ) and not e:IsVehicle() and not c:StartWith( "gmod_" ) and not c:StartWith( "player" ) and not e.LFS
					
					return collide
				end,
				mins = Vector( -WallOffset, -WallOffset, -WallOffset ),
				maxs = Vector( WallOffset, WallOffset, WallOffset ),
			} )
			
			view.drawviewer = true
			view.origin = tr.HitPos
			
			if tr.Hit and not tr.StartSolid then
				view.origin = view.origin + tr.HitNormal * WallOffset
			end
		end

		return view
	end
	
	if ply == self:GetTurretDriver() then
		local radius = 800
		radius = radius + radius * Pod:GetCameraDistance()

		local Zoom = ply:KeyDown( IN_ATTACK2 ) or ply:KeyDown( IN_ZOOM )
		local Rate = FrameTime() * 5
		
		self.InterPoL = isnumber( self.InterPoL ) and self.InterPoL + math.Clamp((Zoom and 1 or 0) - self.InterPoL,-Rate,Rate) or 0
		view.fov = 75 - 30 * self.InterPoL

		radius = radius * (1 - self.InterPoL) + 200 * self.InterPoL

		local StartPos = self:LocalToWorld( Vector(94.13,0,216.8) ) + view.angles:Up() * 100
		local EndPos = StartPos - view.angles:Forward() * radius
		
		local WallOffset = 4

		local tr = util.TraceHull( {
			start = StartPos,
			endpos = EndPos,
			filter = function( e )
				local c = e:GetClass()
				local collide = not c:StartWith( "prop_physics" ) and not c:StartWith( "prop_dynamic" ) and not c:StartWith( "prop_ragdoll" ) and not e:IsVehicle() and not c:StartWith( "gmod_" ) and not c:StartWith( "player" ) and not e.LFS
				
				return collide
			end,
			mins = Vector( -WallOffset, -WallOffset, -WallOffset ),
			maxs = Vector( WallOffset, WallOffset, WallOffset ),
		} )
		
		view.drawviewer = true
		view.origin = tr.HitPos
		
		if tr.Hit and not tr.StartSolid then
			view.origin = view.origin + tr.HitNormal * WallOffset
		end

		return view
	end

	local radius = 800
	radius = radius + radius * Pod:GetCameraDistance()
	
	local StartPos = self:LocalToWorld( Vector(0,0,200) ) + view.angles:Up() * 100
	local EndPos = StartPos - view.angles:Forward() * radius
	
	local WallOffset = 4

	local tr = util.TraceHull( {
		start = StartPos,
		endpos = EndPos,
		filter = function( e )
			local c = e:GetClass()
			local collide = not c:StartWith( "prop_physics" ) and not c:StartWith( "prop_dynamic" ) and not c:StartWith( "prop_ragdoll" ) and not e:IsVehicle() and not c:StartWith( "gmod_" ) and not c:StartWith( "player" ) and not e.LFS
			
			return collide
		end,
		mins = Vector( -WallOffset, -WallOffset, -WallOffset ),
		maxs = Vector( WallOffset, WallOffset, WallOffset ),
	} )
	
	view.drawviewer = true
	view.origin = tr.HitPos
	
	if tr.Hit and not tr.StartSolid then
		view.origin = view.origin + tr.HitNormal * WallOffset
	end

	return view
end

function ENT:LFSHudPaintInfoText( X, Y, speed, alt, AmmoPrimary, AmmoSecondary, Throttle )
	draw.SimpleText( "SPEED", "LFS_FONT", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( speed.."km/h", "LFS_FONT", 120, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	draw.SimpleText( "PRI", "LFS_FONT", 10, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( AmmoPrimary, "LFS_FONT", 120, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
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

	local X = HitPilot.x
	local Y = HitPilot.y
	
	if self:GetFrontInRange() then
		surface.SetDrawColor( 255, 255, 255, 255 )
	else
		surface.SetDrawColor( 255, 0, 0, 255 )
	end

	simfphys.LFS.DrawCircle( X, Y, 10 )
	surface.DrawLine( X + 10, Y, X + 20, Y ) 
	surface.DrawLine( X - 10, Y, X - 20, Y ) 
	surface.DrawLine( X, Y + 10, X, Y + 20 ) 
	surface.DrawLine( X, Y - 10, X, Y - 20 ) 
	
	-- shadow
	surface.SetDrawColor( 0, 0, 0, 80 )
	simfphys.LFS.DrawCircle( X + 1, Y + 1, 10 )
	surface.DrawLine( X + 11, Y + 1, X + 21, Y + 1 ) 
	surface.DrawLine( X - 9, Y + 1, X - 16, Y + 1 ) 
	surface.DrawLine( X + 1, Y + 11, X + 1, Y + 21 ) 
	surface.DrawLine( X + 1, Y - 19, X + 1, Y - 16 ) 
end

function ENT:LFSHudPaintRollIndicator( HitPlane, Enabled ) -- roll indicator
end

function ENT:LFSHudPaintPassenger( X, Y, ply )
	if ply == self:GetGunner() then
		draw.SimpleText( "PRI", "LFS_FONT", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( self:GetAmmoPrimary(), "LFS_FONT", 120, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		
		local EyeAngles = ply:EyeAngles()
		
		local RearGunActive = self:GetRearInRange()

		local X = ScrW() * 0.5
		local Y = ScrH() * 0.5

		if RearGunActive then
			surface.SetDrawColor( 255, 255, 255, 255 )
		else
			surface.SetDrawColor( 255, 0, 0, 255 )
		end
		
		simfphys.LFS.DrawCircle( X, Y, 10 )
		surface.DrawLine( X + 10, Y, X + 20, Y ) 
		surface.DrawLine( X - 10, Y, X - 20, Y ) 
		surface.DrawLine( X, Y + 10, X, Y + 20 ) 
		surface.DrawLine( X, Y - 10, X, Y - 20 ) 
		
		-- shadow
		surface.SetDrawColor( 0, 0, 0, 80 )
		simfphys.LFS.DrawCircle( X + 1, Y + 1, 10 )
		surface.DrawLine( X + 11, Y + 1, X + 21, Y + 1 ) 
		surface.DrawLine( X - 9, Y + 1, X - 16, Y + 1 ) 
		surface.DrawLine( X + 1, Y + 11, X + 1, Y + 21 ) 
		surface.DrawLine( X + 1, Y - 19, X + 1, Y - 16 ) 
	end
	
	if ply == self:GetTurretDriver() then
		draw.SimpleText( "PRI", "LFS_FONT", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( self:GetAmmoSecondary(), "LFS_FONT", 120, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		
		local ID = self:LookupAttachment( "muzzle_cannon" )
		local Muzzle = self:GetAttachment( ID )
	
		if Muzzle then
			local startpos = Muzzle.Pos
			local Trace = util.TraceHull( {
				start = startpos,
				endpos = (startpos + Muzzle.Ang:Up() * 50000),
				mins = Vector( -10, -10, -10 ),
				maxs = Vector( 10, 10, 10 ),
				filter = function( ent ) if ent == self or ent == self:GetRearEnt() or ent:GetClass() == "lfs_atte_massdriver_projectile" then return false end return true end
			} )
			local HitPos = Trace.HitPos:ToScreen()

			local X = HitPos.x
			local Y = HitPos.y

			if self:GetIsCarried() then
				surface.SetDrawColor( 255, 0, 0, 255 )
			else
				surface.SetDrawColor( 255, 255, 255, 255 )
			end
			
			simfphys.LFS.DrawCircle( X, Y, 10 )
			surface.DrawLine( X + 10, Y, X + 20, Y ) 
			surface.DrawLine( X - 10, Y, X - 20, Y ) 
			surface.DrawLine( X, Y + 10, X, Y + 20 ) 
			surface.DrawLine( X, Y - 10, X, Y - 20 ) 
			
			-- shadow
			surface.SetDrawColor( 0, 0, 0, 80 )
			simfphys.LFS.DrawCircle( X + 1, Y + 1, 10 )
			surface.DrawLine( X + 11, Y + 1, X + 21, Y + 1 ) 
			surface.DrawLine( X - 9, Y + 1, X - 16, Y + 1 ) 
			surface.DrawLine( X + 1, Y + 11, X + 1, Y + 21 ) 
			surface.DrawLine( X + 1, Y - 19, X + 1, Y - 16 ) 

			local heat = (self:GetTurretHeat() / 100)
			if heat > 0.01 then
				local sX = 70
				local sY = 6
				X = X - sX * 0.5
				Y = Y + 25

				surface.SetDrawColor(0,0,0,255)
				surface.DrawRect(X - 1, Y - 1, sX + 2, sY + 2)

				surface.SetDrawColor(150,150,150,100)
				surface.DrawRect(X, Y, sX, sY)

				surface.SetDrawColor(255,255,255,255)
				surface.DrawRect(X, Y, sX * math.min(heat,1), sY)
				if heat > 1 then
					surface.SetDrawColor(255,0,0,255)
					surface.DrawRect(X + sX, Y, sX * math.min(heat - 1,1), sY)
				end
			end
		end
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
	self:DamageFX()

	local RearEnt = self:GetRearEnt()

	if not IsValid( RearEnt ) then return end

	if self:GetDieRagdoll() then 
		self:LegClearAll()
		RearEnt:LegClearAll()

		return
	end

	local Up = self:GetUp()
	local Forward = self:GetForward()
	local Vel = self:GetVelocity()
	
	local Stride = 40
	local Lift = 20
	
	local FT = math.min(FrameTime(),0.08) -- if fps lower than 12, clamp the frametime to avoid spazzing.

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
	self:GetLegEnts( 1, 60, 65, self:LocalToWorldAngles( Angle(90,-10,0) ), STARTPOS, ENDPOS, ATTACHMENTS )
	
	
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
	
	self:GetLegEnts( 2, 60, 65, self:LocalToWorldAngles( Angle(90,10,0) ), STARTPOS, ENDPOS, ATTACHMENTS )
	
	
	local Forward = RearEnt:GetForward()
	local Up = RearEnt:GetUp()

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
	
	RearEnt:GetLegEnts( 3, 60, 65, RearEnt:LocalToWorldAngles( Angle(90,180,0) ), STARTPOS, ENDPOS, ATTACHMENTS )
	
	
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
	
	RearEnt:GetLegEnts( 4, 60, 65, RearEnt:LocalToWorldAngles( Angle(90,180,0) ), STARTPOS, ENDPOS, ATTACHMENTS )


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
	local ENDPOS = util.TraceLine( { start = self.TRACEPOS5 - Up * 50, endpos = self.TRACEPOS5 - Up * 160, filter = function( ent ) if ent == self or ent == self:GetRearEnt() or GroupCollide[ ent:GetCollisionGroup() ] then return false end return true end, } ).HitPos + Vector(0,0,60+Z)
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
	
	RearEnt:GetLegEnts( 5, 60, 94, RearEnt:LocalToWorldAngles( Angle(135,100,0) ), STARTPOS, ENDPOS, ATTACHMENTS )
	
	
	
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
	local ENDPOS = util.TraceLine( { start = self.TRACEPOS6 - Up * 50, endpos = self.TRACEPOS6 - Up * 160, filter = function( ent ) if ent == self or ent == self:GetRearEnt() or GroupCollide[ ent:GetCollisionGroup() ] then return false end return true end } ).HitPos + Vector(0,0,60+Z)
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
	
	RearEnt:GetLegEnts( 6, 60, 94, RearEnt:LocalToWorldAngles( Angle(135,-100,0) ), STARTPOS, ENDPOS, ATTACHMENTS )
end
