"""Original Blue Leader study. Blender 5.2 --background --python this_file.

Metres; Z up, -Y forward. Only the existing verified CC0 armature/actions are
reused. All visible geometry is authored here. No third-party add-ons.
"""
import bpy, bmesh, math, json, hashlib, sys
from pathlib import Path
from mathutils import Vector
from math import sin, cos, pi, exp, sqrt

SRC = Path(__file__).resolve().parent
ROOT = SRC.parents[1]
OUT = ROOT / 'assets/blue_leader_study'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.import_scene.gltf(filepath=str(ROOT/'assets/third_party/quaternius/modular_men/Spacesuit.gltf'))
rig = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
for o in list(bpy.data.objects):
    if o != rig: bpy.data.objects.remove(o, do_unlink=True)
rig.name = 'BlueLeaderRig'
rig.data.pose_position = 'REST'
scene = bpy.context.scene
scene.render.engine = 'CYCLES'; scene.cycles.samples = 4
scene.render.fps = 24
groups = {}

def clamp(x,a=0,b=1): return max(a,min(b,x))
def lerp(a,b,t): return a+(b-a)*t
def gauss(x,c,w): return exp(-((x-c)/w)**2)

def body_weights(v):
    z=v.z
    joints=[(.93,'Hips'),(1.08,'Abdomen'),(1.25,'Torso'),(1.42,'Chest'),(1.53,'Neck'),(1.62,'Head')]
    if z<=joints[0][0]: return {'Hips':1}
    for (lo,a),(hi,b) in zip(joints,joints[1:]):
        if z<hi:
            t=(z-lo)/(hi-lo); return {a:1-t,b:t}
    return {'Head':1}

def bind(obj, weights):
    if isinstance(weights,str): weights=lambda v,b=weights:{b:1}
    for v in obj.data.vertices:
        wd=weights(obj.matrix_world@v.co)
        for name,w in wd.items():
            if w>0.00001:
                group=obj.vertex_groups.get(name) or obj.vertex_groups.new(name=name)
                group.add([v.index],w,'REPLACE')
    mod=obj.modifiers.new('Shared 62 bone deformation','ARMATURE'); mod.object=rig
    obj.parent=rig

def finish(obj,name,mat,weights,smooth=True,uv=None):
    obj.name=name
    if uv is not None:
        layer=obj.data.uv_layers.new(name='SourceUV')
        for p in obj.data.polygons:
            for li in p.loop_indices: layer.data[li].uv=uv[obj.data.loops[li].vertex_index]
    elif not obj.data.uv_layers:
        bpy.context.view_layer.objects.active=obj; obj.select_set(True)
        bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
        bpy.ops.uv.smart_project(island_margin=.02); bpy.ops.object.mode_set(mode='OBJECT')
        obj.select_set(False)
    obj.data.uv_layers[0].name='SourceUV'
    if mat=='face':
        # Landmark-calibrated projection from the generated neutral facial source.
        # Sculpt geometry supplies all silhouette, nose, lip and orbital depth.
        anchors=[(1.577,1144),(1.60,1090),(1.643,929),(1.65,901),(1.679,810),(1.688,768),(1.731,556),(1.755,474),(1.78,360),(1.81,230),(1.862,60)]
        def face_uv(co):
            y=anchors[-1][1]
            for a,b in zip(anchors,anchors[1:]):
                if co.z<=b[0]: y=lerp(a[1],b[1],clamp((co.z-a[0])/(b[0]-a[0])));break
            return (.5+co.x*2.95,1-y/1254)
        layer=obj.data.uv_layers[0]
        for li,loop in enumerate(obj.data.loops): layer.data[li].uv=face_uv(obj.data.vertices[loop.vertex_index].co)
        mask=obj.data.attributes.new('FaceProjection','FLOAT','POINT')
        for v in obj.data.vertices:
            lateral=clamp((abs(v.co.x)-.075)/.022)
            lateral=lateral*lateral*(3-2*lateral)
            mask.data[v.index].value=clamp((-v.co.y-.005)/.065)*(1-lateral)
    for p in obj.data.polygons: p.use_smooth=smooth
    bind(obj,weights); groups.setdefault(mat,[]).append(obj)
    return obj

def mesh(name,verts,faces,mat,weights,uv=None,smooth=True):
    data=bpy.data.meshes.new(name); data.from_pydata(verts,[],faces); data.update()
    obj=bpy.data.objects.new(name,data); scene.collection.objects.link(obj)
    bm=bmesh.new(); bm.from_mesh(data); bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(data); bm.free()
    return finish(obj,name,mat,weights,smooth,uv)

def ellipsoid(name,center,scale,mat,weights,seg=32,rings=20):
    bpy.ops.object.select_all(action='DESELECT')
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg,ring_count=rings,location=center)
    obj=bpy.context.object; obj.scale=scale
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True); obj.select_set(False)
    return finish(obj,name,mat,weights)

def loft(name,rows,mat,weights,n=40,cap=True):
    # rows = (centre, radius across X, radius along Y), continuous shaped sections.
    vs=[];uv=[];fs=[]
    for j,(center,rx,ry) in enumerate(rows):
        for i in range(n+1):
            a=2*pi*i/n; vs.append((center[0]+rx*sin(a),center[1]-ry*cos(a),center[2])); uv.append((i/n,j/(len(rows)-1)))
    for j in range(len(rows)-1):
        for i in range(n):
            a=j*(n+1)+i; fs.append((a,a+1,a+n+2,a+n+1))
    if cap: fs.extend([tuple(range(n-1,-1,-1)),tuple((len(rows)-1)*(n+1)+i for i in range(n))])
    return mesh(name,vs,fs,mat,weights,uv)

def tube(name,path,radii,mat,weights,n=12):
    vs=[];uv=[];fs=[]
    for j,p in enumerate(path):
        p=Vector(p); tangent=Vector(path[min(j+1,len(path)-1)])-Vector(path[max(0,j-1)])
        tangent.normalize(); axis=Vector((0,1,0))
        if abs(tangent.dot(axis))>.94: axis=Vector((1,0,0))
        u=tangent.cross(axis).normalized(); v=tangent.cross(u).normalized()
        r=radii[j] if isinstance(radii,list) else radii
        if not isinstance(r,tuple): r=(r,r)
        for i in range(n+1):
            a=2*pi*i/n; vs.append(tuple(p+u*cos(a)*r[0]+v*sin(a)*r[1])); uv.append((i/n,j/(len(path)-1)))
    for j in range(len(path)-1):
        for i in range(n):
            a=j*(n+1)+i;fs.append((a,a+1,a+n+2,a+n+1))
    fs.extend([tuple(range(n-1,-1,-1)),tuple((len(path)-1)*(n+1)+i for i in range(n))])
    return mesh(name,vs,fs,mat,weights,uv)

def bezier(a,b,c,d,n=24):
    return [tuple((1-t)**3*Vector(a)+3*(1-t)**2*t*Vector(b)+3*(1-t)*t*t*Vector(c)+t**3*Vector(d)) for t in [i/n for i in range(n+1)]]

def box(name,center,size,mat,weights,bevel=.01):
    bpy.ops.object.select_all(action='DESELECT'); bpy.ops.mesh.primitive_cube_add(size=1,location=center)
    obj=bpy.context.object; obj.scale=size; bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    mod=obj.modifiers.new('Machined edge','BEVEL');mod.width=bevel;mod.segments=3;bpy.ops.object.modifier_apply(modifier=mod.name)
    mod=obj.modifiers.new('Face normals','WEIGHTED_NORMAL');bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.select_set(False);return finish(obj,name,mat,weights)

def plate(name,outline,depth,mat,weights,bevel=.006):
    # Authored curved outline in 3D; inset central crown makes an actual plate.
    center=sum((Vector(p) for p in outline),Vector())/len(outline)
    n=len(outline);vs=[];fs=[]
    for s in [.02,.30,.62,.86,1.0]:
        for p in outline:
            v=center.lerp(Vector(p),s);v.y-=depth*(1-s*s);vs.append(tuple(v))
    for j in range(4):
        for i in range(n):
            a=j*n+i;b=j*n+(i+1)%n;fs.append((a,b,b+n,a+n))
    fs.append(tuple(reversed(range(n))))
    vs += [(x,y+.012,z) for x,y,z in outline]
    fs += [(4*n+i,5*n+i,5*n+(i+1)%n,4*n+(i+1)%n) for i in range(n)]
    fs.append(tuple(5*n+i for i in range(n)))
    return mesh(name,vs,fs,mat,weights,smooth=True)

# Tailored underlayer: pelvic breadth, defined waist, ribcage and clavicle line.
loft('Tailored padded torso',[( (0,-.035,z),rx,ry) for z,rx,ry in [(.88,.135,.095),(.96,.163,.104),(1.02,.15,.091),(1.10,.119,.079),(1.18,.132,.092),(1.27,.164,.109),(1.35,.174,.105),(1.42,.163,.083),(1.47,.09,.065)]],'leather',body_weights)
loft('Neck with trapezius transition',[((0,-.035,z),rx,ry) for z,rx,ry in [(1.43,.087,.069),(1.49,.053,.049),(1.56,.047,.047),(1.62,.057,.057)]],'skin',body_weights)

# Wraparound segmented cuirass. Its contours follow the ribs and waist rather
# than separate breast cups; shoulders and elbows remain free to articulate.
for side in (-1,1):
    def mir(points): return [(side*x,y,z) for x,y,z in points]
    plate('Shaped protective half cuirass',mir([(.008,-.154,1.16),(.105,-.135,1.15),(.157,-.109,1.24),(.172,-.103,1.36),(.115,-.123,1.435),(.015,-.143,1.40)]),.022,'blue',body_weights)
    tube('Cuirass bronze welt',mir([(.01,-.161,1.17),(.105,-.142,1.16),(.158,-.116,1.24),(.173,-.11,1.36),(.114,-.13,1.433)]),.004,'bronze',body_weights)
    for j in range(3):
        z=1.04+j*.043
        plate('Overlapping abdominal lame',mir([(.006,-.126,z),(.112,-.103,z+.008),(.128,-.11,z+.049),(.008,-.142,z+.045)]),.008,'blue',body_weights)
    # Shaped back plates and collar opening.
    plate('Scapula back plate',mir([(.01,.08,1.18),(.13,.064,1.20),(.163,.057,1.37),(.083,.065,1.445),(.008,.073,1.41)]),-.012,'blue',body_weights)

# Legs, fitted articulated boots and protective knee/shin shells.
for side,suffix in [(-1,'R'),(1,'L')]:
    x=side*.1206; up='UpperLeg.'+suffix; low='LowerLeg.'+suffix; foot='Foot.'+suffix
    def legw(v,up=up,low=low):
        t=clamp((v.z-.48)/.12);return {up:t,low:1-t}
    loft('Tailored trouser '+suffix,[((x,y,z),rx,ry) for z,rx,ry,y in [(.50,.063,.065,-.081),(.56,.067,.070,-.078),(.65,.076,.085,-.061),(.76,.090,.094,-.042),(.88,.103,.100,-.030),(.96,.092,.092,-.030)]],'cloth',legw)
    loft('Calf boot '+suffix,[((x,y,z),rx,ry) for z,rx,ry,y in [(.09,.054,.061,-.063),(.16,.058,.065,-.06),(.29,.069,.075,-.067),(.40,.075,.075,-.074),(.49,.065,.064,-.08)]],'leather',low)
    loft('Sculpted boot foot '+suffix,[((x,y,z),rx,ry) for z,rx,ry,y in [(.025,.071,.153,-.133),(.055,.073,.157,-.133),(.095,.070,.139,-.13),(.132,.052,.077,-.08)]],'leather',foot)
    loft('Layered boot sole '+suffix,[((x,-.133,z),rx,ry) for z,rx,ry in [(.012,.074,.156),(.032,.076,.158),(.046,.074,.155)]],'rubber',foot)
    outline=[(x-.052,-.135,.17),(x+.05,-.135,.17),(x+.064,-.141,.38),(x+.034,-.158,.46),(x-.035,-.158,.46),(x-.065,-.141,.38)]
    plate('Tapered shin guard '+suffix,outline,.018,'blue',low)
    tube('Shin embossed ridge '+suffix,[(x,-.154,.19),(x,-.17,.36),(x,-.177,.43)],.0035,'bronze',low)
    plate('Floating knee shield '+suffix,[(x-.062,-.144,.49),(x,-.166,.46),(x+.062,-.144,.49),(x+.057,-.15,.56),(x,-.174,.595),(x-.057,-.15,.56)],.014,'blue',low)
    for z in [.19,.41]:
        loft('Boot retaining strap '+suffix,[((x,-.068,z+dz),.075,.085) for dz in [-.012,.012]],'leather',low)
        box('Boot clasp '+suffix,(x+side*.065,-.12,z),(.024,.025,.028),'bronze',low,.004)
    plate('Outer thigh guard '+suffix,[(x+side*.025,-.124,.70),(x+side*.091,-.106,.74),(x+side*.10,-.088,.90),(x+side*.018,-.14,.91)],.01,'blue',up)

# Arms in the source T rest pose. Soft sleeves blend at elbows, armor follows
# the underlying long bone rigidly to avoid rubber plate deformation.
for side,suffix in [(-1,'R'),(1,'L')]:
    up='UpperArm.'+suffix;low='LowerArm.'+suffix
    def armw(v,up=up,low=low):
        t=clamp((abs(v.x)-.305)/.065);return {up:1-t,low:t}
    path=[(side*x,y,z) for x,y,z in [(.145,-.058,1.432),(.21,-.058,1.431),(.285,-.058,1.432),(.332,-.057,1.432),(.40,-.066,1.432),(.49,-.077,1.432),(.566,-.085,1.432)]]
    tube('Articulated ivory sleeve '+suffix,path,[(.073,.076),(.070,.071),(.057,.062),(.052,.053),(.061,.062),(.048,.049),(.034,.036)],'cloth',armw,24)
    # Shoulder cap: curved shell over upper arm, flared hem with a bronze lip.
    vs=[];uv=[];fs=[];nx=12;na=20
    for j in range(nx+1):
        t=j/nx;x=side*lerp(.13,.285,t);rad=.087+.02*sin(pi*t)
        for i in range(na+1):
            a=lerp(-1.6,1.75,i/na);vs.append((x,-.056+sin(a)*rad,1.434+cos(a)*rad));uv.append((i/na,t))
    for j in range(nx):
        for i in range(na):
            a=j*(na+1)+i;fs.append((a,a+1,a+na+2,a+na+1))
    # Closed end returns make the cap a fitted shell rather than an open tube.
    for j in [0,nx]:
        idx=len(vs);vs.append((side*lerp(.13,.285,j/nx),-.056,1.434));uv.append((.5,j/nx))
        for i in range(na):fs.append((idx,j*(na+1)+i,j*(na+1)+i+1))
    mesh('Swept pauldron '+suffix,vs,fs,'blue',up,uv)
    for t in [0,1]:
        tube('Pauldrons rolled rim '+suffix,[(side*lerp(.13,.285,t),-.056+sin(a)*.088,1.434+cos(a)*.088) for a in [lerp(-1.6,1.75,i/24) for i in range(25)]],.005,'bronze',up)
    # Vambrace is a tapered hard shell, distinct from cuff/sleeve.
    tube('Tapered forearm shell '+suffix,[(side*.415,-.068,1.432),(side*.46,-.073,1.432),(side*.535,-.082,1.432)],[(.066,.065),(.062,.058),(.044,.044)],'blue',low,24)
    for x in [.424,.524]:
        tube('Forearm leather band '+suffix,[(side*(x-.009),-.078,1.432),(side*(x+.009),-.078,1.432)],[(.065 if x<.5 else .046,)*2]*2,'leather',low,24)
    # Anatomical palms, separated thumb/finger phalanges with joint blends.
    palm='Middle1.'+suffix
    ellipsoid('Gloved palm '+suffix,(side*.66,-.086,1.433),(.069,.048,.027),'leather',palm)
    for finger in ['Index','Middle','Ring','Pinky','Thumb']:
        names=[finger+str(k)+'.'+suffix for k in ([1,2,3] if finger=='Thumb' else [2,3,4])]
        pts=[tuple(rig.data.bones[n].head_local) for n in names]+[tuple(rig.data.bones[names[-1]].tail_local)]
        for j in range(3):
            r=.0105 if finger!='Pinky' else .0085
            tube('Glove '+finger+str(j)+suffix,[pts[j],tuple(Vector(pts[j]).lerp(Vector(pts[j+1]),.5)),pts[j+1]],[r,r*.96,r*.82],'leather',names[j],12)
            ellipsoid('Finger joint '+finger+str(j)+suffix,pts[j],(r,r,r),'leather',names[j],16,10)
    for i in range(3):
        ellipsoid('Knuckle guard '+suffix,(side*(.697+i*.006),-.113+i*.025,1.461),(.015,.012,.006),'blue',palm,16,10)

# Wide field belt with sewn edge, small buckle and practical medical pouches.
loft('Field belt',[((0,-.03,z),.16,.116) for z in [1.0,1.065]],'leather','Hips')
for z in [1.007,1.058]:
    tube('Belt stitching',[(.161*sin(a),-.03-.117*cos(a),z) for a in [2*pi*i/100 for i in range(101)]],.0015,'ivory','Hips',6)
box('Belt buckle',(0,-.155,1.032),(.059,.021,.048),'bronze','Hips',.005)
box('Buckle inset',(0,-.168,1.032),(.037,.005,.029),'leather','Hips',.004)
for side in [-1,1]:
    for j in range(2):
        x=side*(.088+j*.07); y=-.142+j*.026
        box('Field dressing pouch',(x,y,.987),(.063,.055,.108),'leather','Hips',.011)
        box('Ivory pouch flap',(x,y-.03,1.02),(.065,.012,.042),'cloth','Hips',.006)
        box('Pouch fastener',(x,y-.038,1.001),(.012,.008,.022),'bronze','Hips',.003)

# Scarf: multiple draped continuous cloth bands, with actual folds and a long
# asymmetric front end. Chest/torso weighting avoids a rigid mantle in a run.
vs=[];uv=[];fs=[];N=96;M=12
for j in range(M+1):
    t=j/M
    for i in range(N+1):
        a=2*pi*i/N
        front=max(0,cos(a));rad=lerp(.073,.154,t)
        x=rad*sin(a);y=-.035-rad*.89*cos(a)-.012*sin(t*pi*5+a)*sin(pi*t)-.032*front*t
        clearance=clamp((cos(a)-.05)/.35)*clamp((t-.2)/.4)
        y=lerp(y,min(y,-.195-.007*sin(a*4+t*pi*3)),clearance)
        z=1.508-.097*t-.07*front*t+.01*sin(a+1)*t
        vs.append((x,y,z));uv.append((i/N*2,t))
for j in range(M):
    for i in range(N):
        k=j*(N+1)+i;fs.append((k,k+1,k+N+2,k+N+1))
mesh('Draped layered ivory scarf',vs,fs,'cloth',body_weights,uv)
def cloth_panel(name,fn,weights,nx=16,ny=32):
    vs=[];uv=[];fs=[]
    for j in range(ny+1):
        for i in range(nx+1):
            u=i/nx;t=j/ny;vs.append(fn(u,t));uv.append((u,t))
    for j in range(ny):
        for i in range(nx):
            k=j*(nx+1)+i;fs.append((k,k+1,k+nx+2,k+nx+1))
    return mesh(name,vs,fs,'cloth',weights,uv)
cloth_panel('Diagonal scarf end',lambda u,t:(lerp(-.105,.082,t)+(u-.5)*lerp(.11,.085,t),-.19-.012*sin(u*pi*4+t)-.01*sin(t*pi),1.435-.30*t+.036*abs(u-.5)*t**8),body_weights)
# Split coat skirts use pelvis/upper-leg blends and deliberate standing clearance.
for side,suffix in [(-1,'R'),(1,'L')]:
    def skirtw(v,side=side,suffix=suffix):
        t=clamp((1.0-v.z)/.35)*.75;return {'Hips':1-t,'UpperLeg.'+suffix:t}
    cloth_panel('Split side tabard '+suffix,lambda u,t,side=side:(side*(.12+.065*t+(u-.5)*.145),-.015+.13*(u-.5)+.02*sin(u*pi*4)*t,1.02-.40*t+.06*abs(u-.5)*t**8),skirtw)
    cloth_panel('Rear split coat '+suffix,lambda u,t,side=side:(side*(.07+(u-.5)*.14+.025*t),.09+.085*t+.016*sin(u*pi*4)*t,1.02-.44*t+.055*abs(u-.5)*t**8),skirtw)

# Shaped diagonal carrying strap and pack. Clear of the arm sockets.
strap=bezier((-.13,-.15,1.43),(-.08,-.19,1.32),(.11,-.157,1.15),(.13,-.127,1.06))
tube('Broad equipment sling',strap,[(.016,.004)]*len(strap),'leather',body_weights,8)
ellipsoid('Round shoulder clasp',(-.126,-.165,1.42),(.025,.008,.025),'bronze','Chest',32,16)
ellipsoid('Clasp cobalt inset',(-.126,-.174,1.42),(.015,.003,.015),'blue','Chest',24,12)
box('Compact medical backpack',(0,.149,1.277),(.232,.12,.264),'leather','Torso',.03)
box('Medical pack ivory cover',(0,.22,1.30),(.204,.025,.18),'cloth','Torso',.02)
for x in [-.088,.088]:
    box('Pack vertical webbing',(x,.24,1.28),(.023,.012,.23),'leather','Torso',.004)
    box('Pack buckle',(x,.251,1.25),(.029,.009,.028),'bronze','Torso',.004)
for x in [-.067,0,.067]:
    tube('Field injector capsule',[(x,.25,1.18),(x,.25,1.25)],.014,'steel','Torso',16)
    tube('Capsule sealed cap',[(x,.25,1.24),(x,.25,1.26)],.015,'blue','Torso',16)
# Wrist medical module on left forearm; no gameplay or healing effect is added.
box('Wrist medical housing',(.472,-.08,1.50),(.101,.07,.032),'ivory','LowerArm.L',.009)
box('Medical dark display',(.472,-.08,1.519),(.068,.048,.007),'rubber','LowerArm.L',.003)
box('Medical indicator vertical',(.472,-.08,1.524),(.012,.034,.003),'teal','LowerArm.L',.001)
box('Medical indicator horizontal',(.472,-.08,1.524),(.038,.011,.003),'teal','LowerArm.L',.001)

# Original adult face. Continuous sculpted cranium, cheekbones, tapered jaw,
# chin, orbital hollows, integrated nose bridge/tip and philtrum. No donor head.
profiles=[(1.577,.023,.046,-.063),(1.59,.042,.059,-.053),(1.61,.062,.070,-.043),(1.635,.081,.078,-.034),(1.66,.094,.085,-.024),(1.69,.103,.091,-.019),(1.72,.105,.092,-.015),(1.75,.104,.098,-.014),(1.78,.102,.100,-.01),(1.81,.093,.091,-.005),(1.84,.068,.070,0),(1.862,.018,.023,0)]
def profile(z):
    for idx,(a,b) in enumerate(zip(profiles,profiles[1:])):
        if z<=b[0]:
            t=clamp((z-a[0])/(b[0]-a[0]));dz=b[0]-a[0]
            prev=profiles[max(0,idx-1)];nxt=profiles[min(len(profiles)-1,idx+2)]
            # Cubic Hermite sections retain continuous tangents through the jaw
            # and cheeks; smoothstep per ring produces horizontal scalloping.
            return tuple((2*t**3-3*t*t+1)*a[k]+(t**3-2*t*t+t)*dz*(b[k]-prev[k])/(b[0]-prev[0])+(-2*t**3+3*t*t)*b[k]+(t**3-t*t)*dz*(nxt[k]-a[k])/(nxt[0]-a[0]) for k in [1,2,3])
    return profiles[-1][1:]
def face_y(x,z):
    w,d,cy=profile(z);base=cy-d*sqrt(max(.001,1-(x/w)**2))
    # Projections forward are negative Y.
    base-=.022*gauss(x,0,.014)*gauss(z,1.715,.041)
    base-=.022*gauss(x,0,.018)*gauss(z,1.688,.013)
    base-=.009*(gauss(x,.017,.009)+gauss(x,-.017,.009))*gauss(z,1.683,.009)
    base-=.006*(gauss(x,.064,.027)+gauss(x,-.064,.027))*gauss(z,1.694,.025)
    base+=.006*(gauss(x,.043,.025)+gauss(x,-.043,.025))*gauss(z,1.733,.018)
    base-=.009*gauss(x,0,.040)*gauss(z,1.643,.016)
    base-=.009*gauss(x,0,.032)*gauss(z,1.604,.014)
    return base
vs=[];uv=[];fs=[];nz=128;nt=144
for j in range(nz+1):
    z=lerp(profiles[0][0],profiles[-1][0],j/nz);w,d,cy=profile(z)
    for i in range(nt+1):
        a=-pi+2*pi*i/nt;x=w*sin(a);y=cy-d*cos(a)
        if cos(a)>0: y=face_y(x,z)
        vs.append((x,y,z));uv.append((i/nt,j/nz))
for j in range(nz):
    for i in range(nt):
        k=j*(nt+1)+i;center=sum((Vector(vs[q]) for q in [k,k+1,k+nt+2,k+nt+1]),Vector())/4
        hole=any(((center.x-s*.043)/.024)**2+((center.z-1.731)/.009)**2<1 for s in [-1,1]) and center.y<-.07
        if not hole: fs.append((k,k+1,k+nt+2,k+nt+1))
mesh('Sculpted original woman face and cranium',vs,fs,'face','Head',uv)

for s in [-1,1]:
    # Visible sclera is an almond-shaped corneal cap, not an exposed sphere.
    x=s*.043;z=1.731;yc=-.101
    ev=[];eu=[];ef=[]
    for row in range(13):
        v=lerp(-1,1,row/12)
        for col in range(41):
            u=lerp(-1,1,col/40);dx=u*.024;dz=v*(1-u*u)**.6*.008
            ev.append((x+dx,yc-sqrt(max(.00001,.023**2-dx*dx-dz*dz)),z+dz));eu.append((col/40,row/12))
    for row in range(12):
        for col in range(40):
            k=row*41+col;ef.append((k,k+1,k+42,k+41))
    mesh('Almond sclera',ev,ef,'face','Head',eu)
    ellipsoid('Hazel iris',(x,-.1234,z),(.0072,.0015,.0072),'face','Head',32,16)
    ellipsoid('Pupil',(x,-.1252,z),(.0030,.0006,.0033),'face','Head',24,16)
    for upper in [True,False]:
        pts=[]
        for i in range(33):
            t=i/32;xx=x+lerp(-.024,.024,t);zz=z+(sin(pi*t)*(.009 if upper else -.007))+s*(xx-x)*.05
            yy=yc-sqrt(max(.00001,.023**2-(xx-x)**2-(zz-z)**2))-.001
            pts.append((xx,yy,zz))
        tube('Sculpted upper lid' if upper else 'Sculpted lower lid',pts,[.0015+.0006*sin(pi*i/32) for i in range(33)],'face','Head',8)
        # Skin annulus closes the transition from the eye rim into the orbit.
        lv=[];lf=[];lu=[]
        for j in range(5):
            t=j/4
            for i,(xx,yy,zz) in enumerate(pts):
                oz=zz+(1 if upper else -1)*.010*sin(pi*i/32)
                lv.append((xx,lerp(yy+.0008,face_y(xx,oz),t),lerp(zz,oz,t)));lu.append((i/32,t))
        for j in range(4):
            for i in range(32):
                k=j*33+i;lf.append((k,k+1,k+34,k+33))
        mesh('Orbital lid transition',lv,lf,'face','Head',lu)
        if upper: tube('Upper lash line',[(xx,yy-.0017,zz-.0005) for xx,yy,zz in pts],.00065,'hair','Head',6)
    # Brows are detailed in the projected source over modeled brow planes.
    # Ear bowl, helix and tragus, attached to the side of the skull.
    ellipsoid('Ear pinna',(s*.104,-.002,1.696),(.017,.014,.034),'skin','Head',28,20)
    ellipsoid('Ear concha',(s*.114,-.012,1.696),(.008,.004,.018),'lip','Head',24,16)
    tube('Ear helix',[(s*(.111+.009*sin(a)),-.014,1.697+.027*cos(a)) for a in [2*pi*i/36 for i in range(37)]],.0035,'skin','Head',8)
    ellipsoid('Nostril',(s*.013,-.142,1.679),(.0035,.0015,.0017),'nostril','Head',24,12)

# Closed lips with a cupid's bow, dimensional vermilion and a recessed seam.
for upper in [True,False]:
    vs=[];fs=[];uv=[]
    for j in range(5):
        t=j/4
        for i in range(49):
            u=lerp(-1,1,i/48);x=u*.033;seam=1.643+.0015*cos(u*pi)
            fullness=(1-u*u)*(.0045 if upper else .006)
            bow=(.0016*gauss(abs(u),.28,.16)-.0008*gauss(u,0,.15)) if upper else 0
            z=seam+(1 if upper else -1)*fullness*t+bow*t
            y=face_y(x,z)-.0035-.004*sin(pi*t)*(1-u*u)
            vs.append((x,y,z));uv.append((i/48,t))
    for j in range(4):
        for i in range(48):
            k=j*49+i;fs.append((k,k+1,k+50,k+49))
    mesh('Upper lip bow' if upper else 'Lower lip',vs,fs,'face','Head',uv)
tube('Quiet closed mouth line',[(u*.032,face_y(u*.032,1.644)-.004,1.643+.0015*cos(u*pi)) for u in [lerp(-1,1,i/32) for i in range(33)]],.00065,'nostril','Head',6)

# Hair cap has an irregular hairline and swept modeled locks. The braid lies
# behind the left shoulder, with decreasing strand thickness and bronze ties.
vs=[];uv=[];fs=[];N=80;M=32
for j in range(M+1):
    t=j/M
    for i in range(N+1):
        a=-pi+2*pi*i/N
        front=max(0,cos(a));end=2.45-1.13*front+.05*sin(a*5)
        theta=.02+t*end
        z=1.752+.128*cos(theta)
        w,d,cy=profile(min(z,1.862))
        rx=.118*sin(theta) if z>1.81 else w+.009
        ry=.124*sin(theta) if z>1.81 else d+.018
        vs.append((rx*sin(a),(.002 if z>1.81 else cy)-ry*cos(a),z))
        uv.append((i/N,t))
for j in range(M):
    for i in range(N):
        k=j*(N+1)+i;fs.append((k,k+1,k+N+2,k+N+1))
mesh('Contoured dark hair cap',vs,fs,'hair','Head',uv)
for k in range(38):
    a=lerp(-2.9,2.9,k/37)
    end=2.45-1.13*max(0,cos(a))+.05*sin(a*5)
    path=[]
    for j in range(41):
        t=j/40;theta=lerp(end,.16,t);az=a+.55*sin(t*pi/2)
        wave=.0025*sin(t*3*pi+k*.7)*sin(pi*t)
        z=1.752+(.131+wave)*cos(theta);w,d,cy=profile(min(z,1.862))
        rx=(.121+wave)*sin(theta) if z>1.81 else w+.012+wave
        ry=(.127+wave)*sin(theta) if z>1.81 else d+.021+wave
        path.append((rx*sin(az),(.002 if z>1.81 else cy)-ry*cos(az),z))
    tube('Swept sculpted hair lock %02d'%k,path,[(.0005+.0075*sin(pi*i/40)**.7,.0004+.003*sin(pi*i/40)**.7) for i in range(41)],'hair' if k%5 else 'hair_light','Head',8)
for s in [-1,1]:
    for k in range(3):
        p=bezier((s*(.07+k*.012),-.07,1.82-k*.008),(s*.14,-.09,1.78),(s*.13,-.075,1.68),(s*(.10+k*.011),-.035,1.64+k*.02),28)
        tube('Loose face framing lock',p,[(.0055*(1-i/32),.0035*(1-i/32)) for i in range(29)],'hair','Head',8)
def braidw(v):
    t=clamp((1.67-v.z)/.18);return {'Head':1-t,'Chest':t}
for strand in range(3):
    pts=[];rr=[]
    for j in range(90):
        t=j/89;a=t*6*pi+strand*2*pi/3;r=.018*(1-.55*t)
        pts.append((.07+.055*sin(t*pi*.7)+r*cos(a),.102+.022*t+r*sin(a),1.765-.37*t));rr.append(.014*(1-.60*t))
    tube('Interwoven braid strand',pts,rr,'hair' if strand!=1 else 'hair_light',braidw,10)
for z,x in [(1.72,.091),(1.41,.12)]:
    loft('Bronze braid binding',[((x,.113,z+dz),.025,.023) for dz in [-.011,.011]],'bronze',braidw,n=24)

# Original compact service pistol. Matches the existing trigger hand bind and
# offers an explicit muzzle marker for eventual gameplay integration.
gun='Middle1.R'
box('Service pistol slide',(-.852,-.149,1.465),(.194,.045,.047),'steel',gun,.007)
box('Cobalt pistol receiver',(-.819,-.151,1.434),(.13,.041,.035),'blue',gun,.006)
grip=box('Pistol grip',(-.757,-.149,1.399),(.048,.038,.085),'leather',gun,.007)
box('Pistol muzzle block',(-.951,-.149,1.465),(.015,.049,.048),'steel',gun,.004)
tube('Bore recess',[(-.960,-.149,1.465),(-.964,-.149,1.465)],.010,'rubber',gun,20)
box('Front sight',(-.931,-.149,1.495),(.016,.012,.012),'rubber',gun,.002)
for x in [-.80,-.785,-.77]: box('Slide serration',(x,-.174,1.466),(.004,.003,.029),'rubber',gun,.001)
tube('Trigger guard',[(-.804,-.149,1.43),(-.808,-.149,1.391),(-.776,-.149,1.377),(-.745,-.149,1.403)],.004,'steel',gun,8)

# Combine by material, retaining all authored vertex groups. Each material gets
# its own portable UV atlas. SourceUV remains editable; BakeUV is the export UV.
assets={}
for name,objs in groups.items():
    bpy.ops.object.select_all(action='DESELECT')
    for obj in objs:
        obj.select_set(True)
        for mod in list(obj.modifiers): obj.modifiers.remove(mod)
    bpy.context.view_layer.objects.active=objs[0];bpy.ops.object.join();obj=bpy.context.object
    obj.name='Leader_'+name;assets[name]=obj
    obj.data.uv_layers.new(name='BakeUV');obj.data.uv_layers.active_index=1
    bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=1.0,island_margin=.006);bpy.ops.object.mode_set(mode='OBJECT')
    mod=obj.modifiers.new('Shared skeleton skin','ARMATURE');mod.object=rig

source=bpy.data.images.load(str(SRC/'material_source.png'));source.pack()
face_source=bpy.data.images.load(str(SRC/'face_source.png'));face_source.pack()
colors={'bronze':(.26,.18,.085,1),'ivory':(.59,.53,.40,1),'rubber':(.017,.022,.026,1),'steel':(.12,.155,.18,1),'teal':(.05,.55,.58,1),'hair':(.025,.017,.013,1),'hair_light':(.046,.028,.017,1),'eye':(.52,.55,.47,1),'iris':(.11,.14,.057,1),'pupil':(.006,.009,.007,1),'lip':(.32,.122,.089,1),'nostril':(.092,.038,.026,1)}
authoring={}
for name,obj in assets.items():
    mat=bpy.data.materials.new('Leader '+name+' authoring');mat.use_nodes=True
    obj.data.materials.clear();obj.data.materials.append(mat)
    ns=mat.node_tree.nodes;ls=mat.node_tree.links;p=ns.get('Principled BSDF');p.inputs['Roughness'].default_value=.64
    if name=='face':
        coord=ns.new('ShaderNodeUVMap');coord.uv_map='SourceUV'
        tex=ns.new('ShaderNodeTexImage');tex.image=face_source;tex.extension='EXTEND';ls.new(coord.outputs[0],tex.inputs[0])
        attr=ns.new('ShaderNodeAttribute');attr.attribute_name='FaceProjection'
        blend=ns.new('ShaderNodeMixRGB');blend.blend_type='MIX';blend.inputs[1].default_value=(.43,.235,.13,1)
        ls.new(attr.outputs['Fac'],blend.inputs[0]);ls.new(tex.outputs[0],blend.inputs[2]);ls.new(blend.outputs[0],p.inputs['Base Color'])
        gray=ns.new('ShaderNodeRGBToBW');ls.new(tex.outputs[0],gray.inputs[0])
        bump=ns.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.12;bump.inputs['Distance'].default_value=.00008
        ls.new(gray.outputs[0],bump.inputs['Height']);ls.new(bump.outputs[0],p.inputs['Normal'])
        rough=ns.new('ShaderNodeValue');rough.outputs[0].default_value=.64
        authoring[name]=(mat,blend.outputs[0],rough.outputs[0])
    elif name in ['blue','cloth','leather','skin']:
        coord=ns.new('ShaderNodeUVMap');coord.uv_map='SourceUV'
        wrap=ns.new('ShaderNodeVectorMath');wrap.operation='FRACTION';ls.new(coord.outputs[0],wrap.inputs[0])
        mapping=ns.new('ShaderNodeVectorMath');mapping.operation='MULTIPLY_ADD'
        mapping.inputs[1].default_value=(.47,.47,1)
        mapping.inputs[2].default_value={'blue':(.015,.515,0),'cloth':(.515,.515,0),'leather':(.015,.015,0),'skin':(.515,.015,0)}[name]
        ls.new(wrap.outputs[0],mapping.inputs[0]);tex=ns.new('ShaderNodeTexImage');tex.image=source;ls.new(mapping.outputs[0],tex.inputs[0])
        tint=ns.new('ShaderNodeMixRGB');tint.blend_type='MULTIPLY';tint.inputs[0].default_value=1
        tint.inputs[2].default_value={'blue':(.7,.95,1.15,1),'cloth':(.9,.92,.95,1),'leather':(.63,.7,.76,1),'skin':(.8,.83,.77,1)}[name]
        ls.new(tex.outputs[0],tint.inputs[1]);ls.new(tint.outputs[0],p.inputs['Base Color'])
        gray=ns.new('ShaderNodeRGBToBW');ls.new(tex.outputs[0],gray.inputs[0])
        bump=ns.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.20
        bump.inputs['Distance'].default_value={'blue':.0005,'cloth':.00035,'leather':.0003,'skin':.00008}[name]
        ls.new(gray.outputs[0],bump.inputs['Height']);ls.new(bump.outputs[0],p.inputs['Normal'])
        rough=ns.new('ShaderNodeMapRange');rough.inputs['To Min'].default_value={'blue':.40,'cloth':.81,'leather':.58,'skin':.56}[name];rough.inputs['To Max'].default_value={'blue':.64,'cloth':.94,'leather':.78,'skin':.68}[name]
        ls.new(gray.outputs[0],rough.inputs[0]);ls.new(rough.outputs[0],p.inputs['Roughness'])
        if name=='blue':p.inputs['Metallic'].default_value=.25
        authoring[name]=(mat,tint.outputs[0],rough.outputs[0])
    else:
        p.inputs['Base Color'].default_value=colors[name]
        if name in ['bronze','steel']:p.inputs['Metallic'].default_value=.7;p.inputs['Roughness'].default_value=.43
        if name in ['eye','iris','pupil']:p.inputs['Roughness'].default_value=.23
        if name=='teal':p.inputs['Emission Color'].default_value=(.03,.27,.28,1);p.inputs['Emission Strength'].default_value=.35

print('GEOMETRY COMPLETE',sum(len(o.data.vertices) for o in assets.values()),flush=True)
bpy.ops.wm.save_as_mainfile(filepath=str(SRC/'leader_authoring.blend'))
if '--geometry-only' in sys.argv: sys.exit()
for name,(mat,color,roughness) in authoring.items():
    obj=assets[name];bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
    ns=mat.node_tree.nodes;ls=mat.node_tree.links;p=ns.get('Principled BSDF');out=ns.get('Material Output');target=ns.new('ShaderNodeTexImage');emit=ns.new('ShaderNodeEmission')
    resolution=2048 if name in ['blue','cloth','skin','face'] else 1024
    maps={}
    for channel,socket in [('albedo',color),('normal',None),('roughness',roughness)]:
        img=bpy.data.images.new('leader_'+name+'_'+channel,width=resolution,height=resolution,alpha=False)
        if channel!='albedo':img.colorspace_settings.name='Non-Color'
        target.image=img;ns.active=target
        if channel=='normal':ls.new(p.outputs[0],out.inputs[0])
        else:ls.new(socket,emit.inputs['Color']);ls.new(emit.outputs[0],out.inputs[0])
        bpy.ops.object.bake(type='NORMAL' if channel=='normal' else 'EMIT',margin=10,normal_space='TANGENT')
        img.filepath_raw=str(OUT/(img.name+'.png'));img.file_format='PNG';img.save();maps[channel]=img
        print('BAKED',img.name,flush=True)
    portable=bpy.data.materials.new('Leader '+name+' PBR');portable.use_nodes=True
    pn=portable.node_tree.nodes;pl=portable.node_tree.links;pb=pn.get('Principled BSDF')
    for channel,img in maps.items():
        t=pn.new('ShaderNodeTexImage');t.image=img
        uv=pn.new('ShaderNodeUVMap');uv.uv_map='BakeUV';pl.new(uv.outputs[0],t.inputs[0])
        if channel=='normal':
            norm=pn.new('ShaderNodeNormalMap');norm.uv_map='BakeUV';pl.new(t.outputs[0],norm.inputs['Color']);pl.new(norm.outputs[0],pb.inputs['Normal'])
        else:pl.new(t.outputs[0],pb.inputs['Base Color' if channel=='albedo' else 'Roughness'])
    if name=='blue':pb.inputs['Metallic'].default_value=.25
    obj.data.materials.clear();obj.data.materials.append(portable)

# Keep the portable-material inspection copy out of Git; the packed authoring
# source, baked PNGs and GLB already preserve the reproducible asset.
for img in bpy.data.images:
    if img.source=='FILE' or img.name.startswith('leader_'):img.pack()
rig.data.pose_position='POSE'
review_dir=ROOT/'artifacts/blue_leader';review_dir.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(review_dir/'leader_portable.blend'))
bpy.ops.object.select_all(action='DESELECT');rig.select_set(True)
triangles=0
for obj in assets.values():
    obj.select_set(True)
    bpy.context.view_layer.objects.active=obj
    mod=obj.modifiers.new('Portable triangulation','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.data.calc_loop_triangles();triangles+=len(obj.data.loop_triangles)
bpy.context.view_layer.objects.active=rig
bpy.ops.export_scene.gltf(filepath=str(OUT/'blue_leader.glb'),export_format='GLB',use_selection=True,export_tangents=True,export_animations=True,export_animation_mode='ACTIONS',export_cameras=False,export_lights=False)
info={'revision':1,'status':'Separate review candidate; visual acceptance pending','blender':bpy.app.version_string,'triangles':triangles,'materials':len(assets),'bones':len(rig.data.bones),'source_rig':'Quaternius Spacesuit.gltf (CC0); visible geometry entirely original','source_sha256':hashlib.sha256((ROOT/'assets/third_party/quaternius/modular_men/Spacesuit.gltf').read_bytes()).hexdigest(),'front':'Godot +Z','muzzle_bind_position_godot':[-.964,1.465,.149],'muzzle_bone':'Middle1.R','animations':[a.name for a in bpy.data.actions],'limits':['No facial rig or speech animation','Hair and split cloth are bone-skinned, not simulated','Healing equipment is visual only; mission integration awaits acceptance']}
(OUT/'asset_info.json').write_text(json.dumps(info,indent=2)+'\n')
print('LEADER COMPLETE',info,flush=True)
