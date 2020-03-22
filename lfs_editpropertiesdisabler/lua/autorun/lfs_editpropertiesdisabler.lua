hook.Add( "CanProperty", "!!!!lfsEditPropertiesDisabler", function( ply, property, ent )
	if ent.LFS and not ply:IsAdmin() and property == "editentity" then return false end
end )