"""Original Debris 01. Blender 5.2 --background --factory-startup --python this_file.
Metres, Z up; Godot conversion is (x,z,-y). No add-ons or downloaded assets.
Rebuild overwrites this study only. Preserve hand edits before rebuilding.
"""
import bpy, bmesh, math, random, json, sys
from pathlib import Path
from mathutils import Vector

SRC=Path(__file__).resolve().parent; ROOT=SRC.parents[1]
OUT=ROOT/'assets/debris_study'; OUT.mkdir(parents=True,exist_ok=True)
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'art_source/waterworks'))
from share_pbr import share_pbr
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
scene=bpy.context.scene; scene.render.engine='CYCLES'; scene.cycles.samples=4
rng=random.Random(1041126); kits={}; kit='ruin_fall'

def tile(name,source,tint,relief,rough,metal=0):
    bpy.ops.mesh.primitive_plane_add(size=2); plane=bpy.context.object
    mat=bpy.data.materials.new(name+' source'); mat.use_nodes=True
    n,l=mat.node_tree.nodes,mat.node_tree.links; p=n.get('Principled BSDF'); out=n.get('Material Output')
    tex=n.new('ShaderNodeTexImage'); tex.image=bpy.data.images.load(str(source)); tex.image.pack()
    grade=n.new('ShaderNodeMixRGB'); grade.blend_type='MULTIPLY'; grade.inputs[0].default_value=1
    grade.inputs[2].default_value=(*tint,1); l.new(tex.outputs[0],grade.inputs[1]); l.new(grade.outputs[0],p.inputs['Base Color'])
    bump=n.new('ShaderNodeBump'); bump.inputs['Strength'].default_value=.38; bump.inputs['Distance'].default_value=relief
    l.new(tex.outputs[0],bump.inputs['Height']); l.new(bump.outputs[0],p.inputs['Normal'])
    p.inputs['Roughness'].default_value=rough; plane.data.materials.append(mat)
    target=n.new('ShaderNodeTexImage'); emit=n.new('ShaderNodeEmission'); maps={}
    for channel in ('albedo','normal','roughness'):
        img=bpy.data.images.new('debris_'+name+'_'+channel,width=1024,height=1024,alpha=False)
        if channel!='albedo':img.colorspace_settings.name='Non-Color'
        target.image=img; n.active=target
        if channel=='normal':l.new(p.outputs[0],out.inputs[0])
        else:
            for link in list(emit.inputs['Color'].links):l.remove(link)
            if channel=='albedo':l.new(grade.outputs[0],emit.inputs['Color'])
            else:emit.inputs['Color'].default_value=(rough,rough,rough,1)
            l.new(emit.outputs[0],out.inputs[0])
        bpy.ops.object.bake(type='NORMAL' if channel=='normal' else 'EMIT',margin=8)
        img.filepath_raw=str(OUT/(img.name+'.png')); img.file_format='PNG'; img.save(); img.pack(); maps[channel]=img
    bpy.data.objects.remove(plane,do_unlink=True)
    portable=bpy.data.materials.new('Debris '+name+' PBR'); portable.use_nodes=True
    n,l=portable.node_tree.nodes,portable.node_tree.links; p=n.get('Principled BSDF'); p.inputs['Metallic'].default_value=metal
    for channel,img in maps.items():
        t=n.new('ShaderNodeTexImage'); t.image=img
        if channel=='normal':
            normal=n.new('ShaderNodeNormalMap'); l.new(t.outputs[0],normal.inputs['Color']); l.new(normal.outputs[0],p.inputs['Normal'])
        else:l.new(t.outputs[0],p.inputs['Base Color' if channel=='albedo' else 'Roughness'])
    return portable

stone=tile('stone',ROOT/'art_source/gate/v2/aged_limestone_source.png',(.83,.84,.80),.035,.9)
rock=tile('rock',ROOT/'art_source/terrain/cliff_source.png',(.76,.82,.88),.026,.93)
wood=tile('wood',SRC/'deadwood_source.png',(.67,.63,.56),.018,.94)
metal=tile('metal',ROOT/'art_source/waterworks/aged_pipe_source.png',(.55,.62,.61),.012,.76,.45)

def mesh(name,verts,faces,mat,uvs=None,bevel=.018,smooth=False):
    me=bpy.data.meshes.new(name); me.from_pydata(verts,[],faces); me.update()
    ob=bpy.data.objects.new(name,me); scene.collection.objects.link(ob); me.materials.append(mat)
    uv=me.uv_layers.new(name='Mapped material metres')
    for p in me.polygons:
        axis=max(range(3),key=lambda i:abs(p.normal[i])); axes=((1,2),(0,2),(0,1))[axis]
        for li in p.loop_indices:
            vi=me.loops[li].vertex_index; v=me.vertices[vi].co
            uv.data[li].uv=uvs[vi] if uvs else (v[axes[0]]/1.8,v[axes[1]]/1.8)
    bm=bmesh.new(); bm.from_mesh(me); bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(me); bm.free()
    bpy.ops.object.select_all(action='DESELECT'); ob.select_set(True); bpy.context.view_layer.objects.active=ob
    if bevel:
        mod=ob.modifiers.new('Chipped softened arris','BEVEL'); mod.width=bevel; mod.segments=2
        bpy.ops.object.modifier_apply(modifier=mod.name)
        for p in me.polygons:p.use_smooth=True
        mod=ob.modifiers.new('Broad face normals','WEIGHTED_NORMAL'); mod.keep_sharp=True; bpy.ops.object.modifier_apply(modifier=mod.name)
    elif smooth:
        for p in me.polygons:p.use_smooth=True
    ob['kit']=kit; kits.setdefault(kit,[]).append(ob); ob.select_set(False)
    return ob

def shard(name,outline,h,mat=stone,base=-.025,tilt=(0,0),bevel=.016):
    # Three distinct contours form broken shoulders, a sloping fracture top and a buried sole.
    n=len(outline); cx=sum(x for x,y in outline)/n; cy=sum(y for x,y in outline)/n
    verts=[]
    for layer in range(3):
        for i,(x,y) in enumerate(outline):
            k=(.91,1,.88+.055*math.sin(i*2.3))[layer]
            z=base if layer==0 else h*.72 if layer==1 else h+(x-cx)*tilt[0]+(y-cy)*tilt[1]
            verts.append((cx+(x-cx)*k,cy+(y-cy)*k,z))
    faces=[tuple(range(n-1,-1,-1)),tuple(range(2*n,3*n))]
    for layer in range(2):
        for i in range(n):a=layer*n+i; b=layer*n+(i+1)%n; faces.append((a,b,b+n,a+n))
    return mesh(name,verts,faces,mat,bevel=bevel)

def outline(cx,cy,w,d,angle=0):
    pts=[(-.50,-.34),(-.21,-.50),(.32,-.47),(.51,-.15),(.37,.34),(.12,.49),(-.40,.38),(-.52,.07)]
    return [(cx+x*w*math.cos(angle)-y*d*math.sin(angle),cy+x*w*math.sin(angle)+y*d*math.cos(angle)) for x,y in pts]

def band(name,path,width,height,mat=stone):
    verts=[]
    for i,p in enumerate(path):
        p=Vector(p); t=(Vector(path[min(i+1,len(path)-1)])-Vector(path[max(0,i-1)])).normalized()
        side=Vector((-t.y,t.x,0)).normalized()*width/2
        verts.extend([tuple(p-side),tuple(p+side),tuple(p-side+Vector((0,0,height))),tuple(p+side+Vector((0,0,height)))])
    faces=[(0,2,3,1)]
    for i in range(len(path)-1):
        a=i*4; b=a+4
        faces.extend([(a,b,b+1,a+1),(a+2,a+3,b+3,b+2),(a,a+2,b+2,b),(a+1,b+1,b+3,a+3)])
    a=(len(path)-1)*4; faces.append((a,a+1,a+3,a+2)); return mesh(name,verts,faces,mat,bevel=.008)

# Fallen lintel fragment retains a recessed face and broken carved border.
shard('Fallen inscribed lintel', [(-1.42,-.38),(-.70,-.48),(.34,-.40),(.73,-.13),(.50,.06),(.67,.30),(-.81,.43),(-1.39,.15)],.33,tilt=(.035,-.08))
band('Surviving carved outer rim',[(-1.23,-.23,.36),(-.70,-.28,.36),(.25,-.25,.40),(.47,-.10,.39)],.09,.055)
band('Interrupted inner moulding',[(-1.19,.20,.30),(-.75,.27,.31),(-.12,.21,.34),(.34,.20,.35)],.065,.038)
for i in range(4):
    x=-1.10+i*.32; band('Worn cross cut',[(x,-.12,.36),(x+.03,.06,.34)],.035,.018)
shard('Detached triangular corner',[(.88,-.37),(1.51,-.21),(1.26,.28),(.78,.16)],.19,tilt=(-.08,.02))
shard('Half buried facing slab',[(-.58,.59),(.24,.47),(.51,.83),(.29,1.02),(-.49,1.08)],.095)
for x,y,w,d in [(-1.5,.65,.31,.23),(.67,.67,.36,.29),(1.62,.42,.23,.18),(-.8,-.75,.21,.18)]:shard('Lintel spall',outline(x,y,w,d),.045,bevel=.006)

kit='cliff_spall'
for i,(x,y,w,d,h,a) in enumerate([(-.75,0,1.5,.78,.42,.3),(.4,.18,1.15,.8,.26,-.5),(-.1,-.65,.7,.4,.14,.4),(1.06,-.34,.52,.38,.17,-.2),(-1.25,-.5,.35,.29,.09,1.2),(.67,.8,.3,.27,.08,.2)]):
    shard('Detached bedding wedge %d'%i,outline(x,y,w,d,a),h,rock,tilt=(.04,-.06))

def branch(name,path,r0,r1,split=True):
    control=list(map(Vector,path)); path=[]
    # Interpolating growth curve passes through each deliberately placed fork node.
    for i in range(len(control)-1):
        a=control[max(0,i-1)]; b=control[i]; c=control[i+1]; d=control[min(len(control)-1,i+2)]
        for j in range(5):
            t=j/5
            path.append(.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t))
    path.append(control[-1]); sides=12; verts=[]; uv=[]; dist=0
    for i,p in enumerate(path):
        if i:dist+=(p-path[i-1]).length
        tangent=(path[min(i+1,len(path)-1)]-path[max(0,i-1)]).normalized()
        guide=Vector((0,0,1)) if abs(tangent.z)<.95 else Vector((0,1,0))
        u=tangent.cross(guide).normalized(); v=tangent.cross(u).normalized(); r=r0+(r1-r0)*i/(len(path)-1)
        for j in range(sides+1):
            a=j*math.tau/sides; scallop=1+.08*math.cos(j*2.1)
            q=p+(u*math.cos(a)+v*math.sin(a))*r*scallop
            if split and i==len(path)-1:q+=tangent*([.03,.14,-.04,.08,.20,-.03][j%6])
            verts.append(tuple(q)); uv.append((j/sides*.65,dist/.8))
    faces=[]; row=sides+1
    for i in range(len(path)-1):
        for j in range(sides):a=i*row+j; faces.append((a,a+1,a+row+1,a+row))
    faces.extend([tuple(range(sides-1,-1,-1)),tuple((len(path)-1)*row+j for j in range(sides))])
    return mesh(name,verts,faces,wood,uv,0,True)

kit='dead_bough'
path=[(-1.3,-.2,.14),(-.8,-.12,.18),(-.2,.03,.23),(.25,.18,.20),(.68,.38,.14),(1.07,.5,.10)]
branch('Storm fallen forked bough',path,.16,.055)
branch('Connected broken fork',[path[2],(.04,-.25,.26),(.43,-.57,.22),(.85,-.70,.16)],.085,.026)
branch('Snapped upper spur',[path[1],(-.69,.03,.38),(-.43,.20,.48)],.055,.026)
branch('Thin split twig',[path[4],(.55,.70,.19),(.81,.99,.09)],.035,.008)

kit='exposed_root'
# Only three short root ridges: placed under existing trunk roots, within radius 1.2.
for i,a in enumerate((.3,2.4,4.55)):
    pts=[(math.cos(a+t*.3)*r,math.sin(a+t*.3)*r,z) for t,r,z in [(0,.12,.14),(.3,.35,.13),(.6,.58,.075),(1,.91,.003)]]
    branch('Eroded exposed root %d'%i,pts,.062,.006,False)
    p=pts[2]; branch('Root hair fork',[p,(p[0]+.15,p[1]-.13,.035),(p[0]+.22,p[1]-.27,-.005)],.018,.002,False)

kit='wreckage'
# A collapsed small maintenance pallet, not a new vehicle or game object.
for i in range(4):
    x=-.53+i*.30; length=[1.46,1.1,1.63,.93][i]; y=-length/2
    poly=[(x-.12,y),(x+.09,y-.07),(x+.13,length/2-.14),(x+.04,length/2+.04),(x+.015,length/2-.21),(x-.035,length/2+.08),(x-.12,length/2-.09)]
    shard('Split maintenance board %d'%i,poly,.13+i*.016,wood,tilt=(0,.015),bevel=.006)
band('Bent retaining strap',[(-.76,-.30,.18),(-.30,-.30,.20),(.18,-.30,.24),(.64,-.28,.17),(.80,-.22,.06)],.075,.027,metal)
band('Separated strap end',[(-.75,.48,.025),(-.30,.41,.12),(-.03,.40,.18)],.075,.022,metal)
# Folded, torn sheet cover with rolled edge, kept a modest silhouette.
verts=[(.91,-.43,.025),(1.38,-.38,.035),(1.44,.03,.16),(1.30,.37,.36),(.98,.40,.30),(.79,.04,.10),
       (1.03,-.41,.04),(1.49,-.34,.06),(1.55,.03,.18),(1.41,.33,.36)]
cover=mesh('Torn bent pump cover',verts,[(0,1,2,5),(5,2,3,4),(1,7,8,2),(2,8,9,3),(0,6,7,1)],metal,bevel=0)
bpy.context.view_layer.objects.active=cover
mod=cover.modifiers.new('Actual sheet metal thickness','SOLIDIFY'); mod.thickness=.012
bpy.ops.object.modifier_apply(modifier=mod.name)

kit='paving_spall'
# Thin additions only; highest vertex <= .032 before Godot placement.
for i,(x,y,w,d,a) in enumerate([(-.7,.03,.61,.44,.3),(-.16,.19,.37,.34,-.5),(.38,.05,.44,.24,.7),(.78,.30,.22,.18,-.2),(.12,-.43,.17,.14,.1)]):
    shard('Flush paving edge fragment %d'%i,outline(x,y,w,d,a),.022+(i%2)*.006,base=-.025,bevel=.004)

# Pack editable, individually named components into laid-out collections.
layout={key:i*5 for i,key in enumerate(kits)}
for key,objects in kits.items():
    coll=bpy.data.collections.new(key); scene.collection.children.link(coll)
    for ob in objects:
        for old in list(ob.users_collection):old.objects.unlink(ob)
        coll.objects.link(ob); ob.location.x=layout[key]
bpy.ops.wm.save_as_mainfile(filepath=str(SRC/'debris_authoring.blend'))
stats={}
for key,objects in kits.items():
    bpy.ops.object.select_all(action='DESELECT')
    for ob in objects:
        ob.location.x=0; ob.select_set(True); bpy.context.view_layer.objects.active=ob
        mod=ob.modifiers.new('Stable export triangles','TRIANGULATE'); bpy.ops.object.modifier_apply(modifier=mod.name)
    # One mesh per kit, retain its material slots and authored UVs.
    bpy.context.view_layer.objects.active=objects[0]; bpy.ops.object.join(); ob=bpy.context.object; ob.name=key
    ob.data.calc_loop_triangles(); stats[key]=len(ob.data.loop_triangles)
    bpy.ops.export_scene.gltf(filepath=str(OUT/(key+'.glb')),export_format='GLB',use_selection=True,export_tangents=True,export_animations=False,export_cameras=False,export_lights=False)
    share_pbr(OUT/(key+'.glb')); ob.location.x=layout[key]
(OUT/'asset_info.json').write_text(json.dumps({'revision':1,'triangles':stats,'collision':False,'source':'art_source/debris/debris_authoring.blend','status':'Separate review candidate; not integrated','provenance':'Original geometry, built-in imagegen and reused original project sources; TEXTURE_SOURCES.md'},indent=2)+'\n')
print('DEBRIS COMPLETE',stats,flush=True)
