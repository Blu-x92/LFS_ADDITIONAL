
local Materials = {
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

function EFFECT:Init( data )
	local vehicle = data:GetEntity()
	
	if not IsValid( vehicle ) then return end
	
	local ID = vehicle:LookupAttachment( "muzzle" )
	if ID == 0 then return end
	
	local Attachment = vehicle:GetAttachment( ID )

	local Dir = Attachment.Ang:Up()
	local emitter = ParticleEmitter( Attachment.Pos, false )

	for i = 0, 10 do
		local particle = emitter:Add( "effects/yellowflare", Attachment.Pos + Dir * i * 0.7 * math.random(1,2) * 0.5 )
		local Size = 5

		if particle then
			particle:SetVelocity( Dir * 800 )
			particle:SetDieTime( 0.1 )
			particle:SetStartAlpha( 255 * Size )
			particle:SetStartSize( math.max( math.random(10,24) - i * 0.5,0.1 ) * Size )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand( -1, 1 ) )
			particle:SetColor( 255,0,0 )
			particle:SetCollide( false )
		end

		local particle = emitter:Add( "effects/yellowflare", Attachment.Pos + Dir * i * 0.7 * math.random(1,2) * 0.5 )
		local Size = 2

		if particle then
			particle:SetVelocity( Dir * 800 )
			particle:SetDieTime( 0.1 )
			particle:SetStartAlpha( 255 * Size )
			particle:SetStartSize( math.max( math.random(10,24) - i * 0.5,0.1 ) * Size )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand( -1, 1 ) )
			particle:SetColor( 255,255,255 )
			particle:SetCollide( false )
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
