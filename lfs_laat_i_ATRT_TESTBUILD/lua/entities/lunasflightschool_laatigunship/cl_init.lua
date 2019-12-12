--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

function ENT:Initialize()
end

function ENT:DamageFX()
	local HP = self:GetHP()
	if HP == 0 or HP > self:GetMaxHP() * 0.5 then return end
	
	self.nextDFX = self.nextDFX or 0
	
	if self.nextDFX < CurTime() then
		self.nextDFX = CurTime() + 0.05
		
		local effectdata = EffectData()
			effectdata:SetOrigin( self:LocalToWorld( Vector(-397.16,0,260.93) ) )
		util.Effect( "lfs_blacksmoke", effectdata )
	end
end

local function DrawCircle( X, Y, radius )
	local segmentdist = 360 / ( 2 * math.pi * radius / 2 )
	
	for a = 0, 360, segmentdist do
		surface.DrawLine( X + math.cos( math.rad( a ) ) * radius, Y - math.sin( math.rad( a ) ) * radius, X + math.cos( math.rad( a + segmentdist ) ) * radius, Y - math.sin( math.rad( a + segmentdist ) ) * radius )
		
		surface.DrawLine( X + math.cos( math.rad( a ) ) * radius, Y - math.sin( math.rad( a ) ) * radius, X + math.cos( math.rad( a + segmentdist ) ) * radius, Y - math.sin( math.rad( a + segmentdist ) ) * radius )
	end
end

local zoom_mat = Material( "vgui/zoom" )

function ENT:LFSHudPaintPassenger( X, Y, ply )
	if ply == self:GetGunner() then
		local EyeAngles = ply:EyeAngles()
		
		local RearGunActive = self:GetGXHairRG()
		local WingTurretActive = self:GetGXHairWT()

		local X = ScrW() * 0.5
		local Y = ScrH() * 0.5

		if RearGunActive or WingTurretActive then
			surface.SetDrawColor( 255, 255, 255, 255 )
		else
			surface.SetDrawColor( 255, 0, 0, 255 )
		end
		
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
		
	elseif ply == self:GetBTGunnerL() then
		local ID = self:LookupAttachment( "muzzle_ballturret_left" )
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
		
	elseif ply == self:GetBTGunnerR() then
		local ID = self:LookupAttachment( "muzzle_ballturret_right" )
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

function ENT:LFSCalcViewFirstPerson( view, ply )
	return self:LFSCalcViewThirdPerson( view, ply, true )
end

function ENT:LFSCalcViewThirdPerson( view, ply, FirstPerson )
	local Pod = ply:GetVehicle()

	if ply == self:GetDriver() then
	
	elseif ply == self:GetGunner() then
		local radius = 800
		radius = radius + radius * Pod:GetCameraDistance()
		
		local StartPos = self:GetRotorPos() + view.angles:Up() * 250
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
		
	elseif ply == self:GetBTGunnerL() then
		local ID = self:LookupAttachment( "muzzle_ballturret_left" )
		local Muzzle = self:GetAttachment( ID )
		
		if Muzzle then
			local Pos,Ang = LocalToWorld( Vector(0,20,-45), Angle(270,0,-90), Muzzle.Pos, Muzzle.Ang )

			local fwd1 = ply:EyeAngles():Forward()
			local fwd2 = Ang:Forward()
			
			local Zoom = (fwd1 - fwd2):Length() < 0.7 and (ply:KeyDown( IN_ATTACK2 ) or ply:KeyDown( IN_ZOOM )) or false
			local Rate = FrameTime() * 5
			
			self.InterPoL = isnumber( self.InterPoL ) and self.InterPoL + math.Clamp((Zoom and 1 or 0) - self.InterPoL,-Rate,Rate) or 0
			
			view.angles = (fwd1 * (1 - self.InterPoL) + fwd2 * self.InterPoL):Angle()
			view.fov = 75 - 30 * self.InterPoL
			
			view.origin = Pos
			view.drawviewer = false
		end
		
	elseif ply == self:GetBTGunnerR() then
		local ID = self:LookupAttachment( "muzzle_ballturret_right" )
		local Muzzle = self:GetAttachment( ID )
		
		if Muzzle then
			local Pos,Ang = LocalToWorld( Vector(0,20,-45), Angle(270,0,-90), Muzzle.Pos, Muzzle.Ang )
			
			local fwd1 = ply:EyeAngles():Forward()
			local fwd2 = Ang:Forward()
			
			local Zoom = (fwd1 - fwd2):Length() < 0.7 and (ply:KeyDown( IN_ATTACK2 ) or ply:KeyDown( IN_ZOOM )) or false
			local Rate = FrameTime() * 5
			
			self.InterPoR = isnumber( self.InterPoR ) and self.InterPoR + math.Clamp((Zoom and 1 or 0) - self.InterPoR,-Rate,Rate) or 0
			
			view.angles = (fwd1 * (1 - self.InterPoR) + fwd2 * self.InterPoR):Angle()
			view.fov = 75 - 30 * self.InterPoR
			
			view.origin = Pos
			view.drawviewer = false
		end
	else
		view.angles = ply:GetVehicle():LocalToWorldAngles( ply:EyeAngles() )
		
		if FirstPerson then
			view.origin = view.origin + Pod:GetUp() * 40
		else
			view.origin = ply:GetShootPos() + Pod:GetUp() * 40
			
			local radius = 800
			radius = radius + radius * Pod:GetCameraDistance()
			
			local TargetOrigin = view.origin - view.angles:Forward() * radius
			
			local WallOffset = 4

			local tr = util.TraceHull( {
				start = view.origin,
				endpos = TargetOrigin,
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
	end
	
	return view
end

function ENT:ExhaustFX()
	local FullThrottle = self:GetThrottlePercent() >= 35
	
	if self.OldFullThrottle ~= FullThrottle then
		self.OldFullThrottle = FullThrottle
		if FullThrottle then 
			self:EmitSound( "LAATi_BOOST" )
		end
	end
end

function ENT:CanSound()
	self.NextSound = self.NextSound or 0
	return self.NextSound < CurTime()
end

function ENT:CanSound2()
	self.NextSound2 = self.NextSound2 or 0
	return self.NextSound2 < CurTime()
end

function ENT:DelayNextSound( fDelay )
	if not isnumber( fDelay ) then return end
	
	self.NextSound = CurTime() + fDelay
end

function ENT:DelayNextSound2( fDelay )
	if not isnumber( fDelay ) then return end
	
	self.NextSound2 = CurTime() + fDelay
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	if self.ENG then
		self.ENG:ChangePitch(  math.Clamp(math.Clamp(  80 + Pitch * 25, 50,255) + Doppler,0,255) )
		self.ENG:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0.5,1) )
	end
	
	if self.DIST then
		local ply = LocalPlayer()
		local DistMul = math.min( (self:GetPos() - ply:GetPos()):Length() / 8000, 1) ^ 2
		self.DIST:ChangePitch(  math.Clamp( 100 + Doppler * 0.2,0,255) )
		self.DIST:ChangeVolume( math.Clamp( -1.5 + Pitch * 6, 0.5,1) * DistMul )
	end
	
	local OnGround = self:GetIsGroundTouching()
	if self.OldGroundTouching == nil then self.OldGroundTouching = true end
	
	if OnGround ~= self.OldGroundTouching then
		self.OldGroundTouching = OnGround
		if not OnGround then
			if self:CanSound() then
				self:EmitSound( "LAATi_TAKEOFF" )
				self:DelayNextSound( 3 )
				self:DelayNextSound2( 1.5 )
			end
		else
			if self:CanSound2() then
				self:EmitSound( "LAATi_LANDING" )
				self:DelayNextSound( 1.5 )
				self:DelayNextSound2( 3 )
			end
		end
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound( self, "LAATi_ENGINE" )
		self.ENG:PlayEx(0,0)
		
		self.DIST = CreateSound( self, "LAATi_DIST" )
		self.DIST:PlayEx(0,0)
	else
		self:SoundStop()
	end
end

function ENT:OnRemove()
	self:SoundStop()
end

function ENT:SoundStop()
	if self.BTLOOP then
		self.BTLOOP:Stop()
	end
	
	if self.BTRLOOP then
		self.BTRLOOP:Stop()
	end
	
	if self.BTLLOOP then
		self.BTLLOOP:Stop()
	end
	
	if self.ENG then
		self.ENG:Stop()
	end
	
	if self.DIST then
		self.DIST:Stop()
	end
end

function ENT:AnimFins()
end

function ENT:AnimRotor()
	local ply = self:GetGunner()
	local Pod = self:GetGunnerSeat()
	if not IsValid( Pod ) or not IsValid( ply ) then return end
	
	local Yaw = math.Clamp( self:WorldToLocalAngles( ply:EyeAngles() ).y * 0.2,-55,55)
	
	if not self.BT_L_ID then
		self.BT_L_ID = self:LookupBone( "ballturret_wing_left" ) 
	else
		self:ManipulateBoneAngles( self.BT_L_ID, Angle(Yaw,0,0) )
	end
	
	if not self.BT_R_ID then
		self.BT_R_ID = self:LookupBone( "ballturret_wing_right" ) 
	else
		self:ManipulateBoneAngles( self.BT_R_ID, Angle(Yaw,0,0) )
	end
end

function ENT:AnimCabin()
	local FireWingTurret = self:GetWingTurretFire()
	if FireWingTurret ~= self.OldWingTurretFire then
		self.OldWingTurretFire = FireWingTurret
		
		if FireWingTurret then
			self:EmitSound("LAATi_BT_FIRE")
			
			self.BTLOOP = CreateSound( self, "LAATi_BT_FIRE_LOOP_CHAN1" )
			self.BTLOOP:Play()
			
			local effectdata = EffectData()
			effectdata:SetEntity( self )
			util.Effect( "laat_wingturret_projector", effectdata )
		else
			if self.BTLOOP then
				self.BTLOOP:Stop()
			end
		end
	end
	
	do
		local Fire = self:GetBTRFire()
		if Fire ~= self.OldFireBTR then
			self.OldFireBTR = Fire
			
			if Fire then
				self:EmitSound("LAATi_BT_FIRE")
				
				self.BTRLOOP = CreateSound( self, "LAATi_BT_FIRE_LOOP_CHAN2" )
				self.BTRLOOP:Play()
				
				local effectdata = EffectData()
				effectdata:SetEntity( self )
				util.Effect( "laat_ballturret_right_projector", effectdata )
			else
				if self.BTRLOOP then
					self.BTRLOOP:Stop()
				end
			end
		end
	end
	
	do
		local Fire = self:GetBTLFire()
		if Fire ~= self.OldFireBTL then
			self.OldFireBTL = Fire
			
			if Fire then
				self:EmitSound("LAATi_BT_FIRE")
				
				self.BTLLOOP = CreateSound( self, "LAATi_BT_FIRE_LOOP_CHAN3" )
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
end

function ENT:AnimLandingGear()
	local Tval = self:GetRearHatch() and 32 or 0
	local Rate = 50 * FrameTime()
	
	self.smRH = self.smRH and self.smRH + math.Clamp(Tval - self.smRH,-Rate,Rate) or 0
	
	if not self.HatchID then
		self.HatchID = self:LookupBone( "hatch" ) 
	else
		self:ManipulateBoneAngles( self.HatchID, Angle(0,-self.smRH,0) )	
	end
end

function ENT:Draw()
	self:DrawModel()
end
