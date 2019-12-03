--DO NOT EDIT OR REUPLOAD THIS FILE

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_gunship" )

ENT.PrintName = "LAAT/c"
ENT.Author = "Blu"
ENT.Information = ""
ENT.Category = "[LFS]"

ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.UseLAATiAnimHook = true

ENT.MDL = "models/blu/laat_c.mdl"

ENT.AITEAM = 2

ENT.Mass = 10000
ENT.Drag = 0

ENT.SeatPos = Vector(207,0,120)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxHealth = 4000

ENT.MaxPrimaryAmmo = 800
ENT.MaxSecondaryAmmo = -1

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
ENT.VtolAllowInputBelowThrottle = 100
ENT.MaxThrustVtol = 400

--ENT.MaxShield = 200

function ENT:AddDataTables()
	self:NetworkVar( "Bool",22, "GXHairRG" )
end
