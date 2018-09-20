#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required


static Handle hCvar_fFallVec = null;
static float fMaxFallVec;

public Plugin myinfo =
{
	name = "High_Impact_Ragdoll_Deaths",
	author = "Lux",
	description = "High impact falls that kill you as a survivor will now ragdoll and no defibbing.",
	version = "1.0",
	url = "-"
};

public void OnPluginStart()
{
	hCvar_fFallVec = FindConVar("survivor_incap_max_fall_damage");
	if(hCvar_fFallVec == null)
		SetFailState("Unable to find survivor_incap_max_fall_damage");
	HookConVarChange(hCvar_fFallVec, eCvarsChanged);
	fMaxFallVec = float(GetConVarInt(hCvar_fFallVec));
}

public void eCvarsChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	fMaxFallVec = float(GetConVarInt(hCvar_fFallVec));
}


public void OnClientPutInServer(int iClient)
{
	SDKHook(iClient, SDKHook_OnTakeDamageAlivePost, OnTakeDamagePost);
}

public void OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	if(damagetype & ~DMG_FALL)
		return;
	
	if(GetClientTeam(victim) != 2 && IsFakeClient(victim))
	{
		SDKUnhook(victim, SDKHook_OnTakeDamageAlivePost, OnTakeDamagePost);
		return;
	}
	
	if(fMaxFallVec > GetEntPropFloat(victim, Prop_Send, "m_flFallVelocity"))
		return;
	
	SetEntProp(victim, Prop_Send, "m_isFallingFromLedge", 1, 1);
}