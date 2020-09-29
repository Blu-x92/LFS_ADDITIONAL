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

function ENT:LFSCalcViewFirstPerson( view, ply )
	if ply == self:GetDriver() then
		local Pod = self:GetDriverSeat()
		if IsValid( Pod ) then
			Pod:SetThirdPersonMode( true )
		end
	end

	return view
end

function ENT:LFSCalcViewThirdPerson( view, ply )
	return view
end

function ENT:LFSHudPaint( X, Y, data, ply ) -- driver only
end

function ENT:LFSHudPaintPassenger( X, Y, ply ) -- all except driver
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

function ENT:LFSHudPaintPassenger( X, Y, ply )
	if self:GetBodygroup(1) == 2 then return end

	if ply == self:GetGunner() then
		local ID = self:LookupAttachment( "muzzle_turret" )
		local Muzzle = self:GetAttachment( ID )
		
		if Muzzle then
			local Pos = Muzzle.Pos
			local Dir = Muzzle.Ang:Up()

			local trace = util.TraceLine( {
				start = Pos,
				endpos = Pos + Dir * 50000,
				filter = self:GetCrosshairFilterEnts()
			} )

			local hitpos = trace.HitPos:ToScreen()

			local X = hitpos.x
			local Y = hitpos.y

			surface.SetDrawColor( 255, 255, 255, 255 )

			DrawCircle( X, Y, 10 )
			surface.DrawLine( X + 10, Y, X + 20, Y ) 
			surface.DrawLine( X - 10, Y, X - 20, Y ) 
			surface.DrawLine( X, Y + 10, X, Y + 20 ) 
			surface.DrawLine( X, Y - 10, X, Y - 20 ) 
			
			-- shadow
			surface.SetDrawColor( 0, 0, 0, 80 )
			DrawCircle( X + 1, Y + 1, 10 )
			surface.DrawLine( X + 11, Y + 1, X + 21, Y + 1 ) 
			surface.DrawLine( X - 9, Y + 1, X - 16, Y + 1 ) 
			surface.DrawLine( X + 1, Y + 11, X + 1, Y + 21 ) 
			surface.DrawLine( X + 1, Y - 19, X + 1, Y - 16 ) 
		end
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

function ENT:AnimCabin()
	local Fire = self:GetBTLFire()
	if Fire ~= self.OldFireBTL then
		self.OldFireBTL = Fire
		
		if Fire then
			self:EmitSound("LAATi_BT_FIRE")
			
			self.BTLLOOP = CreateSound( self, "LAATi_BT_FIRE_LOOP_CHAN1" )
			self.BTLLOOP:Play()
			
			local effectdata = EffectData()
			effectdata:SetEntity( self )
			util.Effect( "laat_ballturret_left_projector", effectdata )
		else
			if self.BTLLOOP then
				self.BTLLOOP:Stop()
			end
		end
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound( self, "LAATc_IFTX_ENGINE" )
		self.ENG:PlayEx(0,0)

		self.ENG_HI = CreateSound( self, "LAATc_IFTX_ENGINE_HI" )
		self.ENG_HI:PlayEx(0,0)

		self.DIST = CreateSound( self, "LAATc_IFTX_DIST" )
		self.DIST:PlayEx(0,0)
	else
		self:SoundStop()
	end
end

function ENT:RemoveLight()
	if IsValid( self.projector ) then
		self.projector:Remove()
		self.projector = nil
	end
end

function ENT:OnRemove()
	self:SoundStop()

	self:RemoveLight()
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

	if self.BTLLOOP then
		self.BTLLOOP:Stop()
	end
end

function ENT:AnimFins()
end

local spotlight = Material( "effects/lfs_base/spotlight_projectorbeam" )
local glow_spotlight = Material( "sprites/light_glow02_add" )

function ENT:Draw()
	self:DrawModel()

	if self:GetBodygroup( 2 ) ~= 1 or not self:GetEngineActive() then 
		self:RemoveLight()

		return
	end

	if not IsValid( self.projector ) then
		local thelamp = ProjectedTexture()
		thelamp:SetBrightness( 10 ) 
		thelamp:SetTexture( "effects/flashlight/soft" )
		thelamp:SetColor( Color(255,255,255) ) 
		thelamp:SetEnableShadows( false ) 
		thelamp:SetFarZ( 2500 ) 
		thelamp:SetNearZ( 75 ) 
		thelamp:SetFOV( 30 )
		self.projector = thelamp
	end

	local StartPos = self:LocalToWorld( Vector(60,0,10.5) )
	local Dir = self:GetForward()

	render.SetMaterial( glow_spotlight )
	render.DrawSprite( StartPos + Dir * 20, 250, 250, Color( 255, 255, 255, 255) )

	render.SetMaterial( spotlight )
	render.DrawBeam(  StartPos - Dir * 10,  StartPos + Dir * 800, 250, 0, 0.99, Color( 255, 255, 255, 10) ) 
	
	if IsValid( self.projector ) then
		self.projector:SetPos( StartPos )
		self.projector:SetAngles( Dir:Angle() )
		self.projector:Update()
	end
end
