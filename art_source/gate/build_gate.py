"""Original sanctuary gate. Blender --background --factory-startup --python this_file.
Blender Z up, facade faces -Y; exported Godot facade faces +Z. Units are metres.
Rebuild overwrites Gate study outputs only. No third-party geometry/add-ons.
"""
import bpy, bmesh, math, random, json
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
SRC = Path(__file__).resolve().parent
OUT = ROOT / 'assets/gate_study'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version = 0
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 8
rng = random.Random(709)
groups = {'stone': [], 'door': [], 'cloth': [], 'bronze': [], 'light': []}

def mesh(name, verts, faces, group='stone', bevel=.035):
    data = bpy.data.meshes.new(name)
    data.from_pydata(verts, [], faces); data.update()
    obj = bpy.data.objects.new(name, data); scene.collection.objects.link(obj)
    bpy.context.view_layer.objects.active = obj; obj.select_set(True)
    bm = bmesh.new(); bm.from_mesh(data)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces)); bm.to_mesh(data); bm.free()
    if bevel:
        mod = obj.modifiers.new('Worn arris', 'BEVEL'); mod.width = bevel; mod.segments = 3
        bpy.ops.object.modifier_apply(modifier=mod.name)
        for p in data.polygons: p.use_smooth = True
        mod = obj.modifiers.new('Broad stone face normals', 'WEIGHTED_NORMAL'); mod.keep_sharp = True
        bpy.ops.object.modifier_apply(modifier=mod.name)
    groups[group].append(obj); obj.select_set(False)
    return obj

def prism(name, outline, front, back, group='stone', bevel=.035):
    n = len(outline)
    verts = [(x,y,z) for y in (front,back) for x,z in outline]
    faces = [tuple(range(n-1,-1,-1)), tuple(range(n,2*n))]
    faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    return mesh(name, verts, faces, group, bevel)

def block(name, x, y, z, w, d, h, group='stone', chip=.06):
    # Clipped corners form physical wear, distinct from the material's fine cracks.
    c = min(chip,w*.15,h*.15)
    outline = [(x-w/2+c,z-h/2),(x+w/2-c*.3,z-h/2),(x+w/2,z-h/2+c),
               (x+w/2,z+h/2-c*1.6),(x+w/2-c,z+h/2),(x-w/2+c*.5,z+h/2),
               (x-w/2,z+h/2-c),(x-w/2,z-h/2+c*.7)]
    return prism(name,outline,y-d/2,y+d/2,group,min(.035,w*.1,h*.1))

def ribbon(name, path, width, front, depth, group='stone', joints=1, bevel=.025):
    # A curved architectural band constructed as fitted voussoirs, not rotated boxes.
    for start in range(0,len(path)-1,joints):
        stop = min(start+joints,len(path)-1)
        left=[]; right=[]
        for i in range(start,stop+1):
            p=Vector(path[i]); a=Vector(path[max(0,i-1)]); b=Vector(path[min(len(path)-1,i+1)])
            tangent=(b-a).normalized(); normal=Vector((-tangent.y,tangent.x))
            if i==start and start>0: p += tangent*.013
            if i==stop and stop<len(path)-1: p -= tangent*.013
            left.append(tuple(p+normal*width/2)); right.append(tuple(p-normal*width/2))
        prism(name+' %02d'%start,left+right[::-1],front,front+depth,group,bevel)

def bezier(a,b,c,d,n=28):
    return [tuple((1-t)**3*Vector(a)+3*(1-t)**2*t*Vector(b)+3*(1-t)*t*t*Vector(c)+t**3*Vector(d)) for t in [i/n for i in range(n+1)]]

def arch_path(width,spring,apex,base=1.36):
    left=[(-width,base),(-width,2.25),(-width,3.25),(-width,spring)]
    left+=bezier((-width,spring),(-width,spring+.7),(-width*.6,apex-.5),(0,apex),16)[1:]
    return left+[(-x,z) for x,z in left[-2::-1]]

# Broad worn processional stair. Each riser is several interlocking slabs.
for step in range(9):
    top=.15*(step+1); front=-5.1+step*.45; width=9.3-step*.16
    cuts=7 + step % 2
    for j in range(cuts):
        w=width/cuts
        block('Stair %02d slab %02d'%(step,j), -width/2+(j+.5)*w,front+.24,top/2,w-.018,.50,top,chip=.055)
# Landing and deep return floor.
for x in range(-3,4):
    block('Threshold flagstone',x*1.02,-.25,.66,1.0,2.2,1.32,chip=.06)

# Side masonry courses follow a curved silhouette and stop at the true portal opening.
for side in (-1,1):
    boundaries=[9.6,8.2,7.0,6.15,5.58,5.08,4.65]
    for col in range(6):
        x=side*(2.05+col*.92)
        inner=boundaries[col]; outer=boundaries[col+1]
        rows=math.floor(outer/.81)
        for row in range(rows):
            lo=row*.81+.025; hi=(row+1)*.81-.025
            if row==rows-1:
                profile=[(x-side*.455,lo),(x+side*.455,lo),
                         (x+side*.455,outer-.025),(x-side*.455,inner-.025)]
                prism('Sloping upper masonry course',profile,-.30,1.80,bevel=.05)
            else:
                block('Coursed facade',x,.75,(lo+hi)/2,.91,2.1,hi-lo,chip=.05+rng.random()*.09)
    # Continuous sculpted sweeps fan out from the high inner shoulder.
    for layer in range(3):
        path=bezier((side*(1.25+layer*.42),10.6-layer*.9),
                    (side*(1.7+layer*.7),7.35-layer*.65),
                    (side*5.1,6.15-layer*.65),(side*8.1,4.5-layer*.66),32)
        ribbon('Sweeping monumental rib',path,.45 if layer else .57,-.65-layer*.035,.75,joints=4)
    # Flared feet and tapered vertical fins, with inset carved face channels.
    for x,height in ((3.15,8.45),(6.4,6.45)):
        x*=side
        outline=[(x-.78,.05),(x+.78,.05),(x+.48,1.05),(x+.27,2.2),
                 (x+.27,height-.2),(x-.18,height+.2),(x-.32,2.1),(x-.55,.75)]
        prism('Flared sanctuary buttress',outline,-1.12,.60,bevel=.075)
        ribbon('Buttress face groove',[(x,.75),(x,2.0),(x,height-.38)],.105,-1.155,.025,'door',joints=3,bevel=.01)
        for z in (1.05,1.25,height-1.1):
            block('Buttress collar',x,-1.03,z,.78,.85,.13,chip=.025)

# Portal is recessed through multiple nested stone archivolts, leaving a real cavity.
for tier in range(4):
    path=arch_path(1.48+tier*.32,4.4+tier*.08,6.05+tier*.42)
    ribbon('Portal archivolt tier %d'%tier,path,.25,-.86+tier*.11,.45,joints=3)
# Door leaves behind the arch; dark carved stone with recessed bronze panels.
for side in (-1,1):
    outline=[(side*.035,1.35),(side*1.34,1.35),(side*1.34,4.38),(side*.97,4.98),(side*.035,5.75)]
    prism('Sealed recessed door leaf',outline,.52,.82,'door',.04)
    for i in range(3):
        x=side*(.24+i*.40)
        ribbon('Door incised vertical',[(x,1.6),(x,4.65-i*.19)],.022,.50,.025,'bronze',joints=2,bevel=.005)
    ribbon('Door inset outline',[(side*.14,1.55),(side*1.15,1.55),(side*1.15,4.3),(side*.88,4.73),(side*.14,5.28)],.05,.46,.06,'bronze',joints=5,bevel=.012)

# Header closes the space above the arch and carries the great seal.
prism('High carved tympanum',[(-1.92,6.2),(-1.95,8.55),(-.8,9.25),(0,9.9),(.8,9.25),(1.95,8.55),(1.92,6.2),(0,6.8)],-.22,1.6,bevel=.06)
seal_z=7.78
circle=[(math.sin(i*math.tau/96)*1.24,seal_z+math.cos(i*math.tau/96)*1.24) for i in range(97)]
prism('Seal recessed dark field',[(math.sin(i*math.tau/64)*1.11,seal_z+math.cos(i*math.tau/64)*1.11) for i in range(64)],-.42,-.25,'door',.02)
ribbon('Great seal outer carved ring',circle,.31,-.75,.40,joints=8,bevel=.035)
ribbon('Seal inner bronze inlay',[(x*.78,seal_z+(z-seal_z)*.78) for x,z in circle],.045,-.78,.045,'bronze',joints=96,bevel=.01)
for i in range(16):
    a=i*math.tau/16
    ribbon('Seal radial notch',[(math.sin(a)*1.13,seal_z+math.cos(a)*1.13),(math.sin(a)*1.34,seal_z+math.cos(a)*1.34)],.032,-.79,.035,'door',joints=2,bevel=.005)
# Long split crown blade connects the seal to the tall central silhouette.
for side in (-1,1):
    prism('Split crown spire',[(side*.065,6.55),(side*.22,7.15),(side*.22,10.8),(side*.17,11.9),(side*.065,12.3)],-1.0,-.42,bevel=.028)
ribbon('Seal axial bronze needle',[(0,6.8),(0,10.7)],.045,-1.045,.06,'bronze',joints=2,bevel=.009)

# Draped banners: explicit continuous cloth grid, attached along their entire top rod.
for side in (-1,1):
    cx=side*4.75; top=6.65; width=1.13; height=3.1; nx=20; nz=40
    verts=[]; faces=[]; uv=[]
    for j in range(nz+1):
        t=j/nz
        for i in range(nx+1):
            u=i/nx
            hem=.40*(1-abs(2*u-1))*(t**9)
            x=cx+(u-.5)*width+.065*math.sin(t*4+side)*t
            y=-1.02-.10*math.sin(u*math.pi*5+.7*t)*(.20+.8*t)-.18*math.sin(t*2.8)
            z=top-t*height+hem-.055*math.sin(u*math.pi)*(1-t)
            verts.append((x,y,z)); uv.append((u,1-t))
    for j in range(nz):
        for i in range(nx):
            k=j*(nx+1)+i; faces.append((k,k+1,k+nx+2,k+nx+1))
    obj=mesh('Hanging palatinate banner',verts,faces,'cloth',0)
    layer=obj.data.uv_layers.new(name='UVMap')
    for poly in obj.data.polygons:
        poly.use_smooth=True
        for loop in poly.loop_indices: layer.data[loop].uv=uv[obj.data.loops[loop].vertex_index]
    # Rod and two brackets physically meet the top edge of the textile.
    block('Banner suspension rod',cx,-1.015,top+.025,1.45,.10,.10,'bronze',.01)
    for dx in (-.58,.58):
        block('Banner wall bracket',cx+dx,-.62,top+.02,.09,.84,.16,'bronze',.01)

# Rubble at the feet uses individually clipped angular profiles, not spheres.
for side in (-1,1):
    for i in range(13):
        x=side*rng.uniform(3.8,7.7); y=rng.uniform(-2.25,.25)
        w=rng.uniform(.20,.75); h=rng.uniform(.12,.55)
        obj=block('Broken architectural fragment',x,y,h*.46,w,w*.8,h,chip=w*.22)
        obj.rotation_euler.z=rng.uniform(-.6,.6)
# Narrow light at the meeting doors. This is a sealed seam, not a luminous doorway.
block('Restrained violet door seam',0,.45,2.8,.025,.025,2.85,'light',.004)

def join_group(name):
    bpy.ops.object.select_all(action='DESELECT')
    for obj in groups[name]: obj.select_set(True)
    bpy.context.view_layer.objects.active=groups[name][0]; bpy.ops.object.join()
    obj=bpy.context.object; obj.name='Sanctuary '+name
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    if name!='cloth':
        bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
        bpy.ops.uv.smart_project(angle_limit=1.05,island_margin=.004)
        bpy.ops.object.mode_set(mode='OBJECT')
    return obj

assets={name:join_group(name) for name in groups}
source_images={key:bpy.data.images.load(str(SRC/file)) for key,file in [('stone','limestone_basecolor_source.png'),('cloth','banner_basecolor_source.png')]}
for img in source_images.values(): img.pack()
authoring={}
for name,obj in assets.items():
    mat=bpy.data.materials.new(name+' authoring'); mat.use_nodes=True
    obj.data.materials.clear(); obj.data.materials.append(mat)
    ns=mat.node_tree.nodes; ls=mat.node_tree.links; p=ns.get('Principled BSDF'); out=ns.get('Material Output')
    p.inputs['Roughness'].default_value=.85
    if name in ('stone','door','cloth'):
        tex=ns.new('ShaderNodeTexImage'); tex.image=source_images['cloth' if name=='cloth' else 'stone']
        if name!='cloth':
            coord=ns.new('ShaderNodeTexCoord'); scale=ns.new('ShaderNodeVectorMath'); scale.operation='SCALE'; scale.inputs['Scale'].default_value=.37
            ls.new(coord.outputs['Object'],scale.inputs[0]); ls.new(scale.outputs[0],tex.inputs[0]); tex.projection='BOX'; tex.projection_blend=.15
        tint=ns.new('ShaderNodeMixRGB'); tint.blend_type='MULTIPLY'; tint.inputs[0].default_value=1
        tint.inputs[2].default_value= {'stone':(.72,.74,.77,1),'door':(.14,.17,.21,1),'cloth':(.80,.80,.85,1)}[name]
        ls.new(tex.outputs['Color'],tint.inputs[1]); ls.new(tint.outputs[0],p.inputs['Base Color'])
        gray=ns.new('ShaderNodeRGBToBW'); ls.new(tex.outputs[0],gray.inputs[0])
        bump=ns.new('ShaderNodeBump'); bump.inputs['Strength'].default_value=.48 if name!='cloth' else .27
        bump.inputs['Distance'].default_value=.065 if name!='cloth' else .022
        ls.new(gray.outputs[0],bump.inputs['Height']); ls.new(bump.outputs[0],p.inputs['Normal'])
        rough=ns.new('ShaderNodeMapRange'); rough.inputs['To Min'].default_value=.73; rough.inputs['To Max'].default_value=.94
        ls.new(gray.outputs[0],rough.inputs[0]); ls.new(rough.outputs[0],p.inputs['Roughness'])
        authoring[name]=(mat,tint.outputs[0],rough.outputs[0])
    elif name=='bronze':
        p.inputs['Base Color'].default_value=(.25,.16,.065,1); p.inputs['Metallic'].default_value=.68; p.inputs['Roughness'].default_value=.54
    else:
        p.inputs['Base Color'].default_value=(.20,.045,.38,1); p.inputs['Emission Color'].default_value=(.32,.06,.60,1); p.inputs['Emission Strength'].default_value=2.0

bpy.ops.wm.save_as_mainfile(filepath=str(SRC/'gate_authoring.blend'))
for name,(mat,color,roughness) in authoring.items():
    obj=assets[name]; bpy.ops.object.select_all(action='DESELECT'); obj.select_set(True); bpy.context.view_layer.objects.active=obj
    ns=mat.node_tree.nodes; ls=mat.node_tree.links; p=ns.get('Principled BSDF'); out=ns.get('Material Output')
    target=ns.new('ShaderNodeTexImage'); emit=ns.new('ShaderNodeEmission')
    resolution=4096 if name=='stone' else 1024
    maps={}
    for channel,socket in [('albedo',color),('normal',None),('roughness',roughness)]:
        img=bpy.data.images.new('gate_'+name+'_'+channel,width=resolution,height=resolution,alpha=False)
        if channel!='albedo': img.colorspace_settings.name='Non-Color'
        target.image=img; ns.active=target
        if channel=='normal': ls.new(p.outputs[0],out.inputs[0])
        else: ls.new(socket,emit.inputs['Color']); ls.new(emit.outputs[0],out.inputs[0])
        bpy.ops.object.bake(type='NORMAL' if channel=='normal' else 'EMIT',margin=12,normal_space='TANGENT')
        img.filepath_raw=str(OUT/(img.name+'.png')); img.file_format='PNG'; img.save(); maps[channel]=img
        print('BAKED',img.name,flush=True)
    portable=bpy.data.materials.new('Gate '+name+' PBR'); portable.use_nodes=True
    pn=portable.node_tree.nodes; pl=portable.node_tree.links; pb=pn.get('Principled BSDF')
    for channel,img in maps.items():
        t=pn.new('ShaderNodeTexImage'); t.image=img
        if channel=='normal':
            norm=pn.new('ShaderNodeNormalMap'); pl.new(t.outputs[0],norm.inputs[0+1]); pl.new(norm.outputs[0],pb.inputs['Normal'])
        else: pl.new(t.outputs[0],pb.inputs['Base Color' if channel=='albedo' else 'Roughness'])
    if name=='cloth': portable.use_backface_culling=False
    obj.data.materials.clear(); obj.data.materials.append(portable)

bpy.ops.object.select_all(action='SELECT')
triangles=0
for obj in assets.values():
    bpy.context.view_layer.objects.active=obj
    mod=obj.modifiers.new('Portable triangles','TRIANGULATE'); bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.data.calc_loop_triangles(); triangles+=len(obj.data.loop_triangles)
bpy.ops.export_scene.gltf(filepath=str(OUT/'sanctuary_gate.glb'),export_format='GLB',use_selection=True,export_tangents=True,export_animations=False,export_cameras=False,export_lights=False)
stats={'revision':1,'blender':bpy.app.version_string,'triangles':triangles,'materials':5,'stone_texture_resolution':4096,'cloth_door_texture_resolution':1024,'height_m':12.3,'facade_width_m':16.8,'front':'Godot +Z','status':'Approved; integrated at scale 0.78 in the mission','source':'art_source/gate/gate_authoring.blend'}
(OUT/'asset_info.json').write_text(json.dumps(stats,indent=2)+'\n')
print('GATE COMPLETE',stats,flush=True)
