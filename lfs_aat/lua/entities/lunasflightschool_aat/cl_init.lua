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

function ENT:TurretView( view, ply )
	local ID = self:LookupAttachment( "turret_view" )
	local Muzzle = self:GetAttachment( ID )
	local Pod = ply:GetVehicle()

	if Muzzle then
		local Pos,Ang = LocalToWorld( Vector(0,35,-40), Angle(270,0,-90), Muzzle.Pos, Muzzle.Ang )

		local fwd1 = ply:EyeAngles():Forward()
		local fwd2 = Ang:Forward()
		
		local Zoom = (fwd1 - fwd2):Length() < 0.7 and (ply:KeyDown( IN_ATTACK2 ) or ply:KeyDown( IN_ZOOM )) or false
		local Rate = FrameTime() * 5
		
		self.InterPoL = isnumber( self.InterPoL ) and self.InterPoL + math.Clamp((Zoom and 1 or 0) - self.InterPoL,-Rate,Rate) or 0

		view.angles = (fwd1 * (1 - self.InterPoL) + fwd2 * self.InterPoL):Angle()
		view.fov = 75 - 30 * self.InterPoL


		local radius = 800
		radius = radius + radius * Pod:GetCameraDistance()
		local StartPos = self:LocalToWorld( Vector(-90.1038,0,180) )
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
		local originTP = tr.HitPos

		if tr.Hit and not tr.StartSolid then
			originTP = originTP + tr.HitNormal * WallOffset
		end

		view.origin = (originTP * (1 - self.InterPoL) + Pos * self.InterPoL)
		view.drawviewer = false
	end

	return view
end

function ENT:LFSCalcViewFirstPerson( view, ply )
	if ply == self:GetDriver() then
		view.origin = self:LocalToWorld( Vector(-80,0,150) )
	end

	if ply == self:GetGunner() then
		return self:TurretView( view, ply )
	end

	return view
end

function ENT:LFSCalcViewThirdPerson( view, ply )
	local Pod = ply:GetVehicle()

	if ply == self:GetGunner() then
		return self:TurretView( view, ply )
	end

	return view
end

function ENT:LFSHudPaint( X, Y, data, ply ) -- driver only
end

function ENT:LFSHudPaintPassenger( X, Y, ply ) -- all except driver
	if ply == self:GetGunner() then
		local ID = self:LookupAttachment( "muzzle" )
		local Muzzle = self:GetAttachment( ID )
	
		if Muzzle then
			local startpos = Muzzle.Pos
			local Trace = util.TraceHull( {
				start = startpos,
				endpos = (startpos + Muzzle.Ang:Up() * 50000),
				mins = Vector( -10, -10, -10 ),
				maxs = Vector( 10, 10, 10 ),
				filter = function( ent ) if ent == self or ent:GetClass() == "lfs_aat_laser_projectile" then return false end return true end
			} )
			local HitPos = Trace.HitPos:ToScreen()

			local X = HitPos.x
			local Y = HitPos.y

			surface.SetDrawColor( 255, 255, 255, 255 )

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
	end
end

function ENT:LFSHudPaintInfoText( X, Y, speed, alt, AmmoPrimary, AmmoSecondary, Throttle )
	draw.SimpleText( "SPEED", "LFS_FONT", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( speed.."km/h", "LFS_FONT", 120, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	draw.SimpleText( "PRI", "LFS_FONT", 10, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( AmmoPrimary, "LFS_FONT", 120, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	draw.SimpleText( "SEC", "LFS_FONT", 10, 60, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( AmmoSecondary, "LFS_FONT", 120, 60, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
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
		filter = self
	} )
	local HitPilot = TracePilot.HitPos:ToScreen()

	local X = HitPilot.x
	local Y = HitPilot.y
	
	if self:GetWeaponOutOfRange() then
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
end

function ENT:LFSHudPaintRollIndicator( HitPlane, Enabled )
end

local function DrawCircle( X, Y, radius )
	local segmentdist = 360 / ( 2 * math.pi * radius / 2 )
	
	for a = 0, 360, segmentdist do
		surface.DrawLine( X + math.cos( math.rad( a ) ) * radius, Y - math.sin( math.rad( a ) ) * radius, X + math.cos( math.rad( a + segmentdist ) ) * radius, Y - math.sin( math.rad( a + segmentdist ) ) * radius )
		
		surface.DrawLine( X + math.cos( math.rad( a ) ) * radius, Y - math.sin( math.rad( a ) ) * radius, X + math.cos( math.rad( a + segmentdist ) ) * radius, Y - math.sin( math.rad( a + segmentdist ) ) * radius )
	end
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	if self.ENG then
		self.ENG:ChangePitch(  math.Clamp( 60 + Pitch * 30 + Doppler,0,255) )
		self.ENG:ChangeVolume( math.Clamp( Pitch, 0.5,1) )
	end

	if self.ENG_HI then
		self.ENG_HI:ChangePitch(  math.Clamp( 60 + Pitch * 30 + Doppler,0,255) )
		self.ENG_HI:ChangeVolume( math.Clamp( Pitch, 0.5,1) )
	end

	if self.DIST then
		self.DIST:ChangePitch(  math.Clamp(math.Clamp(  Pitch * 100, 50,255) + Doppler * 1.25,0,255) )
		self.DIST:ChangeVolume( math.Clamp( -1.5 + Pitch * 6, 0.5,1) )
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound( self, "lfsAAT_ENGINE" )
		self.ENG:PlayEx(0,0)

		self.ENG_HI = CreateSound( self, "lfsAAT_ENGINE_HI" )
		self.ENG_HI:PlayEx(0,0)

		self.DIST = CreateSound( self, "lfsAAT_DIST" )
		self.DIST:PlayEx(0,0)
	else
		self:SoundStop()
	end
end


function ENT:OnRemove()
	self:SoundStop()
end

function ENT:SoundStop()
	if self.DIST then
		self.DIST:Stop()
	end

	if self.ENG then
		self.ENG:Stop()
	end

	if self.ENG_HI then
		self.ENG_HI:Stop()
	end
end

function ENT:Draw()
	self:DrawModel()
end
