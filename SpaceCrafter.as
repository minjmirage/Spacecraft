package
{
	import com.greensock.*;
	import core3D.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.net.SharedObject;

	[SWF(backgroundColor="#000000", frameRate="30", width="1920", height="1080")]

	public class SpaceCrafter extends Sprite
	{
		public var debugTf:TextField = null;
		private var Assets:Object = null;
		private var Mtls:Object = null;

		private var Projectiles:Vector.<Projectile> = null;
		private var Entities:Vector.<Hull> = null;
		private var DropItems:Vector.<DropItem> = null;
		private var Hostiles:Vector.<Hull> = null;
		private var Friendlies:Vector.<Hull> = null;
		private var Exploding:Vector.<Ship> = null;

		private var frameS_MP:MeshParticles = null;		// small turret frames MeshParticles
		private var frameM_MP:MeshParticles = null;		// medium turret frames MeshParticles
		private var TurretMPs:Object = null;			// Turrets MeshParticles
		private var EffectMPs:Object = null;			// Bullets MeshParticles
		private var EffectEMs:Object = null;			// effects ParticleEmitters
		private var BulletFXs:Object = null;			// projectile rendering Fns
		private var SoundFxs:Object = null;				// dictionary of all SoundFxs
		private var SndsToPlay:Object = null;
		private var ambientLoop:SoundChannel = null;

		private var world:Mesh = null;
		private var sky:Mesh = null;

		private var focusedEntity:Hull = null;
		private var focusedShip:Ship = null;
		private var optionsMenuSelector:Function = null;

		private var mainTitle:Bitmap = null;
		private var subTitle:Bitmap = null;
		private var optionsMenu:Sprite = null;
		private var shipHUD:Sprite = null;

		private var buildMkr:Mesh = null;

		private var lookPt:Vector3D = null;		// camera lookAt point
		private var lookVel:Vector3D = null;	// camera lookAt point velocity
		private var lookDBER:Vector3D = null;	// Dist,Bearing,Elevation,Roll
		private var velDBER:Vector3D = null;	// Dist,Bearing,Elevation,Roll

		private var gameTime:uint=0;
		private var simulationPaused:Boolean = false;

		public var stepFns:Vector.<Function> = null;

		private var undoStk:Vector.<String> = null;

		private var prevLookDBER:Vector3D = null;			// to restore back previous view
		private var gridMesh:Mesh = null;
		private var viewStep:Function = shipViewStep;

		private var userData:UserData = null;

		[Embed(source="3D/textures/tex.jpg")] 					private static var Tex:Class;
		[Embed(source="3D/textures/TexPanel.jpg")] 			private static var TexPanel:Class;
		[Embed(source="3D/textures/TexTransPanel.png")] private static var TexTransPanel:Class;
		[Embed(source="3D/textures/SpecPanel.jpg")] 		private static var SpecPanel:Class;
		[Embed(source="3D/textures/halo.png")] 					private static var TexHalo:Class;

		[Embed(source="3D/textures/texRocks.jpg")] 			private static var TexRocks:Class;
		[Embed(source="3D/textures/specRocks.jpg")] 		private static var SpecRocks:Class;
		[Embed(source="3D/textures/normRocks.jpg")] 		private static var NormRocks:Class;

		[Embed(source="3D/textures/TexSpace1.jpg")] 		private static var TexSpace1:Class;
		[Embed(source="3D/textures/TexSpace2.jpg")] 		private static var TexSpace2:Class;
		[Embed(source="3D/textures/TexSpace3.jpg")] 		private static var TexSpace3:Class;
		[Embed(source="3D/textures/TexSpace4.jpg")] 		private static var TexSpace4:Class;
		[Embed(source="3D/textures/TexSpace5.jpg")] 		private static var TexSpace5:Class;

		[Embed(source="3D/textures/TexPlanets.jpg")] 		private static var TexPlanets:Class;
		[Embed(source="3D/textures/smoke3.png")] 				private static var TexSmoke3:Class;
		[Embed(source="3D/textures/flareWhite.jpg")] 			private static var TexFlareWhite:Class;
		[Embed(source="3D/textures/flareYellow.jpg")] 		private static var TexFlareYellow:Class;
		[Embed(source="3D/textures/flareRed.jpg")]	 			private static var TexFlareRed:Class;
		[Embed(source="3D/textures/thrustGradient.png")]	private static var TexThrustGradient:Class;
		[Embed(source="3D/textures/linearGradient.png")]	private static var TexLinearGradient:Class;
		[Embed(source="3D/textures/reticleR.png")]				private static var TexReticleR:Class;

		[Embed(source="3D/textures/FxBitsSheet.png")] 		private static var FxBitsSheet:Class;
		[Embed(source="3D/textures/FxBlastSheet.png")] 		private static var FxBlastSheet:Class;
		[Embed(source="3D/textures/FxFlashSheet.png")] 		private static var FxFlashSheet:Class;
		[Embed(source="3D/textures/FxRingsSheet.png")] 		private static var FxRingsSheet:Class;
		[Embed(source="3D/textures/FxThrustSheet.png")] 	private static var FxThrustSheet:Class;
		[Embed(source="3D/textures/FxTrailSheet.png")] 		private static var FxTrailSheet:Class;
		[Embed(source="3D/textures/FxSparksSheet.png")] 	private static var FxSparksSheet:Class;
		[Embed(source="3D/textures/FxWaveSheet.png")] 		private static var FxWaveSheet:Class;
		[Embed(source="3D/textures/FxHyperSheet.jpg")] 		private static var FxHyperSheet:Class;

		[Embed(source="icons/icoTick.png")] 		private static var icoTick:Class;
		[Embed(source="icons/icoCross.png")] 		private static var icoCross:Class;
		[Embed(source="icons/icoUndo.png")] 		private static var icoUndo:Class;

		[Embed(source='3D/shipsWheel.rmf', mimeType='application/octet-stream')] 			private static var ShipsWheel_Rmf:Class;
		[Embed(source='3D/RawM.rmf', mimeType='application/octet-stream')] 						private static var RawM_Rmf:Class;
		[Embed(source='3D/RawR.rmf', mimeType='application/octet-stream')] 						private static var RawR_Rmf:Class;
		[Embed(source='3D/RawT.rmf', mimeType='application/octet-stream')] 						private static var RawT_Rmf:Class;
		[Embed(source='3D/hullPosnMkr.rmf', mimeType='application/octet-stream')] 		private static var HullPosnMkr_Rmf:Class;

		[Embed(source='3D/thrusterSmallExt.rmf', mimeType='application/octet-stream')] 	private static var ThrusterExtS_Rmf:Class;
		[Embed(source='3D/launcherSmallExt.rmf', mimeType='application/octet-stream')] 	private static var LauncherExtS_Rmf:Class;
		[Embed(source='3D/mountSmallExt.rmf', mimeType='application/octet-stream')] 		private static var MountExtS_Rmf:Class;
		[Embed(source='3D/mountMediumExt.rmf', mimeType='application/octet-stream')] 		private static var MountExtM_Rmf:Class;

		[Embed(source='3D/thrusterSmall.rmf', mimeType='application/octet-stream')] 	private static var ThrusterS_Rmf:Class;
		[Embed(source='3D/tractorSmall.rmf', mimeType='application/octet-stream')] 		private static var TractorS_Rmf:Class;
		[Embed(source='3D/missileSmall.rmf', mimeType='application/octet-stream')] 		private static var MissileS_Rmf:Class;
		[Embed(source='3D/launcherSmall.rmf', mimeType='application/octet-stream')] 	private static var LauncherS_Rmf:Class;
		[Embed(source='3D/mountSmall.rmf', mimeType='application/octet-stream')] 			private static var MountS_Rmf:Class;
		[Embed(source='3D/frameSmall.rmf', mimeType='application/octet-stream')] 			private static var FrameS_Rmf:Class;
		[Embed(source='3D/mountMedium.rmf', mimeType='application/octet-stream')] 		private static var MountM_Rmf:Class;
		[Embed(source='3D/frameMedium.rmf', mimeType='application/octet-stream')] 		private static var FrameM_Rmf:Class;
		[Embed(source='3D/gunAutoSmall.rmf', mimeType='application/octet-stream')] 		private static var GunAutoS_Rmf:Class;
		[Embed(source='3D/gunFlakSmall.rmf', mimeType='application/octet-stream')] 		private static var GunFlakS_Rmf:Class;
		[Embed(source='3D/gunIonSmall.rmf', mimeType='application/octet-stream')] 		private static var GunIonS_Rmf:Class;
		[Embed(source='3D/gunPlasmaSmall.rmf', mimeType='application/octet-stream')] 	private static var GunPlasmaS_Rmf:Class;
		[Embed(source='3D/gunRailSmall.rmf', mimeType='application/octet-stream')] 		private static var GunRailS_Rmf:Class;
		[Embed(source='3D/railGunMedium.rmf', mimeType='application/octet-stream')] 	private static var RailGunM_Rmf:Class;
		[Embed(source='3D/blasterMedium.rmf', mimeType='application/octet-stream')] 	private static var BlasterM_Rmf:Class;
		[Embed(source='3D/laserMedium.rmf', mimeType='application/octet-stream')] 		private static var LaserM_Rmf:Class;

		[Embed(source="snds/jumpIn.mp3")] 				private var sndJumpIn:Class;
		[Embed(source="snds/hit.mp3")] 						private var sndHit:Class;
		[Embed(source="snds/explosion.mp3")] 			private var sndExplosion:Class;
		[Embed(source="snds/gunAutoS.mp3")] 			private var sndGunAutoS:Class;
		[Embed(source="snds/gunFlakS.mp3")] 			private var sndGunFlakS:Class;
		[Embed(source="snds/gunIonS.mp3")] 				private var sndGunIonS:Class;
		[Embed(source="snds/gunPlasmaS.mp3")]			private var sndGunPlasmaS:Class;
		[Embed(source="snds/missileLaunch.mp3")] 	private var sndLauncherS:Class;
		[Embed(source="snds/gunRailS.mp3")]				private var sndGunRailS:Class;
		[Embed(source="snds/gunIonM.mp3")] 				private var sndGunIonM:Class;
		[Embed(source="snds/gunPlasmaM.mp3")] 		private var sndGunPlasmaM:Class;
		[Embed(source="snds/gunRailM.mp3")] 			private var sndGunRailM:Class;
		[Embed(source="snds/hullGroan1.mp3")] 		private var sndHullGroan1:Class;
		[Embed(source="snds/hullGroan2.mp3")] 		private var sndHullGroan2:Class;
		[Embed(source="snds/menuClick.mp3")] 			private var sndMenuClick:Class;
		[Embed(source="snds/zoomOut.mp3")] 				private var sndZoomOut:Class;
		[Embed(source="snds/spaceAmbience.mp3")] 	private var sndSpaceAmbience:Class;
		[Embed(source="snds/spaceshipHum.mp3")] 	private var sndSpaceshipHum:Class;

		//===============================================================================================
		// Constructor
		//===============================================================================================
		public function SpaceCrafter() : void
		{
			var ppp:Sprite = this;

			function initHandler(ev:Event) : void
			{
				if (stage==null) return;

				var readout:TextField = Mesh.createFPSReadout();

				stage.addChild(readout);
				debugTf = new TextField();
				debugTf.defaultTextFormat = new TextFormat("arial",13,0xFFFFFF);
				debugTf.autoSize = "left";
				debugTf.wordWrap = false;
				stage.addChild(debugTf);
				debugTf.x = 600;

				ppp.removeEventListener(Event.ENTER_FRAME,initHandler);
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;

				init();
			}
			ppp.addEventListener(Event.ENTER_FRAME,initHandler);
		}//endfunction

		//===============================================================================================
		// convenience tool to convert obj to rmf files
		//===============================================================================================
		public function convToRmf(A:Array,callBack:Function=null) : void
		{
			var idx:int=0;
			function loadNext(e:Event=null):void
			{
				Mesh.loadObj(A[idx],function(m:Mesh):void
				{
					var saveFileN:String = A[idx++].split(".obj")[0].split("/").pop();
					m.saveAsRmf(saveFileN);
					if (idx>=A.length)
					{
						stage.removeEventListener(MouseEvent.CLICK,loadNext);
						stage.removeChild(Mesh.debugTf);
						if (callBack!=null)
							callBack();
					}
				});
				stage.addChild(Mesh.debugTf);
			}
			stage.addEventListener(MouseEvent.CLICK,loadNext);

			loadNext();
		}//endfunction

		//===============================================================================================
		// Initialize Game Stuffs
		//===============================================================================================
		private function init() : void
		{
			lookPt = new Vector3D(0,0,0);
			lookVel = new Vector3D(0,0,0);
			lookDBER = new Vector3D(7,0,0,0);
			velDBER = new Vector3D(0,0,0,0);

			world = new Mesh();

			// ----- initialize 3D model assets
			Assets = { shipsWheel:ShipsWheel_Rmf,RawM:RawM_Rmf,RawR:RawR_Rmf,RawT:RawT_Rmf,
						buildMkr:HullPosnMkr_Rmf,
						thrusterSExt:ThrusterExtS_Rmf,launcherSExt:LauncherExtS_Rmf,mountSExt:MountExtS_Rmf, mountMExt:MountExtM_Rmf,
						thrusterS:ThrusterS_Rmf,tractorS:TractorS_Rmf,missileS:MissileS_Rmf,launcherS:LauncherS_Rmf,
						mountS:MountS_Rmf, frameS:FrameS_Rmf, mountM:MountM_Rmf, frameM:FrameM_Rmf,
						gunAutoS:GunAutoS_Rmf, gunFlakS:GunFlakS_Rmf, gunIonS:GunIonS_Rmf, gunPlasmaS:GunPlasmaS_Rmf, gunRailS:GunRailS_Rmf,
						gunIonM:BlasterM_Rmf, gunPlasmaM:LaserM_Rmf, gunRailM:RailGunM_Rmf };
			Mtls = {Tex:new Tex().bitmapData, TexPanel:new TexPanel().bitmapData, SpecPanel:new SpecPanel().bitmapData,
							TexRocks:new TexRocks().bitmapData, SpecRocks:new SpecRocks().bitmapData, NormRocks:new NormRocks().bitmapData,
							TexWhiteGradient:new TexLinearGradient().bitmapData,
							TexThrustGradient:new TexThrustGradient().bitmapData,
							TexTrans:new TexTransPanel().bitmapData,
							TexPlanets:new TexPlanets().bitmapData,
							TexSpace1:fadeVertEnds(new TexSpace1().bitmapData),
							TexSpace2:fadeVertEnds(new TexSpace2().bitmapData),
							TexSpace3:fadeVertEnds(new TexSpace3().bitmapData),
							TexSpace4:fadeVertEnds(new TexSpace4().bitmapData),
							TexSpace5:fadeVertEnds(new TexSpace5().bitmapData)};
			var tex:BitmapData = Mtls["Tex"];
			for (var id:String in Assets)
			{
				Assets[id] = Mesh.parseRmfToMesh(new Assets[id]());
				Assets[id].material.setTexMap(tex);
				Assets[id].material.setSpecular(0);
			}
			Assets["shipsWheel"].setLightingParameters(1,1,1,1);
			ShipHUD.init(stage,world,Assets["shipsWheel"]);

			// ----- initialize turrets particles
			frameS_MP = new MeshParticles(Assets['frameS']);
			frameM_MP = new MeshParticles(Assets['frameM']);
			TurretMPs ={tractorS:new MeshParticles(Assets['tractorS']),
						gunAutoS:new MeshParticles(Assets['gunAutoS']),
						gunFlakS:new MeshParticles(Assets['gunFlakS']),
						gunIonS:new MeshParticles(Assets['gunIonS']),
						gunPlasmaS:new MeshParticles(Assets['gunPlasmaS']),
						gunRailS:new MeshParticles(Assets['gunRailS']),
						gunRailM:new MeshParticles(Assets['gunRailM']),
						gunIonM:new MeshParticles(Assets['gunIonM']),
						gunPlasmaM:new MeshParticles(Assets['gunPlasmaM'])};

			world.addChild(frameS_MP.skin);
			world.addChild(frameM_MP.skin);
			for (var key:String in TurretMPs)	world.addChild(TurretMPs[key].skin);

			// ----- initialize mesh particles
			EffectMPs = new Object();
			EffectMPs["missileS"] = new MeshParticles(Assets["missileS"]);
			EffectMPs["gunAutoS"] = new MeshParticles(Mesh.createStreak(0.3, 0.03, new BitmapData(1, 1, false, 0x88FF88)));
			EffectMPs["gunFlakS"] = new MeshParticles(Mesh.createSphere(0.05, 8, 4, new BitmapData(1, 1, false, 0x88FF88)));
			EffectMPs["gunRailS"] = new MeshParticles(Mesh.createStreak(0.2, 0.07, new BitmapData(1, 1, false, 0xFFFFCC)));
			EffectMPs["gunRailM"] = new MeshParticles(Mesh.createStreak(0.4, 0.14, new BitmapData(1, 1, false, 0xFFFFCC)));
			var grad:BitmapData = Mtls["TexThrustGradient"];
			EffectMPs["thrustConeW"] = new MeshParticles(createLightCone(0.09,0.45,0,0.8,grad));
			EffectMPs["thrustConeM"] = new MeshParticles(createLightCone(0.07,0.35,0,1.1,grad));
			EffectMPs["thrustConeN"] = new MeshParticles(createLightCone(0.05,0.22,0,1.4,grad));
			for (key in EffectMPs)
			{
				(MeshParticles)(EffectMPs[key]).skin.setLightingParameters(1,1,1,0,0,false);
				(MeshParticles)(EffectMPs[key]).skin.material.setBlendMode("add");
				(MeshParticles)(EffectMPs[key]).skin.depthWrite = false;
				world.addChild(EffectMPs[key].skin);
			}

			//(MeshParticles)(EffectMPs["missileS"]).skin.material.setBlendMode("normal");
			EffectMPs["RawM"] = new MeshParticles(Assets["RawM"]); (MeshParticles)(EffectMPs["RawM"]).skin.setLightingParameters(1,1,1,0,0,false); world.addChild(EffectMPs["RawM"].skin);
			EffectMPs["RawR"] = new MeshParticles(Assets["RawR"]); (MeshParticles)(EffectMPs["RawR"]).skin.setLightingParameters(1,1,1,0,0,false); world.addChild(EffectMPs["RawR"].skin);
			EffectMPs["RawT"] = new MeshParticles(Assets["RawT"]); (MeshParticles)(EffectMPs["RawT"]).skin.setLightingParameters(1,1,1,0,0,false); world.addChild(EffectMPs["RawT"].skin);

			// ---- initialize effects emitters
			EffectEMs ={
						smoke3:new ParticlesEmitter(new TexSmoke3().bitmapData,1,10,"add"),
						flareWhite:new ParticlesEmitter(new TexFlareWhite().bitmapData,1,1,"add"),
						flareYellow:new ParticlesEmitter(new TexFlareYellow().bitmapData,1,1,"add"),
						flareRed:new ParticlesEmitter(new TexFlareRed().bitmapData,1,1,"add"),
						halo:new ParticlesEmitter(new TexHalo().bitmapData,1,1,"add"),
						hyperCharge:new ParticlesEmitter(new FxThrustSheet().bitmapData,25,4,"add"),
						missileTrail:new ParticlesEmitter(new FxTrailSheet().bitmapData,25,2,"add"),
						sparks:new ParticlesEmitter(new FxSparksSheet().bitmapData,16,0.5,"add"),
						flash:new ParticlesEmitter(new FxFlashSheet().bitmapData,9,5,"add"),
						ring:new ParticlesEmitter(new FxRingsSheet().bitmapData,25,2,"add"),
						bit:new ParticlesEmitter(new FxBitsSheet().bitmapData, 25, 1),
						blast:new ParticlesEmitter(new FxBlastSheet().bitmapData, 25, 10,"add"),
						wave:new ParticlesEmitter(new FxWaveSheet().bitmapData, 25, 100,"add"),
						hyperspace:new ParticlesEmitter(new FxHyperSheet().bitmapData, 16, 100, "add"),
						reticle:new ParticlesEmitter(new TexReticleR().bitmapData, 1, 3, "add")};
			for (key in EffectEMs)
				world.addChild(EffectEMs[key].skin);

			var rv:Vector3D = new Vector3D();

			// ----- initialize projectile FXs
			BulletFXs = new Object();
			BulletFXs["launcherS"] = function(p:Projectile):void
			{
				(MeshParticles)(EffectMPs["missileS"]).nextLocDirScale(p.px,p.py,p.pz,p.vx,p.vy,p.vz,1);
				(ParticlesEmitter)(EffectEMs["missileTrail"]).emit(p.px,p.py,p.pz,0,0,0,0.65);
			};
			BulletFXs["gunAutoS"] = function(p:Projectile):void
			{
				(MeshParticles)(EffectMPs["gunAutoS"]).nextLocDirScale(p.px,p.py,p.pz,p.vx,p.vy,p.vz,1);
			};
			BulletFXs["gunFlakS"] = function(p:Projectile):void
			{
				(MeshParticles)(EffectMPs["gunFlakS"]).nextLocDirScale(p.px,p.py,p.pz,p.vx,p.vy,p.vz,1);
				randV3values(0.01,rv); (ParticlesEmitter)(EffectEMs["bit"]).emit(p.px,p.py,p.pz,rv.x,rv.y,rv.z,1);
			};
			BulletFXs["gunIonS"] = function(p:Projectile):void
			{
				(ParticlesEmitter)(EffectEMs["flareRed"]).emit(p.px,p.py,p.pz,0,0,0,0.5+Math.sin(p.ttl)*0.05);
				randV3values(0.01,rv); (ParticlesEmitter)(EffectEMs["bit"]).emit(p.px+rv.x,p.py+rv.y,p.pz+rv.z,rv.x,rv.y,rv.z,1);
			};
			BulletFXs["gunPlasmaS"] = function(p:Projectile):void
			{
				(ParticlesEmitter)(EffectEMs["flareYellow"]).emit(p.px,p.py,p.pz,0,0,0,0.5+Math.sin(p.ttl)*0.05);
				randV3values(0.02,rv); (ParticlesEmitter)(EffectEMs["flash"]).emit(p.px+rv.x*6+p.vx,p.py+rv.y*6+p.vy,p.pz+rv.z*6+p.vz,-rv.x,-rv.y,-rv.z,0.2);
				randV3values(0.02,rv); (ParticlesEmitter)(EffectEMs["flash"]).emit(p.px+rv.x*6+p.vx,p.py+rv.y*6+p.vy,p.pz+rv.z*6+p.vz,-rv.x,-rv.y,-rv.z,0.2);
			};
			BulletFXs["gunRailS"] = function(p:Projectile):void
			{
				(MeshParticles)(EffectMPs["gunRailS"]).nextLocDirScale(p.px,p.py,p.pz,p.vx,p.vy,p.vz,1);
				(ParticlesEmitter)(EffectEMs["halo"]).emit(p.px,p.py,p.pz,0,0,0,0.6);
				(ParticlesEmitter)(EffectEMs["ring"]).emit(p.px,p.py,p.pz,0,0,0,0.5);
			};
			BulletFXs["gunIonM"] = function(p:Projectile):void
			{
				(ParticlesEmitter)(EffectEMs["flareRed"]).emit(p.px,p.py,p.pz,0,0,0,0.8+Math.sin(p.ttl)*0.08);
				randV3values(0.03,rv); (ParticlesEmitter)(EffectEMs["bit"]).emit(p.px+rv.x,p.py+rv.y,p.pz+rv.z,rv.x,rv.y,rv.z,1);
				randV3values(0.03,rv); (ParticlesEmitter)(EffectEMs["bit"]).emit(p.px+rv.x,p.py+rv.y,p.pz+rv.z,rv.x,rv.y,rv.z,1);
			};
			BulletFXs["gunPlasmaM"] = function(p:Projectile):void
			{
				(ParticlesEmitter)(EffectEMs["flareWhite"]).emit(p.px,p.py,p.pz,0,0,0,0.8+Math.sin(p.ttl)*0.08);
				randV3values(0.04,rv); (ParticlesEmitter)(EffectEMs["flash"]).emit(p.px+rv.x*6,p.py+rv.y*6,p.pz+rv.z*6,-rv.x,-rv.y,-rv.z,0.3);
				randV3values(0.04,rv); (ParticlesEmitter)(EffectEMs["flash"]).emit(p.px+rv.x*6,p.py+rv.y*6,p.pz+rv.z*6,-rv.x,-rv.y,-rv.z,0.3);
				randV3values(0.04,rv); (ParticlesEmitter)(EffectEMs["flash"]).emit(p.px+rv.x*6,p.py+rv.y*6,p.pz+rv.z*6,-rv.x,-rv.y,-rv.z,0.3);
			};
			BulletFXs["gunRailM"] = function(p:Projectile):void
			{
				(MeshParticles)(EffectMPs["gunRailM"]).nextLocDirScale(p.px,p.py,p.pz,p.vx,p.vy,p.vz,1);
				(ParticlesEmitter)(EffectEMs["halo"]).emit(p.px,p.py,p.pz,0,0,0,0.9);
				(ParticlesEmitter)(EffectEMs["ring"]).emit(p.px,p.py,p.pz,0,0,0,0.8);
			};

			// ----- initialize sounds
			SoundFxs = {jumpIn:new sndJumpIn(),jumpIn_Af:0.3,
									hit:new sndHit(),hit_Af:1,
									explosion:new sndExplosion(),explosion_Af:0.3,
									gunAutoS:new sndGunAutoS(),gunAutoS_Af:1,
									gunFlakS:new sndGunFlakS(),gunFlakS_Af:1,
									gunIonS:new sndGunIonS(),gunIonS_Af:1,
									gunPlasmaS:new sndGunPlasmaS(),gunPlasmaS_Af:1,
									gunRailS:new sndGunRailS(),gunRailS_Af:1,
									launcherS:new sndLauncherS(),launcherS_Af:1,
									gunIonM:new sndGunIonM(),gunIonM_Af:0.6,
									gunPlasmaM:new sndGunPlasmaM(),gunPlasmaM_Af:0.6,
									gunRailM:new sndGunRailM(),gunRailM_Af:0.6,
									hullGroan1:new sndHullGroan1(),hullGroan1_Af:0.6,
									hullGroan2:new sndHullGroan1(),hullGroan2_Af:0.6,
									menuClick:new sndMenuClick(),menuClick_Af:0.2,
									zoomOut:new sndZoomOut(),zoomOut_Af:0.2,
									spaceAmbience:new sndSpaceAmbience(),spaceAmbience_Af:0.001,
									spaceshipHum:new sndSpaceshipHum(),spaceshipHum_Af:0.001
								};
			SndsToPlay = new Object();
			MenuUI.clickSfx = function():void {playSound(lookPt.x,lookPt.y,lookPt.z,"menuClick");};

			buildMkr = Assets["buildMkr"];
			buildMkr.setLightingParameters(1,1,1,0,0,false);

			// ----- create the top down tactical grid
			gridMesh = new Mesh();
			var gridTex:BitmapData = new BitmapData(1,1,true,0x99FFFFFF);
			var crossH:Mesh = Mesh.createPlane(1,0.05,gridTex);
			var crossV:Mesh = Mesh.createPlane(0.05,1,gridTex);
			var cross:Mesh = new Mesh();
			crossH.transform = new Matrix4x4().rotX(Math.PI/2);
			crossV.transform = new Matrix4x4().rotX(Math.PI/2);
			cross.addChild(crossH);
			cross.addChild(crossV);
			cross = cross.mergeTree();
			for (var gx:int=-10; gx<=10; gx++)
				for (var gz:int=-10; gz<=10; gz++)
				{
					cross = cross.clone();
					cross.transform = new Matrix4x4().translate(gx*10,0,gz*10);
					gridMesh.addChild(cross);
				}
			gridMesh = gridMesh.mergeTree();
			gridMesh.material.setSpecular(0);
			gridMesh.material.setAmbient(1,1,1);

			Projectiles = new Vector.<Projectile>();
			DropItems = new Vector.<DropItem>();
			Entities = new Vector.<Hull>();
			Hostiles = new Vector.<Hull>();
			Friendlies = new Vector.<Hull>();
			Exploding = new Vector.<Ship>();
			stepFns = new Vector.<Function>();

			undoStk = new Vector.<String>();

			stage.addEventListener(Event.ENTER_FRAME,worldStep);
			stage.addEventListener(Event.DEACTIVATE, deactivateHandler);
			stage.addEventListener(Event.ACTIVATE, activateHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			Input.init(stage);

			playAmbientLoop("spaceAmbience",1);
			userData = UserData.loadDataFromLocalObject();
			homeBaseScene(userData.shipsConfig);
		}//endfunction

		//===============================================================================================
		// shows your Level, your ships, option to build/modify Resource Units
		//===============================================================================================
		private function homeBaseScene(shipsConfig:Vector.<String>):void
		{
			if (sky!=null) world.removeChild(sky);
			randScenery();
			randAsteroids(10);

			// ----- load user ships
			if (shipsConfig.length>0)
			{
					for (var i:int=shipsConfig.length-1; i>-1; i--)
						addShipToScene(true,0,shipsConfig[i]);		// adds user configured ship to scene
			}
			else
			{
				addShipToScene(true,0);			// creates a new random ship for user
				userData.saveShipsData(Friendlies);
			}

			optionsMenuSelector = function(entity:Hull):void
			{
				if (entity is Ship)
					showShipMainMenu();
				else if (entity is Asteroid)
					showAsteroidMineMenu();
			}

			focusAndRotateAround(Friendlies[0]);
		}//endfunction

		//===============================================================================================
		// NEED TO REFINE!!!
		//===============================================================================================
		private function battleScene(shipsConfig:Vector.<String>):void
		{
			var thisRef:SpaceCrafter = this;
			randScenery();	// random sky and planets

			optionsMenuSelector = function(entity:Hull):void
			{
				if (Friendlies.length==0 || Hostiles.length==0)
					return;
				else if (entity is Ship && Friendlies.indexOf((Ship)(entity))!=-1)
					optionsMenu =
					MenuUI.createLeftStyleMenu(thisRef,
																		new < String > ["Escape Battle"],
																		new < Function>[function():void
																		{
																			var jumpBearing:Number = Math.random()*Math.PI*2;
																			for (var i:int=0; i<Friendlies.length; i++)
																				jumpOut((Ship)(Friendlies[i]),jumpBearing);
																		}]);
				else
					optionsMenu =
					MenuUI.createLeftStyleMenu(thisRef,
																		new < String > ["Back"],
																		new < Function>[function():void	{focusOn(Friendlies[0]);}]);
				optionsMenu.y = subTitle.y+subTitle.height;
			}//endfunction

			// ----- default enemies
			for (var i:int=4; i>-1; i--)
				addShipToScene(false);	// hostile

			// ----- focus to each hostile ship
			var hFocusCnt:int=0;
			function hFocusNext():void
			{
				if (hFocusCnt>=Hostiles.length)
					jumpInPlayerShip();	// jump in friendly ship
				else
				{
					Hostiles[hFocusCnt].engageEnemy = false;		// prevent attack at jump in
					focusAndRotateAround(Hostiles[hFocusCnt++],hFocusNext,90);
				}
			}//endfunction
			hFocusNext();

			// ----- face ship jump in direction
			function jumpInPlayerShip():void
			{
				var slowF:Number = 0.9;
				lookVel = new Vector3D((0-lookPt.x)*(1-slowF),(0-lookPt.y)*(1-slowF),(-1-lookPt.z)*(1-slowF));
				velDBER.x = (10-lookDBER.x)*(1-slowF);								// set dist to 8
				lookDBER.y = Math.PI;
				velDBER.y = 0;

				// ----- align view to ship fn
				var alignViewToShip:Function = function():void
				{
					var shp:Ship = (Ship)(Friendlies[0]);
					var sinB:Number = Math.sin(lookDBER.y);
					var cosB:Number = Math.cos(lookDBER.y);
					var facing:Vector3D = shp.getFacing();
					var bDiff:Number = Math.acos(Math.max(-1,Math.min(1,facing.x*sinB + facing.z*cosB)));
					if (facing.x*cosB - facing.z*sinB<0)
						bDiff *=-1;			// bDiff is the difference in bearing
					var bearingCorrection:Number = Math.max(-0.002,Math.min(0.002,bDiff*(1-0.9)-velDBER.y));
					velDBER.y += bearingCorrection;
					if (Input.downPts.length>0 && stepFns.indexOf(alignViewToShip)!=-1)
						stepFns.splice(stepFns.indexOf(alignViewToShip),1);
				}//endfunction

				shipsConfig = shipsConfig.slice();
				var jumpInTime:int = 0;
				var friendlySpawn:Function = function():void
				{
					if (shipsConfig.length>0)
					{
						if (jumpInTime%100==40)
							mainTitle.name = "ETA 2s";
						else if (jumpInTime%100==70)
							mainTitle.name = "ETA 1s";
						else if (jumpInTime%100==0)
						{
							addShipToScene(true,0,shipsConfig.pop());		// friendly
							jumpIn((Ship)(Friendlies[0]),0,0,0,function():void {stepFns.push(alignViewToShip);});
							focusOn(Friendlies[0]);
							(Ship)(Friendlies[0]).engageEnemy = false;
							stepFns.push(battleStep);
							delayedCall(function():void
							{
								var shp:Ship = null;
								for each (shp in Friendlies)	shp.engageEnemy = true;
								for each (shp in Hostiles)	shp.engageEnemy = true;
							},150);
						}
					}
					else
						stepFns.splice(stepFns.indexOf(friendlySpawn),1);
				};
				stepFns.push(friendlySpawn);
			}//endfunction

			function battleStep():void
			{
				if (Exploding.length==0 &&
						(Friendlies.length==0 || Hostiles.length==0))
				{
					stepFns.splice(stepFns.indexOf(battleStep),1);
					var title:String = "Defeat";
					if (Friendlies.length>0)	title = "Victory";
					MenuUI.createSummaryScreen(thisRef,title,
							new <String>["% Hostile Fleet Destroyed","% Friendly Fleet Destroyed","Resources Gained","Tech Gained"],
							new <int>[54,88,34,223],
							function():void {
								galaxyScene(homeBaseScene);
							});
					if (optionsMenu.parent!=null)
						optionsMenu.parent.removeChild(optionsMenu);
				}
			};
		}//endfunction

		//===============================================================================================
		// convenience function to callback after specified frames delay
		//===============================================================================================
		private function delayedCall(callBack:Function,delay:int=1):void
		{
			function delayCall():void
			{
				if (delay<=0)
				{
					if (callBack!=null)	callBack();
					stepFns.splice(stepFns.indexOf(delayCall),1);
				}
				else
					delay--;
			}//endfunction
			stepFns.push(delayCall);
		}//endfunction

		//===============================================================================================
		// zoom out to galaxy find opponents screen
		//===============================================================================================
		private function galaxyScene(callBack:Function=null):void
		{
			mainTitle.name = "Scanning...";
			subTitle.name = "Detecting other fleet signatures";

			if (optionsMenu!=null && optionsMenu.parent!=null)
				optionsMenu.parent.removeChild(optionsMenu);

			playSound(lookPt.x,lookPt.y,lookPt.z,"zoomOut");
			world.removeChild(sky);

			// ----- remove all ships and HUD
			focusOn(null);
			while (Entities.length>0)
			{
				var entity:Hull = Entities.pop();
				world.removeChild(entity.skin);
			}
			while (Exploding.length>0)
			{
				var expl:Ship = Exploding.pop();
				world.removeChild(expl.skin);
			}
			while (Hostiles.length>0)		Hostiles.pop();
			while (Friendlies.length>0)	Friendlies.pop();
			while (DropItems.length>0)	DropItems.pop();
			while (Projectiles.length>0)	Projectiles.pop();

			var oldViewStep:Function = viewStep;

			// ----- precalculate galaxy spiral stars posns
			var S3:Vector.<Vector3D> = new Vector.<Vector3D>();
			var FW:Vector.<Vector3D> = new Vector.<Vector3D>();
			var FY:Vector.<Vector3D> = new Vector.<Vector3D>();
			var FR:Vector.<Vector3D> = new Vector.<Vector3D>();
			var SinA:Vector.<Number> = new Vector.<Number>();
			var CosA:Vector.<Number> = new Vector.<Number>();
			var w:Number = 50;
			var rotDiv:Number = 3000;
			var i:int=0;
			var j:int=0;
			var len:Number = 0;
			for (i=0; i<rotDiv; i++)
			{	// (len,yoff,ang,scale)
				SinA.push(Math.sin(i/rotDiv*Math.PI*2));
				CosA.push(Math.cos(i/rotDiv*Math.PI*2));
			}
			for (i=0; i<600; i++)	// (len,yoff,ang,scale)
			{
				len = Math.sqrt(Math.random())*w;
				S3.push(new Vector3D(len,(Math.random()-0.5)*0.01*w,probFn(len*90),(1-len/(w*2))*(Math.random()*0.2+0.8)));
				len = Math.sqrt(Math.random())*w;
				FW.push(new Vector3D(len,(Math.random()-0.5)*0.01*w,probFn(len*90),(1-len/w)*(Math.random()*0.2+0.6)));
				len = (Math.random()*w+Math.sqrt(Math.random())*w)/2;
				FY.push(new Vector3D(len,(Math.random()-0.5)*0.01*w,probFn(len*90),(1-len/w)*(Math.random()*0.2+0.8)));
				len = Math.sqrt(Math.random())*w;
				FR.push(new Vector3D(len,(Math.random()-0.5)*0.01*w,probFn(len*90),(1-len/w)*(Math.random()*0.2+0.8)));
			}
			function probFn(addR:Number):int	// provides the galaxy arms prob distribution
			{
				var r:Number = Math.random();
				r = r*r*r*rotDiv/4;
				if (Math.random()<0.5)
					r *= -1;
				r += rotDiv/4;
				if (Math.random()>0.5)
					r+=rotDiv/2;
				r=(r+addR)%rotDiv;
				return Math.floor(rotDiv-r);
			}

			var targStar:Vector3D = null;	 //for the reticle
			var retAge:int=0;
			var retS:Sprite = new Sprite();
			addChild(retS);

			// ----- draws a spiral galaxy
			function galaxyStep():void
			{
				var smoke3Em:ParticlesEmitter = EffectEMs["smoke3"];
				var flareWEm:ParticlesEmitter = EffectEMs["flareWhite"];
				var flareYEm:ParticlesEmitter = EffectEMs["flareYellow"];
				var flareREm:ParticlesEmitter = EffectEMs["flareRed"];
				var sc:Number = lookDBER.x/50;
				var v:Vector3D = null;
				for (var i:int=FW.length-1; i>-1; i--)
				{
					v = S3[i];
					v.z = (v.z+1)%rotDiv;
					smoke3Em.emit(v.x*SinA[v.z],v.y,v.x*CosA[v.z],0,0,0,sc*v.w);
					v = FW[i];
					v.z = (v.z+1)%rotDiv;
					flareWEm.emit(v.x*SinA[v.z],v.y,v.x*CosA[v.z],0,0,0,sc*v.w*(0.8+Math.random()*0.3));
					v = FY[i];
					v.z = (v.z+1)%rotDiv;
					flareYEm.emit(v.x*SinA[v.z],v.y,v.x*CosA[v.z],0,0,0,sc*v.w*(0.8+Math.random()*0.3));
					v = FR[i];
					v.z = (v.z+1)%rotDiv;
					flareREm.emit(v.x*SinA[v.z],v.y,v.x*CosA[v.z],0,0,0,sc*v.w*(0.8+Math.random()*0.3));
				}

				// ----- draw reticle
				if (lookDBER.x>49)	// when to show reticle
				{
					if (targStar==null)
					{
						for (i=0; i<20 && targStar==null; i++)
						{
							targStar = FY[Math.floor(Math.random()*FY.length)];
							var dSq:Number = targStar.x*targStar.x + targStar.z*targStar.z;
							if (dSq>w*w*0.7*0.7 || dSq<w*w*0.2*0.2)
								targStar = null;
						}
					}
					else
					{
						retAge++;
						retS.graphics.clear();
						var screenPt:Vector3D = Mesh.screenPosn(targStar.x*SinA[targStar.z],targStar.y,targStar.x*CosA[targStar.z]);
						var color:uint = Math.floor((Math.cos(retAge)+1)*127);
						color = color <<16 | color << 8 | color;
						retS.graphics.lineStyle(0,color,1);
						var gap:int = stage.stageWidth*0.01;
						var lineGap:Number = Math.max(0,stage.stageWidth*0.5-retAge/10*stage.stageWidth*0.5);
						retS.graphics.moveTo(0,screenPt.y-lineGap/2);
						retS.graphics.lineTo(stage.stageWidth,screenPt.y-lineGap/2);
						retS.graphics.moveTo(0,screenPt.y+lineGap/2);
						retS.graphics.lineTo(stage.stageWidth,screenPt.y+lineGap/2);
						retS.graphics.moveTo(screenPt.x-lineGap/2,0);
						retS.graphics.lineTo(screenPt.x-lineGap/2,stage.stageHeight);
						retS.graphics.moveTo(screenPt.x+lineGap/2,0);
						retS.graphics.lineTo(screenPt.x+lineGap/2,stage.stageHeight);
						if (lineGap<gap)
							retS.graphics.drawRect(screenPt.x-gap,screenPt.y-gap,gap*2,gap*2);
					}
				}

				if (Input.upPts.length>0 && targStar!=null)
				{
					lookVel = new Vector3D(targStar.x*SinA[targStar.z],targStar.y,targStar.x*CosA[targStar.z]).subtract(lookPt);
					lookVel.scaleBy(1-0.9);	// set look velocity to center to selected position
					retS.parent.removeChild(retS);
					viewStep = zoomInAndCallBack;
				}
			}
			stepFns.push(galaxyStep);

			// ----- zoom out view
			viewStep = function():Vector3D
			{
				var slowF:Number = 0.9;

				lookVel.x = -lookPt.x*(1-slowF);		// center to (0,0,0)
				lookVel.y = -lookPt.y*(1-slowF);
				lookVel.z = -lookPt.z*(1-slowF);

				velDBER.x = (50-lookDBER.x)*(1-slowF);									// set dist to 50
				if (Math.sin(lookDBER.y)<0)
					velDBER.y = Math.acos(Math.cos(lookDBER.y))*(1-slowF);	// set bearing to face north
				else
					velDBER.y =-Math.acos(Math.cos(lookDBER.y))*(1-slowF);	// set bearing to face north
				velDBER.z = (-Math.PI*0.4-lookDBER.z)*(1-slowF);				// look from top down
			}//endfunction

			// ----- zoom in view and do callback
			function zoomInAndCallBack():void
			{
				mainTitle.name = "";
				subTitle.name = "";

				var slowF:Number = 0.9;
				velDBER.x = (8-lookDBER.x)*(1-slowF);		// set dist to 1
				velDBER.y += 0.01;												// spin
				velDBER.z = (-Math.PI*0.1-lookDBER.z)*(1-slowF);				// look sideways

				// ----- exit condition
				if (lookDBER.x<8.5)
				{
					stepFns.splice(stepFns.indexOf(galaxyStep),1);
					viewStep = oldViewStep;
					if (callBack!=null)		callBack();
				}
			}//endfunction
		}//endfunction

		//===============================================================================================
		// generate random sky and planets scenery
		//===============================================================================================
		private var planetsDat:Vector.<Vector3D> = null;	// axis x,y,z and w=rotAng
		private function randScenery():Mesh
		{
			// ----- create skybox
			if (sky!=null) world.removeChild(sky);
			var spaceTex:Array= ["TexSpace1","TexSpace2","TexSpace3","TexSpace4","TexSpace5"];
			var colorTones:Vector.<uint> = new <uint> [0xeeeeee,0xff8c8c,0x91ffa7,0x7cd7ff,0xffeb7c];
			var skyIdx:int = int(spaceTex.length*Math.random());
			sky = new Mesh();
			var skyTex:BitmapData = Mtls[spaceTex[skyIdx]];
			MenuUI.colorTone = colorTones[skyIdx];
			for (var i:int=0; i<4; i++)
			{
				var p:Mesh = Mesh.createPlane(3000,3000,skyTex);
				p.transform = new Matrix4x4().rotY(Math.PI/2*i).translate(Math.sin(Math.PI/2*i)*1500,0,Math.cos(Math.PI/2*i)*1500);
				sky.addChild(p);
			}
			sky = sky.mergeTree();
			sky.setLightingParameters(1,1,1,0,0,false,true);
			sky.depthWrite = false;
			world.addChild(sky);

			// ----- create planet and moons
			var planet:Mesh = new Mesh();
			planet.transform = planet.transform.rotX((Math.random()-0.5)*Math.PI*0.9).rotY(Math.random()*Math.PI*2).translate(0,-100,0);
			planetsDat = new Vector.<Vector3D>();
			var ringsGap:Vector.<Number> = new Vector.<Number>();		// the gaps taken up by planets
			var R:Vector.<int> = new Vector.<int>();	// random ordered vector of numbers 0-7
			for (i=0; i<8; i++)
				R.splice(Math.floor(Math.random()*R.length),0,i);
			for (i=0; i<8; i++)
			{
				if (Math.random()<0.7 || i==0)
				{
					var r:int = Math.floor(Math.random()*8);
					var planetRad:Number = 75/(i*2+1);
					var orbitRad:Number = 0;
					if (i>0)	orbitRad =i*100 + 200/(i+1)+Math.random()*50;
					p = createPlanetMesh(planetRad,R[i],Mtls["TexPlanets"]);
					var ang:Number = Math.random()*Math.PI*2;
					p.transform = p.transform.translate(orbitRad*Math.sin(ang),0,orbitRad*Math.cos(ang));
					p.material.setSpecular(0);
					p.material.setAmbient(0,0,0);
					planet.addChild(p);
					planetsDat.push(new Vector3D(Math.random()-0.5,1,Math.random()-0.5,Math.random()*Math.PI*2));
					ringsGap.push(orbitRad-planetRad,orbitRad+planetRad);
				}
			}//endfor
			sky.addChild(planet);

			// ----- create planetary rings
			ringsGap.shift();
			ringsGap.pop();
			var rings:Mesh = new Mesh();
			rings.transform = new Matrix4x4().rotX(Math.PI/2);
			for (i=0; i<ringsGap.length; i+=2)
			{
				var a:Number = Math.random()*0.8;
				var b:Number = 0.2 + Math.random()*0.8;
				if (a<b)
					rings.addChild(createPlanetRing(ringsGap[i] + a*(ringsGap[i+1]-ringsGap[i]),
																					ringsGap[i] + b*(ringsGap[i+1]-ringsGap[i])));
			}
			rings = rings.mergeTree();
			rings.material.setBlendMode("add");
			rings.depthWrite = false;
			planet.addChild(rings);
			rings.setLightingParameters(1,1,1,0,0,false,true);

			// ----- create main and sub title
			var sw:int = stage.stageWidth;
			var sh:int = stage.stageHeight;
			if (mainTitle!=null && mainTitle.parent!=null)
				mainTitle.parent.removeChild(mainTitle);
			mainTitle = MenuUI.createTypeOutTextBmp("Jumping In",sh*MenuUI.fontScale*1.3);
			mainTitle.x = MenuUI.margF*sw*1.1-sh*MenuUI.fontScale*2*0.35+sh*MenuUI.margF*0.3;
			mainTitle.y = MenuUI.margF*sh;
			addChild(mainTitle);
			if (subTitle!=null && subTitle.parent!=null)
				subTitle.parent.removeChild(subTitle);
			subTitle = MenuUI.createTypeOutTextBmp("Location : "+MenuUI.randomPlanetName(),sh*MenuUI.fontScale*0.7);
			subTitle.x = MenuUI.margF*sw*1.1-sh*MenuUI.fontScale*0.35+sh*MenuUI.margF*0.3;
			subTitle.y = mainTitle.y+mainTitle.height*0.8;
			addChild(subTitle);
			return sky;
		}//

		//===============================================================================================
		// create banded planetary ring stretching from radius a to b
		//===============================================================================================
		private function createPlanetRing(a:Number,b:Number):Mesh
		{
			var ring:Mesh = new Mesh();

			var n:int = Math.round(Math.random()*(b-a));	// randomize number of bands
			if (n>30) n=30;
			var B:Vector.<Number> = new <Number>[a,b];
			while (n>0)
			{
				var p:int=0;
				var q:int=B.length-1;
				var r:Number = Math.random()*(b-a)+a;
				while (p<=q)
				{
					var m:int = (p+q)/2;
					if (B[m]<r)	p=m+1;
					else 				q=m-1;
				}
				B.splice(p,0,r);
				n--;
			}
			for (p=B.length-2; p>-1; p--)
			{
				var opacity:Number = 1-Math.random()*0.5-0.05;
				var band:Mesh = Mesh.createCylinder(B[p],B[p+1],0,0,64,Mtls["TexWhiteGradient"]);
				var vd:Vector.<Number> = band.vertData;
				for (var i:int=vd.length-11; i>-1; i-=11)		vd[i+10] = opacity;
				ring.addChild(band);
			}

			return ring;
		}//endfunction

		//===============================================================================================
		// generate random asteroids
		//===============================================================================================
		private function randAsteroids(n:int):void
		{
			var A:Vector.<Asteroid> = new Vector.<Asteroid>();
			for (var i:int=0; i<n; i++)
			{
				var aTyp:int = Math.floor(Math.random()*9);

				var a:Asteroid = new Asteroid("asteroid",aTyp,1+Math.floor(Math.random()*15),Mtls["TexRocks"],Mtls["SpecRocks"],Mtls["NormRocks"]);
				a.name = i+"-"+a.hullConfig.length+"-type"+aTyp;
				do {
					var canPlace:Boolean = true;
					a.posn = new Vector3D((Math.random()-0.5)*200,0,(Math.random()-0.5)*200);
					for (var j:int=A.length-1; j>-1; j--)
						if (A[j].posn.subtract(a.posn).length<(a.radius+A[j].radius)*2)
							canPlace = false;
				} while (!canPlace);
				A.push(a);
				Entities.push(a);
				world.addChild(a.skin);
			}
		}//endfunction

		//===============================================================================================
		// simulate planet movements
		//===============================================================================================
		private function planetStep():void
		{
			if (planetsDat==null || sky==null || !world.containsChild(sky)) return;
			var planet:Mesh = sky.getChildAt(0);
			for (var i:int=planetsDat.length-1; i>-1; i--)
			{
				var v:Vector3D = planetsDat[i];
				var p:Mesh = planet.getChildAt(i);
				var ox:Number = p.transform.ad;
				var oy:Number = p.transform.bd;
				var oz:Number = p.transform.cd;
				var dist:Number = Math.sqrt(ox*ox+oy*oy+oz*oz);
				p.transform = new Matrix4x4().rotFromTo(0,0,1,v.x,v.y,v.z).rotAbout(v.x,v.y,v.z,v.w).translate(ox,oy,oz);
				if (dist>100)
				{
					p.transform = p.transform.rotY(0.1/dist);
					v.w += 0.1/Math.sqrt(dist+100);
				}
				else
					v.w += 0.0001;
			}
		}//endfunction

		//===============================================================================================
		// create a sphere of given texture
		//===============================================================================================
		private static function createPlanetMesh(r:Number,planetType:uint,tex:BitmapData) : Mesh
		{
			if (planetType>=8)	planetType = planetType%8;
			var lon:uint=32;
			var lat:uint=16;
			if (r>60) {lon*=2; lat*=2;}	// higher tri count for larger radius spheres
			var S:Vector.<Number> = new Vector.<Number>();
			var i:int = 0;
			while (i<lat)
			{
				var sinL0:Number = Math.sin(Math.PI*i/lat)+0.0001;			// prevent UV artifact at poles of planet
				var sinL1:Number = Math.sin(Math.PI*(i+1)/lat)+0.0001;
				var cosL0:Number = Math.cos(Math.PI*i/lat);
				var cosL1:Number = Math.cos(Math.PI*(i+1)/lat);
				var A:Vector.<Number> = Mesh.createTrianglesBand(sinL0*r,
															sinL1*r,
															-cosL0*r,
															-cosL1*r,
															lon,true);

				for (var j:int=0; j<A.length; j+=8)
				{
					// ----- recalculate normals
					var nx:Number = A[j+0];
					var ny:Number = A[j+1];
					var nz:Number = A[j+2];
					var nl:Number = Math.sqrt(nx*nx+ny*ny+nz*nz);
					nx/=nl; ny/=nl; nz/=nl;
					A[j+3]=nx; A[j+4]=ny; A[j+5]=nz;
					// ----- adjust UVs
					A[j+7]=i/lat+A[j+7]/lat;
					var ux:Number = int(planetType/4)/2;
					var uy:Number = (planetType%4)/4;
					A[j+6] = ux + 0.0005 + A[j+6]*0.499;		// prevent UV bleed to other planet texture area
					A[j+7] = uy + A[j+7]*0.25;
				}
				S = S.concat(A);
				i++;
			}//endfor

			var m:Mesh = new Mesh();
			m.createGeometry(S);
			m.material.setTexMap(tex);
			return m;
		}//endfunction

		//===============================================================================================
		// fade in to new ambient loop
		//===============================================================================================
		private function playAmbientLoop(id:String,loudness:Number=1,fadeTime:Number=5):void
		{
				var newLoop:SoundChannel = (Sound)(SoundFxs[id]).play(0,99999,new SoundTransform(0,0));
				var newST:SoundTransform = newLoop.soundTransform;
				TweenLite.to(newST,fadeTime,{volume:loudness, onUpdate:function():void {newLoop.soundTransform=newST;}});
				if (ambientLoop!=null)
				{
					var oldLoop:SoundChannel = ambientLoop;
					var oldST:SoundTransform = oldLoop.soundTransform;
					TweenLite.killTweensOf(oldST);
					TweenLite.to(oldST,fadeTime,{volume:0, onUpdate:function():void {oldLoop.soundTransform=oldST;}, onComplete:function():void {oldLoop.stop();}});
				}
				ambientLoop=newLoop;
		}//endfunction

		//===============================================================================================
		// queue sounds to be played on current frame
		//===============================================================================================
		private function playSound(px:Number,py:Number,pz:Number,id:String):void
		{
			if (SndsToPlay[id]==null)
				SndsToPlay[id] = new Vector.<Number>();
			(Vector.<Number>)(SndsToPlay[id]).push(px,py,pz);	// register sound to be played
		}//endfunction

		//===============================================================================================
		// Plays queued sounds on current frame
		//===============================================================================================
		private function soundsStep(camPt:Vector3D):void
		{
			var px:Number = (camPt.x+lookPt.x)/2;
			var py:Number = (camPt.y+lookPt.y)/2;
			var pz:Number = (camPt.z+lookPt.z)/2;
			for (var id:String in SndsToPlay)
			{
				var v:Vector.<Number> = SndsToPlay[id] as Vector.<Number>;
				var loudness:Number = 0;
				while (v.length>0)
				{
					var dz:Number = v.pop()-pz;
					var dy:Number = v.pop()-py;
					var dx:Number = v.pop()-px;
					loudness += 4/((Number)(SoundFxs[id+"_Af"])*Math.sqrt(dx*dx+dy*dy+dz*dz));
				}
				if (loudness>1.5) loudness=1.5;
				if (loudness>0.01)
					(Sound)(SoundFxs[id]).play(0,0,new SoundTransform(loudness,0));
			}
		}//endfunction

		//===============================================================================================
		// MAIN world step function
		//===============================================================================================
		private function worldStep(ev:Event=null) : void
		{
			var i:int=0;
			var key:String;
			var debugTxt:String = "";
			if (!simulationPaused)
			{
				// ----- reset mesh particles -------------------------------------
				frameS_MP.reset();
				frameM_MP.reset();
				for (key in EffectMPs)	EffectMPs[key].reset();
				for (key in TurretMPs)	TurretMPs[key].reset();

				// ----- simulate ships
				var time:uint = getTimer();
				shipsStep();
				debugTxt += "Entities:"+Entities.length+" Projectiles:"+Projectiles.length+" shipsT:"+(getTimer()-time);

				// ----- simulate turrets
				time=getTimer();
				projectilesStep();	debugTxt += " projT:"+(getTimer()-time); time=getTimer();
				explodingStep();	debugTxt += " explT:"+(getTimer()-time); time=getTimer();
				dropItemsStep();	debugTxt += " itmsT:"+(getTimer()-time); time=getTimer();
				var turretsCnt:int = 0;
				for (i=Friendlies.length-1; i>-1; i--)
					turretsCnt+=simulateShipTurrets((Ship)(Friendlies[i]),(Ship)(Friendlies[i]).engageEnemy);
				for (i=Hostiles.length-1; i>-1; i--)
					turretsCnt+=simulateShipTurrets((Ship)(Hostiles[i]),(Ship)(Hostiles[i]).engageEnemy);
				debugTxt += " Turrets:"+turretsCnt+"    turrT:"+(getTimer()-time); time=getTimer();

				// ----- update mesh particles
				var frameSShown:int = frameS_MP.update();
				var frameMShown:int = frameM_MP.update();
				for (key in TurretMPs)	TurretMPs[key].update();

				// ----- exec misc step funs
				for (i = stepFns.length - 1; i > -1; i--)
					stepFns[i]();

				// ----- simulate planets
				planetStep();
			}//endif !simulationPaused

			velDBER.x += lookDBER.x*(Input.zoomF-1);	// adjust zoom from input

			viewStep();	// modifies velDBER and lookVel

			// ----- camera Distance Bearing Elevation Rotation calcuation
			lookDBER = lookDBER.add(velDBER);
			lookDBER.z = Math.max(-Math.PI*0.499,Math.min(Math.PI*0.499,lookDBER.z));
			if (focusedEntity!=null) lookDBER.x = Math.max(focusedEntity.radius*1.1, lookDBER.x);
			velDBER.scaleBy(0.9);

			// ----- calculate cam lookPt easing
			lookPt = lookPt.add(lookVel);
			lookVel.scaleBy(0.9);

			// ----- calculate cam lookat direction
			var camDir:Vector3D =
			new Vector3D(	Math.cos(lookDBER.z)*Math.sin(lookDBER.y),
										Math.sin(lookDBER.z),
										Math.cos(lookDBER.z)*Math.cos(lookDBER.y));
			var camPosn:Vector3D =
			new Vector3D(	lookPt.x-camDir.x*lookDBER.x,
										lookPt.y-camDir.y*lookDBER.x,
										lookPt.z-camDir.z*lookDBER.x);

			// ----- set camera position and orientation
			Mesh.setCamera(camPosn.x,camPosn.y,camPosn.z,lookPt.x,lookPt.y,lookPt.z,1,0.01);
			sky.transform = new Matrix4x4().translate(lookPt.x,lookPt.y,lookPt.z);

			// ----- show ship HUD of focusedShip
			ShipHUD.update(focusedShip);

			// ----- play sound FXs
			soundsStep(camPosn);

			// ----- update Mesh Particles/particle emitters
			for (key in EffectMPs)	EffectMPs[key].update();
			for (key in EffectEMs)	EffectEMs[key].update(camPosn.x,camPosn.y,camPosn.z,simulationPaused);
			debugTxt+=" particlesT:"+(getTimer()-time); time=getTimer();
			debugTxt+="   frameS:"+frameSShown+" frameM:"+frameMShown+" camDist:"+int(lookDBER.x*10)/10;
			debugTf.text = debugTxt;
			// ----- render 3D
			//Mesh.setPointLighting(new <Number>[lookPt.x+100,lookPt.y+100,lookPt.z+100,1,1,1]);
			Mesh.renderBranch(stage, world, false);

			Input.update();
			gameTime++;
		}//endfunction

		//===============================================================================================
		// zooms to entity and display controls/options menu
		//===============================================================================================
		private function focusOn(entity:Hull):void
		{
			focusedEntity = entity;
			focusedShip = null;

			if (entity!=null)
			{
				if (entity is Ship)
					focusedShip = (Ship)(entity);
				else if (entity is Asteroid)
					mainTitle.name = "Asteroid : "+entity.name;
			}

			if (shipHUD != null && shipHUD.parent != null)
				shipHUD.parent.removeChild(shipHUD);
			if (focusedShip!=null)
			{
				if (Hostiles.indexOf(focusedShip)!=-1)
					mainTitle.name = "Hostile : " + focusedShip.name;
				else
					mainTitle.name = focusedShip.name;
				//shipHUD = MenuUI.createShipHUD(focusedShip, stage);
				//addChild(shipHUD);
			}
			// ----- shows appropriate menu for different focused entity
			if (optionsMenu!=null && optionsMenu.parent!=null)
				optionsMenu.parent.removeChild(optionsMenu);
			if (entity!=null && optionsMenuSelector!=null)
				optionsMenuSelector(entity);

			// ----- zoom in to the focused entity
			if (entity!=null)
				velDBER.x = (entity.radius*4-lookDBER.x)*(1-0.9);	// zoom to radius * 4

			stage.focus = stage;
		}//endfunction

		//===============================================================================================
		// convenience function to focus on entity and rotate around it
		//===============================================================================================
		private function focusAndRotateAround(entity:Hull,callBack:Function=null,ttr:int=-1):void
		{
			focusOn(entity);

			// ----- spin view around focused ship
			var rotAroundShip:Function = function():void
			{
				velDBER.x = (focusedEntity.radius*4-lookDBER.x)*(1-0.9);
				velDBER.y = Math.PI/288;
				// stop immediately on interraction
				if (Input.upPts.length>0 || ttr==0)
				{
					stepFns.splice(stepFns.indexOf(rotAroundShip),1);
					if (callBack!=null)	callBack();
				}

				ttr--;
			}//endfunction
			stepFns.push(rotAroundShip);
		}//endfunction

		//===============================================================================================
		// default focus on ship view, allows
		//===============================================================================================
		private function shipViewStep():void
		{
			// ----- enable user focus on selection
			if (Input.upPts.length==1)
			{
				var upPt:InputPt = Input.upPts[0];
				// enable ship selection on mouse click
				if (upPt.endT - upPt.startT<300)
				{
					var ray:VertexData = Mesh.cursorRay(upPt.x,upPt.y,0.01,1000);
					// ----- detect clicked another ship
					var selected:Hull = null;
					for (var i:int=Entities.length-1; i>-1; i--)
						if (Entities[i]!=focusedEntity && Entities[i].hullSkin.lineHitsMesh(ray.vx,ray.vy,ray.vz,ray.nx,ray.ny,ray.nz,Entities[i].skin.transform))
						{
							if (selected==null)
								selected = Entities[i];
						}
					if (selected!=null)
						focusOn(selected);
				}
			}

			// ----- calculate cam lookPt easing
			if (focusedEntity!=null)
			{
				if (lookDBER.x>45 && velDBER.x>=0)	// tactical view mode
				{
					if (prevLookDBER==null)
					{
						world.addChild(gridMesh);
						prevLookDBER = lookDBER;
					}

					// ----- enable drag to scroll top down view interraction
					if (Input.downPts.length==1)	// one finger
					{
						var downPt:InputPt = Input.downPts[0];
						lookVel.x -= (downPt.x-downPt.ox)/100;
						lookVel.z += (downPt.y-downPt.oy)/100;
					}

					if (lookDBER.x>50)
					{
						lookDBER.x = 50;
						velDBER.x = 0;
					}
					else
						velDBER.x = (50-lookDBER.x)*(1-0.9);									// set dist to 50
					velDBER.y = Math.acos(Math.cos(lookDBER.y))*(1-0.9);	// set bearing to face north
					if (Math.sin(lookDBER.y)>0)	velDBER.y*=-1;						// correct direction of turn
					velDBER.z = (-Math.PI*0.5-lookDBER.z)*(1-0.9);				// look from top down
				}
				else // zoom in mode
				{
					if (prevLookDBER!=null)
					{
						world.removeChild(gridMesh);
						prevLookDBER.x = focusedEntity.radius*4;	// hack to dist cam from ship
						velDBER = prevLookDBER.subtract(lookDBER);
						velDBER.scaleBy(1-0.9);
						prevLookDBER = null;
					}

					// ----- enable drag to pan view interraction
					if (Input.downPts.length==1)	// one finger
					{
						downPt = Input.downPts[0];
						velDBER.y+=(downPt.x-downPt.ox)/1000;	// bearing change
						velDBER.z-=(downPt.y-downPt.oy)/1000;	// elevation change
					}

					lookVel = focusedEntity.posn.subtract(lookPt);
					lookVel.scaleBy(1-0.9);
				}
			}//endif
		}//endfunction

		//===============================================================================================
		// handles projectiles simulation
		//===============================================================================================
		private function projectilesStep() : void
		{
			var i:int = 0;
			var key:String;

			for (i=Projectiles.length-1; i>-1; i--)
			{
				var p:Projectile = Projectiles[i];
				if (p.targ is HullBlock)
				{
					// ----- chk hit ship hull
					for (var j:int=Entities.length-1; j>-1; j--)
					{
						var s:Hull = Entities[j];
						var dx:Number = s.posn.x-p.px;
						var dy:Number = s.posn.y-p.py;
						var dz:Number = s.posn.z-p.pz;

						if (dx*dx+dy*dy+dz*dz<s.radius*s.radius+p.vx*p.vx+p.vy*p.vy+p.vz*p.vz)
						{
							var hitPt:VertexData = s.hullSkin.lineMeshIntersection(p.px,p.py,p.pz,p.vx,p.vy,p.vz,s.skin.transform);
							if (hitPt!=null)
							{
								if (posnIsOnScreen(hitPt.vx,hitPt.vy,hitPt.vz))
									projectileHitFx(hitPt.vx,hitPt.vy,hitPt.vz, hitPt.nx,hitPt.ny,hitPt.nz, s.vel.x,s.vel.y,s.vel.z, p.integrity);
								playSound(p.px,p.py,p.pz,"hit");
								if (p.targ.parent==s)	// if is target
									s.registerHit(hitPt,p.integrity);
								p.integrity = 0;
								p.ttl=0;

							}
						}//endif
					}//endfor

					// ----- do missile step function
					if (p is Missile)		(Missile)(p).homeInStep();
				}
				else	// is flak gun projectile
				{
					if (p.ttl<1)	// reached target flak point
					{
						dx = (p.px+p.vx*p.ttl) - (p.targ.px+p.targ.vx*p.ttl);
						dy = (p.py+p.vy*p.ttl) - (p.targ.py+p.targ.vy*p.ttl);
						dz = (p.pz+p.vz*p.ttl) - (p.targ.pz+p.targ.vz*p.ttl);
						if (dx*dx+dy*dy+dz*dz<1)
						{
							p.targ.integrity-=p.integrity;
							if (p.targ.integrity<=0) p.targ.ttl = p.ttl;
						}
						if (p.onDestroy!=null)
							p.onDestroy();
					}
				}
			}//endfor

			for (i=Projectiles.length-1; i>-1; i--)
			{
				p = Projectiles[i];
				if (p.ttl<=1)
				{
					Projectiles.splice(i, 1);
					if (p.integrity>0 && posnIsOnScreen(p.px+p.vx*p.ttl, p.py+p.vy*p.ttl, p.pz+p.vz*p.ttl))
						(ParticlesEmitter)(EffectEMs["flash"]).emit(p.px+p.vx*p.ttl, p.py+p.vy*p.ttl, p.pz+p.vz*p.ttl, 0, 0, 0, Math.sqrt(p.integrity)/10);
				}
				else
				{
					p.ttl-=1;
					p.px+=p.vx;	// move projectile
					p.py+=p.vy;
					p.pz+=p.vz;
					if (posnIsOnScreen(p.px,p.py,p.pz))	// offscreen culling
						p.renderFn(p);
				}
			}//endfor
		}//endfunction

		//===============================================================================================
		// simulate ships chk ship hits projectile after move
		//===============================================================================================
		private function shipsStep():void
		{
			for (var i:int=Entities.length-1; i>-1; i--)
			{
				var entity:Hull = Entities[i];
				if (entity.integrity<=0)
				{
					if (entity is Ship)
						destroyShip((Ship)(entity));
					else
						removeEntity(entity);
				}
				else
				{
					// ----- calculate all projectiles relative position to hull
					var iT:Matrix4x4 = entity.skin.transform.inverse();
					for (var j:int=Projectiles.length-1; j>-1; j--)
					{
						var p:Projectile = Projectiles[j];
						p.tx = iT.aa*p.px+iT.ab*p.py+iT.ac*p.pz+iT.ad;	// previous local position to ship
						p.ty = iT.ba*p.px+iT.bb*p.py+iT.bc*p.pz+iT.bd;
						p.tz = iT.ca*p.px+iT.cb*p.py+iT.cc*p.pz+iT.cd;
					}

					if (entity is Ship)
					{
						if ((Ship)(entity).stepFn!=null)	(Ship)(entity).stepFn();
						doShipDamageFx((Ship)(entity));
						doShipSeparation((Ship)(entity));
					}
					entity.updateStep();

					// ----- chk projectile hits after ship moved to new posn
					for (j=Projectiles.length-1; j>-1; j--)
					{
						p = Projectiles[j];
						var T:Matrix4x4 = entity.skin.transform;
						var hitPt:VertexData =
						entity.hullSkin.lineMeshIntersection(p.px,p.py,p.pz,
														T.aa*p.tx+T.ab*p.ty+T.ac*p.tz+T.ad - p.px,
														T.ba*p.tx+T.bb*p.ty+T.bc*p.tz+T.bd - p.py,
														T.ca*p.tx+T.cb*p.ty+T.cc*p.tz+T.cd - p.pz,T);
						if (hitPt!=null)
						{
							if (posnIsOnScreen(hitPt.vx,hitPt.vy,hitPt.vz))
								projectileHitFx(hitPt.vx,hitPt.vy,hitPt.vz,
																hitPt.nx,hitPt.ny,hitPt.nz,
																entity.vel.x,entity.vel.y,entity.vel.z,
																p.integrity);
							playSound(p.px,p.py,p.pz,"hit");
							if (p.targ is Ship && p.targ.parent==entity)	// if is target
								entity.registerHit(hitPt,p.integrity);
							p.integrity = 0;
							p.ttl=0;
						}
					}//endfor
				}//
			}//endfor
		}//endfunction

		//===============================================================================================
		// simulate drop items, player tap to pick up
		//===============================================================================================
		private var dropItmHitDetect:Mesh = Mesh.createSphere(2,6,4); 	// radius 2
		private function dropItemsStep():void
		{
			// ----- enable user focus on selection
			var ray:VertexData = null;
			if (Input.upPts.length==1)
			{
				var upPt:InputPt = Input.upPts[0];
				// enable ship selection on mouse click
				if (upPt.endT - upPt.startT<300)
					ray = Mesh.cursorRay(upPt.x,upPt.y,0.01,1000);
			}//endif

			var pickedUp:DropItem = null;
			for (var i:int=DropItems.length-1; i>-1; i--)
			{
				var p:DropItem = DropItems[i];
				if (p.ttl<1)	// reached time to live
				{
					DropItems.splice(i,1);
				}
				else
				{
					if (ray!=null && dropItmHitDetect.lineHitsMesh(ray.vx,ray.vy,ray.vz,ray.nx,ray.ny,ray.nz,new Matrix4x4().translate(p.px,p.py,p.pz)))
					{	// ----- pick up item
						pickedUp = p;
						var hit:VertexData = dropItmHitDetect.lineMeshIntersection(ray.vx,ray.vy,ray.vz,ray.nx,ray.ny,ray.nz,new Matrix4x4().translate(p.px,p.py,p.pz));
						ray.nx = hit.vx - ray.vx;		// modify line ray to end at hitpoint
						ray.ny = hit.vy - ray.vy;
						ray.nz = hit.vz - ray.vz;
					}
					else
					{
						p.ttl-=1;
						p.projIntegrity=1;
						p.px+=p.vx;	// move projectile
						p.py+=p.vy;
						p.pz+=p.vz;
						p.vx*=p.damp;
						p.vy*=p.damp;
						p.vz*=p.damp;
						if (posnIsOnScreen(p.px,p.py,p.pz))	// offscreen culling
							p.renderFn(p);
					}
				}
			}

			if (pickedUp!=null)
			{
				pickedUp.ttl=-1;
				EffectEMs["wave"].emit(pickedUp.px,pickedUp.py,pickedUp.pz,0,0,0,0.1);
			}
		}//endfunction

		//===============================================================================================
		// hit fireball and splattering
		//===============================================================================================
		private function projectileHitFx(px:Number,py:Number,pz:Number,nx:Number,ny:Number,nz:Number,vx:Number,vy:Number,vz:Number,dmg:Number):void
		{
			(ParticlesEmitter)(EffectEMs["bit"]).batchEmit(Math.sqrt(dmg), px,py,pz, vx+nx*0.1,vy+ny*0.1,vz+nz*0.1, 0.2);

			var n:int = Math.sqrt(dmg);
			if (n>0)
			{
				var A:Vector.<Vector3D> = new Vector.<Vector3D>();
				for (var i:int=0; i<n; i++)
				{
					var v:Vector3D = randV3values(0.01*(1+n)*(Math.random()*0.5+0.5));
					var dp:Number = v.x*nx + v.y*ny + v.z*nz;
					if (dp<0)	// reflect if against normal
					{
						v.x -= nx*dp*2;
						v.y -= ny*dp*2;
						v.z -= nz*dp*2;
					}
					A.push(v);
				}

				var ttl:int = 30;
				var rv:Vector3D = new Vector3D();
				var streamersFn:Function = function():void
				{
					for (var i:int=A.length-1; i>-1; i--)
					{
						var v:Vector3D = A[i];
						var ptx:Number = px+(v.x+vx)*v.w;
						var pty:Number = py+(v.y+vy)*v.w;
						var ptz:Number = pz+(v.z+vz)*v.w;
						randV3values(0.015,rv);
						(ParticlesEmitter)(EffectEMs["blast"]).emit(ptx,pty,ptz, vx+rv.x,vy+rv.y,vz+rv.z,0.1*(ttl/30));
						v.w+=1;
						v.x*=0.99;
						v.y*=0.99;
						v.z*=0.99;
					}
					ttl--;
					if (ttl<0)
						stepFns.splice(stepFns.indexOf(streamersFn),1);
				};
				stepFns.push(streamersFn);
			}
		}//endfunction

		//===============================================================================================
		// updates ship turrets positions and rotations
		//===============================================================================================
		private function simulateShipTurrets(ship:Ship,active:Boolean=true) : int
		{
			if (ship==null || ship.targets==null) return 0;

			var i:int=0;
			var j:int=0;

			var M:Vector.<Module> = ship.modulesConfig;
			for (i=M.length-1; i>-1; i--)
			{
				var m:Module = M[i];
				if (m.type.substring(0,8)=="thruster")
					simulateThrusterS(ship,m);
				else
				{
					// ----- turret position ------------------------------------------
					var T:Matrix4x4 = new Matrix4x4().rotFromTo(0,1,0,m.nx,m.ny,m.nz);
					if (m.type.charAt(m.type.length-1)=='M')	// mid sized module
						T = T.translate(m.x+m.nx*1.57,m.y+m.ny*1.57,m.z+m.nz*1.57);	// turret local space
					else
						T = T.translate(m.x+m.nx*0.71,m.y+m.ny*0.71,m.z+m.nz*0.71);	// turret local space
					T = ship.skin.transform.mult(T);	// turret global space

					var turX:Number = T.ad;		// turret global space posn
					var turY:Number = T.bd;
					var turZ:Number = T.cd;

					var targObj:Object = null;	// targ current position & vel
					var interceptV:Vector3D=T.rotateVector(new Vector3D(0,0.01,1,m.range/m.speed));	// predicted intercept vector, defa parking posn

					if (m.type=="launcherS")
					{
						if (m.ttf<=0 && active)
						{
							// ----- seek nearest target hull posn ----------------------------
							targObj = nearestTargShipHull(turX,turY,turZ,m.speed,ship,interceptV);
							if (targObj!=null && ship.energy>m.damage)
							{
								m.ttf = m.fireDelay+1;
								ship.energy -= m.damage;
								playSound(turX,turY,turZ,m.type);
								launch4Missiles(targObj,m,ship);
							}
						}
					}
					else	// is weapon turret
					{
						// ----- seek nearest target projectile/hull posn -------------------
						if (m.type=="tractorS")
							targObj = nearestTargDropItem(turX,turY,turZ,ship,interceptV);
						else if (m.type=="gunAutoS" || m.type=="gunFlakS")
							targObj = nearestTargProjectile(turX,turY,turZ,m.speed,ship,interceptV);
						else if (active)
							targObj = nearestTargShipHull(turX,turY,turZ,m.speed,ship,interceptV);

						// ----- rotate turret towards interceptV ---------------------------
						var canFire:Boolean = targObj!=null && m.ttf<=0;
						var invT:Matrix4x4 = T.inverse();
						var localPosn:Vector3D = invT.transform(new Vector3D(interceptV.x*interceptV.w+turX,
																							interceptV.y*interceptV.w+turY,
																							interceptV.z*interceptV.w+turZ));

						var nx:Number = localPosn.x;
						var nz:Number = localPosn.z;
						var _nl:Number = 1/Math.sqrt(nx*nx+nz*nz);
						nx*=_nl; nz*=_nl;
						var sinB:Number = Math.sin(m.bearing);
						var cosB:Number = Math.cos(m.bearing);
						var diffB:Number = nx*sinB+nz*cosB;	// using a.b = |a||b|cosA
						if (diffB<-1) 		diffB=-1;
						else if (diffB>1)	diffB= 1;
						diffB = Math.acos(diffB);
						if (nx*cosB-sinB*nz<0)	diffB*=-1;
						if (diffB<-m.turnRate)			{diffB=-m.turnRate; canFire=false;}
						else if (diffB> m.turnRate)	{diffB= m.turnRate; canFire=false;}
						m.bearing+=diffB;
						var diffE:Number = Math.atan2(localPosn.y,Math.sqrt(localPosn.x*localPosn.x+localPosn.z*localPosn.z))-m.elevation;
						if (diffE<-m.turnRate)			{diffE=-m.turnRate; canFire=false;}
						else if (diffE> m.turnRate)	{diffE= m.turnRate; canFire=false;}
						m.elevation+=diffE;

						if (canFire)	// if within range and ready to fire
						{
							if (ship.energy>m.damage)
							{
								m.ttf = m.fireDelay + 1;
								if (targObj is HullBlock)
									Projectiles.push(new Projectile(turX, turY, turZ,	interceptV.x, interceptV.y, interceptV.z, targObj, BulletFXs[m.type], m.damage, m.range / m.speed, m.type));
								else if (m.type=="tractorS" && targObj is DropItem)
								{
									EffectEMs["flash"].emit(targObj.px,targObj.py,targObj.pz,0,0,0,1);
									if ((DropItem)(targObj).tractorIn(turX,turY,turZ,ship))
									//if ((DropItem)(targObj).tractorTo(interceptV))
									{
										EffectEMs["wave"].emit(targObj.px,targObj.py,targObj.pz,0,0,0,5/100);
										DropItems.splice(DropItems.indexOf((DropItem)(targObj)),1);
									}
								}
								else if (targObj is Projectile)
								{	// target is projectile
									(Projectile)(targObj).projIntegrity -= m.damage;	// prevent double targeting
									var p:Projectile = new Projectile(turX, turY, turZ,	interceptV.x, interceptV.y, interceptV.z, targObj, BulletFXs[m.type], m.damage, interceptV.w, m.type);
									if (m.type=="gunFlakS") setAsFlakProjectile(ship,p);
									Projectiles.push(p);
								}

								ship.energy -= m.damage;
								muzzleFlash(turX,turY,turZ,interceptV.x,interceptV.y,interceptV.z,m.muzzleLen,m.damage);
								playSound(turX,turY,turZ,m.type);
							}
						}

						// ----- if turret is on screen then prep for render
						if (posnIsOnScreen(turX,turY,turZ))
						{
							// ----- do turret recoil fx
							var recoil:Number = m.ttf/m.fireDelay;
							if (recoil<0) recoil=0;
							var Tlocal:Matrix4x4 = new Matrix4x4(1,0,0,0,0,1,0,0,0,0,1,-recoil*m.fireDelay*0.002).rotX(-m.elevation).rotY(m.bearing);	// turret transform local

							// ----- orientate turret
							var turMP:MeshParticles = TurretMPs[m.type];
							turMP.nextLocRotScale(T.mult(Tlocal));

							// ----- orientate frame
							if (m.type.charAt(m.type.length-1)=='M')
							{
								Tlocal = new Matrix4x4().translate(0,-1.57,0).rotX(-m.elevation*0.001).rotY(m.bearing);
								var MTg:Matrix4x4 = T.mult(Tlocal);
								if (Mesh.viewT.ca*MTg.ab + Mesh.viewT.cb*MTg.bb + Mesh.viewT.cc*MTg.cb<0.6)	// if frameS not facing away from camera, render
									frameM_MP.nextLocRotScale(MTg);
							}
							else
							{
								Tlocal = new Matrix4x4().translate(0,-0.71,0).rotX(-m.elevation*0.001).rotY(m.bearing);
								var STg:Matrix4x4 = T.mult(Tlocal);
								if (Mesh.viewT.ca*STg.ab + Mesh.viewT.cb*STg.bb + Mesh.viewT.cc*STg.cb<0.6)	// if frameS not facing away from camera, render
									frameS_MP.nextLocRotScale(STg);
							}
						}
					}

					m.ttf--;	// time to fire
				}
			}//endfor

			return M.length;
		}//endfunction

		//===============================================================================================
		// finds nearest hittable ship hull, modifies interceptV
		//===============================================================================================
		[Inline]
		private final function nearestTargShipHull(turX:Number,turY:Number,turZ:Number,pspeed:Number,ship:Ship,interceptV:Vector3D):HullBlock
		{
			var targObj:HullBlock = null;	// targ current position & vel

			for (var st:int=ship.targets.length-1; st>-1; st--)
			{
				var targ:Hull = ship.targets[st];
				var dvx:Number = targ.vel.x - ship.vel.x;	// diff in speed between 2 ships
				var dvy:Number = targ.vel.y - ship.vel.y;
				var dvz:Number = targ.vel.z - ship.vel.z;
				var targCV:Vector3D =
				interceptVector3(pspeed,					// projectile speed
									targ.posn.x-turX,targ.posn.y-turY,targ.posn.z-turZ,	// target ship posn from turret
									dvx,dvy,dvz,						// target vel from turret
									(interceptV.w*pspeed+targ.radius*2)/pspeed);		// cutoff T
				if (targCV!=null)			// chk ship is in range culling
					for (var j:int=targ.hullConfig.length-1; j>-1; j--)
					{
						var tPt:HullBlock = targ.hullConfig[j];
						var iV:Vector3D =
						interceptVector3(pspeed,	// projectile speed
										tPt.extPosn.x-turX,tPt.extPosn.y-turY,tPt.extPosn.z-turZ,	// target block posn from turret
										dvx,dvy,dvz,			// target vel from turret
										interceptV.w);		// cutoff time
						if (iV!=null &&	!ship.hullSkin.lineHitsMesh(turX,turY,turZ,iV.x*iV.w,iV.y*iV.w,iV.z*iV.w,ship.skin.transform))	// does not hit self
						{
							targObj = tPt;
							interceptV.x = iV.x+ship.vel.x;
							interceptV.y = iV.y+ship.vel.y;
							interceptV.z = iV.z+ship.vel.z;
							interceptV.w = iV.w;
						}
					}//endfor j
			}//endfor st

			return targObj;
		}//endfunction

		//===============================================================================================
		// finds nearest interceptable incoming projectile, modifies interceptV
		//===============================================================================================
		[Inline]
		private final function nearestTargProjectile(turX:Number,turY:Number,turZ:Number,pspeed:Number,ship:Ship,interceptV:Vector3D):Projectile
		{
			var targObj:Projectile = null;	// targ current position & vel

			for (var j:int=Projectiles.length-1; j>-1; j--)
			{
				var pp:Projectile = Projectiles[j];
				if (pp.targ is HullBlock && pp.targ.parent==ship && Projectiles[j].projIntegrity>0)
				{
					var ipV:Vector3D =
					interceptVector3(pspeed, 	// projectile speed
									pp.px-turX,pp.py-turY,pp.pz-turZ, 	// target block posn from turret
									pp.vx-ship.vel.x,pp.vy-ship.vel.y,pp.vz-ship.vel.z,	// target vel from turret
									interceptV.w);		// cutoff time
					if (ipV!=null &&
						!ship.hullSkin.lineHitsMesh(turX,turY,turZ,ipV.x*ipV.w,ipV.y*ipV.w,ipV.z*ipV.w,ship.skin.transform))	// does not hit self
					{
						targObj = pp;
						interceptV.x = ipV.x+ship.vel.x;
						interceptV.y = ipV.y+ship.vel.y;
						interceptV.z = ipV.z+ship.vel.z;
						interceptV.w = ipV.w;
					}
				}
			}

			return targObj;
		}//endfunction

		//===============================================================================================
		// finds direction to nearest drop item, returns drop item, modifies interceptV
		//===============================================================================================
		[Inline]
		private final function nearestTargDropItem(turX:Number,turY:Number,turZ:Number,ship:Ship,interceptV:Vector3D):Projectile
		{
			var targObj:DropItem = null;	// targ current position & vel
			interceptV.w = 10000;

			for (var j:int=DropItems.length-1; j>-1; j--)
			{
				var pp:DropItem = DropItems[j];
				if (pp.projIntegrity==1)
				{
					var dx:Number = pp.px-turX;
					var dy:Number = pp.py-turY;
					var dz:Number = pp.pz-turZ;
					var dl:Number = Math.sqrt(dx*dx+dy*dy+dz*dz);
					if (dl<interceptV.w && !ship.hullSkin.lineHitsMesh(turX,turY,turZ,pp.px-turX,pp.py-turY,pp.pz-turZ,ship.skin.transform))
					{
						if (targObj!=null) targObj.projIntegrity = 1;
						targObj = pp;
						pp.projIntegrity = 0;
						interceptV.x = dx;
						interceptV.y = dy;
						interceptV.z = dz;
						interceptV.w = dl;
					}//endif
				}//endif
			}//endfor

			return targObj;
		}//endfunction

		//===============================================================================================
		// launches 4 missiles in sequence from launcher position
		//===============================================================================================
		private function launch4Missiles(targObj:Object,m:Module,shp:Ship):void
		{
			var delay:int = 30;
			var launchFn:Function = function():void
			{
				if (delay%10==0)
				{
					var T:Matrix4x4 = new Matrix4x4().rotFromTo(0,1,0,m.nx,m.ny,m.nz).translate(m.x+m.nx*0.6,m.y+m.ny*0.6,m.z+m.nz*0.6);
					T = shp.skin.transform.mult(T);	// turret global space
					var ang:Number = delay/20*Math.PI;
					var px:Number = Math.sin(ang)*0.25;
					var py:Number = 0;
					var pz:Number = Math.cos(ang)*0.25;
					var tpx:Number = T.aa*px+T.ab*py+T.ac*pz+T.ad;
					var tpy:Number = T.ba*px+T.bb*py+T.bc*pz+T.bd;
					var tpz:Number = T.ca*px+T.cb*py+T.cc*pz+T.cd;
					var vx:Number = shp.vel.x+T.ab*m.speed;	// vel straight up from launcher
					var vy:Number = shp.vel.y+T.bb*m.speed;
					var vz:Number = shp.vel.z+T.cb*m.speed;
					var mp:Missile = new Missile(tpx, tpy, tpz,	vx,vy,vz, targObj, BulletFXs[m.type], m.damage/4, m.range/m.speed, m.type);
					muzzleFlash(tpx,tpy,tpz, vx,vy,vz,0.1,m.damage/4);
					Projectiles.push(mp);
				}
				if (delay==0)
					stepFns.splice(stepFns.indexOf(launchFn),1);	// remove this function
				else
					delay--;
			};
			stepFns.push(launchFn);
		}//endfunction

		//===============================================================================================
		// sets given projectile to explode on destruct and damage nearby projectiles
		//===============================================================================================
		private final function setAsFlakProjectile(firer:Ship,p:Projectile):void
		{
			p.onDestroy = function():void
			{
				(ParticlesEmitter)(EffectEMs["bit"]).batchEmit(10, p.px,p.py,p.pz, 0, 0, 0, 0.15);
				(ParticlesEmitter)(EffectEMs["wave"]).emit(p.px,p.py,p.pz,0,0,0,5/100);

				var delay:int = 10;
				var delayedDestroy:Function = function():void
				{
					delay--;
					if (delay>0) return;

					for (var j:int=Projectiles.length-1; j>-1; j--)
					{
						var op:Projectile = Projectiles[j];
						var dx:Number = p.px-op.px;
						var dy:Number = p.py-op.py;
						var dz:Number = p.pz-op.pz;
						if (op.targ is HullBlock && op.targ.parent==firer && dx*dx+dy*dy+dz*dz<7)
						{
							if (op.integrity<=p.integrity)
							{
								(ParticlesEmitter)(EffectEMs["flash"]).emit(op.px, op.py, op.pz, 0, 0, 0, Math.sqrt(op.integrity)/10);
								op.ttl=0;
							}
							else
								(ParticlesEmitter)(EffectEMs["flash"]).emit(op.px, op.py, op.pz, 0, 0, 0, Math.sqrt(p.integrity)/10);
							op.projIntegrity -= p.integrity;
							op.integrity -= p.integrity;
						}
					}//endfor

					stepFns.splice(stepFns.indexOf(delayedDestroy),1);	// remove this function
				};//endfunction
				stepFns.push(delayedDestroy);

			};//endfunction
		}//endfunction

		//===============================================================================================
		// simulates thruster glow
		//===============================================================================================
		[Inline]
		private final function simulateThrusterS(ship:Ship,m:Module):void
		{
			var pt:Vector3D = ship.skin.transform.transform(new Vector3D(m.x+m.nx*0.7,m.y+m.ny*0.7,m.z+m.nz*0.7));
			if (posnIsOnScreen(pt.x,pt.y,pt.z))
			{
				var dir:Vector3D = ship.skin.transform.rotateVector(new Vector3D(m.nx,m.ny,m.nz));
				var thrustSc:Number = Math.min(2,ship.vel.length/ship.maxSpeed*0.8 + 0.2);
				(MeshParticles)(EffectMPs["thrustConeW"]).nextLocDirScale(pt.x,pt.y,pt.z,dir.x,dir.y,dir.z,thrustSc*(1+Math.random()*0.1));
				(MeshParticles)(EffectMPs["thrustConeM"]).nextLocDirScale(pt.x,pt.y,pt.z,dir.x,dir.y,dir.z,thrustSc*(1+Math.random()*0.1));
				(MeshParticles)(EffectMPs["thrustConeN"]).nextLocDirScale(pt.x,pt.y,pt.z,dir.x,dir.y,dir.z,thrustSc*(1+Math.random()*0.1));
			}
		}//endfunction

		//===============================================================================================
		// convenience function to add muzzle flash to turrets
		//===============================================================================================
		private final function muzzleFlash(px:Number,py:Number,pz:Number,nx:Number,ny:Number,nz:Number,muzzleLen:Number,pwr:Number) : void
		{
			var _dl:Number = 1/Math.sqrt(nx*nx+ny*ny+nz*nz);
			px += muzzleLen*nx*_dl;
			py += muzzleLen*ny*_dl;
			pz += muzzleLen*nz*_dl;
			var sw:int = stage.stageWidth;
			var sh:int = stage.stageHeight;
			var ttl:int=3;
			var flashStep:Function = function():void
			{
				var id:String = "thrustConeN";
				if (ttl==2) id = "thrustConeM";
				else if (ttl==1) id = "thrustConeW";
				else if (ttl<=0) stepFns.splice(stepFns.indexOf(flashStep),1);
				var scpt:Vector3D = Mesh.screenPosn(px,py,pz);			// offscreen culling
				if (scpt.z>0 && scpt.x>0 && scpt.x<sw && scpt.y>0 && scpt.y<sh)	// is on screen
					(MeshParticles)(EffectMPs[id]).nextLocDirScale(px,py,pz,nx,ny,nz,Math.sqrt(pwr)/9);
				ttl--;
			};
			stepFns.push(flashStep);
		}//endfunction

		//===============================================================================================
		// ----- do damage FX --------------------------
		//===============================================================================================
		[Inline]
		private final function doShipDamageFx(ship:Ship):void
		{
			var T:Matrix4x4 = ship.skin.transform;
			var rv:Vector3D = new Vector3D();
			for (var j:int=ship.damagePosns.length-1; j>-1; j--)
			{
				var pt:VertexData = ship.damagePosns[j];
				pt.u-=pt.w;
				if (pt.u<=0)
				{
					var px:Number = T.aa*pt.vx + T.ab*pt.vy + T.ac*pt.vz + T.ad;
					var py:Number = T.ba*pt.vx + T.bb*pt.vy + T.bc*pt.vz + T.bd;
					var pz:Number = T.ca*pt.vx + T.cb*pt.vy + T.cc*pt.vz + T.cd;
					if (posnIsOnScreen(px,py,pz))
					{
						var nx:Number = T.aa*pt.nx + T.ab*pt.ny + T.ac*pt.nz;
						var ny:Number = T.ba*pt.nx + T.bb*pt.ny + T.bc*pt.nz;
						var nz:Number = T.ca*pt.nx + T.cb*pt.ny + T.cc*pt.nz;
						var mag:Number = Math.sqrt(pt.w);
						if (Math.random()<0.5)
						{
							mag *= 0.003;
							(ParticlesEmitter)(EffectEMs["blast"]).emit(px,py,pz,ship.vel.x+nx*mag,ship.vel.y+ny*mag,ship.vel.z+nz*mag,mag*5);
						}
						else
						{
							mag *= 0.012;
							randV3values(0.1,rv);
							var dp:Number = rv.x*nx + rv.y*ny + rv.z*nz;
							if (dp<0)
							{
								rv.x+=dp*2*nx;
								rv.y+=dp*2*ny;
								rv.z+=dp*2*nz;
							}
							(ParticlesEmitter)(EffectEMs["sparks"]).emit(px,py,pz,ship.vel.x+nx*mag+rv.x,ship.vel.y+ny*mag+rv.y,ship.vel.z+nz*mag+rv.z,0.5);
						}
					}
					pt.u=50;
				}
			}
		}//endfunction

		//===============================================================================================
		// force ship to move away
		//===============================================================================================
		[Inline]
		private final function doShipSeparation(ship:Ship):void
		{
			// ----- ensure separation between ships ----------------------
			for (var j:int=Entities.length-1; j>=0; j--)
			{
				var other:Hull = Entities[j];
				if (other!=ship)
				{
					var dx:Number = other.posn.x - ship.posn.x;
					var dy:Number = other.posn.y - ship.posn.y;
					var dz:Number = other.posn.z - ship.posn.z;
					var dlSq:Number = dx*dx+dy*dy+dz*dz;
					if (dlSq<(ship.radius+other.radius)*(ship.radius+other.radius))
					{
						var _dl:Number = 1/Math.sqrt(dlSq);
						ship.vel.x -= dx*_dl*ship.maxAccel;	// move ship away
						ship.vel.y -= dy*_dl*ship.maxAccel;
						ship.vel.z -= dz*_dl*ship.maxAccel;
					}//endif
				}
			}//endfor
		}//endfunction

		//===============================================================================================
		// simulate ships destruction
		//===============================================================================================
		private function explodingStep() : void
		{
			for (var j:int=Exploding.length-1; j>-1; j--)
			{
				var ship:Ship = Exploding[j];
				var hb:HullBlock = null;
				if (ship.tte<=0)
				{
					playSound(ship.posn.x,ship.posn.y,ship.posn.z,"explosion");
					ship.updateStep();
					for (var k:int=ship.hullConfig.length-1; k>-1; k--)
					{	// create final blasts
						hb = ship.hullConfig[k];
						var rand:Vector3D = new Vector3D(Math.random()-0.5,Math.random()-0.5,Math.random()-0.5);
						rand.scaleBy(0.1*Math.random()/rand.length);
						(ParticlesEmitter)(EffectEMs["blast"]).emit(hb.extPosn.x,hb.extPosn.y,hb.extPosn.z,rand.x,rand.y,rand.z,Math.random()*0.2+0.8);
					}
					(ParticlesEmitter)(EffectEMs["wave"]).emit(ship.posn.x,ship.posn.y,ship.posn.z,0,0,0,ship.radius*10/100);
					world.removeChild(ship.skin);
					Exploding.splice(j,1);
				}
				else
				{	// ----- do multiple hull explosions
					var dir:Vector3D = new Vector3D();
					for (var i:int=ship.hullConfig.length-1; i>-1; i--)
					{
						hb = ship.hullConfig[i];
						var pt:Vector3D = ship.skin.transform.transform(new Vector3D(hb.x,hb.y,hb.z));
						randV3values(10000,dir);
						var hitPt:VertexData = ship.hullSkin.lineMeshIntersection(pt.x,pt.y,pt.z,dir.x,dir.y,dir.z,ship.skin.transform);
						if (hitPt!=null && posnIsOnScreen(hitPt.vx+hitPt.nx*0.3,hitPt.vy+hitPt.ny*0.3,hitPt.vz+hitPt.nz*0.3))
						{
							(ParticlesEmitter)(EffectEMs["flash"]).emit(hitPt.vx+hitPt.nx*0.3,hitPt.vy+hitPt.ny*0.3,hitPt.vz+hitPt.nz*0.3,0,0,0,Math.random()*0.5+0.5);
							(ParticlesEmitter)(EffectEMs["bit"]).batchEmit(3,hitPt.vx+hitPt.nx*0.3,hitPt.vy+hitPt.ny*0.3,hitPt.vz+hitPt.nz*0.3,hitPt.nx*0.3,hitPt.ny*0.3,hitPt.nz*0.3,0.3);
						}
					}//endfor

					// ----- tumble ship
					ship.skin.transform = ship.skin.transform.translate(-ship.posn.x,-ship.posn.y,-ship.posn.z);
					ship.skin.transform = ship.skin.transform.rotate(ship.vel.x,ship.vel.y,ship.vel.z);
					ship.skin.transform = ship.skin.transform.translate(ship.posn.x, ship.posn.y, ship.posn.z);
					ship.hullSkin.material.ambR += 0.02;
					simulateShipTurrets(ship,false);
					ship.tte--;
				}
			}//endfor
		}//endfunction

		//===============================================================================================
		// kill and remove ship from world
		//===============================================================================================
		private function destroyShip(ship:Ship):void
		{
			ship.vel = randV3values(0.01);
			Exploding.push(ship);
			playSound(ship.posn.x,ship.posn.y,ship.posn.z,"hullGroan"+(1+Math.round(Math.random())));
			removeEntity(ship);
			world.addChild(ship.skin);	// add back ship skin for explosion fx

			var itmI:int = ship.hullConfig.length-1;
			var modI:int = ship.modulesConfig.length-1;

			var dropFn:Function = function():void
			{
				var A:Array = ["RawM","RawR","RawT"];
				// ----- drop RawM items
				if (itmI>-1)
				{
					var h:HullBlock = ship.hullConfig[itmI--];
					var v:Vector3D = new Vector3D(Math.random()-0.5,Math.random()-0.5,Math.random()-0.5);
					v.scaleBy(0.6*Math.random()/v.length);
					addDropItemToScene(A[int(A.length*Math.random())],h.extPosn.x,h.extPosn.y,h.extPosn.z,v.x,v.y,v.z);
				}//endfor

				// ----- drop RawT/RawR items
				if (modI>-1)
				{
					var m:Module = ship.modulesConfig[modI--];
					v = new Vector3D(Math.random()-0.5,Math.random()-0.5,Math.random()-0.5);
					v.scaleBy(0.6*Math.random()/v.length);
					if (EffectMPs[m.type]!=null)	// drops the mounted gun
						addDropItemToScene(m.type,h.extPosn.x,h.extPosn.y,h.extPosn.z,v.x,v.y,v.z);
				}//endfor

				if (itmI<=-1 && modI<=-1)
					stepFns.splice(stepFns.indexOf(dropFn),1);
			}//endfunction
			stepFns.push(dropFn);
		}//endfunction

		//===============================================================================================
		// cleanly remove entity from world
		//===============================================================================================
		private function removeEntity(e:Hull):void
		{
			for (var i:int=Entities.length-1; i>-1; i--)
				if (Entities[i] is Ship)
				{
					var T:Vector.<Hull> = (Ship)(Entities[i]).targets;
					if (T.indexOf(e)!=-1)	T.splice(T.indexOf(e),1);
				}
			if (Entities.indexOf(e)!=-1) 		Entities.splice(Entities.indexOf(e),1);
			if (Friendlies.indexOf(e)!=-1) 	Friendlies.splice(Friendlies.indexOf(e),1);
			if (Hostiles.indexOf(e)!=-1) 		Hostiles.splice(Hostiles.indexOf(e),1);
			world.removeChild(e.skin);
			if (focusedEntity==e && Friendlies.length>0)
				focusOn(Friendlies[0]);
		}//endfunction

		//===============================================================================================
		// drop pickUp items
		//===============================================================================================
		private function addDropItemToScene(itmId:String,px:Number,py:Number,pz:Number,vx:Number,vy:Number,vz:Number) : Projectile
		{
			var rvQ:Vector3D = new Vector3D(Math.random()-0.5,Math.random()-0.5,Math.random()-0.5);			// tumbling quaternion
			var rotSpeed:Number = Math.random()*0.2;
			rvQ.scaleBy(Math.sin(rotSpeed/2)/rvQ.length);
			rvQ.w = Math.cos(rotSpeed/2);

			var oQ:Vector3D = new Vector3D(0,0,0,1);	// starting identity quaternion
			var itmMp:MeshParticles = null;
			if (TurretMPs[itmId]!=null)
				itmMp = TurretMPs[itmId];
			else
				itmMp = EffectMPs[itmId];
			var p:DropItem = new DropItem(px,py,pz,vx,vy,vz,
			function():void {
				oQ = Matrix4x4.quatMult(rvQ,oQ);		// increment rotation
				var T:Matrix4x4 = Matrix4x4.quaternionToMatrix(oQ.w,oQ.x,oQ.y,oQ.z);
				T.ad = p.px;
				T.bd = p.py;
				T.cd = p.pz;
				itmMp.nextLocRotScale(T,1);				// item icon
				EffectEMs["reticle"].emit(p.px,p.py,p.pz,0,0,0,1);	//
			},0,100000,itmId);

			DropItems.push(p);
			return p;
		}//endfunction

		//===============================================================================================
		// creates and adds a random ship to world
		//===============================================================================================
		private function addShipToScene(friendly:Boolean,dist:Number=30,config:String=null) : Ship
		{
			var ship:Ship = null;
			if (friendly)
			{
				if (config!=null)	ship = Ship.createShipFromConfigStr(Assets,config,Mtls["TexPanel"],Mtls["SpecPanel"]);
				else							ship = Ship.createRandomShip(Assets,Math.random()*15+5,Math.random()*6+1,Mtls["TexPanel"],Mtls["SpecPanel"]);
				Friendlies.push(ship);
				ship.targets = Hostiles;
				setDumbAI(ship);
			}
			else
			{
				if (config!=null)	ship = Ship.createShipFromConfigStr(Assets,config,Mtls["SpecPanel"],Mtls["TexPanel"]);
				else							ship = Ship.createRandomShip(Assets,Math.random()*15+5,Math.random()*6+1,Mtls["SpecPanel"],Mtls["TexPanel"]);
				Hostiles.push(ship);
				ship.targets = Friendlies;
				setDumbAI(ship);
			}
			ship.modulesSkin.material.setTexMap(Mtls["Tex"]);
			ship.modulesSkinExt.material.setTexMap(Mtls["Tex"]);
			world.addChild(ship.skin);
			Entities.push(ship);
			var ang:Number = Math.random()*Math.PI*2;
			ship.posn.x = Math.sin(ang)*dist;
			ship.posn.z = Math.cos(ang)*dist;
			ship.setFacing(ang);

			return ship;
		}//endfunction

		//===============================================================================================
		// hyper jump out
		//===============================================================================================
		private function jumpOut(ship:Ship,bearing:Number,callBack:Function=null) : void
		{
			var ttJump:int = 120;
			var sw:int = stage.stageWidth;
			var sh:int = stage.stageHeight;
			var M:Vector.<Module> = ship.modulesConfig;

			ship.stepFn = function():void
			{
				var jumpDir:Vector3D = new Vector3D(Math.sin(bearing),0,Math.cos(bearing));
				if (ttJump>=0)
				{
					ship.moveTowardsStep(ship.posn.add(jumpDir));
					ship.vel.scaleBy(0.5);	// slow ship down
					var facing:Vector3D = ship.getFacing();
					if (facing.dotProduct(jumpDir)<0.98 && ttJump==0)
						ttJump++;		// force complete turn before jump
				}
				else
				{
					ship.vel.x += -0.04*ttJump*jumpDir.x;	// accel ship
					ship.vel.y += -0.04*ttJump*jumpDir.y;
					ship.vel.z += -0.04*ttJump*jumpDir.z;
					ship.moveTowardsStep(ship.posn.add(jumpDir));
				}

				ttJump--;

				for (var i:int=M.length-1; i>-1; i--)
				{
					var m:Module = M[i];
					if (m.type.substring(0,8)=="thruster")
					{
						var pt:Vector3D = ship.skin.transform.transform(new Vector3D(m.x+m.nx*0.7,m.y+m.ny*0.7,m.z+m.nz*0.7));
						var scpt:Vector3D = Mesh.screenPosn(pt.x,pt.y,pt.z);			// offscreen culling
						if (scpt.z>0 && scpt.x>0 && scpt.x<sw && scpt.y>0 && scpt.y<sh)	// is on screen
						{
							var dir:Vector3D = ship.skin.transform.rotateVector(new Vector3D(m.nx,m.ny,m.nz));
							var rand:Vector3D = new Vector3D(Math.random()-0.5,Math.random()-0.5,Math.random()-0.5);
							if (ttJump<0)
							{
								rand.scaleBy(0.005/rand.length);
								(ParticlesEmitter)(EffectEMs["hyperCharge"]).emit(pt.x,pt.y,pt.z,dir.x*0.15+rand.x,dir.y*0.15+rand.y,dir.z*0.15+rand.z,1);
							}
							else
							{
								rand.scaleBy(1/rand.length);
								var dp:Number = rand.dotProduct(dir);
								if (dp<0)
									rand = new Vector3D(rand.x-dir.x*dp*2,rand.y-dir.y*dp*2,rand.z-dir.z*dp*2);
								(ParticlesEmitter)(EffectEMs["hyperCharge"]).emit(pt.x+rand.x,pt.y+rand.y,pt.z+rand.z,-rand.x*0.15,-rand.y*0.15,-rand.z*0.15,0.3);
							}
						}
					}
				}//endfor

				if (ttJump<-15)
				{
					(ParticlesEmitter)(EffectEMs["hyperspace"]).emit(ship.posn.x,ship.posn.y,ship.posn.z,0,0,0,ship.radius*3/100);
					playSound(ship.posn.x,ship.posn.y,ship.posn.z,"jumpIn");
					removeEntity(ship);
					if (callBack!=null) callBack();
				}
			};//endfunction
		}//endfunction

		//===============================================================================================
		// hyper jump in ship given x,y,z position and w=bearing
		//===============================================================================================
		private function jumpIn(ship:Ship,px:Number,pz:Number,bearing:Number,callBack:Function=null) : void
		{
			var initialSpeed:Number = 5;
			var dist:Number = initialSpeed/(1-ship.slowF);
			var sinB:Number = Math.sin(bearing);
			var cosB:Number = Math.cos(bearing);
			ship.posn.x = px-dist*sinB;
			ship.posn.z = pz-dist*cosB;
			ship.setFacing(bearing);
			ship.vel.x = initialSpeed*sinB;
			ship.vel.z = initialSpeed*cosB;
			var sw:int = stage.stageWidth;
			var sh:int = stage.stageHeight;
			(ParticlesEmitter)(EffectEMs["hyperspace"]).emit(ship.posn.x,ship.posn.y,ship.posn.z,0,0,0,ship.radius*3/100);
			playSound(ship.posn.x,ship.posn.y,ship.posn.z,"jumpIn");
			ship.updateStep();

			var oldStep:Function = ship.stepFn;

			ship.stepFn = function():void
			{
				var M:Vector.<Module> = ship.modulesConfig;
				for (var i:int=M.length-1; i>-1; i--)
				{
					var m:Module = M[i];
					if (m.type.substring(0,8)=="thruster")
					{
						var pt:Vector3D = ship.skin.transform.transform(new Vector3D(m.x+m.nx*0.7,m.y+m.ny*0.7,m.z+m.nz*0.7));
						var scpt:Vector3D = Mesh.screenPosn(pt.x,pt.y,pt.z);			// offscreen culling
						if (scpt.z>0 && scpt.x>0 && scpt.x<sw && scpt.y>0 && scpt.y<sh)	// is on screen
						{
							var dir:Vector3D = ship.skin.transform.rotateVector(new Vector3D(m.nx,m.ny,m.nz));
							(MeshParticles)(EffectMPs["thrustConeW"]).nextLocDirScale(pt.x,pt.y,pt.z,dir.x,dir.y,dir.z,1);
							var rand:Vector3D = new Vector3D(Math.random()-0.5,Math.random()-0.5,Math.random()-0.5);
							rand.scaleBy(0.005/rand.length);
							(ParticlesEmitter)(EffectEMs["hyperCharge"]).emit(pt.x,pt.y,pt.z,dir.x*0.15+rand.x,dir.y*0.15+rand.y,dir.z*0.15+rand.z,1);
						}
					}
				}//endfor
				if (ship.vel.length<0.01)
				{
					ship.stepFn = oldStep;
					if (callBack!=null) callBack();
				}
			}//endfunction
		}//endfunction

		//===============================================================================================
		// allow user to steer ship
		//===============================================================================================
		private function setPlayerAI(ship:Ship):void
		{
			setDumbAI(ship);
			var dumbStepFn:Function = ship.stepFn;
			ship.stepFn = function():void
			{
				if (focusedShip==ship)
				{	// allow user control
					var ang:Number = Input.yaw*ship.maxRotAccel;
					var sinA2:Number = Math.sin(ang/2);
					var cross:Vector3D = new Vector3D(0,1,0);
					ship.rotAccel = new Vector3D(sinA2*cross.x,sinA2*cross.y,sinA2*cross.z,Math.cos(ang/2));
					ship.accel = ship.maxAccel*Input.thrust;
					ship.rotVel = Matrix4x4.quatMult(ship.rotAccel,ship.rotVel);
					var curF:Vector3D = ship.skin.transform.rotateVector(new Vector3D(0,0,1));
					ship.vel.x += curF.x*ship.accel;	// increment vel
					ship.vel.y += curF.y*ship.accel;
					ship.vel.z += curF.z*ship.accel;
				}
				else
					dumbStepFn();	// AI control
			}//endfunction
		}//endfunction

		//===============================================================================================
		//
		//===============================================================================================
		private function setDumbAI(ship:Ship):void
		{
			ship.stepFn = function():void
			{
				// ----- seek target to move towards
				var T:Vector.<Hull> = ship.targets;
				var targ:Hull = null;
				var dlSq:Number = Number.MAX_VALUE;
				if (T!=null)
				for (var j:int=T.length-1; j>=0; j--)
				{
					var other:Hull = T[j];
					var dx:Number = other.posn.x - ship.posn.x;
					var dy:Number = other.posn.y - ship.posn.y;
					var dz:Number = other.posn.z - ship.posn.z;
					if (dlSq>dx*dx+dy*dy+dz*dz)
					{
						targ = other;
						dlSq = dx*dx+dy*dy+dz*dz;
					}
				}//endfor

				// ----- move towards target keeping targDist
				if (targ!=null)
				{
					var targDist:Number = (ship.radius+other.radius)*10;
					if (ship.engageEnemy)
						targDist = (ship.radius+other.radius)*2;

					var dv:Vector3D = targ.posn.subtract(ship.posn);	// vector to ship

					var f:Number = Math.sqrt(1/(Math.abs(dv.length-targDist)+1));

					if (dv.length-targDist<0)	dv.scaleBy(-1/dv.length);
					else											dv.scaleBy( 1/dv.length);

					var pv:Vector3D = new Vector3D(dz,0,-dx);	// perpenticular vector
					var facing:Vector3D = ship.getFacing();
					if (facing.x*dz-facing.z*dx<0)
						pv.scaleBy(-1);
					pv.normalize();

					// travel vector
					var tv:Vector3D = new Vector3D(dv.x*(1-f)+pv.x*f,dv.y*(1-f)+pv.y*f,dv.z*(1-f)+pv.z*f);
					//tv.scaleBy(ship.radius*1.2/tv.length);
					var tp:Vector3D = ship.posn.add(tv);
					//(ParticlesEmitter)(EffectEMs["flareWhite"]).emit(tp.x,tp.y,tp.z,0,0,0,1);		// debug
					ship.moveTowardsStep(tp);
				}//endif
			}//endfunction
		}//endfunction

		//===============================================================================================
		// the main menu in home scene
		//===============================================================================================
		private function showAsteroidMineMenu():void
		{
			var thisRef:SpaceCrafter = this;
			optionsMenu =
			MenuUI.createLeftStyleMenu(thisRef,
					new < String > ["Mine Asteroid","Back"],
					new < Function>[function():void	{
														Friendlies[int(Friendlies.length*Math.random())].targets = new <Hull>[focusedEntity];
														focusOn(Friendlies[int(Friendlies.length*Math.random())]);
													},
													function():void {focusOn(Friendlies[int(Friendlies.length*Math.random())]);}]);
			optionsMenu.y = subTitle.y+subTitle.height;
		}//endfunction

		//===============================================================================================
		// the main menu in home scene
		//===============================================================================================
		private function showShipMainMenu():void
		{
			var thisRef:SpaceCrafter = this;
			optionsMenu =
			MenuUI.createLeftStyleMenu(thisRef,
					new < String > ["Find Opponent","Configure Ship"],
					new < Function>[function ():void	{galaxyScene(function():void {battleScene(userData.shipsConfig);});},
													showShipModifyMenu]);
			optionsMenu.y = subTitle.y+subTitle.height;
			mainTitle.name = focusedShip.name+" : Home Base";
		}//endfunction

		//===============================================================================================
		// Main menu to start editing ship config
		//===============================================================================================
		private function showShipModifyMenu():void
		{
			var thisRef:SpaceCrafter = this;
			optionsMenu =
			MenuUI.createLeftStyleMenu(thisRef,
										new < String > ["Extend Hull","Place Modules","Remove Modules/Hull","Import RMF","Back"],
										new < Function>[function():void {showShipEditMenu("Extend Hull",extendChassisStep,showShipModifyMenu);},
														function():void {modulesSelectMenu(showShipModifyMenu)},
														function():void {showShipEditMenu("Remove Modules/Hull",trimChassisStep,showShipModifyMenu);},
														function():void {
															MenuUI.createConfirmDialog(thisRef,"ReImport RMF?",
																									new icoTick().bitmapData,
																									new icoCross().bitmapData,
																									function(confirm:Boolean):void
																									{
																										if (confirm)
																										convToRmf(['3D/shipsWheel.obj','3D/RawM.obj','3D/RawR.obj','3D/RawT.obj',
																													'3D/launcherSmallExt.obj',
																													'3D/thrusterSmallExt.obj',
																													'3D/mountSmallExt.obj',
																													'3D/mountMediumExt.obj',
																													'3D/tractorSmall.obj',
																													'3D/missileSmall.obj',
																													'3D/launcherSmall.obj',
																													'3D/hullPosnMkr.obj',
																													'3D/thrusterSmall.obj',
																													'3D/mountSmall.obj',
																													'3D/frameSmall.obj',
																													'3D/mountMedium.obj',
																													'3D/frameMedium.obj',
																													'3D/gunAutoSmall.obj',
																													'3D/gunFlakSmall.obj',
																													'3D/gunIonSmall.obj',
																													'3D/gunPlasmaSmall.obj',
																													'3D/gunRailSmall.obj',
																													'3D/railGunMedium.obj',
																													'3D/blasterMedium.obj',
																													'3D/laserMedium.obj'],
																													showShipModifyMenu);	// init game after done parsing??!!
																										else
																											showShipModifyMenu();
																									});
																	},
													showShipMainMenu]);
			optionsMenu.y = subTitle.y+subTitle.height;
			mainTitle.name = focusedShip.name+" : Outfit StarShip";
		}//endfunction

		//===============================================================================================
		// generic ship editing function menu
		//===============================================================================================
		private function showShipEditMenu(title:String,editStepFn:Function,callBack:Function):void
		{
			// ----- change to spaceshipHum and darken env
			playAmbientLoop("spaceshipHum");
			var planets:Mesh = sky.getChildAt(0);
			planets.setLightingParameters(0.2,0.2,0.2,0,0,false,true);
			sky.material.setAmbient(0.2,0.2,0.2);
			var prevHideShipsWheel:Boolean = ShipHUD.hideShipsWheel;
			ShipHUD.hideShipsWheel = true;
			focusedShip.hullSkin.material.setTexMap(Mtls["TexTrans"]);		// set hull skin transparent
			focusedShip.skin.removeChild(focusedShip.modulesSkinExt);
			focusedShip.skin.addChild(focusedShip.modulesSkin);
			var oldCallBack:Function = callBack;
			callBack = function():void
			{
				playAmbientLoop("spaceAmbience");
				planets.setLightingParameters(0,0,0,0,0,true,true);
				sky.material.setAmbient(1,1,1);
				ShipHUD.hideShipsWheel = prevHideShipsWheel;
				focusedShip.hullSkin.material.setTexMap(Mtls["TexPanel"]); // set back hull skin
				focusedShip.skin.removeChild(focusedShip.modulesSkin);
				focusedShip.skin.addChild(focusedShip.modulesSkinExt);
				if (oldCallBack!=null) oldCallBack();
			}

			velDBER.x = (focusedShip.radius*2-lookDBER.x)*(1-0.9);		// zoom closer to ship

			var tickBmd:BitmapData = new icoTick().bitmapData;
			var crossBmd:BitmapData = new icoCross().bitmapData;
			var undoBmd:BitmapData = new icoUndo().bitmapData;
			var mainRef:SpaceCrafter = this;
			var showBtns:Vector.<Boolean> = new <Boolean>[false,true,false];
			undoStk = new Vector.<String>();
			var btnsShowFn:Function = function():void
			{
				if (undoStk.length>0)
					showBtns[0] = showBtns[2] = true;
				else
					showBtns[0] = showBtns[2] = false;
			};//endfunction

			function showThisEditMenu():void
			{
				stepFns.push(btnsShowFn);		// add dynamic show hide buttons
				stepFns.push(editStepFn);		// add edit interraction

				optionsMenu =
				MenuUI.createSimpleEditModeMenu(mainRef,tickBmd,crossBmd,undoBmd,
				function(confirm:Boolean):void
				{
					// ----- remove edit ship interraction first
					stepFns.splice(stepFns.indexOf(btnsShowFn),1);
					stepFns.splice(stepFns.indexOf(editStepFn),1);
					world.removeChild(buildMkr);

					if (confirm)	// if tick pressed
					{
						MenuUI.createConfirmDialog(mainRef,"Keep Changes?",tickBmd,crossBmd,function(yes:Boolean):void
						{
							if (yes)
							{
								userData.saveShipsData(Friendlies);
								callBack();
							}
							else
								showThisEditMenu();
						});
					}
					else     // if cross pressed
					{
						if (undoStk.length>0)
							MenuUI.createConfirmDialog(mainRef,"Discard Changes?",tickBmd,crossBmd,function(yes:Boolean):void
							{
								if (yes)
								{
									focusedShip.setFromConfig(undoStk.shift());	// restore original config
									callBack();
								}
								else
									showThisEditMenu();
							});
						else
							callBack();
					}
				},
				function():void		// undo function
				{
					if (undoStk.length>0)
						focusedShip.setFromConfig(undoStk.pop());	// restore last config
				},
				showBtns);
				optionsMenu.y = subTitle.y+subTitle.height;
				mainTitle.name = focusedShip.name+" : "+title;
			};
			showThisEditMenu();
		}//endfunction

		//===============================================================================================
		// item selection carousel
		//===============================================================================================
		private function modulesSelectMenu(callBack:Function):void
		{
			ShipHUD.hideShipsWheel = true;
			var planets:Mesh = sky.getChildAt(0);
			planets.setLightingParameters(0.2,0.2,0.2,0,0,false,true);
			sky.material.setAmbient(0.2,0.2,0.2);

			var Ids:Vector.<Object> =
			new <Object>[	{id:'thrusterS', name:'Ship Thruster'},
										{id:'tractorS', name:'Tractor Beam'},
										{id:'gunAutoS', name:'Point Defense Gatling Gun'},
										{id:'gunFlakS', name:'Point Defense Flak Gun'},
										{id:'gunIonS', name:'Ion Blaster'},
										{id:'gunPlasmaS', name:'Plasma Blaster'},
										{id:'gunRailS', name:'Rail Gun'},
										{id:'launcherS', name:'Missile Launcher'},
										{id:'gunIonM', name:'Ion Cannon'},
										{id:'gunRailM', name:'Rail Cannon'},
										{id:'gunPlasmaM', name:'Plasma Cannon'}];

			var n:int = Ids.length;
			var Models:Vector.<Mesh> = new Vector.<Mesh>();

			// ----- create carousel items
			for (var i:int=n-1; i>-1; i--)
			{
				var m:Mesh = Assets[Ids[i].id].clone();
				m.centerToGeometry();	// center to mesh bounding rect
				var vol:Vector3D = m.maxXYZ().subtract(m.minXYZ());
				var sc:Number = Math.pow(1/Math.pow(vol.x*vol.y*vol.z,0.7),1/3);	// tweak scale so diff is not too large
				m.transform = new Matrix4x4().scale(sc,sc,sc);
				m.material.setSpecular(0,0);
				m.material.setAmbient(1,1,1);
				var nm:Mesh = new Mesh();
				nm.addChild(m);
				nm.mergeTree();
				world.addChild(nm);
				Models.unshift(nm);
			}

			var itmsSc:Number = 0;
			var rotOff:Number = 0;		// the carousel rotation state
			var prevSelIdx:int =0;
			var selIdx:Number = 0;
			var selRotVel:Number = 0;
			var itmRot:Vector3D = new Vector3D(0,0,0,1);	// the rotation quaternion
			var itmRotVel:Vector3D = new Vector3D(0,0,0,1);	// rotation vel of item

			var oldViewStep:Function = viewStep;	// hijack viewStep

			// ----- carousel rotation logic and cam view control
			viewStep = function():void
			{
				var n:int = Models.length;
				itmsSc = (itmsSc*4+1)/5;

				// ----- apply rotation to selected item
				var px:Number = Math.sin(rotOff);								// current rotoff vect
				var py:Number = Math.cos(rotOff);
				var qx:Number = Math.sin(-Math.round(selIdx)/n*Math.PI*2);	// target rotoff vect
				var qy:Number = Math.cos(-Math.round(selIdx)/n*Math.PI*2);
				var ang:Number = Math.acos(Math.max(-1,Math.min(1,px*qx+py*qy)));
				if (px*qy-qx*py>0)	ang*=-1;
				rotOff += Math.max(-0.1,Math.min(0.1,ang*0.2));	// spin carousel
				itmRot = Matrix4x4.quatMult(itmRotVel,itmRot);
				itmRotVel.scaleBy(0.93);	// reduce item rotation speed
				itmRotVel.w = Math.sqrt(1 - itmRotVel.x*itmRotVel.x-itmRotVel.y*itmRotVel.y-itmRotVel.z*itmRotVel.z);

				// ----- arrange items in carousel fashion
				for (var i:int=n-1; i>-1; i--)
				{
					var m:Mesh = Models[i];
					qx = Math.sin(-i/n*Math.PI*2);
					qy = Math.cos(-i/n*Math.PI*2);
					var angDiff:Number = Math.acos(Math.max(-1,Math.min(1,px*qx+py*qy)));
					var sc:Number = 1.5+2*(1+Math.cos(Math.min(Math.PI,Math.max(-Math.PI,angDiff*10))));					// scale larger for selected
					sc *= itmsSc;
					var elevOff:Number = Math.PI*0.7;
					var tiltTo:Vector3D = new Vector3D(	Math.cos(lookDBER.z+elevOff)*Math.sin(lookDBER.y),
																							Math.sin(lookDBER.z+elevOff),
																							Math.cos(lookDBER.z+elevOff)*Math.cos(lookDBER.y));
					if (i==Math.round(selIdx))
						m.transform = Matrix4x4.quaternionToMatrix(itmRot.w,itmRot.x,itmRot.y,itmRot.z).scale(sc,sc,sc).translate(0,0,focusedShip.radius*(2-(sc-1)/6));
					else
						m.transform = new Matrix4x4().scale(sc,sc,sc).translate(0,0,focusedShip.radius*2);
					m.transform = m.transform.rotY(i/n*Math.PI*2+rotOff+Math.PI+lookDBER.y).rotFromTo(0,1,0,tiltTo.x,tiltTo.y,tiltTo.z).translate(lookPt.x,lookPt.y,lookPt.z);
				}

				// ----- detect mouse click
				if (Input.upPts.length>0)
				{
					var upPt:InputPt = Input.upPts[0];
					if (upPt.endT-upPt.startT<300)
					{
						var ray:VertexData = Mesh.cursorRay(stage.mouseX,stage.mouseY,0.01,100);
						for (i=n-1; i>-1; i--)
						{
							if (Models[i].lineHitsMesh(ray.vx,ray.vy,ray.vz,ray.nx,ray.ny,ray.nz))
							{
								if (Math.round(selIdx)==i)
								{		// do addModule
									optionsMenu.parent.removeChild(optionsMenu);
									viewStep = oldViewStep;
									for (var j:int=Models.length-1; j>-1; j--)
										world.removeChild(Models[j]);
									var addModStep:Function = addModuleFn(Ids[i].id);
									showShipEditMenu("Place "+Ids[i].name,addModStep,function():void
									{
										modulesSelectMenu(callBack);
									});
									return;
								}
								else
								{
									selIdx = i;
									prevSelIdx = i;
									selRotVel = 0;
									optionsMenu.y = subTitle.y+subTitle.height;
									mainTitle.name = focusedShip.name+" : Outfit "+Ids[prevSelIdx].name;
								}
							}
						}
					}
				}//endif

				if (prevSelIdx!=Math.round(selIdx))
				{
					prevSelIdx = Math.round(selIdx);
					optionsMenu.y = subTitle.y+subTitle.height;
					mainTitle.name = focusedShip.name+" : Outfit "+Ids[prevSelIdx].name;
				}

				// ----- enable drag to pan view interraction
				if (Input.downPts.length==1)	// one finger
				{
					var downPt:InputPt = Input.downPts[0];
					velDBER.y+=(downPt.x-downPt.ox)/5000;	// bearing change
					velDBER.z-=(downPt.y-downPt.oy)/5000;	// elevation change
					itmRotVel = Matrix4x4.quatMult(new Matrix4x4().rotFromTo(0,0,1,(downPt.x-downPt.ox)/1000,-(downPt.y-downPt.oy)/1000,1).rotationQuaternion(),itmRotVel);
					selRotVel += (downPt.x-downPt.ox)/3000;
				}
				selIdx+=selRotVel;
				while (Math.round(selIdx)<0)	selIdx+=n;
				while (Math.round(selIdx)>n-1)	selIdx-=n;
				selRotVel*=0.96;
				if (selRotVel*selRotVel<0.004) selRotVel=0;

				// ----- calculate cam lookPt easing
				if (focusedShip!=null)
				{
					velDBER.x = (focusedShip.radius*4-lookDBER.x)*(1-0.8);	// fix dist to radius*4
					lookVel = focusedShip.posn.subtract(lookPt);
					lookVel.scaleBy(1-0.9);
					lookDBER.x = Math.max(focusedShip.radius*1.1, lookDBER.x);
				}
			}//endfunction

			var cleanUp:Function = function():void
			{
				planets.setLightingParameters(0,0,0,0,0,true,true);
				sky.material.setAmbient(1,1,1);
				viewStep = oldViewStep;
				for (var i:int=Models.length-1; i>-1; i--)
					world.removeChild(Models[i]);
				ShipHUD.hideShipsWheel = false;
				if (callBack!=null) callBack();
			}//endfunction

			optionsMenu =	MenuUI.createLeftStyleMenu(this,new <String>["back"],new <Function>[cleanUp]);
			optionsMenu.y = subTitle.y+subTitle.height;
			mainTitle.name = focusedShip.name+" : Outfit Modules";
		}//endfunction

		//===============================================================================================
		// interraction to add ship module
		//===============================================================================================
		private function addModuleFn(type:String="") : Function
		{
			var size:int=1;
			if (type.charAt(type.length-1)=="M")
				size=2;
			var mmkr:Mesh = Mesh.createTetra(0.3, new BitmapData(1,1,false,0x00FF00), false);
			mmkr.applyTransform(new Matrix4x4().scale(2, 2, 1).rotX(-Math.PI/2));
			var Mkrs:Vector.<Mesh> = new Vector.<Mesh>();
			for (var i:int=0; i<size; i++)
				for (var j:int=0; j<size; j++)
					Mkrs.push(mmkr.clone());

			return function():void
			{
				var ray:VertexData = Mesh.cursorRay(stage.mouseX,stage.mouseY,0.01,100);
				var hit:VertexData = focusedShip.skin.lineMeshIntersection(ray.vx,ray.vy,ray.vz,ray.nx,ray.ny,ray.nz);
				if (hit!=null)
				{
					var shipInvT:Matrix4x4 = focusedShip.skin.transform.inverse();
					var localPt:Vector3D = shipInvT.transform(new Vector3D(hit.vx-hit.nx*size/2,hit.vy-hit.ny*size/2,hit.vz-hit.nz*size/2));
					var localNorm:Vector3D = shipInvT.rotateVector(new Vector3D(hit.nx, hit.ny, hit.nz));

					var orient:Vector3D = new Vector3D(Math.round(localNorm.x),Math.round(localNorm.y),Math.round(localNorm.z));
					var Pts:Vector.<Vector3D> = focusedShip.surfaceToOccupy(localPt.x,localPt.y,localPt.z,orient,size);
					//var blocks:Vector.<HullBlock> = focusedShip.freeHullBlocks(localPt.x,localPt.y,localPt.z,size);

					//debugTf.text = "Pts="+Pts.length+"  blocks="+blocks.length+" orient="+orient+" hitNormal="+int(localNorm.x*100)/100+","+int(localNorm.y*100)/100+","+int(localNorm.z*100)/100;

					for (i=Math.min(Pts.length,Mkrs.length)-1; i>-1; i--)
					{
						var pt:Vector3D = Pts[i];
						Mkrs[i].transform =  focusedShip.skin.transform.mult(new Matrix4x4().rotFromTo(0,1,0,orient.x,orient.y,orient.z).translate(pt.x-orient.x*0.3,pt.y-orient.y*0.3,pt.z-orient.z*0.3));
						world.addChild(Mkrs[i]);
					}
					if (Input.upPts.length>0)
					{
						var upPt:InputPt = Input.upPts[0];
						if (upPt.endT-upPt.startT<300)
						{
							undoStk.push(focusedShip.toString());
							if (focusedShip.addModule(localPt.x,localPt.y,localPt.z,orient,type))	// orient,type,size
								focusedShip.rebuildShip();
							else
								undoStk.pop();		// discard undo state
						}
					}
				}
				else
				{
					for (i=Mkrs.length-1; i>=0; i--)
						world.removeChild(Mkrs[i]);
				}
			}//endfunction
		}//endfunction

		//===============================================================================================
		// interaction to trim ship chassis
		//===============================================================================================
		private function trimChassisStep() : void
		{
			// ----- ray cast cursor
			var ray:VertexData = Mesh.cursorRay(stage.mouseX,stage.mouseY,0.01,100);
			var hit:VertexData = focusedShip.skin.lineMeshIntersection(ray.vx,ray.vy,ray.vz,ray.nx,ray.ny,ray.nz);
			if (hit!=null)
			{
				var shipInvT:Matrix4x4 = focusedShip.skin.transform.inverse();
				var localPt:Vector3D = shipInvT.transform(new Vector3D(hit.vx-hit.nx/2,hit.vy-hit.ny/2,hit.vz-hit.nz/2));
				localPt.x = Math.round(localPt.x);
				localPt.y = Math.round(localPt.y);
				localPt.z = Math.round(localPt.z);

				if (focusedShip.adjacentToSpace(localPt.x,localPt.y,localPt.z))
				{
					buildMkr.transform = focusedShip.skin.transform.mult(new Matrix4x4().scale(1.3,1.3,1.3).translate(localPt.x,localPt.y,localPt.z));
					world.addChild(buildMkr);
					if (Input.upPts.length>0)
					{
						var upPt:InputPt = Input.upPts[0];
						if (upPt.endT-upPt.startT<300)
						{
							undoStk.push(focusedShip.toString());
							var occupyingModule:Module = focusedShip.getHullBlocks(localPt.x,localPt.y,localPt.z,1)[0].module;
							if (occupyingModule!=null)
								focusedShip.removeModule(occupyingModule);
							else
								focusedShip.trimHull(localPt.x,localPt.y,localPt.z);
							focusedShip.rebuildShip();
						}
					}
				}
				else
					world.removeChild(buildMkr);
			}
			else
			{
				world.removeChild(buildMkr);
			}
		}//endfunction

		//===============================================================================================
		// interaction to extend ship chassis
		//===============================================================================================
		private function extendChassisStep() : void
		{
			// ----- ray cast cursor
			var ray:VertexData = Mesh.cursorRay(stage.mouseX,stage.mouseY,0.01,100);
			var hit:VertexData = focusedShip.skin.lineMeshIntersection(ray.vx,ray.vy,ray.vz,ray.nx,ray.ny,ray.nz);
			if (hit!=null)
			{
				var shipInvT:Matrix4x4 = focusedShip.skin.transform.inverse();
				var localPt:Vector3D = shipInvT.transform(new Vector3D(hit.vx+hit.nx/2,hit.vy+hit.ny/2,hit.vz+hit.nz/2));
				localPt.x = Math.round(localPt.x);
				localPt.y = Math.round(localPt.y);
				localPt.z = Math.round(localPt.z);
				buildMkr.transform = focusedShip.skin.transform.mult(new Matrix4x4().translate(localPt.x,localPt.y,localPt.z));

				if (focusedShip.adjacentToHull(localPt.x,localPt.y,localPt.z))
				{
					world.addChild(buildMkr);
					if (Input.upPts.length>0)
					{
						var upPt:InputPt = Input.upPts[0];
						if (upPt.endT-upPt.startT<300)
						{
							undoStk.push(focusedShip.toString());
							focusedShip.extendHull(localPt.x,localPt.y,localPt.z);
							focusedShip.rebuildShip();
						}
					}
				}
				else
					world.removeChild(buildMkr);
			}
			else
			{
				world.removeChild(buildMkr);
			}
		}//endfunction

		//===============================================================================================
		//
		//===============================================================================================
		private function keyDownHandler(ev:KeyboardEvent) : void
		{
			if (ev.keyCode==32)
			{
				//toggleView();
			}
		}//endfunction

		//===============================================================================================
		//
		//===============================================================================================
		private function deactivateHandler(ev:Event):void
		{
			simulationPaused = true;
			var st:SoundTransform = ambientLoop.soundTransform;
			TweenLite.to(st,1,{volume:0, onUpdate:function():void {ambientLoop.soundTransform=st;}});
		}//endfunction

		//===============================================================================================
		//
		//===============================================================================================
		private function activateHandler(ev:Event):void
		{
			simulationPaused = false;
			var st:SoundTransform = ambientLoop.soundTransform;
			TweenLite.to(st,1,{volume:1, onUpdate:function():void {ambientLoop.soundTransform=st;}});
		}//endfunction

		//===============================================================================================
		// returns if point is visible in screen fustrum
		//===============================================================================================
		[Inline]
		private final function posnIsOnScreen(px:Number, py:Number, pz:Number) : Boolean
		{
			var pt:Vector3D = Mesh.screenPosn(px,py,pz);	// offscreen culling
			if (pt.z<=0) return false;
			return pt.x >= 0 && pt.x < stage.stageWidth && pt.y >= 0 && pt.y < stage.stageHeight;
		}//endfunction

		//=================================================================================================
		// given gun muzzle speed, and target (posn,vel) RELATIVE to gun,
		// returns projectile intercept vector (x,y,z,w)	where w is time to collision
		// pspeed: projectile velocity
		// gun posn assumed to be at (0,0,0)
		// targ posn (tpx,tpy,tpz) targ vel (tvx,tvy,tvz)
		//=================================================================================================
		[Inline]
		public static function collisionVector3(pspeed:Number,tpx:Number,tpy:Number,tpz:Number,tvx:Number,tvy:Number,tvz:Number) : Vector3D
		{
			// finalP = initialP + targV*time			... (1)    target
			// time = |finalP|/pspeed					... (2)	   projectile
			// | initialP + targV*time | / pspeed		... sub (1) in (2)
			// simplifying
			// => 0 = (tpx*tpx + tpy*tpy + tpz*tpz) + 2*(tpx*tvx + tpy*tvy + tpz*tvz)*t + (tvx*tvx + tvy*tvy + tvz*tvz - pspeed*pspeed)*t*t
			// using quadratic formula (-b +- sqrt(b*b-4*a*c))/(2*a) ...

			var a:Number = tvx*tvx + tvy*tvy + tvz*tvz - pspeed*pspeed;
			var b:Number = 2*(tpx*tvx + tpy*tvy +tpz*tvz);
			var c:Number = tpx*tpx + tpy*tpy + tpz*tpz;

			if (b*b-4*a*c>=0)						// if has solution
			{
				var det:Number = Math.sqrt(b*b-4*a*c);
				var t:Number = (-b - det)/(2*a);	// time to hit
				if (t<0) t = (-b + det)/(2*a);
				var fpx:Number = tpx + tvx*t;	// target final position x
				var fpy:Number = tpy + tvy*t;	// target final position y
				var fpz:Number = tpz + tvz*t;	// target final position y
				var _fpl:Number = pspeed/Math.sqrt(fpx*fpx+fpy*fpy+fpz*fpz);
				return new Vector3D(fpx*_fpl,fpy*_fpl,fpz*_fpl,t);	// returns vector from gun posn to targ posn
			}// endif has solution

			return null;
		}//endfunction

		//=================================================================================================
		// given gun muzzle speed, and target (posn,vel) RELATIVE to gun,
		// returns projectile intercept vector (x,y,z,w)	where w is time to collision
		// pspeed: projectile velocity
		// gun posn assumed to be at (0,0,0)
		// targ posn (tpx,tpy,tpz) targ vel (tvx,tvy,tvz)
		//=================================================================================================
		[Inline]
		public static function interceptVector3(pspeed:Number,tpx:Number,tpy:Number,tpz:Number,tvx:Number,tvy:Number,tvz:Number,cutoffT:Number) : Vector3D
		{
			// finalP = initialP + targV*time			... (1)    target
			// time = |finalP|/pspeed					... (2)	   projectile
			// | initialP + targV*time | / pspeed		... sub (1) in (2)
			// simplifying
			// => 0 = (tpx*tpx + tpy*tpy + tpz*tpz) + 2*(tpx*tvx + tpy*tvy + tpz*tvz)*t + (tvx*tvx + tvy*tvy + tvz*tvz - pspeed*pspeed)*t*t
			// using quadratic formula (-b +- sqrt(b*b-4*a*c))/(2*a) ...

			var a:Number = tvx*tvx + tvy*tvy + tvz*tvz - pspeed*pspeed;
			var b:Number = 2*(tpx*tvx + tpy*tvy +tpz*tvz);
			var c:Number = tpx*tpx + tpy*tpy + tpz*tpz;

			if (b*b-4*a*c>=0)						// if has solution
			{
				var det:Number = Math.sqrt(b*b-4*a*c);
				var t:Number = (-b - det)/(2*a);	// time to hit
				if (t<0) t = (-b + det)/(2*a);
				if (t>cutoffT) return null;
				var fpx:Number = tpx + tvx*t;	// target final position x
				var fpy:Number = tpy + tvy*t;	// target final position y
				var fpz:Number = tpz + tvz*t;	// target final position y
				var _fpl:Number = pspeed/Math.sqrt(fpx*fpx+fpy*fpy+fpz*fpz);
				return new Vector3D(fpx*_fpl,fpy*_fpl,fpz*_fpl,t);	// returns vector from gun posn to targ posn
			}// endif has solution

			return null;
		}//endfunction

		//===============================================================================================
		// create a space nebula texture using perlin noise
		//===============================================================================================
		private static function createSpaceTexture(w:int,h:int,spaceBG:Sprite=null) : BitmapData
		{
			if (spaceBG==null)
			{
				spaceBG=new Sprite();
				spaceBG.graphics.beginFill(0,1);
				spaceBG.graphics.drawRect(-w/2,-h/2,w,h);
				spaceBG.graphics.endFill();
				for (var i:int=0; i<60; i++)
				{
					var r:int = int(20+Math.random()*80);
					var p:Sprite = new Sprite();
					p.graphics.beginFill(0x0044BB,1);
					p.graphics.drawCircle(0,0,r);
					p.graphics.endFill();
					p.x = -w/2 + Math.random()*w;
					p.y = -h/2 + Math.random()*h;
					p.filters = [new BlurFilter(r,r,3)];
					spaceBG.addChild(p);
				}
				for (i=0; i<15; i++)
				{
					r = int(20+Math.random()*50);
					p = new Sprite();
					p.graphics.beginFill(0x00AA88,1);
					p.graphics.drawCircle(0,0,r);
					p.graphics.endFill();
					p.x = -w*0.4 + Math.random()*w*0.8;
					p.y = -h*0.4 + Math.random()*h*0.8;
					p.filters = [new BlurFilter(r*2,r*2,3)];
					spaceBG.addChild(p);
				}

				var spider:Sprite = createSpiderCracksSprite(0,0,0xFF1199,1000,spaceBG,13);
				spider.filters = [new BlurFilter(32,32,5)];
			}

			// ----- generate background perlin noise and colored overlay
			var bmd:BitmapData = new BitmapData(w,h,false);
			var seed:Number = Math.floor(Math.random()*10);
			var offSets:Array =[new Point(0,0),new Point(0,0),new Point(0,0),new Point(0,0),
								new Point(0,0),new Point(0,0),new Point(0,0),new Point(0,0),
								new Point(0,0),new Point(0,0),new Point(0,0),new Point(0,0),
								new Point(0,0),new Point(0,0),new Point(0,0),new Point(0,0)];
			var channels:uint = BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE;
			bmd.perlinNoise(60, 60, 4, seed, false, true, 7, true, offSets);

			// ----- create a displacement map filter and apply
			var dispbmd:BitmapData = new BitmapData(w,h);
			dispbmd.perlinNoise(320, 320, 2, seed, false, true, 7, false, offSets);
			bmd.applyFilter(bmd,new Rectangle(0,0,bmd.width,bmd.height),new Point(0,0),new DisplacementMapFilter(dispbmd,new Point(0,0),BitmapDataChannel.BLUE,BitmapDataChannel.RED,80,80,DisplacementMapFilterMode.CLAMP));
			dispbmd.dispose();
			//bmd.applyFilter(bmd,new Rectangle(0,0,bmd.width,bmd.height),new Point(0,0),new ColorMatrixFilter([1,0,0,0,50, 0,1,0,0,50, 0,0,1,0,50, 0,0,0,1,0]));
			bmd.draw(spaceBG,new Matrix(1,0,0,1,bmd.width/2,bmd.height/2),null,BlendMode.MULTIPLY,null,false);
			return bmd;
		}//endfunction

		//===============================================================================================
		// paint hole in mc at position (px,py)
		//===============================================================================================
		private static function createSpiderCracksSprite(px:Number,py:Number,color:Number,w:Number,mc,n:int=12) : Sprite
		{
			var hole:Sprite = new Sprite();
			hole.x = px;
			hole.y = py;

			var ang:Number = Math.random()*Math.PI*2;

			for (var i:int=0; i<n; i++)
			{
				ang += Math.random()*Math.PI;
				var len:Number = w/2 + Math.random()*w/2;
				var vx:Number = Math.sin(ang)*len;
				var vy:Number =-Math.cos(ang)*len;
				var pt:Point = mc.localToGlobal(new Point(px+vx,py+vy));
				drawCrookedLine(0,0,		// from
								vx,vy,		// to
								w/32,0,		// thickness
								8,color,	// kinks
								hole);		// DSprite
			}

			mc.addChild(hole);
			return hole;
		}//endfunction

		//===============================================================================================
		// Draws a zigzag connecting line from (px,py) to (qx,qy) thickness fat1 to fat2
		// n number of kinks inbetween, of color in given Sprite
		//===============================================================================================
		private static function drawCrookedLine(px:Number,py:Number,qx:Number,qy:Number,
								 fat1:Number,fat2:Number,
								 n:Number,color:Number,mc:Sprite) : void
		{
			var A:Array = [px,py];
			var ux:Number = qx-px;
			var uy:Number = qy-py;
			var vl:Number = Math.sqrt(ux*ux + uy*uy);
			ux /= vl;
			uy /= vl;

			var i:int=0;
			var f:Number=0;

			for (i=1; i<=n; i++)
			{
				f = i/(n+1);
				var r:int = (Math.random()-0.5)*vl/n;
				A.push((f*qx + (1-f)*px) + r*uy);
				A.push((f*qy + (1-f)*py) - r*ux);
			}
			A.push(qx);
			A.push(qy);

			for (i=0; i<A.length-2; i+=2)
			{
				f = i/(A.length-2);
				var f1:Number = fat2*f + fat1*(1-f);
				f = (i+2)/(A.length-2);
				var f2:Number = fat2*f + fat1*(1-f);
				mc.graphics.beginFill(color);
				mc.graphics.moveTo(A[i+0]+f1/2*uy	,A[i+1]-f1/2*ux);
				mc.graphics.lineTo(A[i+2]+f2/2*uy	,A[i+3]-f2/2*ux);
				mc.graphics.lineTo(A[i+2]-f2/2*uy	,A[i+3]+f2/2*ux);
				mc.graphics.lineTo(A[i+0]-f1/2*uy	,A[i+1]+f1/2*ux);
				mc.graphics.endFill();
			}
		}//endfunction

		//===============================================================================================
		//
		//===============================================================================================
		private static function fadeVertEnds(bmd:BitmapData) : BitmapData
		{
			var s:Sprite = new Sprite();
			var mat:Matrix = new Matrix();
			mat.createGradientBox(bmd.width,bmd.height,Math.PI/2,0,0);
			s.graphics.beginGradientFill("linear",[0x000000,0xFFFFFF,0xFFFFFF,0x000000],[1,1,1,1],[0,105,150,255],mat);
			s.graphics.drawRect(0,0,bmd.width,bmd.height);
			s.graphics.endFill();
			//var noise:BitmapData = new BitmapData(
			bmd.draw(s,null,null,"multiply");
			return bmd;
		}//endfunction

		//===============================================================================================
		// convenience fn to create a double sided light cone inside and outside
		//===============================================================================================
		private static function createLightCone(r1:Number,r2:Number,z1:Number,z2:Number,bmd:BitmapData) : Mesh
		{
			var cone:Mesh = new Mesh();
			cone.addChild(Mesh.createCylinder(r1,r2,z1,z2,12,bmd));
			var r:Mesh = cone.clone();
			r.transform = new Matrix4x4().scale(-1,1,1);
			cone.addChild(r);
			return cone.mergeTree();
		}//endfunction

		//===============================================================================================
		// convenience fn to return a random vector of given length, override given vector v
		//===============================================================================================
		private static function randV3values(len:Number,v:Vector3D=null):Vector3D
		{
			if (v==null) v=new Vector3D(0,0,0);
			v.x = Math.random()-0.5;
			v.y = Math.random()-0.5;
			v.z = Math.random()-0.5;
			v.scaleBy(len/v.length);
			return v;
		}//endfunction

	}//endClass

}//endPackage

import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.GlowFilterPlugin;
import core3D.*;
import flash.display.Stage;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.events.KeyboardEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.Vector3D;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;
import flash.media.SoundMixer;
import flash.media.SoundTransform;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import flash.utils.getTimer;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.sensors.Accelerometer;
import flash.events.AccelerometerEvent;
import flash.net.SharedObject;

TweenPlugin.activate([GlowFilterPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

class UserData
{
	public var uid:String=null;						// user unique id string
	public var userName:String=null;
	public var credits:int = 0;						// current user credits
	public var inventory:Object=null;			// current user inventory Object dictionary
	public var shipsConfig:Vector.<String>=null;	// current user ships data

	//===============================================================================================
	//
	//===============================================================================================
	public function UserData():void
	{
		uid = toBase62(new Date().getTime()*100 + int(Math.random()*100));
		credits = 0;
		inventory = new Object();
		shipsConfig = new Vector.<String>();
	}//endfunction

	//===============================================================================================
	// some homebrew conversion to make uid short
	//===============================================================================================
	private function toBase62(x:int):String
	{
		var r:String = "";
		var cs:String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";	// base62
		while (x<0)
		{
			r = cs.charAt(x%cs.length) + r;
			x = int(x/cs.length);
		}
		return r;
	}//endfunction

	//===============================================================================================
	// override user ships data with this one
	//===============================================================================================
	public function saveShipsData(S:Vector.<Hull>):void
	{
		var so:SharedObject = SharedObject.getLocal("SpaceCrafter");
		shipsConfig = new Vector.<String>();
		for (var i:int=0; i<S.length; i++)
			shipsConfig.push(S[i].toString());
	}//endfunction

	//===============================================================================================
	// Saves all given user ships data
	//===============================================================================================
	public function saveDataToLocalObject():void
	{
		var so:SharedObject = SharedObject.getLocal("SpaceCrafter");
		so.data.currentUser = toString();
		so.flush();
	}//endfunction

	//===============================================================================================
	// string representation of user save data
	//===============================================================================================
	public function toString():String
	{
		var invStr:String = "";
		for(var id:String in inventory)
			invStr += id+","+inventory[id]+",";
		if (invStr.length>0) invStr = invStr.substr(0,invStr.length-1);

		var shpStr:String = "";
		for (var i:int=0; i<shipsConfig.length; i++)
			shpStr += shipsConfig[i]+";";
		if (shpStr.length>0) shpStr = shpStr.substr(0,shpStr.length-1);

		return uid+"&"+userName+"&"+credits+"&"+invStr+"&"+shpStr;
	}//endfunction

	//===============================================================================================
	// Load user ship data return config string in ";" delimited form
	//===============================================================================================
	public static function loadDataFromLocalObject():UserData
	{
		var usrDat:UserData = new UserData();
		var so:SharedObject = SharedObject.getLocal("SpaceCrafter");

		if (so.data.hasOwnProperty("ships"))
		{	// parse legacy ship config
			var lS:Array = so.data.split(";");
			for (var ls:int=0; ls<lS.length; ls++)
				usrDat.shipsConfig.push(lS[ls]);
			delete so.data.ships;
		}

		if (so.data.hasOwnProperty("currentUser"))
		{
			var A:Array = so.data.currentUser.split("&");

			usrDat.uid = A[0];
			usrDat.userName = A[1];
			usrDat.credits = parseInt(A[2]);

			// ----- parse inventory
			var I:Array = A[3].split(",");
			for (var i:int=0; i<I.length; i+=2)
				usrDat.inventory[I[i]] = parseInt(I[i+1]);

			// ----- parse ships config
			var S:Array = A[4].split(";");
			for (var s:int=0; s<S.length; s++)
				usrDat.shipsConfig.push(S[s]);
		}

		return usrDat;
	}//endfunction
}//endclass

class ShipHUD
{
	private static var healthBar:MeshParticles = null;
	private static var energyBar:MeshParticles = null;
	private static var depletedBase:MeshParticles = null;

	private static var shipsWheel:Mesh = null;
	private static var world:Mesh = null;
	private static var stage:Stage = null;

	public static var hideShipsWheel:Boolean = false;

	/**
	* init
	*/
	public static function init(_stage:Stage,_world:Mesh,_shipsWheel:Mesh):void
	{
		var cube:Mesh = Mesh.createPlane(0.001,0.0016,null);
		healthBar = new MeshParticles(cube);
		healthBar.skin.material.setAmbient(0,1,0.2);
		healthBar.skin.material.setSpecular(0.2);
		energyBar = new MeshParticles(cube);
		energyBar.skin.material.setAmbient(0,0.3,1);
		energyBar.skin.material.setSpecular(0.2);
		depletedBase = new MeshParticles(cube);
		depletedBase.skin.material.setAmbient(0.2,0.2,0.2);
		depletedBase.skin.material.setSpecular(0.2);

		stage = _stage;
		world = _world;
		shipsWheel = _shipsWheel;
	}//endfunction

	/**
	* HUD update step
	*/
	public static function update(hull:Hull):void
	{
		if (stage==null)
		{
			throw new Error("ShipHUD not initialized!");
			return;
		}

		if (!(hull is Ship))
		{
			world.removeChild(healthBar.skin);
			world.removeChild(energyBar.skin);
			world.removeChild(depletedBase.skin);
			world.removeChild(shipsWheel);
			return;
		}

		var shp:Ship = (Ship)(hull);
		var sT:Matrix4x4 = shp.skin.transform;
		var bearing:Number = Math.acos(Math.max(-1,Math.min(1,sT.cc)));		// ship bearing
		if (sT.ac>0)	bearing*=-1;

		var invVT:Matrix4x4 = Mesh.viewT.inverse();
		var r:VertexData = Mesh.cursorRay(stage.stageWidth/2,stage.stageHeight*0.95,0.1,0.2);;
		var lp:Vector3D = Mesh.viewT.transform(new Vector3D(r.vx,r.vy,r.vz));
		var wheel:Mesh = shipsWheel;
		wheel.transform = invVT.mult(new Matrix4x4().rotZ(bearing*10).translate(lp.x,lp.y,lp.z));
		if (hideShipsWheel)
			world.removeChild(wheel);
		else
			world.addChild(wheel);

		healthBar.reset();
		energyBar.reset();
		depletedBase.reset();

		var integPerBlk:Number = shp.maxIntegrity/shp.hullConfig.length;
		var unitInteg:Number = integPerBlk;

		for (var i:int=shp.maxIntegrity/unitInteg-1; i>-1; i--)
		{
			var iT:Matrix4x4 = invVT.mult(new Matrix4x4().translate(lp.x-int(i/2)*0.0014-0.03,lp.y+(i%2)*0.002-0.001,lp.z));
			if (i*unitInteg<=shp.integrity)
				healthBar.nextLocRotScale(iT, 1);
			else
				depletedBase.nextLocRotScale(iT, 0.7);
		}

		var energPerBlk:Number = shp.maxEnergy/shp.hullConfig.length;
		var unitEnerg:Number = energPerBlk;

		for (var e:int=shp.maxEnergy/unitEnerg-1; e>-1; e--)
		{
			var eT:Matrix4x4 = invVT.mult(new Matrix4x4().translate(lp.x+int(e/2)*0.0014+0.03,lp.y+(e%2)*0.002-0.001,lp.z));
			if (e*unitEnerg<=shp.energy)
				energyBar.nextLocRotScale(eT, 1);
			else
				depletedBase.nextLocRotScale(eT, 0.7);
		}

		//throw new Error("shp maxIntegrity="+shp.maxIntegrity+" maxEnergy="+shp.maxEnergy+"  in="+(shp.maxIntegrity/unitInteg-1));

		healthBar.update();
		energyBar.update();
		depletedBase.update();
		world.addChild(healthBar.skin);
		world.addChild(energyBar.skin);
		world.addChild(depletedBase.skin);

	}//endfunction
}//endclass

class Input
{
	public static var zoomF:Number = 1;
	public static var downPts:Vector.<InputPt> = null;
	public static var upPts:Vector.<InputPt> = null;

	public static var yaw:Number = 0;
	public static var thrust:Number = 0;
	public static var pitch:Number = 0;

	private static var touchObj:Object = null;
	private static var mousePt:InputPt = null;
	private static var stage:Stage = null;

	//===============================================================================================
	//
	//===============================================================================================
	public static function init(stageInstance:Stage):void
	{
		stage = stageInstance;
		if (Multitouch.supportsGestureEvents)
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			stage.addEventListener(TouchEvent.TOUCH_BEGIN,Input.touchBeginHandler);
			stage.addEventListener(TouchEvent.TOUCH_MOVE,Input.touchMoveHandler);
			stage.addEventListener(TouchEvent.TOUCH_END,Input.touchEndHandler);
		}
		else
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN,Input.mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP,Input.mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL,Input.mouseWheelHandler);
		}

		if (Accelerometer.isSupported)
		{
			var my_acc:Accelerometer = new Accelerometer();
			my_acc.addEventListener(AccelerometerEvent.UPDATE, accUpdateHandler);
		}
		else
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		stage.addEventListener(Event.DEACTIVATE, deactivateHandler);

		touchObj = new Object();
		downPts = new Vector.<InputPt>();
		upPts = new Vector.<InputPt>();
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	public static function update():void
	{
		for (var i:int=downPts.length-1; i>-1; i--)
		{
			var pt:InputPt = downPts[i];
			pt.ox = pt.x;
			pt.oy = pt.y;
		}

		if (mousePt!=null)
		{
			mousePt.x = stage.mouseX;
			mousePt.y = stage.mouseY;
		}

		while (upPts.length>0)	upPts.shift();
		zoomF = 1;
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	private static function accUpdateHandler(ev:AccelerometerEvent) : void
	{
		if (ev.accelerationX*ev.accelerationX>0.01)
			yaw = ev.accelerationX*0.01;
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	private static function keyDownHandler(ev:KeyboardEvent) : void
	{
		if (ev.keyCode == 38 || ev.keyCode == 87)	thrust = 1;
		if (ev.keyCode == 37 || ev.keyCode == 65)	yaw =-1;
		if (ev.keyCode == 39 || ev.keyCode == 68)	yaw = 1;
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	private static function keyUpHandler(ev:KeyboardEvent) : void
	{
		if (ev.keyCode == 38 || ev.keyCode == 87)	thrust = 0;
		if (ev.keyCode == 37 || ev.keyCode == 65)	yaw = 0;
		if (ev.keyCode == 39 || ev.keyCode == 68)	yaw = 0;
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	private static function deactivateHandler(ev:Event) : void
	{
		thrust = 0;
		yaw = 0;
	}//endfunction

	//===============================================================================================
	// handles individual touch begin
	//===============================================================================================
	private static function touchBeginHandler(ev:TouchEvent) : void
	{
		var newInPt:InputPt = new InputPt(ev.stageX,ev.stageY);
		touchObj[ev.touchPointID] = newInPt;
		downPts.push(newInPt);
		touchObj.cnt+=1;
	}//endfunction

	//===============================================================================================
	// handles individual touch moves
	//===============================================================================================
	private static function touchMoveHandler(ev:TouchEvent) : void
	{
		if (touchObj[ev.touchPointID]!=null)
		{
			(InputPt)(touchObj[ev.touchPointID]).x = ev.stageX;
			(InputPt)(touchObj[ev.touchPointID]).y = ev.stageY;
		}

		if (downPts.length>1)	// calculate zoomF
		{
			var pt1:InputPt = downPts[0];
			var pt2:InputPt = downPts[1];
			var dox:Number = pt1.ox-pt2.ox;
			var doy:Number = pt1.oy-pt2.oy;
			var dolSq:Number = dox*dox+doy*doy;
			var dx:Number = pt1.x-pt2.x;
			var dy:Number = pt1.y-pt2.y;
			var dlSq:Number = dx*dx+dy*dy;
			zoomF = Math.sqrt(dolSq/dlSq);
		}
	}//endfunction

	//===============================================================================================
	// handles individal touch end
	//===============================================================================================
	private static function touchEndHandler(ev:TouchEvent) : void
	{
		if (touchObj[ev.touchPointID]!=null)
		{
			var pt:InputPt = touchObj[ev.touchPointID];
			pt.endT = getTimer();
			downPts.splice(downPts.indexOf(pt),1);
			upPts.push(pt);
			delete touchObj[ev.touchPointID];
		}
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	private static function mouseDownHandler(ev:Event) : void
	{
		mousePt = new InputPt(stage.mouseX,stage.mouseY);
		downPts.push(mousePt);
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	private static function mouseUpHandler(ev:Event) : void
	{
		if (mousePt!=null)
		{
			mousePt.endT = getTimer();
			upPts.push(mousePt);
			downPts.splice(downPts.indexOf(mousePt),1);
			mousePt = null;
		}
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	private static function mouseWheelHandler(ev:MouseEvent) : void
	{
		zoomF = 1 + ev.delta / 50;
	}//endfunction
}//endclass

class InputPt
{
	public var x:int=0;
	public var y:int=0;
	public var ox:int=0;
	public var oy:int=0;
	public var startT:int=0;
	public var endT:int=0;

	public function InputPt(px:int,py:int):void
	{
		x = px;
		y = py;
		ox = px;
		oy = py;
		startT = getTimer();
	}//endconstr
 }//endclass

class MenuUI
{
	public static var fontScale:Number = 30/700;
	public static var margF:Number = 0.01;
	public static var clickSfx:Function = null;
	public static var colorTone:uint = 0x99FFFF;		// overridden externally as needed

	public static var starPrefix:Vector.<String> =
	Vector.<String>([	"Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu",
										"Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega"]);
	public static var constellation:Vector.<String> =
	Vector.<String>([	"Andromedae","Antliae","Apodis","Aquarii","Aquilae","Arae","Arietis","Aurigae","Boötis","Caeli",
										"Camelopardalis","Cancri","Canum Venaticorum","Canis Majoris","Canis Minoris","Capricorni",
										"Carinae","Cassiopeiae","Centauri","Cephei","Ceti","Chamaeleontis","Circini","Columbae","Corvi",
										"Crateris","Crucis","Cygni","Delphini","Doradus","","Draconis","Equulei","Eridani","Fornacis","Gemini",
										"Pollux","Gruis","Herculis","Horologii","Hydrae","Hydri","Indi","Lacertae","Leonis","Leonis Minoris",
										"Leporis","Librae","Lupi","Lyncis","Lyrae","Mensae","Microscopii","Monocerotis","Muscae","Normae",
										"Octantis","Ophiuchi","Orionis","Pavonis","Pegasi","Persei","Phoenicis","Pictoris","Piscium","Puppis",
										"Pyxidis","Reticuli","Sagittae","Sagittarii","Scorpii","Sculptoris","Scuti","Serpentis","Sextantis",
										"Tauri","Telescopii","Trianguli","Tucanae","Ursae Majoris","Ursae Minoris","Velorum","Virginis",
										"Volantis","Vulpeculae"]);
	public static var planetSuffix:Vector.<String> =
	Vector.<String>(["I","II","III","IV","V","VI","VII","VIII","IX","X"]);

	//===============================================================================================
	// generate cool spacey planet names
	//===============================================================================================
	public static function randomPlanetName():String
	{
		return 	starPrefix[int(Math.random()*starPrefix.length)]+" "+
						constellation[int(Math.random()*constellation.length)]+" "+
						planetSuffix[int(Math.random()*planetSuffix.length)];
	}//endfunction

	//===============================================================================================
	// create a generic summary screen
	//===============================================================================================
	public static function createSummaryScreen(targ:SpaceCrafter,titleTxt:String,labels:Vector.<String>,values:Vector.<int>,callBack:Function) : Sprite
	{
		var sw:Number = targ.stage.stageWidth;
		var sh:Number = targ.stage.stageHeight;

		var labColor:uint = uint((colorTone>>16)*0.7)<<16 | uint(((colorTone>>8) & 0xFF)*0.7)<<8 | uint((colorTone & 0xFF)*0.7);
		var fSize:Number = fontScale*sh/2;

		var s:Sprite = new Sprite();

		var L:Array = [];
		var V:Array = [];
		var n:int = Math.min(labels.length,values.length);
		for (var i:int=0; i<n; i++)
		{
			var lab:Bitmap = createTextBmp(labels[i],int(fontScale*sh),int(fontScale*sh),labColor);
			lab.y = (sh - (n-1-i)*lab.height)/2;
			lab.x = sw/2 - lab.width-margF*sw;
			lab.alpha = 0;
			TweenLite.to(lab, 0.3, { alpha:1, delay:0.1*i+0.1, x:sw/2 - lab.width } );
			L.push(lab);
			s.addChild(lab);

			var tf:TextField = new TextField();
			tf.autoSize = "left";
			tf.wordWrap = false;
			tf.defaultTextFormat = new TextFormat("arial bold",int(fontScale*sh),colorTone,null,null,null,null,null,"right",0,0);
			tf.filters = [new GlowFilter(colorTone, 1, fontScale*sh/4, fontScale*sh/4, 1, 1)];
			tf.y = lab.y+(lab.height-tf.height)/2;
			tf.x = sw/2 + margF*sw;
			tf.text = values[i]+"";
			TweenLite.to(tf, 0.3, { alpha:1, delay:0.1*i+0.1, x:sw/2 } );
			V.push(tf);
			s.addChild(tf);
		}

		var blockH:Number = s.height;
		var title:Bitmap = createTextBmp(titleTxt, int(1.7*fontScale*sh),0,colorTone);
		title.x = (sw-title.width)/2;
		title.y = ((sh-blockH)/2 - title.height)/2;
		title.alpha = 0;
		TweenLite.to(title, 0.3, { alpha:1} );
		s.addChild(title);

		var okBtn:Sprite = createStandardButton(createTextBmp("Ok",int(fontScale*sh),int(fontScale*sh),colorTone),closeAndRemoveFn(callBack));
		okBtn.alpha = 0;
		okBtn.y = okBtn.height*i;
		okBtn.x = (sw-okBtn.width)/2;
		okBtn.y = sh - (sh-blockH)/4 + okBtn.height/2;
		s.addChild(okBtn);
		TweenLite.to(okBtn, 0.3, { alpha:1, delay:0.1*n+0.1 } );

		function closeAndRemoveFn(callBack:Function):Function
		{
			var isClosing:Boolean = false;
			return function():void
			{
				if (isClosing) return;
				isClosing = true;
				for (var i:int=0; i<n; i++)
				{
					TweenLite.to(L[i], 0.3, { alpha:0, delay:0.1*i+0.1, x:sw/2-L[i].width-margF*sw } );
					TweenLite.to(V[i], 0.3, { alpha:0, delay:0.1*i+0.1, x:sw/2+margF*sw } );
				}
				TweenLite.to(okBtn, 0.3, { alpha:0} );
				TweenLite.to(title, 0.3, { alpha:0, delay:0.2, onComplete:function():void { if (s.parent != null) s.parent.removeChild(s); if (callBack!=null) callBack(); }} );
			}
		}//endfunction

		targ.addChild(s);
		return s;
	}//endfunction

	//===============================================================================================
	// Generic menu creation function
	//===============================================================================================
	public static function createLeftStyleMenu(targ:SpaceCrafter,selectionTxts:Vector.<String>,callBacks:Vector.<Function>) : Sprite
	{
		var sw:Number = targ.stage.stageWidth;
		var sh:Number = targ.stage.stageHeight;

		var s:Sprite = new Sprite();

		var n:int = Math.min(selectionTxts.length, callBacks.length);
		var Btns:Vector.<Sprite> = new Vector.<Sprite>();
		var closing:Boolean = false;
		function closeAndRemoveFn(callBack:Function):Function
		{
			return function():void
			{
				if (closing) return;
				closing = true;
				for (var i:int=0; i<Btns.length; i++)
					TweenLite.to(Btns[i], 0.3, { x:0, alpha:0, delay:0.1*Btns.length-0.1*i } );
				TweenLite.to(s, 0.3, { delay:0.1 * Btns.length, onComplete:function():void { if (s.parent != null) s.parent.removeChild(s); if (callBack!=null) callBack(); }} );
			}
		}//endfunction

		for (var i:int=0; i<n; i++)
		{
			var addBtn:Sprite = createStandardButton(createTextBmp(selectionTxts[i],int(fontScale*sh),int(fontScale*sh),colorTone),closeAndRemoveFn(callBacks[i]));
			addBtn.alpha = 0;
			addBtn.y = addBtn.height*i;
			s.addChild(addBtn);
			Btns.push(addBtn);
			TweenLite.to(addBtn, 0.3, { x:margF*sw, alpha:1, delay:0.1*i+0.1 } );
		}

		targ.addChild(s);
		return s;
	}//endfunction

	//===============================================================================================
	// Generic comfirmation dialog box
	//===============================================================================================
	public static function createConfirmDialog(targ:SpaceCrafter,titleTxt:String,
																						tickIco:BitmapData,crossIco:BitmapData,callBack:Function) : Sprite
	{
		var sw:Number = targ.stage.stageWidth;
		var sh:Number = targ.stage.stageHeight;
		var margX:Number = margF*sw;		// margin value

		var s:Sprite = new Sprite();

		// ----- create title and buttons
		var sc:Number = fontScale*sh/60;
		var bw:Number = Math.max(tickIco.width*sc,crossIco.width*sc)+margX*10;	// ico bitmap w
		var bh:Number = Math.max(tickIco.height*sc,crossIco.height*sc)+margX*2;	// ico bitmap h
		var tickBmd:BitmapData = new BitmapData(bw,bh,true,0x00000000);
		var crossBmd:BitmapData = new BitmapData(bw,bh,true,0x00000000);
		var colorT:ColorTransform = new ColorTransform((colorTone>>16)/255,((colorTone>>8) & 0xFF)/255,(colorTone & 0xFF)/255);
		tickBmd.draw(tickIco,new Matrix(sc,0,0,sc,(bw-tickIco.width*sc)/2,(bh-tickIco.height*sc)/2),colorT,null,null,true);
		crossBmd.draw(crossIco,new Matrix(sc,0,0,sc,(bw-crossIco.width*sc)/2,(bh-crossIco.height*sc)/2),colorT,null,null,true);
		var tickBtn:Sprite = createStandardButton(new Bitmap(tickBmd),closeAndRemoveFn(function():void {callBack(true);}));
		var crossBtn:Sprite = createStandardButton(new Bitmap(crossBmd),closeAndRemoveFn(function():void {callBack(false);}));
		var title:Bitmap = createTextBmp(titleTxt, int(1.7*fontScale*sh),0,colorTone);

		// ----- position buttons
		var panelw:int = Math.max(title.width+margX*2,tickBtn.width+crossBtn.width+margX*3);
		title.x = (panelw - title.width)/2;
		title.y = margX;
		s.addChild(title);
		tickBtn.x = (panelw - tickBtn.width-margX-crossBtn.width)/2;
		tickBtn.y = title.y+title.height+margX;
		s.addChild(tickBtn);
		crossBtn.x = tickBtn.x+tickBtn.width+margX;
		crossBtn.y = tickBtn.y;
		s.addChild(crossBtn);

		var panelh:int = s.height+margX*2;
		var lcorn:int = int((panelw+panelh)/30);
		var lineColor:uint = uint((colorTone>>16)*0.5)<<16 | uint(((colorTone>>8) & 0xFF)*0.5)<<8 | uint((colorTone & 0xFF)*0.5);
		s.graphics.lineStyle(3, lineColor);
		s.graphics.beginFill(0x000000, 0.3);
		s.graphics.moveTo(0,lcorn);
		s.graphics.lineTo(lcorn,0);
		s.graphics.lineTo(panelw-lcorn,0);
		s.graphics.lineTo(panelw,lcorn);
		s.graphics.lineTo(panelw,panelh-lcorn);
		s.graphics.lineTo(panelw-lcorn,panelh);
		s.graphics.lineTo(lcorn,panelh);
		s.graphics.lineTo(0,panelh-lcorn);
		s.graphics.lineTo(0,lcorn);

		for (var i:int=0; i<s.numChildren; i++)
		{
			s.getChildAt(i).alpha = 0;
			TweenLite.to(s.getChildAt(i), 0.3, {alpha:1, delay:0.1*i} );
		}

		function closeAndRemoveFn(callBack:Function):Function
		{
			return function():void
			{
				TweenLite.to(crossBtn, 0.3, { alpha:0 } );
				TweenLite.to(tickBtn, 0.3, { alpha:0, delay:0.1 } );
				TweenLite.to(title, 0.3, { alpha:0, delay:0.2, onComplete:function():void { if (s.parent != null) s.parent.removeChild(s); if (callBack!=null) callBack(); }} );
			}
		}//endfunction

		s.x = (sw-s.width)/2;
		s.y = (sh-s.height)/2;
		s.alpha = 0;
		targ.addChild(s);
		TweenLite.to(s, 0.3, { alpha:1 } );
		return s;
	}//endfunction

	//===============================================================================================
	// Generic ship editing mode menu
	//===============================================================================================
	public static function createSimpleEditModeMenu(targ:SpaceCrafter,
																									tickIco:BitmapData,crossIco:BitmapData,undoIco:BitmapData,
																									callBack:Function,undoFn:Function,showBtns:Vector.<Boolean>=null) : Sprite
	{
		if (showBtns!=null && showBtns.length!=3)		showBtns = null;
		var sw:Number = targ.stage.stageWidth;
		var sh:Number = targ.stage.stageHeight;
		var margX:Number = margF*sw;		// margin value

		var s:Sprite = new Sprite();

		// ----- create title and buttons
		var sc:Number = fontScale*sh/60;
		var bw:Number = Math.max(tickIco.width*sc,crossIco.width*sc,undoIco.width)+margX*10;	// ico bitmap w
		var bh:Number = Math.max(tickIco.height*sc,crossIco.height*sc,undoIco.width)+margX*2;	// ico bitmap h
		var tickBmd:BitmapData = new BitmapData(bw,bh,true,0x00000000);
		var crossBmd:BitmapData = new BitmapData(bw,bh,true,0x00000000);
		var undoBmd:BitmapData = new BitmapData(bw,bh,true,0x00000000);
		var colorT:ColorTransform = new ColorTransform((colorTone>>16)/255,((colorTone>>8) & 0xFF)/255,(colorTone & 0xFF)/255);
		tickBmd.draw(tickIco,new Matrix(sc,0,0,sc,(bw-tickIco.width*sc)/2,(bh-tickIco.height*sc)/2),colorT,null,null,true);
		crossBmd.draw(crossIco,new Matrix(sc,0,0,sc,(bw-crossIco.width*sc)/2,(bh-crossIco.height*sc)/2),colorT,null,null,true);
		undoBmd.draw(undoIco,new Matrix(sc,0,0,sc,(bw-undoIco.width*sc)/2,(bh-undoIco.height*sc)/2),colorT,null,null,true);
		var tickBtn:Sprite = createStandardButton(new Bitmap(tickBmd),closeAndRemoveFn(function():void {callBack(true);}));
		var crossBtn:Sprite = createStandardButton(new Bitmap(crossBmd),closeAndRemoveFn(function():void {callBack(false);}));
		var undoBtn:Sprite = createStandardButton(new Bitmap(undoBmd),undoFn);

		if (showBtns==null)
			TweenLite.to(crossBtn, 0.3, {x:margX, alpha:1, delay:0.1} );
		else
			crossBtn.visible = false;

		if (showBtns==null)
			TweenLite.to(tickBtn, 0.3, {x:margX, alpha:1, delay:0.2} );
		else
			tickBtn.visible = false;

		if (showBtns==null)
			TweenLite.to(undoBtn, 0.3, {x:sw-undoBtn.width-margX, alpha:1, delay:0.3} );
		else
			undoBtn.visible = false;
		crossBtn.alpha = 0;
		tickBtn.alpha = 0;
		undoBtn.alpha = 0;
		s.addChild(crossBtn);
		s.addChild(tickBtn);
		s.addChild(undoBtn);

		function enterFrameHandler(ev:Event):void
		{
			if (showBtns[0])
			{
				if (!tickBtn.visible)
				{
					tickBtn.visible=true;
					TweenLite.to(tickBtn, 0.3, {x:margX, alpha:1} );
					tickBtn.y = sh-tickBtn.height-margX-s.y;
				}
			}
			else
			{
				if (tickBtn.visible && tickBtn.alpha==1)
					TweenLite.to(tickBtn, 0.3, {x:0, alpha:0, onComplete:function():void {tickBtn.visible = false;}} );
			}

			if (showBtns[1])
			{
				if (!crossBtn.visible)
				{
					crossBtn.visible=true;
					TweenLite.to(crossBtn, 0.3, {x:margX, alpha:1} );
				}
			}
			else
			{
				if (crossBtn.visible && crossBtn.alpha==1)
					TweenLite.to(crossBtn, 0.3, {x:0, alpha:0, onComplete:function():void {crossBtn.visible = false;}} );
			}

			if (showBtns[2])
			{
				if (!undoBtn.visible)
				{
					undoBtn.visible = true;
					TweenLite.to(undoBtn, 0.3, {x:sw-undoBtn.width-margX, alpha:1} );
					undoBtn.x = sw - undoBtn.width;
				}
			}
			else
			{
				if (undoBtn.visible && undoBtn.alpha==1)
					TweenLite.to(undoBtn, 0.3, {x:sw-undoBtn.width, alpha:0, onComplete:function():void {undoBtn.visible = false;}} );
			}
		}//endfunction
		if (showBtns!=null)
			s.addEventListener(Event.ENTER_FRAME,enterFrameHandler);

		function closeAndRemoveFn(callBack:Function):Function
		{
			s.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
			return function():void
			{
				TweenLite.to(tickBtn, 0.3, { alpha:0 } );
				TweenLite.to(crossBtn, 0.3, { alpha:0, delay:0.1 } );
				TweenLite.to(undoBtn, 0.3, { alpha:0, delay:0.2 } );
				TweenLite.to(s, 0.3, { delay:0.3, onComplete:function():void { if (s.parent != null) s.parent.removeChild(s); if (callBack!=null) callBack(); }} );
			}
		}//endfunction

		targ.addChild(s);
		return s;
	}//endfunction

	//===============================================================================================
	// creates standard looking techy looking button
	//===============================================================================================
	public static function createStandardButton(bmp:Bitmap, onClick:Function=null) : Sprite
	{
		var lineColor:uint = uint((colorTone>>16)*0.5)<<16 | uint(((colorTone>>8) & 0xFF)*0.5)<<8 | uint((colorTone & 0xFF)*0.5);
		var s:Sprite = new Sprite();
		var lmarg:int = int(bmp.height/12);
		var lcorn:int = int(bmp.height/4);
		s.graphics.lineStyle(2, lineColor, lmarg);
		s.graphics.beginFill(0x000000, 0.3);
		s.graphics.moveTo(lmarg, lcorn);		// top left corner
		s.graphics.lineTo(lcorn, lmarg);
		s.graphics.lineTo(bmp.width-lmarg-lcorn/2, lmarg);		// top right corner
		s.graphics.lineTo(bmp.width-lmarg, lmarg+lcorn/2);
		s.graphics.lineTo(bmp.width-lmarg, bmp.height-lcorn);	// bottom right corner
		s.graphics.lineTo(bmp.width-lmarg-lcorn/2, bmp.height-lcorn/2);
		s.graphics.lineTo(bmp.width-lmarg-lcorn/2-bmp.width/3, bmp.height-lcorn/2);
		s.graphics.lineTo(bmp.width - lcorn-bmp.width/3, bmp.height - lmarg);
		s.graphics.lineTo(lmarg+lcorn/2, bmp.height - lmarg);	// bottom left corner
		s.graphics.lineTo(lmarg, bmp.height - lmarg - lcorn/2);
		s.graphics.lineTo(lmarg, lcorn);
		var smallRectSize:int = bmp.height / 8;
		s.graphics.beginFill(colorTone, 0.5);
		s.graphics.drawRect(lmarg * 3, bmp.height - lmarg * 3 - smallRectSize, smallRectSize, smallRectSize);
		s.graphics.endFill();
		bmp.bitmapData.draw(s,null,null,"add");
		s.graphics.clear();
		s.addChild(bmp);
		setAsBtn(s, onClick);
		return s;
	}//endfunction

	//===============================================================================================
	// create text bitmap
	//===============================================================================================
	public static function createTextBmp(txt:String, size:int=20, marg:int=0, color:uint=0x99FFFF) : Bitmap
	{
		var borderWidth:int = size / 4;
		var tf:TextField = new TextField();
		tf.autoSize = "left";
		tf.wordWrap = false;
		tf.defaultTextFormat = new TextFormat("arial bold",size,color,null,null,null,null,null,null,marg,marg);
		tf.text = txt;
		tf.filters = [new GlowFilter(color, 1, borderWidth, borderWidth, 1, 1)];

		var bmd:BitmapData = new BitmapData(tf.width+borderWidth*2,tf.height+borderWidth*2,true,0x000000);
		bmd.draw(tf, new Matrix(1, 0, 0, 1, borderWidth, borderWidth));
		return new Bitmap(bmd);
	}//endfunction

	//===============================================================================================
	// create a text bitmap with type out anim, text follows name value
	//===============================================================================================
	public static function createTypeOutTextBmp(s:String,size:int,marg:int=0) : Bitmap
	{
		if (s==null) s="";
		var borderWidth:int = size / 4;
		var tf:TextField = new TextField();
		tf.autoSize = "left";
		tf.wordWrap = false;
		tf.defaultTextFormat = new TextFormat("arial bold",size,colorTone,null,null,null,null,null,null,marg,marg);
		tf.text = " ";
		tf.filters = [new GlowFilter(colorTone, 1, borderWidth, borderWidth, 1, 1)];

		var bmd:BitmapData = new BitmapData(1,tf.height+borderWidth*2,true,0x00000000);
		var bmp:Bitmap = new Bitmap(bmd);
		var mat:Matrix = new Matrix(1, 0, 0, 1, borderWidth, borderWidth);
		var rect:Rectangle = new Rectangle(0,0,bmd.width,bmd.height);

		bmp.name = s;
		var targTxt:String = "";

		function enterFrameHandler(ev:Event):void
		{
			if (bmp.name==null) bmp.name="";
			if (bmp.name!=targTxt)
			{	// ----- detect text change, change to new sized bmd for new text
				targTxt = bmp.name;
				var otxt:String = tf.text;
				tf.text = targTxt;
				bmd = new BitmapData(tf.width+borderWidth*2,tf.height+borderWidth*2,true,0x99000000);
				tf.text = otxt;
			}

			if (bmp.bitmapData!=bmd && tf.width<=bmd.width)
			{	// not yet swapped to new sized bmd
				bmp.bitmapData.dispose();
				bmp.bitmapData = bmd;
				rect.width = bmd.width;
				rect.height = bmd.height;
			}

			var txt:String = tf.text;

			if (txt.length>targTxt.length || targTxt.substr(0,txt.length)!=txt)
			{	// ----- delete chars from behind
				tf.text = txt.substr(0,txt.length-1);
				bmp.bitmapData.fillRect(rect,0);
				bmp.bitmapData.draw(tf, mat);	// draw textField on bmd
			}
			else if (txt.length<targTxt.length)
			{	// ----- type chars out
				tf.text = targTxt.substr(0,txt.length+1);
				bmp.bitmapData.fillRect(rect,0);
				bmp.bitmapData.draw(tf, mat);	// draw textField on bmd
			}
		}//endfunction
		bmp.addEventListener(Event.ENTER_FRAME,enterFrameHandler);

		function removeHandler(ev:Event):void
		{
			bmp.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			bmp.removeEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
		}//endfunction
		bmp.addEventListener(Event.REMOVED_FROM_STAGE, removeHandler);

		return bmp;
	}//endfunction

	//===============================================================================================
	// generic button interraction
	//===============================================================================================
	private static function setAsBtn(s:Sprite,onClick:Function=null) : void
	{
		s.buttonMode = true;
		s.mouseChildren = false;
		var glowTween:TweenLite = TweenLite.to(s, 1, { glowFilter: { color:colorTone, blurX:0, blurY:0, strength:0, alpha:0, remove:true }} );;
		function rollOverHandler(ev:Event):void
		{
			glowTween.kill();
			glowTween = TweenLite.to(s, 0.2, { glowFilter: { color:colorTone, blurX:8, blurY:1, strength:1, alpha:1 }} );
		}

		function rollOutHandler(ev:Event):void
		{
			glowTween.kill();
			glowTween = TweenLite.to(s, 1, { glowFilter: { color:colorTone, blurX:0, blurY:0, strength:0, alpha:0, remove:true}} );
		}

		function clickHandler(ev:Event):void
		{
			glowTween.kill();
			s.filters = [new GlowFilter(0xFFFFFF, 1, 16, 4, 3, 2)];
			glowTween = TweenLite.to(s, 0.3, { glowFilter: { color:colorTone, blurX:0, blurY:0, strength:0, alpha:0, remove:true }} );
			if (clickSfx!=null)	clickSfx();		// play the click sound
			if (onClick!=null) onClick();
		}

		function removedHandler(ev:Event):void
		{
			glowTween.kill();
			s.filters = [];
			s.removeEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			s.removeEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
			s.removeEventListener(MouseEvent.CLICK,clickHandler);
			s.removeEventListener(Event.REMOVED_FROM_STAGE,removedHandler);
		}

		s.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
		s.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
		s.addEventListener(MouseEvent.CLICK,clickHandler);
		s.addEventListener(Event.REMOVED_FROM_STAGE,removedHandler);
	}//endfunction

	//===============================================================================================
	// create textured font with textured edges
	//===============================================================================================
	public static function createTexturedTitle(txt:String,tex1:BitmapData,tex2:BitmapData,borderWidth:int=10) : Bitmap
	{
		var tf:TextField = new TextField();
		tf.autoSize = "left";
		tf.wordWrap = false;
		tf.htmlText = txt;
		tf.x = borderWidth;
		tf.y = borderWidth;
		tf.filters = [new GlowFilter(0xFFFFFF,1,borderWidth*2,borderWidth*2,100,1)];

		var tfmc:Sprite = new Sprite();
		tfmc.addChild(tf);

		// ----- draw text inner background
		var bg:Sprite = new Sprite();
		bg.graphics.beginBitmapFill(tex2,new Matrix(0.5,0,0,0.5));
		bg.graphics.drawRect(0,0,tf.width+borderWidth*2,tf.height+borderWidth*2);
		bg.graphics.endFill();

		// ----- draw outer text border
		var bmd:BitmapData = new BitmapData(tf.width+borderWidth*2,tf.height+borderWidth*2,true,0x000000);
		var s:Sprite = new Sprite();
		s.addChild(tfmc);
		bmd.draw(bg);
		bmd.draw(s,null,null,'alpha',null,false);
		bmd.applyFilter(bmd,new Rectangle(0,0,bmd.width,bmd.height),new Point(0,0),new GlowFilter(0,1,borderWidth,borderWidth,2,1,true));

		// ----- draw inner Text
		tf.filters = [];
		bg.graphics.clear();
		bg.graphics.beginBitmapFill(tex1,new Matrix(0.5,0,0,0.5));
		bg.graphics.drawRect(0,0,tf.width+borderWidth*2,tf.height+borderWidth*2);
		bg.graphics.endFill();
		s.addChildAt(bg,0);
		tfmc.cacheAsBitmap = true;
		bg.mask = tfmc;
		var tmd:BitmapData = new BitmapData(bmd.width,bmd.height,true,0x00000000);
		tmd.draw(s);
		tmd.applyFilter(tmd,new Rectangle(0,0,tmd.width,tmd.height),new Point(0,0),new GlowFilter(0,1,borderWidth,borderWidth,1,1,true));
		tmd.applyFilter(tmd,new Rectangle(0,0,tmd.width,tmd.height),new Point(0,0),new GlowFilter(0,1,2,2,2,1));

		// ----- combine inner and outer text
		bmd.copyPixels(tmd,new Rectangle(0,0,tmd.width,tmd.height),new Point(borderWidth,borderWidth),null,null,true);
		tmd.dispose();
		return new Bitmap(bmd);
	}//endfunction

	//===============================================================================================
	// standard stats readout for a ship
	//===============================================================================================
	public static function createShipHUD(ship:Ship, stage:Stage) : Sprite
	{
		var s:Sprite = new Sprite();

		// ----- create stats labels
		var labColor:uint = uint((colorTone>>16)*0.7)<<16 | uint(((colorTone>>8) & 0xFF)*0.7)<<8 | uint((colorTone & 0xFF)*0.7);
		var fSize:Number = fontScale*stage.stageHeight/2;
		var labelsBmp:Bitmap = createTextBmp("Speed\nAccel\nTurnRate",fSize,0,labColor);
		s.addChild(labelsBmp);
		var maxValuesBmp:Bitmap = createTextBmp("/ "+Math.floor(ship.maxSpeed*10000)/10+"\n/ "+Math.floor(ship.maxAccel*10000)/10+"\n/ "+Math.floor(ship.maxRotAccel*10000)/10,fSize,0,labColor);
		s.addChild(maxValuesBmp);

		var curStatsTf:TextField = new TextField();
		curStatsTf.autoSize = "left";
		curStatsTf.wordWrap = false;
		curStatsTf.defaultTextFormat = new TextFormat("arial bold",fSize,colorTone,null,null,null,null,null,"right",0,0);
		curStatsTf.filters = [new GlowFilter(colorTone, 1, fSize/4, fSize/4, 1, 1)];
		s.addChild(curStatsTf);

		var txtIntegrity:TextField = new TextField();
		txtIntegrity.autoSize = "left";
		txtIntegrity.wordWrap = false;
		txtIntegrity.defaultTextFormat = new TextFormat("arial bold",fSize,colorTone,null,null,null,null,null,"right",0,0);
		txtIntegrity.filters = [new GlowFilter(colorTone, 1, fSize/4, fSize/4, 1, 1)];
		s.addChild(txtIntegrity);

		var txtEnergy:TextField = new TextField();
		txtEnergy.autoSize = "right";
		txtEnergy.wordWrap = false;
		txtEnergy.defaultTextFormat = new TextFormat("arial bold",fSize,colorTone,null,null,null,null,null,"right",0,0);
		txtEnergy.filters = [new GlowFilter(colorTone, 1, fSize/4, fSize/4, 1, 1)];
		s.addChild(txtEnergy);

		var curE:int = 0;
		var curH:int = 0;
		var p1:Number=0;
		var p2:Number=0;
		function update(ev:Event=null):void
		{
			var sw:int = stage.stageWidth;
			var sh:int = stage.stageHeight;
			var bw:int = Math.round(sw*(0.5-margF*4));
			var bh:int = Math.round(sh*0.02);

			curStatsTf.text = Math.round(ship.vel.length*10000)/10+"\n"+Math.round(ship.accel*10000)/10+"\n"+Math.round(ship.rotAccel.length*10000)/10;

			maxValuesBmp.x = sw*(1-margF)-maxValuesBmp.width;
			maxValuesBmp.y = sh-bh*3.5-maxValuesBmp.height;
			curStatsTf.x = maxValuesBmp.x-curStatsTf.width;
			curStatsTf.y = maxValuesBmp.y+fSize/4;
			labelsBmp.x = maxValuesBmp.x - maxValuesBmp.width - labelsBmp.width;
			labelsBmp.y = maxValuesBmp.y;

			var ph:int = sh-bh-sw*margF;

			txtEnergy.text = "Energy : "+Math.round(ship.energy)+"/"+ship.maxEnergy;
			txtEnergy.x = sw*margF;
			txtEnergy.y = ph - txtEnergy.height;

			txtIntegrity.text = Math.round(ship.integrity)+"/"+ship.maxIntegrity+" : Hull Integrity";
			txtIntegrity.x = sw*(1-margF)-txtIntegrity.width;
			txtIntegrity.y = ph - txtIntegrity.height;

			s.graphics.clear();
			var targE:int = Math.round(ship.energy);
			var targH:int = Math.round(ship.integrity);
			if (targE!=curE || targH!=curH)
			{
				var x1:int = sw*margF;
				var x2:int = sw*(1-margF)-bw;
				// --- draw energy bar
				p1 = targE / ship.maxEnergy;
				p2 = curE / ship.maxEnergy;
				drawBar(s,x1,ph,bw,bh,p1,p2,0x00AACC,0xCC0000,0x111111,false);
				curE = Math.round((curE*2 + targE) / 3);
				if ((curE-targE)*(curE-targE)<1) curE = targE;
				// --- draw health bar
				p1 = targH / ship.maxIntegrity;
				p2 = curH / ship.maxIntegrity;
				drawBar(s,x2,ph,bw,bh,p1,p2,0xBBBBAA,0xCC0000,0x111111,true);
				curH = Math.round((curH*2 + targH) / 3);
				if ((curH-targH)*(curH-targH)<1) curH = targH;

				drawVertThrottle(s,x1+bw+sw*margF,sh*(1-10*margF),x2-x1-bw-2*sw*margF,sh*9*margF,ship.vel.length/ship.maxSpeed,0x66FF66,0x000000);
			}

			if (ship.integrity <= 0)	removeHandler();
		}//endfunction

		function removeHandler(ev:Event=null):void
		{
			s.removeEventListener(Event.ENTER_FRAME, update);
			s.removeEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
		}

		s.addEventListener(Event.ENTER_FRAME, update);
		s.addEventListener(Event.REMOVED_FROM_STAGE, removeHandler);

		update();
		return s;
	}//endfunction

	//===============================================================================================
	// convenience function to
	//===============================================================================================
	private static function drawVertThrottle(s:Sprite,x:int,y:int,w:int,h:int,p:Number,c1:uint,c2:uint):void
	{
		var n:int=10;
		for (var i:int=0; i<n; i++)
		{
			if ((i/n)<p)
				s.graphics.beginFill(c1,1);
			else
				s.graphics.beginFill(c2,1);
			s.graphics.drawRoundRect(x,y+h*(1-(i+1)/n),w,h/n/2,h/n/2);
			s.graphics.endFill();
		}
	}//endfunction

	//===============================================================================================
	// convenience function to draw a healthbar
	//===============================================================================================
	[Inline]
	private static function drawBar(s:Sprite,x:int,y:int,w:int,h:int,p1:Number,p2:Number,c1:uint,c2:uint,c3:uint,alignL:Boolean):void
	{
		if (p1<0) p1=0;
		if (p2<p1) p2=p1;
		s.graphics.beginFill(0xFFFFFF,0.5);
		s.graphics.drawRect(x,y,2,h);
		s.graphics.drawRect(x+w-2,y,2,h);
		s.graphics.endFill();
		x += 2;			// create bar inset
		y += 2;
		w -= 4;
		h -= 4;
		p1*= w;
		p2*= w;
		var matr:Matrix = new Matrix();
		if (alignL) matr.createGradientBox(w, h, Math.PI, x, y);
		else 				matr.createGradientBox(w, h, 0, x, y);
		s.graphics.beginGradientFill("linear", [colorBrightness(c3,1.1), colorBrightness(c3,0.8), colorBrightness(c3,0.3)], [0.5,0.5,0.5], [0x00,0x80,0xFF], matr, "pad"); 	// grey bar
		if (alignL) s.graphics.drawRect(x+p2, y, w-p2, h);
		else				s.graphics.drawRect(x, y, w-p2, h);
		s.graphics.endFill();
		if (p2 > p1)
		{
			s.graphics.beginGradientFill("linear", [colorBrightness(c2,1.1), colorBrightness(c2,0.8), colorBrightness(c2,0.3)], [1,1,1], [0x00,0x80,0xFF], matr, "pad");	// red retreat bar
			if (alignL)	s.graphics.drawRect(x+p1, y, p2-p1, h);
			else 				s.graphics.drawRect(x+w-p2, y, p2-p1, h);
			s.graphics.endFill();
		}
		s.graphics.beginGradientFill("linear", [colorBrightness(c1,1.1), colorBrightness(c1,0.8), colorBrightness(c1,0.3)], [1,1,1], [0x00,0x80,0xFF], matr, "pad");			// green health bar
		if (alignL)	s.graphics.drawRect(x, y, p1, h);
		else				s.graphics.drawRect(x+w-p1, y, p1, h);
		s.graphics.endFill();
	}//endfunction

	//===============================================================================================
	// convenience function to tweak color brightness with multiplier
	//===============================================================================================
	[Inline]
	private static function colorBrightness(c:uint,mul:Number) : uint
	{
		var r:uint = c>>16;
		var g:uint = (c>>8) & 0xFF;
		var b:uint = c & 0xFF;
		r*=mul;	if (r>255) r=255;
		g*=mul; if (g>255) g=255;
		b*=mul; if (b>255) b=255;
		return r<<16 | g<<8 | b;
	}//endfunction

	//===============================================================================================
	// draws out waveform of sound output
	// sampInt: sample interval minimum 4
	// mag: height/2 of the display area
	//===============================================================================================
	public static function createSoundOutputDisplay(sampInt:int=8,mag:int=20) : Sprite
	{
		sampInt = Math.max(sampInt,4);
		var canvas:Sprite = new Sprite();
		canvas.addEventListener(Event.ENTER_FRAME,readWaveform);
		canvas.addEventListener(MouseEvent.CLICK,clickHandler);

		// ---------------------------------------------------------------------------
		function readWaveform(ev:Event):void
		{
			// ----- float on top of other movieClips ---------------
			/*
			if (canvas.parent!=null && canvas.parent.numChildren>canvas.parent.getChildIndex(canvas))
			{
				var pp = canvas.parent;
				pp.addChild(pp.removeChild(canvas));
			}
			*/
			var vol:Number = SoundMixer.soundTransform.volume;

			// ----- draw bounding box ------------------------------
			canvas.graphics.clear();
			canvas.graphics.lineStyle(0,0xFFFFFF,0.10);
			canvas.graphics.beginFill(0x000000,0.5);
			canvas.graphics.drawRect(0,0,256/sampInt*4,mag*2);
			canvas.graphics.endFill();

			// ----- read waveform data -----------------------------
			var bytes:ByteArray = new ByteArray();
			SoundMixer.computeSpectrum(bytes);
			bytes.position=0;

			// ----- draw left channel waveform ---------------------
			canvas.graphics.lineStyle(0,0x33FFFF,1);
			var val:Number = bytes.readFloat();
			canvas.graphics.moveTo(0,val*vol*mag+mag);
			for (bytes.position=4; bytes.position<1024; bytes.position+=sampInt-4)
			{
				val = bytes.readFloat();
				canvas.graphics.lineTo(bytes.position/sampInt,val*vol*mag+mag);
			}//endFor

			// ----- draw right channel waveform --------------------
			val = bytes.readFloat();
			canvas.graphics.moveTo(0,val*vol*mag+mag);
			for (bytes.position=1024; bytes.position<2048; bytes.position+=sampInt-4)
			{
				val = bytes.readFloat();
				canvas.graphics.lineTo((bytes.position-1024)/sampInt,val*vol*mag+mag);
			}//endFor

			// ----- draw end rectangles ----------------------------
			canvas.graphics.lineStyle();
			canvas.graphics.beginFill(0x999999,1);
			canvas.graphics.drawRect(-1,(1-vol)*mag,2,vol*mag*2);
			canvas.graphics.drawRect(256/sampInt*4-1,(1-vol)*mag,2,vol*mag*2);
			canvas.graphics.endFill();

		}//endfunction

		// ---------------------------------------------------------------------------
		function clickHandler(ev:MouseEvent):void
		{
			if (SoundMixer.soundTransform.volume>0.6)
				SoundMixer.soundTransform = new SoundTransform(0.5,0);
			else if (SoundMixer.soundTransform.volume>0)
				SoundMixer.soundTransform = new SoundTransform(0,0);
			else
				SoundMixer.soundTransform = new SoundTransform(1,0);
		}//endfunction

		canvas.buttonMode = true;
		return canvas;
	}//endfunction
}//endclass

class Module		// data class
{
	public var x:Number=0;	// center
	public var y:Number=0;
	public var z:Number=0;

	public var nx:Number=0;	// orientation
	public var ny:Number=0;
	public var nz:Number=0;

	public var type:String=null;	// type of weapon

	public var bearing:Number=0;	// elevation of turret (local space)
	public var elevation:Number=0;	// bearing of turret (local space)

	public var ttf:int=0;			// time to fire
	public var fireDelay:int=3;		// delay to next shot
	public var range:Number=10;		// range of weapon
	public var turnRate:Number=0.05;// rotation speed of turret
	public var speed:Number=0.1;	//
	public var damage:Number=1;		//
	public var muzzleLen:Number=0.3;

	/**
	 *
	 * @param	px
	 * @param	py
	 * @param	pz
	 * @param	vx
	 * @param	vy
	 * @param	vz
	 * @param	kind
	 */
	public function Module(px:Number=0,py:Number=0,pz:Number=0,vx:Number=0,vy:Number=0,vz:Number=-1,kind:String=""):void
	{
		x=px;
		y=py;
		z=pz;
		nx=vx;
		ny=vy;
		nz=vz;
		type=kind;

		if (kind=="tractorS")
		{
			range=30;
			turnRate=0.2;
			speed=0.05;
		}
		else if (kind=="launcherS")
		{
			fireDelay=1000;
			speed=0.2;		// only initial launch speed. missiles have accel
			damage=200;
			range=40;
		}
		else if (kind=="gunAutoS")
		{
			fireDelay=3;
			speed=0.5;
			damage=4;
			range=8;
			turnRate=0.1;
			muzzleLen=0.26;
		}
		else if (kind=="gunFlakS")
		{
			fireDelay=50;
			speed=0.3;
			damage=20;
			range=7;
			muzzleLen=0.3;
		}
		else if (kind=="gunIonS")
		{
			fireDelay=40;
			speed=0.3;
			damage=20;
			range=15;
			muzzleLen=0.35;
		}
		else if (kind=="gunPlasmaS")
		{
			fireDelay=80;
			speed=0.15;
			damage=80;
			range=15;
			muzzleLen=0.35;
		}
		else if (kind=="gunRailS")
		{
			fireDelay=60;
			speed=0.6;
			damage=20;
			range=20;
			muzzleLen=0.37;
		}
		else if (kind=="gunIonM")
		{
			fireDelay=80;
			speed=0.3;
			damage=160;
			turnRate = 0.02;
			range=30;
			muzzleLen=0.7;
		}
		else if (kind=="gunRailM")
		{
			fireDelay=100;
			speed=0.6;
			damage=200;
			turnRate = 0.02;
			range=40;
			muzzleLen=0.7;
		}
		else if (kind=="gunPlasmaM")
		{
			fireDelay=100;
			speed=0.15;
			damage=400;
			turnRate = 0.02;
			range=30;
			muzzleLen=0.7;
		}
	}//endconstr

	public function toString():String
	{
			return 	Math.round(x*10)/10+","+Math.round(y*10)/10+","+Math.round(z*10)/10+","+
							Math.round(nx*10)/10+","+Math.round(ny*10)/10+","+Math.round(nz*10)/10+","+type;
	}//endfunction
}//endclass

class HullBlock		// data class
{
	public var x:int=0;
	public var y:int=0;
	public var z:int=0;
	public var integrity:Number = 0;		// used in astroid
	public var parent:Hull = null;			// used for projectile collision resolution
	public var extPosn:Vector3D = null;	// used for calc turret aim
	public var module:Module=null;			// module occupying this hullBlock
	public var walked:Boolean = false;

	public function HullBlock(px:int,py:int,pz:int,hull:Hull):void
	{
		x=px;
		y=py;
		z=pz;
		parent=hull;
		extPosn = new Vector3D(px,py,pz);
	}//endconstr
}//endclass

class Hull
{
	public var name:String = "";

	public var hullConfig:Vector.<HullBlock> = null;	// hull shape configuration

	public var skin:Mesh = null;
	public var hullSkin:Mesh = null;

	public var pivot:Vector3D = null;					// point hull rotates about
	public var radius:Number = 0;							// radius of hull
	public var posn:Vector3D = null;					// current position
	public var vel:Vector3D = null;						// current position
	public var rotPosn:Vector3D = null;				// current orientation quaternion
	public var rotVel:Vector3D = null;				// current rotational velocity quaternion
	public var integrity:Number = 0;

	private static var Adj:Vector.<Vector3D> = null;	// convenient for adjacent blocks chks

	//===============================================================================================
	// constructs a blocky hull entity
	//===============================================================================================
	public function Hull(hullName:String=null,texMap:BitmapData=null,specMap:BitmapData=null,normMap:BitmapData=null):void
	{
		if (hullName!=null)
			name = hullName;

		pivot = new Vector3D();	// CG point hull rotates about
		posn = new Vector3D();
		vel = new Vector3D();

		skin = new Mesh();
		hullSkin = new Mesh();
		hullSkin.material.setSpecular(1,1);
		hullSkin.material.setTexMap(texMap);
		hullSkin.material.setSpecMap(specMap);
		hullSkin.material.setNormMap(normMap);
		skin.addChild(hullSkin);

		if (Adj==null)
		Adj = new <Vector3D>[new Vector3D(0,0,-1),	// front
												 new Vector3D(1,0,0),	// right
												 new Vector3D(0,0,1),	// back
												 new Vector3D(-1,0,0),	// left
												 new Vector3D(0,-1,0),	// bottom
												 new Vector3D(0,1,0)];	// top

		hullConfig = new Vector.<HullBlock>();

		// ----- initializes with default hull
		hullConfig.push(new HullBlock(0,0,0,this));

		rebuildHull();				// update hull look from config infos
	}//endfunction

	//===============================================================================================
	// placeholder, should be overridden
	//===============================================================================================
	public function updateStep():void
	{
		posn.x += vel.x;
		posn.y += vel.y;
		posn.z += vel.z;
		rotPosn = Matrix4x4.quatMult(rotVel,rotPosn);		// update rotation

		// ----- update transform
		skin.transform = Matrix4x4.quaternionToMatrix(rotPosn.w,rotPosn.x,rotPosn.y,rotPosn.z).mult(new Matrix4x4().translate(-pivot.x,-pivot.y,-pivot.z)).translate(posn.x,posn.y,posn.z);
		updateHullBlocksWorldPosns();	// calculate global positions for each hull space
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	public function setFromConfig(config:String):void
	{
		var H:Array = config.split(",");

		// ----- replicate from hullConfig info
		hullConfig = new Vector.<HullBlock>();
		for (var i:int=0; i<H.length; i+=3)
			hullConfig.push(new HullBlock(parseInt(H[i],10),parseInt(H[i+1],10),parseInt(H[i+2],10),this));

		rebuildHull();
	}//endfunction

	//===============================================================================================
	// updates hullblocks extPosns property to current world position according to skin transform
	//===============================================================================================
	public function updateHullBlocksWorldPosns():void
	{
		var t:Matrix4x4 = skin.transform;
		for (var j:int=hullConfig.length-1; j>-1; j--)
		{
			var hb:HullBlock = hullConfig[j];
			hb.extPosn.x = hb.x*t.aa+hb.y*t.ab+hb.z*t.ac+t.ad;
			hb.extPosn.y = hb.x*t.ba+hb.y*t.bb+hb.z*t.bc+t.bd;
			hb.extPosn.z = hb.x*t.ca+hb.y*t.cb+hb.z*t.cc+t.cd;
		}
	}//endfunction

	//===============================================================================================
	// randomly generates a hull shape
	//===============================================================================================
	public function randomHullConfig(n:uint=10,symmetry:Boolean=true) : void
	{
		hullConfig = new Vector.<HullBlock>();
		if (n==0) return;
		hullConfig.push(new HullBlock(0,0,0,this));
		var Adj:Vector.<Vector3D> = Vector.<Vector3D>([	new Vector3D(0,0,1),new Vector3D(0,0,-1),
														new Vector3D(0,1,0),new Vector3D(0,-1,0),
														new Vector3D(1,0,0),new Vector3D(-1,0,0)]);
		for (var i:int=1; i<n; i++)
		{
			do {
				var dir:Vector3D = Adj[int(Adj.length*Math.random())];
				var hull:HullBlock = hullConfig[int(hullConfig.length*Math.random())];
			} while (hullIdx(hull.x+dir.x,hull.y+dir.y,hull.z+dir.z)!=-1);
			hullConfig.push(new HullBlock(hull.x+dir.x,hull.y+dir.y,hull.z+dir.z,this));
			if (symmetry && hullIdx(-hull.x-dir.x,hull.y+dir.y,hull.z+dir.z)==-1)
			{
				hullConfig.push(new HullBlock(-hull.x-dir.x,hull.y+dir.y,hull.z+dir.z,this));
				i++;
			}
		}//endfor
	}//endfunction

	//===============================================================================================
	// extends ship chassis adding new block at position
	//===============================================================================================
	public function extendHull(px:int,py:int,pz:int) : Boolean
	{
		if (adjacentToHull(px,py,pz))
		{
			hullConfig.push(new HullBlock(px, py, pz,this));
			return true;
		}
		return false;
	}//endfunction

	//===============================================================================================
	// trims ship chassis removing block at position
	//===============================================================================================
	public function trimHull(px:int,py:int,pz:int) : Boolean
	{
		if (hullConfig.length<=1)	return false;

		if (adjacentToSpace(px,py,pz))	// posn in hull and next to skin surface
		{
			var idx:int = hullIdx(px,py,pz);
			var h:HullBlock = hullConfig[idx];
			hullConfig.splice(idx,1);
			if (isOnePiece())
			{
				return true;
			}
			else
			{
				hullConfig.push(h);
				return false;
			}
		}

		return false;
	}//endfunction

	//===============================================================================================
	// creates the hull mesh geometry from hullConfig info
	//===============================================================================================
	public function rebuildHull(uMin:Number=0,uMax:Number=1,vMin:Number=0,vMax:Number=1) : void
	{
		// ----- update chassis skin
		radius = 0;
		pivot = new Vector3D();
		var tmp:Mesh = new Mesh();
		for (var i:int=hullConfig.length-1; i>-1; i--)
		{
			var h:HullBlock = hullConfig[i];
			tmp.addChild(createHullPart(h.x,h.y,h.z,uMin,uMax,vMin,vMax));
			pivot.x+=h.x;
			pivot.y+=h.y;
			pivot.z+=h.z;
		}
		tmp = tmp.mergeTree();
		if (hullConfig.length>0)
		{
			hullSkin.setGeometry(tmp.vertData,tmp.idxsData);
			pivot.scaleBy(1/hullConfig.length);
			radius = tmp.maxXYZ().subtract(tmp.minXYZ()).length/2;
		}
		integrity = hullConfig.length*100;
	}//endfunction

	//===============================================================================================
	// returns if hull position is adjacent to empty space
	//===============================================================================================
	public function adjacentToSpace(px:int,py:int,pz:int) : Boolean
	{
		if (hullIdx(px,py,pz)==-1)	return false;	// chk if not in hull

		for (var i:int=5; i>=0; i--)
			if (hullIdx(px+Adj[i].x,py+Adj[i].y,pz+Adj[i].z)==-1)
				return true;

		return false;
	}//endfunctioh

	//===============================================================================================
	// returns if empty space position is adjacent to current hull configuration
	//===============================================================================================
	public function adjacentToHull(px:int,py:int,pz:int) : Boolean
	{
		if (hullIdx(px,py,pz)!=-1)	return false;	// chk if in hull

		for (var i:int=5; i>=0; i--)
			if (hullIdx(px+Adj[i].x,py+Adj[i].y,pz+Adj[i].z)!=-1)
				return true;

		return false;
	}//endfunction

	//===============================================================================================
	// returns index of hullBlock occupying position, useful to check if position is within ship hull
	//===============================================================================================
	protected function hullIdx(px:int,py:int,pz:int) : int
	{
		for (var i:int=hullConfig.length-1; i>=0; i--)
		{
			var h:HullBlock = hullConfig[i];
			if (h.x==px && h.y==py && h.z==pz)
				return i;
		}

		return -1;
	}//endfunction

	//===============================================================================================
	// returns the necessary face extensions to form the hull skin only
	//===============================================================================================
	protected function createHullPart(px:int,py:int,pz:int,uMin:Number=0,uMax:Number=1,vMin:Number=0,vMax:Number=1) : Mesh
	{
		var i:int=0;

		// vertices
		var V:Vector.<Number> = new <Number>[-0.5,-0.5,-0.5,  0.5,-0.5,-0.5,  0.5,0.5,-0.5,  -0.5,0.5,-0.5,
												 -0.5,-0.5, 0.5,  0.5,-0.5, 0.5,  0.5,0.5, 0.5,  -0.5,0.5, 0.5,
												 -0.5,0,0,  0.5,0,0,	// 8left 9right
												 0,0.5,0,  0,-0.5,0,	// 10up 11down
												 0,0,-0.5,  0,0,0.5];	// 12front 13back
		// tri indices
		var I:Vector.<uint> = new <uint>[0,3,12, 3,2,12, 2,1,12, 1,0,12, 	// front 0,3,2,1
											 1,2,9, 2,6,9, 6,5,9, 5,1,9,			// right 1,2,6,5
											 5,6,13, 6,7,13, 7,4,13, 4,5,13,	// back 5,6,7,4
											 4,7,8, 7,3,8, 3,0,8, 0,4,8,			// left 4,7,3,0
											 4,0,11, 0,1,11, 1,5,11, 5,4,11,	// bottom  4,0,1,5
											 3,7,10, 7,6,10, 6,2,10, 2,3,10];	// top  3,7,6,2

		// determine which face to delete
		for (i=5; i>=0; i--)
			if (hullIdx(px+Adj[i].x,py+Adj[i].y,pz+Adj[i].z)!=-1)
				I.splice(i*12,12);

		// shrink vertice inwards if not connected to adj hull plate
		for (var v:int=0; v<8; v++)	// for all corner points
		{
			var fcnt:int=0;		// if not connected, corner point must have 6 tri faces using it
			for (i=I.length-1; i>-1; i--)
				if (I[i]==v)
					fcnt++;

			if (fcnt==6)
			{
				V[v*3+0]*=0.78;
				V[v*3+1]*=0.78;
				V[v*3+2]*=0.78;
			}
		}

		var uMid:Number = (uMin+uMax)/2;
		var vMid:Number = (vMin+vMax)/2;
		var U:Vector.<Number> =
		new <Number>[	uMin,vMin, uMin,vMax, uMid,vMid,
									uMin,vMax, uMax,vMax, uMid,vMid,
									uMax,vMax, uMax,vMin, uMid,vMid,
									uMax,vMin, uMin,vMin, uMid,vMid];	// UV coords
		var ul:uint=U.length;
		var VData:Vector.<Number> = new Vector.<Number>();
		for (i=0; i<I.length; i+=3)
		VData.push(	V[I[i+0]*3+0],V[I[i+0]*3+1],V[I[i+0]*3+2],	// vertex a
					0,0,0,	// normal a
					U[i*2%ul+0],U[i*2%ul+1],
					V[I[i+1]*3+0],V[I[i+1]*3+1],V[I[i+1]*3+2],	// vertex b
					0,0,0,	// normal b
					U[i*2%ul+2],U[i*2%ul+3],
					V[I[i+2]*3+0],V[I[i+2]*3+1],V[I[i+2]*3+2],	// vertex c
					0,0,0,	// normal c
					U[i*2%ul+4],U[i*2%ul+5]);

		var m:Mesh = new Mesh();
		m.createGeometry(VData);
		m.transform = new Matrix4x4().translate(px,py,pz);
		return m;
	}//endfunction

	//===============================================================================================
	// returns the free hullBlocks to be occupied by module of given size
	//===============================================================================================
	public function getHullBlocks(px:Number,py:Number,pz:Number,size:uint=1) : Vector.<HullBlock>
	{
		if (size==0) 	size=1;
		var V:Vector.<HullBlock> = new Vector.<HullBlock>();
		var off:Number = (size-1)/2;
		for (var x:int=0; x<size; x++)
			for (var y:int=0; y<size; y++)
				for (var z:int=0; z<size; z++)
				{
					var idx:int = hullIdx(Math.round(px+ x-off),Math.round(py+ y-off),Math.round(pz+ z-off));
					if (idx!=-1) V.push(hullConfig[idx]);
				}
		return V;
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	public function registerHit(hitPt:VertexData,dmg:Number):void
	{

	}//endfunction

	//===============================================================================================
	// checks if there are disjointed hull pieces
	//===============================================================================================
	public function isOnePiece() : Boolean
	{
		if (hullConfig==null || hullConfig.length==0)	return false;

		var i:int=0;

		hullConfig[0].walked = true;
		var CA:Vector.<HullBlock> = Vector.<HullBlock>([hullConfig[0]]);

		while (CA.length>0)
		{
			var b:HullBlock = CA.shift();
			for (i=Adj.length-1; i>=0; i--)
			{
				var idx:int = hullIdx(b.x+Adj[i].x,b.y+Adj[i].y,b.z+Adj[i].z);
				if (idx!=-1 && !hullConfig[idx].walked)
				{
					hullConfig[idx].walked = true;
					CA.push(hullConfig[idx]);
				}
			}//endfor
		}//endwhile

		var onePiece:Boolean = true;
		for (i=hullConfig.length-1; i>=0; i--)
		{
			if (!hullConfig[i].walked) onePiece=false;
			hullConfig[i].walked=false;
		}//endfor

		return onePiece;
	}//endfunction

	//===============================================================================================
	// to represent this ship config as a string
	//===============================================================================================
	public function toString():String
	{
		var s:String = name+"&";
		for (var i:int=0; i<hullConfig.length; i++)
			s+= Math.round(hullConfig[i].x)+","+Math.round(hullConfig[i].y)+","+Math.round(hullConfig[i].z)+",";

		return s.substr(0,s.length-1);
	}//endfunction
}//endClass

class Asteroid extends Hull
{
	public var slowF:Number = 0.95;						// slow down factor
	public var type:uint = 0;

	private var stepFns:Vector.<Function> = null;

	//===============================================================================================
	//
	//===============================================================================================
	public function Asteroid(name:String=null,asteroidType:uint=0,size:uint=1,texMap:BitmapData=null,specMap:BitmapData=null,normMap:BitmapData=null):void
	{
		// ----- create random asteroid geometry
		super(name,texMap,specMap,normMap);
		type = asteroidType%9;	// total 9 types of asteroids, type used in rebuildAsteroid
		randomHullConfig(size,false);
		rebuildAsteroid();
		integrity = 1;

		// ----- set asteroid texture
		for (var i:int=hullConfig.length-1; i>-1; i--)
			hullConfig[i].integrity = 500+type*50;
		hullSkin.material.setAmbient(0,0,0);
		hullSkin.material.setSpecular(1,1);

		rotPosn = new Vector3D(Math.random()-0.5,Math.random()-0.5,Math.random()-0.5,0);
		rotPosn.scaleBy(Math.random()/rotPosn.length);
		rotPosn.w = Math.sqrt(1-rotPosn.length*rotPosn.length);
		rotVel = new Vector3D(Math.random()-0.5,Math.random()-0.5,Math.random()-0.5,0);
		rotVel.scaleBy(Math.random()*0.005/rotVel.length);
		rotVel.w = Math.sqrt(1-rotVel.length*rotVel.length);

		stepFns = new Vector.<Function>();
	}//endConstr

	//===============================================================================================
	// build asteroid shape with smooth shading, modifies vertex data normals
	//===============================================================================================
	public function rebuildAsteroid():void
	{
		// ----- update chassis skin
		if (hullConfig.length==0)
		{
			radius = 0;
			hullSkin.setGeometry();	// set as empty mesh
			return;
		}

		var uMin:Number = (type%3)/3+0.001;
		var vMin:Number = int(type/3)/3+0.001;
		var uMax:Number = uMin+1/3 - 0.002;
		var vMax:Number = vMin+1/3 - 0.002;
		var pivotShift:Vector3D = pivot;	// old pivot
		pivot = new Vector3D();
		var tmp:Mesh = new Mesh();
		for (var i:int=hullConfig.length-1; i>-1; i--)
		{
			var h:HullBlock = hullConfig[i];
			tmp.addChild(createHullPart(h.x,h.y,h.z,uMin,uMax,vMin,vMax));			// uv to use correct area of texture
			pivot.x+=h.x;
			pivot.y+=h.y;
			pivot.z+=h.z;
		}
		pivot.scaleBy(1/hullConfig.length);		// new pivot
		tmp = tmp.mergeTree();
		radius = tmp.maxXYZ().subtract(tmp.minXYZ()).length/2;

		// ----- calculate smooth shaded normals
		var Norms:Object = new Object();
		var V:Vector.<Number> = tmp.vertData;
		for (i=V.length-11; i>-1; i-=11)
		{
			var id:String = int(V[i+0]*100)+","+int(V[i+1]*100)+","+int(V[i+2]*100);
			if (Norms[id]==null)
				Norms[id] = new Vector3D(V[i+3],V[i+4],V[i+5],1);
			else
			{
					var nv:Vector3D = Norms[id];
					nv.x += V[i+3];
					nv.y += V[i+4];
					nv.z += V[i+5];
					nv.w += 1;
			}
		}//endfor
		for (id in Norms)	Norms[id].normalize();

		// ----- override normals to smooth normals
		var u:Number = (type%3)/3;
		var v:Number = int(type/3)/3;
		var NV:Vector.<Number> = new Vector.<Number>();
		var n:int = V.length/11;
		for (i=0; i<n; i++)
		{
			var ii:int = i*11;
			nv = Norms[int(V[ii+0]*100)+","+int(V[ii+1]*100)+","+int(V[ii+2]*100)];
			NV.push(	V[ii+0] + 0.3*nv.x/nv.w,				// tweak vertices to become more curvy
								V[ii+1] + 0.3*nv.y/nv.w,
								V[ii+2] + 0.3*nv.z/nv.w,
								nv.x,nv.y,nv.z,									// use soft shading normals
								V[ii+9],V[ii+10]);							// UVs
		}//endfor

		// ----- adjust asteroid center shift
		pivotShift = pivot.subtract(pivotShift);
		pivotShift = skin.transform.rotateVector(pivotShift);
		posn = posn.add(pivotShift);

		hullSkin.createGeometry(NV,tmp.idxsData);		// calculates tangent basis

		// ----- re randomize rotation
		rotVel = new Vector3D(Math.random()-0.5,Math.random()-0.5,Math.random()-0.5,0);
		rotVel.scaleBy(Math.random()*0.005/rotVel.length);
		rotVel.w = Math.sqrt(1-rotVel.length*rotVel.length);
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	private function disintegrateFx(localx:int,localy:int,localz:int,callBack:Function=null):void
	{
		var div:int = 5;

		// ----- randomize fragment centers
		var P:Vector.<Vector3D> = new Vector.<Vector3D>();
		for (var i:int=10; i>0; i--)
		{
			var j:int = int(Math.random()*div*div*div);
			P.push(new Vector3D(j%div,int(j/div)%div,int(j/(div*div))));
		}

		// ----- determine fragment shapes
		var Fragments:Vector.<Hull> = new Vector.<Hull>();
		for (i=P.length-1; i>-1; i--)
			Fragments.push(new Hull(name+"_frag"+i,hullSkin.material.texMap,hullSkin.material.specMap,hullSkin.material.normMap));

		for (var x:int=0; x<div; x++)
			for (var y:int=0; y<div; y++)
				for (var z:int=0; z<div; z++)
				{
					var nDsq:Number = Number.MAX_VALUE;
					var nIdx:int = 0;
					for (i=P.length-1; i>-1; i--)
					{
						var p:Vector3D = P[i];
						var dSq:Number = (p.x-x)*(p.x-x)+(p.y-y)*(p.y-y)+(p.z-z)*(p.z-z);
						if (dSq<nDsq)
						{
							nDsq = dSq;
							nIdx = i;
						}
					}//endfor i
					Fragments[nIdx].hullConfig.push(new HullBlock(x,y,z,Fragments[nIdx]));
				}//endfor xyz

		// ----- construct fragments in put in skin
		var uMin:Number = (type%3)/3+0.001;
		var vMin:Number = int(type/3)/3+0.001;
		var uMax:Number = uMin+1/3 - 0.002;
		var vMax:Number = vMin+1/3 - 0.002;
		var con:Mesh = new Mesh;
		var sc:Number = 0.8/div;
		con.transform = con.transform.scale(sc,sc,sc).translate(localx,localy,localz);
		skin.addChild(con);
		for (i=Fragments.length-1; i>-1; i--)
		{
			var frag:Hull = Fragments[i];
			frag.rebuildHull(uMin,uMax,vMin,vMax);
			frag.posn.x = frag.pivot.x-(div-1)*0.5;
			frag.posn.y = frag.pivot.y-(div-1)*0.5;
			frag.posn.z = frag.pivot.z-(div-1)*0.5;
			frag.vel.x = frag.posn.x/5;
			frag.vel.y = frag.posn.y/5;
			frag.vel.z = frag.posn.z/5;
			frag.rotPosn = new Vector3D(0,0,0,1);
			frag.rotVel = new Vector3D(Math.random()-0.5,Math.random()-0.5,Math.random()-0.5,0);
			frag.rotVel.scaleBy(Math.random()*0.1/frag.rotVel.length);
			frag.rotVel.w = Math.sqrt(1-frag.rotVel.length*frag.rotVel.length);
			con.addChild(frag.skin);
		}

		// ----- fragments simulation
		var ttl:int = 90;
		var fn:Function = function():void
		{
			if (ttl<0)
			{
				skin.removeChild(con);
				stepFns.splice(stepFns.indexOf(fn),1);
				if (callBack!=null) callBack();
			}
			else
			{
				var sc:Number = ttl/90;
				for (var i:int=Fragments.length-1; i>-1; i--)
				{
					var frag:Hull = Fragments[i];
					var pv:Vector3D = frag.pivot;
					frag.hullSkin.transform = new Matrix4x4().translate(-pv.x,-pv.y,-pv.z).scale(sc,sc,sc).translate(pv.x,pv.y,pv.z);
					frag.updateStep();
				}
				ttl--;
			}
		};
		fn();
		stepFns.push(fn);
	}//endfunction

	//===============================================================================================
	// update position & orientation of asteroid
	//===============================================================================================
	public override function updateStep():void
	{
		// ----- move astroid with current velocity
		super.updateStep();
		vel.scaleBy(slowF);			// speed slow
		//rotVel.scaleBy(slowF);	// rotation slow
		//rotVel.w = Math.sqrt(1 - rotVel.x*rotVel.x - rotVel.y*rotVel.y - rotVel.z*rotVel.z);

		for (var i:int=stepFns.length-1; i>-1; i--)
			stepFns[i]();
	}//endfunction

	//===============================================================================================
	// records down the damage position and magnitude
	//===============================================================================================
	public override function registerHit(hitPt:VertexData,dmg:Number):void
	{
		var invT:Matrix4x4 = skin.transform.inverse();
		var nvx:Number = hitPt.vx*invT.aa + hitPt.vy*invT.ab + hitPt.vz*invT.ac + invT.ad;
		var nvy:Number = hitPt.vx*invT.ba + hitPt.vy*invT.bb + hitPt.vz*invT.bc + invT.bd;
		var nvz:Number = hitPt.vx*invT.ca + hitPt.vy*invT.cb + hitPt.vz*invT.cc + invT.cd;
		var nh:HullBlock = null;
		var ndSq:Number = Number.MAX_VALUE;
		for (var i:int=hullConfig.length-1; i>-1; i--)
		{
				var h:HullBlock = hullConfig[i];
				if (nh==null || (nvx-h.x)*(nvx-h.x)+(nvy-h.y)*(nvy-h.y)+(nvz-h.z)*(nvz-h.z)<ndSq)
				{
					nh=h;
					ndSq=(nvx-h.x)*(nvx-h.x)+(nvy-h.y)*(nvy-h.y)+(nvz-h.z)*(nvz-h.z);
				}
		}

		// ----- assign damage
		if (nh!=null)
		{
			nh.integrity-=dmg;

			// ----- remove block if destroyed
			if (nh.integrity<=0)
			{
				hullConfig.splice(hullConfig.indexOf(nh),1);
				if (hullConfig.length==0)
					disintegrateFx(nh.x,nh.y,nh.z,function():void {integrity=0;});
				else
					disintegrateFx(nh.x,nh.y,nh.z);
				rebuildAsteroid();
			}
		}
	}//endfunction
}//endClass

class Ship extends Hull
{
	public var modelAssets:Object = null;				// ref to external models assets

	public var modulesConfig:Vector.<Module> = null;	// mounted modules configuration

	public var modulesSkinExt:Mesh = null;
	public var modulesSkin:Mesh = null;

	public var maxIntegrity:Number = 1;
	public var maxEnergy:Number = 1;
	public var energy:Number = 1;

	public var tte:int = 90;										// time to explode

	public var banking:Number = 0;							// current ship roll
	public var accel:Number = 0;								// current acceleration
	public var rotAccel:Vector3D = null;				// current rota acceleration

	public var slowF:Number = 0.9;							// ship slow down factor
	public var maxAccel:Number = 0.001;					// ship acceleration factor
	public var maxRotAccel:Number = 0.001;			// ship rotational acceleration
	public var maxSpeed:Number = maxAccel/(1/slowF-1);	// ship max speed, calculated

	public var engageEnemy:Boolean = true;

	public var targets:Vector.<Hull> = null;		// list of targets for ship
	public var stepFn:Function = null;
	public var damagePosns:Vector.<VertexData> = null;

	private static var RandNames:Vector.<String> =
	new <String>["Androsynth Guardian","Arilou Skiff","Chenjesu Broodhome","Earthling Cruiser","Ilwrath Avenger","Mmrnmhrm X Form","Mycon Podship","Shofixti Scout","Spathi Eluder",
	"Syreen Penetrator","Umgah Drone","Ur-Quan Dreadnought","Kohr-Ah Marauder","VUX Intruder","Chmmr Avatar","Dnyarri Overmind","Druuge Mauler","Melnorme Trader","Orz Nemesis","Pkunk Fury",
	"Slylandro Probe","Supox Blade","Thraddash Torch","Utwig Jugger","Yehat Terminator","Zoq-Fot-Pik Stinger","Taalo Shield"];

	//===============================================================================================
	// constructs a ship entity
	//===============================================================================================
	public function Ship(assets:Object,shpName:String=null,texMap:BitmapData=null,specMap:BitmapData=null,normMap:BitmapData=null):void
	{
		if (shpName==null) shpName = RandNames[Math.floor(Math.random()*RandNames.length)];
		super(shpName,texMap,specMap,normMap);

		modelAssets = assets;
		rotVel = new Vector3D(0,0,0,1);
		rotAccel = new Vector3D(0,0,0,1);

		hullSkin.material.setAmbient(0.3,0.3,0.3);
		hullSkin.material.setSpecular(5,2);
		modulesSkin = new Mesh();
		modulesSkin.material.setSpecular(0.2);
		modulesSkinExt = new Mesh();
		modulesSkinExt.material.setSpecular(0.2);
		skin.addChild(modulesSkinExt);

		hullConfig = new Vector.<HullBlock>();
		modulesConfig = new Vector.<Module>();
		damagePosns = new Vector.<VertexData>();

		// ----- initializes with default hull
		hullConfig.push(new HullBlock(0,1,-1,this));
		hullConfig.push(new HullBlock(0,-1,-1,this));
		hullConfig.push(new HullBlock(0,0,-1,this));
		hullConfig.push(new HullBlock(0,0,0,this));
		hullConfig.push(new HullBlock(0,0,1,this));
		hullConfig.push(new HullBlock(1,0,1,this));
		hullConfig.push(new HullBlock(-1,0,1,this));

		// ----- initializes with default modules
		addModule( 1,0,1,new Vector3D(1,0,0),"gunAutoS");			//
		addModule( 0,0,1,new Vector3D(0,0,1),"gunIonS");			//
		addModule( -1,0,1,new Vector3D(-1,0,0),"gunAutoS");		//

		addModule(0,-1,-1,new Vector3D(0,0,-1),"thrusterS");		// thruster
		addModule(0, 1,-1,new Vector3D(0,0,-1),"thrusterS");		// thruster
		addModule(0, 0,-1,new Vector3D(0,0,-1),"thrusterS");		// thruster

		rebuildShip();				// update hull look from config infos
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	public static function createRandomShip(assets:Object,hullCnt:uint=10,thrustersCnt:uint=4,texMap:BitmapData=null,specMap:BitmapData=null,normMap:BitmapData=null):Ship
	{
		var s:Ship = new Ship(assets,null,texMap,specMap,normMap);
		s.modulesConfig = new Vector.<Module>();
		s.randomHullConfig(hullCnt);
		s.randomThrustersConfig(thrustersCnt);
		s.randomModulesConfig();
		s.rebuildShip();
		return s;
	}//endfunction

	//===============================================================================================
	//
	//===============================================================================================
	public static function createShipFromConfigStr(assets:Object,config:String,texMap:BitmapData=null,specMap:BitmapData=null,normMap:BitmapData=null):Ship
	{
		try {
			var s:Ship = new Ship(assets,null,texMap,specMap,normMap);
			s.setFromConfig(config);
		}
		catch (e:Error)
		{
			s = new Ship(assets);
		}
		return s;
	}//endfunction

	//===============================================================================================
	// records down the damage position and magnitude {(vx,vy,vz):posn (nx,ny,nz):normal w:damage }
	//===============================================================================================
	public override function registerHit(hitPt:VertexData,dmg:Number):void
	{
		integrity -= dmg;	// ship to take damage

		var invT:Matrix4x4 = skin.transform.inverse();
		var nvx:Number = hitPt.vx*invT.aa + hitPt.vy*invT.ab + hitPt.vz*invT.ac + invT.ad;
		var nvy:Number = hitPt.vx*invT.ba + hitPt.vy*invT.bb + hitPt.vz*invT.bc + invT.bd;
		var nvz:Number = hitPt.vx*invT.ca + hitPt.vy*invT.cb + hitPt.vz*invT.cc + invT.cd;
		hitPt.vx = nvx;
		hitPt.vy = nvy;
		hitPt.vz = nvz;
		var nnx:Number = hitPt.nx*invT.aa + hitPt.ny*invT.ab + hitPt.nz*invT.ac;
		var nny:Number = hitPt.nx*invT.ba + hitPt.ny*invT.bb + hitPt.nz*invT.bc;
		var nnz:Number = hitPt.nx*invT.ca + hitPt.ny*invT.cb + hitPt.nz*invT.cc;
		hitPt.nx = nnx;
		hitPt.ny = nny;
		hitPt.nz = nnz;
		hitPt.w = dmg;
		damagePosns.push(hitPt);
	}//endfunction

	//===============================================================================================
	// creates a ship instance from given config string
	//===============================================================================================
	public override function setFromConfig(config:String):void
	{
		var A:Array = config.split("&");
		name = A[0];
		var H:Array = A[1].split(",");
		var M:Array = A[2].split(",");

		// ----- replicate from hullConfig info
		hullConfig = new Vector.<HullBlock>();
		for (var i:int=0; i<H.length; i+=3)
			hullConfig.push(new HullBlock(parseInt(H[i],10),parseInt(H[i+1],10),parseInt(H[i+2],10),this));

		// ----- replicate from modulesConfig info
		modulesConfig = new Vector.<Module>();
		for (i=0; i<M.length; i+=7)
			addModule(parseFloat(M[i]),parseFloat(M[i+1]),parseFloat(M[i+2]),		// position
								new Vector3D(parseFloat(M[i+3]),parseFloat(M[i+4]),parseFloat(M[i+5])),		// orientation
								M[i+6]);		// moduleType
		rebuildShip();
	}//endfunction

	//===============================================================================================
	// re sets ship facing to
	//===============================================================================================
	public function setFacing(bearing:Number):void
	{
		rotPosn = new Vector3D(0,Math.sin(bearing/2),0,Math.cos(bearing/2));
	}

	//===============================================================================================
	// returns ship forward vector
	//===============================================================================================
	public function getFacing():Vector3D
	{
		return new Vector3D(skin.transform.ac,skin.transform.bc,skin.transform.cc);
	}

	//===============================================================================================
	//
	//===============================================================================================
	public function moveTowardsStep(pt:Vector3D):void
	{
		// ----- modify ship heading to travel towards point
		var targF:Vector3D = new Vector3D(pt.x - posn.x,pt.y - posn.y,pt.z - posn.z);
		targF.normalize();
		var curF:Vector3D = new Vector3D(skin.transform.ac,skin.transform.bc,skin.transform.cc);
		var cross:Vector3D = curF.crossProduct(targF);
		cross.normalize();
		var ang:Number = targF.x*curF.x+targF.y*curF.y+targF.z*curF.z;
		if (ang<-1) ang=-1;
		if (ang>1)	ang= 1;
		ang = Math.acos(ang);
		if (ang>maxRotAccel) ang=maxRotAccel;
		var sinA2:Number = Math.sin(ang/2);
		rotAccel = new Vector3D(sinA2*cross.x,sinA2*cross.y,sinA2*cross.z,Math.cos(ang/2));
		rotVel = Matrix4x4.quatMult(rotAccel,rotVel);

		var thrustTresh:Number = Math.PI*0.5;
		if (ang<thrustTresh)
		{
			accel = (thrustTresh-ang)/thrustTresh * maxAccel;
			vel.x += curF.x*accel;	// increment vel
			vel.y += curF.y*accel;
			vel.z += curF.z*accel;
		}
	}//endfunction

	//===============================================================================================
	// update orientate ship hull according to facing, position
	//===============================================================================================
	public override function updateStep():void
	{
		// ----- increment energy
		energy += hullConfig.length;
		if (energy>maxEnergy) energy = maxEnergy;

		// ----- calculate ship banking
		banking *= 1-(1-slowF)*(1-slowF);
		banking += -rotVel.y;

		// ----- move ship with current velocity and rotation
		posn.x += vel.x;
		posn.y += vel.y;
		posn.z += vel.z;
		rotPosn = Matrix4x4.quatMult(rotVel,rotPosn);		// update rotation

		// ----- update transform
		skin.transform = Matrix4x4.quaternionToMatrix(rotPosn.w,rotPosn.x,rotPosn.y,rotPosn.z).mult(new Matrix4x4().translate(-pivot.x,-pivot.y,-pivot.z).rotZ(banking)).translate(posn.x,posn.y,posn.z);
		updateHullBlocksWorldPosns();	// calculate global positions for each hull space
		vel.scaleBy(slowF);						// speed slow
		rotVel.scaleBy(slowF);				// rotation slow

		// ----- update ship transform
		updateHullBlocksWorldPosns();	// calculate global positions for each hull space
	}//endfunction

	//===============================================================================================
	// adds module at given position at specified orientation
	//===============================================================================================
	public function addModule(px:Number,py:Number,pz:Number,orient:Vector3D,type:String) : Boolean
	{
		var i:int=0;
		var size:uint=1;
		if (type.charAt(type.length-1)=='M')
			size=2;

		// ----- chk if enough available hull blocks to contain module
		var blocks:Vector.<HullBlock> = freeHullBlocks(px,py,pz,size);
		if (blocks.length!=size*size*size)	return false;

		// ----- chk enough surface area
		var surf:Vector.<Vector3D> = surfaceToOccupy(px,py,pz,orient,size);
		for (i=surf.length-1; i>=0; i--)
			if (hullIdx(surf[i].x,surf[i].y,surf[i].z)!=-1)
				return false;

		var meanPt:Vector3D = new Vector3D(0,0,0);
		for (i=blocks.length-1; i>=0; i--)
		{
			var blk:HullBlock = blocks[i];
			meanPt.x+=blk.x;
			meanPt.y+=blk.y;
			meanPt.z+=blk.z;
		}
		meanPt.x/=blocks.length;
		meanPt.y/=blocks.length;
		meanPt.z/=blocks.length;

		var mod:Module = new Module(meanPt.x,meanPt.y,meanPt.z,orient.x, orient.y,orient.z,type);

		// ----- register blocks as taken up by this module
		for (i=blocks.length-1; i>=0; i--)		blocks[i].module=mod;

		modulesConfig.push(mod);	// register module

		return true;
	}//endfunction

	//===============================================================================================
	// removes specified module
	//===============================================================================================
	public function removeModule(m:Module) : void
	{
		var i:int=0;
		for (i=hullConfig.length-1; i>-1; i--)
			if (hullConfig[i].module==m)
				hullConfig[i].module=null;
		if (modulesConfig.indexOf(m)!=-1)
			modulesConfig.splice(modulesConfig.indexOf(m),1);
	}//endfunction

	//===============================================================================================
	// random place lv 1 modules... fills up rest of available slots
	//===============================================================================================
	public function randomModulesConfig(symmetry:Boolean=true) : void
	{
		var D:Vector.<Vector3D> = new <Vector3D>[new Vector3D(0,1,0), 	// top
												new Vector3D(0,-1,0), 	// bottom
												new Vector3D(-1,0,0), 	// left
												new Vector3D(1,0,0),	// right
												new Vector3D(0,0,1),	// front
												new Vector3D(0,0,-1)]; 	// back
		var left:Vector3D = D[2];
		var right:Vector3D = D[3];

		// ----- auto get gun module ids
		var ModIds:Vector.<String> = new Vector.<String>();
		for (var id:String in modelAssets)
			if (id.charAt(id.length-1)=='S' && (id.substr(0,3)=="gun" || id.substr(0,8)=="launcher"))
				ModIds.push(id);

		for (var i:int=hullConfig.length-1; i>=0; i--)
		{
			var hull:HullBlock = hullConfig[i];
			if (hull.module==null)
			{
				// ----- generate random seq array
				var R:Vector.<uint> = new Vector.<uint>();
				for (var j:int=0; j<6; j++)	R.splice(int(Math.random()*(R.length+1)),0,j);
				if (symmetry && hull.x==0)		// if middle block
				{
					R.splice(R.indexOf(2),1);
					R.splice(R.indexOf(3),1);
				}

				while (hull.module==null && R.length>0)
				{	// add module at x,y,z, dir, type, size
					var modType:String = ModIds[int(Math.random()*ModIds.length)];
					var dir:Vector3D = D[R.shift()];
					addModule(hull.x,hull.y,hull.z,dir,modType);
					if (symmetry && hull.x!=0)
					{
						var hidx:int=hullIdx(-hull.x,hull.y,hull.z);
						if (hidx!=-1 && hullConfig[hidx].module==null)
						{
							if (dir==left)			dir=right;
							else if (dir==right)	dir=left;
							addModule(-hull.x,hull.y,hull.z,dir,modType);
						}
					}
				}//endwhile
			}//endif
		}//endfor
	}//endfunction

	//===============================================================================================
	// random place thrusters
	//===============================================================================================
	public function randomThrustersConfig(n:uint=4,symmetry:Boolean=true) : void
	{
		var R:Vector.<uint> = new Vector.<uint>();
		for (var j:int=0; j<hullConfig.length; j++)	R.splice(int(Math.random()*(R.length+1)),0,j);

		var back:Vector3D = new Vector3D(0, 0, -1);

		var cnt:uint=0;
		while (R.length>0 && cnt<n)
		{
			var hull:HullBlock = hullConfig[R.shift()];
			if (hull.module==null && addModule(hull.x,hull.y,hull.z,back,"thrusterS"))
				cnt++;

			if (symmetry)
			{
				var hidx:int=hullIdx(-hull.x,hull.y,hull.z);
				if (hidx!=-1 && hullConfig[hidx].module==null  && addModule(-hull.x,hull.y,hull.z,back,"thrusterS"))
				cnt++;
			}
		}//endfor
	}//endfunction

	//===============================================================================================
	// creates the chassis mesh geometry from hullConfig info
	//===============================================================================================
	public function rebuildShip() : void
	{
		if (modelAssets==null) return;

		// ----- update chassis skin
		rebuildHull();

		maxIntegrity = hullConfig.length*200;
		integrity = hullConfig.length*200;
		maxEnergy = hullConfig.length*100;
		energy = hullConfig.length*100;

		// ----- update chassis mounts
		var thrustCnt:int = 0;
		var rotMoment:Number = 0;
		var tmp:Mesh = new Mesh();
		var tmpExt:Mesh = new Mesh();
		for (var i:int=modulesConfig.length-1; i>=0; i--)
		{
			var m:Module = modulesConfig[i];
			var mt:Mesh = null;
			var mtExt:Mesh = null;
			if (m.type.indexOf("thruster")!=-1)	// thruster
			{
				mt = modelAssets["thrusterS"].clone();
				mtExt = modelAssets["thrusterSExt"].clone();
				thrustCnt++;
				rotMoment += Math.sqrt((m.x-pivot.x)*(m.x-pivot.x) + (m.y-pivot.y)*(m.y-pivot.y) + (m.z-pivot.z)*(m.z-pivot.z));
			}
			else if (m.type.indexOf("launcherS")!=-1)	// missile luncher
			{
				mt = modelAssets["launcherS"].clone();
				mtExt = modelAssets["launcherSExt"].clone();
			}
			else if (m.type.charAt(m.type.length-1)=='S')		// small gun
			{
				mt = modelAssets['mountS'].clone();
				mtExt = modelAssets['mountSExt'].clone();
			}
			else if (m.type.charAt(m.type.length-1)=='M')		// medium gun
			{
				mt = modelAssets['mountM'].clone();
				mtExt = modelAssets['mountMExt'].clone();
			}
			mt.transform = new Matrix4x4().rotFromTo(0, 1, 0, m.nx, m.ny, m.nz).translate(m.x, m.y, m.z);
			mtExt.transform = new Matrix4x4().rotFromTo(0, 1, 0, m.nx, m.ny, m.nz).translate(m.x, m.y, m.z);
			tmp.addChild(mt);
			tmpExt.addChild(mtExt);
		}

		maxRotAccel = thrustCnt/rotMoment*0.001;
		maxAccel = thrustCnt/hullConfig.length*0.015;
		maxSpeed = maxAccel/(1/slowF-1);

		tmp = tmp.mergeTree();
		tmpExt = tmpExt.mergeTree();
		modulesSkin.setGeometry(tmp.vertData, tmp.idxsData);
		modulesSkinExt.setGeometry(tmpExt.vertData, tmpExt.idxsData);
	}//endfunction

	//===============================================================================================
	// returns the free hullBlocks to be occupied by module of given size
	//===============================================================================================
	public function freeHullBlocks(px:Number,py:Number,pz:Number,size:uint=1) : Vector.<HullBlock>
	{
		var HB:Vector.<HullBlock> = getHullBlocks(px,py,pz,size);
		for (var i:int=HB.length-1; i>-1; i--)
			if (HB[i].module!=null)
				HB.splice(i,1);
		return HB;
	}//endfunction

	//===============================================================================================
	// surface area required to house module of given size
	//===============================================================================================
	public function surfaceToOccupy(px:Number,py:Number,pz:Number,orient:Vector3D,size:uint=1) : Vector.<Vector3D>
	{
		var x:int=0;
		var y:int=0;
		var z:int=0;
		var off:Number = (size-1)/2;
		var V:Vector.<Vector3D> = new Vector.<Vector3D>();
		if (Math.abs(orient.x)==1)
		{
			for (y=0; y<size; y++)
				for (z=0; z<size; z++)
					V.push(new Vector3D(Math.round(px+off*orient.x+orient.x),Math.round(py+y-off),Math.round(pz+z-off)));
		}
		else if (Math.abs(orient.y)==1)
		{
			for (x=0; x<size; x++)
				for (z=0; z<size; z++)
					V.push(new Vector3D(Math.round(px+x-off),Math.round(py+off*orient.y+orient.y),Math.round(pz+z-off)));
		}
		else if (Math.abs(orient.z)==1)
		{
			for (x=0; x<size; x++)
				for (y=0; y<size; y++)
					V.push(new Vector3D(Math.round(px+x-off),Math.round(py+y-off),Math.round(pz+off*orient.z+orient.z)));
		}

		return V;
	}//endfunction

	//===============================================================================================
	// to represent this ship config as a string
	//===============================================================================================
	public override function toString():String
	{
		var s:String = super.toString()+"&";
		for (var i:int=0; i<modulesConfig.length; i++)
			s+=modulesConfig[i].toString()+",";
		if (modulesConfig.length>0)
			s = s.substr(0,s.length-1);
		return s;
	}//endfunction
}//endClass

class Projectile	// data class
{
	public var px:Number = 0;	// position
	public var py:Number = 0;
	public var pz:Number = 0;
	public var vx:Number = 0;	// velocity
	public var vy:Number = 0;
	public var vz:Number = 0;
	public var tx:Number = 0;	// temp vars
	public var ty:Number = 0;
	public var tz:Number = 0;
	public var ttl:Number = 120;
	public var integrity:Number = 1;
	public var projIntegrity:Number = 1;	// to prevent double targeting
	public var maxIntegrity:Number = 1;
	public var targ:Object = null;
	public var renderFn:Function = null;
	public var type:String = null;
	public var onDestroy:Function =null;

	public function Projectile(px:Number,py:Number,pz:Number,vx:Number,vy:Number,vz:Number,targ:Object=null,renderFn:Function=null,dmg:Number=1,ttl:Number=120,type:String=null):void
	{
		this.px = px;
		this.py = py;
		this.pz = pz;
		this.vx = vx;
		this.vy = vy;
		this.vz = vz;
		this.renderFn = renderFn;
		this.integrity = dmg;
		this.projIntegrity = dmg;
		this.maxIntegrity = dmg;
		this.ttl = ttl;
		this.targ = targ;
		this.type = type;
	}//endfunction
}//endclass

class DropItem extends Projectile
{
	public var accel:Number = 0.05;
	public var damp:Number = 0.97;

	public function DropItem(px:Number,py:Number,pz:Number,vx:Number,vy:Number,vz:Number,renderFn:Function=null,dmg:Number=1,ttl:Number=120,type:String=null):void
	{
		super(px,py,pz,vx,vy,vz,null,renderFn,dmg,ttl*1.2,type);
	}//endfunction

	public function tractorTo(iV:Vector3D):Boolean
	{
		// ----- remove perpenticular component and add accel towards point
		if (iV.w<1)
		{
			return true;
		}
		else
		{
			vx = -iV.x;
			vy = -iV.y;
			vz = -iV.z;
			return false;
	 	}
	}//endfunction

	public function tractorIn(tpx:Number,tpy:Number,tpz:Number,shp:Ship):Boolean
	{
		var dx:Number = tpx-px;
		var dy:Number = tpy-py;
		var dz:Number = tpz-pz;
		var dl:Number = Math.sqrt(dx*dx+dy*dy+dz*dz);
		dx/=dl;
		dy/=dl;
		dz/=dl;
		var dp:Number = dx*vx+dy*vy+dz*vz;
		if (dp*5>=dl)
		{
			px = tpx;
			py = tpy;
			pz = tpz;
			return true;
		}
		else
		{
			// ----- remove perpenticular component and add accel towards point
			vx = dx*dp + dx*accel + shp.vel.x;	// tweak to make it travel in vel of ship
			vy = dy*dp + dy*accel + shp.vel.y;
			vz = dz*dp + dz*accel + shp.vel.z;
			return false;
	 	}
	}//endfunction
}//endclass

class Missile extends Projectile
{
	var accel:Number = 0.025;
	var damp:Number = 0.9;
	var turnRate:Number = 0.3;

	public function Missile(px:Number,py:Number,pz:Number,vx:Number,vy:Number,vz:Number,targ:Object=null,renderFn:Function=null,dmg:Number=1,ttl:Number=120,type:String=null):void
	{
		super(px,py,pz,vx,vy,vz,targ,renderFn,dmg,ttl*1.2,type);
		//s = s*damp + a
		//damp = (speed-accel)/speed;
	}//endfunction

	public function homeInStep():void
	{
		if (!(targ is HullBlock) || targ.extPosn==null) return;
		var speed:Number = Math.sqrt(vx*vx+vy*vy+vz*vz);
		var dpx:Number = targ.extPosn.x-px;
		var dpy:Number = targ.extPosn.y-py;
		var dpz:Number = targ.extPosn.z-pz;
		var hull:Hull = targ.parent;
		var cv:Vector3D = SpaceCrafter.collisionVector3(speed,dpx,dpy,dpz,hull.vel.x,hull.vel.y,hull.vel.z);
		if (cv!=null)
		{
			// ----- determine rotation of missile
			var ang:Number = (cv.x*vx+cv.y*vy+cv.z*vz)/(speed*speed);
			if (ang<-1) ang=-1;
			if (ang>1)	ang=1;
			ang = Math.acos(ang);	// turn angle in radians
			if (ang>turnRate)		ang = turnRate;
			var axis:Vector3D = new Vector3D(vx,vy,vz).crossProduct(cv);
			if (axis.length>0)
			{
				// ----- apply rotation
				var rM:Matrix4x4 = new Matrix4x4().rotAbout(axis.x,axis.y,axis.z,ang);
				var nvx:Number = rM.aa*vx + rM.ab*vy + rM.ac*vz;
				var nvy:Number = rM.ba*vx + rM.bb*vy + rM.bc*vz;
				var nvz:Number = rM.ca*vx + rM.cb*vy + rM.cc*vz;
				var nvl:Number = Math.sqrt(nvx*nvx+nvy*nvy+nvz*nvz);
				vx = vx*damp + nvx/nvl*accel;
				vy = vy*damp + nvy/nvl*accel;
				vz = vz*damp + nvz/nvl*accel;
			}
		}
	}//endfunction
}//endclass
