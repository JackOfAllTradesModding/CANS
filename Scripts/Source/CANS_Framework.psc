ScriptName CANS_Framework Extends Quest
{CANS Revamped framework. Literally rewritten from scratch.}

;Stores ModNames in 3 arrays, max of 384. The odds of ever reaching that are bizarre and insane.
;Individual weights will be stored in a global list via storageutil. 
;As Will Category info. Global Values can suck a dick.

Import StorageUtil

Quest Property CANS Auto; The quest that controls everything.
MagicEffect Property CANS_Manager Auto; The Effect that actually handles the math and updates
Spell Property CANS_Application Auto; The spell that applies the Effect
CANS_Core Property Core Auto; The script that makes up the Effect

Bool Property CANS_Tracelogging = False Auto; Boolean to handle tracelogging
Bool Property CANS_Override = False Auto; Whether Overrides are enabled by the user or not.
Bool Property MaxBellyEnabled = True Auto; Whether the user has enabled the maximum scale options
Bool Property MaxBreastEnabled = True Auto;
Bool Property MaxButtEnabled = True Auto;

Float Property MaxBellySize = 7.0 Auto; Max scales set by the user. Irrelevant if disabled
Float Property MaxBreastSize = 7.0 Auto;
Float Property MaxButtSize = 7.0 Auto;

Float Property PregnancyBellyWeight = 1.0 Auto; Categorical weights for each section
Float Property PregnancyBreastWeight = 1.0 Auto;
Float Property PregnancyButtWeight = 1.0 Auto;
Float Property MilkingBellyWeight = 1.0 Auto;
Float Property MilkingBreastWeight = 1.0 Auto;
Float Property MilkingButtWeight = 1.0 Auto;
Float Property InflationBellyWeight = 1.0 Auto;
Float Property InflationBreastWeight = 1.0 Auto;
Float Property InflationButtWeight = 1.0 Auto;
Float Property CumflationBellyWeight = 1.0 Auto;
Float Property CumflationBreastWeight = 1.0 Auto;
Float Property CumflationButtWeight = 1.0 Auto;
Float Property MiscCatBellyWeight = 1.0 Auto;
Float Property MiscCatBreastWeight = 1.0 Auto;
Float Property MiscCatButtWeight = 1.0 Auto;
Float Property UnCatBellyWeight = 1.0 Auto;
Float Property UnCatBreastWeight = 1.0 Auto;
Float Property UnCatButtWeight = 1.0 Auto;

Float Property UpdateDelay = 1.0 Auto;

Float Property DecreasingAdditiveFactor = 2.0 Auto; Important for the new additive method. Some wicked cool math down below with this

Int Property CANS_Belly_Mode = 0 Auto; What mode it is using for the final calculation
Int Property CANS_Breast_Mode = 0 Auto; Separate mode feature requested.
Int Property CANS_Butt_Mode = 0 Auto;
Int Property CANS_WeightingMode = 2 Auto; how the weighting is determined for the final calculation

String[] Property ModNames1 Auto; 0-127
String[] Property ModNames2 Auto; 128-255
String[] Property ModNames3 Auto; 256-383
;Stored here and not in FormList so that they can be kept track of to populate the MCM and uninstall.

CANS_Core[] Property ActiveFrames1 Auto; 0-127
CANS_Core[] Property ActiveFrames2 Auto; 128-255
CANS_Core[] Property ActiveFrames3 Auto; 256-383
CANS_Core[] Property ActiveFrames4 Auto; 384-511
CANS_Core[] Property ActiveFrames5 Auto; 512-639
CANS_Core[] Property ActiveFrames6 Auto; 640-767
CANS_Core[] Property ActiveFrames7 Auto; 768-895
CANS_Core[] Property ActiveFrames8 Auto; 896-1023
;Redundancy in the off chance someone pushes whatever limit I set up. Actually designed to catch poor mod design.
;Theoretically the only actual limit on actors is that it can only run 1024 simultaneous updates.
;If you somehow run into this limit and need to surpass it contact me. Either something is terribly terribly wrong or I'll pay you $50 US.

String Property LeftBreast = "NPC L Breast" AutoReadOnly
String Property LeftBreast01 = "NPC L Breast01" AutoReadOnly
String Property LeftButt = "NPC L Butt" AutoReadOnly
String Property RightBreast = "NPC R Breast" AutoReadOnly
String Property RightBreast01 = "NPC R Breast01" AutoReadOnly
String Property RightButt = "NPC R Butt" AutoReadOnly
String Property Belly = "NPC Belly" AutoReadOnly
String Property WWRBreast1 = "NPC L Breast P1" AutoReadOnly
String Property WWRBreast2 = "NPC L Breast P2" AutoReadOnly
String Property WWRBreast3 = "NPC L Breast P3" AutoReadOnly
String Property WWLBreast1 = "NPC R Breast P1" AutoReadOnly
String Property WWLBreast2 = "NPC R Breast P2" AutoReadOnly
String Property WWLBreast3 = "NPC R Breast P3" AutoReadOnly
;HDT Werewolf breasts pointed out by Ed86 of MME.
;Breast Curve fix also generously donated from Ed86's script.

Event OnPlayerLoadGame() ;Prints some info to the debug log.
	
	If CANS_Tracelogging == True
		ActorCount();
		ModCount();
	EndIf
	
EndEvent

Event OnReset() ;May use to reset values. We'll see.

EndEvent

Event OnInit() ;Initializes values, arrays, etc.

	ModNames1 = new String[128]
	ModNames2 = new String[128]
	ModNames3 = new String[128]
	
	If CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_Init")
	EndIf
	
	;Torpedo Fix
	If HasIntValue(None, "CANS.TorpedoFix") == False ;TorpedoFix not initialized by default
		If CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_NoTorpedo")
		EndIf
		SetIntValue(None, "CANS.TorpedoFix", 0) ;Creates CANS.TorpedoFix as int globally = 0 (disabled)
		SetFloatValue(None, "CANS.TorpedoFixValue", 0.1) ;Creates The default TorpedoFix Value
		
		If CANS_Tracelogging == True 
			Debug.Trace("$CANS_Debug_TorpedoReady")
		EndIf
		
	Else ;Torpedo fix is initialized.
		If HasFloatValue(None, "CANS.TorpedoFixValue") == True
			If CANS_Tracelogging == True
				Debug.Trace("$CANS_Debug_YesTorpedo")
			EndIf
			
		Else
			SetFloatValue(None, "CANS.TorpedoFixValue", 0.1)
			If CANS_Tracelogging == True 
				Debug.Trace("$CANS_Debug_TorpedoReady")
			EndIf
		EndIf
	EndIf
	;Torpedo Fix set Up 
	
	If CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_InitEnd")
	EndIf 
	
	SetFormValue(None, "CANS Framework", Self) ;Stores itself in the Global values, for soft dependency.
	
EndEvent 

Function EndCANS() ;Functional ?
	ClearAllPrefix("CANS");
EndFunction 

Bool Function RegisterMyMod(Actor zTarget, String ModName, String Cat = "UnCat") ;Functional.

	;Local Variables
	Bool Registered = False;
	int aCount = 0;
	Float bCount = 0.0;
	Float cCount = 0.0;
	Float dCount = 0.0;
	
	
	If CANS_TraceLogging == True 
		Debug.Trace("$CANS_Debug_Registration{"+ModName+"}")
	EndIf
	
	If CountStringValuePrefix("CANS."+ModName+".Category" < 1)
		;Figure out where in the ModNames Array the mod goes.
		If !Registered ;ModNames1
			aCount = ModNames1.Find(ModName)
			If aCount == -1 ;ModName is not in ModNames1
				aCount = ModNAmes1.Find("")
				If aCount == -1 ;No freespace in ModNames1
					;Leaves this conditional and the next, goes to ModNames2
				Else
					;Freespace present, register mod here.
					ModNames1[aCount] = ModName;
					Registered = True;
				EndIf
			Else ;ModName is in ModNames1
				Registered = True;
			EndIf
		EndIf
			
		If !Registered ;ModNAmes2
			aCount = ModNames2.Find(ModName)
			If aCount == -1
				aCount = ModNames2.Find("")
				If aCount == -1
					
				Else
					ModNames2[aCount] = ModName;
					aCount += 128
					Registered = True
				EndIf
			Else
				aCount += 128
				Registered = True;
			EndIf
		EndIf
		
		If !Registered ;ModNAmes3
			aCount = ModNames3.Find(ModName)
			If aCount == -1
				aCount = ModNames3.Find("")
				If aCount == -1
					Debug.Trace("$CANS_ERROR_1{" + ModName + "}")
				Else
					ModNames3[aCount] = ModNAme;
					aCount += 256;
					Registered = True;
				EndIf
			Else
				aCount += 256;
				Registered = True;
			EndIf
		EndIf
		
		If !Registered ;Catch all failure
			Return False; Registration has failed. Returns false.
		EndIf
	EndIf
	
	;Set Global values. (Weight, Category) 
	SetStringValue(None, "CANS."+ModName+".Category", Cat) ;Stores the category for the mod globally.
	If !(HasFloatValue(None, "CANS."+ModName+".Weight"))
		SetFloatValue(None, "CANS."+ModName+".Weight", 1.0)
	EndIf
	
	SetStringValue(zTarget, "CANS.Running", "CANS.Running");Used for the actor count function
	
	If CANS_TraceLogging == True
		Debug.Trace("$CANS_Debug_Registration_{"+ModName+"}Vars1")
	EndIf
	
	;Register node values and mod itself to an actor.
	bCount = GetFloatValue(zTarget, "CANS."+ModName+".Belly", 1.0)
	cCount = GetFloatValue(zTarget, "CANS."+ModName+".Breast", 1.0)
	dCount = GetFloatValue(zTarget, "CANS."+ModName+".Butt", 1.0)
	;Returns the value in case the registration is on an already affected actor, however, may retrieve old values if values are not reset to zero and the mod is uninstalled from the MCM.
	
	SetFloatValue(zTarget, "CANS."+ModName+".Belly", bCount)
	SetFloatValue(zTarget, "CANS."+ModName+".Breast", cCount)
	SetFloatValue(zTarget, "CANS."+ModName+".Butt", dCount)
	;Adds the 3 float values to the target for the mod's sizes. Or resets them if the mod is re-registering.
	
	If StringListHas(zTarget, "CANS.Mods", ModName) == False
		StringListAdd(zTarget, "CANS.Mods", ModName)
	EndIf
	;Stores mods active on an Actor in a list stored locally on them. Updating gets that much easier. I'm sleepd deprived.
	
	If CANS_TraceLogging == True 
		Debug.Trace("$CANS_Debug_Registration_{"+ModName+"}Vars2")
	EndIf
	
	If CANS_TraceLogging == True 
		Debug.Trace("$CANS_Debug_Registration{"+ModName+"}End")
	EndIf
	
	Return True;
EndFunction 

Bool Function UninstallMyMod(Actor zTarget, String ModName) ;Functional
	
	If CANS_TraceLogging == True 
		Debug.Trace("$CANS_Debug_Uninstall{"+ModName+"}_Local{"+(zTarget.GetActorBase().GetName())+"}Start")
	EndIf
	
	bool aBool = StringListRemove(zTarget, "CANS.Mods", ModName, True)
	bool bBool
	bool cBool
	If aBool == False
		Debug.Trace("$CANS_ERROR_2{"+ModName+"}");
	EndIf
	aBool = UnsetFloatValue(zTarget, "CANS."+ModName+".Belly")
	bBool = UnsetFloatValue(zTarget, "CANS."+ModName+".Breast")
	cBool = UnsetFloatValue(zTarget, "CANS."+ModName+".Butt")
	If !aBool || !bBool || !cBool
		Debug.Trace("$CANS_ERROR_3{"+ModName+"}{"+(zTarget.GetActorBase().GetName())+"}")
	EndIf
	;Remove mod rom stringlist, remove float values. check the actor for cans values, remove the NiO if none remain
	
	If CANS_TraceLogging == True 
		Debug.Trace("$CANS_Debug_Uninstall{"+ModName+"}_Local{"+(zTarget.GetActorBase().GetName())+"}End")
	EndIf
	
	If CountFloatValuePrefix("CANS."+ModName) == 0
		UninstallAMod(ModName)
	EndIf
	
EndFunction

Bool Function UninstallAMod(String ModName) ;Working, May leave the modname on the actors' lists. Warrants testing. Can be fixed by adding actors to global form list in registration and a loop to remove all info from them. Would also make actor count faster
	;Removes all instances of the mods effect on all actors. Returns false and logs an error of there was a problem
	
	;Local Variables
	int aCount = 0;
	int bCount = 0;
	int cCount = 0;
	int dCount = 0;
	int FinalSize = 0;
	
	;Clears the Float Values and the Modlist from actors.
	ClearStringListPrefix(ModName)
	ClearFloatValuePrefix("CANS."+ModName)
	ClearStringValuePrefix("CANS."+ModName)
	;Float values definitely removed, modname may not be. Warrants further testing.
	
	
	;Remove the Mod Name from the arrays and translate the arrays to cover any blank space.
	aCount = ModNames1.Find(ModName)
	If aCount != -1 ;Is in this one.
		ModNames1[aCount] = "";
	Else ;is not in this one
		aCount = ModNames2.Find(ModName)
		If aCount != -1
			ModNames2[aCount] = "";
			aCount += 128;
		Else
			aCount = ModNames3.Find(ModName)
			If aCount != -1
				ModNames3[aCount] = "";
				aCount += 256;
			Else
				Debug.Trace("$CANS_ERROR_4{"+ModName+"}")
				Return False;
			EndIf
		EndIf
	EndIf
	
	bCount = aCount + 1;
	cCount = ModCount()
	;aCount = the one we just emptied.
	;bCount = the next one
	;cCount = the end of the array
	;dCount = aCount for values greater than 127
	;FinalSize = dCount + 1
	While aCount < cCount
		If aCount < 127
			ModNames1[aCount] = ModNames1[bCount];
			ModNames1[bCount] = "";
		ElseIf aCount == 127
			ModNames1[127] = ModNames2[0];
			ModNames2[0] = "";
		ElseIf aCount < 255
			dCount = aCount - 128
			FinalSize = bCount - 128
			ModNames2[dCount] = ModNames2[FinalSize]
			ModNames2[FinalSize] = "";
		ElseIf aCount == 255
			ModNAmes2[127] = ModNames3[0]
			ModNames3[0] = "";
		ElseIf aCount < 383
			dCount = aCount - 256;
			FinalSize = bCount - 256;
			ModNames3[dCount] = ModNames3[FinalSize];
			ModNames3[FinalSize] = "";
		EndIf
		;Special cases for the end of arrays, except the last one. Unimportant as it can just empty the final index and finish.
		aCount += 1
		bCount += 1
	EndWhile
	;Note: Used extra variables (FinalSize, bCount) instead of direct calculations (aCount+1,dCount+1) because arrays demonstrate unexpected behavior when a calculation is used within the brackets to retrieve an index.
	
EndFunction 

Int Function ModCount() ;Returns the number of mods installed in the list, so the index of the last one, plus 1. 0-384
	If CANS_TraceLogging == True
		Debug.Trace("$CANS_Debug_ModCount_Start")
	EndIf
	
	int aCount = 0;
	aCount = ModNames1.Find("")
	If aCount == -1
		aCount = ModNames2.Find("")
		If aCount == -1
			aCount = ModNames3.Find("")
			If aCount == -1
				aCount = 384;
				If CANS_TraceLogging == True
					Debug.Trace("$CANS_Debug_ModCount{"+aCount+"}_End")
				EndIf
				Return aCount;
			Else
				aCount += 256;
				If CANS_TraceLogging == True
					Debug.Trace("$CANS_Debug_ModCount{"+aCount+"}_End")
				EndIf
				Return aCount;
			EndIf
		Else
			aCount += 128;
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_ModCount{"+aCount+"}_End")
			EndIf
			Return aCount;
		EndIf
	Else
		If CANS_TraceLogging == True
			Debug.Trace("$CANS_Debug_ModCount{"+aCount+"}_End")
		EndIf
		Return aCount;
	EndIf

EndFunction

Int Function ActorCount() ;Returns number of actors.
	int aCount = 0;
	If CANS_TraceLogging == 1
		Debug.Trace("$CANS_Debug_ActorCount_Start")
	EndIf
	
	aCount = CountStringValuePrefix("CANS.Running")
	
	If CANS_TraceLogging == 1
		Debug.Trace("$CANS_Debug_ActorCount{"+aCount+"}_End")
	EndIf
	
	Return aCount;	
EndFunction

Int Function Belly(Actor zTarget, String ModName, Float NodeSize) ;Done
	;Return Codes:
		;0: Functioned as expected, update called
		;1: Override in place from another mod. Size stored but not updated
		;2: Terrible error has occurred. Please wait for some time (at least 4*UpdateDelay) and attmept the update once again. Size has been updated but not the NiO

	If CANS_TraceLogging == True
		Debug.Trace("$CANS_Debug_Belly{"+ModName+"}Start")
	EndIf
	SetFloatValue(zTarget, "CANS."+ModName+".Belly", NodeSize);
	;Updates stored node size before doing any kind of math
	
	;Check for override
	If GetStringValue(zTarget, "CANS.Override.Belly", "") != "" && GetStringValue(zTarget, "CANS.Override.Belly") != ModName
	;There is an override from another mod
		If CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Belly{"+ModName+"}_Overridden")
		EndIf
		Return 1;
	Else ;Either no override or this mod supplies it.
		If (!zTarget.HasMagicEffect(CANS_Manager))
			zTarget.AddSpell(CANS_Application, false)
			;CANS_Application.Cast(zTarget, zTarget);
			If (CANS_Tracelogging == True)
				Debug.Trace("$CANS_Debug_EffectApply{"+zTarget.GetLeveledActorBase().GetName()+"}")
			EndIf
		EndIf
		Int Idx = GetIntValue(zTarget, "CANS.EffectIdx", 1024);
		Bool CorrectIdx = True;
		
		If (Idx == 1024) ;Will return 0-1023 if it exists, 1024 means that this actor doesnt have the effect somehow.
			Debug.Trace("$CANS_ERROR_7{"+zTarget.GetLeveledActorBase().GetName()+"}")
		EndIf

		If (Idx < 128)
			CorrectIdx = ActiveFrames1[Idx].QueueBelly(ModName, zTarget);
		ElseIf (Idx < 256)
			Idx -= 128;
			CorrectIdx = ActiveFrames2[Idx].QueueBelly(ModName, zTarget);
		ElseIf (Idx < 384)
			Idx -= 256;
			CorrectIdx = ActiveFrames3[Idx].QueueBelly(ModName, zTarget);
		ElseIf (Idx < 512)
			Idx -= 384;
			CorrectIdx = ActiveFrames4[Idx].QueueBelly(ModName, zTarget);
		ElseIf (Idx < 640)
			Idx -= 512;
			CorrectIdx = ActiveFrames5[Idx].QueueBelly(ModName, zTarget);
		ElseIf (Idx < 768)
			Idx -= 640;
			CorrectIdx = ActiveFrames6[Idx].QueueBelly(ModName, zTarget);
		ElseIf (Idx < 896)
			Idx -= 768;
			CorrectIdx = ActiveFrames7[Idx].QueueBelly(ModName, zTarget);
		Else
			Idx -= 896;
			CorrectIdx = ActiveFrames8[Idx].QueueBelly(ModName, zTarget);
		EndIf
		
		If (CorrectIdx == False)
			Debug.Trace("$CANS_ERROR_8{"+zTarget.GetLeveledActorBase().GetName()+"}")
			Return 2;
		EndIf
	EndIf
	
	Return 0;
	
EndFunction 

Int Function Breast(Actor zTarget, String ModName, Float NodeSize) ;Done
;Return Codes:
	;0: Functioned as expected, update called
	;1: Override in place from another mod. Size stored but not updated
	;2: Sizes set to 1.0, NiO removed.

;Update value
;Check for an override
;If no override, update regularly, depending on mode. 
;Take into account individual weights (if enabled) for all modes but highest only
;Take into account categorical mins and maxes for all modes
;Take into account categorical weigting for everything but highes only (if enabled).

;Modes in CANS 2:
	;0:Highest Value Only
	;1:Additive (Weighted) ;Intended to be used with weighting to prevent scales from becoming increasingly ridiculous.
	;2:Weighted Average (no division by summation)
	;3:Additive (Legacy) straight additive
;Weighting modes:
	;0: Categorical weights
	;1: individual weights
	;2: no weighting
	
	
	If CANS_TraceLogging == True
		Debug.Trace("$CANS_Debug_Breast{"+ModName+"}Start")
	EndIf
	SetFloatValue(zTarget, "CANS."+ModName+".Breast", NodeSize);
	
	If GetStringValue(zTarget, "CANS.Override.Breast") != "" && GetStringValue(zTarget, "CANS.Override.Breast") != ModName
		If CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Breast{"+ModName+"}_Overridden")
		EndIf
		Return 1;
	Else ;Either no override or this mod supplies it.
		If (!zTarget.HasMagicEffect(CANS_Manager))
			zTarget.AddSpell(CANS_Application, false)
			;CANS_Application.Cast(zTarget, zTarget);
			If (CANS_Tracelogging)
				Debug.Trace("$CANS_Debug_EffectApply{"+zTarget.GetLeveledActorBase().GetName()+"}")
			EndIf
		EndIf
		Int Idx = GetIntValue(zTarget, "CANS.EffectIdx", 1024);
		Bool CorrectIdx = True;
		
		If (Idx == 1024)
			Debug.Trace("$CANS_ERROR_7{"+zTarget.GetLeveledActorBase().GetName()+"}")
		EndIf

		If (Idx < 128)
			CorrectIdx = ActiveFrames1[Idx].QueueBreast(ModName, zTarget);
		ElseIf (Idx < 256)
			Idx -= 128;
			CorrectIdx = ActiveFrames2[Idx].QueueBreast(ModName, zTarget);
		ElseIf (Idx < 384)
			Idx -= 256;
			CorrectIdx = ActiveFrames3[Idx].QueueBreast(ModName, zTarget);
		ElseIf (Idx < 512)
			Idx -= 384;
			CorrectIdx = ActiveFrames4[Idx].QueueBreast(ModName, zTarget);
		ElseIf (Idx < 640)
			Idx -= 512;
			CorrectIdx = ActiveFrames5[Idx].QueueBreast(ModName, zTarget);
		ElseIf (Idx < 768)
			Idx -= 640;
			CorrectIdx = ActiveFrames6[Idx].QueueBreast(ModName, zTarget);
		ElseIf (Idx < 896)
			Idx -= 768;
			CorrectIdx = ActiveFrames7[Idx].QueueBreast(ModName, zTarget);
		Else
			Idx -= 896;
			CorrectIdx = ActiveFrames8[Idx].QueueBreast(ModName, zTarget);
		EndIf
		
		If (CorrectIdx == False)
			Debug.Trace("$CANS_ERROR_8{"+zTarget.GetLeveledActorBase().GetName()+"}")
			Return 2;
		EndIf
	EndIf
	
	Return 0;
	
EndFunction

Int Function Butt(Actor zTarget, String ModName, Float NodeSize) ;Done
;Return Codes:
	;0: Functioned as expected, update called
	;1: Override in place from another mod. Size stored but not updated
	;2: Sizes set to 1.0, NiO removed.

;Update value
;Check for an override
;If no override, update regularly, depending on mode. 
;Take into account individual weights (if enabled) for all modes but highest only
;Take into account categorical mins and maxes for all modes
;Take into account categorical weigting for everything but highes only (if enabled).

;Modes in CANS 2:
	;0:Highest Value Only
	;1:Additive (Weighted) ;Intended to be used with weighting to prevent scales from becoming increasingly ridiculous.
	;2:Weighted Average (no division by summation)
	;3:Additive (Legacy) straight additive
;Weighting modes:
	;0: Categorical weights
	;1: individual weights
	;2: no weighting
	
	
	If CANS_TraceLogging == True
		Debug.Trace("$CANS_Debug_Butt{"+ModName+"}Start")
	EndIf
	SetFloatValue(zTarget, "CANS."+ModName+".Butt", NodeSize);
	
	If GetStringValue(zTarget, "CANS.Override.Butt") != "" && GetStringValue(zTarget, "CANS.Override.Butt") != ModName
		If CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Butt{"+ModName+"}_Overridden")
		EndIf
		Return 1;
	Else ;Either no override or this mod supplies it.
		If (!zTarget.HasMagicEffect(CANS_Manager))
			zTarget.AddSpell(CANS_Application, false)
			;CANS_Application.Cast(zTarget, zTarget);
			If (CANS_Tracelogging)
				Debug.Trace("$CANS_Debug_EffectApply{"+zTarget.GetLeveledActorBase().GetName()+"}")
			EndIf
		EndIf
		Int Idx = GetIntValue(zTarget, "CANS.EffectIdx", 1024);
		Bool CorrectIdx = True;
		
		If (Idx == 1024)
			Debug.Trace("$CANS_ERROR_7{"+zTarget.GetLeveledActorBase().GetName()+"}")
		EndIf

		If (Idx < 128)
			CorrectIdx = ActiveFrames1[Idx].QueueButt(ModName, zTarget);
		ElseIf (Idx < 256)
			Idx -= 128;
			CorrectIdx = ActiveFrames2[Idx].QueueButt(ModName, zTarget);
		ElseIf (Idx < 384)
			Idx -= 256;
			CorrectIdx = ActiveFrames3[Idx].QueueButt(ModName, zTarget);
		ElseIf (Idx < 512)
			Idx -= 384;
			CorrectIdx = ActiveFrames4[Idx].QueueButt(ModName, zTarget);
		ElseIf (Idx < 640)
			Idx -= 512;
			CorrectIdx = ActiveFrames5[Idx].QueueButt(ModName, zTarget);
		ElseIf (Idx < 768)
			Idx -= 640;
			CorrectIdx = ActiveFrames6[Idx].QueueButt(ModName, zTarget);
		ElseIf (Idx < 896)
			Idx -= 768;
			CorrectIdx = ActiveFrames7[Idx].QueueButt(ModName, zTarget);
		Else
			Idx -= 896;
			CorrectIdx = ActiveFrames8[Idx].QueueButt(ModName, zTarget);
		EndIf
		
		If (CorrectIdx == False)
			Debug.Trace("$CANS_ERROR_8{"+zTarget.GetLeveledActorBase().GetName()+"}")
			Return 2;
		EndIf
	EndIf
	
	Return 0;
	
EndFunction

Float Function ReturnBelly(Actor zTarget, String ModName);Done
	Float aFloat = 0.0;
	;Note, if returning 0.0, could not find your mod.
	aFloat = GetFloatValue(zTarget, "CANS."+ModName+".Belly", 0.0);
	Return aFloat;
EndFunction

Float Function ReturnBreast(Actor zTarget, String ModName);Done
	Float aFloat = 0.0;
	;Note, if returning 0.0, could not find your mod.
	aFloat = GetFloatValue(zTarget, "CANS."+ModName+".Breast", 0.0);
	Return aFloat;
EndFunction

Float Function ReturnButt(Actor zTarget, String ModName);Done
	Float aFloat = 0.0;
	;Note, if returning 0.0, could not find your mod.
	aFloat = GetFloatValue(zTarget, "CANS."+ModName+".Butt", 0.0);
	Return aFloat;
EndFunction

Int Function OverrideBelly(Actor zTarget, String ModName, Float NodeSize) ;Double check, should be functional
;Return Codes:
	;0: Functioned as intended
	;1: Another mod has an override active, node sizes changed.
	;2: Overrides not enabled in MCM. Regular update called. DO NOT CALL ANOTHER UPDATE IF THIS RETURNS 2
	;3:
	;Also printed to debug log for user convenience
;Checks to see if OVerrides are enabled by the user. If yes: check for active overrides, set if the current override is this mod or not set, update size only if another mod has an override. If overrides are disabled this will simply call the regular update function.
	
	If CANS_TraceLogging == True
		Debug.Trace("$CANS_Debug_Override1{"+ModName+"}Start")
	EndIf

	If Self.CANS_Override == True
		
		SetFloatValue(zTarget, "CANS."+ModName+".Belly", NodeSize); This is so much easier than arrays
		
		If GetStringValue(zTarget, "CANS.Override.Belly", "") != "" && GetStringValue(zTarget, "CANS.Override.Belly", "") != ModName
			;There is an override and it is not this mod.
			If CANS_TraceLogging == True	
				Debug.Trace("$CANS_Debug_Override1{"+ModName+"}Blocked{"+GetStringValue(zTarget, "CANS.Override.Belly")+"}")
				;Eww.
			EndIf 
			Self.Belly(zTarget, ModName, NodeSize)
			;Calling regular belly function.
			Return 1;
		
		ElseIf GetStringValue(zTarget, "CANS.Override.Belly", "") == "" || GetStringValue(zTarget, "CANS.Override.Belly", "") == ModName;
			;Either no override or this mod is the override.
			SetStringValue(zTarget, "CANS.Override.Belly", ModName);
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_Override_Success")
			EndIf
				
			If NodeSize != 1.0
				NiOverride.AddNodeTransformScale(zTarget, False, True, Belly, "C.A.N.S.", NodeSize)
				If zTarget == Game.GetPlayer()
					NiOverride.AddNodeTransformScale(zTarget, True, True, Belly, "C.A.N.S.", NodeSize)
				EndIf
			Else
				NiOverride.RemoveNodeTransformScale(zTarget, False, True, Belly, "C.A.N.S.")
				If zTarget == Game.GetPlayer()
					NiOverride.RemoveNodeTransformScale(zTarget, True, True, Belly, "C.A.N.S.")
				EndIf
			EndIf
			
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_Override_End")
			EndIf
			Return 0;
		EndIf
		
	Else
		If CANS_TraceLogging == True
			Debug.Trace("$CANS_Debug_OverrideDisabled")
		EndIf
		Self.Belly(zTarget, ModName, NodeSize)
		;Calling regular belly function.
		Return 2;
	EndIf
EndFunction

Bool Function OverrideBreast(Actor zTarget, String ModName, Float NodeSize) ;done
	If CANS_TraceLogging == True
		Debug.Trace("$CANS_Debug_Override2{"+ModName+"}Start")
	EndIf

	If Self.CANS_Override == True
		
		SetFloatValue(zTarget, "CANS."+ModName+".Breast", NodeSize); This is so much easier than arrays
		
		If GetStringValue(zTarget, "CANS.Override.Breast", "") != "" && GetStringValue(zTarget, "CANS.Override.Breast", "") != ModName
			;There is an override and it is not this mod.
			If CANS_TraceLogging == True	
				Debug.Trace("$CANS_Debug_Override2{"+ModName+"}Blocked{"+GetStringValue(zTarget, "CANS.Override.Breast")+"}")
				;Eww.
			EndIf 
			Self.Breast(zTarget, ModName, NodeSize)
			;Calling regular Breast function.
			Return 1;
			
		ElseIf GetStringValue(zTarget, "CANS.Override.Breast", "") == "" || GetStringValue(zTarget, "CANS.Override.Breast", "") == ModName;
			;Either no override or this mod is the override.
			SetStringValue(zTarget, "CANS.Override.Breast", ModName);
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_Override_Success")
			EndIf
				
			If NodeSize == 1.0 ;If the size is one, remove the CANS NiO instead of just updateing it. Slightly saves memory, possibly performance.
			If CANS_Tracelogging == True
				Debug.Trace("$CANS_Debug_Breast_unsize")
			EndIf
			NiOverride.RemoveNodeTransformScale(zTarget, False, True, LeftBreast, "C.A.N.S.")
			NiOverride.RemoveNodeTransformScale(zTarget, False, True, RightBreast, "C.A.N.S.")
			If zTarget == Game.GetPlayer()
				NiOverride.RemoveNodeTransformScale(zTarget, True, True, LeftBreast, "C.A.N.S.")
				NiOverride.RemoveNodeTransformScale(zTarget, True, True, RightBreast, "C.A.N.S.")
			EndIf
			Return 2;
		Else ;otherwise update the size
			If CANS_Tracelogging == True
				Debug.Trace("$CANS_Debug_Breast_resize")
			EndIf
			NiOverride.AddNodeTransformScale(zTarget, False, True, LeftBreast, "C.A.N.S.", NodeSize)
			NiOverride.AddNodeTransformScale(zTarget, False, True, RightBreast, "C.A.N.S.", NodeSize)
			If zTarget == Game.GetPlayer()
				NiOverride.AddNodeTransformScale(zTarget, True, True, LeftBreast, "C.A.N.S.", NodeSize)
				NiOverride.AddNodeTransformScale(zTarget, True, True, RightBreast, "C.A.N.S.", NodeSize)
			EndIf
		EndIf
		
		
		;BREAST CURVE
		
		If GetIntValue(None, "CANS.TorpedoFix", 0) == 1 &&  NetImmerse.HasNode(zTarget, RightBreast01, False) && NetImmerse.HasNode(zTarget, LeftBreast01, False)
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_Breast_TorpedoFix")
			endif
			Float CurveFix
			If NodeSize <= 1
				CurveFix = 1.0
			Else
				CurveFix = 1.0 - (GetFloatValue(None, "CANS.TorpedoFixValue")*NodeSize)
			EndIf
			NiOverride.AddNodeTransformScale(zTarget, False, True, RightBreast01, "C.A.N.S.", CurveFix)
			NiOverride.AddNodeTransformScale(zTarget, False, True, LeftBreast01, "C.A.N.S.", CurveFix)

			If zTarget == Game.GetPlayer()
				NiOverride.AddNodeTransformScale(zTarget, True, True, RightBreast01, "C.A.N.S.", CurveFix)
				NiOverride.AddNodeTransformScale(zTarget, True, True, LeftBreast01, "C.A.N.S.", CurveFix)
			EndIf

		EndIf
		
		;WW BREASTS
		If (NetImmerse.HasNode(zTarget, WWRBreast1, False)) && (NetImmerse.HasNode(zTarget, WWLBreast1, False)) && (NetImmerse.HasNode(zTarget, WWRBreast2, False)) && (NetImmerse.HasNode(zTarget, WWLBreast2, False)) && (NetImmerse.HasNode(zTarget, WWRBreast3, False)) && (NetImmerse.HasNode(zTarget, WWLBreast3, False))
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_Breasts_WW")
			endif
			NiOverride.AddNodeTransformScale(zTarget, False, True, WWRBreast1, "C.A.N.S.", NodeSize)
			NiOverride.AddNodeTransformScale(zTarget, False, True, WWLBreast1, "C.A.N.S.", NodeSize)
			NiOverride.AddNodeTransformScale(zTarget, False, True, WWRBreast2, "C.A.N.S.", NodeSize)
			NiOverride.AddNodeTransformScale(zTarget, False, True, WWLBreast2, "C.A.N.S.", NodeSize)
			NiOverride.AddNodeTransformScale(zTarget, False, True, WWRBreast3, "C.A.N.S.", NodeSize)
			NiOverride.AddNodeTransformScale(zTarget, False, True, WWLBreast3, "C.A.N.S.", NodeSize)
			
			If zTarget == Game.GetPlayer()
				NiOverride.AddNodeTransformScale(zTarget, true, True, WWRBreast1, "C.A.N.S.", NodeSize)
				NiOverride.AddNodeTransformScale(zTarget, true, True, WWLBreast1, "C.A.N.S.", NodeSize)
				NiOverride.AddNodeTransformScale(zTarget, true, True, WWRBreast2, "C.A.N.S.", NodeSize)
				NiOverride.AddNodeTransformScale(zTarget, true, True, WWLBreast2, "C.A.N.S.", NodeSize)
				NiOverride.AddNodeTransformScale(zTarget, true, True, WWRBreast3, "C.A.N.S.", NodeSize)
				NiOverride.AddNodeTransformScale(zTarget, true, True, WWLBreast3, "C.A.N.S.", NodeSize)
			endif			
		EndIf
			
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_Override_End")
			EndIf
			Return 0;
		EndIf
		
	Else
		If CANS_TraceLogging == True
			Debug.Trace("$CANS_Debug_OverrideDisabled")
		EndIf
		Self.Breast(zTarget, ModName, NodeSize)
		;Calling regular Breast function.
		Return 2;
	EndIf
EndFunction

Bool Function OverrideButt(Actor zTarget, String ModName, Float NodeSize) ;done
	
	If CANS_TraceLogging == True
		Debug.Trace("$CANS_Debug_Override3{"+ModName+"}Start")
	EndIf

	If Self.CANS_Override == True
		
		SetFloatValue(zTarget, "CANS."+ModName+".Butt", NodeSize); This is so much easier than arrays
		
		If GetStringValue(zTarget, "CANS.Override.Butt", "") != "" && GetStringValue(zTarget, "CANS.Override.Butt", "") != ModName
			;There is an override and it is not this mod.
			If CANS_TraceLogging == True	
				Debug.Trace("$CANS_Debug_Override3{"+ModName+"}Blocked{"+GetStringValue(zTarget, "CANS.Override.Butt")+"}")
				;Eww.
			EndIf 
			Self.Butt(zTarget, ModName, NodeSize)
			;Calling regular Butt function.
			Return 1;
			
		ElseIf GetStringValue(zTarget, "CANS.Override.Butt", "") == "" || GetStringValue(zTarget, "CANS.Override.Butt", "") == ModName;
			;Either no override or this mod is the override.
			SetStringValue(zTarget, "CANS.Override.Butt", ModName);
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_Override_Success")
			EndIf
				
			If NodeSize != 1.0
				NiOverride.AddNodeTransformScale(zTarget, False, True, LeftButt, "C.A.N.S.", NodeSize)
				NiOverride.AddNodeTransformScale(zTarget, False, True, RightButt, "C.A.N.S.", NodeSize)
				If zTarget == Game.GetPlayer()
					NiOverride.AddNodeTransformScale(zTarget, True, True, LeftButt, "C.A.N.S.", NodeSize)
					NiOverride.AddNodeTransformScale(zTarget, True, True, RightButt, "C.A.N.S.", NodeSize)
				EndIf
			Else
				NiOverride.RemoveNodeTransformScale(zTarget, False, True, LeftButt, "C.A.N.S.")
				NiOverride.RemoveNodeTransformScale(zTarget, False, True, RightButt, "C.A.N.S.")
				If zTarget == Game.GetPlayer()
					NiOverride.RemoveNodeTransformScale(zTarget, True, True, LeftButt, "C.A.N.S.")
					NiOverride.RemoveNodeTransformScale(zTarget, True, True, RightButt, "C.A.N.S.")
				EndIf
			EndIf
			
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_Override_End")
			EndIf
			Return 0;
		EndIf
		
	Else
		If CANS_TraceLogging == True
			Debug.Trace("$CANS_Debug_OverrideDisabled")
		EndIf
		Self.Butt(zTarget, ModName, NodeSize)
		;Calling regular Butt function.
		Return 2;
	EndIf
EndFunction

Bool Function EndOverrideBelly(Actor zTarget, String ModName, Bool Force = False) ;Double check, should be functional
	
	If CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_EndOverride{"+ModName+"}Start");
	EndIf
	
	String Existing = GetStringValue(zTarget, "CANS.Override.Belly", "(No existing override)");
	
	If Force == True
		If CANS_TraceLogging == True
			Debug.Trace("$CANS_Warning_EndOverride{"+ModName+"}{"+Existing+"}Force")
		EndIf
		UnsetStringValue(zTarget, "CANS.Override.Belly");
		Return True;
	Else
		
		If Existing == "(No existing override)"
			;No override to end.
			If CANS_TraceLogging == True
				Debug.Trace("CANS_Debug_Endoverride{"+ModName+"}Fail_1")
			EndIf
			Return False;
		ElseIf Existing == ModName
			UnsetStringValue(zTarget, "CANS.Override.Belly");
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_EndOverride{"+ModName+"}Success")
			EndIf
			Return True;
		ElseIf Existing != ModName
			Debug.Trace("$CANS_Debug_EndOverride{"+ModName+"}{"+Existing+"}Fail_2")
			Return False;
		EndIf
	EndIf
	
EndFunction

Bool Function EndOverrideBreast(Actor zTarget, String ModName, Bool Force = False) ;done

	If CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_EndOverride{"+ModName+"}Start");
	EndIf
	
	String Existing = GetStringValue(zTarget, "CANS.Override.Breast", "(No existing override)");
	
	If Force == True
		If CANS_TraceLogging == True
			Debug.Trace("$CANS_Warning_EndOverride{"+ModName+"}{"+Existing+"}Force")
		EndIf
		UnsetStringValue(zTarget, "CANS.Override.Breast");
		Return True;
	Else
		
		If Existing == "(No existing override)"
			;No override to end.
			If CANS_TraceLogging == True
				Debug.Trace("CANS_Debug_Endoverride{"+ModName+"}Fail_1")
			EndIf
			Return False;
		ElseIf Existing == ModName
			UnsetStringValue(zTarget, "CANS.Override.Breast");
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_EndOverride{"+ModName+"}Success")
			EndIf
			Return True;
		ElseIf Existing != ModName
			Debug.Trace("$CANS_Debug_EndOverride{"+ModName+"}{"+Existing+"}Fail_2")
			Return False;
		EndIf
	EndIf
EndFunction

Bool Function EndOverrideButt(Actor zTarget, String ModName, Bool Force = False) ;done
	
	If CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_EndOverride{"+ModName+"}Start");
	EndIf
	
	String Existing = GetStringValue(zTarget, "CANS.Override.Butt", "(No existing override)");
	
	If Force == True
		If CANS_TraceLogging == True
			Debug.Trace("$CANS_Warning_EndOverride{"+ModName+"}{"+Existing+"}Force")
		EndIf
		UnsetStringValue(zTarget, "CANS.Override.Butt");
		Return True;
	Else
		
		If Existing == "(No existing override)"
			;No override to end.
			If CANS_TraceLogging == True
				Debug.Trace("CANS_Debug_Endoverride{"+ModName+"}Fail_1")
			EndIf
			Return False;
		ElseIf Existing == ModName
			UnsetStringValue(zTarget, "CANS.Override.Butt");
			If CANS_TraceLogging == True
				Debug.Trace("$CANS_Debug_EndOverride{"+ModName+"}Success")
			EndIf
			Return True;
		ElseIf Existing != ModName
			Debug.Trace("$CANS_Debug_EndOverride{"+ModName+"}{"+Existing+"}Fail_2")
			Return False;
		EndIf
	EndIf
EndFunction

Function EndAllOverride() ;CANS USE ONLY
	If CANS_Tracelogging == True
		Debug.Trace("$CANS_Warning_EndAllOverrides")
	EndIf
	ClearAllPrefix("CANS.Override")
EndFunction

Function EndAllBellyOverride() ;CANS USE ONLY
	If CANS_Tracelogging == True
		Debug.Trace("$CANS_Warning_EndBellyOverrides")
	EndIf
	ClearAllPrefix("CANS.Override.Belly")
EndFunction

Function EndAllBreastOverride() ;CANS USE ONLY
	If CANS_Tracelogging == True
		Debug.Trace("$CANS_Warning_EndBreastOverrides")
	EndIf
	ClearAllPrefix("CANS.Override.Breast")
EndFunction

Function EndAllButtOverride() ;CANS USE ONLY
	If CANS_Tracelogging == True
		Debug.Trace("$CANS_Warning_EndButtOverrides")
	EndIf
	ClearAllPrefix("CANS.Override.Belly")
EndFunction

Bool Function TempEffect(ActiveMagicEffect Effect, int Idx) ;done
	If (Idx < 128)
		ActiveFrames1[Idx] = (Effect as CANS_Core);
		Return True;
	ElseIf (Idx < 256)
		Idx -= 128;
		ActiveFrames2[Idx] = (Effect as CANS_Core);
		Return True;
	ElseIf (Idx < 384)
		Idx -= 256;
		ActiveFrames3[Idx] = (Effect as CANS_Core);
		Return True;
	ElseIf (Idx < 512)
		Idx -= 384;
		ActiveFrames4[Idx] = (Effect as CANS_Core);
		Return True;
	ElseIf (Idx < 640)
		Idx -= 512;
		ActiveFrames5[Idx] = (Effect as CANS_Core);
		Return True;
	ElseIf (Idx < 768)
		Idx -= 640;
		ActiveFrames6[Idx] = (Effect as CANS_Core);
		Return True;
	ElseIf (Idx < 896)
		Idx -= 768;
		ActiveFrames7[Idx] = (Effect as CANS_Core);
		Return True;
	Else
		Idx -= 896;
		ActiveFrames8[Idx] = (Effect as CANS_Core);
		Return True;
	EndIf

	Return False;
	
EndFunction;

Bool Function EndEffect(ActiveMagicEffect Effect, int Idx) ;Done

	Bool Unregistered = False
	
	While !Unregistered
		If (Idx < 128)
			If (ActiveFrames1[Idx] == (Effect as CANS_Core))
				ActiveFrames1[Idx] = None;
				Unregistered = True
				Return True;
			EndIf
		ElseIf (Idx < 256)
			Idx -= 128;
			If (ActiveFrames2[Idx] == (Effect as CANS_Core))
				ActiveFrames2[Idx] = None;
				Unregistered = True
				Return True;
			EndIf
		ElseIf (Idx < 384)
			Idx -= 256;
			If (ActiveFrames3[Idx] == (Effect as CANS_Core))
				ActiveFrames3[Idx] = None;
				Unregistered = True
				Return True;
			EndIf
		ElseIf (Idx < 512)
			Idx -= 384;
			If (ActiveFrames4[Idx] == (Effect as CANS_Core))
				ActiveFrames4[Idx] = None;
				Unregistered = True
				Return True;
			EndIf
		ElseIf (Idx < 640)
			Idx -= 512;
			If (ActiveFrames5[Idx] == (Effect as CANS_Core))
				ActiveFrames5[Idx] = None;
			EndIf
			Return True;
		ElseIf (Idx < 768)
			Idx -= 640;
			If (ActiveFrames6[Idx] == (Effect as CANS_Core))
				ActiveFrames6[Idx] = None;
				Unregistered = True
				Return True;
			EndIf
		ElseIf (Idx < 896)
			Idx -= 768;
			If (ActiveFrames7[Idx] == (Effect as CANS_Core))
				ActiveFrames7[Idx] = None;
				Unregistered = True
				Return True;
			EndIf
		Else
			Idx -= 896;
			If (ActiveFrames8[Idx] == (Effect as CANS_Core))
				ActiveFrames8[Idx] = None;
				Unregistered = True
				Return True;
			EndIf
		EndIf

		If !Unregistered
			Debug.Trace("$CANS_ERROR_9")
			Idx = FindEffect(Effect)
		EndIf
		
		If Idx == 1024 ;Could not find it, no longer in the arrays
			Debug.Trace("$CANS_ERROR_10")
			Unregistered = True;
		EndIf
	EndWhile
	If CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_EffectGone")
	EndIf
	;;If they don't match, log an error, and handle it. Search for the effect in ALL of them, and remove it. CANNOT have these getting cluttered becaus eI forgot to handle and error
	
	Return False;
	
EndFunction

Int Function FindEffect(ActiveMagicEffect Effect)
	int aCount
	bool Found = False
	
	If !Found 
		aCount = ActiveFrames1.find((Effect as CANS_Core));
		If aCount != -1 ;Found
			Found = True;
			aCount += 0;
		EndIf
	EndIf
	
	If !Found
		aCount = ActiveFrames2.Find((Effect as CANS_Core))
		If aCount != -1
			Found = True
			aCount += 128
		EndIf
	EndIf
	
	If !Found
		aCount = ActiveFrames3.Find((Effect as CANS_Core))
		If aCount != -1
			Found = True
			aCount += 256
		EndIf
	EndIf
	
	If !Found
		aCount = ActiveFrames4.Find((Effect as CANS_Core))
		If aCount != -1
			Found = True
			aCount += 384
		EndIf
	EndIf
	
	If !Found
		aCount = ActiveFrames5.Find((Effect as CANS_Core))
		If aCount != -1
			Found = True
			aCount += 512
		EndIf
	EndIf
	
	If !Found
		aCount = ActiveFrames6.Find((Effect as CANS_Core))
		If aCount != -1
			Found = True
			aCount += 640
		EndIf
	EndIf
	
	If !Found
		aCount = ActiveFrames7.Find((Effect as CANS_Core))
		If aCount != -1
			Found = True
			aCount += 768
		EndIf
	EndIf
	
	If !Found
		aCount = ActiveFrames8.Find((Effect as CANS_Core))
		If aCount != -1
			Found = True
			aCount += 896
		EndIf
	EndIf
	
	If !Found
		aCount = 1024
	EndIf
	
	Return aCount
	
EndFunction 