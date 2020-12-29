--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")


function ENT:LFSCalcViewFirstPerson( view, ply ) -- modify first person camera view here
	if ply == self:GetDriver() then
		view.origin = view.origin + self:GetForward() * 37 + self:GetUp() * 8
		return view
	end

	return view
end

function ENT:Initialize()	
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	
	self.nextEFX = self.nextEFX or 0

	local FullThrottle = self:GetThrottlePercent() >= 35

	if self.OldFullThrottle ~= FullThrottle then
		self.OldFullThrottle = FullThrottle
		if FullThrottle then 
			self.BoostAdd = 200
		end
	end

	self.BoostAdd = self.BoostAdd and (self.BoostAdd - self.BoostAdd * FrameTime()) or 0
	
	if self.nextEFX < CurTime() then
		self.nextEFX = CurTime() + 0.01
		
		local emitter = ParticleEmitter( self:GetPos(), false )
		local Pos = {
			[0] = Vector(-155,0,76.85),
			[1] = Vector(-155,0,41.82),
		}
		if emitter then
			local Mirror = false
			for i = 0,1 do
				local vOffset = self:LocalToWorld( Pos[i] )
				local vNormal = -self:GetForward()

				vOffset = vOffset + vNormal * 5

				local particle = emitter:Add( "effects/muzzleflash2", vOffset )
				if not particle then return end

				particle:SetVelocity( vNormal * math.Rand(500,1000) + self:GetVelocity() )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.1 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand(15,25) )
				particle:SetEndSize( math.Rand(0,10) )
				particle:SetRoll( math.Rand(-1,1) * 100 )
				
				particle:SetColor( 255, 200, 50 )
			
				Mirror = true
			end
			
			emitter:Finish()
		end
	end
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	if self.ENG then
		self.ENG:ChangePitch(  math.Clamp(math.Clamp(  70 + Pitch * 50, 50,255) + Doppler,0,255) )
		self.ENG:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0.5,1) )
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound( self, "VWING_ENGINE" )
		self.ENG:PlayEx(0,0)
	else
		self:SoundStop()
	end
end

function ENT:OnRemove()
	self:SoundStop()
end

function ENT:SoundStop()
	if self.ENG then
		self.ENG:Stop()
	end
end

function ENT:AnimFins()
	self.SMLG = self.SMLG and self.SMLG + (self:GetLGear() - self.SMLG) * FrameTime() * 10 or 1
	
	self:SetPoseParameter( "wings", 1 - self.SMLG )
	self:InvalidateBoneCache()
end

function ENT:AnimRotor()
end

function ENT:AnimCabin()
end

function ENT:AnimLandingGear()
end

local mat = Material( "sprites/light_glow02_add" )
local circle = Material( "vgui/circle" )
function ENT:Draw()
	self:DrawModel()

	if not self:GetEngineActive() then return end

	cam.Start3D2D( self:LocalToWorld( Vector(-136,0,76.85) ), self:LocalToWorldAngles( Angle(-90,0,0) ), 1 )
		surface.SetDrawColor( 255, 220, 150, 255 )
		surface.SetMaterial( circle )
		surface.DrawTexturedRectRotated( 0, 0, 20, 20 , 0 )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( mat )
		surface.DrawTexturedRectRotated( 0, 0, 20, 20 , 0 )
	cam.End3D2D()
	
	cam.Start3D2D( self:LocalToWorld( Vector(-136,0,41.82) ), self:LocalToWorldAngles( Angle(-90,0,0) ), 1 )
		surface.SetDrawColor( 255, 220, 150, 255 )
		surface.SetMaterial( circle )
		surface.DrawTexturedRectRotated( 0, 0, 20, 20 , 0 )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( mat )
		surface.DrawTexturedRectRotated( 0, 0, 20, 20 , 0 )
	cam.End3D2D()

end
