package core3D
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;

	/**
	* Author: Lin Minjiang
	* Creates an emitter to emit copies of meshes specified by given mesh
	* Supports up to 60 copies of given mesh in a single mesh
	* Primarily to support massive numbers of projectiles on stage
	*/
	public class MeshParticles
	{
		public var skin:Mesh;

		public var numLiveParticles:uint=0;		// number of live meshes to render

		public var MData:Vector.<VertexData>;	// position, orientation, and scaling and of each mesh

		private var MDataBytes:ByteArray=null;
		private var particlesPerMesh:uint=60;	// total number of particles per batch render
		private var trisPerParticle:uint=0;
		private var particleMesh:Mesh = null;

		/**
		* creates a 60 batch rendered mesh group
		*/
		public function MeshParticles(m:Mesh) : void
		{
			particleMesh = new Mesh();
			particleMesh.addChild(m);				// adding as child so that transform is applied during merge
			particleMesh = particleMesh.mergeTree();

			if (particleMesh.vertData==null || particleMesh.idxsData==null)
			{
				Mesh.debugTrace("MeshParticles Error! empty mesh given!");
				particleMesh = Mesh.createTetra();
			}

			skin = new Mesh();
			skin.material = m.material.clone();			// copy texture/lighting info
			MData = new Vector.<VertexData>();
			MDataBytes = new ByteArray();
			MDataBytes.endian = "littleEndian";
		}//endConstructor

		/**
		* generates mesh for particles rendering
		*/
		private function createNewRenderMesh():Mesh
		{
			var oV:Vector.<Number> = particleMesh.vertData;	// vertices, normals and UV data [vx,vy,vz,nx,ny,nz,tx,ty,tz,u,v, ...] can be null
			var oI:Vector.<uint> = particleMesh.idxsData;		// indices to vertices forming triangles [a1,a2,a3, b1,b2,b3, ...]

			// ----- set as 0 drawn by default
			numLiveParticles = 0;
			trisPerParticle = oI.length/3;

			var maxPerMesh:int=60;
			if (Mesh.context3d.profile.indexOf("standard")!=-1)
				maxPerMesh=120;

			particlesPerMesh = Math.min(maxPerMesh,65535/(oV.length/11));
			if (particlesPerMesh<maxPerMesh)	Mesh.debugTrace("MeshParticles rendered per batch:"+particlesPerMesh+"\n");

			var V:Vector.<Number> = new Vector.<Number>();
			var I:Vector.<uint> = new Vector.<uint>();
			var cOff:uint=5;		// constants offset, vc5 onwards unused
			var iOff:uint=0;		// triangles indices offset
			for (var i:int=0; i<particlesPerMesh; i++)	// create 60 duplicate meshes
			{
				var j:uint=0;
				var n:uint=oV.length;
				while (j<n)			// append to main V
				{
					V.push(	oV[j+0],oV[j+1],oV[j+2],	// vx,vy,vz
							oV[j+3],oV[j+4],oV[j+5],	// nx,ny,nz
							oV[j+6],oV[j+7],oV[j+8],	// tx,ty,tz
							oV[j+9],oV[j+10],			// texU,texV,
							cOff+i*2,cOff+i*2+1);		// idx,idx+1 for orientation and positioning
					j+=11;
				}

				j=0;
				n=oI.length;
				while (j<n)	{I.push(oI[j]+iOff); j++;}	// append to main I
				iOff+=oV.length/11;
			}

			// ----- create skin mesh for this emitter --------------
			var m:Mesh = new Mesh();
			m.material = skin.material;
			m.depthWrite = skin.depthWrite;
			m.setMeshes(V,I);
			return m;
		}//endfunction

		/**
		* sets the location, direction and scaling of next mesh derived from given transform matrix
		*/
		public function nextLocRotScale(trans:Matrix4x4,sc:Number=1) : void
		{
			if (MData.length==numLiveParticles)
				MData.push(new VertexData());
			var md:VertexData = MData[numLiveParticles];	// the mesh particle data to alter
			numLiveParticles++;

			md.w = sc;						// set scale
			var quat:Vector3D = trans.rotationQuaternion();
			md.nx=quat.x;					// set quaternion
			md.ny=quat.y;
			md.nz=quat.z;
			md.vx=trans.ad;					// set location
			md.vy=trans.bd;
			md.vz=trans.cd;
		}//endfunction

		/**
		* set the Loc Rot Scale directly for next mesh
		*/
		public function nextLocDirScale(px:Number,py:Number,pz:Number,	// position
										dx:Number,dy:Number,dz:Number,	// direction
										sc:Number=1) : void				// scale
		{
			if (MData.length==numLiveParticles)
				MData.push(new VertexData());
			var md:VertexData = MData[numLiveParticles];	// the mesh particle data to alter
			numLiveParticles++;

			var dl:Number = dx*dx+dy*dy+dz*dz;
			if (dl>0)
			{
				dl = Math.sqrt(dl);
				dx/=dl; dy/=dl; dz/=dl;	// normalized direction vector
				var ax:Number =-dy;
				var ay:Number = dx;
				var al:Number = Math.sqrt(ax*ax+ay*ay);
				if (al<0.000001)
				{
					md.nx=0; 				// quaternion qx
					md.ny=0;				// quaternion qy
					md.nz=0;				// quaternion qz
				}
				else
				{
					ax/=al; ay/=al;			// rotation axis normalized
					var sinA_2:Number = Math.sqrt((1-dz)/2);	// double angle formula, cosA=dz
					md.nx=ax*sinA_2; 		// quaternion qx
					md.ny=ay*sinA_2;		// quaternion qy
					md.nz=0;				// quaternion qz
				}
			}
			else
			{md.nx=0; md.ny=0; md.nz=1;}

			md.vx = px;
			md.vy = py;
			md.vz = pz;
			md.w = sc;
		}//endfunction

		/**
		* sets the scale of all the meshes to 0
		*/
		public function reset() : void
		{
			numLiveParticles=0;
		}//endfunction

		/**
		* updates the meshes positions, send data to renderer
		*/
		public function update() : int
		{
			if (Mesh.context3d==null) return 0;

			// ----- write particles positions data -----------------
			var T:ByteArray = MDataBytes;
			T.position = 0;
			var baOffset:int = 0;
			var mcnt:int = 0;
			var pcnt:int = 0;
			var rmesh:Mesh = null;

			for (var i:int=numLiveParticles-1; i>-1; i--)
			{
				var m:VertexData = MData[i];
				T.writeFloat(m.nx);	// quaternion x
				T.writeFloat(m.ny);	// quaternion y
				T.writeFloat(m.nz);	// quaternion z
				T.writeFloat(m.w);	// scale
				T.writeFloat(m.vx);	// translation x
				T.writeFloat(m.vy);	// translation y
				T.writeFloat(m.vz);	// translation z
				T.writeFloat(0);
				pcnt++;

				if (pcnt>=particlesPerMesh || i==0)
				{
					if (skin.numChildren()<=mcnt)
						skin.addChild(createNewRenderMesh());
					rmesh = skin.getChildAt(mcnt);
					rmesh.trisCnt = trisPerParticle*pcnt;
					rmesh.vcData = T;		// send particle transforms to mesh for GPU transformation
					rmesh.vcDataNumReg = pcnt*2;
					rmesh.vcDataOffset = baOffset;

					baOffset += pcnt*2*16;
					mcnt++;
					pcnt=0;
				}//endif
			}//endfor

			// ----- disable rest of unused render meshes
			for (i=skin.numChildren()-1; i>=mcnt; i--)
			{
				rmesh = skin.getChildAt(i)
				rmesh.vcData = null;
				rmesh.trisCnt = 0;
				rmesh.vcDataNumReg = 0;
				rmesh.vcDataOffset = 0;
			}

			return numLiveParticles;
		}//endfuntcion
	}//endclass
}//endpackage
