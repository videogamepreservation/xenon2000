//-------------------------------------------------------------
//
// Class:	CAlien
//
// Author:	John M Phillips
//
// Started:	06/05/00
//
// Base:	CActor
//
// Derived:	CAsteroid
//
//-------------------------------------------------------------

#include "game.h"

//-------------------------------------------------------------

void CAlien::onLeavingScreen()
{
	kill();
}

//-------------------------------------------------------------
