"""Clothed anatomical direction proof, not the finished animated leader.
Requires build_foundation.py first. Loads its packed foundation and exports a
native Godot-review bust with simple portable materials and source textures.
"""
import bpy,bmesh,math,json
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[3]
ART=ROOT/'artifacts/blue_leader/v2'
OUT=ROOT/'assets/blue_leader_study/v2';OUT.mkdir(parents=True,exist_ok=True)
SRC=Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(SRC/'anatomy_authoring.blend'))
bpy.context.preferences.filepaths.save_version=0
scene=bpy.context.scene
body=bpy.data.objects['Leader_anatomical_foundation']
# Keep full editable anatomy in foundation.blend. The review export is cropped
# below the breastplate; no unclothed full body is sent to the review scene.
for o in list(bpy.data.objects):
    if o.type=='ARMATURE':
        for child in list(o.children):
            matrix=child.matrix_world.copy();child.parent=None;child.matrix_world=matrix
        bpy.data.objects.remove(o,do_unlink=True)
meshes=[]
for o in list(bpy.data.objects):
    if o.type!='MESH':continue
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    bpy.ops.object.convert(target='MESH');o=bpy.context.object
    # Eye/brow/hair geometry remains fitted to the already customized body.
    bm=bmesh.new();bm.from_mesh(o.data)
    cutoff=1.38 if o==body else 1.14
    bmesh.ops.delete(bm,geom=[v for v in bm.verts if v.co.z<cutoff or (o==body and v.co.z<1.38 and abs(v.co.x)>.14)],context='VERTS')
    bm.to_mesh(o.data);bm.free()
    if o==body:
        # Core body uses several skin-region slots with the same atlas. One
        # shared skin shader avoids baking into another slot's source image.
        counts={i:0 for i in range(len(o.data.materials))}
        for p in o.data.polygons:counts[p.material_index]+=1
        skin=o.data.materials[max(counts,key=counts.get)].copy()
        o.data.materials.clear();o.data.materials.append(skin)
        for p in o.data.polygons:p.material_index=0
    meshes.append(o)

def material(name,color,metal=0,rough=.6):
    m=bpy.data.materials.new(name);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value=(*color,1);p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=rough
    return m
bronze=material('Muted bronze',(.23,.15,.065),.65,.42)
leather=material('Dark leather',(.035,.024,.017),0,.75)
ivory=material('Weathered ivory',(.58,.51,.37),0,.85)
blue=material('Cobalt enamel',(.022,.065,.20),.35,.45)
atlas=bpy.data.images.load(str(ROOT/'art_source/blue_leader/material_source.png'))
for mat,offset in [(blue,(.015,.515,0)),(ivory,(.515,.515,0))]:
    ns=mat.node_tree.nodes;ls=mat.node_tree.links;p=ns.get('Principled BSDF')
    uv=ns.new('ShaderNodeTexCoord');scale=ns.new('ShaderNodeVectorMath');scale.operation='MULTIPLY_ADD';scale.inputs[1].default_value=(.47,.47,1);scale.inputs[2].default_value=offset
    tex=ns.new('ShaderNodeTexImage');tex.image=atlas;ls.new(uv.outputs['UV'],scale.inputs[0]);ls.new(scale.outputs[0],tex.inputs[0]);ls.new(tex.outputs[0],p.inputs['Base Color'])

def mesh(name,vs,fs,mat,thick=.004,subdiv=1,uv=None):
    data=bpy.data.meshes.new(name);data.from_pydata(vs,[],fs);data.update()
    o=bpy.data.objects.new(name,data);scene.collection.objects.link(o);data.materials.append(mat)
    bm=bmesh.new();bm.from_mesh(data);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(data);bm.free()
    for p in data.polygons:p.use_smooth=True
    if uv:
        layer=data.uv_layers.new(name='UVMap')
        for li,l in enumerate(data.loops):layer.data[li].uv=uv[l.vertex_index]
    else:
        bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
        bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.uv.smart_project(island_margin=.01);bpy.ops.object.mode_set(mode='OBJECT')
    if subdiv:
        mod=o.modifiers.new('Formed surface','SUBSURF');mod.levels=subdiv
    if thick:
        mod=o.modifiers.new('Material thickness','SOLIDIFY');mod.thickness=thick
        mod=o.modifiers.new('Rounded seams','BEVEL');mod.width=.0018;mod.segments=2
    meshes.append(o);return o

def tube(name,path,radius,mat):
    curve=bpy.data.curves.new(name,'CURVE');curve.dimensions='3D';curve.resolution_u=12;curve.bevel_depth=radius;curve.bevel_resolution=3
    sp=curve.splines.new('BEZIER');sp.bezier_points.add(len(path)-1)
    for b,p in zip(sp.bezier_points,path):b.co=p;b.handle_left_type='AUTO';b.handle_right_type='AUTO'
    o=bpy.data.objects.new(name,curve);scene.collection.objects.link(o);o.data.materials.append(mat)
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o;bpy.ops.object.convert(target='MESH');meshes.append(o);return o

def panel(name,fn,mat,nx=24,ny=20,thick=.004):
    vs=[];fs=[];uv=[]
    for j in range(ny+1):
        for i in range(nx+1):vs.append(fn(i/nx,j/ny));uv.append((i/nx,j/ny))
    for j in range(ny):
        for i in range(nx):
            k=j*(nx+1)+i;fs.append((k,k+1,k+nx+2,k+nx+1))
    return mesh(name,vs,fs,mat,thick,1,uv)

# A solid torso shell with a neck opening and shaped shoulder transitions.
# Profile is deliberately broad over the rib cage, not separate breast cups.
def cuirass(u,t):
    a=(u-.5)*math.tau;z=1.13+t*(.20-.045*max(0,math.cos(a))**6)
    rx=.19-.026*math.sin(t*math.pi);ry=.128-.020*t
    return (rx*math.sin(a),-.008-ry*math.cos(a),z)
panel('Protective cuirass',cuirass,blue,64,20,.012)
for t in [.035,.94]:tube('Cuirass rolled border',[cuirass(i/80,t) for i in range(81)],.003,bronze)
for side in [-1,1]:
    # Two curved laminated plates protect each shoulder. Unlike v1's barrels,
    # these are continuous domes with flared lower edges and explicit thickness.
    for layer in [0,1]:
        def shell(u,t,side=side,layer=layer):
            a=(u-.5)*math.pi*1.23
            r=.09+layer*.009
            x=side*(.15+t*.11+layer*.025)
            z=1.285+.075*math.sin(math.pi*(t*.72+.15))-layer*.045
            return (x,-.012-r*math.sin(a),z+r*.60*math.cos(a)-t*.035)
        panel('Layered shoulder shell',shell,blue,24,12,.006)
        tube('Shoulder metal edge',[shell(i/32,1) for i in range(33)],.0035,bronze)
        for u in [.12,.88]:
            p=Vector(shell(u,.83));bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,radius=.005,location=p)
            o=bpy.context.object;o.name='Recessed shoulder rivet';o.data.materials.append(bronze);meshes.append(o)

# Draped scarf wraps the neck in three folds and crosses the chest diagonally.
def scarf(u,t):
    a=u*math.tau;front=max(0,math.cos(a));r=.067+t*.075+.006*math.sin(t*math.pi*6+a)
    return(r*math.sin(a),-.012-r*.90*math.cos(a)-.055*front*t,1.405-t*(.074+.074*front)+.008*math.sin(a*2)*t)
panel('Wrapped scarf folds',scarf,ivory,80,28,.003)
def tail(u,t):
    return(-.105+.20*t+(u-.5)*(.10-.03*t),-.164-.018*math.sin(u*math.pi*3+t)-.01*math.sin(t*math.pi),1.34-.22*t+.025*math.cos(u*math.pi*2)*t**7)
panel('Overlapping scarf end',tail,ivory,24,30,.002)
tube('Leather carrying strap',[(-.123,-.128,1.35),(-.07,-.176,1.29),(.015,-.165,1.21),(.12,-.145,1.14)],.012,leather)
bpy.ops.mesh.primitive_uv_sphere_add(segments=40,ring_count=20,location=(-.126,-.148,1.333));clasp=bpy.context.object;clasp.name='Scarf bronze clasp';clasp.scale=(.021,.006,.021);clasp.data.materials.append(bronze);meshes.append(clasp)

# Work directly with the mapped hair asset; keep it dark rather than the
# source's light brown. This is a provisional tied-back style, not final hair.
hair=bpy.data.objects.get('Leader_Hair')
for mat in hair.data.materials:
    p=next((n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED'),None)
    if p and p.inputs['Base Color'].is_linked:
        ns=mat.node_tree.nodes;ls=mat.node_tree.links;source=p.inputs['Base Color'].links[0].from_socket
        tint=ns.new('ShaderNodeMixRGB');tint.blend_type='MULTIPLY';tint.inputs[0].default_value=1;tint.inputs[2].default_value=(.16,.13,.11,1);ls.new(source,tint.inputs[1]);ls.new(tint.outputs[0],p.inputs['Base Color']);p.inputs['Roughness'].default_value=.47

# Bake complex authoring colors to the existing UVs, while retaining material
# alpha and separate eye surfaces. Export contains no source-only shader nodes.
scene.cycles.samples=4
for o in meshes:
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    bpy.ops.object.convert(target='MESH')
    if not o.data.uv_layers:continue
    if o.name in ['Leader_Eyes','Leader_Eyebrows','Leader_Eyelashes','Leader_Hair']:
        # Keep the core UV/alpha maps together. Baking RGB alone while retaining
        # a second alpha image causes glTF texture packing to misalign cards.
        for mat in o.data.materials:
            p=next((n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED'),None)
            tex=next((n for n in mat.node_tree.nodes if n.type=='TEX_IMAGE' and n.image),None)
            if p and tex:mat.node_tree.links.new(tex.outputs['Color'],p.inputs['Base Color'])
        continue
    for mi,mat in enumerate(list(o.data.materials)):
        if not mat or not mat.use_nodes:continue
        p=next((n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED'),None)
        if not p or not p.inputs['Base Color'].is_linked:continue
        # Materials are shared by pauldrons: bake only the reusable UV-mapped
        # quadrant texture once by connecting its cropped source directly.
        # A material-specific bake below uses its source UV layout per object.
        mat=mat.copy();o.data.materials[mi]=mat
        ns=mat.node_tree.nodes;ls=mat.node_tree.links;p=next(n for n in ns if n.type=='BSDF_PRINCIPLED');out=next(n for n in ns if n.type=='OUTPUT_MATERIAL')
        color=p.inputs['Base Color'].links[0].from_socket
        img=bpy.data.images.new(o.name.replace(' ','_')+'_color',width=2048 if o==body else 1024,height=2048 if o==body else 1024,alpha=False)
        node=ns.new('ShaderNodeTexImage');node.image=img;ns.active=node
        emit=ns.new('ShaderNodeEmission');ls.new(color,emit.inputs[0]);ls.new(emit.outputs[0],out.inputs[0]);bpy.ops.object.bake(type='EMIT',margin=8)
        ls.new(p.outputs[0],out.inputs[0]);ls.new(node.outputs[0],p.inputs['Base Color'])
        img.filepath_raw=str(ART/(img.name+'.png'));img.file_format='PNG';img.save();img.pack()
        print('BAKED',o.name,flush=True)

scene.cycles.samples=48
scene.render.resolution_x=1200;scene.render.resolution_y=1200
focus=Vector((0,-.025,1.425));cam=scene.camera;cam.data.ortho_scale=.65
for label,angle in [('bust_front',0),('bust_threequarter',-.55),('bust_profile',-1.3)]:
    cam.location=focus+Vector((math.sin(angle)*3,-math.cos(angle)*3,.03));cam.rotation_euler=(focus-cam.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(ART/(label+'.png'));bpy.ops.render.render(write_still=True)
cam.location=focus+Vector((-1.5,-3,.03));cam.rotation_euler=(focus-cam.location).to_track_quat('-Z','Y').to_euler()
for img in bpy.data.images:
    if img.source=='FILE':img.pack()
bpy.ops.wm.save_as_mainfile(filepath=str(SRC/'leader_bust_authoring.blend'))
bpy.ops.object.select_all(action='DESELECT')
for o in meshes:o.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(ART/'leader_bust_pending.glb'),export_format='GLB',use_selection=True,export_animations=False,export_cameras=False,export_lights=False)
(ART/'leader_bust_pending.glb').replace(OUT/'leader_bust.glb')
print('BUST PROOF COMPLETE',flush=True)
