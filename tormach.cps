/*
  Copyright (C) 2012-2020 by Autodesk, Inc.
  All rights reserved.

  Tormach PathPilot post processor configuration.

  $Revision: 2593 $
  $Date: 2020-12-17 23:24:18 +0000 (Thu, 17 Dec 2020) $
  $Author: david $
  
  Modified by David Loomes to support integrated Fusion 360 probing in PathPilot
  24/02/19		Initial probing release
  13/06/19		Added post support for plane angle probing
  27/10/19		Added support for Tormach extended WCS - 500 WCS max, using G54.1 Pxxx syntax
  11/12/19		Added support for electronic tool setter (G37)
  21/01/20		Incorporated corrections from Autodesk for smartcool processing.
  29/06/20		Added support for I/O boards
  25/07/20		Added partial circle probing operations
  06/08/20		Added support for inspection reports
  28/09/20		Added option to turn on output during probing ops
  29/09/20		Added multiple options to control retract operations
  09/10/20		Added comments to delimit pre-amble, post-amble and tool table
  02/01/21		Added Manual NC 'Action' options to control inspection probing
*/

description = "Tormach PathPilot with probing and ETS";
vendor = "Tormach";
vendorUrl = "http://www.tormach.com";
legal = "Copyright (C) 2012-2018 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 40783;

longDescription = "Tormach PathPilot post for 3-axis and 4-axis milling with SmartCool support and integrated probing functions. 500 WCS support, ETS support";

extension = "nc";
setCodePage("ascii");

capabilities = CAPABILITY_MILLING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion



// user-defined properties
properties = {
	writeMachine: true, // write machine
	writeTools: true, // writes the tools
	writeVersion: false, // include version info
	/*
	useG30: true, // disable to avoid G30 output
	useG28: false, // move table to "load" position at end of program
	*/
	retractOnProgramBegin: "g30z",
	retractOnProgramEnd: "g30z",
	retractOnTCBegin: "g30z",
	retractOnTCEnd: "none",
	retractOnWCSChange: "g30z",
	retractOnWorkPlaneChange: "g30z",
	retractOnManualNCStop: "none",
//	substituteRapidAfterRetract: false,
	
	useM6: true, // disable to avoid M6 output
	showSequenceNumbers: false, // show sequence numbers
	sequenceNumberStart: 10, // first sequence number
	sequenceNumberIncrement: 10, // increment for sequence numbers
	sequenceNumberOperation: true, // output sequence numbers at operation start only
	optionalStopTool: true, // optional stop before tool change
	optionalStopOperation: false, // optional stop between all operations
	separateWordsWithSpace: true, // specifies that the words should be separated with a white space
	useRadius: false, // specifies that arcs should be output using the radius (R word) instead of the I, J, and K words.
	dwellInSeconds: true, // specifies the unit for dwelling: true:seconds and false:milliseconds.
	forceWorkOffset: false, // forces the work offset code at tool changes
	rotaryTableAxis: "none", // none, X, Y, Z, -X, -Y, -Z
	smartCoolEquipped: false, // machine has smart coolant attachment
	multiCoolEquipped: false, // machine has multi-coolant module
	smartCoolToolSweepPercentage: 100, // tool length percentage to sweep coolant
	multiCoolAirBlastSeconds: 4, // air blast time when equipped with Multi-Coolant module
	disableCoolant: false, // disables all coolant codes
	reversingHead: false, // uses self-reversing tapping head
	reversingHeadFeed: 2.0, // percentage of tapping feed to retract the tool with reversing tapping head
	maxTool: 256, // maximum tool/offset number
	
	// properties controlling integrated probing
	probeFastSpeed: 20.0,
	probeSlowSpeed: 1.0,
	probeSlowDistance: 0.04,

	// properties to control tool setter functions
	etsTolerance: 0.005,	// for ETS test operations, what difference between measured and tool table length is allowed
	etsDiameterLimit: 0.5, // max diameter of tools that can be used with the ETS
	etsBeforeStart: "none",	// default is no checking before program start
	etsBeforeUse: "none",	// default to no ets check before use of a tool
	etsAfterUse: "none",	// default to no ets check after tool has been used
	etsAfterOperation: "none",	// default to no ets check after each machining operation
	
	//properties to allow tapping on a PCNC440
	expandTapping: false,
	tapSpeedFactor: 1.0,
	spindleReverseChannel: "0",
	
	// properties to use usb i/o module
	spindleRunningChannel: "0",
	toolChangeInProgressChannel: "0",
	floodCoolingOnChannel: "0",
	mistCoolingOnChannel: "0",
	etsInUseChannel: "0",
	etsReadyInput: "0",
	progRunningChannel: "0",
	probeInUseChannel: "0"
};

// user-defined property definitions
propertyDefinitions = {
	writeMachine: {title:"Write machine", description:"Output the machine settings in the header of the code.", group:0, type:"boolean"},
	writeTools: {title:"Write tool list", description:"Output a tool list in the header of the code.", group:0, type:"boolean"},
	writeVersion: {title:"Write version", description:"Write the version number in the header of the code.", group:0, type:"boolean"},

	useM6: {title:"Use M6", description:"Disable to avoid outputting M6.", group:1, type:"boolean"},
	showSequenceNumbers: {title:"Use sequence numbers", description:"Use sequence numbers for each block of outputted code.", group:1, type:"boolean"},
	sequenceNumberStart: {title:"Start sequence number", description:"The number at which to start the sequence numbers.", group:1, type:"integer"},
	sequenceNumberIncrement: {title:"Sequence number increment", description:"The amount by which the sequence number is incremented by in each block.", group:1, type:"integer"},
	sequenceNumberOperation: {title:"Sequence number at operation only", description:"Use sequence numbers at start of operation only.", group:1, type:"boolean"},
	optionalStopTool: {title:"Optional stop between tools", description:"Outputs optional stop code prior to a tool change.", group:1, type:"boolean"},
	optionalStopOperation: {title:"Optional stop between operations", description:"Outputs optional stop code prior between all operations.", group:1, type:"boolean"},
	separateWordsWithSpace: {title:"Separate words with space", description:"Adds spaces between words if 'yes' is selected.", group:1, type:"boolean"},
	useRadius: {title:"Radius arcs", description:"If yes is selected, arcs are outputted using radius values rather than IJK.", group:1, type:"boolean"},
	dwellInSeconds: {title:"Dwell in seconds", description:"Specifies the unit for dwelling, set to 'Yes' for seconds and 'No' for milliseconds.", group:1, type:"boolean"},
	forceWorkOffset: {title:"Force work offset", description:"Forces the work offset code at tool changes.", group:1, type:"boolean"},
	maxTool: {title:"Maximum tool number", description:"Enter the maximum tool number allowed by the control.", group:1, type:"number"},
	rotaryTableAxis: {
		title: "Rotary table axis",
		description: "Select rotary table axis. Check the table direction on the machine and use the (Reversed) selection if the table is moving in the opposite direction.",
		type: "enum",
		group:1,
		values:[
		{title:"No rotary", id:"none"},
		{title:"X", id:"x"},
		{title:"Y", id:"y"},
		{title:"Z", id:"z"},
		{title:"X (Reversed)", id:"-x"},
		{title:"Y (Reversed)", id:"-y"},
		{title:"Z (Reversed)", id:"-z"}
		]
	},

	retractOnProgramBegin: {title:"Retract before Program  start", description:"Retract opertion before start of program", type: "enum", group:2,
	values:[
		{title:"None", id:"none"}, 
		{title:"G30 - z only", id:"g30z"}, 
		{title:"G30 - z, then xy", id:"g30zxy"},
		{title:"G28 - z only", id:"g28z"}, 
		{title:"G28 - z, then xy", id:"g28zxy"},
	]},
	retractOnProgramEnd: {title:"Retract after program end", description:"Retract operation after end of program", type: "enum", group:2,
	values:[
		{title:"None", id:"none"}, 
		{title:"G30 - z only", id:"g30z"}, 
		{title:"G30 - z, then xy", id:"g30zxy"},
		{title:"G28 - z only", id:"g28z"}, 
		{title:"G28 - z, then xy", id:"g28zxy"},
	]},
	retractOnTCBegin: {title:"Retract before tool change", description:"Retract operation before each tool change", type: "enum", group:2,
	values:[
		{title:"None", id:"none"}, 
		{title:"G30 - z only", id:"g30z"}, 
		{title:"G30 - z, then xy", id:"g30zxy"},
		{title:"G28 - z only", id:"g28z"}, 
		{title:"G28 - z, then xy", id:"g28zxy"},
	]},
	retractOnTCEnd: {title:"Retract after tool change", description:"Retract operation after each tool change", type: "enum", group:2,
	values:[
		{title:"None", id:"none"}, 
		{title:"G30 - z only", id:"g30z"}, 
		{title:"G30 - z, then xy", id:"g30zxy"},
		{title:"G28 - z only", id:"g28z"}, 
		{title:"G28 - z, then xy", id:"g28zxy"},
	]},
	retractOnWCSChange: {title:"Retract on WCS change", description:"Retract operation when moving from one WCS to another", type: "enum", group:2,
	values:[
		{title:"None", id:"none"}, 
		{title:"G30 - z only", id:"g30z"}, 
		{title:"G30 - z, then xy", id:"g30zxy"},
		{title:"G28 - z only", id:"g28z"}, 
		{title:"G28 - z, then xy", id:"g28zxy"},
	]},
	retractOnWorkPlaneChange: {title:"Retract on work plane change", description:"Retract operation when changing work plane (A axis move)", type: "enum", group:2,
	values:[
		{title:"None", id:"none"}, 
		{title:"G30 - z only", id:"g30z"}, 
		{title:"G30 - z, then xy", id:"g30zxy"},
		{title:"G28 - z only", id:"g28z"}, 
		{title:"G28 - z, then xy", id:"g28zxy"},
	]},
	retractOnManualNCStop: {title:"Retract on ManualNC Stop", description:"Retract operation when changing work plane (A axis move)", type: "enum", group:2,
	values:[
		{title:"None", id:"none"}, 
		{title:"G30 - z only", id:"g30z"}, 
		{title:"G30 - z, then xy", id:"g30zxy"},
		{title:"G28 - z only", id:"g28z"}, 
		{title:"G28 - z, then xy", id:"g28zxy"},
	]},
//	substituteRapidAfterRetract: {title: "Rapid after retract",
//			description:"Replace linear moves following retracts with rapid moves",
//			type:"boolean", group:2
//		},


	// probing settings
	probeFastSpeed: {title: "Fast probing speed (inch/min)", description: "Fast probing speed (inch/min)", type:"number", group:3},
	probeSlowSpeed: {title: "Slow probing speed (inch/min)", description: "Slow probing speed (inch/min)", type:"number", group:3},
	probeSlowDistance: {title: "Slow probe distance (inch)", description: "Slow probe distance (inch)", type:"number", group:3},

	// properties to control tool setter functions
	etsTolerance: {title: "Tolerance for ETS checks (inch)", description: "Tolerance allowed for tool lengths for ETS checks", type:"number", group:4},
	etsDiameterLimit: {title: "ETS diameter limit (inch)", descriptopn: "Tools larger than this will not be checked by the tool setter", type: "number", group:4},
	
	etsBeforeStart: 
	{
		title: "ETS op before start",
		description: "What toolsetter function should be performed before the start of the program",
		type: "enum",
		values:
			[
			{title: "None", id:"none"},
			{title: "Check", id:"check"},
			{title: "Set", id:"set"},
			],
			group:4
	},
	
	etsBeforeUse:
	{
		title: "ETS op before a tool is used",
		description: "What toolsetter function should be performed after a tool is loaded",
		type: "enum",
		values:
			[
			{title: "None", id:"none"},
			{title: "Check", id:"check"},
			{title: "Set", id:"set"},
			],
			group:4
	},
	
	etsAfterUse:
	{
		title: "ETS op after a tool is used",
		description: "What toolsetter function should be performed when a tool is returned to the ATC",
		type: "enum",
		values:
			[
			{title: "None", id:"none"},
			{title: "Check", id:"check"},
			{title: "Set", id:"set"},
			],
			group:4
	},
	
	etsAfterOperation:
	{
		title: "ETS op after each machining operation",
		description: "What toolsetter function should be performed after erach machining operation",
		type: "enum",
		values:
			[
			{title: "None", id:"none"},
			{title: "Check", id:"check"},
			{title: "Set", id:"set"},
			],
			group:4
	},
	

	expandTapping: {title:"Expand tapping", description:"Expand tapping for machines without canned cycle tapping", group:5, type:"boolean"},
	tapSpeedFactor: {title:"Tap speed factor", description:"Spindle speed correction factor for tapping tools.  Only for 440 where spindle speed cannot be adjusted.  Leave at 1.0 otherwise", group:5, type:"number"},
	spindleReverseChannel: 
	{
		title: "Spindle reversing",
		description: "Choose M4 for standard spindle reversing, one of the others for reverse controlled by USB I/O module",
		type: "enum",
		values:
			[
			{title: "M4", id:"0"},
			{title: "M3 M64 P0", id:"1"},
			{title: "M3 M64 P1", id:"2"},
			{title: "M3 M64 P2", id:"3"},
			{title: "M3 M64 P3", id:"4"},
			{title: "M3 M64 P4", id:"5"},
			{title: "M3 M64 P5", id:"6"},
			{title: "M3 M64 P6", id:"7"},
			{title: "M3 M64 P7", id:"8"},
			{title: "M3 M64 P8", id:"9"},
			{title: "M3 M64 P9", id:"10"},
			{title: "M3 M64 P10", id:"11"},
			{title: "M3 M64 P11", id:"12"},
			{title: "M3 M64 P12", id:"13"},
			{title: "M3 M64 P13", id:"14"},
			{title: "M3 M64 P14", id:"15"},
			{title: "M3 M64 P15", id:"16"},
			],
			group:5
	},

	// properties to use usb i/o module
	spindleRunningChannel:
	{
		title: "I/O Spindle running",
		description: "Choose USB output channel to indicate spindle running",
		type: "enum",
		values:
			[
			{title: "none", id:"0"},

			{title: "Board 1, output 1", id:"1"},
			{title: "Board 1, output 2", id:"2"},
			{title: "Board 1, output 3", id:"3"},
			{title: "Board 1, output 4", id:"4"},

			{title: "Board 2, output 1", id:"5"},
			{title: "Board 2, output 2", id:"6"},
			{title: "Board 2, output 3", id:"7"},
			{title: "Board 2, output 4", id:"8"},

			{title: "Board 3, output 1", id:"9"},
			{title: "Board 3, output 2", id:"10"},
			{title: "Board 3, output 3", id:"11"},
			{title: "Board 3, output 4", id:"12"},

			{title: "Board 4, output 1", id:"13"},
			{title: "Board 4, output 2", id:"14"},
			{title: "Board 4, output 3", id:"15"},
			{title: "Board 4, output 4", id:"16"},
			],
			group:6
	},

	toolChangeInProgressChannel:
	{
		title: "I/O Tool change in progress",
		description: "Choose USB output channel to indicate tool change in progress",
		type: "enum",
		values:
			[
			{title: "none", id:"0"},

			{title: "Board 1, output 1", id:"1"},
			{title: "Board 1, output 2", id:"2"},
			{title: "Board 1, output 3", id:"3"},
			{title: "Board 1, output 4", id:"4"},

			{title: "Board 2, output 1", id:"5"},
			{title: "Board 2, output 2", id:"6"},
			{title: "Board 2, output 3", id:"7"},
			{title: "Board 2, output 4", id:"8"},

			{title: "Board 3, output 1", id:"9"},
			{title: "Board 3, output 2", id:"10"},
			{title: "Board 3, output 3", id:"11"},
			{title: "Board 3, output 4", id:"12"},

			{title: "Board 4, output 1", id:"13"},
			{title: "Board 4, output 2", id:"14"},
			{title: "Board 4, output 3", id:"15"},
			{title: "Board 4, output 4", id:"16"},
			],
			group:6
	},

	floodCoolingOnChannel:
	{
		title: "I/O Flood cooling",
		description: "Choose USB output channel to indicate flood cooling is on",
		type: "enum",
		values:
			[
			{title: "none", id:"0"},

			{title: "Board 1, output 1", id:"1"},
			{title: "Board 1, output 2", id:"2"},
			{title: "Board 1, output 3", id:"3"},
			{title: "Board 1, output 4", id:"4"},

			{title: "Board 2, output 1", id:"5"},
			{title: "Board 2, output 2", id:"6"},
			{title: "Board 2, output 3", id:"7"},
			{title: "Board 2, output 4", id:"8"},

			{title: "Board 3, output 1", id:"9"},
			{title: "Board 3, output 2", id:"10"},
			{title: "Board 3, output 3", id:"11"},
			{title: "Board 3, output 4", id:"12"},

			{title: "Board 4, output 1", id:"13"},
			{title: "Board 4, output 2", id:"14"},
			{title: "Board 4, output 3", id:"15"},
			{title: "Board 4, output 4", id:"16"},
			],
			group:6
	},

	mistCoolingOnChannel:
	{
		title: "I/O Mist cooling",
		description: "Choose USB output channel to indicate mist cooling is on",
		type: "enum",
		values:
			[
			{title: "none", id:"0"},

			{title: "Board 1, output 1", id:"1"},
			{title: "Board 1, output 2", id:"2"},
			{title: "Board 1, output 3", id:"3"},
			{title: "Board 1, output 4", id:"4"},

			{title: "Board 2, output 1", id:"5"},
			{title: "Board 2, output 2", id:"6"},
			{title: "Board 2, output 3", id:"7"},
			{title: "Board 2, output 4", id:"8"},

			{title: "Board 3, output 1", id:"9"},
			{title: "Board 3, output 2", id:"10"},
			{title: "Board 3, output 3", id:"11"},
			{title: "Board 3, output 4", id:"12"},

			{title: "Board 4, output 1", id:"13"},
			{title: "Board 4, output 2", id:"14"},
			{title: "Board 4, output 3", id:"15"},
			{title: "Board 4, output 4", id:"16"},
			],
			group:6
	},

	etsInUseChannel:
	{
		title: "I/O ETS in use",
		description: "Choose USB output channel to indicate ETS is in use",
		type: "enum",
		values:
			[
			{title: "none", id:"0"},

			{title: "Board 1, output 1", id:"1"},
			{title: "Board 1, output 2", id:"2"},
			{title: "Board 1, output 3", id:"3"},
			{title: "Board 1, output 4", id:"4"},

			{title: "Board 2, output 1", id:"5"},
			{title: "Board 2, output 2", id:"6"},
			{title: "Board 2, output 3", id:"7"},
			{title: "Board 2, output 4", id:"8"},

			{title: "Board 3, output 1", id:"9"},
			{title: "Board 3, output 2", id:"10"},
			{title: "Board 3, output 3", id:"11"},
			{title: "Board 3, output 4", id:"12"},

			{title: "Board 4, output 1", id:"13"},
			{title: "Board 4, output 2", id:"14"},
			{title: "Board 4, output 3", id:"15"},
			{title: "Board 4, output 4", id:"16"},
			],
			group:6
	},

	etsReadyInput:
	{
		title: "I/O ETS ready for use",
		description: "Choose USB input channel to indicate ETS is ready for use",
		type: "enum",
		values:
			[
			{title: "none", id:"0"},

			{title: "Board 1, input 1", id:"1"},
			{title: "Board 1, input 2", id:"2"},
			{title: "Board 1, input 3", id:"3"},
			{title: "Board 1, input 4", id:"4"},

			{title: "Board 2, input 1", id:"5"},
			{title: "Board 2, input 2", id:"6"},
			{title: "Board 2, input 3", id:"7"},
			{title: "Board 2, input 4", id:"8"},

			{title: "Board 3, input 1", id:"9"},
			{title: "Board 3, input 2", id:"10"},
			{title: "Board 3, input 3", id:"11"},
			{title: "Board 3, input 4", id:"12"},

			{title: "Board 4, input 1", id:"13"},
			{title: "Board 4, input 2", id:"14"},
			{title: "Board 4, input 3", id:"15"},
			{title: "Board 4, input 4", id:"16"},
			],
			group:6
	},
	progRunningChannel:
	{
		title: "I/O Program running",
		description: "Choose USB output channel to indicate a g-code program is running",
		type: "enum",
		values:
			[
			{title: "none", id:"0"},

			{title: "Board 1, output 1", id:"1"},
			{title: "Board 1, output 2", id:"2"},
			{title: "Board 1, output 3", id:"3"},
			{title: "Board 1, output 4", id:"4"},

			{title: "Board 2, output 1", id:"5"},
			{title: "Board 2, output 2", id:"6"},
			{title: "Board 2, output 3", id:"7"},
			{title: "Board 2, output 4", id:"8"},

			{title: "Board 3, output 1", id:"9"},
			{title: "Board 3, output 2", id:"10"},
			{title: "Board 3, output 3", id:"11"},
			{title: "Board 3, output 4", id:"12"},

			{title: "Board 4, output 1", id:"13"},
			{title: "Board 4, output 2", id:"14"},
			{title: "Board 4, output 3", id:"15"},
			{title: "Board 4, output 4", id:"16"},
			],
			group:6
	},

	probeInUseChannel:
	{
		title: "I/O Probe in use",
		description: "Choose USB output channel to indicate Probe is in use",
		type: "enum",
		values:
			[
			{title: "none", id:"0"},

			{title: "Board 1, output 1", id:"1"},
			{title: "Board 1, output 2", id:"2"},
			{title: "Board 1, output 3", id:"3"},
			{title: "Board 1, output 4", id:"4"},

			{title: "Board 2, output 1", id:"5"},
			{title: "Board 2, output 2", id:"6"},
			{title: "Board 2, output 3", id:"7"},
			{title: "Board 2, output 4", id:"8"},

			{title: "Board 3, output 1", id:"9"},
			{title: "Board 3, output 2", id:"10"},
			{title: "Board 3, output 3", id:"11"},
			{title: "Board 3, output 4", id:"12"},

			{title: "Board 4, output 1", id:"13"},
			{title: "Board 4, output 2", id:"14"},
			{title: "Board 4, output 3", id:"15"},
			{title: "Board 4, output 4", id:"16"},
			],
			group:6
	},

	smartCoolEquipped: {title:"SmartCool equipped", description:"Specifies if the machine has the SmartCool attachment.", group:7, type:"boolean"},
	multiCoolEquipped: {title:"Multi-Coolant equipped", description:"Specifies if the machine has the Multi-Coolant module.", group:7, type:"boolean"},
	smartCoolToolSweepPercentage: {title:"SmartCool sweep percentage", description:"Sets the tool length percentage to sweep coolant.", group:7,type:"integer"},
	multiCoolAirBlastSeconds: {title:"Multi-Coolant air blast in seconds", description:"Sets the Multi-Coolant air blast time in seconds.", group:7,type:"integer"},
	disableCoolant: {title:"Disable coolant", description:"Disable all coolant codes.", group:7,type:"boolean"},
	reversingHead: {title:"Use self-reversing tapping head", description:"Expanded cycles are output with a self-reversing tapping head.", group:8, type:"boolean"},
	reversingHeadFeed: {title:"Self-reversing head feed ratio", description:"The percentage of the tapping feedrate for retracting the tool.", group:8, type:"number"},

};



var permittedCommentChars = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,=_-*#<>";

var nFormat = createFormat({prefix:"N", decimals:0});
var gFormat = createFormat({prefix:"G", decimals:1});
var mFormat = createFormat({prefix:"M", decimals:0});
var hFormat = createFormat({prefix:"H", decimals:0});
var dFormat = createFormat({prefix:"D", decimals:0});
var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var inchFormat = createFormat({decimals:4, forceDecimal:true});
var mmFormat = createFormat({decimals:3, forceDecimal:true});
var rFormat = xyzFormat; // radius
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var feedFormat = createFormat({decimals:(unit == MM ? 0 : 1), forceDecimal:true});
var toolFormat = createFormat({decimals:0});
var rpmFormat = createFormat({decimals:0});
var coolantOptionFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-99999.999
var milliFormat = createFormat({decimals:0}); // milliseconds // range 1-9999
var taperFormat = createFormat({decimals:1, scale:DEG});
var qFormat = createFormat({prefix:"Q", decimals:0});
var pFormat = createFormat({prefix:"P", decimals:0});
var probeAngleFormat = createFormat({decimals:3, forceDecimal:true});

var xOutput = createVariable({prefix:"X"}, xyzFormat);
var yOutput = createVariable({prefix:"Y"}, xyzFormat);
var zOutput = createVariable({onchange:function () {retracted = false;}, prefix:"Z"}, xyzFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, abcFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var dOutput = createVariable({}, dFormat);
var coolantOutput = createVariable({}, mFormat);
var spindleOutput = createVariable({}, mFormat);

// circular output
var iOutput = createReferenceVariable({prefix:"I", force:true}, xyzFormat);
var jOutput = createReferenceVariable({prefix:"J", force:true}, xyzFormat);
var kOutput = createReferenceVariable({prefix:"K", force:true}, xyzFormat);

var gMotionModal = createModal({force:true}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G93-94
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({force:false}, gFormat); // modal group 9 // G81, ...
var gRetractModal = createModal({force:true}, gFormat); // modal group 10 // G98-99

// formatting and output objects to support probing
var probeMCode = 200;
var gVarBase = 2000;
var pProbeFormat = createFormat({decimals:0});
var pProbeOutput = createVariable({prefix:"P", force:true}, pProbeFormat);
var probe100Format = createFormat({decimals:3, zeropad:true, width:3, forceDecimal:true});
var gvarFormat = createFormat({decimals:0});
var gvarOutput = createVariable({prefix:"#", force:true}, gvarFormat);

var WARNING_WORK_OFFSET = 0;
var MAX_WORK_OFFSET = 500;

// collected state
var sequenceNumber;
var currentWorkOffset;
var currentCoolantMode = COOLANT_OFF;
var coolantZHeight = 9999.0;
var masterAxis;
var movementType;
var retracted = false; // specifies that the tool has been retracted to the safe plane

// variables to control the component and feature nos. for inspection routines.
var probeOutputWorkOffset = 1;
var inspectionHeaderWritten = false;
var inspectionRunning=false;
var inspectPartno=1;
var inspectFeatureno=1;

function formatSequenceNumber() {
  if (sequenceNumber > 99999) {
    sequenceNumber = properties.sequenceNumberStart;
  }
  var seqno = nFormat.format(sequenceNumber);
  sequenceNumber += properties.sequenceNumberIncrement;
  return seqno;
}

/**
  Writes the specified block.
*/
function writeBlock() {
  if (!formatWords(arguments)) {
    return;
  }
  if (properties.showSequenceNumbers) {
    writeWords2(formatSequenceNumber(), arguments);
    sequenceNumber += properties.sequenceNumberIncrement;
  } else {
    writeWords(arguments);
  }
}

function formatSubroutineCall(funcName)
{
	return "o<" + "f360_" + funcName + "> call";
}

function formatParameter(parmVal)
{
	return "[" + parmVal + "]";
}

function formatComment(text) {
  return("(" + filterText(String(text), permittedCommentChars) + ")");
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text));
}

function writeCommentSeqno(text) {
  writeln(formatSequenceNumber() + formatComment(text));
}

/**
  Compare a text string to acceptable choices.

  Returns -1 if there is no match.
*/
function parseChoice() {
  for (var i = 1; i < arguments.length; ++i) {
    if (String(arguments[0]).toUpperCase() == String(arguments[i]).toUpperCase()) {
      return i - 1;
    }
  }
  return -1;
}

function UseToolWithETS(tool)
{
	var toolTypeName = getToolTypeName(tool.type);
	// don't attempt to measure probes
	if (toolTypeName == "probe")
	{
		writeComment("Skipping ETS functions for tool " + tool.number + ", probe");
		return false;
	}
	
	if (toolTypeName == "spot drill" || toolTypeName == "drill")
		return true;

	// don't attempt to check tools that are too big for the ets
	if (tool.diameter > (unit == MM ? 25.4 : 1) * properties.etsDiameterLimit)
	{
		writeComment("Skipping ETS functions for tool " + tool.number + ", " + toolTypeName + ", too big for the tool setter");
		return false;
	}
	
	return true;
}

function TurnOutputOn(channel)
{
	if (channel != "0")
		writeBlock(mFormat.format(64), pFormat.format(channel - 1));
}

function TurnOutputOff(channel)
{
	if (channel != "0")
		writeBlock(mFormat.format(65), pFormat.format(channel - 1));
}

function WaitForInputON(channel)
{
	if (channel != "0")
		writeBlock(mFormat.format(66), pFormat.format(channel - 1), "L3", "Q10000");
}

function CheckCurrentTool(tool)
{
	if (UseToolWithETS(tool))
	{
		writeComment("Use ETS to check length of tool " + tool.number)
		onCommand(COMMAND_COOLANT_OFF);
		onCommand(COMMAND_STOP_SPINDLE);
	
		TurnOutputOn(properties.etsInUseChannel);
		WaitForInputON(properties.etsReadyInput);
		writeBlock(gFormat.format(37), "P" + xyzFormat.format((unit == MM ? 25.4 : 1) * properties.etsTolerance));
		TurnOutputOff(properties.etsInUseChannel);
	}
}

function SetCurrentTool(tool)
{
	if (UseToolWithETS(tool))
	{
		writeComment("Use ETS to set length of tool " + tool.number)
		onCommand(COMMAND_COOLANT_OFF);
		onCommand(COMMAND_STOP_SPINDLE);
	
		TurnOutputOn(properties.etsInUseChannel);
		WaitForInputON(properties.etsReadyInput);
		writeBlock(gFormat.format(37));
		TurnOutputOff(properties.etsInUseChannel);
		}
}

function IsLiveTool(tool)
{
	// would love to implement it like this if Autodesk would sort out the logic in the library manager!
	//return tool.liveTool;
	return getToolTypeName(tool.type) != "probe";
}

function onOpen() 
{
	// install my expand tapping handler
	expandTapping = myExpandTapping;

	if (properties.useRadius) 
	{
		maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
	}

	if (properties.sequenceNumberOperation) 
	{
		properties.showSequenceNumbers = false;
	}

	// Define rotary attributes from properties
	var rotary = parseChoice(properties.rotaryTableAxis, "-Z", "-Y", "-X", "NONE", "X", "Y", "Z");
	if (rotary < 0) 
	{
		error(localize("Valid rotaryTableAxis values are: None, X, Y, Z, -X, -Y, -Z"));
		return;
	}
	rotary -= 3;

	// Define Master (carrier) axis
	masterAxis = Math.abs(rotary) - 1;
	if (masterAxis >= 0) 
	{
		var rotaryVector = [0, 0, 0];
		rotaryVector[masterAxis] = rotary/Math.abs(rotary);
		var aAxis = createAxis({coordinate:0, table:true, axis:rotaryVector, cyclic:true, preference:0});
		machineConfiguration = new MachineConfiguration(aAxis);

		setMachineConfiguration(machineConfiguration);
		// Single rotary does not use TCP mode
		optimizeMachineAngles2(1); // 0 = TCP Mode ON, 1 = TCP Mode OFF
	}

	if (!machineConfiguration.isMachineCoordinate(0)) 
	{
		aOutput.disable();
	}

	if (!machineConfiguration.isMachineCoordinate(1)) 
	{
		bOutput.disable();
	}

	if (!machineConfiguration.isMachineCoordinate(2)) 
	{
		cOutput.disable();
	}
  
	if (!properties.separateWordsWithSpace) 
	{
		setWordSeparator("");
	}

	sequenceNumber = properties.sequenceNumberStart;

	writeln("%");
	if (programName) 
	{
		writeComment(programName);
	}

	if (programComment) 
	{
		writeComment(programComment);
	}

	if (properties.writeVersion) 
	{
		if (typeof getHeaderVersion == "function" && getHeaderVersion()) 
		{
			writeComment(localize("post version") + ": " + getHeaderVersion());
		}
		if (typeof getHeaderDate == "function" && getHeaderDate()) 
		{
			writeComment(localize("post modified") + ": " + getHeaderDate());
		}
	}

	// dump machine configuration
	var vendor = machineConfiguration.getVendor();
	var model = machineConfiguration.getModel();
	var description = machineConfiguration.getDescription();

	if (properties.writeMachine && (vendor || model || description)) 
	{
		writeComment(localize("Machine"));
		if (vendor) 
		{
			writeComment("  " + localize("vendor") + ": " + vendor);
		}
		if (model) 
		{
			writeComment("  " + localize("model") + ": " + model);
		}
		if (description) 
		{
			writeComment("  " + localize("description") + ": "  + description);
		}
	}

	// dump tool information
	if (properties.writeTools) 
	{
		var zRanges = {};
		if (is3D()) 
		{
			var numberOfSections = getNumberOfSections();
			for (var i = 0; i < numberOfSections; ++i) 
			{
				var section = getSection(i);
				var zRange = section.getGlobalZRange();
				var tool = section.getTool();

				if (zRanges[tool.number]) 
					zRanges[tool.number].expandToRange(zRange);
				else 
					zRanges[tool.number] = zRange;
			}
		}
	}

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) 
	{
		writeComment("Tool table");
		for (var i = 0; i < tools.getNumberOfTools(); ++i) 
		{
			var tool = tools.getTool(i);
			var comment = "T" + toolFormat.format(tool.number) + "  " +
				"D=" + xyzFormat.format(tool.diameter) + " " +
			localize("CR") + "=" + xyzFormat.format(tool.cornerRadius);
			if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) 
			{
				comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
			}
			if (zRanges[tool.number]) 
			{
				comment += " - " + localize("ZMIN") + "=" + xyzFormat.format(zRanges[tool.number].getMinimum());
			}
			comment += " - " + getToolTypeName(tool.type);
			writeComment(comment);
		}
		writeComment("Tool table end");
    }
	
	if (false) 
	{
		// check for duplicate tool number
		for (var i = 0; i < getNumberOfSections(); ++i) 
		{
			var sectioni = getSection(i);
			var tooli = sectioni.getTool();
			for (var j = i + 1; j < getNumberOfSections(); ++j) 
			{
				var sectionj = getSection(j);
				var toolj = sectionj.getTool();
				if (tooli.number == toolj.number) 
				{
					if (xyzFormat.areDifferent(tooli.diameter, toolj.diameter) ||
						xyzFormat.areDifferent(tooli.cornerRadius, toolj.cornerRadius) ||
						abcFormat.areDifferent(tooli.taperAngle, toolj.taperAngle) ||
						(tooli.numberOfFlutes != toolj.numberOfFlutes)) 
					{
						error(subst(
							localize("Using the same tool number for different cutter geometry for operation '%1' and '%2'."),
							sectioni.hasParameter("operation-comment") ? sectioni.getParameter("operation-comment") : ("#" + (i + 1)),
							sectionj.hasParameter("operation-comment") ? sectionj.getParameter("operation-comment") : ("#" + (j + 1))
							));
						return;
					}
				}
			}
		}
	}

	if ((getNumberOfSections() > 0) && (getSection(0).workOffset == 0)) 
	{
		for (var i = 0; i < getNumberOfSections(); ++i) 
		{
			if (getSection(i).workOffset > 0) 
			{
				error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
				return;
			}
		}
	}

	// absolute coordinates and feed per min
	writeBlock(gAbsIncModal.format(90), gFormat.format(54), gFormat.format(64), gFormat.format(50), gPlaneModal.format(17), gFormat.format(40), gFormat.format(80), gFeedModeModal.format(94), gFormat.format(91.1), gFormat.format(49));

	switch (unit) 
	{
	case IN:
		writeBlock(gUnitModal.format(20), formatComment(localize("Inch")));
		break;
	case MM:
		writeBlock(gUnitModal.format(21), formatComment(localize("Metric")));
		break;
	}
  
	// at the start, we are not necessarily retracted
	retracted = false;

	// optional retract before start of program
	UserRetract(properties.retractOnProgramBegin, "before start of program");

	// write probing variables
	writeComment("Probing control variables");
	writeBlock("#<_probeFastSpeed>=", xyzFormat.format((unit == MM ? 25.4 : 1) * properties.probeFastSpeed));
	writeBlock("#<_probeSlowSpeed>=", xyzFormat.format((unit == MM ? 25.4 : 1) * properties.probeSlowSpeed));
	writeBlock("#<_probeSlowDistance>=", xyzFormat.format((unit == MM ? 25.4 : 1) * properties.probeSlowDistance));

	// turn on the g-code running output
	TurnOutputOn(properties.progRunningChannel);

	if (properties.etsBeforeStart != "none")
	{
		// some ets function requested before start of program
		writeComment("Use ETS to " + properties.etsBeforeStart + " tools before start of run");
		var tools = getToolTable();
		for (var i = 0; i < tools.getNumberOfTools(); ++i) 
		{
			// fetch the tool we are going to check
			var tool = tools.getTool(i);

			// check if this tool can be used
			if (!UseToolWithETS(tool))
				continue;
			
			writeComment("Load tool " + tool.number);
			UserRetract(properties.retractOnTCBegin, "prior to toolchange");
			writeBlock("T" + toolFormat.format(tool.number), gFormat.format(43), hFormat.format(tool.number), mFormat.format(6));
			onDwell(1.0);
			UserRetract(properties.retractOnTCEnd, "after tool change");

			switch (properties.etsBeforeStart)
			{
			case "set":
				SetCurrentTool(tool);
				break;
				
			case "check":
				CheckCurrentTool(tool);
				break;
			}
		}
	}
  
	writeComment("End of pre-amble")

}

function WriteInspectionHeader()
{
	writeComment("LOGAPPEND,inspection.txt");
	writeComment("LOG,program=" + programName);
	writeComment("LOG,timestamp=#<_epochtime>")
	writeComment("LOG,comment=" + programComment);
	writeComment("LOG,unit=" + ((unit == MM) ? "mm" : "inch"));
	writeComment("LOGCLOSE");
	inspectionHeaderWritten = true;
}

function DoStartInspection()
{
	writeln("");
	writeComment("Starting inspection")

	// don't write 2 inspection headers
	if (!inspectionHeaderWritten)
	{
		WriteInspectionHeader();
		inspectPartno = 1;
		inspectFeatureno = 1;
	}

	inspectionRunning = true;
}

function DoStopInspection()
{
	writeln("");
	writeComment("Inspection stopped")
	inspectionRunning = false;
}

function DoInspectionCommand(command)
{
	switch (command)
	{
		case "start":
		case "on":
		case "begin":
			DoStartInspection();
			break;

		case "stop":
		case "off":
		case "end":
			DoStopInspection();
			break;

		default:
			error("Unknown Inspection command - " + command);
		}
}

function OnManualAction(command)
{
	var commands = String(command).toLowerCase().split(/[,= ]+/);

	if (commands[0] == "inspection")
		DoInspectionCommand(commands[1])
	else
		error("Unknown MaualNC action - " + command);

}

// handler for all ManualNC sections
function onManualNC(command, value)
{
	switch (command)
	{
	case COMMAND_ACTION:
		// pick up Action manualNC
		OnManualAction(value);
		break;

	case COMMAND_DISPLAY_MESSAGE:
		writeln("");
		writeComment("MSG," + value);
		break;

	default:
		// default handling for all other manual nc
		expandManualNC(command, value);
	}
}

function onParameter(name, value) 
{
  if (name == "display") 
  {
    writeComment("MSG, " + value);
  }
}

function onComment(message) {
  var comments = String(message).split(";");
  for (comment in comments) {
    writeComment(comments[comment]);
  }
}

/** Force output of X, Y, and Z. */
function  forceXYZ()
{
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  previousDPMFeed = 0;
  feedOutput.reset();
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function setWorkPlane(abc) {
  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }

  if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z))) {
    return; // no change
  }

  onCommand(COMMAND_UNLOCK_MULTI_AXIS);

  // NOTE: add retract here

  writeBlock(
    gMotionModal.format(0),
    conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(abc.x)),
    conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(abc.y)),
    conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(abc.z))
  );
  
  onCommand(COMMAND_LOCK_MULTI_AXIS);

  currentWorkPlaneABC = abc;
}

var closestABC = true; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane) 
{
  	var W = workPlane; // map to global frame

  	var abc = machineConfiguration.getABC(W);
	if (closestABC) 
	{
		if (currentMachineABC) 
		{
      		abc = machineConfiguration.remapToABC(abc, currentMachineABC);
		} 
		else 
		{
      		abc = machineConfiguration.getPreferredABC(abc);
    	}
	} 
	else 
	{
    	abc = machineConfiguration.getPreferredABC(abc);
  	}
  
	try 
	{
    	abc = machineConfiguration.remapABC(abc);
    	currentMachineABC = abc;
	} 
	catch (e)
	{
    	error(
			localize("Machine angles not supported") + ":"
			+ conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
			+ conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
			+ conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
			);
	}
  
  	var direction = machineConfiguration.getDirection(abc);
	if (!isSameDirection(direction, W.forward)) 
	{
    	error(localize("Orientation not supported."));
  	}
	  
	if (!machineConfiguration.isABCSupported(abc)) 
	{
    	error(
		localize("Work plane is not supported") + ":"
		+ conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
		+ conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
		+ conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
		);
  	}

  	var tcp = false;
  	cancelTransformation();
	if (tcp)
	{
    	setRotation(W); // TCP mode
	}
	else
	{
    	var O = machineConfiguration.getOrientation(abc);
    	var R = machineConfiguration.getRemainingOrientation(abc, W);
    	var rotate = true;
    	var axis = machineConfiguration.getAxisU();
		if (axis.isEnabled() && axis.isTable())
		{
      		var ix = axis.getCoordinate();
      		var rotAxis = axis.getAxis();
      		if (isSameDirection(machineConfiguration.getDirection(abc), rotAxis) ||
				  isSameDirection(machineConfiguration.getDirection(abc), Vector.product(rotAxis, -1)))
			{
        		var direction = isSameDirection(machineConfiguration.getDirection(abc), rotAxis) ? 1 : -1;
        		abc.setCoordinate(ix, Math.atan2(R.right.y, R.right.x) * direction);
        		rotate = false;
      		}
    	}
		if (rotate)
		{
      		setRotation(R);
    	}
  	}
  	return abc;
}
var measureToolRequested = false;

function onSection() 
{
	// are we changing the tool ?
	var insertToolCall = isFirstSection() ||
		currentSection.getForceToolChange && currentSection.getForceToolChange() ||
		(tool.number != getPreviousSection().getTool().number);
  
//	retracted = false; // specifies that the tool has been retracted to the safe plane
	
	// are we changing the WCS
	var newWorkOffset = isFirstSection() ||
		(getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  
	// are we changing the work plane
	var newWorkPlane = isFirstSection() ||
		!isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
		(currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
		Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
		(!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
		(!getPreviousSection().isMultiAxis() && currentSection.isMultiAxis() ||
		getPreviousSection().isMultiAxis() && !currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations

	if (insertToolCall || newWorkOffset || newWorkPlane) 
	{
		if (!isFirstSection() && !insertToolCall)
		{
			if (newWorkOffset)
				UserRetract(properties.retractOnWCSChange, "new WCS");
		
			if (newWorkPlane)
				UserRetract(properties.retractOnWorkPlaneChange, "new work plane");
		}
			
		forceWorkPlane();
	}
	
	writeln("");

	if (hasParameter("operation-comment")) 
	{
		var comment = getParameter("operation-comment");
		if (comment) 
		{
			if (properties.sequenceNumberOperation) 
			{
				writeCommentSeqno(comment);
			} 
			else 
			{
				writeComment(comment);
			}
		}
	}

	// optional stop
	if (!isFirstSection() && ((insertToolCall && properties.optionalStopTool) || properties.optionalStopOperation))
	{
		onCommand(COMMAND_OPTIONAL_STOP);
	}

	// tool change
	if (insertToolCall) 
	{
		forceWorkPlane();
		onCommand(COMMAND_COOLANT_OFF);
		onCommand(COMMAND_STOP_SPINDLE);

		if (tool.number > properties.maxTool) 
		{
			warning(localize("Tool number exceeds maximum value."));
		}
	
		var lengthOffset = tool.lengthOffset;
		if (lengthOffset > properties.maxTool) 
		{
			error(localize("Length offset out of range."));
			return;
		}

		// time to check the outgoing tool
		// ETS check of outgoing tool
		if (!isFirstSection())
		{
			var previousTool = getPreviousSection().getTool();
			switch (properties.etsAfterUse)
			{
				case "check":
					CheckCurrentTool(previousTool);
					break;
				
				case "set":
					SetCurrentTool(previousTool);
					break;
			}
		}
	
		// change tool
		UserRetract(properties.retractOnTCBegin, "prior to toolchange");
		TurnOutputOn(properties.toolChangeInProgressChannel);

		if (properties.useM6) 
		{
			writeBlock("T" + toolFormat.format(tool.number),
			gFormat.format(43),
			hFormat.format(lengthOffset),
			mFormat.format(6));
		} 
		else 
		{
			writeBlock("T" + toolFormat.format(tool.number), gFormat.format(43), hFormat.format(lengthOffset));
		}
	
		TurnOutputOff(properties.toolChangeInProgressChannel);
		UserRetract(properties.retractOnTCEnd, "after toolchange");

		// time to do ets processing for the new tool
		switch (properties.etsBeforeUse)
		{
			case "check":
				CheckCurrentTool(tool);
				break;
		
			case "set":
				SetCurrentTool(tool);
				break;
		}

		if (tool.comment) 
		{
			writeComment(tool.comment);
		}

		var showToolZMin = false;
		if (showToolZMin) 
		{
			if (is3D()) 
			{
				var numberOfSections = getNumberOfSections();
				var zRange = currentSection.getGlobalZRange();
				var number = tool.number;
				for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) 
				{
					var section = getSection(i);
					if (section.getTool().number != number) 
					{
						break;
					}
					zRange.expandToRange(section.getGlobalZRange());
				}
				writeComment(localize("ZMIN") + "=" + zRange.getMinimum());
			}
		}
	} // if (InsertToolCall)
  
	// manual nc requested tool measure
	if (measureToolRequested)
	{
		writeComment("Tool measure requested by ManulNC");
		measureToolRequested = false;
		SetCurrentTool(tool);
	}

	// Define coolant code
	var topOfPart = undefined;
	if (hasParameter("operation:surfaceZHigh")) 
	{
		topOfPart = getParameter("operation:surfaceZHigh"); // TAG: not safe
	}

	// set the coolant
	// don't attempt to set coolant for probes or non live tools
	if (IsLiveTool(tool) && getToolTypeName(tool.type) != "probe")
	{
		var c = setCoolant(tool.coolant, topOfPart);
		writeBlock(c[0], c[1], c[2], c[3]);
	}
	else
		onCommand(COMMAND_COOLANT_OFF);

	// now set the spindle
	if (true ||
		insertToolCall ||
		isFirstSection() ||
		(rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) ||
		(tool.clockwise != getPreviousSection().getTool().clockwise)) 
	{
		if (spindleSpeed < 0) 
		{
			error(localize("Spindle speed out of range."));
			return;
		}

		if (spindleSpeed > 99999) 
		{
			warning(localize("Spindle speed exceeds maximum value."));
		}

		// would love to do this check, but Fusion 360 currently flags warnings if you set the spindle speed to 0 - even if it's a live tool
		// error if nonlivetool has non zero spindle speed
		if (!IsLiveTool(tool) && spindleSpeed > 0)
		{
			error("Non-zero spindle speed specified for non-live tool, tool number " + tool.number + ", " + getToolTypeName(tool.type));
			return;
		}

		if (!IsLiveTool(tool) || spindleSpeed == 0) 
		{
			onCommand(COMMAND_STOP_SPINDLE);
		} 
		else 
		{
			writeBlock(sOutput.format(spindleSpeed));
			onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
			if ((spindleSpeed > 5000) && properties.waitForSpindle) 
			{
				onDwell(properties.waitForSpindle);
			}
		}
	} // set spindle

	// wcs
	if (insertToolCall && properties.forceWorkOffset) 
	{ 
		// force work offset when changing tool
		currentWorkOffset = undefined;
	}

	var workOffset = currentSection.workOffset;
	if (workOffset == 0) 
	{
		warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
		workOffset = 1;
	}

	if (workOffset > 0) 
	{
		var p = workOffset; // 1->... // G59 P1 is the same as G54 and so on
		if (p > MAX_WORK_OFFSET)
		{
			error(localize("Work offset out of range."));
			return;
		}

		if (workOffset != currentWorkOffset) 
		{
			if (p > 9) 
			{
				// new format for PathPilot V2.3.4 onward - G54.1 Pxxx
				writeBlock(gFormat.format(54.1), pFormat.format(workOffset));
			}
			else if (p > 6) 
			{
				// G59.xxx
				p = 59 + ((p - 6)/10.0);
				writeBlock(gFormat.format(p)); // G59.x
			} 
			else
			{
				// G54 .. G59
				writeBlock(gFormat.format(53 + workOffset)); // G54->G59
			}
			currentWorkOffset = workOffset;
		}
	}

	forceXYZ();

	if (machineConfiguration.isMultiAxisConfiguration()) 
	{ // use 5-axis indexing for multi-axis mode
		// set working plane after datum shift

		var abc = new Vector(0, 0, 0);
		if (currentSection.isMultiAxis()) 
		{
			forceWorkPlane();
			cancelTransformation();
			abc = currentSection.getInitialToolAxisABC();
		} 
		else 
		{
			abc = getWorkPlaneMachineABC(currentSection.workPlane);
		}
		
		setWorkPlane(abc);
	} 
	else 
	{ // pure 3D
		var remaining = currentSection.workPlane;
		if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) 
		{
			error(localize("Tool orientation is not supported."));
			return;
		}
		setRotation(remaining);
	}

	forceAny();
	gMotionModal.reset();

	var initialPosition = getFramePosition(currentSection.getInitialPosition());
	if (!retracted && !insertToolCall) 
	{
		if (getCurrentPosition().z < initialPosition.z) 
		{
			writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
		}
	}

	if (!insertToolCall && retracted) 
	{ // G43 already called above on tool change
		var lengthOffset = tool.lengthOffset;
		if (lengthOffset > properties.maxTool) 
		{
			error(localize("Length offset out of range."));
			return;
		}

		gMotionModal.reset();
		writeBlock(gPlaneModal.format(17));
	
		if (!machineConfiguration.isHeadConfiguration()) 
		{
			writeBlock(
			gAbsIncModal.format(90),
			gMotionModal.format(0), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y));
		
			writeBlock(gMotionModal.format(0), gFormat.format(43), zOutput.format(initialPosition.z), hFormat.format(lengthOffset));
		} 
		else 
		{
			writeBlock(
				gAbsIncModal.format(90),
				gMotionModal.format(0),
				gFormat.format(43), xOutput.format(initialPosition.x),
				yOutput.format(initialPosition.y),
				zOutput.format(initialPosition.z), hFormat.format(lengthOffset)
				);
		}
 	} 
 	else 
 	{
		writeBlock(
      		gAbsIncModal.format(90),
      		gMotionModal.format(0),
      		xOutput.format(initialPosition.x),
			yOutput.format(initialPosition.y)
			);
 	}
}

// allow manual insertion of comma delimited g-code
function onPassThrough(text) 
{
  	var commands = String(text).split(",");
	for (text in commands) 
	{
    	writeBlock(commands[text]);
  	}
}

function onDwell(seconds) 
{
	if (seconds > 99999.999) 
		warning(localize("Dwelling time is out of range."));

	if (properties.dwellInSeconds) 
		writeBlock(gFormat.format(4), "P" + secFormat.format(seconds));
	else 
	{
		milliseconds = clamp(1, seconds * 1000, 99999999);
		writeBlock(gFormat.format(4), "P" + milliFormat.format(milliseconds));
	}
}

function onSpindleSpeed(spindleSpeed) 
{
  writeBlock(sOutput.format(spindleSpeed));
}

function setCoolant(coolant, topOfPart) 
{
	var coolCodes = ["", "", "", ""];
	coolantZHeight = 9999.0;
	var coolantCode = 9;

	if (properties.disableCoolant) 
	{
		return coolCodes;
	}
  
	// Smart coolant is not enabled
	if (!properties.smartCoolEquipped) 
	{
		if (coolant == COOLANT_OFF) 
		{
			coolantCode = 9;
		} 
		else 
		{
			coolantCode = 8; // default all coolant modes to flood
			if (coolant != COOLANT_FLOOD) 
			{
				warning(localize("Unsupported coolant setting. Defaulting to FLOOD."));
			}
		}
		
		coolCodes[0] = coolantOutput.format(coolantCode);
		//mFormat.format(coolantCode);
	} 
	else 
	{ // Smart coolant is enabled
		// must drive the output because of additional words to configure smart cool
		coolantOutput.reset();
		if ((coolant == COOLANT_MIST) || (coolant == COOLANT_AIR)) 
		{
			coolantCode = 7;
			coolCodes[0] = coolantOutput.format(coolantCode);
			// coolCodes[0] = mFormat.format(coolantCode);
		} 
		else if (coolant == COOLANT_FLOOD_MIST) 
		{ // flood with air blast
			coolantCode = 8;
			coolCodes[0] = coolantOutput.format(coolantCode);
			// coolCodes[0] = mFormat.format(coolantCode);
			if (properties.multiCoolEquipped) 
			{
				if (properties.multiCoolAirBlastSeconds != 0) 
				{
					coolCodes[3] = qFormat.format(properties.multiCoolAirBlastSeconds);
				}
			} 
			else 
			{
				warning(localize("COOLANT_FLOOD_MIST programmed without Multi-Coolant support. Defaulting to FLOOD."));
			}
		} 
		else if (coolant == COOLANT_OFF) 
		{
			coolantCode = 9;
			coolCodes[0] = coolantOutput.format(coolantCode);
			// coolCodes[0] = mFormat.format(coolantCode);
		} 
		else 
		{
			coolantCode = 8;
			coolCodes[0] = coolantOutput.format(coolantCode);
			//coolCodes[0] = mFormat.format(coolantCode);
			if (coolant != COOLANT_FLOOD) 
			{
				warning(localize("Unsupported coolant setting. Defaulting to FLOOD."));
			}
		}

		// Determine Smart Coolant location based on machining operation
		if (hasParameter("operation-strategy")) 
		{
			var strategy = getParameter("operation-strategy");
			if (strategy) 
			{
				// Drilling strategy. Keep coolant at top of part
				if (strategy == "drill") 
				{
					if (topOfPart != undefined) 
					{
						coolantZHeight = topOfPart;
						coolCodes[1] = "E" + xyzFormat.format(coolantZHeight);
					}

					// Tool end point milling. Keep coolant at end of tool
				} 
				else if ((strategy == "face") ||
					(strategy == "engrave") ||
                   	(strategy == "contour_new") ||
                   	(strategy == "horizontal_new") ||
                   	(strategy == "parallel_new") ||
                   	(strategy == "scallop_new") ||
                   	(strategy == "pencil_new") ||
                   	(strategy == "radial_new") ||
                   	(strategy == "spiral_new") ||
                   	(strategy == "morphed_spiral") ||
                   	(strategy == "ramp") ||
                   	(strategy == "project")) 
				{
					coolCodes[1] = "P" + coolantOptionFormat.format(0);

					// Side Milling. Sweep the coolant along the length of the tool
				} 
				else 
				{
					coolCodes[1] = "P" + coolantOptionFormat.format(0);
					coolCodes[2] = "R" + xyzFormat.format(tool.fluteLength * (properties.smartCoolToolSweepPercentage / 100.0));
				}
			}
		}
	}

	// sort out the io module for the selected collant mode
	switch (coolantCode)
	{
		case 7:
			// mist coolant
			TurnOutputOn(properties.mistCoolingOnChannel);
			TurnOutputOff(properties.floodCoolingOnChannel);
			break;
			
		case 8:
			// flood coolant
			TurnOutputOn(properties.floodCoolingOnChannel);
			TurnOutputOff(properties.mistCoolingOnChannel);
			break;
			
		case 9:
			// no coolant
			TurnOutputOff(properties.floodCoolingOnChannel);
			TurnOutputOff(properties.mistCoolingOnChannel);
			break;
	}
	
	currentCoolantMode = coolant;
	return coolCodes;
}

function onCycle() 
{
	 writeBlock(gPlaneModal.format(17));
}

function getCommonCycle(x, y, z, r) 
{
	forceXYZ();
	return [xOutput.format(x), yOutput.format(y),
		zOutput.format(z),
		"R" + xyzFormat.format(r)];
}

function expandTappingPoint(x, y, z) 
{
	onExpandedRapid(x, y, cycle.clearance);
	onExpandedLinear(x, y, z, cycle.feedrate);
	onExpandedLinear(x, y, cycle.clearance, cycle.feedrate * properties.reversingHeadFeed);
}

// some functions to support probing operations
/* Convert approach to sign. */
function approach(value)
{
  validate((value == "positive") || (value == "negative"), "Invalid approach.");
  return (value == "positive") ? 1 : -1;
}

function IsInspectionSection(section)
{
	return section.hasParameter("operation-strategy") && (section.getParameter("operation-strategy") == "probe") && inspectionRunning;
//		&& section.hasParameter("probe-output-work-offset") && (section.getParameter("probe-output-work-offset") > MAX_WORK_OFFSET);
}

function isProbeOperation() 
{
  return hasParameter("operation-strategy") && (getParameter("operation-strategy") == "probe");
}

function onParameter(name, value) 
{
  if (name == "probe-output-work-offset") 
  {
    probeOutputWorkOffset = inspectionRunning ? 1000 : ((value > 0) ? value : 1);
  }
}


function ShowProbeHeader()
{
	// output only if this is an inspection operation
	if (IsInspectionSection(currentSection))
	{
		var comment = "Probe";
		if (hasParameter("operation-comment")) 
		{
			comment = getParameter("operation-comment");
			if (!comment) 
				comment = "Probe";
		}
  
		writeComment("LOGAPPEND,inspection.txt");
		writeComment("LOG," + cycleType + "," + currentWorkOffset + "," + inspectPartno + "," + inspectFeatureno + "," + comment);
		writeComment("LOGCLOSE");

		// increment the part and feature number
		inspectFeatureno++;

		if (cycle.printResults && cycle.incrementComponent)
		{
			inspectPartno++;
			inspectFeatureno = 1;
		}
	}
}

function onCyclePoint(x, y, z) 
{
	if (!isSameDirection(getRotation().forward, new Vector(0, 0, 1))) 
	{
		expandCyclePoint(x, y, z);
		return;
	}

  	if (isFirstCyclePoint()) 
  	{
    	repositionToCycleClearance(cycle, x, y, z);
    
    	// return to initial Z which is clearance plane and set absolute mode

    	var F = cycle.feedrate;
    	var P = !cycle.dwell ? 0 : cycle.dwell; // in seconds

		// Adjust SmartCool to top of part if it changes    // Adjust SmartCool to top of part if it changes
		if (properties.smartCoolEquipped && xyzFormat.areDifferent((z + cycle.depth), coolantZHeight)) 
		{
      		var c = setCoolant(currentCoolantMode, z + cycle.depth);
			if (c)
			{
        		writeBlock(c[0], c[1], c[2], c[3]);
      		}
    	}

		switch (cycleType) 
		{
			case "drilling":
				writeBlock(
					gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
					getCommonCycle(x, y, z, cycle.retract),
					feedOutput.format(F)
				);
			break;

			case "counter-boring":
				if (P > 0) 
				{
					writeBlock(
					gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(82),
					getCommonCycle(x, y, z, cycle.retract),
					"P" + secFormat.format(P),
					feedOutput.format(F)
					);
				} 
				else 
				{
					writeBlock(
					gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
					getCommonCycle(x, y, z, cycle.retract),
					feedOutput.format(F)
					);
				}
			break;

			case "chip-breaking":
				if ((P > 0) || (cycle.accumulatedDepth < cycle.depth)) 
				{
					expandCyclePoint(x, y, z);
				} 
				else 
				{
					writeBlock(
					gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(73),
					getCommonCycle(x, y, z, cycle.retract),
					"Q" + xyzFormat.format(cycle.incrementalDepth),
					feedOutput.format(F)
					);
				}
			break;

		case "deep-drilling":
		writeBlock(
			gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(83),
			getCommonCycle(x, y, z, cycle.retract),
			"Q" + xyzFormat.format(cycle.incrementalDepth),
			// conditional(P > 0, "P" + secFormat.format(P)),
			feedOutput.format(F)
		);
		break;
		case "tapping":
			if (tool.type == TOOL_TAP_LEFT_HAND || properties.expandTapping)
				expandCyclePoint(x, y, z);
			else if (properties.reversingHead) 
			{
				expandTappingPoint(x, y, z);
			} 
			else 
			{
				if (!F) 
				{
					F = tool.getTappingFeedrate();
				}
				writeBlock(sOutput.format(spindleSpeed));
				writeBlock(
					gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(84),
					getCommonCycle(x, y, z, cycle.retract),
					conditional(P > 0, "P" + secFormat.format(P)),
					feedOutput.format(F)
					);
			}
		break;
		case "left-tapping":
		if (properties.expandTapping)
			expandCyclePoint(x, y, z);
		else if (properties.reversingHead) {
			expandTappingPoint(x, y, z);
		} else {
			if (!F) {
			F = tool.getTappingFeedrate();
			}
			writeBlock(
			gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(84),
			getCommonCycle(x, y, z, cycle.retract),
			conditional(P > 0, "P" + secFormat.format(P)),
			feedOutput.format(F)
			);
		}
		break;
		case "right-tapping":
		if (properties.expandTapping)
				expandCyclePoint(x, y, z);
		else if (properties.reversingHead) {
			expandTappingPoint(x, y, z);
		} else {
			if (!F) {
			F = tool.getTappingFeedrate();
			}
			writeBlock(
			gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(84),
			getCommonCycle(x, y, z, cycle.retract),
			conditional(P > 0, "P" + secFormat.format(P)),
			feedOutput.format(F)
			);
		}
		break;
		case "fine-boring":
		writeBlock(
			gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(76),
			getCommonCycle(x, y, z, cycle.retract),
			"P" + secFormat.format(P),
			"Q" + xyzFormat.format(cycle.shift),
			feedOutput.format(F)
		);
		break;
		case "back-boring":
		var dx = (gPlaneModal.getCurrent() == 19) ? cycle.backBoreDistance : 0;
		var dy = (gPlaneModal.getCurrent() == 18) ? cycle.backBoreDistance : 0;
		var dz = (gPlaneModal.getCurrent() == 17) ? cycle.backBoreDistance : 0;
		writeBlock(
			gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(87),
			getCommonCycle(x - dx, y - dy, z - dz, cycle.bottom),
			"I" + xyzFormat.format(cycle.shift),
			"J" + xyzFormat.format(0),
			"P" + secFormat.format(P),
			feedOutput.format(F)
		);
		break;
		case "reaming":
		if (P > 0) {
			writeBlock(
			gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(89),
			getCommonCycle(x, y, z, cycle.retract),
			"P" + secFormat.format(P),
			feedOutput.format(F)
			);
		} else {
			writeBlock(
			gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(85),
			getCommonCycle(x, y, z, cycle.retract),
			feedOutput.format(F)
			);
		}
		break;
		case "stop-boring":
		writeBlock(
			gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(86),
			getCommonCycle(x, y, z, cycle.retract),
			"P" + secFormat.format(P),
			feedOutput.format(F)
		);
		break;
		case "manual-boring":
		writeBlock(
			gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(88),
			getCommonCycle(x, y, z, cycle.retract),
			"P" + secFormat.format(P),
			feedOutput.format(F)
		);
		break;
		case "boring":
		if (P > 0) {
			writeBlock(
			gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(89),
			getCommonCycle(x, y, z, cycle.retract),
			"P" + secFormat.format(P),
			feedOutput.format(F)
			);
		} else {
			writeBlock(
			gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(85),
			getCommonCycle(x, y, z, cycle.retract),
			feedOutput.format(F)
			);
		}
		break;
	// here come all the probing options

		case "probing-x":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(approach(cycle.approach1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
			 	formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			gMotionModal.reset();
		break;

		case "probing-y":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(approach(cycle.approach1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			gMotionModal.reset();
		break;

		case "probing-z":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(approach(cycle.approach1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			gMotionModal.reset();
		break;

		case "probing-x-wall":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
		break;

		case "probing-y-wall":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			break;

		case "probing-x-channel":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			break;

		case "probing-x-channel-with-island":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
		break;

		case "probing-y-channel":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			break;
			
		case "probing-y-channel-with-island":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			break;
			
		case "probing-xy-circular-boss":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
		break;
		
		case "probing-xy-circular-partial-boss":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				formatParameter(probeAngleFormat.format(cycle.partialCircleAngleA)),
				formatParameter(probeAngleFormat.format(cycle.partialCircleAngleB)),
				formatParameter(probeAngleFormat.format(cycle.partialCircleAngleC)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
		break;

		case "probing-xy-circular-hole":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			break;

		case "probing-xy-circular-hole-with-island":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			break;

		case "probing-xy-circular-partial-hole":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				formatParameter(probeAngleFormat.format(cycle.partialCircleAngleA)),
				formatParameter(probeAngleFormat.format(cycle.partialCircleAngleB)),
				formatParameter(probeAngleFormat.format(cycle.partialCircleAngleC)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
		break;

		case "probing-xy-circular-partial-hole-with-island":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				formatParameter(probeAngleFormat.format(cycle.partialCircleAngleA)),
				formatParameter(probeAngleFormat.format(cycle.partialCircleAngleB)),
				formatParameter(probeAngleFormat.format(cycle.partialCircleAngleC)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			break;

		case "probing-xy-rectangular-hole":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.width2)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			break;

		case "probing-xy-rectangular-boss":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.width2)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
		break;
		
		case "probing-xy-rectangular-hole-with-island":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(xyzFormat.format(cycle.width1)),
				formatParameter(xyzFormat.format(cycle.width2)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			break;

		case "probing-xy-inner-corner":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(approach(cycle.approach1)),
				formatParameter(approach(cycle.approach2)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			gMotionModal.reset();
			break;

		case "probing-xy-outer-corner":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(approach(cycle.approach1)),
				formatParameter(approach(cycle.approach2)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			gMotionModal.reset();
			break;

		case "probing-x-plane-angle":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(approach(cycle.approach1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				formatParameter(xyzFormat.format(cycle.probeSpacing)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			gMotionModal.reset();

			g68RotationMode = 1;
			break;
			
		case "probing-y-plane-angle":
			writeComment(cycleType);
			ShowProbeHeader();
			TurnOutputOn(properties.probeInUseChannel);
			writeBlock(formatSubroutineCall(cycleType),
				formatParameter(xyzFormat.format(x)),
				formatParameter(xyzFormat.format(y)),
				formatParameter(xyzFormat.format(z)),
				formatParameter(xyzFormat.format(tool.diameter)),
				formatParameter(feedFormat.format(F)),
				formatParameter(xyzFormat.format(cycle.depth)),
				formatParameter(approach(cycle.approach1)),
				formatParameter(xyzFormat.format(cycle.probeClearance)),
				formatParameter(xyzFormat.format(cycle.probeOvertravel)),
				formatParameter(xyzFormat.format(cycle.retract)),
				formatParameter(probe100Format.format(probeOutputWorkOffset)),
				formatParameter(xyzFormat.format(cycle.probeSpacing)),
				getProbingArguments(cycle)
				);
			TurnOutputOff(properties.probeInUseChannel);

			// probing may change the motion mode, so it needs to be re-established in the next move
			forceXYZ();
			gMotionModal.reset();

			g68RotationMode = 1;
			break;

		// end of probing

		default:
		expandCyclePoint(x, y, z);
		}
	} 
	else
	{
		if (cycleExpanded) 
		{
      		expandCyclePoint(x, y, z);
		} 
		else if (((cycleType == "tapping") || (cycleType == "right-tapping") || (cycleType == "left-tapping")) && properties.reversingHead)
		{
      		expandTappingPoint(x, y, z);
		} 
		else 
		{
      		writeBlock(xOutput.format(x), yOutput.format(y));
    	}
  	}
}

function getProbingArguments(cycle) 
{
	return [
				// size tolerance
				formatParameter(xyzFormat.format(cycle.toleranceSize ? cycle.toleranceSize : 0)),
				formatParameter(cycle.wrongSizeAction == "stop-message" ? 1 : 0),

				// position tolerance
				formatParameter(xyzFormat.format(cycle.tolerancePosition ? cycle.tolerancePosition : 0)),
				formatParameter(cycle.outOfPositionAction == "stop-message" ? 1 : 0),

				// angular tolerance
				formatParameter(xyzFormat.format(cycle.toleranceAngle ? cycle.toleranceAngle : 0)),
				formatParameter(cycle.angleAskewAction == "stop-message" ? 1 : 0),

				// print results
				formatParameter(cycle.printResults ? (xyzFormat.format(2 + cycle.incrementComponent)) : 0)
			];
  }
  
function myExpandTapping(x, y, z)
{
	writeComment("Tapping with a " + (tool.clockwise ? "right hand" : "left hand") + " tap")
	// get the feedrate either from the cycle, or the tool
	var feedRate = cycle.feedRate;
	if (!feedRate)
		feedRate = tool.getTappingFeedrate();

	// rapid move above the hole
	onRapid(x, y, cycle.clearance);

	// spindle on
	onSpindleSpeed(tool.spindleRPM * properties.tapSpeedFactor);
	if (tool.clockwise)
		onCommand(COMMAND_SPINDLE_CLOCKWISE);
	else
		onCommand(COMMAND_SPINDLE_COUNTERCLOCKWISE);

	// rapid down to retract height
	onRapid(x, y, cycle.retract);

	// linear down to slightly less than tapping depth
	onLinear(x, y, z + 2.0 * tool.getThreadPitch(), feedRate);
	
	// reverse the motor
	if (tool.clockwise)
		onCommand(COMMAND_SPINDLE_COUNTERCLOCKWISE);
	else
		onCommand(COMMAND_SPINDLE_CLOCKWISE);
	
	// short rapid movement to final depth
	onRapid(x, y, z);

	if (cycle.dwell > 0)
        writeBlock(gFormat.format(4), "P" + secFormat.format(cycle.dwell));
	
	// linear back up to retract height
	onLinear(x, y, cycle.retract, feedRate);
	
	//if (cycle.dwell > 0)
    //    writeBlock(gFormat.format(4), "P" + secFormat.format(cycle.dwell));
	
	// rapid back up to clearance
	onRapid(x, y, cycle.clearance);

    // spindle on forward again
	//onSpindleSpeed(tool.spindleRPM * properties.tapSpeedFactor);
	if (tool.clockwise)
		onCommand(COMMAND_SPINDLE_CLOCKWISE);
	else
		onCommand(COMMAND_SPINDLE_COUNTERCLOCKWISE);
}

function onCycleEnd() {
  if (!cycleExpanded) {
    writeBlock(gCycleModal.format(80));
    zOutput.reset();
  }
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

function onMovement(movement) {
  movementType = movement;
}

function onRapid(_x, _y, _z) 
{
	var x = xOutput.format(_x);
	var y = yOutput.format(_y);
	var z = zOutput.format(_z);
	if (x || y || z) 
	{
		if (pendingRadiusCompensation >= 0) 
		{
			error(localize("Radius compensation mode cannot be changed at rapid traversal."));
			return;
		}
		writeBlock(gMotionModal.format(0), x, y, z);
		feedOutput.reset();
	}
}

function onLinear(_x, _y, _z, feed) 
{
	if (retracted)
//	 	if(properties.substituteRapidAfterRetract)
//		{
//			writeComment("Substituting Linear with rapid");
//			onRapid(_x, _y, _z);
//			return;
//		}
//		else
			writeComment("Linear move whilst retracted");

	var x = xOutput.format(_x);
	var y = yOutput.format(_y);
	var z = zOutput.format(_z);
	var f = feedOutput.format(feed);
	if (x || y || z) 
	{
		if (pendingRadiusCompensation >= 0) 
		{
			pendingRadiusCompensation = -1;
			var d = tool.diameterOffset;
			if (d > properties.maxTool) 
			{
				warning(localize("The diameter offset exceeds the maximum value."));
			}
			writeBlock(gPlaneModal.format(17));
			switch (radiusCompensation) 
			{
				case RADIUS_COMPENSATION_LEFT:
					dOutput.reset();
					writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), gFormat.format(41), x, y, z, dOutput.format(d), f);
					// error(localize("Radius compensation mode is not supported by the CNC control."));
					break;
		
				case RADIUS_COMPENSATION_RIGHT:
					dOutput.reset();
					writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), gFormat.format(42), x, y, z, dOutput.format(d), f);
					// error(localize("Radius compensation mode is not supported by the CNC control."));
					break;
				default:
					writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), gFormat.format(40), x, y, z, f);
			}
		} 
		else 
		{
			writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), x, y, z, f);
		}
	} 
	else if (f) 
	{
		if (getNextRecord().isMotion()) 
		{ // try not to output feed without motion
			feedOutput.reset(); // force feed on next line
		}
		else 
		{
			writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), f);
		}
	}
}

function onRapid5D(_x, _y, _z, _a, _b, _c) 
{
	if (retracted)
		writeComment("Rapid multi-axis while retracted");

	if (!currentSection.isOptimizedForMachine()) 
	{
    	error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
    	return;
  	}
  
	if (pendingRadiusCompensation >= 0) 
	{
    	error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    	return;
  	}

	  var x = xOutput.format(_x);
	var y = yOutput.format(_y);
	var z = zOutput.format(_z);
	var a = aOutput.format(_a);
	var b = bOutput.format(_b);
	var c = cOutput.format(_c);
	writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
	feedOutput.reset();
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) 
{
	if (retracted)
		writeComment("Linear multi-axis while retracted");

	if (!currentSection.isOptimizedForMachine()) 
	{
    	error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
    	return;
  	}
  
	if (pendingRadiusCompensation >= 0) 
	{
    	error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    	return;
  	}

	var x = xOutput.format(_x);
	var y = yOutput.format(_y);
	var z = zOutput.format(_z);
	var a = aOutput.format(_a);
	var b = bOutput.format(_b);
	var c = cOutput.format(_c);

	// get feedrate number
	var f = {frn:0, fmode:0};
	if (a || b || c) 
	{
		f = getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed);
		if (useInverseTimeFeed) 
		{
			f.frn = inverseTimeOutput.format(f.frn);
		} 
		else 
		{
			f.frn = feedOutput.format(f.frn);
		}
	} 
	else 
	{
		f.frn = feedOutput.format(feed);
		f.fmode = 94;
	}

	if (x || y || z || a || b || c) 
	{
		writeBlock(gFeedModeModal.format(f.fmode), gMotionModal.format(1), x, y, z, a, b, c, f.frn);
	} 
	else if (f.frn) 
	{
		if (getNextRecord().isMotion()) 
		{ // try not to output feed without motion
			feedOutput.reset(); // force feed on next line
		} 
		else 
		{
			writeBlock(gFeedModeModal.format(f.fmode), gMotionModal.format(1), f.frn);
		}
	}
}

// Start of multi-axis feedrate logic
/***** You can add 'properties.useInverseTime' if desired. *****/
/***** 'previousABC' can be added throughout to maintain previous rotary positions. Required for Mill/Turn machines. *****/
/***** 'headOffset' should be defined when a head rotary axis is defined. *****/
/***** The feedrate mode must be included in motion block output (linear, circular, etc.) for Inverse Time feedrate support. *****/
var dpmBPW = 0.1; // ratio of rotary accuracy to linear accuracy for DPM calculations
var inverseTimeUnits = 1.0; // 1.0 = minutes, 60.0 = seconds
var maxInverseTime = 99999.9999; // maximum value to output for Inverse Time feeds
var maxDPM = 9999.99; // maximum value to output for DPM feeds
var useInverseTimeFeed = true; // use 1/T feeds
var inverseTimeFormat = createFormat({decimals:4, forceDecimal:true});
var inverseTimeOutput = createVariable({prefix:"F", force:true}, inverseTimeFormat);
var previousDPMFeed = 0; // previously output DPM feed
var dpmFeedToler = 0.5; // tolerance to determine when the DPM feed has changed
// var previousABC = new Vector(0, 0, 0); // previous ABC position if maintained in post, don't define if not used
var forceOptimized = undefined; // used to override optimized-for-angles points (XZC-mode)

/** Calculate the multi-axis feedrate number. */
function getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed) {
  var f = {frn:0, fmode:0};
  if (feed <= 0) {
    error(localize("Feedrate is less than or equal to 0."));
    return f;
  }
  
  var length = getMoveLength(_x, _y, _z, _a, _b, _c);
  
  if (useInverseTimeFeed) { // inverse time
    f.frn = getInverseTime(length.tool, feed);
    f.fmode = 93;
    feedOutput.reset();
  } else { // degrees per minute
    f.frn = getFeedDPM(length, feed);
    f.fmode = 94;
  }
  return f;
}

/** Returns point optimization mode. */
function getOptimizedMode() {
  if (forceOptimized != undefined) {
    return forceOptimized;
  }
  // return (currentSection.getOptimizedTCPMode() != 0); // TAG:doesn't return correct value
  return true; // always return false for non-TCP based heads
}
  
/** Calculate the DPM feedrate number. */
function getFeedDPM(_moveLength, _feed) {
  if ((_feed == 0) || (_moveLength.tool < 0.0001) || (toDeg(_moveLength.abcLength) < 0.0005)) {
    previousDPMFeed = 0;
    return _feed;
  }
  var moveTime = _moveLength.tool / _feed;
  if (moveTime == 0) {
    previousDPMFeed = 0;
    return _feed;
  }

  var dpmFeed;
  var tcp = false; // !getOptimizedMode() && (forceOptimized == undefined);   // set to false for rotary heads
  if (tcp) { // TCP mode is supported, output feed as FPM
    dpmFeed = _feed;
  } else if (false) { // standard DPM
    dpmFeed = Math.min(toDeg(_moveLength.abcLength) / moveTime, maxDPM);
    if (Math.abs(dpmFeed - previousDPMFeed) < dpmFeedToler) {
      dpmFeed = previousDPMFeed;
    }
  } else if (true) { // combination FPM/DPM
    var length = Math.sqrt(Math.pow(_moveLength.xyzLength, 2.0) + Math.pow((toDeg(_moveLength.abcLength) * dpmBPW), 2.0));
    dpmFeed = Math.min((length / moveTime), maxDPM);
    if (Math.abs(dpmFeed - previousDPMFeed) < dpmFeedToler) {
      dpmFeed = previousDPMFeed;
    }
  } else { // machine specific calculation
    dpmFeed = _feed;
  }
  previousDPMFeed = dpmFeed;
  return dpmFeed;
}

/** Calculate the Inverse time feedrate number. */
function getInverseTime(_length, _feed) {
  var inverseTime;
  if (_length < 1.e-6) { // tool doesn't move
    if (typeof maxInverseTime === "number") {
      inverseTime = maxInverseTime;
    } else {
      inverseTime = 999999;
    }
  } else {
    inverseTime = _feed / _length / inverseTimeUnits;
    if (typeof maxInverseTime === "number") {
      if (inverseTime > maxInverseTime) {
        inverseTime = maxInverseTime;
      }
    }
  }
  return inverseTime;
}

/** Calculate radius for each rotary axis. */
function getRotaryRadii(startTool, endTool, startABC, endABC) {
  var radii = new Vector(0, 0, 0);
  var startRadius;
  var endRadius;
  var axis = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
  for (var i = 0; i < 3; ++i) {
    if (axis[i].isEnabled()) {
      var startRadius = getRotaryRadius(axis[i], startTool, startABC);
      var endRadius = getRotaryRadius(axis[i], endTool, endABC);
      radii.setCoordinate(axis[i].getCoordinate(), Math.max(startRadius, endRadius));
    }
  }
  return radii;
}

/** Calculate the distance of the tool position to the center of a rotary axis. */
function getRotaryRadius(axis, toolPosition, abc) {
  if (!axis.isEnabled()) {
    return 0;
  }

  var direction = axis.getEffectiveAxis();
  var normal = direction.getNormalized();
  // calculate the rotary center based on head/table
  var center;
  var radius;
  if (axis.isHead()) {
    var pivot;
    if (typeof headOffset === "number") {
      pivot = headOffset;
    } else {
      pivot = tool.getBodyLength();
    }
    if (axis.getCoordinate() == machineConfiguration.getAxisU().getCoordinate()) { // rider
      center = Vector.sum(toolPosition, Vector.product(machineConfiguration.getDirection(abc), pivot));
      center = Vector.sum(center, axis.getOffset());
      radius = Vector.diff(toolPosition, center).length;
    } else { // carrier
      var angle = abc.getCoordinate(machineConfiguration.getAxisU().getCoordinate());
      radius = Math.abs(pivot * Math.sin(angle));
      radius += axis.getOffset().length;
    }
  } else {
    center = axis.getOffset();
    var d1 = toolPosition.x - center.x;
    var d2 = toolPosition.y - center.y;
    var d3 = toolPosition.z - center.z;
    var radius = Math.sqrt(
      Math.pow((d1 * normal.y) - (d2 * normal.x), 2.0) +
      Math.pow((d2 * normal.z) - (d3 * normal.y), 2.0) +
      Math.pow((d3 * normal.x) - (d1 * normal.z), 2.0)
    );
  }
  return radius;
}
  
/** Calculate the linear distance based on the rotation of a rotary axis. */
function getRadialDistance(radius, startABC, endABC) {
  // calculate length of radial move
  var delta = Math.abs(endABC - startABC);
  if (delta > Math.PI) {
    delta = 2 * Math.PI - delta;
  }
  var radialLength = (2 * Math.PI * radius) * (delta / (2 * Math.PI));
  return radialLength;
}
  
/** Calculate tooltip, XYZ, and rotary move lengths. */
function getMoveLength(_x, _y, _z, _a, _b, _c) {
  // get starting and ending positions
  var moveLength = {};
  var startTool;
  var endTool;
  var startXYZ;
  var endXYZ;
  var startABC;
  if (typeof previousABC !== "undefined") {
    startABC = new Vector(previousABC.x, previousABC.y, previousABC.z);
  } else {
    startABC = getCurrentDirection();
  }
  var endABC = new Vector(_a, _b, _c);
    
  if (!getOptimizedMode()) { // calculate XYZ from tool tip
    startTool = getCurrentPosition();
    endTool = new Vector(_x, _y, _z);
    startXYZ = startTool;
    endXYZ = endTool;

    // adjust points for tables
    if (!machineConfiguration.getTableABC(startABC).isZero() || !machineConfiguration.getTableABC(endABC).isZero()) {
      startXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).getTransposed().multiply(startXYZ);
      endXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).getTransposed().multiply(endXYZ);
    }

    // adjust points for heads
    if (machineConfiguration.getAxisU().isEnabled() && machineConfiguration.getAxisU().isHead()) {
      if (typeof getOptimizedHeads === "function") { // use post processor function to adjust heads
        startXYZ = getOptimizedHeads(startXYZ.x, startXYZ.y, startXYZ.z, startABC.x, startABC.y, startABC.z);
        endXYZ = getOptimizedHeads(endXYZ.x, endXYZ.y, endXYZ.z, endABC.x, endABC.y, endABC.z);
      } else { // guess at head adjustments
        var startDisplacement = machineConfiguration.getDirection(startABC);
        startDisplacement.multiply(headOffset);
        var endDisplacement = machineConfiguration.getDirection(endABC);
        endDisplacement.multiply(headOffset);
        startXYZ = Vector.sum(startTool, startDisplacement);
        endXYZ = Vector.sum(endTool, endDisplacement);
      }
    }
  } else { // calculate tool tip from XYZ, heads are always programmed in TCP mode, so not handled here
    startXYZ = getCurrentPosition();
    endXYZ = new Vector(_x, _y, _z);
    startTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).multiply(startXYZ);
    endTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).multiply(endXYZ);
  }

  // calculate axes movements
  moveLength.xyz = Vector.diff(endXYZ, startXYZ).abs;
  moveLength.xyzLength = moveLength.xyz.length;
  moveLength.abc = Vector.diff(endABC, startABC).abs;
  for (var i = 0; i < 3; ++i) {
    if (moveLength.abc.getCoordinate(i) > Math.PI) {
      moveLength.abc.setCoordinate(i, 2 * Math.PI - moveLength.abc.getCoordinate(i));
    }
  }
  moveLength.abcLength = moveLength.abc.length;

  // calculate radii
  moveLength.radius = getRotaryRadii(startTool, endTool, startABC, endABC);
  
  // calculate the radial portion of the tool tip movement
  var radialLength = Math.sqrt(
    Math.pow(getRadialDistance(moveLength.radius.x, startABC.x, endABC.x), 2.0) +
    Math.pow(getRadialDistance(moveLength.radius.y, startABC.y, endABC.y), 2.0) +
    Math.pow(getRadialDistance(moveLength.radius.z, startABC.z, endABC.z), 2.0)
  );
  
  // calculate the tool tip move length
  // tool tip distance is the move distance based on a combination of linear and rotary axes movement
  moveLength.tool = moveLength.xyzLength + radialLength;

  // debug
  if (false) {
    writeComment("DEBUG - tool   = " + moveLength.tool);
    writeComment("DEBUG - xyz    = " + moveLength.xyz);
    var temp = Vector.product(moveLength.abc, 180/Math.PI);
    writeComment("DEBUG - abc    = " + temp);
    writeComment("DEBUG - radius = " + moveLength.radius);
  }
  return moveLength;
}
// End of multi-axis feedrate logic

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  // controller does not handle transition between planes well
  if (((movementType == MOVEMENT_LEAD_IN) ||
       (movementType == MOVEMENT_LEAD_OUT)||
       (movementType == MOVEMENT_RAMP) ||
       (movementType == MOVEMENT_PLUNGE) ||
       (movementType == MOVEMENT_RAMP_HELIX) ||
       (movementType == MOVEMENT_RAMP_PROFILE) ||
       (movementType == MOVEMENT_RAMP_ZIG_ZAG)) &&
       (getCircularPlane() != PLANE_XY)) {
    linearize(tolerance);
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (properties.useRadius || isHelical()) { // radius mode does not support full arcs
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(17), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), feedOutput.format(feed));
      break;
    case PLANE_ZX:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(18), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
      break;
    case PLANE_YZ:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(19), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else if (!properties.useRadius) {
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(17), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), feedOutput.format(feed));
      break;
    case PLANE_ZX:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(18), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
      break;
    case PLANE_YZ:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(19), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else { // use radius mode
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      r = -r; // allow up to <360 deg arcs
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(17), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), feedOutput.format(feed));
      break;
    case PLANE_ZX:
      writeBlock(gPlaneModal.format(18), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), feedOutput.format(feed));
      break;
    case PLANE_YZ:
      writeBlock(gPlaneModal.format(19), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), feedOutput.format(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

var mapCommand = {
  //COMMAND_STOP:0,
  COMMAND_OPTIONAL_STOP:1,
  COMMAND_END:2,
  //COMMAND_SPINDLE_CLOCKWISE:3,
  //COMMAND_SPINDLE_COUNTERCLOCKWISE:4,
  //COMMAND_STOP_SPINDLE:5,
  COMMAND_ORIENTATE_SPINDLE:19,
  //COMMAND_LOAD_TOOL:6,
  //COMMAND_COOLANT_ON:8, // flood
  //COMMAND_COOLANT_OFF:9
};

function onCommand(command) 
{
	switch (command) 
	{
		case COMMAND_STOP:
			UserRetract(properties.retractOnManualNCStop, "Manual NC Stop");
			writeBlock(mFormat.format(0));
			return;

		case COMMAND_START_SPINDLE:
			onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
			return;

		case COMMAND_LOCK_MULTI_AXIS:
			return;

		case COMMAND_UNLOCK_MULTI_AXIS:
			return;

		case COMMAND_BREAK_CONTROL:
			CheckCurrentTool(tool);
			return;

		case COMMAND_TOOL_MEASURE:
			// measure the tool in the next section
			measureToolRequested = true;
			return;

		case COMMAND_SPINDLE_CLOCKWISE:
			writeComment("Spindle clockwise");
			TurnOutputOn(properties.spindleRunningChannel);
			TurnOutputOff(properties.spindleReverseChannel);
			writeBlock(spindleOutput.format(3));
			return;

		case COMMAND_SPINDLE_COUNTERCLOCKWISE:
			writeComment("Spindle anti-clockwise");
			TurnOutputOn(properties.spindleRunningChannel);
			if (properties.spindleReverseChannel == "0")
				writeBlock(spindleOutput.format(4));
			else
			{
				TurnOutputOn(properties.spindleReverseChannel);
				writeBlock(spindleOutput.format(3));
			}
			return;

		case COMMAND_STOP_SPINDLE:
			TurnOutputOff(properties.spindleRunningChannel);
			writeBlock(spindleOutput.format(5));
			return;

		case COMMAND_COOLANT_OFF:
			TurnOutputOff(properties.floodCoolingOnChannel);
			TurnOutputOff(properties.mistCoolingOnChannel);
			writeBlock(coolantOutput.format(9));
			return;
	}
  
	var stringId = getCommandStringId(command);
	var mcode = mapCommand[stringId];
	if (mcode != undefined) 
	{
		writeBlock(mFormat.format(mcode));
	} 
	else 
	{
		onUnsupportedCommand(command);
	}
}

function onSectionEnd() 
{
	writeBlock(gPlaneModal.format(17));

	if (currentSection.isMultiAxis()) 
	{
		writeBlock(gFeedModeModal.format(94)); // inverse time feed off
	}

	// process ets operations at end of section
	switch (properties.etsAfterOperation)
	{
		case "check":
			onCommand(COMMAND_BREAK_CONTROL);
			break;
			
		case "set":
			if (UseToolWithETS(tool))
			{
				SetCurrentTool(tool);
			}
			break;
	}
	
	// is it the last section with this tool
	if (((getCurrentSectionId() + 1) >= getNumberOfSections()) ||
		(tool.number != getNextSection().getTool().number)) 
	{
		if (IsLiveTool(tool))
		{
			onCommand(COMMAND_STOP_SPINDLE);
			onCommand(COMMAND_COOLANT_OFF);
		}	

		// should we check for tool breakage
		if (tool.breakControl)
			onCommand(COMMAND_BREAK_CONTROL);
	}

	forceAny();
}

function UserRetract(retractMode, reason)
{
	if (retractMode != "none")
	{
		onCommand(COMMAND_COOLANT_OFF);
		onCommand(COMMAND_STOP_SPINDLE);
		writeComment("Retracting " + reason + " - " + retractMode);
	}

		switch (retractMode)
	{
		case "none":
			break;
			
		case "g30z":
			gMotionModal.reset();
			writeBlock(gFormat.format(53), gMotionModal.format(0), (unit==MM) ? "Z[25.4 * #5183]" : "Z#5183");
			gMotionModal.reset();
			forceXYZ();
			retracted = true;
			break;

		case "g30zxy":
			gMotionModal.reset();
			writeBlock(gFormat.format(53), gMotionModal.format(0), (unit==MM) ? "Z[25.4 * #5183]" : "Z#5183");
			writeBlock(gFormat.format(53), gMotionModal.format(0), (unit==MM) ? "X[25.4 * #5181] Y[25.4 * #5182]" : "X#5181 Y#5182");
			gMotionModal.reset();
			forceXYZ();
			retracted = true;
			break;

		case "g28z":
			writeBlock(gAbsIncModal.format(91), gFormat.format(28), "Z", xyzFormat.format(0.0));
			writeBlock(gAbsIncModal.format(90));
			gMotionModal.reset();
			forceXYZ();
			retracted = true;
			break;

		case "g28zxy":
			writeBlock(gAbsIncModal.format(91), gFormat.format(28), "Z", xyzFormat.format(0.0));
			writeBlock(gAbsIncModal.format(91), gFormat.format(28), "X", xyzFormat.format(0.0), "Y", xyzFormat.format(0.0));
			writeBlock(gAbsIncModal.format(90));
			gMotionModal.reset();
			forceXYZ();
			retracted = true;
			break;
	}
}
/** Output block to do safe retract and/or move to home position. */
/*
function writeRetract() 
{
	// initialize routine
	var _xyzMoved = new Array(false, false, false);
	var _useG28 = properties.useG28; // can be either true or false
	var _useG30 = properties.useG30; // can be either true or false

	// check syntax of call
	if (arguments.length == 0) 
	{
		error(localize("No axis specified for writeRetract()."));
		return;
	}

	for (var i = 0; i < arguments.length; ++i) 
	{
		if ((arguments[i] < 0) || (arguments[i] > 2)) 
		{
			error(localize("Bad axis specified for writeRetract()."));
			return;
		}
    
		if (_xyzMoved[arguments[i]]) 
		{
			error(localize("Cannot retract the same axis twice in one line"));
			return;
		}
		_xyzMoved[arguments[i]] = true;
	}
  
	// special conditions
	if (_xyzMoved[2] && (_xyzMoved[0] || _xyzMoved[1])) 
	{ 
		// XY don't use G28
		error(localize("You cannot move home in XY & Z in the same block."));
		return;
	}
  
	if (_xyzMoved[0] != _xyzMoved[1]) 
	{
		error(localize("X & Y must be moved to home in the same block."));
		return;
	}
	if (_xyzMoved[0] || _xyzMoved[1]) 
	{
		_useG30 = false;
	}
	if (_xyzMoved[2]) 
	{
		_useG28 = false;
	}

	// define home positions
	var _xHome;
	var _yHome;
	var _zHome;
	
	if (_useG28) 
	{
		_xHome = 0;
		_yHome = 0;
		_zHome = 0;
	} 
	else 
	{
		if (properties.homePositionCenter &&
			hasParameter("part-upper-x") && hasParameter("part-lower-x")) 
		{
			_xHome = (getParameter("part-upper-x") + getParameter("part-lower-x")) / 2;
		} 
		else 
		{
			_xHome = machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : 0;
		}
    
		_yHome = machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : 0;
		_zHome = machineConfiguration.getRetractPlane();
	}

	// format home positions
	var words = []; // store all retracted axes in an array
	for (var i = 0; i < arguments.length; ++i) 
	{
		// define the axes to move
		switch (arguments[i]) 
		{
		case X:
			words.push("X" + xyzFormat.format(_xHome));
			break;
		case Y:
			words.push("Y" + xyzFormat.format(_yHome));
			break;
		case Z:
			words.push("Z" + xyzFormat.format(_zHome));
			retracted = true;
			break;
		}
	}

	// output move to home
	if (words.length > 0) 
	{
		if (_useG28) 
		{
			writeBlock(gFormat.format(28));
		} 
		else if (_useG30) 
		{
			writeComment("Retracting Z");
			writeBlock(gFormat.format(30));
		}

		// force any axes that move to home on next block
		if (_xyzMoved[0]) 
		{
			xOutput.reset();
		}
		if (_xyzMoved[1]) 
		{
			yOutput.reset();
		}
    
		if (_xyzMoved[2]) 
		{
			zOutput.reset();
		}
	}
}
*/
function onClose() 
{
	writeln("");
	writeComment("Post-amble");
	onCommand(COMMAND_COOLANT_OFF);
	onCommand(COMMAND_STOP_SPINDLE);
	onImpliedCommand(COMMAND_END);

	UserRetract(properties.retractOnProgramEnd, "after end of program");
	setWorkPlane(new Vector(0, 0, 0)); // reset working plane

	// turn off the g-code running output
	TurnOutputOff(properties.progRunningChannel);
	
	writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
	writeln("%");
}
