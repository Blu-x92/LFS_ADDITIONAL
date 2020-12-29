--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile()

ENT.Type            = "anim"

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "Attacker" )
	self:NetworkVar( "Entity",1, "Inflictor" )
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
			self.smv = self.smv and self.smv + (VectorRand() * 0.5 - self.smv) * FrameTime() or Vector(0,0,0)
			pObj:SetVelocityInstantaneous( (self:GetForward() + self.smv) * 8000 )
		end

		local Vel = self:GetVelocity()

		if not self.Filter then
			self.Filter = {}
	
			table.insert( self.Filter, self )

			local inflictor = self:GetInflictor()

			if IsValid( inflictor ) then
				local filterents = inflictor.FilterEnts
				if istable( filterents ) then
					for _, ent in pairs( filterents ) do
						table.insert( self.Filter, ent )
					end
				end
			end
		end

		local trace = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() + Vel:GetNormalized() * (Vel:Length() * FrameTime() + 25),
			filter = self.Filter
		} )

		if trace.Hit then
			self:SetPos( trace.HitPos )
			self:ProjDetonate()
			self:simfphysDamage( trace.Entity )
			self:LFSDamage( trace.Entity )
		end
	end

	function ENT:Initialize()	
		self:SetModel( "models/weapons/w_missile_launch.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:PhysWake()
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		
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
		util.BlastDamage( IsValid( Inflictor ) and Inflictor or Entity(0), IsValid( Attacker ) and Attacker or Entity(0), self:GetPos(),300,150)

		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
		util.Effect( "lfs_aat_missile_explosion", effectdata )

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

	function ENT:simfphysDamage( HitEnt )
		if not IsValid( HitEnt ) then return end

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
				dmginfo:SetDamage( 250 )
				dmginfo:SetAttacker( IsValid( self:GetAttacker() ) and self:GetAttacker() or self )
				dmginfo:SetDamageType( DMG_DIRECT )
				dmginfo:SetInflictor( self ) 
				dmginfo:SetDamagePosition( Pos ) 
			HitEnt:TakeDamageInfo( dmginfo )
			
			sound.Play( "Missile.ShotDown", Pos, 140)
		end
	end

	function ENT:LFSDamage( HitEnt )
		if not IsValid( HitEnt ) then return end

		if not HitEnt.LFS and not HitEnt.IdentifiesAsLFS then return end

		local Pos = self:GetPos()

		local effectdata = EffectData()
			effectdata:SetOrigin( Pos )
			effectdata:SetNormal( -self:GetForward() )
		util.Effect( "manhacksparks", effectdata, true, true )

		local dmginfo = DamageInfo()
			dmginfo:SetDamage( 50 )
			dmginfo:SetAttacker( IsValid( self:GetAttacker() ) and self:GetAttacker() or self )
			dmginfo:SetDamageType( DMG_DIRECT )
			dmginfo:SetInflictor( self ) 
			dmginfo:SetDamagePosition( Pos ) 
		HitEnt:TakeDamageInfo( dmginfo )

		sound.Play( "Missile.ShotDown", Pos, 140)
	end

	function ENT:PhysicsCollide( data )
		self.Explode = true
	end

	function ENT:OnTakeDamage( dmginfo )	
	end
else
	function ENT:Initialize()	
		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetEntity( self )
		util.Effect( "lfs_aat_missile_trail", effectdata )
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:Think()
	end

	function ENT:OnRemove()
	end
end