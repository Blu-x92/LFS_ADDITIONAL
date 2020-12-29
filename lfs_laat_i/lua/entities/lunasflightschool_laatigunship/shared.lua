--DO NOT EDIT OR REUPLOAD THIS FILE

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_gunship" )

ENT.PrintName = "LAAT/i"
ENT.Author = "Luna"
ENT.Information = "Gunship/Troop Transport of the Galactic Republic"
ENT.Category = "[LFS] - Star Wars Pack"

ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.UseLAATiAnimHook = true

ENT.MDL = "models/blu/laat.mdl"

ENT.AITEAM = 2

ENT.Mass = 10000
ENT.Drag = 0

ENT.SeatPos = Vector(207,0,120)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxHealth = 4000

ENT.MaxPrimaryAmmo = 1400
ENT.MaxSecondaryAmmo = 26

ENT.MaxTurnPitch = 70
ENT.MaxTurnYaw = 70
ENT.MaxTurnRoll = 70

ENT.PitchDamping = 2
ENT.YawDamping = 2
ENT.RollDamping = 1

ENT.TurnForcePitch = 6000
ENT.TurnForceYaw = 6000
ENT.TurnForceRoll = 4000

ENT.RotorPos = Vector(210,0,130)

ENT.RPMThrottleIncrement = 180

ENT.MaxVelocity = 2400

ENT.MaxThrust = 5000

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 101
ENT.MaxThrustVtol = 400

--ENT.MaxShield = 200

function ENT:AddDataTables()
	self:NetworkVar( "Int",12, "DoorMode" )
	
	self:NetworkVar( "Bool",13, "WingTurretFire" )
	self:NetworkVar( "Vector",14, "WingTurretTarget" )
	self:NetworkVar( "Entity",15, "BTPodL" )
	self:NetworkVar( "Entity",16, "BTPodR" )
	self:NetworkVar( "Entity",17, "BTGunnerL" )
	self:NetworkVar( "Entity",18, "BTGunnerR" )
	self:NetworkVar( "Bool",19, "BTLFire" )
	self:NetworkVar( "Bool",20, "BTRFire" )
	self:NetworkVar( "Bool",21, "RearHatch" )
	self:NetworkVar( "Bool",22, "GXHairRG" )
	self:NetworkVar( "Bool",23, "GXHairWT" )
end

sound.Add( {
	name = "LAATi_FIRE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/laat/fire.mp3"
} )

sound.Add( {
	name = "LAATi_FIREMISSILE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/laat/fire_missile.mp3"
} )

sound.Add( {
	name = "LAATi_BT_FIRE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 100,
	pitch = {90, 110},
	sound = "lfs/laat/ballturret_fire.mp3"
} )

sound.Add( {
	name = "LAATi_BT_FIRE_LOOP_CHAN1",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 100,
	sound = "lfs/laat/ballturret_loop.wav"
} )

sound.Add( {
	name = "LAATi_BT_FIRE_LOOP_CHAN2",
	channel = CHAN_VOICE2,
	volume = 1.0,
	level = 100,
	sound = "lfs/laat/ballturret_loop.wav"
} )

sound.Add( {
	name = "LAATi_BT_FIRE_LOOP_CHAN3",
	channel = CHAN_VOICE,
	volume = 1.0,
	level = 100,
	sound = "lfs/laat/ballturret_loop.wav"
} )

sound.Add( {
	name = "LAATi_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 115,
	sound = "lfs/laat/loop.wav"
} )

sound.Add( {
	name = "LAATi_TAKEOFF",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = {"^lfs/laat/takeoff_1.wav","^lfs/laat/takeoff_2.wav"}
} )

sound.Add( {
	name = "LAATi_BOOST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = {"^lfs/laat/boost_1.wav","^lfs/laat/boost_2.wav"}
} )

sound.Add( {
	name = "LAATi_LANDING",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^lfs/laat/landing.wav"
} )

sound.Add( {
	name = "LAATi_DIST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^lfs/laat/dist.wav"
} )

hook.Add("CalcMainActivity", "!!!lfs_LAATi_passengeranims", function(ply)
	if not ply.lfsGetPlane then return end
	
	local Ent = ply:lfsGetPlane()
	
	if not IsValid( Ent ) then return end
	if not Ent.UseLAATiAnimHook then return end
	
	local Pod = ply:GetVehicle()
	
	if Pod == Ent:GetDriverSeat() or Pod == Ent:GetGunnerSeat() or Pod == Ent:GetBTPodL() or Pod == Ent:GetBTPodR() then return end
	
	if ply.m_bWasNoclipping then 
		ply.m_bWasNoclipping = nil 
		ply:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM ) 
		
		if CLIENT then 
			ply:SetIK( true )
		end 
	end 
	
	ply.CalcIdeal = ACT_STAND
	ply.CalcSeqOverride = ply:LookupSequence( "idle_all_02" )

	if ply:GetAllowWeaponsInVehicle() and IsValid( ply:GetActiveWeapon() ) then
		
		local holdtype = ply:GetActiveWeapon():GetHoldType()
		
		if holdtype == "smg" then 
			holdtype = "smg1"
		end

		local seqid = ply:LookupSequence( "idle_" .. holdtype )
		
		if seqid ~= -1 then
			ply.CalcSeqOverride = seqid
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end)

if SERVER then
	resource.AddSingleFile( "materials/effects/lfs_base/ballturret_projectorbeam.vmt" )
	resource.AddSingleFile( "materials/effects/lfs_base/ballturret_projectorbeam.vtf" )
end