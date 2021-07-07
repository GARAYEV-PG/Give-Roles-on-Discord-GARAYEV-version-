#include <lk>

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <discord_utilities>
#include <vip_core>

KeyValues KV;

public Plugin myinfo = 
{
    name 			= "Give Roles",
    author 			= "GARAYEV",
    description 	= "Give roles on discord for vip/admin group",
    version 		= "1.0.3",
    url 			= "Discord: GARAYEV#9999"
};

public void OnPluginStart()
{
    HookEvent("player_connect_full", Event_PlayerConnect);

    char szPath[PLATFORM_MAX_PATH];
    KV = new KeyValues("GiveRoles");
    BuildPath(Path_SM, szPath, sizeof(szPath), "configs/discord_roles.ini");

    if(!KV.ImportFromFile(szPath))
        SetFailState("[Give Roles] - Файл конфигураций не найден");
}

public void Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
    char szVip[64], szAdm[64], szRole[64];
    int client = GetClientOfUserId(event.GetInt("userid"));

    KV.Rewind();

    if(KV.GotoFirstSubKey(true))
    {
        do
        {
            if(KV.GetSectionName(szRole, sizeof(szRole)))//Читаем, если есть "485384583485...."
            {
                KV.GetString("vip_group", szVip, sizeof(szVip), "");
                KV.GetString("admin_group", szAdm, sizeof(szAdm), "");

                if(LK_GetClientAllCash(client) >= KV.GetNum("lk", 1))
                    DU_AddRole(client, szRole);

                if(szVip[0])
                {
                    if(VIP_IsClientVIP(client))
                    {
                        if(VIP_IsValidVIPGroup(szVip))
                        {
                            char szBuf[64];
                            VIP_GetClientVIPGroup(client, szBuf, sizeof(szBuf));//Получаем ВИП группу игрока
                            if(StrEqual(szBuf, szVip, false))
                                DU_AddRole(client, szRole);
                        }
                        else 
                            LogError("[Give Roles] - \"%s\" такой VIP группы не существует");
                    }
                }

                if(szAdm[0])
                {
                    AdminId iAdminID = GetUserAdmin(client);
                    if(iAdminID)
                    {
                        int iGroups = GetAdminGroupCount(iAdminID);
                        if(iGroups)
                        {
                            char szBuf[64];
                            for(int i = 0; i < iGroups; i++)//i++, не ++i. Так как индекс групп начинается с 0, наверное. Стоит проверить. Если с 1, то тогда ++i
                                if(GetAdminGroup(iAdminID, i, szBuf, sizeof(szBuf)) != INVALID_GROUP_ID)
                                    if(StrEqual(szBuf, szAdm, false))
                                        DU_AddRole(client, szRole);
                        }
                    }
                }
            }
        }
        while(KV.GotoNextKey(true));
    }
}