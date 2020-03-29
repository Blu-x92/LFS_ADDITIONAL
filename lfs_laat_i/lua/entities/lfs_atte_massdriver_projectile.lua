--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile()

ENT.Type            = "anim"

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "Attacker" )
	self:NetworkVar( "Entity",1, "Inflictor" )
	self:NetworkVar( "Entity",2, "RearEnt" )
	self:NetworkVar( "Float",0, "StartVelocity" )
end

if SERVER then
	function ENT:SpawnFunction( ply, tr, ClassName )

		if not tr.Hit then return end

		local ent = ents.Create( ClassName )
		ent:SetPos( tr.HitPos + tr.HitNormal * 20 )
		ent:Spawn()
		ent:Activate()

		return ent

	end

	function ENT:BlindFire()
		local pObj = self:GetPhysicsObject()
		
		if IsValid( pObj ) then
			pObj:SetVelocityInstantaneous( self:GetForward() * (self:GetStartVelocity() + 3000) )
		end

		local trace = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetForward() * (self:GetVelocity():Length() * FrameTime() + 25),
			filter = {self,self:GetInflictor(), self:GetRearEnt()}
		} )

		if trace.Hit then
			self:SetPos( trace.HitPos )
			self:ProjDetonate()
		end
	end

	function ENT:Initialize()	
		self:SetModel( "models/weapons/w_missile_launch.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:PhysWake()
		
		local pObj = self:GetPhysicsObject()
		
		if IsValid( pObj ) then
			pObj:EnableGravity( false ) 
			pObj:SetMass( 1 ) 
		end
		
		self.SpawnTime = CurTime()
	end

	function ENT:ProjDetonate()
		local Inflictor = self:GetInflictor()
		local Attacker = self:GetAttacker()
		util.BlastDamage( IsValid( Inflictor ) and Inflictor or Entity(0), IsValid( Attacker ) and Attacker or Entity(0), self:GetPos(),500,200)
		
		self:Remove()
	end

	function ENT:Think()	
		local curtime = CurTime()
		self:NextThink( curtime )

		self:BlindFire()

		if self.Explode then
			self:ProjDetonate()
		end
		
		if (self.SpawnTime + 12) < curtime then
			self:Remove()
		end
		
		return true
	end

	local IsThisSimfphys = {
		["gmod_sent_vehicle_fphysics_base"] = true,
		["gmod_sent_vehicle_fphysics_wheel"] = true,
	}
	
	function ENT:PhysicsCollide( data )
		local HitEnt = data.HitEntity
		
		if IsValid( HitEnt ) and not self.Explode then 
			local Class = HitEnt:GetClass():lower()

			if IsThisSimfphys[ Class ] then
				local Pos = self:GetPos()
				
				if Class == "gmod_sent_vehicle_fphysics_wheel" then
					HitEnt = HitEnt:GetBaseEnt()
				end

				local effectdata = EffectData()
					effectdata:SetOrigin( Pos )
					effectdata:SetNormal( -self:GetForward() )
				util.Effect( "manhacksparks", effectdata, true, true )

				local dmginfo = DamageInfo()
					dmginfo:SetDamage( 1000 )
					dmginfo:SetAttacker( IsValid( self:GetAttacker() ) and self:GetAttacker() or self )
					dmginfo:SetDamageType( DMG_DIRECT )
					dmginfo:SetInflictor( self ) 
					dmginfo:SetDamagePosition( Pos ) 
				HitEnt:TakeDamageInfo( dmginfo )
				
				sound.Play( "Missile.ShotDown", Pos, 140)
			end
		end
		
		self.Explode = true
	end

	function ENT:OnTakeDamage( dmginfo )	
	end
else
	function ENT:Initialize()	
		self.Emitter = ParticleEmitter( self:GetPos(), false )
		
		self.Materials = {
			"particle/smokesprites_0001",
			"particle/smokesprites_0002",
			"particle/smokesprites_0003",
			"particle/smokesprites_0004",
			"particle/smokesprites_0005",
			"particle/smokesprites_0006",
			"particle/smokesprites_0007",
			"particle/smokesprites_0008",
			"particle/smokesprites_0009",
			"particle/smokesprites_0010",
			"particle/smokesprites_0011",
			"particle/smokesprites_0012",
			"particle/smokesprites_0013",
			"particle/smokesprites_0014",
			"particle/smokesprites_0015",
			"particle/smokesprites_0016"
		}
		
		self.snd = CreateSound(self, "ambient/machines/combine_shield_touch_loop1.wav")
		self.snd:Play()
	end

	local mat = Material( "sprites/light_glow02_add" )
	function ENT:Draw()
		self:DrawModel()

		local pos = self:GetPos()


		local r = 0
		local g = 127
		local b = 255
		
		render.SetMaterial( mat )

		for i =0,10 do
			local Size = (16 - i) * 16 + math.random(-5,5)
			render.DrawSprite( pos - self:GetForward() * i * 10 + VectorRand(), Size, Size, Color( r, g, b, 255 ) )
		end

		render.DrawSprite( pos, 128, 128, Color( r, g, b, 255 ) )
	end

	function ENT:Think()
		local curtime = CurTime()
		
		self.NextFX = self.NextFX or 0
		
		if self.NextFX < curtime then
			self.NextFX = curtime + 0.02
			
			local pos = self:LocalToWorld( Vector(-8,0,0) )
		end
		
		return true
	end

	function ENT:OnRemove()
		if self.snd then
			self.snd:Stop()
		end
		
		local Pos = self:GetPos()
		
		self:Explosion( Pos + self:GetVelocity() / 20 )
		
		local random = math.random(1,2)
		
		sound.Play( "Explo.ww2bomb", Pos, 95, 140, 1 )
		
		if self.Emitter then
			self.Emitter:Finish()
		end
	end

	function ENT:Explosion( pos )
		local emitter = self.Emitter
		if not emitter then return end
		
		for i = 0,60 do
			local particle = emitter:Add( self.Materials[math.random(1,table.Count( self.Materials ))], pos )
			
			if particle then
				particle:SetVelocity( VectorRand(-1,1) * 600 )
				particle:SetDieTime( math.Rand(4,6) )
				particle:SetAirResistance( math.Rand(200,600) ) 
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( math.Rand(10,30) )
				particle:SetEndSize( math.Rand(80,120) )
				particle:SetRoll( math.Rand(-1,1) )
				particle:SetColor( 50,50,50 )
				particle:SetGravity( Vector( 0, 0, 100 ) )
				particle:SetCollide( false )
			end
		end
		
		for i = 0, 40 do
			local particle = emitter:Add( "sprites/flamelet"..math.random(1,5), pos )
			
			if particle then
				particle:SetVelocity( VectorRand(-1,1) * 500 )
				particle:SetDieTime( 0.14 )
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( 10 )
				particle:SetEndSize( math.Rand(30,60) )
				particle:SetEndAlpha( 100 )
				particle:SetRoll( math.Rand( -1, 1 ) )
				particle:SetColor( 200,150,150 )
				particle:SetCollide( false )
			end
		end
		
		local dlight = DynamicLight( math.random(0,9999) )
		if dlight then
			dlight.pos = pos
			dlight.r = 255
			dlight.g = 180
			dlight.b = 100
			dlight.brightness = 8
			dlight.Decay = 2000
			dlight.Size = 200
			dlight.DieTime = CurTime() + 0.1
		end
	end
end