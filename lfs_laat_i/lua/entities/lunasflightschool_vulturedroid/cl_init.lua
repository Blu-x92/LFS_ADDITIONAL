--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

function ENT:Initialize()	
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	
	self.nextEFX = self.nextEFX or 0
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)
	
	local Driver = self:GetDriver()
	if IsValid( Driver ) then
		local W = Driver:lfsGetInput( "+THROTTLE" )
		if W ~= self.oldW then
			self.oldW = W
			if W then
				self.BoostAdd = 40
			end
		end
	end
	
	self.BoostAdd = self.BoostAdd and (self.BoostAdd - self.BoostAdd * FrameTime()) or 0
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	if self.ENG then
		self.ENG:ChangePitch(  math.Clamp(math.Clamp(  60 + Pitch * 50, 80,255) + Doppler,0,255) )
		self.ENG:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0.5,1) )
	end
	
	if self.DIST then
		self.DIST:ChangePitch(  math.Clamp(math.Clamp(  Pitch * 100, 50,255) + Doppler * 1.25,0,255) )
		self.DIST:ChangeVolume( math.Clamp( -1.5 + Pitch * 6, 0.5,1) * (LocalPlayer():InVehicle() and 0.8 or 0.5) )
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound( self, "VULTURE_ENGINE" )
		self.ENG:PlayEx(0,0)
		
		self.DIST = CreateSound( self, "VULTURE_DIST" )
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
end

function ENT:AnimFins()
end

function ENT:AnimRotor()
end

function ENT:AnimCabin()
end

function ENT:AnimLandingGear()
end


local mat = Material( "sprites/light_glow02_add" )
function ENT:Draw()
	self:DrawModel()
	
	if not self:GetEngineActive() then return end
	
	cam.Start3D2D( self:LocalToWorld( Vector(-36.2,-62.6,0) ), self:LocalToWorldAngles( Angle(0,299,90) ), 1 )
		draw.NoTexture()
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRectRotated( -11, -1.5, 19.7, 6 , -3.4 )
		surface.DrawTexturedRectRotated( -11, 1.5, 19.7, 6 , 3.4 )
	cam.End3D2D()
	
	cam.Start3D2D( self:LocalToWorld( Vector(-36.2,62.6,0) ), self:LocalToWorldAngles( Angle(0,61,-90) ), 1 )
		draw.NoTexture()
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRectRotated( -11, -1.5, 19.7, 6 , -3.4 )
		surface.DrawTexturedRectRotated( -11, 1.5, 19.7, 6 , 3.4 )
	cam.End3D2D()
	
	if not istable( self.FxPos ) then
		self.FxPos = {
			Vector(-49.5,-45.31,1.9),
			Vector(-47,-48.39,1.8),
			Vector(-45,-51.55,1.7),
			Vector(-43,-54.71,1.6),
			Vector(-41,-57.97,1.5),
			Vector(-39,-60.82,1.4),
			Vector(-49.5,45.31,1.9),
			Vector(-47,48.39,1.8),
			Vector(-45,51.55,1.7),
			Vector(-43,54.71,1.6),
			Vector(-41,57.97,1.5),
			Vector(-39,60.82,1.4),
			Vector(-49.5,-45.31,-1.9),
			Vector(-47,-48.39,-1.8),
			Vector(-45,-51.55,-1.7),
			Vector(-43,-54.71,-1.6),
			Vector(-41,-57.97,-1.5),
			Vector(-39,-60.82,-1.4),
			Vector(-49.5,45.31,-1.9),
			Vector(-47,48.39,-1.8),
			Vector(-45,51.55,-1.7),
			Vector(-43,54.71,-1.6),
			Vector(-41,57.97,-1.5),
			Vector(-39,60.82,-1.4),
		}
	end
	
	local Boost = self.BoostAdd or 0
	local Size = 30 + (self:GetRPM() / self:GetLimitRPM()) * 15 + Boost
	
	for _, v in pairs( self.FxPos ) do
		local pos = self:LocalToWorld( v )
		render.SetMaterial( mat )
		render.DrawSprite( pos, Size, Size, Color( 38, 0, 230, 255) )
	end
end
