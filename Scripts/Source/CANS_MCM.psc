ScriptName CANS_MCM Extends SKI_ConfigBase
{CANS MCM 3.0, For the complete CANS rework. Essentially CANS MCM 2.0 but with some neat new touches. and some hacky workarounds}

Import StorageUtil

;Properties
CANS_Framework Property CANSframe Auto
Quest Property CANS Auto
;CANS itself since the global variables have been removed. They were pointless clutter.


;variables
String[] ModeType
String[] WeightType
String version = "1.0.0.0"
bool CurveToggle
Int TotalModCount
Int ActorCount
int zCount ;Used in the uninstalling options to avoid writing 2 sets of 128 nearly identical snippets.
;String


;Meta variables I need a lot for an MCM
Int DisableThis
Int NoFlag
String InfoTextWeight = "$CANS_Info_Weight"
String InfoTextUninstall = "$CANS_Info_Uninstall"
Actor target


;Option ID's.
;Using NP++ comment folding (BeginFold,MidFold,EndFold)
;Page 1 BeginFold
int Option_BellyMode;
int Option_BreastMode;
int Option_ButtMode;
int Option_Weight;
int DelayID;
int OverrideEnable
int DecreasingFactor
int TorpedoToggle
int TorpedoFix
int ToggleMaxBelly
int MaxBellyID
int ToggleMaxBreast
int MaxBreastID
int ToggleMaxButt
int MaxButtID
int Ignore00
int Ignore01
int Ignore02
int Ignore03
int Ignore04
int Ignore05
int Ignore06
int Uninstall_ID
;Page 2 Midfold
int PregnancyWeight1_ID
int PregnancyWeight2_ID
int PregnancyWeight3_ID
int CumflationWeight1_ID
int CumflationWeight2_ID
int CumflationWeight3_ID
int MiscWeight1_ID
int MiscWeight2_ID
int MiscWeight3_ID
int MilkingWeight1_ID
int MilkingWeight2_ID
int MilkingWeight3_ID
int InflationWeight1_ID
int InflationWeight2_ID
int InflationWeight3_ID
int UnCatWeight1_ID
int UnCatWeight2_ID
int UnCatWeight3_ID
;Individual Weights  MidFold
Int[] IndivWeight_P1
Int[] IndivWeight_P2
Int[] IndivWeight_P3
;Uninstall Buttons MidFold
Int[] ModUninstall_P1
Int[] ModUninstall_P2
Int[] ModUninstall_P3
;Fun fact, these 6 arrays cut out more than 2000 lines of code immediately, at the time of this writing, that would have been 45% of this file.
;THroughout the course of this file they cut out easily 3 times that much, taking the original size from nearly 10,000 lines of code to 2,500
;Debug PAge MidFold
Int TraceLogToggle
Int EndOverrides0
Int EndOverrides1
Int EndOverrides2
Int EndOverrides3
;EndFold


Event OnConfigInit()
	DisableThis = OPTION_FLAG_DISABLED
	NoFlag = OPTION_FLAG_NONE
	target = Game.GetPlayer()
	
	ModeType = New String[6]
	ModeType[0] = "$CANS_MCM_Mode_1" ;HVO
	ModeType[1] = "$CANS_MCM_Mode_2" ;Additive
	ModeType[2] = "$CANS_MCM_Mode_3" ;Weighted Average
	ModeType[3] = "$CANS_MCM_Mode_4" ;Legacy Additive
	ModeType[4] = "$CANS_MCM_Mode_5" ;sqrt of sum of squares
	ModeType[5] = "$CANS_MCM_Mode_6" ;legacy average
	
	WeightType = New String[3]
	WeightType[0] = "$CANS_MCM_Weight_1"
	WeightType[1] = "$CANS_MCM_Weight_2"
	WeightType[2] = "$CANS_MCM_Weight_3"
	
	
	ModUninstall_P1 = New Int[128];
	ModUninstall_P2 = New Int[128];
	ModUninstall_P3 = New Int[128];
	
	IndivWeight_P1 = New Int[128];
	IndivWeight_P2 = New Int[128];
	IndivWeight_P3 = New Int[128];
	
	
EndEvent

Event OnConfigOpen() ;Dynamically resets the pages every time you open the menu to keep them up to date with how many mods you've got

	If GetIntValue(None, "CANS.TorpedoFix", 0) == 0
		CurveToggle = False
	Else
		CurveToggle = True
	EndIf

	If CANSframe.ModCount() <= 127	
		Pages = New String[5]
		Pages[0] = "$CANS_MCM_Page_General"
		Pages[1] = "$CANS_MCM_Page_Category"
		Pages[2] = "$CANS_MCM_Page_ModList"
		Pages[3] = "$CANS_MCM_Page_Weights"
		Pages[4] = "$CANS_MCM_Page_Debug"
	ElseIf CANSframe.ModCount() <= 255
		Pages = New String[7]
		Pages[0] = "$CANS_MCM_Page_General"
		Pages[1] = "$CANS_MCM_Page_Category"
		Pages[2] = "$CANS_MCM_Page_ModListB1"
		Pages[3] = "$CANS_MCM_Page_ModListB2"
		Pages[4] = "$CANS_MCM_Page_WeightsB1"
		Pages[5] = "$CANS_MCM_Page_WeightsB2"
		Pages[6] = "$CANS_MCM_Page_Debug"
	ElseIf CANSFrame.ModCount() <= 383
		Pages = New String[9]
		Pages[0] = "$CANS_MCM_Page_General"
		Pages[1] = "$CANS_MCM_Page_Category"
		Pages[2] = "$CANS_MCM_Page_ModListB1"
		Pages[3] = "$CANS_MCM_Page_ModListB2"
		Pages[4] = "$CANS_MCM_Page_ModListB3"
		Pages[5] = "$CANS_MCM_Page_WeightsB1"
		Pages[6] = "$CANS_MCM_Page_WeightsB2"
		Pages[7] = "$CANS_MCM_Page_WeightsB3"
		Pages[8] = "$CANS_MCM_Page_Debug"
	Else
		Pages = New String[5]
		Pages[0] = "$CANS_MCM_Page_General"
		Pages[1] = "$CANS_MCM_Page_Category"
		Pages[2] = "$CANS_MCM_Page_ModList"
		Pages[3] = "$CANS_MCM_Page_Weights"
		Pages[4] = "$CANS_MCM_Page_Debug"
	EndIf
	;Now with page support for 384 mods
	
EndEvent

Event OnPageReset(String Qpage)

	If (QPage == "")
		;Need to get someone to make splash art
		;LoadCustomContent("/CANS/MCMSplash.swf")
	Else
		;UnLoadCustomContent()
	EndIf
	
	If (Qpage == "$CANS_MCM_Page_General") ;Ready
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)
		
		AddHeaderOption("$CANS_MCM_HeaderGeneral")
		Option_BellyMode = AddMenuOption("$CANS_BellyMode", ModeType[CANSframe.CANS_Belly_Mode])
		Option_BreastMode = AddMenuOption("$CANS_BreastMode", ModeType[CANSframe.CANS_Breast_Mode])
		Option_ButtMode = AddMenuOption("$CANS_ButtMode", ModeType[CANSframe.CANS_Butt_Mode])
		AddEmptyOption()
		Option_Weight = AddMenuOption("$CANS_WeightMode", WeightType[CANSframe.CANS_WeightingMode])
		AddEmptyOption()
		DelayID = AddSliderOption("Update Delay", CANSframe.UpdateDelay)
		AddEmptyOption()
		AddHeaderOption("$CANS_MaxNodeScales")
		ToggleMaxBelly = AddToggleOption("$CANS_Belly", CANSframe.MaxBellyEnabled)
		MaxBellyID = AddSliderOption("$CANS_MaxBellyScale", CANSframe.MaxBellySize)
		ToggleMaxBreast = AddToggleOption("$CANS_Breast", CANSFrame.MaxBreastEnabled)
		MaxBreastID = AddSliderOption("$CANS_MaxBreastScale", CANSframe.MaxBreastSize)
		ToggleMaxButt = AddToggleOption("$CANS_Butt", CANSframe.MaxButtEnabled)
		MaxButtID = AddSliderOption("$CANS_MaxButtScale", CANSframe.MaxButtSize)
		AddEmptyOption()
		AddHeaderOption("$CANS_AdvancedFeatures")
		OverrideEnable = AddToggleOption("$CANS_OverrideToggle", CANSframe.CANS_Override)
		DecreasingFactor = AddSliderOption("$CANS_DecreasingFactor", CANSframe.DecreasingAdditiveFactor)
		AddEmptyOption()
		AddHeaderOption("$CANS_TorpedoFix")
		TorpedoToggle = AddToggleOption("$CANS_TorpedoFixT", CurveToggle)
		if CurveToggle == True
			TorpedoFix = AddSliderOption("$CANS_BreastCurve", GetFloatValue(None, "CANS.TorpedoFixValue", 0.0), "{0}", NoFlag)
		Else
			TorpedoFix = AddSliderOption("$CANS_BreastCurve", GetFloatValue(None, "CANS.TorpedoFixValue", 0.0), "{0}", DisableThis)
		EndIf
		
		SetCursorPosition(1)
		AddHeaderOption("$CANS_MCM_HeaderStatus")
		Ignore00 = AddTextOption("$CANS_MCM_Version{"+version+"}", "", DisableThis)
		Ignore01 = AddTextOption("$CANS_MCM_Mods{"+CANSframe.ModCount()+"}", "", DisableThis)
		Ignore02 = AddTextOption("$CANS_MCM_Actors{"+CANSframe.ActorCount()+"}", "", DisableThis)
		AddEmptyOption()
		Ignore03 = AddTextOption("$CANS_MCM_Player{"+target.GetActorBase().GetName()+"}1", "", DisableThis)
		Ignore04 = AddTextOption("$CANS_Belly", NiOverride.GetNodeTransformScale(target, false, true, CANSframe.Belly, "C.A.N.S."));
		Ignore05 = AddTextOption("$CANS_Breast", NiOverride.GetNodeTransformScale(target, false, true, CANSframe.RightBreast, "C.A.N.S."))
		Ignore06 = AddTextOption("$CANS_Butt", NiOverride.GetNodeTransformScale(target, false, true, CANSframe.RightButt, "C.A.N.S."))
		AddEmptyOption()
		AddEmptyOption()
		Uninstall_ID = AddTextOption("$CANS_Uninstall", "")
		
	ElseIf (Qpage == "$CANS_MCM_Page_Category") ;Ready
		SetCursorPosition(0)
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		AddHeaderOption("$CANS_Pregnancy")
		PregnancyWeight1_ID = AddSliderOption("$CANS_BellyWeight", CANSframe.PregnancyBellyWeight)
		PregnancyWeight2_ID = AddSliderOption("$CANS_BreastWeight", CANSframe.PregnancyBreastWeight)
		PregnancyWeight3_ID = AddSliderOption("$CANS_ButtWeight", CANSframe.PregnancyButtWeight)
		AddEmptyOption()
		
		AddHeaderOption("$CANS_Cumflation")
		CumflationWeight1_ID = AddSliderOption("$CANS_BellyWeight", CANSframe.CumflationBellyWeight)
		CumflationWeight2_ID = AddSliderOption("$CANS_BreastWeight", CANSframe.CumflationBreastWeight)
		CumflationWeight3_ID = AddSliderOption("$CANS_ButtWeight", CANSframe.CumflationButtWeight)
		AddEmptyOption()
		
		AddHeaderOption("$CANS_MiscCat")
		MiscWeight1_ID = AddSliderOption("$CANS_BellyWeight", CANSframe.MiscCatBellyWeight)
		MiscWeight2_ID = AddSliderOption("$CANS_BreastWeight", CANSframe.MiscCatBreastWeight)
		MiscWeight3_ID = AddSliderOption("$CANS_ButtWeight", CANSframe.MiscCatButtWeight)
		AddEmptyOption()
		
		SetCursorPosition(1)
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		AddHeaderOption("$CANS_Milking")
		MilkingWeight1_ID = AddSliderOption("$CANS_BellyWeight", CANSframe.MilkingBellyWeight)
		MilkingWeight2_ID = AddSliderOption("$CANS_BreastWeight", CANSframe.MilkingBreastWeight)
		MilkingWeight3_ID = AddSliderOption("$CANS_ButtWeight", CANSframe.MilkingButtWeight)
		AddEmptyOption()
		
		AddHeaderOption("$CANS_Inflation")
		InflationWeight1_ID = AddSliderOption("$CANS_BellyWeight", CANSframe.InflationBellyWeight)
		InflationWeight2_ID = AddSliderOption("$CANS_BreastWeight", CANSframe.InflationBreastWeight)
		InflationWeight3_ID = AddSliderOption("$CANS_ButtWeight", CANSframe.InflationButtWeight)
		AddEmptyOption()
		
		AddHeaderOption("$CANS_Uncat")
		UncatWeight1_ID = AddSliderOption("$CANS_BellyWeight", CANSframe.UncatBellyWeight)
		UncatWeight2_ID = AddSliderOption("$CANS_BreastWeight", CANSframe.UncatBreastWeight)
		UncatWeight3_ID = AddSliderOption("$CANS_ButtWeight", CANSframe.UncatButtWeight)
		AddEmptyOption()
		
	ElseIf (Qpage == "$CANS_MCM_Page_ModList") || (Qpage == "$CANS_MCM_Page_ModListB1") ;Ready
		
		int aCount = 0;
		int bCount = CANSframe.ModCount();
		SetCursorPosition(0);
		SetCursorFillMode(LEFT_TO_RIGHT);
		
		If bCount == 0;
			AddHeaderOption("$CANS_NoMods");
			aCount = 128;
		EndIf
			
		While (aCount < bCount) && (aCount < 128)
			ModUninstall_P1[aCount] = AddTextOption(aCount + ": " + CANSframe.ModNames1[aCount], "");
			aCount += 1;
		EndWhile
		
	ElseIf (Qpage == "$CANS_MCM_Page_ModListB2") ;Ready
		
		int aCount = 128;
		int bCount = CANSframe.ModCount();
		SetCursorPosition(0);
		SetCursorFillMode(LEFT_TO_RIGHT);
		
		If bCount == 0;
			AddHeaderOption("$CANS_NoMods");
			aCount = 256;
		EndIf
			
		While (aCount < bCount) && (aCount < 256)
			ModUninstall_P2[aCount] = AddTextOption(aCount + ": " + CANSframe.ModNames2[aCount], "");
			aCount += 1
		EndWhile
		
	ElseIf (Qpage == "$CANS_MCM_Page_ModListB3") ;Ready
		
		int aCount = 256;
		int bCount = CANSframe.ModCount();
		SetCursorPosition(0);
		SetCursorFillMode(LEFT_TO_RIGHT);
		
		If bCount == 0;
			AddHeaderOption("$CANS_NoMods");
			aCount = 384;
		EndIf
			
		While (aCount < bCount) && (aCount < 384)
			ModUninstall_P3[aCount] = AddTextOption(aCount + ": " + CANSframe.ModNames3[aCount], "");
			aCount += 1
		EndWhile
		
	ElseIf (Qpage == "$CANS_MCM_Page_Weights") || (Qpage == "$CANS_MCM_Page_WeightsB1") ;Ready
		
		int aCount = 0;
		int bCount = CANSframe.ModCount();
		SetCursorPosition(0);
		SetCursorFillMode(LEFT_TO_RIGHT);
		
		If bCount == 0;
			AddHeaderOption("$CANS_NoMods");
			aCount = 128;
		EndIf
		
		While (aCount < bCount) && (aCount < 128)
			String ModName = CANSframe.ModNames1[aCount];
			IndivWeight_P1[aCount] = AddSliderOption(ModName, GetFloatValue(None, "CANS."+ModName+".Weight", 1.0))
			aCount += 1;
		EndWhile
		
	ElseIf (Qpage == "$CANS_MCM_Page_WeightsB2") ;Ready
		
		int aCount = 0;
		int bCount = CANSframe.ModCount();
		SetCursorPosition(0);
		SetCursorFillMode(LEFT_TO_RIGHT);
		
		If bCount == 0;
			AddHeaderOption("$CANS_NoMods");
			aCount = 128;
		EndIf
		
		While (aCount < bCount) && (aCount < 128)
			String ModName = CANSframe.ModNames2[aCount];
			IndivWeight_P2[aCount] = AddSliderOption(ModName, GetFloatValue(None, "CANS."+ModName+".Weight", 1.0))
			aCount += 1;
		EndWhile
	
	ElseIf (Qpage == "$CANS_MCM_Page_WeightsB3") ;Ready
		
		int aCount = 0;
		int bCount = CANSframe.ModCount();
		SetCursorPosition(0);
		SetCursorFillMode(LEFT_TO_RIGHT);
		
		If bCount == 0;
			AddHeaderOption("$CANS_NoMods");
			aCount = 128;
		EndIf
		
		While (aCount < bCount) && (aCount < 128)
			String ModName = CANSframe.ModNames3[aCount];
			IndivWeight_P3[aCount] = AddSliderOption(ModName, GetFloatValue(None, "CANS."+ModName+".Weight", 1.0))
			aCount += 1;
		EndWhile
	
	ElseIf (Qpage == "$CANS_MCM_Page_Debug") ;Spells needed
		SetCursorPosition(0)
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("$CANS_TraceLogging")
		TraceLogToggle = AddToggleOption("$CANS_TraceLog", CANSframe.CANS_TraceLogging)
		AddEmptyOption()
		AddEmptyOption()
		AddHeaderOption("$CANS_Overrides")
		EndOverrides0 = AddTextOption("$CANS_EndOverrides0", "")
		EndOverrides1 = AddTextOption("$CANS_EndOverrides1", "")
		EndOverrides2 = AddTextOption("$CANS_EndOverrides2", "")
		EndOverrides3 = AddTextOption("$CANS_EndOverrides3", "")
		;SetCursorPosition(1)
		;AddHeaderOption("$CANS_Spells")
		;DebugSpell1 = AddTextOption("$CANS_Debug_S_1", "")
		;DebugSpell2 = AddTextOption("$CANS_Debug_S_2", "")
		;DebugSpell3 = AddTextOption("$CANS_Debug_S_3", "")
	Else
	
	EndIf

EndEvent 

Event OnOptionHighLight(int OID) ;Done for now, barring debug spells
	
	;General Settings beginfold
	If (OID == Uninstall_ID)
		SetInfoText("$CANS_Uninstall")
	ElseIf (OID == Option_BellyMode)
		SetInfoText("$CANS_Info_OptionBellyMode")
	ElseIf (OID == Option_BreastMode)
		SetInfoText("$CANS_Info_OptionBreastMode")
	ElseIf (OID == Option_ButtMode)
		SetInfoText("$CANS_Info_OptionButtMode")
	ElseIf (OID == Option_Weight)
		SetInfoText("$CANS_Info_OptionWeight")
	ElseIF (OID == TorpedoToggle)
		SetInfoText("$CANS_Info_TorpedoToggle")
	ElseIf (OID == TorpedoFix)
		SetInfoText("$CANS_Info_TorpedoFix")
	ElseIf (OID == ToggleMaxBelly)
		SetInfoText("$CANS_Info_ToggleMaxBelly")
	ElseIf (OID == ToggleMaxBreast)
		SetInfoText("$CANS_Info_ToggleMaxBreast")
	ElseIf (OID == ToggleMaxButt)
		SetInfoText("$CANS_Info_ToggleMaxButt")
	ElseIF (OID == MaxBellyID)
		SetInfoText("$CANS_Info_MaxBelly")
	ElseIf (OID == MaxBreastID)
		SetInfoText("$CANS_Info_MaxBreast")
	ElseIf (OID == MaxButtID)
		SetInfoText("$CANS_Info_MaxButt")
	ElseIf (OID == OverrideEnable)
		SetInfoText("$CANS_Info_OverrideToggle")
	ElseIf (OID == DecreasingFactor)
		SetInfoText("$CANS_Info_DecreasingFactor")
	ElseIf (OID == DelayID)
		SetInfoText("$CANS_Info_Delay")
	EndIf
	;endfold
	
	;Misc text, ignore. beginfold
	If (OID == Ignore00)
		SetInfoText("")
	ElseIf (OID == Ignore01)
		SetInfoText("")
	ElseIf (OID == Ignore02)
		SetInfoText("")
	ElseIf (OID == Ignore03)
		SetInfoText("")
	ElseIf (OID == Ignore04)
		SetInfoText("")
	ElseIf (OID == Ignore05)
		SetInfoText("")
	ElseIf (OID == Ignore06)
		SetInfoText("")
	EndIf
	;endfold
	
	;cat weights beginfold
	If (OID == PregnancyWeight1_ID)
		SetInfoText("$CANS_Info_Cat1")
	ElseIf (OID == PregnancyWeight2_ID)
		SetInfoText("$CANS_Info_Cat2")
	ElseIf (OID == PregnancyWeight3_ID)
		SetInfoText("$CANS_Info_Cat3")
	ElseIF (OID == CumflationWeight1_ID)
		SetInfoText("$CANS_Info_Cat1")
	ElseIf (OID == CumflationWeight2_ID)
		SetInfoText("$CANS_Info_Cat2")
	ElseIf (OID == CumflationWeight3_ID)
		SetInfoText("$CANS_Info_Cat3")
	ElseIf (OID == MiscWeight1_ID)
		SetInfoText("$CANS_Info_Cat1")
	ElseIf (OID == MiscWeight2_ID)
		SetInfoText("$CANS_Info_Cat2")
	ElseIf (OID == MiscWeight3_ID)
		SetInfoText("$CANS_Info_Cat3")
	ElseIf (OID == MilkingWeight1_ID)
		SetInfoText("$CANS_Info_Cat1")
	ElseIf (OID == MilkingWeight2_ID)
		SetInfoText("$CANS_Info_Cat2")
	ElseIf (OID == MilkingWeight3_ID)
		SetInfoText("$CANS_Info_Cat3")
	ElseIf (OID == InflationWeight1_ID)
		SetInfoText("$CANS_Info_Cat1")
	ElseIf (OID == InflationWeight2_ID)
		SetInfoText("$CANS_Info_Cat2")
	ElseIf (OID == InflationWeight3_ID)
		SetInfoText("$CANS_Info_Cat3")
	ElseIf (OID == UncatWeight1_ID)
		SetInfoText("$CANS_Info_Cat1")
	ElseIf (OID == UncatWeight2_ID)
		SetInfoText("$CANS_Info_Cat2")
	ElseIf (OID == UncatWeight3_ID)
		SetInfoText("$CANS_Info_Cat3")
	EndIf
	;endfold
	
	;Uninstall buttons p1 beginfold
	
	
	If (CurrentPage == "$CANS_MCM_Page_ModList") || (CurrentPage == "$CANS_MCM_Page_ModListB1")
		SetInfoText("$CANS_Info_Uninstall{"+CANSframe.ModNames1[zCount]+"}");
		
	;Actual work to sort out zCount midfold
		If (OID == ModUninstall_P1[0])
			zCount = 0;
		ElseIf (OID == ModUninstall_P1[1])
			zCount = 1;
		ElseIf (OID == ModUninstall_P1[2])
			zCount = 2;
		ElseIf (OID == ModUninstall_P1[3])
			zCount = 3;
		ElseIf (OID == ModUninstall_P1[4])
			zCount = 4;
		ElseIf (OID == ModUninstall_P1[5])
			zCount = 5;
		ElseIf (OID == ModUninstall_P1[6])
			zCount = 6;
		ElseIf (OID == ModUninstall_P1[7])
			zCount = 7;
		ElseIf (OID == ModUninstall_P1[8])
			zCount = 8;
		ElseIf (OID == ModUninstall_P1[9])
			zCount = 9;
		ElseIf (OID == ModUninstall_P1[10])
			zCount = 10;
		ElseIf (OID == ModUninstall_P1[11])
			zCount = 11;
		ElseIf (OID == ModUninstall_P1[12])
			zCount = 12;
		ElseIf (OID == ModUninstall_P1[13])
			zCount = 13;
		ElseIf (OID == ModUninstall_P1[14])
			zCount = 14;
		ElseIf (OID == ModUninstall_P1[15])
			zCount = 15;
		ElseIf (OID == ModUninstall_P1[16])
			zCount = 16;
		ElseIf (OID == ModUninstall_P1[17])
			zCount = 17;
		ElseIf (OID == ModUninstall_P1[18])
			zCount = 18;
		ElseIf (OID == ModUninstall_P1[19])
			zCount = 19;
		ElseIf (OID == ModUninstall_P1[20])
			zCount = 20;
		ElseIf (OID == ModUninstall_P1[21])
			zCount = 21;
		ElseIf (OID == ModUninstall_P1[22])
			zCount = 22;
		ElseIf (OID == ModUninstall_P1[23])
			zCount = 23;
		ElseIf (OID == ModUninstall_P1[24])
			zCount = 24;
		ElseIf (OID == ModUninstall_P1[25])
			zCount = 25;
		ElseIf (OID == ModUninstall_P1[26])
			zCount = 26;
		ElseIf (OID == ModUninstall_P1[27])
			zCount = 27;
		ElseIf (OID == ModUninstall_P1[28])
			zCount = 28;
		ElseIf (OID == ModUninstall_P1[29])
			zCount = 29;
		ElseIf (OID == ModUninstall_P1[30])
			zCount = 30;
		ElseIf (OID == ModUninstall_P1[31])
			zCount = 31;
		ElseIf (OID == ModUninstall_P1[32])
			zCount = 32;
		ElseIf (OID == ModUninstall_P1[33])
			zCount = 33;
		ElseIf (OID == ModUninstall_P1[34])
			zCount = 34;
		ElseIf (OID == ModUninstall_P1[35])
			zCount = 35;
		ElseIf (OID == ModUninstall_P1[36])
			zCount = 36;
		ElseIf (OID == ModUninstall_P1[37])
			zCount = 37;
		ElseIf (OID == ModUninstall_P1[38])
			zCount = 38;
		ElseIf (OID == ModUninstall_P1[39])
			zCount = 39;
		ElseIf (OID == ModUninstall_P1[40])
			zCount = 40;
		ElseIf (OID == ModUninstall_P1[41])
			zCount = 41;
		ElseIf (OID == ModUninstall_P1[42])
			zCount = 42;
		ElseIf (OID == ModUninstall_P1[43])
			zCount = 43;
		ElseIf (OID == ModUninstall_P1[44])
			zCount = 44;
		ElseIf (OID == ModUninstall_P1[45])
			zCount = 45;
		ElseIf (OID == ModUninstall_P1[46])
			zCount = 46;
		ElseIf (OID == ModUninstall_P1[47])
			zCount = 47;
		ElseIf (OID == ModUninstall_P1[48])
			zCount = 48;
		ElseIf (OID == ModUninstall_P1[49])
			zCount = 49;
		ElseIf (OID == ModUninstall_P1[50])
			zCount = 40;
		ElseIf (OID == ModUninstall_P1[51])
			zCount = 51;
		ElseIf (OID == ModUninstall_P1[52])
			zCount = 52;
		ElseIf (OID == ModUninstall_P1[53])
			zCount = 53;
		ElseIf (OID == ModUninstall_P1[54])
			zCount = 54;
		ElseIf (OID == ModUninstall_P1[55])
			zCount = 55;
		ElseIf (OID == ModUninstall_P1[56])
			zCount = 56;
		ElseIf (OID == ModUninstall_P1[57])
			zCount = 57;
		ElseIf (OID == ModUninstall_P1[58])
			zCount = 58;
		ElseIf (OID == ModUninstall_P1[59])
			zCount = 59;
		ElseIf (OID == ModUninstall_P1[60])
			zCount = 60;
		ElseIf (OID == ModUninstall_P1[61])
			zCount = 61;
		ElseIf (OID == ModUninstall_P1[62])
			zCount = 62;
		ElseIf (OID == ModUninstall_P1[63])
			zCount = 63;
		ElseIf (OID == ModUninstall_P1[64])
			zCount = 64;
		ElseIf (OID == ModUninstall_P1[65])
			zCount = 65;
		ElseIf (OID == ModUninstall_P1[66])
			zCount = 66;
		ElseIf (OID == ModUninstall_P1[67])
			zCount = 67;
		ElseIf (OID == ModUninstall_P1[68])
			zCount = 68;
		ElseIf (OID == ModUninstall_P1[69])
			zCount = 69;
		ElseIf (OID == ModUninstall_P1[70])
			zCount = 70;
		ElseIf (OID == ModUninstall_P1[71])
			zCount = 71;
		ElseIf (OID == ModUninstall_P1[72])
			zCount = 72;
		ElseIf (OID == ModUninstall_P1[73])
			zCount = 73;
		ElseIf (OID == ModUninstall_P1[74])
			zCount = 74;
		ElseIf (OID == ModUninstall_P1[75])
			zCount = 75;
		ElseIf (OID == ModUninstall_P1[76])
			zCount = 76;
		ElseIf (OID == ModUninstall_P1[77])
			zCount = 77;
		ElseIf (OID == ModUninstall_P1[78])
			zCount = 78;
		ElseIf (OID == ModUninstall_P1[79])
			zCount = 79;
		ElseIf (OID == ModUninstall_P1[80])
			zCount = 80;
		ElseIf (OID == ModUninstall_P1[81])
			zCount = 81;
		ElseIf (OID == ModUninstall_P1[82])
			zCount = 82;
		ElseIf (OID == ModUninstall_P1[83])
			zCount = 83;
		ElseIf (OID == ModUninstall_P1[84])
			zCount = 84;
		ElseIf (OID == ModUninstall_P1[85])
			zCount = 85;
		ElseIf (OID == ModUninstall_P1[86])
			zCount = 86;
		ElseIf (OID == ModUninstall_P1[87])
			zCount = 87;
		ElseIf (OID == ModUninstall_P1[88])
			zCount = 88;
		ElseIf (OID == ModUninstall_P1[89])
			zCount = 89;
		ElseIf (OID == ModUninstall_P1[90])
			zCount = 90;
		ElseIf (OID == ModUninstall_P1[91])
			zCount = 91;
		ElseIf (OID == ModUninstall_P1[92])
			zCount = 92;
		ElseIf (OID == ModUninstall_P1[93])
			zCount = 93;
		ElseIf (OID == ModUninstall_P1[94])
			zCount = 94;
		ElseIf (OID == ModUninstall_P1[95])
			zCount = 95;
		ElseIf (OID == ModUninstall_P1[96])
			zCount = 96;
		ElseIf (OID == ModUninstall_P1[97])
			zCount = 97;
		ElseIf (OID == ModUninstall_P1[98])
			zCount = 98;
		ElseIf (OID == ModUninstall_P1[99])
			zCount = 99;
		ElseIf (OID == ModUninstall_P1[100])
			zCount = 100;
		ElseIf (OID == ModUninstall_P1[101])
			zCount = 101;
		ElseIf (OID == ModUninstall_P1[102])
			zCount = 102;
		ElseIf (OID == ModUninstall_P1[103])
			zCount = 103;
		ElseIf (OID == ModUninstall_P1[104])
			zCount = 104;
		ElseIf (OID == ModUninstall_P1[105])
			zCount = 105;
		ElseIf (OID == ModUninstall_P1[106])
			zCount = 106;
		ElseIf (OID == ModUninstall_P1[107])
			zCount = 107;
		ElseIf (OID == ModUninstall_P1[108])
			zCount = 108;
		ElseIf (OID == ModUninstall_P1[109])
			zCount = 109;
		ElseIf (OID == ModUninstall_P1[110])
			zCount = 110;
		ElseIf (OID == ModUninstall_P1[111])
			zCount = 111;
		ElseIf (OID == ModUninstall_P1[112])
			zCount = 112;
		ElseIf (OID == ModUninstall_P1[113])
			zCount = 113;
		ElseIf (OID == ModUninstall_P1[114])
			zCount = 114;
		ElseIf (OID == ModUninstall_P1[115])
			zCount = 115;
		ElseIf (OID == ModUninstall_P1[116])
			zCount = 116;
		ElseIf (OID == ModUninstall_P1[117])
			zCount = 117;
		ElseIf (OID == ModUninstall_P1[118])
			zCount = 118;
		ElseIf (OID == ModUninstall_P1[119])
			zCount = 119;
		ElseIf (OID == ModUninstall_P1[120])
			zCount = 120;
		ElseIf (OID == ModUninstall_P1[121])
			zCount = 121;
		ElseIf (OID == ModUninstall_P1[122])
			zCount = 122;
		ElseIf (OID == ModUninstall_P1[123])
			zCount = 123;
		ElseIf (OID == ModUninstall_P1[124])
			zCount = 124;
		ElseIf (OID == ModUninstall_P1[125])
			zCount = 125;
		ElseIf (OID == ModUninstall_P1[126])
			zCount = 126;
		ElseIf (OID == ModUninstall_P1[127])
			zCount = 127;
		EndIf
	;midfold
	
	EndIf
	
	;endfold
	
	;Uninstall buttons p2 beginfold
	
	
	If (CurrentPage == "$CANS_MCM_Page_ModListB2")
		SetInfoText("$CANS_Info_Uninstall{"+CANSframe.ModNames2[zCount]+"}");
	
	;Actual work to sort out zCount midfold
	
		If (OID == ModUninstall_P2[0])
			zCount = 0;
		ElseIf (OID == ModUninstall_P2[1])
			zCount = 1;
		ElseIf (OID == ModUninstall_P2[2])
			zCount = 2;
		ElseIf (OID == ModUninstall_P2[3])
			zCount = 3;
		ElseIf (OID == ModUninstall_P2[4])
			zCount = 4;
		ElseIf (OID == ModUninstall_P2[5])
			zCount = 5;
		ElseIf (OID == ModUninstall_P2[6])
			zCount = 6;
		ElseIf (OID == ModUninstall_P2[7])
			zCount = 7;
		ElseIf (OID == ModUninstall_P2[8])
			zCount = 8;
		ElseIf (OID == ModUninstall_P2[9])
			zCount = 9;
		ElseIf (OID == ModUninstall_P2[10])
			zCount = 10;
		ElseIf (OID == ModUninstall_P2[11])
			zCount = 11;
		ElseIf (OID == ModUninstall_P2[12])
			zCount = 12;
		ElseIf (OID == ModUninstall_P2[13])
			zCount = 13;
		ElseIf (OID == ModUninstall_P2[14])
			zCount = 14;
		ElseIf (OID == ModUninstall_P2[15])
			zCount = 15;
		ElseIf (OID == ModUninstall_P2[16])
			zCount = 16;
		ElseIf (OID == ModUninstall_P2[17])
			zCount = 17;
		ElseIf (OID == ModUninstall_P2[18])
			zCount = 18;
		ElseIf (OID == ModUninstall_P2[19])
			zCount = 19;
		ElseIf (OID == ModUninstall_P2[20])
			zCount = 20;
		ElseIf (OID == ModUninstall_P2[21])
			zCount = 21;
		ElseIf (OID == ModUninstall_P2[22])
			zCount = 22;
		ElseIf (OID == ModUninstall_P2[23])
			zCount = 23;
		ElseIf (OID == ModUninstall_P2[24])
			zCount = 24;
		ElseIf (OID == ModUninstall_P2[25])
			zCount = 25;
		ElseIf (OID == ModUninstall_P2[26])
			zCount = 26;
		ElseIf (OID == ModUninstall_P2[27])
			zCount = 27;
		ElseIf (OID == ModUninstall_P2[28])
			zCount = 28;
		ElseIf (OID == ModUninstall_P2[29])
			zCount = 29;
		ElseIf (OID == ModUninstall_P2[30])
			zCount = 30;
		ElseIf (OID == ModUninstall_P2[31])
			zCount = 31;
		ElseIf (OID == ModUninstall_P2[32])
			zCount = 32;
		ElseIf (OID == ModUninstall_P2[33])
			zCount = 33;
		ElseIf (OID == ModUninstall_P2[34])
			zCount = 34;
		ElseIf (OID == ModUninstall_P2[35])
			zCount = 35;
		ElseIf (OID == ModUninstall_P2[36])
			zCount = 36;
		ElseIf (OID == ModUninstall_P2[37])
			zCount = 37;
		ElseIf (OID == ModUninstall_P2[38])
			zCount = 38;
		ElseIf (OID == ModUninstall_P2[39])
			zCount = 39;
		ElseIf (OID == ModUninstall_P2[40])
			zCount = 40;
		ElseIf (OID == ModUninstall_P2[41])
			zCount = 41;
		ElseIf (OID == ModUninstall_P2[42])
			zCount = 42;
		ElseIf (OID == ModUninstall_P2[43])
			zCount = 43;
		ElseIf (OID == ModUninstall_P2[44])
			zCount = 44;
		ElseIf (OID == ModUninstall_P2[45])
			zCount = 45;
		ElseIf (OID == ModUninstall_P2[46])
			zCount = 46;
		ElseIf (OID == ModUninstall_P2[47])
			zCount = 47;
		ElseIf (OID == ModUninstall_P2[48])
			zCount = 48;
		ElseIf (OID == ModUninstall_P2[49])
			zCount = 49;
		ElseIf (OID == ModUninstall_P2[50])
			zCount = 40;
		ElseIf (OID == ModUninstall_P2[51])
			zCount = 51;
		ElseIf (OID == ModUninstall_P2[52])
			zCount = 52;
		ElseIf (OID == ModUninstall_P2[53])
			zCount = 53;
		ElseIf (OID == ModUninstall_P2[54])
			zCount = 54;
		ElseIf (OID == ModUninstall_P2[55])
			zCount = 55;
		ElseIf (OID == ModUninstall_P2[56])
			zCount = 56;
		ElseIf (OID == ModUninstall_P2[57])
			zCount = 57;
		ElseIf (OID == ModUninstall_P2[58])
			zCount = 58;
		ElseIf (OID == ModUninstall_P2[59])
			zCount = 59;
		ElseIf (OID == ModUninstall_P2[60])
			zCount = 60;
		ElseIf (OID == ModUninstall_P2[61])
			zCount = 61;
		ElseIf (OID == ModUninstall_P2[62])
			zCount = 62;
		ElseIf (OID == ModUninstall_P2[63])
			zCount = 63;
		ElseIf (OID == ModUninstall_P2[64])
			zCount = 64;
		ElseIf (OID == ModUninstall_P2[65])
			zCount = 65;
		ElseIf (OID == ModUninstall_P2[66])
			zCount = 66;
		ElseIf (OID == ModUninstall_P2[67])
			zCount = 67;
		ElseIf (OID == ModUninstall_P2[68])
			zCount = 68;
		ElseIf (OID == ModUninstall_P2[69])
			zCount = 69;
		ElseIf (OID == ModUninstall_P2[70])
			zCount = 70;
		ElseIf (OID == ModUninstall_P2[71])
			zCount = 71;
		ElseIf (OID == ModUninstall_P2[72])
			zCount = 72;
		ElseIf (OID == ModUninstall_P2[73])
			zCount = 73;
		ElseIf (OID == ModUninstall_P2[74])
			zCount = 74;
		ElseIf (OID == ModUninstall_P2[75])
			zCount = 75;
		ElseIf (OID == ModUninstall_P2[76])
			zCount = 76;
		ElseIf (OID == ModUninstall_P2[77])
			zCount = 77;
		ElseIf (OID == ModUninstall_P2[78])
			zCount = 78;
		ElseIf (OID == ModUninstall_P2[79])
			zCount = 79;
		ElseIf (OID == ModUninstall_P2[80])
			zCount = 80;
		ElseIf (OID == ModUninstall_P2[81])
			zCount = 81;
		ElseIf (OID == ModUninstall_P2[82])
			zCount = 82;
		ElseIf (OID == ModUninstall_P2[83])
			zCount = 83;
		ElseIf (OID == ModUninstall_P2[84])
			zCount = 84;
		ElseIf (OID == ModUninstall_P2[85])
			zCount = 85;
		ElseIf (OID == ModUninstall_P2[86])
			zCount = 86;
		ElseIf (OID == ModUninstall_P2[87])
			zCount = 87;
		ElseIf (OID == ModUninstall_P2[88])
			zCount = 88;
		ElseIf (OID == ModUninstall_P2[89])
			zCount = 89;
		ElseIf (OID == ModUninstall_P2[90])
			zCount = 90;
		ElseIf (OID == ModUninstall_P2[91])
			zCount = 91;
		ElseIf (OID == ModUninstall_P2[92])
			zCount = 92;
		ElseIf (OID == ModUninstall_P2[93])
			zCount = 93;
		ElseIf (OID == ModUninstall_P2[94])
			zCount = 94;
		ElseIf (OID == ModUninstall_P2[95])
			zCount = 95;
		ElseIf (OID == ModUninstall_P2[96])
			zCount = 96;
		ElseIf (OID == ModUninstall_P2[97])
			zCount = 97;
		ElseIf (OID == ModUninstall_P2[98])
			zCount = 98;
		ElseIf (OID == ModUninstall_P2[99])
			zCount = 99;
		ElseIf (OID == ModUninstall_P2[100])
			zCount = 100;
		ElseIf (OID == ModUninstall_P2[101])
			zCount = 101;
		ElseIf (OID == ModUninstall_P2[102])
			zCount = 102;
		ElseIf (OID == ModUninstall_P2[103])
			zCount = 103;
		ElseIf (OID == ModUninstall_P2[104])
			zCount = 104;
		ElseIf (OID == ModUninstall_P2[105])
			zCount = 105;
		ElseIf (OID == ModUninstall_P2[106])
			zCount = 106;
		ElseIf (OID == ModUninstall_P2[107])
			zCount = 107;
		ElseIf (OID == ModUninstall_P2[108])
			zCount = 108;
		ElseIf (OID == ModUninstall_P2[109])
			zCount = 109;
		ElseIf (OID == ModUninstall_P2[110])
			zCount = 110;
		ElseIf (OID == ModUninstall_P2[111])
			zCount = 111;
		ElseIf (OID == ModUninstall_P2[112])
			zCount = 112;
		ElseIf (OID == ModUninstall_P2[113])
			zCount = 113;
		ElseIf (OID == ModUninstall_P2[114])
			zCount = 114;
		ElseIf (OID == ModUninstall_P2[115])
			zCount = 115;
		ElseIf (OID == ModUninstall_P2[116])
			zCount = 116;
		ElseIf (OID == ModUninstall_P2[117])
			zCount = 117;
		ElseIf (OID == ModUninstall_P2[118])
			zCount = 118;
		ElseIf (OID == ModUninstall_P2[119])
			zCount = 119;
		ElseIf (OID == ModUninstall_P2[120])
			zCount = 120;
		ElseIf (OID == ModUninstall_P2[121])
			zCount = 121;
		ElseIf (OID == ModUninstall_P2[122])
			zCount = 122;
		ElseIf (OID == ModUninstall_P2[123])
			zCount = 123;
		ElseIf (OID == ModUninstall_P2[124])
			zCount = 124;
		ElseIf (OID == ModUninstall_P2[125])
			zCount = 125;
		ElseIf (OID == ModUninstall_P2[126])
			zCount = 126;
		ElseIf (OID == ModUninstall_P2[127])
			zCount = 127;
		EndIf
		
	;midfold
	
	EndIf
	
	;endfold
	
	;Uninstall buttons p3 beginfold
	
	
	If (CurrentPage == "$CANS_MCM_Page_ModListB3")
		SetInfoText("$CANS_Info_Uninstall{"+CANSframe.ModNames3[zCount]+"}");
	
	;Actual work to sort out zCount midfold
	
		If (OID == ModUninstall_P3[0])
			zCount = 0;
		ElseIf (OID == ModUninstall_P3[1])
			zCount = 1;
		ElseIf (OID == ModUninstall_P3[2])
			zCount = 2;
		ElseIf (OID == ModUninstall_P3[3])
			zCount = 3;
		ElseIf (OID == ModUninstall_P3[4])
			zCount = 4;
		ElseIf (OID == ModUninstall_P3[5])
			zCount = 5;
		ElseIf (OID == ModUninstall_P3[6])
			zCount = 6;
		ElseIf (OID == ModUninstall_P3[7])
			zCount = 7;
		ElseIf (OID == ModUninstall_P3[8])
			zCount = 8;
		ElseIf (OID == ModUninstall_P3[9])
			zCount = 9;
		ElseIf (OID == ModUninstall_P3[10])
			zCount = 10;
		ElseIf (OID == ModUninstall_P3[11])
			zCount = 11;
		ElseIf (OID == ModUninstall_P3[12])
			zCount = 12;
		ElseIf (OID == ModUninstall_P3[13])
			zCount = 13;
		ElseIf (OID == ModUninstall_P3[14])
			zCount = 14;
		ElseIf (OID == ModUninstall_P3[15])
			zCount = 15;
		ElseIf (OID == ModUninstall_P3[16])
			zCount = 16;
		ElseIf (OID == ModUninstall_P3[17])
			zCount = 17;
		ElseIf (OID == ModUninstall_P3[18])
			zCount = 18;
		ElseIf (OID == ModUninstall_P3[19])
			zCount = 19;
		ElseIf (OID == ModUninstall_P3[20])
			zCount = 20;
		ElseIf (OID == ModUninstall_P3[21])
			zCount = 21;
		ElseIf (OID == ModUninstall_P3[22])
			zCount = 22;
		ElseIf (OID == ModUninstall_P3[23])
			zCount = 23;
		ElseIf (OID == ModUninstall_P3[24])
			zCount = 24;
		ElseIf (OID == ModUninstall_P3[25])
			zCount = 25;
		ElseIf (OID == ModUninstall_P3[26])
			zCount = 26;
		ElseIf (OID == ModUninstall_P3[27])
			zCount = 27;
		ElseIf (OID == ModUninstall_P3[28])
			zCount = 28;
		ElseIf (OID == ModUninstall_P3[29])
			zCount = 29;
		ElseIf (OID == ModUninstall_P3[30])
			zCount = 30;
		ElseIf (OID == ModUninstall_P3[31])
			zCount = 31;
		ElseIf (OID == ModUninstall_P3[32])
			zCount = 32;
		ElseIf (OID == ModUninstall_P3[33])
			zCount = 33;
		ElseIf (OID == ModUninstall_P3[34])
			zCount = 34;
		ElseIf (OID == ModUninstall_P3[35])
			zCount = 35;
		ElseIf (OID == ModUninstall_P3[36])
			zCount = 36;
		ElseIf (OID == ModUninstall_P3[37])
			zCount = 37;
		ElseIf (OID == ModUninstall_P3[38])
			zCount = 38;
		ElseIf (OID == ModUninstall_P3[39])
			zCount = 39;
		ElseIf (OID == ModUninstall_P3[40])
			zCount = 40;
		ElseIf (OID == ModUninstall_P3[41])
			zCount = 41;
		ElseIf (OID == ModUninstall_P3[42])
			zCount = 42;
		ElseIf (OID == ModUninstall_P3[43])
			zCount = 43;
		ElseIf (OID == ModUninstall_P3[44])
			zCount = 44;
		ElseIf (OID == ModUninstall_P3[45])
			zCount = 45;
		ElseIf (OID == ModUninstall_P3[46])
			zCount = 46;
		ElseIf (OID == ModUninstall_P3[47])
			zCount = 47;
		ElseIf (OID == ModUninstall_P3[48])
			zCount = 48;
		ElseIf (OID == ModUninstall_P3[49])
			zCount = 49;
		ElseIf (OID == ModUninstall_P3[50])
			zCount = 40;
		ElseIf (OID == ModUninstall_P3[51])
			zCount = 51;
		ElseIf (OID == ModUninstall_P3[52])
			zCount = 52;
		ElseIf (OID == ModUninstall_P3[53])
			zCount = 53;
		ElseIf (OID == ModUninstall_P3[54])
			zCount = 54;
		ElseIf (OID == ModUninstall_P3[55])
			zCount = 55;
		ElseIf (OID == ModUninstall_P3[56])
			zCount = 56;
		ElseIf (OID == ModUninstall_P3[57])
			zCount = 57;
		ElseIf (OID == ModUninstall_P3[58])
			zCount = 58;
		ElseIf (OID == ModUninstall_P3[59])
			zCount = 59;
		ElseIf (OID == ModUninstall_P3[60])
			zCount = 60;
		ElseIf (OID == ModUninstall_P3[61])
			zCount = 61;
		ElseIf (OID == ModUninstall_P3[62])
			zCount = 62;
		ElseIf (OID == ModUninstall_P3[63])
			zCount = 63;
		ElseIf (OID == ModUninstall_P3[64])
			zCount = 64;
		ElseIf (OID == ModUninstall_P3[65])
			zCount = 65;
		ElseIf (OID == ModUninstall_P3[66])
			zCount = 66;
		ElseIf (OID == ModUninstall_P3[67])
			zCount = 67;
		ElseIf (OID == ModUninstall_P3[68])
			zCount = 68;
		ElseIf (OID == ModUninstall_P3[69])
			zCount = 69;
		ElseIf (OID == ModUninstall_P3[70])
			zCount = 70;
		ElseIf (OID == ModUninstall_P3[71])
			zCount = 71;
		ElseIf (OID == ModUninstall_P3[72])
			zCount = 72;
		ElseIf (OID == ModUninstall_P3[73])
			zCount = 73;
		ElseIf (OID == ModUninstall_P3[74])
			zCount = 74;
		ElseIf (OID == ModUninstall_P3[75])
			zCount = 75;
		ElseIf (OID == ModUninstall_P3[76])
			zCount = 76;
		ElseIf (OID == ModUninstall_P3[77])
			zCount = 77;
		ElseIf (OID == ModUninstall_P3[78])
			zCount = 78;
		ElseIf (OID == ModUninstall_P3[79])
			zCount = 79;
		ElseIf (OID == ModUninstall_P3[80])
			zCount = 80;
		ElseIf (OID == ModUninstall_P3[81])
			zCount = 81;
		ElseIf (OID == ModUninstall_P3[82])
			zCount = 82;
		ElseIf (OID == ModUninstall_P3[83])
			zCount = 83;
		ElseIf (OID == ModUninstall_P3[84])
			zCount = 84;
		ElseIf (OID == ModUninstall_P3[85])
			zCount = 85;
		ElseIf (OID == ModUninstall_P3[86])
			zCount = 86;
		ElseIf (OID == ModUninstall_P3[87])
			zCount = 87;
		ElseIf (OID == ModUninstall_P3[88])
			zCount = 88;
		ElseIf (OID == ModUninstall_P3[89])
			zCount = 89;
		ElseIf (OID == ModUninstall_P3[90])
			zCount = 90;
		ElseIf (OID == ModUninstall_P3[91])
			zCount = 91;
		ElseIf (OID == ModUninstall_P3[92])
			zCount = 92;
		ElseIf (OID == ModUninstall_P3[93])
			zCount = 93;
		ElseIf (OID == ModUninstall_P3[94])
			zCount = 94;
		ElseIf (OID == ModUninstall_P3[95])
			zCount = 95;
		ElseIf (OID == ModUninstall_P3[96])
			zCount = 96;
		ElseIf (OID == ModUninstall_P3[97])
			zCount = 97;
		ElseIf (OID == ModUninstall_P3[98])
			zCount = 98;
		ElseIf (OID == ModUninstall_P3[99])
			zCount = 99;
		ElseIf (OID == ModUninstall_P3[100])
			zCount = 100;
		ElseIf (OID == ModUninstall_P3[101])
			zCount = 101;
		ElseIf (OID == ModUninstall_P3[102])
			zCount = 102;
		ElseIf (OID == ModUninstall_P3[103])
			zCount = 103;
		ElseIf (OID == ModUninstall_P3[104])
			zCount = 104;
		ElseIf (OID == ModUninstall_P3[105])
			zCount = 105;
		ElseIf (OID == ModUninstall_P3[106])
			zCount = 106;
		ElseIf (OID == ModUninstall_P3[107])
			zCount = 107;
		ElseIf (OID == ModUninstall_P3[108])
			zCount = 108;
		ElseIf (OID == ModUninstall_P3[109])
			zCount = 109;
		ElseIf (OID == ModUninstall_P3[110])
			zCount = 110;
		ElseIf (OID == ModUninstall_P3[111])
			zCount = 111;
		ElseIf (OID == ModUninstall_P3[112])
			zCount = 112;
		ElseIf (OID == ModUninstall_P3[113])
			zCount = 113;
		ElseIf (OID == ModUninstall_P3[114])
			zCount = 114;
		ElseIf (OID == ModUninstall_P3[115])
			zCount = 115;
		ElseIf (OID == ModUninstall_P3[116])
			zCount = 116;
		ElseIf (OID == ModUninstall_P3[117])
			zCount = 117;
		ElseIf (OID == ModUninstall_P3[118])
			zCount = 118;
		ElseIf (OID == ModUninstall_P3[119])
			zCount = 119;
		ElseIf (OID == ModUninstall_P3[120])
			zCount = 120;
		ElseIf (OID == ModUninstall_P3[121])
			zCount = 121;
		ElseIf (OID == ModUninstall_P3[122])
			zCount = 122;
		ElseIf (OID == ModUninstall_P3[123])
			zCount = 123;
		ElseIf (OID == ModUninstall_P3[124])
			zCount = 124;
		ElseIf (OID == ModUninstall_P3[125])
			zCount = 125;
		ElseIf (OID == ModUninstall_P3[126])
			zCount = 126;
		ElseIf (OID == ModUninstall_P3[127])
			zCount = 127;
		EndIf
		
	;midfold
	
	EndIf
	
	;endfold
	
	;Individual Weight p1 beginfold
	
	If (CurrentPage == "$CANS_MCM_Page_ModList") || (CurrentPAge == "$CANS_MCM_Page_ModListB1")
		SetInfoText("$CANS_IndivWeight{"+CANSframe.ModNames1[zCount]+"}");
	
	;zCount midfold
	
		If (OID == IndivWeight_P1[0])
			zCount = 0;
		ElseIf (OID == IndivWeight_P1[1])
			zCount = 1;
		ElseIf (OID == IndivWeight_P1[2])
			zCount = 2;
		ElseIf (OID == IndivWeight_P1[3])
			zCount = 3;
		ElseIf (OID == IndivWeight_P1[4])
			zCount = 4;
		ElseIf (OID == IndivWeight_P1[5])
			zCount = 5;
		ElseIf (OID == IndivWeight_P1[6])
			zCount = 6;
		ElseIf (OID == IndivWeight_P1[7])
			zCount = 7;
		ElseIf (OID == IndivWeight_P1[8])
			zCount = 8;
		ElseIf (OID == IndivWeight_P1[9])
			zCount = 9;
		ElseIf (OID == IndivWeight_P1[10])
			zCount = 10;
		ElseIf (OID == IndivWeight_P1[11])
			zCount = 11;
		ElseIf (OID == IndivWeight_P1[12])
			zCount = 12;
		ElseIf (OID == IndivWeight_P1[13])
			zCount = 13;
		ElseIf (OID == IndivWeight_P1[14])
			zCount = 14;
		ElseIf (OID == IndivWeight_P1[15])
			zCount = 15;
		ElseIf (OID == IndivWeight_P1[16])
			zCount = 16;
		ElseIf (OID == IndivWeight_P1[17])
			zCount = 17;
		ElseIf (OID == IndivWeight_P1[18])
			zCount = 18;
		ElseIf (OID == IndivWeight_P1[19])
			zCount = 19;
		ElseIf (OID == IndivWeight_P1[20])
			zCount = 20;
		ElseIf (OID == IndivWeight_P1[21])
			zCount = 21;
		ElseIf (OID == IndivWeight_P1[22])
			zCount = 22;
		ElseIf (OID == IndivWeight_P1[23])
			zCount = 23;
		ElseIf (OID == IndivWeight_P1[24])
			zCount = 24;
		ElseIf (OID == IndivWeight_P1[25])
			zCount = 25;
		ElseIf (OID == IndivWeight_P1[26])
			zCount = 26;
		ElseIf (OID == IndivWeight_P1[27])
			zCount = 27;
		ElseIf (OID == IndivWeight_P1[28])
			zCount = 28;
		ElseIf (OID == IndivWeight_P1[29])
			zCount = 29;
		ElseIf (OID == IndivWeight_P1[30])
			zCount = 30;
		ElseIf (OID == IndivWeight_P1[31])
			zCount = 31;
		ElseIf (OID == IndivWeight_P1[32])
			zCount = 32;
		ElseIf (OID == IndivWeight_P1[33])
			zCount = 33;
		ElseIf (OID == IndivWeight_P1[34])
			zCount = 34;
		ElseIf (OID == IndivWeight_P1[35])
			zCount = 35;
		ElseIf (OID == IndivWeight_P1[36])
			zCount = 36;
		ElseIf (OID == IndivWeight_P1[37])
			zCount = 37;
		ElseIf (OID == IndivWeight_P1[38])
			zCount = 38;
		ElseIf (OID == IndivWeight_P1[39])
			zCount = 39;
		ElseIf (OID == IndivWeight_P1[40])
			zCount = 40;
		ElseIf (OID == IndivWeight_P1[41])
			zCount = 41;
		ElseIf (OID == IndivWeight_P1[42])
			zCount = 42;
		ElseIf (OID == IndivWeight_P1[43])
			zCount = 43;
		ElseIf (OID == IndivWeight_P1[44])
			zCount = 44;
		ElseIf (OID == IndivWeight_P1[45])
			zCount = 45;
		ElseIf (OID == IndivWeight_P1[46])
			zCount = 46;
		ElseIf (OID == IndivWeight_P1[47])
			zCount = 47;
		ElseIf (OID == IndivWeight_P1[48])
			zCount = 48;
		ElseIf (OID == IndivWeight_P1[49])
			zCount = 49;
		ElseIf (OID == IndivWeight_P1[50])
			zCount = 40;
		ElseIf (OID == IndivWeight_P1[51])
			zCount = 51;
		ElseIf (OID == IndivWeight_P1[52])
			zCount = 52;
		ElseIf (OID == IndivWeight_P1[53])
			zCount = 53;
		ElseIf (OID == IndivWeight_P1[54])
			zCount = 54;
		ElseIf (OID == IndivWeight_P1[55])
			zCount = 55;
		ElseIf (OID == IndivWeight_P1[56])
			zCount = 56;
		ElseIf (OID == IndivWeight_P1[57])
			zCount = 57;
		ElseIf (OID == IndivWeight_P1[58])
			zCount = 58;
		ElseIf (OID == IndivWeight_P1[59])
			zCount = 59;
		ElseIf (OID == IndivWeight_P1[60])
			zCount = 60;
		ElseIf (OID == IndivWeight_P1[61])
			zCount = 61;
		ElseIf (OID == IndivWeight_P1[62])
			zCount = 62;
		ElseIf (OID == IndivWeight_P1[63])
			zCount = 63;
		ElseIf (OID == IndivWeight_P1[64])
			zCount = 64;
		ElseIf (OID == IndivWeight_P1[65])
			zCount = 65;
		ElseIf (OID == IndivWeight_P1[66])
			zCount = 66;
		ElseIf (OID == IndivWeight_P1[67])
			zCount = 67;
		ElseIf (OID == IndivWeight_P1[68])
			zCount = 68;
		ElseIf (OID == IndivWeight_P1[69])
			zCount = 69;
		ElseIf (OID == IndivWeight_P1[70])
			zCount = 70;
		ElseIf (OID == IndivWeight_P1[71])
			zCount = 71;
		ElseIf (OID == IndivWeight_P1[72])
			zCount = 72;
		ElseIf (OID == IndivWeight_P1[73])
			zCount = 73;
		ElseIf (OID == IndivWeight_P1[74])
			zCount = 74;
		ElseIf (OID == IndivWeight_P1[75])
			zCount = 75;
		ElseIf (OID == IndivWeight_P1[76])
			zCount = 76;
		ElseIf (OID == IndivWeight_P1[77])
			zCount = 77;
		ElseIf (OID == IndivWeight_P1[78])
			zCount = 78;
		ElseIf (OID == IndivWeight_P1[79])
			zCount = 79;
		ElseIf (OID == IndivWeight_P1[80])
			zCount = 80;
		ElseIf (OID == IndivWeight_P1[81])
			zCount = 81;
		ElseIf (OID == IndivWeight_P1[82])
			zCount = 82;
		ElseIf (OID == IndivWeight_P1[83])
			zCount = 83;
		ElseIf (OID == IndivWeight_P1[84])
			zCount = 84;
		ElseIf (OID == IndivWeight_P1[85])
			zCount = 85;
		ElseIf (OID == IndivWeight_P1[86])
			zCount = 86;
		ElseIf (OID == IndivWeight_P1[87])
			zCount = 87;
		ElseIf (OID == IndivWeight_P1[88])
			zCount = 88;
		ElseIf (OID == IndivWeight_P1[89])
			zCount = 89;
		ElseIf (OID == IndivWeight_P1[90])
			zCount = 90;
		ElseIf (OID == IndivWeight_P1[91])
			zCount = 91;
		ElseIf (OID == IndivWeight_P1[92])
			zCount = 92;
		ElseIf (OID == IndivWeight_P1[93])
			zCount = 93;
		ElseIf (OID == IndivWeight_P1[94])
			zCount = 94;
		ElseIf (OID == IndivWeight_P1[95])
			zCount = 95;
		ElseIf (OID == IndivWeight_P1[96])
			zCount = 96;
		ElseIf (OID == IndivWeight_P1[97])
			zCount = 97;
		ElseIf (OID == IndivWeight_P1[98])
			zCount = 98;
		ElseIf (OID == IndivWeight_P1[99])
			zCount = 99;
		ElseIf (OID == IndivWeight_P1[100])
			zCount = 100;
		ElseIf (OID == IndivWeight_P1[101])
			zCount = 101;
		ElseIf (OID == IndivWeight_P1[102])
			zCount = 102;
		ElseIf (OID == IndivWeight_P1[103])
			zCount = 103;
		ElseIf (OID == IndivWeight_P1[104])
			zCount = 104;
		ElseIf (OID == IndivWeight_P1[105])
			zCount = 105;
		ElseIf (OID == IndivWeight_P1[106])
			zCount = 106;
		ElseIf (OID == IndivWeight_P1[107])
			zCount = 107;
		ElseIf (OID == IndivWeight_P1[108])
			zCount = 108;
		ElseIf (OID == IndivWeight_P1[109])
			zCount = 109;
		ElseIf (OID == IndivWeight_P1[110])
			zCount = 110;
		ElseIf (OID == IndivWeight_P1[111])
			zCount = 111;
		ElseIf (OID == IndivWeight_P1[112])
			zCount = 112;
		ElseIf (OID == IndivWeight_P1[113])
			zCount = 113;
		ElseIf (OID == IndivWeight_P1[114])
			zCount = 114;
		ElseIf (OID == IndivWeight_P1[115])
			zCount = 115;
		ElseIf (OID == IndivWeight_P1[116])
			zCount = 116;
		ElseIf (OID == IndivWeight_P1[117])
			zCount = 117;
		ElseIf (OID == IndivWeight_P1[118])
			zCount = 118;
		ElseIf (OID == IndivWeight_P1[119])
			zCount = 119;
		ElseIf (OID == IndivWeight_P1[120])
			zCount = 120;
		ElseIf (OID == IndivWeight_P1[121])
			zCount = 121;
		ElseIf (OID == IndivWeight_P1[122])
			zCount = 122;
		ElseIf (OID == IndivWeight_P1[123])
			zCount = 123;
		ElseIf (OID == IndivWeight_P1[124])
			zCount = 124;
		ElseIf (OID == IndivWeight_P1[125])
			zCount = 125;
		ElseIf (OID == IndivWeight_P1[126])
			zCount = 126;
		ElseIf (OID == IndivWeight_P1[127])
			zCount = 127;
		EndIf
		
	;midfold
	
	
	EndIf
	
	;endfold
	
	;Individual Weight p2 beginfold
	
	
	
	
	If (CurrentPage == "$CANS_MCM_Page_ModListB2")
		SetInfoText("$CANS_IndivWeight{"+CANSframe.ModNames2[zCount]+"}");
		
		;zCount midfold
	
		If (OID == IndivWeight_P2[0])
			zCount = 0;
		ElseIf (OID == IndivWeight_P2[1])
			zCount = 1;
		ElseIf (OID == IndivWeight_P2[2])
			zCount = 2;
		ElseIf (OID == IndivWeight_P2[3])
			zCount = 3;
		ElseIf (OID == IndivWeight_P2[4])
			zCount = 4;
		ElseIf (OID == IndivWeight_P2[5])
			zCount = 5;
		ElseIf (OID == IndivWeight_P2[6])
			zCount = 6;
		ElseIf (OID == IndivWeight_P2[7])
			zCount = 7;
		ElseIf (OID == IndivWeight_P2[8])
			zCount = 8;
		ElseIf (OID == IndivWeight_P2[9])
			zCount = 9;
		ElseIf (OID == IndivWeight_P2[10])
			zCount = 10;
		ElseIf (OID == IndivWeight_P2[11])
			zCount = 11;
		ElseIf (OID == IndivWeight_P2[12])
			zCount = 12;
		ElseIf (OID == IndivWeight_P2[13])
			zCount = 13;
		ElseIf (OID == IndivWeight_P2[14])
			zCount = 14;
		ElseIf (OID == IndivWeight_P2[15])
			zCount = 15;
		ElseIf (OID == IndivWeight_P2[16])
			zCount = 16;
		ElseIf (OID == IndivWeight_P2[17])
			zCount = 17;
		ElseIf (OID == IndivWeight_P2[18])
			zCount = 18;
		ElseIf (OID == IndivWeight_P2[19])
			zCount = 19;
		ElseIf (OID == IndivWeight_P2[20])
			zCount = 20;
		ElseIf (OID == IndivWeight_P2[21])
			zCount = 21;
		ElseIf (OID == IndivWeight_P2[22])
			zCount = 22;
		ElseIf (OID == IndivWeight_P2[23])
			zCount = 23;
		ElseIf (OID == IndivWeight_P2[24])
			zCount = 24;
		ElseIf (OID == IndivWeight_P2[25])
			zCount = 25;
		ElseIf (OID == IndivWeight_P2[26])
			zCount = 26;
		ElseIf (OID == IndivWeight_P2[27])
			zCount = 27;
		ElseIf (OID == IndivWeight_P2[28])
			zCount = 28;
		ElseIf (OID == IndivWeight_P2[29])
			zCount = 29;
		ElseIf (OID == IndivWeight_P2[30])
			zCount = 30;
		ElseIf (OID == IndivWeight_P2[31])
			zCount = 31;
		ElseIf (OID == IndivWeight_P2[32])
			zCount = 32;
		ElseIf (OID == IndivWeight_P2[33])
			zCount = 33;
		ElseIf (OID == IndivWeight_P2[34])
			zCount = 34;
		ElseIf (OID == IndivWeight_P2[35])
			zCount = 35;
		ElseIf (OID == IndivWeight_P2[36])
			zCount = 36;
		ElseIf (OID == IndivWeight_P2[37])
			zCount = 37;
		ElseIf (OID == IndivWeight_P2[38])
			zCount = 38;
		ElseIf (OID == IndivWeight_P2[39])
			zCount = 39;
		ElseIf (OID == IndivWeight_P2[40])
			zCount = 40;
		ElseIf (OID == IndivWeight_P2[41])
			zCount = 41;
		ElseIf (OID == IndivWeight_P2[42])
			zCount = 42;
		ElseIf (OID == IndivWeight_P2[43])
			zCount = 43;
		ElseIf (OID == IndivWeight_P2[44])
			zCount = 44;
		ElseIf (OID == IndivWeight_P2[45])
			zCount = 45;
		ElseIf (OID == IndivWeight_P2[46])
			zCount = 46;
		ElseIf (OID == IndivWeight_P2[47])
			zCount = 47;
		ElseIf (OID == IndivWeight_P2[48])
			zCount = 48;
		ElseIf (OID == IndivWeight_P2[49])
			zCount = 49;
		ElseIf (OID == IndivWeight_P2[50])
			zCount = 40;
		ElseIf (OID == IndivWeight_P2[51])
			zCount = 51;
		ElseIf (OID == IndivWeight_P2[52])
			zCount = 52;
		ElseIf (OID == IndivWeight_P2[53])
			zCount = 53;
		ElseIf (OID == IndivWeight_P2[54])
			zCount = 54;
		ElseIf (OID == IndivWeight_P2[55])
			zCount = 55;
		ElseIf (OID == IndivWeight_P2[56])
			zCount = 56;
		ElseIf (OID == IndivWeight_P2[57])
			zCount = 57;
		ElseIf (OID == IndivWeight_P2[58])
			zCount = 58;
		ElseIf (OID == IndivWeight_P2[59])
			zCount = 59;
		ElseIf (OID == IndivWeight_P2[60])
			zCount = 60;
		ElseIf (OID == IndivWeight_P2[61])
			zCount = 61;
		ElseIf (OID == IndivWeight_P2[62])
			zCount = 62;
		ElseIf (OID == IndivWeight_P2[63])
			zCount = 63;
		ElseIf (OID == IndivWeight_P2[64])
			zCount = 64;
		ElseIf (OID == IndivWeight_P2[65])
			zCount = 65;
		ElseIf (OID == IndivWeight_P2[66])
			zCount = 66;
		ElseIf (OID == IndivWeight_P2[67])
			zCount = 67;
		ElseIf (OID == IndivWeight_P2[68])
			zCount = 68;
		ElseIf (OID == IndivWeight_P2[69])
			zCount = 69;
		ElseIf (OID == IndivWeight_P2[70])
			zCount = 70;
		ElseIf (OID == IndivWeight_P2[71])
			zCount = 71;
		ElseIf (OID == IndivWeight_P2[72])
			zCount = 72;
		ElseIf (OID == IndivWeight_P2[73])
			zCount = 73;
		ElseIf (OID == IndivWeight_P2[74])
			zCount = 74;
		ElseIf (OID == IndivWeight_P2[75])
			zCount = 75;
		ElseIf (OID == IndivWeight_P2[76])
			zCount = 76;
		ElseIf (OID == IndivWeight_P2[77])
			zCount = 77;
		ElseIf (OID == IndivWeight_P2[78])
			zCount = 78;
		ElseIf (OID == IndivWeight_P2[79])
			zCount = 79;
		ElseIf (OID == IndivWeight_P2[80])
			zCount = 80;
		ElseIf (OID == IndivWeight_P2[81])
			zCount = 81;
		ElseIf (OID == IndivWeight_P2[82])
			zCount = 82;
		ElseIf (OID == IndivWeight_P2[83])
			zCount = 83;
		ElseIf (OID == IndivWeight_P2[84])
			zCount = 84;
		ElseIf (OID == IndivWeight_P2[85])
			zCount = 85;
		ElseIf (OID == IndivWeight_P2[86])
			zCount = 86;
		ElseIf (OID == IndivWeight_P2[87])
			zCount = 87;
		ElseIf (OID == IndivWeight_P2[88])
			zCount = 88;
		ElseIf (OID == IndivWeight_P2[89])
			zCount = 89;
		ElseIf (OID == IndivWeight_P2[90])
			zCount = 90;
		ElseIf (OID == IndivWeight_P2[91])
			zCount = 91;
		ElseIf (OID == IndivWeight_P2[92])
			zCount = 92;
		ElseIf (OID == IndivWeight_P2[93])
			zCount = 93;
		ElseIf (OID == IndivWeight_P2[94])
			zCount = 94;
		ElseIf (OID == IndivWeight_P2[95])
			zCount = 95;
		ElseIf (OID == IndivWeight_P2[96])
			zCount = 96;
		ElseIf (OID == IndivWeight_P2[97])
			zCount = 97;
		ElseIf (OID == IndivWeight_P2[98])
			zCount = 98;
		ElseIf (OID == IndivWeight_P2[99])
			zCount = 99;
		ElseIf (OID == IndivWeight_P2[100])
			zCount = 100;
		ElseIf (OID == IndivWeight_P2[101])
			zCount = 101;
		ElseIf (OID == IndivWeight_P2[102])
			zCount = 102;
		ElseIf (OID == IndivWeight_P2[103])
			zCount = 103;
		ElseIf (OID == IndivWeight_P2[104])
			zCount = 104;
		ElseIf (OID == IndivWeight_P2[105])
			zCount = 105;
		ElseIf (OID == IndivWeight_P2[106])
			zCount = 106;
		ElseIf (OID == IndivWeight_P2[107])
			zCount = 107;
		ElseIf (OID == IndivWeight_P2[108])
			zCount = 108;
		ElseIf (OID == IndivWeight_P2[109])
			zCount = 109;
		ElseIf (OID == IndivWeight_P2[110])
			zCount = 110;
		ElseIf (OID == IndivWeight_P2[111])
			zCount = 111;
		ElseIf (OID == IndivWeight_P2[112])
			zCount = 112;
		ElseIf (OID == IndivWeight_P2[113])
			zCount = 113;
		ElseIf (OID == IndivWeight_P2[114])
			zCount = 114;
		ElseIf (OID == IndivWeight_P2[115])
			zCount = 115;
		ElseIf (OID == IndivWeight_P2[116])
			zCount = 116;
		ElseIf (OID == IndivWeight_P2[117])
			zCount = 117;
		ElseIf (OID == IndivWeight_P2[118])
			zCount = 118;
		ElseIf (OID == IndivWeight_P2[119])
			zCount = 119;
		ElseIf (OID == IndivWeight_P2[120])
			zCount = 120;
		ElseIf (OID == IndivWeight_P2[121])
			zCount = 121;
		ElseIf (OID == IndivWeight_P2[122])
			zCount = 122;
		ElseIf (OID == IndivWeight_P2[123])
			zCount = 123;
		ElseIf (OID == IndivWeight_P2[124])
			zCount = 124;
		ElseIf (OID == IndivWeight_P2[125])
			zCount = 125;
		ElseIf (OID == IndivWeight_P2[126])
			zCount = 126;
		ElseIf (OID == IndivWeight_P2[127])
			zCount = 127;
		EndIf
		;midfold
		
	EndIf
	;endfold
	
	;Individual Weight p3 beginfold
	
	If (CurrentPage == "$CANS_MCM_Page_ModListB3")
		SetInfoText("$CANS_IndivWeight{"+CANSframe.ModNames3[zCount]+"}");
	
	;zCount midfold
	
		If (OID == IndivWeight_P3[0])
			zCount = 0;
		ElseIf (OID == IndivWeight_P3[1])
			zCount = 1;
		ElseIf (OID == IndivWeight_P3[2])
			zCount = 2;
		ElseIf (OID == IndivWeight_P3[3])
			zCount = 3;
		ElseIf (OID == IndivWeight_P3[4])
			zCount = 4;
		ElseIf (OID == IndivWeight_P3[5])
			zCount = 5;
		ElseIf (OID == IndivWeight_P3[6])
			zCount = 6;
		ElseIf (OID == IndivWeight_P3[7])
			zCount = 7;
		ElseIf (OID == IndivWeight_P3[8])
			zCount = 8;
		ElseIf (OID == IndivWeight_P3[9])
			zCount = 9;
		ElseIf (OID == IndivWeight_P3[10])
			zCount = 10;
		ElseIf (OID == IndivWeight_P3[11])
			zCount = 11;
		ElseIf (OID == IndivWeight_P3[12])
			zCount = 12;
		ElseIf (OID == IndivWeight_P3[13])
			zCount = 13;
		ElseIf (OID == IndivWeight_P3[14])
			zCount = 14;
		ElseIf (OID == IndivWeight_P3[15])
			zCount = 15;
		ElseIf (OID == IndivWeight_P3[16])
			zCount = 16;
		ElseIf (OID == IndivWeight_P3[17])
			zCount = 17;
		ElseIf (OID == IndivWeight_P3[18])
			zCount = 18;
		ElseIf (OID == IndivWeight_P3[19])
			zCount = 19;
		ElseIf (OID == IndivWeight_P3[20])
			zCount = 20;
		ElseIf (OID == IndivWeight_P3[21])
			zCount = 21;
		ElseIf (OID == IndivWeight_P3[22])
			zCount = 22;
		ElseIf (OID == IndivWeight_P3[23])
			zCount = 23;
		ElseIf (OID == IndivWeight_P3[24])
			zCount = 24;
		ElseIf (OID == IndivWeight_P3[25])
			zCount = 25;
		ElseIf (OID == IndivWeight_P3[26])
			zCount = 26;
		ElseIf (OID == IndivWeight_P3[27])
			zCount = 27;
		ElseIf (OID == IndivWeight_P3[28])
			zCount = 28;
		ElseIf (OID == IndivWeight_P3[29])
			zCount = 29;
		ElseIf (OID == IndivWeight_P3[30])
			zCount = 30;
		ElseIf (OID == IndivWeight_P3[31])
			zCount = 31;
		ElseIf (OID == IndivWeight_P3[32])
			zCount = 32;
		ElseIf (OID == IndivWeight_P3[33])
			zCount = 33;
		ElseIf (OID == IndivWeight_P3[34])
			zCount = 34;
		ElseIf (OID == IndivWeight_P3[35])
			zCount = 35;
		ElseIf (OID == IndivWeight_P3[36])
			zCount = 36;
		ElseIf (OID == IndivWeight_P3[37])
			zCount = 37;
		ElseIf (OID == IndivWeight_P3[38])
			zCount = 38;
		ElseIf (OID == IndivWeight_P3[39])
			zCount = 39;
		ElseIf (OID == IndivWeight_P3[40])
			zCount = 40;
		ElseIf (OID == IndivWeight_P3[41])
			zCount = 41;
		ElseIf (OID == IndivWeight_P3[42])
			zCount = 42;
		ElseIf (OID == IndivWeight_P3[43])
			zCount = 43;
		ElseIf (OID == IndivWeight_P3[44])
			zCount = 44;
		ElseIf (OID == IndivWeight_P3[45])
			zCount = 45;
		ElseIf (OID == IndivWeight_P3[46])
			zCount = 46;
		ElseIf (OID == IndivWeight_P3[47])
			zCount = 47;
		ElseIf (OID == IndivWeight_P3[48])
			zCount = 48;
		ElseIf (OID == IndivWeight_P3[49])
			zCount = 49;
		ElseIf (OID == IndivWeight_P3[50])
			zCount = 40;
		ElseIf (OID == IndivWeight_P3[51])
			zCount = 51;
		ElseIf (OID == IndivWeight_P3[52])
			zCount = 52;
		ElseIf (OID == IndivWeight_P3[53])
			zCount = 53;
		ElseIf (OID == IndivWeight_P3[54])
			zCount = 54;
		ElseIf (OID == IndivWeight_P3[55])
			zCount = 55;
		ElseIf (OID == IndivWeight_P3[56])
			zCount = 56;
		ElseIf (OID == IndivWeight_P3[57])
			zCount = 57;
		ElseIf (OID == IndivWeight_P3[58])
			zCount = 58;
		ElseIf (OID == IndivWeight_P3[59])
			zCount = 59;
		ElseIf (OID == IndivWeight_P3[60])
			zCount = 60;
		ElseIf (OID == IndivWeight_P3[61])
			zCount = 61;
		ElseIf (OID == IndivWeight_P3[62])
			zCount = 62;
		ElseIf (OID == IndivWeight_P3[63])
			zCount = 63;
		ElseIf (OID == IndivWeight_P3[64])
			zCount = 64;
		ElseIf (OID == IndivWeight_P3[65])
			zCount = 65;
		ElseIf (OID == IndivWeight_P3[66])
			zCount = 66;
		ElseIf (OID == IndivWeight_P3[67])
			zCount = 67;
		ElseIf (OID == IndivWeight_P3[68])
			zCount = 68;
		ElseIf (OID == IndivWeight_P3[69])
			zCount = 69;
		ElseIf (OID == IndivWeight_P3[70])
			zCount = 70;
		ElseIf (OID == IndivWeight_P3[71])
			zCount = 71;
		ElseIf (OID == IndivWeight_P3[72])
			zCount = 72;
		ElseIf (OID == IndivWeight_P3[73])
			zCount = 73;
		ElseIf (OID == IndivWeight_P3[74])
			zCount = 74;
		ElseIf (OID == IndivWeight_P3[75])
			zCount = 75;
		ElseIf (OID == IndivWeight_P3[76])
			zCount = 76;
		ElseIf (OID == IndivWeight_P3[77])
			zCount = 77;
		ElseIf (OID == IndivWeight_P3[78])
			zCount = 78;
		ElseIf (OID == IndivWeight_P3[79])
			zCount = 79;
		ElseIf (OID == IndivWeight_P3[80])
			zCount = 80;
		ElseIf (OID == IndivWeight_P3[81])
			zCount = 81;
		ElseIf (OID == IndivWeight_P3[82])
			zCount = 82;
		ElseIf (OID == IndivWeight_P3[83])
			zCount = 83;
		ElseIf (OID == IndivWeight_P3[84])
			zCount = 84;
		ElseIf (OID == IndivWeight_P3[85])
			zCount = 85;
		ElseIf (OID == IndivWeight_P3[86])
			zCount = 86;
		ElseIf (OID == IndivWeight_P3[87])
			zCount = 87;
		ElseIf (OID == IndivWeight_P3[88])
			zCount = 88;
		ElseIf (OID == IndivWeight_P3[89])
			zCount = 89;
		ElseIf (OID == IndivWeight_P3[90])
			zCount = 90;
		ElseIf (OID == IndivWeight_P3[91])
			zCount = 91;
		ElseIf (OID == IndivWeight_P3[92])
			zCount = 92;
		ElseIf (OID == IndivWeight_P3[93])
			zCount = 93;
		ElseIf (OID == IndivWeight_P3[94])
			zCount = 94;
		ElseIf (OID == IndivWeight_P3[95])
			zCount = 95;
		ElseIf (OID == IndivWeight_P3[96])
			zCount = 96;
		ElseIf (OID == IndivWeight_P3[97])
			zCount = 97;
		ElseIf (OID == IndivWeight_P3[98])
			zCount = 98;
		ElseIf (OID == IndivWeight_P3[99])
			zCount = 99;
		ElseIf (OID == IndivWeight_P3[100])
			zCount = 100;
		ElseIf (OID == IndivWeight_P3[101])
			zCount = 101;
		ElseIf (OID == IndivWeight_P3[102])
			zCount = 102;
		ElseIf (OID == IndivWeight_P3[103])
			zCount = 103;
		ElseIf (OID == IndivWeight_P3[104])
			zCount = 104;
		ElseIf (OID == IndivWeight_P3[105])
			zCount = 105;
		ElseIf (OID == IndivWeight_P3[106])
			zCount = 106;
		ElseIf (OID == IndivWeight_P3[107])
			zCount = 107;
		ElseIf (OID == IndivWeight_P3[108])
			zCount = 108;
		ElseIf (OID == IndivWeight_P3[109])
			zCount = 109;
		ElseIf (OID == IndivWeight_P3[110])
			zCount = 110;
		ElseIf (OID == IndivWeight_P3[111])
			zCount = 111;
		ElseIf (OID == IndivWeight_P3[112])
			zCount = 112;
		ElseIf (OID == IndivWeight_P3[113])
			zCount = 113;
		ElseIf (OID == IndivWeight_P3[114])
			zCount = 114;
		ElseIf (OID == IndivWeight_P3[115])
			zCount = 115;
		ElseIf (OID == IndivWeight_P3[116])
			zCount = 116;
		ElseIf (OID == IndivWeight_P3[117])
			zCount = 117;
		ElseIf (OID == IndivWeight_P3[118])
			zCount = 118;
		ElseIf (OID == IndivWeight_P3[119])
			zCount = 119;
		ElseIf (OID == IndivWeight_P3[120])
			zCount = 120;
		ElseIf (OID == IndivWeight_P3[121])
			zCount = 121;
		ElseIf (OID == IndivWeight_P3[122])
			zCount = 122;
		ElseIf (OID == IndivWeight_P3[123])
			zCount = 123;
		ElseIf (OID == IndivWeight_P3[124])
			zCount = 124;
		ElseIf (OID == IndivWeight_P3[125])
			zCount = 125;
		ElseIf (OID == IndivWeight_P3[126])
			zCount = 126;
		ElseIf (OID == IndivWeight_P3[127])
			zCount = 127;
		EndIf
	
	;midfold
	
	EndIf
	;endfold
	
	;Debug Page beginfold
	
	If (OID == EndOverrides0)
		SetInfoText("$CANS_Info_EndOverrides0")
	ElseIf (OID == EndOverrides1)
		SetInfoText("$CANS_Info_EndOverrides1")
	ElseIf (OID == EndOverrides2)
		SetInfoText("$CANS_Info_EndOverrides2")
	ElseIf (OID == EndOverrides3)
		SetInfoText("$CANS_Info_EndOverrides3")
	ElseIf (OID == TraceLogToggle)
		SetInfoText("$CANS_Info_Tracelog")
	EndIf 
	
	;endfold
	
EndEvent

Event OnOptionSelect(int OID)
	
	;general settings beginfold
	If (OID == Uninstall_ID)
		SetTextOptionValue(Uninstall_ID, "Uninstalling")
		SetInfoText("$CANS_Uninstalling")
		If CANSframe.CANS_Tracelogging == True
			Debug.Trace("CANS: Uninstalling...")
		EndIf
		CANSframe.EndCANS()
		Utility.Wait(0.1)
		;Ends everything about CANS rather abruptly. Forces them to close the window to allow all variables to return to default and/or uninitialized states.
	ElseIf (OID == TorpedoToggle)
		If (GetIntValue(None, "CANS.TorpedoFix", 0) == 0)
			SetToggleOptionValue(TorpedoToggle, True)
			SetIntValue(None, "CANS.TorpedoFix", 1)
		Else
			SetToggleOptionValue(TorpedoToggle, False)
			SetIntValue(None, "CANS.TorpedoFix", 0)
		EndIf
	ElseIf (OID == ToggleMaxBelly)
		Bool a = CANSframe.MaxBellyEnabled
		a = !a 
		CANSframe.MaxBellyEnabled = a;
		SetToggleOptionValue(ToggleMaxBelly, a)
	ElseIF (OID == ToggleMaxBreast)
		Bool a = CANSframe.MaxBreastEnabled
		a = !a 
		CANSframe.MaxBreastEnabled = a;
		SetToggleOptionValue(ToggleMaxBreast, a)
	ElseIf (OID == ToggleMaxButt)
		Bool a = CANSframe.MaxButtEnabled
		a = !a 
		CANSframe.MaxButtEnabled = a;
		SetToggleOptionValue(ToggleMaxButt, a)
	ElseIf (OID == OverrideEnable)
		Bool a = CANSframe.CANS_Override
		a = !a 
		CANSframe.CANS_Override = a 
		SetToggleOptionValue(OverrideEnable, a)
	EndIf
	;endfold
	
	;Uninstall Buttons beginfold
	If (CurrentPage == "$CANS_MCM_Page_ModList") || (CurrentPage == "$CANS_MCM_Page_ModListB1")
		CANSframe.UninstallAMod(CANSframe.ModNames1[zCount]);
	ElseIf (CurrentPage == "$CANS_MCM_Page_ModListB2")
		CANSframe.UninstallAMod(CANSframe.ModNames2[zCount]);
	ElseIf (CurrentPAge == "$CANS_MCM_Page_ModListB3")
		CANSframe.UninstallAMod(CANSframe.ModNames3[zCount]);
	EndIf
	;EndFold
	
	;Debug Options beginfold
	
	If (OID == TraceLogToggle)
		Bool a = CANSframe.CANS_Tracelogging;
		a = !a;
		CANSframe.CANS_TraceLogging = a;
		SetToggleOptionValue(TraceLogToggle, a);
	ElseIf (OID == EndOverrides0)
		CANSframe.EndAllOverride();
	ElseIf (OID == EndOVerrides1)
		CANSframe.EndAllBellyOverride()
	ElseIf (OID == EndOverrides2)
		CANSframe.EndAllBreastOverride()
	ElseIf (OID == EndOverrides3)
		CANSframe.EndAllButtOverride()
	EndIf
	;endfold
	
EndEvent

Event OnOptionSliderOpen(int OID)
	;SetSliderDialogStartValue
	;SetSliderDialogDefaultValue
	;SetSliderDialogRange
	;SetSliderDialogInterval
	
	;general settings beginfold
	If (OID == DelayID)
		SetSliderDialogStartValue(CANSframe.UpdateDelay)
		SetSliderDialogDefaultValue(0.5)
		SetSliderDialogRange(0.1, 4.0)
		SetSliderDialogInterval(0.1)
	ElseIf (OID == TorpedoFix)
		SetSliderDialogStartValue(GetFloatValue(None, "CANS.TorpedoFixValue"))
		SetSliderDialogDefaultValue(0.1)
		SetSliderDialogRange(0.0, 1.0)
		SetSliderDialogInterval(0.1)
	ElseIf (OID == MaxBellyID)
		SetSliderDialogStartValue(CANSframe.MaxBellySize)
		SetSliderDialogDefaultValue(6.0)
		SetSliderDialogRange(1.0, 13.0)
		SetSliderDialogInterval(0.1)
	ElseIf (OID == MaxBreastID)
		SetSliderDialogStartValue(CANSframe.MaxBreastSize)
		SetSliderDialogDefaultValue(6.0)
		SetSliderDialogRange(1.0, 13.0)
		SetSliderDialogInterval(0.1)
	ElseIf (OID == MaxButtID)
		SetSliderDialogStartValue(CANSframe.MaxButtSize)
		SetSliderDialogDefaultValue(6.0)
		SetSliderDialogRange(1.0, 13.0)
		SetSliderDialogInterval(0.1)
	ElseIf (OID == DecreasingFactor)
		SetSliderDialogStartValue(CANSframe.DecreasingAdditiveFactor)
		SetSliderDialogDefaultValue(2.0)
		SetSliderDialogRange(1.0, 5.0)
		SetSliderDialogInterval(0.1)
	EndIf
	;endfold
	
	;cat weights beginfold
	If (OID == PregnancyWeight1_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.PregnancyBellyWeight)
	ElseIf (OID == PregnancyWeight2_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.PregnancyBreastWeight)
	ElseIf (OID == PregnancyWeight3_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.PregnancyButtWeight)
	ElseIF (OID == CumflationWeight1_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.CumflationBellyWeight)
	ElseIf (OID == CumflationWeight2_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.CumflationBreastWeight)
	ElseIf (OID == CumflationWeight3_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.CumflationButtWeight)
	ElseIf (OID == MiscWeight1_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.MiscCatBellyWeight)
	ElseIf (OID == MiscWeight2_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.MiscCatBreastWeight)
	ElseIf (OID == MiscWeight3_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.MiscCatButtWeight)
	ElseIf (OID == MilkingWeight1_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.MilkingBellyWeight)
	ElseIf (OID == MilkingWeight2_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.MilkingBreastWeight)
	ElseIf (OID == MilkingWeight3_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.MilkingButtWeight)
	ElseIf (OID == InflationWeight1_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.InflationBellyWeight)
	ElseIf (OID == InflationWeight2_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.InflationBreastWeight)
	ElseIf (OID == InflationWeight3_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.InflationButtWeight)
	ElseIf (OID == UncatWeight1_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.UnCatBellyWeight)
	ElseIf (OID == UncatWeight2_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.UnCatBreastWeight)
	ElseIf (OID == UncatWeight3_ID)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(CANSframe.UnCatButtWeight)
	EndIf
	;endfold
	
	;Individual Weights beginfold
	If (CurrentPage == "$CANS_MCM_Page_Weights") || (CurrentPage == "$CANS_MCM_Page_WeightsB1")
		string ModName = CANSframe.ModNames1[zCount];
		float weight = GetFloatValue(None, "CANS."+ModName+".Weight", 1.0)
		SetSliderDialogStartValue(weight)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogInterval(0.1)
	ElseIf (CurrentPage == "$CANS_MCM_Page_WeightsB2")
		string ModName = CANSframe.ModNames2[zCount];
		float weight = GetFloatValue(None, "CANS."+ModName+".Weight", 1.0)
		SetSliderDialogStartValue(weight)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogInterval(0.1)
	ElseIf (CurrentPage == "$CANS_MCM_Page_WeightsB3")
		string ModName = CANSframe.ModNames3[zCount];
		float weight = GetFloatValue(None, "CANS."+ModName+".Weight", 1.0)
		SetSliderDialogStartValue(weight)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogInterval(0.1)
	EndIf 
	;endfold
	
EndEvent

Event OnOptionSliderAccept(int OID, float value) ;;FIXME: After testing, ensure can actually change property values
	;set value(s)
	;SetSliderOptionValue
	
	;general settings, beginfold
	If (OID == DelayID)
		CANSframe.UpdateDelay = value;
		SetSliderOptionValue(DelayID, value);
	ElseIf (OID == TorpedoFix)
		SetFloatValue(None, "CANS.TorpedoFixValue", value)
		SetSliderOptionValue(TorpedoFix, value);
	ElseIf (OID == MaxBellyID)
		CANSframe.MaxBellySize = value;
		SetSliderOptionValue(MaxBellyID, value);
	ElseIf (OID == MaxBreastID)
		CANSframe.MaxBreastSize = value;
		SetSliderOptionValue(MaxBreastID, value);
	ElseIf (OID == MaxButtID)
		CANSframe.MaxButtSize = value;
		SetSliderOptionValue(MaxButtID, value);
	ElseIf (OID == DecreasingFactor)
		CANSframe.DecreasingAdditiveFactor = value
		SetSliderOptionValue(DecreasingFactor, value)
	EndIf 
	;endfold
	
	;Cat Weights beginfold
	If (OID == PregnancyWeight1_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.PregnancyBellyWeight = value
	ElseIf (OID == PregnancyWeight2_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.PregnancyBreastWeight = value
	ElseIf (OID == PregnancyWeight3_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.PregnancyButtWeight = value
	ElseIF (OID == CumflationWeight1_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.CumflationBellyWeight = value
	ElseIf (OID == CumflationWeight2_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.CumflationBreastWeight = value
	ElseIf (OID == CumflationWeight3_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.CumflationButtWeight = value
	ElseIf (OID == MiscWeight1_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.MiscCatBellyWeight = value
	ElseIf (OID == MiscWeight2_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.MiscCatBreastWeight = value
	ElseIf (OID == MiscWeight3_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.MiscCatButtWeight = value
	ElseIf (OID == MilkingWeight1_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.MilkingBellyWeight = value
	ElseIf (OID == MilkingWeight2_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.MilkingBreastWeight = value
	ElseIf (OID == MilkingWeight3_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.MilkingButtWeight = value
	ElseIf (OID == InflationWeight1_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.InflationBellyWeight = value
	ElseIf (OID == InflationWeight2_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.InflationBreastWeight = value
	ElseIf (OID == InflationWeight3_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.InflationButtWeight = value
	ElseIf (OID == UncatWeight1_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.UnCatBellyWeight = value
	ElseIf (OID == UncatWeight2_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.UnCatBreastWeight = value
	ElseIf (OID == UncatWeight3_ID)
		SetSliderOptionValue(OID, value)
		CANSframe.UnCatButtWeight = value
	EndIf
	;endfold
	
	;Individual Weights beginfold
	If (CurrentPage == "$CANS_MCM_Page_Weights") || (CurrentPage == "$CANS_MCM_Page_WeightsB1")
		;Recatch zCount to find mod name, set weight value, update option value
		string ModName = CANSframe.ModNames1[zCount];
		SetFloatValue(None, "CANS."+ModName+".Weight", value);
		SetSliderOptionValue(IndivWeight_P1[zCount], value);
	ElseIf (CurrentPAge == "$CANS_MCM_Page_WeightsB2")
		string ModName = CANSframe.ModNames2[zCount];
		SetFloatValue(None, "CANS."+ModName+".Weight", value);
		SetSliderOptionValue(IndivWeight_P2[zCount], value);
	ElseIf (CurrentPage == "$CANS_MCM_Page_WeightsB3")
		string ModName = CANSframe.ModNames3[zCount]
		SetFloatValue(None, "CANS."+ModName+".Weight", value)
		SetSliderOptionValue(IndivWeight_P3[zCount], value)
	EndIf
	;endfold
	
EndEvent

Event OnOptionMenuOpen(int OID)
	;SetMenuDialogStartIndex
	;SetMenuDialogDefaultIndex;
	;SetMenuDialogOptions;
	
	;general settings beginfold
	If (OID == Option_BellyMode)
		SetMenuDialogOptions(ModeType);
		SetMenuDialogStartIndex(0);
		SetMenuDialogDefaultIndex(0);
	ElseIf (OID == Option_BreastMode)
		SetMenuDialogOptions(ModeType);
		SetMenuDialogStartIndex(0);
		SetMenuDialogDefaultIndex(0);
	ElseIf (OID == Option_ButtMode)
		SetMenuDialogOptions(ModeType);
		SetMenuDialogStartIndex(0);
		SetMenuDialogDefaultIndex(0);
	ElseIf (OID == Option_Weight)
		SetMenuDialogOptions(WeightType);
		SetMenuDialogStartIndex(0);
		SetMenuDialogDefaultIndex(0);
	EndIf
	;endfold
	
EndEvent

Event OnOptionMenuAccept(int OID, int Idx) ;;FIXME: Possibly rewrite after testing, make sure can actually change property values. If necesary can replace each and every property with storageutil, but global variables will not be used.
	;SetValue
	;SetMenuOptionValue
	;queue update???
	
	;general settings beginfold
	If (OID == Option_BellyMode)
		CANSframe.CANS_Belly_Mode = Idx;
		SetMenuOptionValue(Option_BellyMode, ModeType[Idx]);
	ElseIf (OID == Option_BreastMode)
		CANSframe.CANS_Breast_Mode = Idx;
		SetMenuOptionValue(Option_BreastMode, ModeType[Idx]);
	ElseIf (OID == Option_ButtMode)
		CANSframe.CANS_Butt_Mode = Idx;
		SetMenuOptionValue(Option_ButtMode, ModeType[Idx]);
	ElseIf (OID == Option_Weight)
		CANSframe.CANS_WeightingMode = Idx;
		SetMenuOptionValue(Option_Weight, WeightType[Idx]);
	EndIf
	;endfold
	
EndEvent
