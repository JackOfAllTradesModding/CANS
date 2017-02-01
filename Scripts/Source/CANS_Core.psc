ScriptName CANS_Core Extends ActiveMagicEffect 
{The new and temporary magic effect, handles only the math and update and then deletes itself.}
;TBH I'm really proud of the mechanics at work behind CANS

CANS_Framework Property CANSframe Auto
Quest Property CANS Auto
Actor Property zTarget Auto;
import StorageUtil;

Int Property MyIdx Auto; 0-1023
String Property ModCaller Auto; Stores name of most recent call so that it can print it with the tracelog

Bool UpdateQueued = False;
Bool BellyQueued = False;
Bool BreastQueued = False;
Bool ButtQueued = False;
;Queues updates and exectues them. Dispels itself.

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


Event OnEffectStart(Actor akTarget, Actor akCaster) ;Done
	If (CANSframe.CANS_Tracelogging == True)
		Debug.Trace("$CANS_Debug_EffectStart{"+akTarget.GetLeveledActorBase().GetName()+"}")
	EndIf
	zTarget = akTarget;
	MyIdx = FindSpot();
	;Sets the effect's two housekeeping properties
	SetIntValue(zTarget, "CANS.EffectIdx", MyIdx);
	;Stores itself in the arrays in cansframe and then stores the index on the target, allowing access
	RegisterForSingleUpdate(20.0);
	;catch-all in case updates fail to queue so the effect can dispel itself appropriately
EndEvent;

Int Function FindSpot() ;Done

	;Searches CANSframe.ActiveFramesX for an empty spot and stores itself.
	int aCount = 0;
	int bCount = 0;
	bool Registered = false;
	
	While (!Registered && bCount < 3) ;Adds itself to the appropriate array
	If (CANSframe.CANS_Tracelogging == True)
		Debug.Trace("$CANS_Debug_EffectSpot{"+zTarget.GetLeveledActorBase().GetName()+"}Start{"+bCount+"}")
	EndIf
		If !Registered ;Array 1
			aCount = CANSframe.ActiveFrames1.Find(None);
			If aCount != -1
				Registered = CANSframe.TempEffect(Self, aCount);Continues to loop if this fails for any reason.
			Else
				Registered = False;
			EndIf
		EndIf
	
		If !Registered ;Array 2
			aCount = CANSframe.ActiveFrames2.Find(None);
			If aCount != -1
				aCount += 128;
				Registered = CANSframe.TempEffect(Self, aCount);Continues to loop if this fails for any reason.
			Else
				Registered = False;
			EndIf
		EndIf
	
		If !Registered ;Array 3
			aCount = CANSframe.ActiveFrames3.Find(None);
			If aCount != -1
				aCount += 256;
				Registered = CANSframe.TempEffect(Self, aCount);Continues to loop if this fails for any reason.
			Else
				Registered = False;
			EndIf
		EndIf
	
		If !Registered ;Array 4
			aCount = CANSframe.ActiveFrames4.Find(None);
			If aCount != -1
				aCount += 384;
				Registered = CANSframe.TempEffect(Self, aCount);Continues to loop if this fails for any reason.
			Else
				Registered = False;
			EndIf
		EndIf
	
		If !Registered ;Array 5
			aCount = CANSframe.ActiveFrames5.Find(None);
			If aCount != -1
				aCount += 512;
				Registered = CANSframe.TempEffect(Self, aCount);Continues to loop if this fails for any reason.
			Else
				Registered = False;
			EndIf
		EndIf
	
		If !Registered ;Array 6
			aCount = CANSframe.ActiveFrames6.Find(None);
			If aCount != -1
				aCount += 640;
				Registered = CANSframe.TempEffect(Self, aCount);Continues to loop if this fails for any reason.
			Else
				Registered = False;
			EndIf
		EndIf
	
		If !Registered ;Array 7
			aCount = CANSframe.ActiveFrames7.Find(None);
			If aCount != -1
				aCount += 768;
				Registered = CANSframe.TempEffect(Self, aCount);Continues to loop if this fails for any reason.
			Else
				Registered = False;
			EndIf
		EndIf
	
		If !Registered ;Array 8
			aCount = CANSframe.ActiveFrames8.Find(None);
			If aCount != -1
				aCount += 896;
				Registered = CANSframe.TempEffect(Self, aCount);Continues to loop if this fails for any reason.
			Else
				Registered = False;
			EndIf
		EndIf
	
	bCount += 1;
	
	EndWhile ;Repeats if it still failed to register. Allows the magic effect to register even if they're all filled by simply waiting it's turn.
	
	;;Check for registration, fail if not
	If (!Registered)
		Debug.Trace("$CANS_ERROR_6{"+zTarget.GetLeveledActorBase().GetName()+"}")
	EndIf
	
	If (CANSframe.CANS_Tracelogging == True)
		Debug.Trace("$CANS_Debug_EffectSpot{"+zTarget.GetLeveledActorBase().GetName()+"}End{"+aCount+"}")
	EndIf
	
	Return aCount; 0-1023
	
EndFunction;

Bool Function QueueBelly(String ModName, actor akTarget) ;Done
	If !UpdateQueued
		UnregisterForUpdate()
	EndIf
	;Removes the long delay update set at effect start
	If (akTarget != zTarget) && (zTarget != none)
		Return False;
	ElseIf (zTarget == none)
		zTarget = akTarget
	EndIf
	
	If (ModName != ModCaller)
		ModCaller = ModName;
		If (CANSframe.CANS_Tracelogging == True)
			Debug.Trace("$CANS_Debug_Effect{"+zTarget.GetLeveledActorBase().GetName()+"}CallerChange{"+ModCaller+"}")
		EndIf
		;Unimportant from a scripting perspective but important for troubleshooting purposes
	EndIf
	;Size set when function called in framework.
	;Override checked in framework.
	;This function is only called when an update is actually necessary and all the sizes have been updated
	RegisterForSingleUpdate(CANSframe.UpdateDelay);
	UpdateQueued = True;
	BellyQueued = True;
	Return True;
	
EndFunction;

Bool Function QueueBreast(String ModName, actor akTarget) ;Done
	If !UpdateQueued
		UnregisterForUpdate()
	EndIf
	;Removes the long delay update set at effect start
	If (akTarget != zTarget) && (zTarget != none)
		Return False;
	ElseIf (zTarget == none)
		zTarget = akTarget
	EndIf
	
	If (ModName != ModCaller)
		ModCaller = ModName;
		If (CANSframe.CANS_Tracelogging == True)
			Debug.Trace("$CANS_Debug_Effect{"+zTarget.GetLeveledActorBase().GetName()+"}CallerChange{"+ModCaller+"}")
		EndIf
		;Unimportant from a scripting perspective but important for troubleshooting purposes
	EndIf
	;Size set when function called in framework.
	;Override checked in framework.
	;This function is only called when an update is actually necessary and all the sizes have been updated
	RegisterForSingleUpdate(CANSframe.UpdateDelay);
	UpdateQueued = True;
	BreastQueued = True;
	Return True;
	
EndFunction;

Bool Function QueueButt(String ModName, actor akTarget) ;Done
	If !UpdateQueued
		UnregisterForUpdate()
	EndIf
	;Removes the long delay update set at effect start
	If (akTarget != zTarget) && (zTarget != none)
		Return False;
	ElseIf (zTarget == none)
		zTarget = akTarget
	EndIf
	
	If (ModName != ModCaller)
		ModCaller = ModName;
		If (CANSframe.CANS_Tracelogging == True)
			Debug.Trace("$CANS_Debug_Effect{"+zTarget.GetLeveledActorBase().GetName()+"}CallerChange{"+ModCaller+"}")
		EndIf
		;Unimportant from a scripting perspective but important for troubleshooting purposes
	EndIf
	;Size set when function called in framework.
	;Override checked in framework.
	;This function is only called when an update is actually necessary and all the sizes have been updated
	RegisterForSingleUpdate(CANSframe.UpdateDelay);
	UpdateQueued = True;
	ButtQueued = True;
	Return True;
	
EndFunction;

Event OnUpdate() ;Done
	If !UpdateQueued
		;Log an error
		;Dispel the effect
		Debug.Trace("$CANS_ERROR_0{"+zTarget.GetLeveledActorBase().GetName()+"}");
		EndMe()
	Else
		;One or more updates actually queued
		If BellyQueued
			Belly(zTarget, ModCaller)
		EndIf
		;Utility.Wait(0.001); Just to keep it from running while you're in a menu
		If BreastQueued
			Breast(zTarget, ModCaller)
		EndIf
		
		If ButtQueued
			Butt(zTarget, ModCaller)
		EndIf
		
		EndMe()
		
	EndIf
EndEvent

Int Function Belly(Actor aTarget, String ModName) ;Done
	;Modes in CANS 2:
		;0:Highest Value Only
		;1:Additive (Weighted) ;Intended to be used with weighting to prevent scales from becoming increasingly ridiculous.
		;2:Weighted Average (no division by summation)
		;3:Additive (Legacy) straight additive
	;Weighting modes:
		;0: Categorical weights
		;1: individual weights
		;2: no weighting
	
	Int WeightingMode = CANSframe.CANS_WeightingMode;
	;StringList CANS.Mods w/ names
	;Weighting stored  globally as cans.modname.Weight
	;Cat stored as CANS.ModName.Category
	
	;Get size of modlist
	;loop through it using those.
	;Index starts at 0???
	;Use that to pull up either the category or the weight.
	
	int aCount = 0;
	int bCount = 0;
	
	Float CurrentSize = 0.0;
	Float NewSize = 0.0;
	Float FinalSize = 0.0;
	
	Float WeightMult = 0.0;
	Float CatLimit = 0.0;
	String zName = "";
	String zCat = "";
	
	If CANSframe.CANS_Belly_Mode == 0 ;Highest value only
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Belly{"+Self.ModCaller+"}_HVstart")
		EndIf
		;Ignores weighting. 
		;Takes into consideration max values.
		bCount = StringListCount(zTarget, "CANS.Mods") ;Find number of mods on an actor. Theoretically less than 384 but you never know do ya?
		
		While aCount < bCount;
			zName = StringListGet(zTarget, "CANS.Mods", aCount);
			NewSize = GetFloatValue(zTarget, "CANS."+zName+".Belly")
			If CurrentSize < NewSize
				CurrentSize = NewSize
				If CANSframe.CANS_Tracelogging == True
					Debug.Trace("$CANS_Debug_Belly{"+zName+"}_HVChange")
				EndIf
			EndIf
			aCount += 1
		EndWhile
		FinalSize = CurrentSize
		
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Belly{"+FinalSize+"}_HVend")
		EndIf
		
	ElseIf CANSframe.CANS_Belly_Mode == 1 ;Additive
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Belly{"+Self.ModCaller+"}_AddBegin")
		EndIf
		
		;Weighted
		;(wt*v1)+1/(f^2)*(wt*v2)...
		bCount = StringListCount(zTarget, "CANS.Mods");
		
		aCount = 0
		While aCount < bCount;This is some weird bullshit going on because the sort function in storage util is in ascending order
			
			If WeightingMode == 0
				zName = StringListGet(zTarget, "CANS.Mods", aCount);
				zCat = GetStringValue(None, "CANS."+zName+".Category", "UnCat")
				If zCat == "Pregnany"
					WeightMult = CANSframe.PregnancyBellyWeight;
				ElseIf zCat == "Milking"
					WeightMult = CANSframe.MilkingBellyWeight;
				ElseIf zCat == "Inflation"
					WeightMult = CANSframe.InflationBellyWeight;
				ElseIf zCat == "Cumflation"
					WeightMult = CANSframe.CumflationBellyWeight;
				ElseIf zCat == "MiscCat"
					WeightMult = CANSframe.MiscCatBellyWeight;
				Else
					WeightMult = CANSframe.UncatBellyWeight;
				EndIf
				;Weight multiplier set up for the categories.
					
			ElseIf WeightingMode == 1;Individual weights
				WeightMult = GetFloatValue(None, "CANS."+zName+".Weight",1.0)
				If HasFloatValue(None, "CANS."+zName+".Weight") == False
					SetFloatValue(None, "CANS."+zName+".Weight",1.0)
				EndIf
			ElseIf WeightingMode == 2;no weights
				WeightMult = 1.0;
			Else
				Debug.Trace("$CANS_ERROR_5{"+Self.ModCaller+"}");
				WeightMult = 1.0;
			EndIf
			
			CurrentSize = GetFloatValue(zTarget, "CANS."+zName+".Belly")*WeightMult
			FloatListAdd(zTarget, "CANS.SortedBelly", CurrentSize);
			aCount += 1;
		EndWhile
		
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Belly_AddListMade");;DELETE ME FOR FINAL RELEASE, ONLY FOR TESTING LAG
		EndIf
		
		FloatListSort(zTarget, "CANS.SortedBelly"); Sorted list.
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Belly_AddListSorted")
		EndIf
		aCount = 0;
		While aCount < bCount;
			NewSize = (FloatListGet(zTarget, "CANS.SortedBelly", (bCount-aCount)))*(1/(Math.Pow(CANSframe.DecreasingAdditiveFactor, aCount))) 
			;Gets the floats from the list counting backwards, since sorting sorts it in ascending order. Multiplies it by a decreasing factor.
			If NewSize < 1.0
				NewSize = (1.0-NewSize);
			ElseIf NewSize == 1.0
				NewSize = 0.0;
			EndIf
			FinalSize += NewSize;
			aCount += 1;
		EndWhile
		
		FloatListClear(zTarget, "CANS.SortedBelly"); Deletes the sorted list to save data
		
		;;NEED TO TEST FOR LAG. POTENTIAL MULTITHREADING POINT
		
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Belly{"+FinalSize+"}AddEnd")
		EndIf
		
		
	ElseIf CANSframe.CANS_Belly_Mode == 2 ;Weighted average
		;Math (wt*value)+(wt*value)
		;Note: If all weights let at 1.0 this is effectively the legacy additive.
		bCount = StringListCount(zTarget, "CANS.Mods");
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Belly{"+Self.ModCaller+"}WavgStart")
		EndIf
		
		aCount = 0
		While aCount < bCount;This is some weird bullshit going on because the sort function in storage util is in ascending order
			
			If WeightingMode == 0
				zName = StringListGet(zTarget, "CANS.Mods", aCount);
				zCat = GetStringValue(None, "CANS."+zName+".Category", "UnCat")
				If zCat == "Pregnany"
					WeightMult = CANSframe.PregnancyBellyWeight;
				ElseIf zCat == "Milking"
					WeightMult = CANSframe.MilkingBellyWeight;
				ElseIf zCat == "Inflation"
					WeightMult = CANSframe.InflationBellyWeight;
				ElseIf zCat == "Cumflation"
					WeightMult = CANSframe.CumflationBellyWeight;
				ElseIf zCat == "MiscCat"
					WeightMult = CANSframe.MiscCatBellyWeight;
				Else
					WeightMult = CANSframe.UncatBellyWeight;
				EndIf
				;Weight multiplier set up for the categories.
					
			ElseIf WeightingMode == 1;Individual weights
				WeightMult = GetFloatValue(None, "CANS."+zName+".Weight",1.0)
				If HasFloatValue(None, "CANS."+zName+".Weight") == False
					SetFloatValue(None, "CANS."+zName+".Weight",1.0)
				EndIf
			ElseIf WeightingMode == 2;no weights
				WeightMult = 1.0;
			Else
				Debug.Trace("$CANS_ERROR_5{"+Self.ModCaller+"}");
				WeightMult = 1.0;
			EndIf
			
			FinalSize += GetFloatValue(zTarget, "CANS."+zName+".Belly")*WeightMult
			aCount += 1;
		EndWhile
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Belly_WavgEnd")
		EndIf
		
	ElseIf CANSframe.CANS_Belly_Mode == 3 ;Legacy additive
		bCount = StringListCount(zTarget, "CANS.Mods");
		aCount = 0;
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Belly{"+Self.ModCaller+"}LAddStart")
		EndIf
		
		While aCount < bCount
			zName = StringListGet(zTarget, "CANS.Mods", aCount);
			FinalSize += GetFloatValue(zTarget, "CANS."+zName+".Belly")
		EndWhile
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Belly{"+FinalSize+"}LAddEnd")
		EndIf
		
	ElseIf CANSframe.CANS_Belly_Mode == 4 ;sqrt of sum of squares
		bCount = StringListCount(zTarget, "CANS.Mods");
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Belly{"+Self.ModCaller+"}SQstart")
		EndIf
		
		aCount = 0
		While aCount < bCount;This is some weird bullshit going on because the sort function in storage util is in ascending order
			
			If WeightingMode == 0
				zName = StringListGet(zTarget, "CANS.Mods", aCount);
				zCat = GetStringValue(None, "CANS."+zName+".Category", "UnCat")
				If zCat == "Pregnany"
					WeightMult = CANSframe.PregnancyBellyWeight;
				ElseIf zCat == "Milking"
					WeightMult = CANSframe.MilkingBellyWeight;
				ElseIf zCat == "Inflation"
					WeightMult = CANSframe.InflationBellyWeight;
				ElseIf zCat == "Cumflation"
					WeightMult = CANSframe.CumflationBellyWeight;
				ElseIf zCat == "MiscCat"
					WeightMult = CANSframe.MiscCatBellyWeight;
				Else
					WeightMult = CANSframe.UncatBellyWeight;
				EndIf
				;Weight multiplier set up for the categories.
					
			ElseIf WeightingMode == 1;Individual weights
				WeightMult = GetFloatValue(None, "CANS."+zName+".Weight",1.0)
				If HasFloatValue(None, "CANS."+zName+".Weight") == False
					SetFloatValue(None, "CANS."+zName+".Weight",1.0)
				EndIf
			ElseIf WeightingMode == 2;no weights
				WeightMult = 1.0;
			Else
				Debug.Trace("$CANS_ERROR_5{"+Self.ModCaller+"}");
				WeightMult = 1.0;
			EndIf
			
			
			CurrentSize = Math.Pow(GetFloatValue(zTarget, "CANS."+zName+".Belly")*WeightMult, 2);
			If CurrentSize >= 1.0
				FinalSize += CurrentSize
			Else;Size was less than 1
				FinalSize -= CurrentSize
			EndIf
			aCount += 1;Almost forgot this
		EndWhile
		
		FinalSize = Math.Sqrt(FinalSize);
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Belly{"+FinalSize+"}SQend")
		EndIf
		
	ElseIf CANSframe.CANS_Belly_Mode == 5 ;Legacy Average, because I don't forget my roots
		bCount = StringListCount(zTarget, "CANS.Mods");
		aCount = 0;
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Belly{"+Self.ModCaller+"}LAvgStart")
		EndIf
		
		While aCount < bCount
			zName = StringListGet(zTarget, "CANS.Mods", aCount);
			FinalSize += GetFloatValue(zTarget, "CANS."+zName+".Belly")
		EndWhile
		
		FinalSize = FinalSize/bCount;
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Belly{"+FinalSize+"}LAvgEnd")
		EndIf
	EndIf
	
	If CANSframe.CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_Belly{"+Self.ModCaller+"}_Finale{"+FinalSize+"}begin")
	EndIf
	
	If (FinalSize > CANSframe.MaxBellySize) && (CANSframe.MaxBellyEnabled == True) ;Catch in case size is over the limit.
		FinalSize = CANSframe.MaxBellySize;
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Belly_OverMax")
		EndIf
	EndIf
	
	If FinalSize <= 0
		FinalSize = 1
	EndIf
	
	If FinalSize == 1.0 ;If the size is one, remove the CANS NiO instead of just updateing it. Slightly saves memory, possibly performance.
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Belly_unsize")
		EndIf
		NiOverride.RemoveNodeTransformScale(zTarget, False, True, Belly, "C.A.N.S.")
		If zTarget == Game.GetPlayer()
			NiOverride.RemoveNodeTransformScale(zTarget, True, True, Belly, "C.A.N.S.")
		EndIf
		Return 2;
	Else ;otherwise update the size
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Belly_resize")
		EndIf
		NiOverride.AddNodeTransformScale(zTarget, False, True, Belly, "C.A.N.S.", FinalSize)
		If zTarget == Game.GetPlayer()
			NiOverride.AddNodeTransformScale(zTarget, True, True, Belly, "C.A.N.S.", FinalSize)
		EndIf
	EndIf
	
	If CANSframe.CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_Belly{"+Self.ModCaller+"}_Finale{"+FinalSize+"}end")
	EndIf
	
EndFunction

Int Function Breast(Actor aTarget, String ModName) ;Done
	;Modes in CANS 2:
		;0:Highest Value Only
		;1:Additive (Weighted) ;Intended to be used with weighting to prevent scales from becoming increasingly ridiculous.
		;2:Weighted Average (no division by summation)
		;3:Additive (Legacy) straight additive
	;Weighting modes:
		;0: Categorical weights
		;1: individual weights
		;2: no weighting

		
	Int WeightingMode = CANSframe.CANS_WeightingMode;
		;StringList CANS.Mods w/ names
		;Weighting stored  globally as cans.modname.Weight
		;Cat stored as CANS.ModName.Category
		
		;Get size of modlist
		;loop through it using those.
		;Index starts at 0???
		;Use that to pull up either the category or the weight.
	
	int aCount = 0;
	int bCount = 0;
	
	Float CurrentSize = 0.0;
	Float NewSize = 0.0;
	Float FinalSize = 0.0;
	
	Float WeightMult = 0.0;
	Float CatLimit = 0.0;
	String zName = "";
	String zCat = "";
	
	If CANSframe.CANS_Breast_Mode == 0 ;Highest value only
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Breast{"+ModName+"}_HVstart")
		EndIf
		;Ignores weighting. 
		;Takes into consideration max values.
		bCount = StringListCount(zTarget, "CANS.Mods") ;Find number of mods on an actor. Theoretically less than 384 but you never know do ya?
		
		While aCount < bCount;
			zName = StringListGet(zTarget, "CANS.Mods", aCount);
			NewSize = GetFloatValue(zTarget, "CANS."+zName+".Breast")
			If CurrentSize < NewSize
				CurrentSize = NewSize
				If CANSframe.CANS_Tracelogging == True
					Debug.Trace("$CANS_Debug_Breast{"+zName+"}_HVChange")
				EndIf
			EndIf
			aCount += 1
		EndWhile
		FinalSize = CurrentSize
		
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Breast{"+FinalSize+"}_HVend")
		EndIf
		
	ElseIf CANSframe.CANS_Breast_Mode == 1 ;Additive
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Breast{"+ModName+"}_AddBegin")
		EndIf
		
		;Weighted
		;(wt*v1)+1/(f^2)*(wt*v2)...
		bCount = StringListCount(zTarget, "CANS.Mods");
		
		aCount = 0
		While aCount < bCount;This is some weird bullshit going on because the sort function in storage util is in ascending order
			
			If WeightingMode == 0
				zName = StringListGet(zTarget, "CANS.Mods", aCount);
				zCat = GetStringValue(None, "CANS."+zName+".Category", "Uncat")
				If zCat == "Pregnany"
					WeightMult = CANSframe.PregnancyBreastWeight;
				ElseIf zCat == "Milking"
					WeightMult = CANSframe.MilkingBreastWeight;
				ElseIf zCat == "Inflation"
					WeightMult = CANSframe.InflationBreastWeight;
				ElseIf zCat == "Cumflation"
					WeightMult = CANSframe.CumflationBreastWeight;
				ElseIf zCat == "MiscCat"
					WeightMult = CANSframe.MiscCatBreastWeight;
				Else
					WeightMult = CANSframe.UncatBreastWeight;
				EndIf
				;Weight multiplier set up for the categories.
					
			ElseIf WeightingMode == 1;Individual weights
				WeightMult = GetFloatValue(None, "CANS."+zName+".Weight",1.0)
				If HasFloatValue(None, "CANS."+zName+".Weight") == False
					SetFloatValue(None, "CANS."+zName+".Weight",1.0)
				EndIf
			ElseIf WeightingMode == 2;no weights
				WeightMult = 1.0;
			Else
				Debug.Trace("$CANS_ERROR_5{"+ModName+"}");
				WeightMult = 1.0;
			EndIf
			
			CurrentSize = GetFloatValue(zTarget, "CANS."+zName+".Breast")*WeightMult
			FloatListAdd(zTarget, "CANS.SortedBreast", CurrentSize);
			aCount += 1;Almost forgot this
		EndWhile
		
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Breast_AddListMade");;DELETE ME FOR FINAL RELEASE, ONLY FOR TESTING LAG
		EndIf
		
		FloatListSort(zTarget, "CANS.SortedBreast"); Sorted list.
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Breast_AddListSorted")
		EndIf
		aCount = 0;
		While aCount < bCount;
			NewSize = (FloatListGet(zTarget, "CANS.SortedBreast", (bCount-aCount)))*(1/(Math.Pow(CANSframe.DecreasingAdditiveFactor, aCount))) 
			;Gets the floats from the list counting backwards, since sorting sorts it in ascending order. Multiplies it by a decreasing factor.
			If NewSize < 1.0
				NewSize = (1.0-NewSize);
			ElseIf NewSize == 1.0
				NewSize = 0.0;
			EndIf
			FinalSize += NewSize;
			aCount += 1;
		EndWhile
		
		FloatListClear(zTarget, "CANS.SortedBreast"); Deletes the sorted list to save data
		
		;;NEED TO TEST FOR LAG. POTENTIAL MULTITHREADING POINT
		
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Breast{"+FinalSize+"}AddEnd")
		EndIf
		
		
	ElseIf CANSframe.CANS_Breast_Mode == 2 ;Weighted average
		;Math (wt*value)+(wt*value)
		;Note: If all weights let at 1.0 this is effectively the legacy additive.
		bCount = StringListCount(zTarget, "CANS.Mods");
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Breast{"+ModName+"}WavgStart")
		EndIf
		
		aCount = 0
		While aCount < bCount;This is some weird bullshit going on because the sort function in storage util is in ascending order
			
			If WeightingMode == 0
				zName = StringListGet(zTarget, "CANS.Mods", aCount);
				zCat = GetStringValue(None, "CANS."+zName+".Category", "Uncat")
				If zCat == "Pregnany"
					WeightMult = CANSframe.PregnancyBreastWeight;
				ElseIf zCat == "Milking"
					WeightMult = CANSframe.MilkingBreastWeight;
				ElseIf zCat == "Inflation"
					WeightMult = CANSframe.InflationBreastWeight;
				ElseIf zCat == "Cumflation"
					WeightMult = CANSframe.CumflationBreastWeight;
				ElseIf zCat == "MiscCat"
					WeightMult = CANSframe.MiscCatBreastWeight;
				Else
					WeightMult = CANSframe.UncatBreastWeight;
				EndIf
				;Weight multiplier set up for the categories.
					
			ElseIf WeightingMode == 1;Individual weights
				WeightMult = GetFloatValue(None, "CANS."+zName+".Weight",1.0)
				If HasFloatValue(None, "CANS."+zName+".Weight") == False
					SetFloatValue(None, "CANS."+zName+".Weight",1.0)
				EndIf
			ElseIf WeightingMode == 2;no weights
				WeightMult = 1.0;
			Else
				Debug.Trace("$CANS_ERROR_5{"+ModName+"}");
				WeightMult = 1.0;
			EndIf
			
			FinalSize += GetFloatValue(zTarget, "CANS."+zName+".Breast")*WeightMult
			aCount += 1;Almost forgot this
		EndWhile
		
		
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Breast_WavgEnd")
		EndIf
		
	ElseIf CANSframe.CANS_Breast_Mode == 3 ;Legacy additive
		bCount = StringListCount(zTarget, "CANS.Mods");
		aCount = 0;
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Breast{"+ModName+"}LAddStart")
		EndIf
		
		While aCount < bCount
			zName = StringListGet(zTarget, "CANS.Mods", aCount);
			FinalSize += GetFloatValue(zTarget, "CANS."+zName+".Breast")
		EndWhile
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Breast{"+FinalSize+"}LAddEnd")
		EndIf
		
	ElseIf CANSframe.CANS_Breast_Mode == 4 ;sqrt of sum of squares
		bCount = StringListCount(zTarget, "CANS.Mods");
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Breast{"+ModName+"}SQstart")
		EndIf
		
		aCount = 0
		While aCount < bCount;This is some weird bullshit going on because the sort function in storage util is in ascending order
			
			If WeightingMode == 0
				zName = StringListGet(zTarget, "CANS.Mods", aCount);
				zCat = GetStringValue(None, "CANS."+zName+".Category", "Uncat")
				If zCat == "Pregnany"
					WeightMult = CANSframe.PregnancyBreastWeight;
				ElseIf zCat == "Milking"
					WeightMult = CANSframe.MilkingBreastWeight;
				ElseIf zCat == "Inflation"
					WeightMult = CANSframe.InflationBreastWeight;
				ElseIf zCat == "Cumflation"
					WeightMult = CANSframe.CumflationBreastWeight;
				ElseIf zCat == "MiscCat"
					WeightMult = CANSframe.MiscCatBreastWeight;
				Else
					WeightMult = CANSframe.UncatBreastWeight;
				EndIf
				;Weight multiplier set up for the categories.
					
			ElseIf WeightingMode == 1;Individual weights
				WeightMult = GetFloatValue(None, "CANS."+zName+".Weight",1.0)
				If HasFloatValue(None, "CANS."+zName+".Weight") == False
					SetFloatValue(None, "CANS."+zName+".Weight",1.0)
				EndIf
			ElseIf WeightingMode == 2;no weights
				WeightMult = 1.0;
			Else
				Debug.Trace("$CANS_ERROR_5{"+ModName+"}");
				WeightMult = 1.0;
			EndIf
			
			
			CurrentSize = Math.Pow(GetFloatValue(zTarget, "CANS."+zName+".Breast")*WeightMult, 2);
			If CurrentSize >= 1.0
				FinalSize += CurrentSize
			Else;Size was less than 1
				FinalSize -= CurrentSize
			EndIf
			aCount += 1;Almost forgot this
		EndWhile
		
		FinalSize = Math.Sqrt(FinalSize);
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Breast{"+FinalSize+"}SQend")
		EndIf
		
	ElseIf CANSframe.CANS_Breast_Mode == 5 ;Legacy Average, because I don't forget my roots
		bCount = StringListCount(zTarget, "CANS.Mods");
		aCount = 0;
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Breast{"+ModName+"}LAvgStart")
		EndIf
		
		While aCount < bCount
			zName = StringListGet(zTarget, "CANS.Mods", aCount);
			FinalSize += GetFloatValue(zTarget, "CANS."+zName+".Breast")
		EndWhile
		
		FinalSize = FinalSize/bCount;
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Breast{"+FinalSize+"}LAvgEnd")
		EndIf
	EndIf
	
	If CANSframe.CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_Breast{"+ModName+"}_Finale{"+FinalSize+"}begin")
	EndIf
	
	If (FinalSize > CANSframe.MaxBreastSize) && (CANSframe.MaxBreastEnabled == True) ;Catch in case size is over the limit.
		FinalSize = CANSframe.MaxBreastSize;
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Breast_OverMax")
		EndIf
	EndIf
	
	If FinalSize <= 0
		FinalSize = 1
	EndIf
	
	If FinalSize == 1.0 ;If the size is one, remove the CANS NiO instead of just updateing it. Slightly saves memory, possibly performance.
		If CANSframe.CANS_Tracelogging == True
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
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Breast_resize")
		EndIf
		NiOverride.AddNodeTransformScale(zTarget, False, True, LeftBreast, "C.A.N.S.", FinalSize)
		NiOverride.AddNodeTransformScale(zTarget, False, True, RightBreast, "C.A.N.S.", FinalSize)
		If zTarget == Game.GetPlayer()
			NiOverride.AddNodeTransformScale(zTarget, True, True, LeftBreast, "C.A.N.S.", FinalSize)
			NiOverride.AddNodeTransformScale(zTarget, True, True, RightBreast, "C.A.N.S.", FinalSize)
		EndIf
	EndIf
	
	;;TRACELOG POINT
	
	;;BREAST CURVE
	
	If GetIntValue(None, "CANS.TorpedoFix", 0) == 1 &&  NetImmerse.HasNode(zTarget, RightBreast01, False) && NetImmerse.HasNode(zTarget, LeftBreast01, False)
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("$CANS_Debug_Breast_TorpedoFix")
		endif
		Float CurveFix
		If FinalSize <= 1
			CurveFix = 1.0
		Else
			CurveFix = 1.0 - (GetFloatValue(None, "CANS.TorpedoFixValue")*FinalSize)
		EndIf
		NiOverride.AddNodeTransformScale(zTarget, False, True, RightBreast01, "C.A.N.S.", CurveFix)
		NiOverride.AddNodeTransformScale(zTarget, False, True, LeftBreast01, "C.A.N.S.", CurveFix)

		If zTarget == Game.GetPlayer()
			NiOverride.AddNodeTransformScale(zTarget, True, True, RightBreast01, "C.A.N.S.", CurveFix)
			NiOverride.AddNodeTransformScale(zTarget, True, True, LeftBreast01, "C.A.N.S.", CurveFix)
		EndIf

	EndIf
	
	;;TRACELOG POINT
	
	;;WW BREASTS
	If (NetImmerse.HasNode(zTarget, WWRBreast1, False)) && (NetImmerse.HasNode(zTarget, WWLBreast1, False)) && (NetImmerse.HasNode(zTarget, WWRBreast2, False)) && (NetImmerse.HasNode(zTarget, WWLBreast2, False)) && (NetImmerse.HasNode(zTarget, WWRBreast3, False)) && (NetImmerse.HasNode(zTarget, WWLBreast3, False))
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("$CANS_Debug_Breasts_WW")
		endif
		NiOverride.AddNodeTransformScale(zTarget, False, True, WWRBreast1, "C.A.N.S.", FinalSize)
		NiOverride.AddNodeTransformScale(zTarget, False, True, WWLBreast1, "C.A.N.S.", FinalSize)
		NiOverride.AddNodeTransformScale(zTarget, False, True, WWRBreast2, "C.A.N.S.", FinalSize)
		NiOverride.AddNodeTransformScale(zTarget, False, True, WWLBreast2, "C.A.N.S.", FinalSize)
		NiOverride.AddNodeTransformScale(zTarget, False, True, WWRBreast3, "C.A.N.S.", FinalSize)
		NiOverride.AddNodeTransformScale(zTarget, False, True, WWLBreast3, "C.A.N.S.", FinalSize)
		
		If zTarget == Game.GetPlayer()
			NiOverride.AddNodeTransformScale(zTarget, true, True, WWRBreast1, "C.A.N.S.", FinalSize)
			NiOverride.AddNodeTransformScale(zTarget, true, True, WWLBreast1, "C.A.N.S.", FinalSize)
			NiOverride.AddNodeTransformScale(zTarget, true, True, WWRBreast2, "C.A.N.S.", FinalSize)
			NiOverride.AddNodeTransformScale(zTarget, true, True, WWLBreast2, "C.A.N.S.", FinalSize)
			NiOverride.AddNodeTransformScale(zTarget, true, True, WWRBreast3, "C.A.N.S.", FinalSize)
			NiOverride.AddNodeTransformScale(zTarget, true, True, WWLBreast3, "C.A.N.S.", FinalSize)
		endif			
	EndIf
	;;TRACELOG POINT
	
	If CANSframe.CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_Breast{"+ModName+"}_Finale{"+FinalSize+"}end")
	EndIf
	
EndFunction

Int Function Butt(Actor aTarget, String ModName) ;Done
	;Modes in CANS 2:
		;0:Highest Value Only
		;1:Additive (Weighted) ;Intended to be used with weighting to prevent scales from becoming increasingly ridiculous.
		;2:Weighted Average (no division by summation)
		;3:Additive (Legacy) straight additive
	;Weighting modes:
		;0: Categorical weights
		;1: individual weights
		;2: no weighting
	
	Int WeightingMode = CANSframe.CANS_WeightingMode;
		;StringList CANS.Mods w/ names
		;Weighting stored  globally as cans.modname.Weight
		;Cat stored as CANS.ModName.Category
		
		;Get size of modlist
		;loop through it using those.
		;Index starts at 0???
		;Use that to pull up either the category or the weight.
	
	int aCount = 0;
	int bCount = 0;
	
	Float CurrentSize = 0.0;
	Float NewSize = 0.0;
	Float FinalSize = 0.0;
	
	Float WeightMult = 0.0;
	Float CatLimit = 0.0;
	String zName = "";
	String zCat = "";
	
	If CANSframe.CANS_Butt_Mode == 0 ;Highest value only
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Butt{"+ModName+"}_HVstart")
		EndIf
		;Ignores weighting. 
		;Takes into consideration max values.
		bCount = StringListCount(zTarget, "CANS.Mods") ;Find number of mods on an actor. Theoretically less than 384 but you never know do ya?
		
		While aCount < bCount;
			zName = StringListGet(zTarget, "CANS.Mods", aCount);
			NewSize = GetFloatValue(zTarget, "CANS."+zName+".Butt")
			If CurrentSize < NewSize
				CurrentSize = NewSize
				If CANSframe.CANS_Tracelogging == True
					Debug.Trace("$CANS_Debug_Butt{"+zName+"}_HVChange")
				EndIf
			EndIf
			aCount += 1
		EndWhile
		FinalSize = CurrentSize
		
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Butt{"+FinalSize+"}_HVend")
		EndIf
		
	ElseIf CANSframe.CANS_Butt_Mode == 1 ;Additive
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Butt{"+ModName+"}_AddBegin")
		EndIf
		
		;Weighted
		;(wt*v1)+1/(f^2)*(wt*v2)...
		bCount = StringListCount(zTarget, "CANS.Mods");
		
		aCount = 0
		While aCount < bCount;This is some weird bullshit going on because the sort function in storage util is in ascending order
			
			If WeightingMode == 0
				zName = StringListGet(zTarget, "CANS.Mods", aCount);
				zCat = GetStringValue(None, "CANS."+zName+".Category", "UnCat")
				If zCat == "Pregnany"
					WeightMult = CANSframe.PregnancyButtWeight;
				ElseIf zCat == "Milking"
					WeightMult = CANSframe.MilkingButtWeight;
				ElseIf zCat == "Inflation"
					WeightMult = CANSframe.InflationButtWeight;
				ElseIf zCat == "Cumflation"
					WeightMult = CANSframe.CumflationButtWeight;
				ElseIf zCat == "MiscCat"
					WeightMult = CANSframe.MiscCatButtWeight;
				Else
					WeightMult = CANSframe.UncatButtWeight;
				EndIf
				;Weight multiplier set up for the categories.
					
			ElseIf WeightingMode == 1;Individual weights
				WeightMult = GetFloatValue(None, "CANS."+zName+".Weight",1.0)
				If HasFloatValue(None, "CANS."+zName+".Weight") == False
					SetFloatValue(None, "CANS."+zName+".Weight",1.0)
				EndIf
			ElseIf WeightingMode == 2;no weights
				WeightMult = 1.0;
			Else
				Debug.Trace("$CANS_ERROR_5{"+ModName+"}");
				WeightMult = 1.0;
			EndIf
			
			CurrentSize = GetFloatValue(zTarget, "CANS."+zName+".Butt")*WeightMult
			FloatListAdd(zTarget, "CANS.SortedButt", CurrentSize);
			aCount += 1;Almost forgot this
		EndWhile
		
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Butt_AddListMade");;DELETE ME FOR FINAL RELEASE, ONLY FOR TESTING LAG
		EndIf
		
		FloatListSort(zTarget, "CANS.SortedButt"); Sorted list.
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Butt_AddListSorted")
		EndIf
		aCount = 0;
		While aCount < bCount;
			NewSize = (FloatListGet(zTarget, "CANS.SortedButt", (bCount-aCount)))*(1/(Math.Pow(CANSframe.DecreasingAdditiveFactor, aCount))) 
			;Gets the floats from the list counting backwards, since sorting sorts it in ascending order. Multiplies it by a decreasing factor.
			If NewSize < 1.0
				NewSize = (1.0-NewSize);
			ElseIf NewSize == 1.0
				NewSize = 0.0;
			EndIf
			FinalSize += NewSize;
			aCount += 1;
		EndWhile
		
		FloatListClear(zTarget, "CANS.SortedButt"); Deletes the sorted list to save memory
		
		;;NEED TO TEST FOR LAG.
		
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Butt{"+FinalSize+"}AddEnd")
		EndIf
		
		
	ElseIf CANSframe.CANS_Butt_Mode == 2 ;Weighted average
		;Math (wt*value)+(wt*value)
		;Note: If all weights let at 1.0 this is effectively the legacy additive.
		bCount = StringListCount(zTarget, "CANS.Mods");
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Butt{"+ModName+"}WavgStart")
		EndIf
		
		aCount = 0
		While aCount < bCount;This is some weird bullshit going on because the sort function in storage util is in ascending order
			
			If WeightingMode == 0
				zName = StringListGet(zTarget, "CANS.Mods", aCount);
				zCat = GetStringValue(None, "CANS."+zName+".Category", "UnCat")
				If zCat == "Pregnany"
					WeightMult = CANSframe.PregnancyButtWeight;
				ElseIf zCat == "Milking"
					WeightMult = CANSframe.MilkingButtWeight;
				ElseIf zCat == "Inflation"
					WeightMult = CANSframe.InflationButtWeight;
				ElseIf zCat == "Cumflation"
					WeightMult = CANSframe.CumflationButtWeight;
				ElseIf zCat == "MiscCat"
					WeightMult = CANSframe.MiscCatButtWeight;
				Else
					WeightMult = CANSframe.UncatButtWeight;
				EndIf
				;Weight multiplier set up for the categories.
					
			ElseIf WeightingMode == 1;Individual weights
				WeightMult = GetFloatValue(None, "CANS."+zName+".Weight",1.0)
				If HasFloatValue(None, "CANS."+zName+".Weight") == False
					SetFloatValue(None, "CANS."+zName+".Weight",1.0)
				EndIf
			ElseIf WeightingMode == 2;no weights
				WeightMult = 1.0;
			Else
				Debug.Trace("$CANS_ERROR_5{"+ModName+"}");
				WeightMult = 1.0;
			EndIf
			
			FinalSize += GetFloatValue(zTarget, "CANS."+zName+".Butt")*WeightMult
			aCount += 1;Almost forgot this
		EndWhile
		
		
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Butt_WavgEnd")
		EndIf
		
	ElseIf CANSframe.CANS_Butt_Mode == 3 ;Legacy additive
		bCount = StringListCount(zTarget, "CANS.Mods");
		aCount = 0;
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Butt{"+ModName+"}LAddStart")
		EndIf
		
		While aCount < bCount
			zName = StringListGet(zTarget, "CANS.Mods", aCount);
			FinalSize += GetFloatValue(zTarget, "CANS."+zName+".Butt")
		EndWhile
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Butt{"+FinalSize+"}LAddEnd")
		EndIf
		
	ElseIf CANSframe.CANS_Butt_Mode == 4 ;sqrt of sum of squares
		bCount = StringListCount(zTarget, "CANS.Mods");
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Butt{"+ModName+"}SQstart")
		EndIf
		
		aCount = 0
		While aCount < bCount;This is some weird bullshit going on because the sort function in storage util is in ascending order
			
			If WeightingMode == 0
				zName = StringListGet(zTarget, "CANS.Mods", aCount);
				zCat = GetStringValue(None, "CANS."+zName+".Category", "UnCat")
				If zCat == "Pregnany"
					WeightMult = CANSframe.PregnancyButtWeight;
				ElseIf zCat == "Milking"
					WeightMult = CANSframe.MilkingButtWeight;
				ElseIf zCat == "Inflation"
					WeightMult = CANSframe.InflationButtWeight;
				ElseIf zCat == "Cumflation"
					WeightMult = CANSframe.CumflationButtWeight;
				ElseIf zCat == "MiscCat"
					WeightMult = CANSframe.MiscCatButtWeight;
				Else
					WeightMult = CANSframe.UncatButtWeight;
				EndIf
				;Weight multiplier set up for the categories.
					
			ElseIf WeightingMode == 1;Individual weights
				WeightMult = GetFloatValue(None, "CANS."+zName+".Weight",1.0)
				If HasFloatValue(None, "CANS."+zName+".Weight") == False
					SetFloatValue(None, "CANS."+zName+".Weight",1.0)
				EndIf
			ElseIf WeightingMode == 2;no weights
				WeightMult = 1.0;
			Else
				Debug.Trace("$CANS_ERROR_5{"+ModName+"}");
				WeightMult = 1.0;
			EndIf
			
			
			CurrentSize = Math.Pow(GetFloatValue(zTarget, "CANS."+zName+".Butt")*WeightMult, 2);
			If CurrentSize >= 1.0
				FinalSize += CurrentSize
			Else;Size was less than 1
				FinalSize -= CurrentSize
			EndIf
			aCount += 1;Almost forgot this
		EndWhile
		
		FinalSize = Math.Sqrt(FinalSize);
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Butt{"+FinalSize+"}SQend")
		EndIf
		
	ElseIf CANSframe.CANS_Butt_Mode == 5 ;Legacy Average, because I don't forget my roots
		bCount = StringListCount(zTarget, "CANS.Mods");
		aCount = 0;
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Butt{"+ModName+"}LAvgStart")
		EndIf
		
		While aCount < bCount
			zName = StringListGet(zTarget, "CANS.Mods", aCount);
			FinalSize += GetFloatValue(zTarget, "CANS."+zName+".Butt")
		EndWhile
		
		FinalSize = FinalSize/bCount;
		
		If CANSframe.CANS_TraceLogging == True
			Debug.Trace("CANS_Debug_Butt{"+FinalSize+"}LAvgEnd")
		EndIf
	EndIf
	
	If CANSframe.CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_Butt{"+ModName+"}_Finale{"+FinalSize+"}begin")
	EndIf
	
	If (FinalSize > CANSframe.MaxButtSize) && (CANSframe.MaxButtEnabled == True) ;Catch in case size is over the limit.
		FinalSize = CANSframe.MaxButtSize;
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Butt_OverMax")
		EndIf
	EndIf
	
	If FinalSize <= 0
		FinalSize = 1
	EndIf
	
	If FinalSize == 1.0 ;If the size is one, remove the CANS NiO instead of just updateing it. Slightly saves memory, possibly performance.
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Butt_unsize")
		EndIf
		NiOverride.RemoveNodeTransformScale(zTarget, False, True, LeftButt, "C.A.N.S.")
		NiOverride.RemoveNodeTransformScale(zTarget, False, True, RightButt, "C.A.N.S.")
		If zTarget == Game.GetPlayer()
			NiOverride.RemoveNodeTransformScale(zTarget, True, True, LeftButt, "C.A.N.S.")
			NiOverride.RemoveNodeTransformScale(zTarget, True, True, RightButt, "C.A.N.S.")
		EndIf
		Return 2;
	Else ;otherwise update the size
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("$CANS_Debug_Butt_resize")
		EndIf
		NiOverride.AddNodeTransformScale(zTarget, False, True, LeftButt, "C.A.N.S.", FinalSize)
		NiOverride.AddNodeTransformScale(zTarget, False, True, RightButt, "C.A.N.S.", FinalSize)
		If zTarget == Game.GetPlayer()
			NiOverride.AddNodeTransformScale(zTarget, True, True, LeftButt, "C.A.N.S.", FinalSize)
			NiOverride.AddNodeTransformScale(zTarget, True, True, RightButt, "C.A.N.S.", FinalSize)
		EndIf
	EndIf
	
	If CANSframe.CANS_Tracelogging == True
		Debug.Trace("$CANS_Debug_Butt{"+ModName+"}_Finale{"+FinalSize+"}end")
	EndIf
	
EndFunction

Function EndMe() ;Done
	;Removes the Int value, removes itself from the active frame arrays
	;unregisters for updates
	;dispels itself
	If (CANSframe.CANS_Tracelogging == True)
		Debug.Trace("$CANS_Debug_EffectEnding{"+zTarget.GetLeveledActorBase().GetName()+"}")
	EndIf
	UnsetIntValue(zTarget, "CANS.EffectIdx");
	CANSframe.EndEffect(self, MyIdx);
	UnregisterForUpdate(); Just in case
	Self.Dispel();

EndFunction

