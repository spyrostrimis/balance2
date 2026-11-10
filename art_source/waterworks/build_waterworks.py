"""Original Waterworks 01. Blender --background --factory-startup --python this_file.
Metres, Z up; Blender -Y is Godot +Z. Deterministic, no add-ons.
Editable individual components are saved before UV atlas assembly and baking.
"""
import bpy, bmesh, math, random, json
import sys
from pathlib import Path
from mathutils import Vector

SRC = Path(__file__).resolve().parent
sys.path.insert(0,str(SRC))
from share_pbr import share_pbr
ROOT = SRC.parents[1]
OUT = ROOT / 'assets/waterworks_study'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version = 0
scene = bpy.context.scene; scene.render.engine = 'CYCLES'; scene.cycles.samples = 8
rng = random.Random(111026)
parts = {}; kit = 'cistern'

def mesh(name, verts, faces, material='stone', bevel=.018):
    data=bpy.data.meshes.new(name); data.from_pydata(verts,[],faces); data.update()
    obj=bpy.data.objects.new(name,data); scene.collection.objects.link(obj)
    bpy.context.view_layer.objects.active=obj; obj.select_set(True)
    bm=bmesh.new(); bm.from_mesh(data); bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(data); bm.free()
    if bevel:
        mod=obj.modifiers.new('Worn physical edges','BEVEL'); mod.width=bevel; mod.segments=3
        bpy.ops.object.modifier_apply(modifier=mod.name)
        for p in data.polygons:p.use_smooth=True
        mod=obj.modifiers.new('Broad face normals','WEIGHTED_NORMAL'); mod.keep_sharp=True
        bpy.ops.object.modifier_apply(modifier=mod.name)
    age=rng.uniform(.83,1.0) if material=='stone' else 1
    attr=data.color_attributes.new(name='Age',type='FLOAT_COLOR',domain='CORNER')
    for c in attr.data:c.color=(age,age,age,1)
    obj['kit']=kit; obj['surface']=material
    parts.setdefault((kit,material),[]).append(obj); obj.select_set(False)
    return obj

def slab(name, outline, bottom, top, material='stone', bevel=.025):
    # Convex clipped plan, explicit fan caps rather than concave ngons.
    n=len(outline); verts=[(x,y,z) for z in (bottom,top) for x,y in outline]
    faces=[tuple(range(n-1,-1,-1))]+[(n,n+i,n+i+1) for i in range(1,n-1)]
    faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    return mesh(name,verts,faces,material,bevel)

def block(name, center, size, material='stone', chip=.08, angle=0):
    x,y,z=center; w,d,h=size; c=min(chip,w*.24,d*.24)
    outline=[(-w/2+c,-d/2),(w/2-c*.4,-d/2),(w/2,-d/2+c*.7),(w/2,d/2-c),
             (w/2-c*1.7,d/2),(-w/2+c*.6,d/2),(-w/2,d/2-c*.7),(-w/2,-d/2+c)]
    outline=[(x+a*math.cos(angle)-b*math.sin(angle),y+a*math.sin(angle)+b*math.cos(angle)) for a,b in outline]
    return slab(name,outline,z-h/2,z+h/2,material,min(.028,h*.13))

def sector(name, inner, outer, start, end, bottom, top, material='stone', broken=False):
    n=max(3,int((end-start)*14)); verts=[]
    for z in (bottom,top):
        for r in (inner,outer):
            for i in range(n+1):
                a=start+(end-start)*i/n
                # Lost corners at the fracture ends make actual irregular break faces.
                zz=z
                if broken and z==top and i in (0,1,n-1,n):zz-=.045+(i%2)*.065
                rr=r+(rng.uniform(-.018,.018) if z==top else 0)
                verts.append((rr*math.cos(a),rr*math.sin(a),zz))
    k=n+1; faces=[]
    for i in range(n):
        faces += [(i,i+1,i+1+2*k,i+2*k),(k+i,3*k+i,3*k+i+1,k+i+1),
                  (2*k+i,2*k+i+1,3*k+i+1,3*k+i),(i,k+i,k+i+1,i+1)]
    faces += [(0,2*k,3*k,k),(n,k+n,3*k+n,2*k+n)]
    return mesh(name,verts,faces,material,.022)

def tube(name, points, radius, material='metal', sides=24, wall=.038, torn=False):
    # Double-walled swept pipe with open bores and explicit annular end faces.
    verts=[]; faces=[]; count=len(points)
    for layer in range(2):
        for i,p in enumerate(points):
            p=Vector(p); t=(Vector(points[min(i+1,count-1)])-Vector(points[max(0,i-1)])).normalized()
            guide=Vector((0,0,1)) if abs(t.z)<.9 else Vector((0,1,0))
            u=t.cross(guide).normalized(); v=t.cross(u).normalized()
            for j in range(sides):
                a=math.tau*j/sides; r=radius-layer*wall
                rag=(.024*math.sin(j*2.7)+(.065 if 3<=j<=6 else -.012)) if torn and i==count-1 else 0
                p2=p+t*rag+(u*math.cos(a)+v*math.sin(a))*(r+(rag*.3 if torn else 0))
                verts.append(tuple(p2))
    span=count*sides
    for layer in range(2):
        for i in range(count-1):
            for j in range(sides):
                a=layer*span+i*sides+j; b=layer*span+i*sides+(j+1)%sides
                faces.append((a,b,b+sides,a+sides))
    for i in (0,count-1):
        for j in range(sides):
            a=i*sides+j; b=i*sides+(j+1)%sides; faces.append((a,a+span,b+span,b))
    o=mesh(name,verts,faces,material,0)
    for f in o.data.polygons:f.use_smooth=True
    return o

def rod(name,a,b,r,material='iron',sides=10):
    return tube(name,[a,b],r,material,sides,r*.98)

def flange(x,y,z,axis=(1,0,0),radius=.31):
    p=Vector((x,y,z)); t=Vector(axis).normalized(); u=t.cross(Vector((0,0,1))).normalized()
    if u.length<.1:u=Vector((1,0,0))
    v=t.cross(u).normalized()
    tube('Raised bolted flange',[p-t*.055,p+t*.055],radius,'metal',32,radius-.188)
    for j in range(8):
        a=math.tau*j/8; q=p+(u*math.cos(a)+v*math.sin(a))*(radius-.044)
        rod('Hexagonal flange bolt',q-t*.074,q+t*.074,.025,'iron',6)

# Cistern: a curved, interlocking masonry vessel; the retained water sits below breach.
for j in range(14):
    a=j*math.tau/14
    sector('Radial bed slab',.01,2.08,a+.006,a+math.tau/14-.006,-.035,.13)
for row in range(3):
    n=18; gap_center=-.88; half_gap=(.19,.29,.40)[row]
    for j in range(n):
        a=j*math.tau/n+(row%2)*math.pi/n
        # Circular signed distance to the storm breach at the southeast rim.
        middle=a+math.pi/n; distance=abs((middle-gap_center+math.pi)%math.tau-math.pi)
        if distance<half_gap:continue
        sector('Curved ashlar course %d'%row,1.60,1.99,a+.009,a+math.tau/n-.009,.13+row*.29,.405+row*.29,
               broken=distance<half_gap+.4)
for j in range(18):
    a=j*math.tau/18; mid=a+math.pi/18
    if abs((mid+.88+math.pi)%math.tau-math.pi)<.49:continue
    near_break=abs((mid+.88+math.pi)%math.tau-math.pi)<.82
    sector('Overhanging worn coping',1.53,2.08,a+.01,a+math.tau/18-.01,1.015,1.19,broken=near_break)
# Dark mineral tide band near the bottom records a much fuller past reservoir.
for j in range(18):
    a=j*math.tau/18
    sector('Lower damp mineral liner',1.582,1.606,a+.005,a+math.tau/18-.005,.135,.29,'damp')
for j in range(6):
    a=-1.26+j*.135; r=1.65+(j%2)*.34
    block('Storm fallen coping', (r*math.cos(a),r*math.sin(a),.16),(.39,.30,.24),chip=.11,angle=a+.6)
for j in range(12):
    a=rng.uniform(-1.35,-.40); r=rng.uniform(1.7,2.25)
    block('Breach chips',(r*math.cos(a),r*math.sin(a),.055),(.12,.16,.09),chip=.05,angle=a)
# Modern inlet, displaced riser, separated flange, saddle support and valve.
tube('Cistern inlet',[(-1.40,.48,.64),(-1.80,.48,.64),(-2.20,.48,.46)],.205,torn=True)
flange(-2.15,.48,.48)
tube('Torn feed main',[(-5.05,.50,.34),(-4.30,.50,.34),(-3.55,.50,.34),(-2.60,.50,.35)],.205,torn=True)
for x in (-4.45,-3.47):
    flange(x,.50,.34)
    block('Cut stone pipe saddle',(x,.50,.09),(.42,.62,.18),chip=.09)
    # Strap hugs the real pipe, down to the bolts on each foot.
    pts=[(x,.5+math.cos(a)*.24,.34+math.sin(a)*.24) for a in [i*math.pi/12 for i in range(13)]]
    tube('Clamping saddle strap',pts,.027,'iron',8,.025)
    for y in (.23,.77):rod('Saddle anchor',(x,y,.13),(x,y,.22),.032,'iron',6)
block('Cast valve body',(-1.86,.47,.93),(.54,.53,.57),'metal',.12)
block('Removable inspection cover',(-1.86,.18,.95),(.40,.055,.38),'metal',.07)
for x in (-2.01,-1.71):
    for z in (.81,1.09):rod('Cover fastener',(x,.12,z),(x,.18,z),.024,'iron',6)
rod('Valve spindle',(-1.86,.47,1.10),(-1.86,.47,1.39),.043,'iron')
wheel=[(-1.86+.24*math.cos(a),.47+.24*math.sin(a),1.4) for a in [i*math.tau/40 for i in range(41)]]
tube('Hand valve wheel',wheel,.027,'iron',8,.026)
for j in range(5):
    a=j*math.tau/5; rod('Valve wheel spoke',(-1.86,.47,1.4),(-1.86+.24*math.cos(a),.47+.24*math.sin(a),1.4),.017)
tube('Storm buckled riser',[(-1.55,.64,.74),(-1.42,.64,1.14),(-1.14,.60,1.48)],.16,torn=True)

def pier(x,height,broken=False):
    block('Splayed pier footing',(x,0,.11),(1.28,1.25,.24),chip=.13)
    block('Chamfered plinth',(x,0,.30),(1.07,1.04,.17),chip=.07)
    for row in range(5 if not broken else 3):
        z=.41+row*.365
        block('Jointed pier shaft',(x,0,z+.17),(.76,.81,.34),chip=.045+(row%2)*.025)
        # Raised border fillets frame a recessed flat shaft face, repeated on both sides.
        for face in (-1,1):
            for dx in (-.29,.29):block('Pier face carved border',(x+dx,face*.425,z+.17),(.083,.09,.33),chip=.018)
    if broken:
        outline=[(x-.40,-.40),(x+.30,-.40),(x+.38,-.12),(x+.21,.38),(x-.37,.36)]
        o=slab('Exposed fractured pier core',outline,1.35,1.63,bevel=.018)
        for v in o.data.vertices:
            if v.co.z>1.5:v.co.z+=.14*math.sin(v.co.x*19+v.co.y*8)
    else:
        for z,w,d,h in [(2.27,.90,.96,.14),(2.40,1.05,1.10,.13),(2.55,1.31,1.25,.17)]:
            block('Moulded watercourse capital',(x,0,z),(w,d,h),chip=.055)
        for face in (-1,1):
            for dx in (-.25,0,.25):
                # Carved tapered flutes with chamfered tips, not painted ornament.
                block('Capital dentil',(x+dx,face*.50,2.30),(.14,.18,.16),chip=.025)

for variant in range(2):
    kit='aqueduct_%02d'%variant
    for i in range(3):pier(i*3.1,2.6 if i<2 else 1.3,i==2)
    # Main lintel spans only the first two piers. All solid overhead material >2.45m.
    # Fracture outline is asymmetric and the channel remains visibly hollow above.
    outline=[(-.62,-.48),(3.63,-.48),(3.89,-.24),(3.58,-.03),(3.83,.20),(3.54,.47),(-.62,.47)]
    slab('Fractured load bearing lintel',outline,2.61,2.91)
    for side in (-1,1):
        # Two carved face bands and a recessed frieze catch RTS light.
        block('Lintel lower moulding',(1.48,side*.49,2.66),(4.20,.11,.10),chip=.07)
        for j in range(3):
            start=-.59+j*1.40; end=start+1.375
            if j==2:
                # Explicit uneven fracture face; a missing top corner reveals the channel.
                front=side*.42-.095; back=side*.42+.095
                verts=[(start,front,2.90),(end+.12,front,2.90),(end-.20,front,3.08),(end-.07,front,3.18),(start,front,3.18),
                       (start,back,2.90),(end+.02,back,2.90),(end-.31,back,3.08),(end-.15,back,3.18),(start,back,3.18)]
                faces=[(0,1,2),(0,2,3),(0,3,4),(5,7,6),(5,8,7),(5,9,8)]
                faces += [(i,(i+1)%5,(i+1)%5+5,i+5) for i in range(5)]
                mesh('Jagged channel break',verts,faces,bevel=.018)
                block('Truncated channel lip',(start+.42,side*.44,3.21),(.84,.24,.09),chip=.08)
            else:
                block('Open channel sidewall',((start+end)/2,side*.42,3.04),(end-start,.18,.28),chip=.04)
                block('Channel worn lip',((start+end)/2,side*.44,3.21),(end-start+.02,.24,.09),chip=.04)
        for j in range(12):
            x=-.33+j*.32
            block('Frieze inset divider',(x,side*.492,2.81),(.045,.032,.15),chip=.008)
    # A short surviving channel stump atop the broken third pier, deliberately tilted.
    # Broken pier terminates in exposed masonry, not an intact replacement capital.
    shard=[(5.84,-.37),(6.15,-.40),(6.46,-.16),(6.25,.10),(5.86,.31)]
    slab('Jagged surviving pier shoulder',shard,1.43,1.75 if variant else 1.64,bevel=.024)
    for j in range(7):
        x=6.2+rng.uniform(-.55,.55); y=rng.uniform(-.50,.50)
        block('Fallen carved masonry',(x,y,rng.uniform(.06,.16)),(.32,.30,.20),chip=.11,angle=rng.random()*3)
    # Paper-thin spalls can sit outside registered pier circles without hiding routes.
    for j in range(9):
        x=rng.uniform(.9,5.6); y=rng.uniform(-.6,.6)
        block('Flush architectural spall',(x,y,.007),(.19,.25,.035),chip=.07,angle=rng.random()*3)

# The southern conduit is cosmetic like its predecessor; retain its low silhouette.
kit='conduit'
tube('Low conduit',[(-.56,0,.21),(-.10,0,.21),(.56,0,.21)],.175)
flange(-.44,0,.21,radius=.23)
kit='conduit_broken'
tube('Split low conduit',[(-.56,0,.21),(-.10,0,.21),(.43,.035,.18)],.175,torn=True)
flange(-.44,0,.21,radius=.23)

# Authoring materials: generated image sources, age attribute and modest recess AO.
sources={'stone':bpy.data.images.load(str(ROOT/'art_source/gate/v2/aged_limestone_source.png')),
         'metal':bpy.data.images.load(str(SRC/'aged_pipe_source.png'))}
for img in sources.values():img.pack()
authoring={}
for surface in ('stone','damp','metal','iron'):
    mat=bpy.data.materials.new('Waterworks '+surface+' authoring'); mat.use_nodes=True
    ns=mat.node_tree.nodes; ls=mat.node_tree.links; p=ns.get('Principled BSDF')
    tex=ns.new('ShaderNodeTexImage'); tex.image=sources['stone' if surface in ('stone','damp') else 'metal']
    coord=ns.new('ShaderNodeTexCoord'); scale=ns.new('ShaderNodeVectorMath'); scale.operation='SCALE'; scale.inputs['Scale'].default_value=.8
    ls.new(coord.outputs['Object'],scale.inputs[0]); ls.new(scale.outputs[0],tex.inputs[0]); tex.projection='BOX'; tex.projection_blend=.18
    tint=ns.new('ShaderNodeMixRGB'); tint.blend_type='MULTIPLY'; tint.inputs[0].default_value=1
    tint.inputs[2].default_value={'stone':(.79,.85,.91,1),'damp':(.24,.34,.27,1),'metal':(.88,.96,1,1),'iron':(.32,.34,.34,1)}[surface]
    ls.new(tex.outputs[0],tint.inputs[1]); color=tint.outputs[0]
    age=ns.new('ShaderNodeAttribute'); age.attribute_name='Age'
    mul=ns.new('ShaderNodeMixRGB'); mul.blend_type='MULTIPLY'; mul.inputs[0].default_value=1
    ls.new(color,mul.inputs[1]); ls.new(age.outputs['Color'],mul.inputs[2]); color=mul.outputs[0]
    ao=ns.new('ShaderNodeAmbientOcclusion'); ao.inputs['Distance'].default_value=.22; ao.samples=8
    soften=ns.new('ShaderNodeMapRange'); soften.inputs['To Min'].default_value=.66
    ls.new(ao.outputs['AO'],soften.inputs[0])
    mul=ns.new('ShaderNodeMixRGB'); mul.blend_type='MULTIPLY'; mul.inputs[0].default_value=1
    ls.new(color,mul.inputs[1]); ls.new(soften.outputs[0],mul.inputs[2]); color=mul.outputs[0]
    ls.new(color,p.inputs['Base Color'])
    gray=ns.new('ShaderNodeRGBToBW'); ls.new(tex.outputs[0],gray.inputs[0])
    bump=ns.new('ShaderNodeBump'); bump.inputs['Strength'].default_value=.32; bump.inputs['Distance'].default_value=.035 if surface in ('stone','damp') else .014
    ls.new(gray.outputs[0],bump.inputs['Height']); ls.new(bump.outputs[0],p.inputs['Normal'])
    rough=ns.new('ShaderNodeMapRange'); rough.inputs['To Min'].default_value=.76 if surface=='stone' else .58; rough.inputs['To Max'].default_value=.94
    ls.new(gray.outputs[0],rough.inputs[0]); ls.new(rough.outputs[0],p.inputs['Roughness'])
    p.inputs['Metallic'].default_value=.45 if surface=='iron' else .18 if surface=='metal' else 0
    authoring[surface]=(mat,color,rough.outputs[0])
    for (k,m),objects in parts.items():
        if m==surface:
            for o in objects:o.data.materials.append(mat)

# Keep editable parts in named collections with isolated kits for inspection.
for (k,m),objects in parts.items():
    coll=bpy.data.collections.get(k)
    if coll is None:coll=bpy.data.collections.new(k); scene.collection.children.link(coll)
    for obj in objects:
        for old in list(obj.users_collection):old.objects.unlink(obj)
        coll.objects.link(obj)
layout={'cistern':0,'aqueduct_00':18,'aqueduct_01':36,'conduit':54,'conduit_broken':58}
for (k,m),objects in parts.items():
    for obj in objects:obj.location.x=layout[k]
bpy.ops.wm.save_as_mainfile(filepath=str(SRC/'waterworks_authoring.blend'))
for objects in parts.values():
    for obj in objects:obj.location.x=0

# Join each kit/surface, triangulate before baking; UV pack each surface globally.
assets={}
for (k,m),objects in parts.items():
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]; bpy.ops.object.join(); obj=bpy.context.object; obj.name=k+'_'+m
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    tri=obj.modifiers.new('Stable bake triangulation','TRIANGULATE'); bpy.ops.object.modifier_apply(modifier=tri.name)
    # Separate source UV sets, then pack all kits of the same material together.
    assets[(k,m)]=obj
# Separate kits during baking so their AO never shadows unrelated variants.
for (k,m),obj in assets.items():obj.location.x=layout[k]
for surface in authoring:
    objs=[o for (k,m),o in assets.items() if m==surface]
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:o.select_set(True)
    bpy.context.view_layer.objects.active=objs[0]
    bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=1.05,island_margin=.006)
    bpy.ops.object.mode_set(mode='OBJECT')
    mat,color,roughness=authoring[surface]; ns=mat.node_tree.nodes; ls=mat.node_tree.links
    p=ns.get('Principled BSDF'); out=ns.get('Material Output'); target=ns.new('ShaderNodeTexImage'); emit=ns.new('ShaderNodeEmission')
    resolution=4096 if surface=='stone' else 2048 if surface=='metal' else 512
    maps={}
    for channel,socket in [('albedo',color),('normal',None),('roughness',roughness)]:
        img=bpy.data.images.new('waterworks_'+surface+'_'+channel,width=resolution,height=resolution,alpha=False)
        if channel!='albedo':img.colorspace_settings.name='Non-Color'
        target.image=img; ns.active=target
        if channel=='normal':ls.new(p.outputs[0],out.inputs[0])
        else:ls.new(socket,emit.inputs['Color']); ls.new(emit.outputs[0],out.inputs[0])
        bpy.ops.object.bake(type='NORMAL' if channel=='normal' else 'EMIT',margin=12,normal_space='TANGENT')
        img.filepath_raw=str(OUT/(img.name+'.png')); img.file_format='PNG'; img.save(); maps[channel]=img
        print('BAKED',img.name,flush=True)
    portable=bpy.data.materials.new('Waterworks '+surface+' PBR'); portable.use_nodes=True
    pn=portable.node_tree.nodes; pl=portable.node_tree.links; pb=pn.get('Principled BSDF')
    pb.inputs['Metallic'].default_value=p.inputs['Metallic'].default_value
    for channel,img in maps.items():
        t=pn.new('ShaderNodeTexImage'); t.image=img
        if channel=='normal':
            n=pn.new('ShaderNodeNormalMap'); pl.new(t.outputs[0],n.inputs['Color']); pl.new(n.outputs[0],pb.inputs['Normal'])
        else:pl.new(t.outputs[0],pb.inputs['Base Color' if channel=='albedo' else 'Roughness'])
    for obj in objs:obj.data.materials.clear(); obj.data.materials.append(portable)

stats={}
for k in sorted(set(k for k,m in assets)):
    bpy.ops.object.select_all(action='DESELECT'); triangles=0
    for (key,m),obj in assets.items():
        if key==k:
            obj.location.x=0
            obj.select_set(True); obj.data.calc_loop_triangles(); triangles+=len(obj.data.loop_triangles)
    bpy.ops.export_scene.gltf(filepath=str(OUT/(k+'.glb')),export_format='GLB',use_selection=True,export_tangents=True,export_animations=False,export_cameras=False,export_lights=False)
    share_pbr(OUT/(k+'.glb'))
    stats[k]=triangles
    for (key,m),obj in assets.items():
        if key==k:obj.location.x=layout[k]
(OUT/'asset_info.json').write_text(json.dumps({'revision':1,'triangles':stats,'source':'art_source/waterworks/waterworks_authoring.blend','collision':False,'units':'metres','status':'Separate review candidate; not accepted or integrated','provenance':'Original Blender geometry, built-in imagegen sources, portable baked PBR. See TEXTURE_SOURCES.md.'},indent=2)+'\n')
print('WATERWORKS COMPLETE',stats,flush=True)
