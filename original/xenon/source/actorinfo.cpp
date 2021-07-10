//-------------------------------------------------------------
//
// Class:	CActorInfo
//
// Author:	John M Phillips
//
// Started:	06/05/00
//
// Base:	None
//
// Derived:	None
//
//-------------------------------------------------------------

#include "game.h"

//-------------------------------------------------------------

CActorInfoList ActorInfoList;

//-------------------------------------------------------------

ActorInfo CActorInfoList::m_info_list[INFO_TOTAL] = {

	// pickups

	{	"ShieldPickup",				ACTOR_TYPE_PICKUP,	"PUShield.bmp",		32,	32,	16,	16,	8.f,  INFINITE_SHIELD,	50	},
	{	"SpeedPickup",				ACTOR_TYPE_PICKUP,	"PUSpeed.bmp",		32,	32,	16,	16,	8.f,  INFINITE_SHIELD,	50	},
	{	"WeaponPickup",				ACTOR_TYPE_PICKUP,	"PUWeapon.bmp",		32,	32,	16,	16,	8.f,  INFINITE_SHIELD,	50	},
	{	"CloakPickup",				ACTOR_TYPE_PICKUP,	"PUInvuln.bmp",		32,	32,	16,	16,	8.f,  INFINITE_SHIELD,	50	},
	{	"DivePickup",				ACTOR_TYPE_PICKUP,	"PUDive.bmp",		32,	32,	16,	16,	8.f,  INFINITE_SHIELD,	50	},
	{	"ScorePickup",				ACTOR_TYPE_PICKUP,	"PUScore.bmp",		32,	32,	16,	16,	8.f,  INFINITE_SHIELD,	50	},
	{	"ClonePickup",				ACTOR_TYPE_PICKUP,	"Clone.bmp",		32,	32,	16,	16,	8.f,  INFINITE_SHIELD,	50	},
	{	"WingtipPickup",			ACTOR_TYPE_PICKUP,	"Wingtip.bmp",		32,	64,	16,	32,	8.f,  INFINITE_SHIELD,	50	},
	{	"MissilePickup",			ACTOR_TYPE_PICKUP,	"PUMissil.bmp",		32,	32,	16,	16,	8.f,  INFINITE_SHIELD,	50	},
	{	"LaserPickup",				ACTOR_TYPE_PICKUP,	"PULaser.bmp",		32,	32,	16,	16,	8.f,  INFINITE_SHIELD,	50	},
	{	"LifePickup",				ACTOR_TYPE_PICKUP,	"PULife.bmp",		32,	32,	16,	16,	8.f,  INFINITE_SHIELD,	50	},

	// aliens

	{	"WallHugger",				ACTOR_TYPE_ALIEN,	"wallhugger.bmp",	64,	64,	32,	32,	8.f, 5,	20	},
	{	"SmallStandardAsteroid",	ACTOR_TYPE_ALIEN,	"SAster32.bmp",		32,	32,	16,	16,	16.f,1,	10	},
	{	"MediumStandardAsteroid",	ACTOR_TYPE_ALIEN,	"SAster64.bmp",		64,	64,	32,	32,	12.f,2,	20	},
	{	"BigStandardAsteroid",		ACTOR_TYPE_ALIEN,	"SAster96.bmp",		96,	96,	48,	48,	8.f, 3, 40	},
	{	"SmallHighDensityAsteroid",	ACTOR_TYPE_ALIEN,	"GAster32.bmp",		32,	32,	16,	16, 16.f, 2, 20	},
	{	"MediumHighDensityAsteroid",ACTOR_TYPE_ALIEN,	"GAster64.bmp",		64,	64,	32,	32,	12.f, 4, 40	},
	{	"BigHighDensityAsteroid",	ACTOR_TYPE_ALIEN,	"GAster96.bmp",		96,	96,	48,	48,  8.f, 4, 80	},
	{	"SmallIndestuctibleAsteroid",ACTOR_TYPE_ALIEN,	"MAster32.bmp",		32,	32,	16,	16,	16.f, INFINITE_SHIELD, 0	},
	{	"MediumIndestuctibleAsteroid",ACTOR_TYPE_ALIEN,	"MAster64.bmp",		64,	64,	32,	32,	12.f, INFINITE_SHIELD, 0	},
	{	"BigIndestuctibleAsteroid",ACTOR_TYPE_ALIEN,	"MAster96.bmp",		96,	96,	48,	48,	8.f, INFINITE_SHIELD, 0		},
	{	"Rusher",					ACTOR_TYPE_ALIEN,	"rusher.bmp",		64,	32,	32,	16,	16.f, 5, 30		},
	{	"Pod",						ACTOR_TYPE_ALIEN,	"pod.bmp",			96,	96,	48,	48,	8.f, 10, 100	},
	{	"Homer",					ACTOR_TYPE_ALIEN,	"Homing.bmp",		64,	64,	32,	32,	16.f, 5, 100	},
	{	"Drone",					ACTOR_TYPE_ALIEN,	"drone.bmp",		32,	32,	16, 16, 16.f, 1, 30		},
	{	"StandardLoner",			ACTOR_TYPE_ALIEN,	"LonerA.bmp",		64,	64,	32,	32,	16.f, 2, 30	},
	{	"MediumLoner",				ACTOR_TYPE_ALIEN,	"LonerB.bmp",		64,	64,	32,	32,	16.f, 4, 60	},
	{	"ArmouredLoner",			ACTOR_TYPE_ALIEN,	"LonerC.bmp",		64,	64,	32,	32, 16.f, 6, 90	},
	{	"OrganicGun",				ACTOR_TYPE_ALIEN,	"GShoot.bmp",		64,	64,	32,	32,	8.f, 5,	20	},

	// bullets

	{	"Missile",					ACTOR_TYPE_BULLET,	"missile.bmp",		16,16,8,8,0.f,INFINITE_SHIELD,0,0,0,1,2,3,10.f,10.f,10.f	},
	{	"HomingMissile",			ACTOR_TYPE_BULLET,	"hmissile.bmp",		32,32,16,16,0.f,INFINITE_SHIELD,0,0,0,1,2,3,5.f,5.f,5.f		},
	{	"Laser",					ACTOR_TYPE_BULLET,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0,0,0,2,4,6,20.f,20.f,20.f		},
	{	"HomerProjectile",			ACTOR_TYPE_ALIENBULLET,"HomProjc.bmp",	16,16,8,8,0.f,1,50,0,0,2,4,6,3.f,3.f,3.f					},
	{	"Spinner",					ACTOR_TYPE_ALIENBULLET,"EnWeap6.bmp",	16,16,8,8,16.f,INFINITE_SHIELD,0,0,0,1,2,3,5.f,5.f,5.f		},
	{	"Spore",					ACTOR_TYPE_ALIENBULLET,"SporesA.bmp",	16,16,8,8,8.f,1,5,0,0,2,4,6,1.5f,1.5f,1.5f },

	// weapons

	{	"MissileWeapon",			ACTOR_TYPE_WEAPON,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0,0.1f,0.25f	},
	{	"HomingMissileWeapon",		ACTOR_TYPE_WEAPON,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0,0.1f,0.25f	},
	{	"LaserWeapon",				ACTOR_TYPE_WEAPON,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0,0.1f,0.1f 	},
	{	"HomerProjectileWeapon",	ACTOR_TYPE_WEAPON,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0,5.f,5.f		},
	{	"SpinnerWeapon",			ACTOR_TYPE_WEAPON,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0,1.f,1.f		},

	// ship

	{	"Ship",						ACTOR_TYPE_SHIP,	"Ship2.bmp",		64,64,32,32,0.f,100,0	},

	// upgrades

	{	"Clone",					ACTOR_TYPE_UPGRADE,	"clone.bmp",		32,32,16,16,8.f,50,50	},
	{	"Wingtip",					ACTOR_TYPE_UPGRADE,	"Wingtip.bmp",		32,64,16,32,8.f,INFINITE_SHIELD,0	},
	
	// engines

	{	"ShipEngine",				ACTOR_TYPE_ENGINE,	"Burner1.bmp",		16,32,8,0,10.f,INFINITE_SHIELD,0	},
	{	"CloneEngine",				ACTOR_TYPE_ENGINE,	"Burner2.bmp",		32,32,16,0,10.f,INFINITE_SHIELD,0	},
	{	"RetroEngine",				ACTOR_TYPE_ENGINE,	"Retros.bmp",		32,32,16,16,10.f,INFINITE_SHIELD,0	},

	// effects

	{	"SmallExplosion",			ACTOR_TYPE_ALIEN,	"explode16.bmp",	16,16,8,8,40.f,INFINITE_SHIELD,0	},
	{	"MediumExplosion",			ACTOR_TYPE_ALIEN,	"explode32.bmp",	32,32,16,16,40.f,INFINITE_SHIELD,0	},
	{	"BigExplosion",				ACTOR_TYPE_ALIEN,	"explode64.bmp",	64,64,32,32,40.f,INFINITE_SHIELD,0	},
	{	"StandardDustEffect",		ACTOR_TYPE_EFFECT,	"SDust.bmp",		4,4,2,2,16.f,INFINITE_SHIELD,0	},
	{	"HighDensityDustEffect",	ACTOR_TYPE_EFFECT,	"GDust.bmp",		4,4,2,2,16.f,INFINITE_SHIELD,0	},
	{	"SmokeEffect",				ACTOR_TYPE_EFFECT,	"smoke.bmp",		32,32,16,16,8.f,INFINITE_SHIELD,0	},
	{	"Label",					ACTOR_TYPE_LABEL,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0 },

	// generators

	{	"DroneGenerator",			ACTOR_TYPE_WEAPON,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0	},
	{	"RusherGenerator",			ACTOR_TYPE_WEAPON,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0	},
	{	"SporeGenerator",			ACTOR_TYPE_WEAPON,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0	},

	// boss

	{	"BossMouth",				ACTOR_TYPE_BOSS,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0	},
	{	"BossEye",					ACTOR_TYPE_BOSS,	"bosseyes2.bmp",	32,32,16,16,0.f,INFINITE_SHIELD,0	},
	{	"BossControl",				ACTOR_TYPE_BOSS,	0,					0,0,0,0,0.f,INFINITE_SHIELD,0	}
};

//-------------------------------------------------------------

bool CActorInfoList::load(const char *filename)
{
	gsCFile::setDirectory(DIRECTORY_ROOT);

	gsCIniFile file;

	if (!file.open(filename))
		return false;

	if (strcmp(file.readString("Title","Game","UNKNOWN"),"Xenon") != 0 ||
		file.readInt("Title","Version",0) != 1) {
		file.close();
		return false;
		}

	for (int i = 0; i < INFO_TOTAL; i++) {

		ActorInfo *info = &m_info_list[i];

		const char *name = info->m_name;

		const char *type = file.readString(name,"Type","UNKNOWN");

		if		(strcmp(type,"Ship") == 0) info->m_type = ACTOR_TYPE_SHIP;
		else if (strcmp(type,"Bullet") == 0) info->m_type = ACTOR_TYPE_BULLET;
		else if (strcmp(type,"Upgrade") == 0) info->m_type = ACTOR_TYPE_UPGRADE;
		else if (strcmp(type,"Engine") == 0) info->m_type = ACTOR_TYPE_ENGINE;
		else if (strcmp(type,"Weapon") == 0) info->m_type = ACTOR_TYPE_WEAPON;
		else if (strcmp(type,"Pickup") == 0) info->m_type = ACTOR_TYPE_PICKUP;
		else if (strcmp(type,"Alien") == 0) info->m_type = ACTOR_TYPE_ALIEN;
		else if (strcmp(type,"AlienBullet") == 0) info->m_type = ACTOR_TYPE_ALIENBULLET;
		else if (strcmp(type,"Label") == 0) info->m_type = ACTOR_TYPE_LABEL;
		else if (strcmp(type,"Effect") == 0) info->m_type = ACTOR_TYPE_EFFECT;
		else {
			file.close();
			return false;
			}

		const char *filename = file.readString(name,"ImageFilename","NONE");

		if (strcmp(filename,"NONE") == 0)
			info->m_filename = 0;
		else
			info->m_filename = strdup(filename);

		info->m_tile_width = file.readInt(name,"TileWidth",0);
		info->m_tile_height = file.readInt(name,"TileHeight",0);
		info->m_hotspot_x = file.readInt(name,"HotspotX",0);
		info->m_hotspot_y = file.readInt(name,"HotspotY",0);

		info->m_initial_shield = file.readInt(name,"InitialShield",INFINITE_SHIELD);
		info->m_kill_bonus = file.readInt(name,"KillBonus",0);

		info->m_fire_delay = file.readFloat(name,"FireDelay",0.f);
		info->m_autofire_delay = file.readFloat(name,"AutofireDelay",0.f);

		info->m_energy[0] = file.readInt(name,"EnergyGrade0",0);
		info->m_energy[1] = file.readInt(name,"EnergyGrade1",0);
		info->m_energy[2] = file.readInt(name,"EnergyGrade2",0);

		info->m_speed[0] = file.readFloat(name,"SpeedGrade0",0);
		info->m_speed[1] = file.readFloat(name,"SpeedGrade1",0);
		info->m_speed[2] = file.readFloat(name,"SpeedGrade2",0);
		}

	file.close();

	return true;
}

//-------------------------------------------------------------

bool CActorInfoList::save(const char  *filename)
{
	gsCFile::setDirectory(DIRECTORY_ROOT);

	gsCIniFile file;

	if (!file.open(filename))
		return false;

	file.writeString("Title","Game","Xenon");
	file.writeString("Title","Version","1");

	for (int i = 0; i < INFO_TOTAL; i++) {
		ActorInfo *info = &m_info_list[i];

		const char *name = info->m_name;

		switch (info->m_type) {
			case ACTOR_TYPE_SHIP:			file.writeString(name,"Type","Ship");		break;
			case ACTOR_TYPE_BULLET:			file.writeString(name,"Type","Bullet");		break;
			case ACTOR_TYPE_UPGRADE:		file.writeString(name,"Type","Upgrade");	break;
			case ACTOR_TYPE_ENGINE:			file.writeString(name,"Type","Engine");		break;
			case ACTOR_TYPE_WEAPON:			file.writeString(name,"Type","Weapon");		break;
			case ACTOR_TYPE_PICKUP:			file.writeString(name,"Type","Pickup");		break;
			case ACTOR_TYPE_ALIEN:			file.writeString(name,"Type","Alien");		break;
			case ACTOR_TYPE_ALIENBULLET:	file.writeString(name,"Type","AlienBullet");	break;
			case ACTOR_TYPE_LABEL:			file.writeString(name,"Type","Label");		break;
			case ACTOR_TYPE_EFFECT:			file.writeString(name,"Type","Effect");		break;
			}

		if (info->m_filename) {
			file.writeString(name,"ImageFilename",info->m_filename);
			file.writeInt(name,"TileWidth",info->m_tile_width);
			file.writeInt(name,"TileHeight",info->m_tile_height);
			file.writeInt(name,"HotspotX",info->m_hotspot_x);
			file.writeInt(name,"HotspotY",info->m_hotspot_y);
			file.writeFloat(name,"AnimationRate",info->m_anim_rate);
			}
		else
			file.writeString(name,"ImageFilename","NONE");

		if (info->m_initial_shield != INFINITE_SHIELD)
			file.writeInt(name,"InitialShield",info->m_initial_shield);

		file.writeInt(name,"KillBonus",info->m_kill_bonus);

		if (info->m_type == ACTOR_TYPE_WEAPON) {
			file.writeFloat(name,"FireDelay",info->m_fire_delay);
			file.writeFloat(name,"AutofireDelay",info->m_autofire_delay);
			}

		if (info->m_type == ACTOR_TYPE_BULLET ||
			info->m_type == ACTOR_TYPE_ALIENBULLET) {
			file.writeInt(name,"EnergyGrade0",info->m_energy[0]);
			file.writeInt(name,"EnergyGrade1",info->m_energy[1]);
			file.writeInt(name,"EnergyGrade2",info->m_energy[2]);
			file.writeFloat(name,"SpeedGrade0",info->m_speed[0]);
			file.writeFloat(name,"SpeedGrade1",info->m_speed[1]);
			file.writeFloat(name,"SpeedGrade2",info->m_speed[2]);
			}
		}

	file.close();

	return true;
}

//-------------------------------------------------------------
